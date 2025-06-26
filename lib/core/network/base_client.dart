import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:mime/mime.dart';

import 'api_urls.dart';
import 'base_client_model.dart';

enum RequestMethodName { get, post, put, patch, delete }

class BaseClient {
  final http.Client _client;
  final Duration timeout;
  final String _baseUrl = ApiUrls.currentBaseURL;
  String? _accessToken;

  BaseClient({http.Client? client, this.timeout = const Duration(minutes: 1)})
    : _client = client ?? http.Client();

  // Set access token for authenticated requests
  void setAccessToken(String? token) {
    _accessToken = token;
  }

  // Get current access token
  String? get accessToken => _accessToken;

  /// Build URL with path parameters and query parameters
  Uri? _buildUrl({
    required String url,
    Map<String, String>? pathParams,
    Map<String, String>? queryParams,
  }) {
    String finalUrl = url.startsWith('http') ? url : '$_baseUrl$url';

    // Replace path parameters
    if (pathParams != null) {
      pathParams.forEach((key, value) {
        finalUrl = finalUrl.replaceAll(':$key', Uri.encodeComponent(value));
      });
    }

    try {
      final uri = Uri.parse(finalUrl);
      return queryParams != null
          ? uri.replace(
              queryParameters: {...uri.queryParameters, ...queryParams},
            )
          : uri;
    } catch (e) {
      if (kDebugMode) {
        print("URL parsing error: $e");
      }
      return null;
    }
  }

  /// Build headers with default headers and optional bearer token
  Map<String, String> _buildHeaders({
    Map<String, String>? headers,
    String? bearerToken,
  }) {
    final defaultHeaders = Map<String, String>.from(ApiHeaders.defaultHeaders);

    // Use provided bearer token, otherwise use stored access token
    final token = bearerToken ?? _accessToken;
    if (token != null) {
      defaultHeaders[ApiHeaders.authorization] = 'Bearer $token';
    }

    if (headers != null) {
      defaultHeaders.addAll(headers);
    }

    return defaultHeaders;
  }

  /// Encode request body to JSON string
  String? _encodeBody({dynamic body}) {
    if (body == null) return null;
    try {
      return jsonEncode(body);
    } catch (e) {
      if (kDebugMode) {
        print("Body encoding error: $e");
      }
      return null;
    }
  }

  /// Process HTTP response and return BaseClientModel
  BaseClientModel _processResponse({
    required http.Response response,
    required RequestMethodName method,
  }) {
    final statusCode = response.statusCode;
    final body = response.body;

    if (kDebugMode) {
      print(
        '${method.name.toUpperCase()} response: Status $statusCode, Body: $body',
      );
    }

    if (statusCode >= 200 && statusCode < 300) {
      dynamic data;
      if (body.isNotEmpty) {
        try {
          data = jsonDecode(body);
          if (kDebugMode) {
            print('${method.name.toUpperCase()} parsed data: $data');
          }
        } catch (e) {
          if (kDebugMode) {
            print('${method.name.toUpperCase()} parsing error: $e');
          }
          return const BaseClientModel.formatError();
        }
      }
      return BaseClientModel.success(data: data, statusCode: statusCode);
    }

    // Handle error responses
    dynamic data;
    if (body.isNotEmpty) {
      try {
        data = jsonDecode(body);
      } catch (e) {
        if (kDebugMode) {
          print('${method.name.toUpperCase()} error parsing error: $e');
        }
        return const BaseClientModel.formatError();
      }
    }

    return BaseClientModel.failure(
      message: data is Map<String, dynamic> && data['message'] != null
          ? data['message'] as String
          : 'Request failed with status $statusCode',
      data: data,
      statusCode: statusCode,
    );
  }

  /// Handle exceptions and return appropriate BaseClientModel
  BaseClientModel _handleException(
    dynamic error, {
    required RequestMethodName method,
  }) {
    if (kDebugMode) {
      print('${method.name.toUpperCase()} error: $error');
    }

    if (error is SocketException) {
      return const BaseClientModel.networkError();
    } else if (error is TimeoutException) {
      return const BaseClientModel.timeoutError();
    } else if (error is HttpException) {
      return BaseClientModel.unexpectedError(message: error.message);
    } else {
      return const BaseClientModel.unexpectedError();
    }
  }

  /// Perform GET request
  Future<BaseClientModel> get(
    String url, {
    Map<String, String>? headers,
    Map<String, String>? pathParams,
    Map<String, String>? queryParams,
    String? bearerToken,
  }) async {
    if (kDebugMode) {
      print('GET request: $url, Query: $queryParams, Path: $pathParams');
    }

    final uri = _buildUrl(
      url: url,
      queryParams: queryParams,
      pathParams: pathParams,
    );

    if (uri == null) {
      return const BaseClientModel.unexpectedError(
        message: 'Invalid URL format',
      );
    }

    final requestHeaders = _buildHeaders(
      headers: headers,
      bearerToken: bearerToken,
    );

    try {
      final response = await _client
          .get(uri, headers: requestHeaders)
          .timeout(
            timeout,
            onTimeout: () => throw TimeoutException('GET request timed out'),
          );
      return _processResponse(
        response: response,
        method: RequestMethodName.get,
      );
    } catch (error) {
      return _handleException(error, method: RequestMethodName.get);
    }
  }

  /// Perform POST request
  Future<BaseClientModel> post(
    String url, {
    Map<String, String>? headers,
    dynamic body,
    Map<String, String>? queryParams,
    Map<String, String>? pathParams,
    String? bearerToken,
  }) async {
    if (kDebugMode) {
      print(
        'POST request: $url, Query: $queryParams, Path: $pathParams, Body: $body',
      );
    }

    final uri = _buildUrl(
      url: url,
      pathParams: pathParams,
      queryParams: queryParams,
    );

    if (uri == null) {
      return const BaseClientModel.unexpectedError(
        message: 'Invalid URL format',
      );
    }

    final requestHeaders = _buildHeaders(
      headers: headers,
      bearerToken: bearerToken,
    );

    final encodedBody = _encodeBody(body: body);
    if (body != null && encodedBody == null) {
      return const BaseClientModel.unexpectedError(
        message: 'Failed to encode body',
      );
    }

    try {
      final response = await _client
          .post(uri, headers: requestHeaders, body: encodedBody)
          .timeout(
            timeout,
            onTimeout: () => throw TimeoutException('POST request timed out'),
          );
      return _processResponse(
        response: response,
        method: RequestMethodName.post,
      );
    } catch (error) {
      return _handleException(error, method: RequestMethodName.post);
    }
  }

  /// Perform POST request with form data and file uploads
  Future<BaseClientModel> postFormData(
    String url, {
    Map<String, String>? headers,
    Map<String, String>? formFields,
    Map<String, File>? files,
    Map<String, String>? queryParams,
    Map<String, String>? pathParams,
    String? bearerToken,
  }) async {
    if (kDebugMode) {
      print(
        'POST FormData request: $url, Query: $queryParams, Path: $pathParams, FormFields: $formFields, Files: ${files?.keys}',
      );
    }

    final uri = _buildUrl(
      url: url,
      pathParams: pathParams,
      queryParams: queryParams,
    );

    if (uri == null) {
      return const BaseClientModel.unexpectedError(
        message: 'Invalid URL format',
      );
    }

    final requestHeaders = _buildHeaders(
      headers: headers,
      bearerToken: bearerToken,
    );

    try {
      var request = http.MultipartRequest('POST', uri)
        ..headers.addAll(requestHeaders);

      // Add form fields
      if (formFields != null) {
        request.fields.addAll(formFields);
      }

      // Add files
      if (files != null) {
        for (var entry in files.entries) {
          final file = entry.value;
          if (await file.exists()) {
            final mimeType =
                lookupMimeType(file.path) ?? 'application/octet-stream';
            final mediaType = MediaType.parse(mimeType);

            request.files.add(
              await http.MultipartFile.fromPath(
                entry.key,
                file.path,
                contentType: mediaType,
              ),
            );
          } else {
            if (kDebugMode) {
              print('File not found: ${file.path}');
            }
            return const BaseClientModel.unexpectedError(
              message: 'File not found',
            );
          }
        }
      }

      final streamedResponse = await request.send().timeout(
        timeout,
        onTimeout: () =>
            throw TimeoutException('POST FormData request timed out'),
      );
      final response = await http.Response.fromStream(streamedResponse);

      return _processResponse(
        response: response,
        method: RequestMethodName.post,
      );
    } catch (error) {
      return _handleException(error, method: RequestMethodName.post);
    }
  }

  /// Perform PUT request
  Future<BaseClientModel> put(
    String url, {
    Map<String, String>? headers,
    dynamic body,
    Map<String, String>? pathParams,
    Map<String, String>? queryParams,
    String? bearerToken,
  }) async {
    if (kDebugMode) {
      print(
        'PUT request: $url, Query: $queryParams, Path: $pathParams, Body: $body',
      );
    }

    final uri = _buildUrl(
      url: url,
      pathParams: pathParams,
      queryParams: queryParams,
    );

    if (uri == null) {
      return const BaseClientModel.unexpectedError(
        message: 'Invalid URL format',
      );
    }

    final requestHeaders = _buildHeaders(
      headers: headers,
      bearerToken: bearerToken,
    );

    final encodedBody = _encodeBody(body: body);
    if (body != null && encodedBody == null) {
      return const BaseClientModel.unexpectedError(
        message: 'Failed to encode body',
      );
    }

    try {
      final response = await _client
          .put(uri, headers: requestHeaders, body: encodedBody)
          .timeout(
            timeout,
            onTimeout: () => throw TimeoutException('PUT request timed out'),
          );
      return _processResponse(
        response: response,
        method: RequestMethodName.put,
      );
    } catch (error) {
      return _handleException(error, method: RequestMethodName.put);
    }
  }

  /// Perform PATCH request
  Future<BaseClientModel> patch(
    String url, {
    Map<String, String>? headers,
    dynamic body,
    Map<String, String>? queryParams,
    Map<String, String>? pathParams,
    String? bearerToken,
  }) async {
    if (kDebugMode) {
      print(
        'PATCH request: $url, Query: $queryParams, Path: $pathParams, Body: $body',
      );
    }

    final uri = _buildUrl(
      url: url,
      queryParams: queryParams,
      pathParams: pathParams,
    );

    if (uri == null) {
      return const BaseClientModel.unexpectedError(
        message: 'Invalid URL format',
      );
    }

    final requestHeaders = _buildHeaders(
      headers: headers,
      bearerToken: bearerToken,
    );

    final encodedBody = _encodeBody(body: body);
    if (body != null && encodedBody == null) {
      return const BaseClientModel.unexpectedError(
        message: 'Failed to encode body',
      );
    }

    try {
      final response = await _client
          .patch(uri, headers: requestHeaders, body: encodedBody)
          .timeout(
            timeout,
            onTimeout: () => throw TimeoutException('PATCH request timed out'),
          );
      return _processResponse(
        response: response,
        method: RequestMethodName.patch,
      );
    } catch (error) {
      return _handleException(error, method: RequestMethodName.patch);
    }
  }

  /// Perform DELETE request
  Future<BaseClientModel> delete(
    String url, {
    Map<String, String>? headers,
    dynamic body,
    Map<String, String>? queryParams,
    Map<String, String>? pathParams,
    String? bearerToken,
  }) async {
    if (kDebugMode) {
      print(
        'DELETE request: $url, Query: $queryParams, Path: $pathParams, Body: $body',
      );
    }

    final uri = _buildUrl(
      url: url,
      queryParams: queryParams,
      pathParams: pathParams,
    );

    if (uri == null) {
      return const BaseClientModel.unexpectedError(
        message: 'Invalid URL format',
      );
    }

    final requestHeaders = _buildHeaders(
      headers: headers,
      bearerToken: bearerToken,
    );

    final encodedBody = _encodeBody(body: body);
    if (body != null && encodedBody == null) {
      return const BaseClientModel.unexpectedError(
        message: 'Failed to encode body',
      );
    }
    try {
      final response = await _client
          .delete(uri, headers: requestHeaders, body: encodedBody)
          .timeout(
            timeout,
            onTimeout: () => throw TimeoutException('DELETE request timed out'),
          );
      return _processResponse(
        response: response,
        method: RequestMethodName.delete,
      );
    } catch (error) {
      return _handleException(error, method: RequestMethodName.delete);
    }
  }

  /// Download file as bytes
  Future<BaseClientModel> downloadFile(
    String url, {
    Map<String, String>? headers,
    Map<String, String>? queryParams,
    String? bearerToken,
  }) async {
    if (kDebugMode) {
      print('Download request: $url, Query: $queryParams');
    }

    final uri = _buildUrl(url: url, queryParams: queryParams);

    if (uri == null) {
      return const BaseClientModel.unexpectedError(
        message: 'Invalid URL format',
      );
    }

    final requestHeaders = _buildHeaders(
      headers: headers,
      bearerToken: bearerToken,
    );

    try {
      final response = await _client
          .get(uri, headers: requestHeaders)
          .timeout(
            timeout,
            onTimeout: () =>
                throw TimeoutException('Download request timed out'),
          );

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return BaseClientModel.success(
          data: response.bodyBytes,
          statusCode: response.statusCode,
        );
      } else {
        return BaseClientModel.failure(
          message: 'Download failed with status ${response.statusCode}',
          statusCode: response.statusCode,
        );
      }
    } catch (error) {
      return _handleException(error, method: RequestMethodName.get);
    }
  }

  /// Upload single file with multipart
  Future<BaseClientModel> uploadFileMultipart(
    String url,
    File file, {
    Map<String, String>? headers,
    Map<String, String>? additionalFields,
    String fieldName = 'file',
    String? bearerToken,
  }) async {
    if (kDebugMode) {
      print('Upload file request: $url, File: ${file.path}');
    }

    if (!await file.exists()) {
      return const BaseClientModel.unexpectedError(
        message: 'File does not exist',
      );
    }

    final uri = _buildUrl(url: url);
    if (uri == null) {
      return const BaseClientModel.unexpectedError(
        message: 'Invalid URL format',
      );
    }

    final requestHeaders = _buildHeaders(
      headers: headers,
      bearerToken: bearerToken,
    );

    try {
      final request = http.MultipartRequest('POST', uri)
        ..headers.addAll(requestHeaders);

      // Add additional fields
      if (additionalFields != null) {
        request.fields.addAll(additionalFields);
      }

      // Add file
      final mimeType = lookupMimeType(file.path) ?? 'application/octet-stream';
      final mediaType = MediaType.parse(mimeType);

      request.files.add(
        await http.MultipartFile.fromPath(
          fieldName,
          file.path,
          contentType: mediaType,
        ),
      );

      final streamedResponse = await request.send().timeout(
        timeout,
        onTimeout: () => throw TimeoutException('Upload request timed out'),
      );

      final response = await http.Response.fromStream(streamedResponse);
      return _processResponse(
        response: response,
        method: RequestMethodName.post,
      );
    } catch (error) {
      return _handleException(error, method: RequestMethodName.post);
    }
  }

  /// Close the HTTP client
  void dispose() {
    if (kDebugMode) {
      print('Disposing BaseClient');
    }
    _client.close();
  }
}
