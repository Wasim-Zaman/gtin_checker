enum BaseClientStatus {
  success,
  failure,
  networkError,
  timeoutError,
  formatError,
  unexpectedError,
}

class BaseClientModel {
  final BaseClientStatus status;
  final dynamic data;
  final String? message;
  final int? statusCode;

  const BaseClientModel._({
    required this.status,
    this.data,
    this.message,
    this.statusCode,
  });

  /// Success response
  const BaseClientModel.success({
    required this.data,
    this.statusCode,
  }) : status = BaseClientStatus.success,
       message = null;

  /// Failure response with error message
  const BaseClientModel.failure({
    required String this.message,
    this.data,
    this.statusCode,
  }) : status = BaseClientStatus.failure;

  /// Network connectivity error
  const BaseClientModel.networkError({
    this.message = 'No internet connection',
    this.data,
    this.statusCode,
  }) : status = BaseClientStatus.networkError;

  /// Request timeout error
  const BaseClientModel.timeoutError({
    this.message = 'Request timeout',
    this.data,
    this.statusCode,
  }) : status = BaseClientStatus.timeoutError;

  /// JSON format error
  const BaseClientModel.formatError({
    this.message = 'Invalid response format',
    this.data,
    this.statusCode,
  }) : status = BaseClientStatus.formatError;

  /// Unexpected error
  const BaseClientModel.unexpectedError({
    this.message = 'An unexpected error occurred',
    this.data,
    this.statusCode,
  }) : status = BaseClientStatus.unexpectedError;

  /// Check if the response is successful
  bool get isSuccess => status == BaseClientStatus.success;

  /// Check if the response is a failure
  bool get isFailure => status == BaseClientStatus.failure;

  /// Check if the response is a network error
  bool get isNetworkError => status == BaseClientStatus.networkError;

  /// Check if the response is a timeout error
  bool get isTimeoutError => status == BaseClientStatus.timeoutError;

  /// Check if the response is a format error
  bool get isFormatError => status == BaseClientStatus.formatError;

  /// Check if the response is an unexpected error
  bool get isUnexpectedError => status == BaseClientStatus.unexpectedError;

  /// Get error message for display
  String get errorMessage {
    switch (status) {
      case BaseClientStatus.networkError:
        return message ?? 'No internet connection';
      case BaseClientStatus.timeoutError:
        return message ?? 'Request timeout';
      case BaseClientStatus.formatError:
        return message ?? 'Invalid response format';
      case BaseClientStatus.unexpectedError:
        return message ?? 'An unexpected error occurred';
      case BaseClientStatus.failure:
        return message ?? 'Request failed';
      case BaseClientStatus.success:
        return '';
    }
  }

  @override
  String toString() {
    return 'BaseClientModel(status: $status, data: $data, message: $message, statusCode: $statusCode)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is BaseClientModel &&
        other.status == status &&
        other.data == data &&
        other.message == message &&
        other.statusCode == statusCode;
  }

  @override
  int get hashCode {
    return status.hashCode ^
        data.hashCode ^
        message.hashCode ^
        statusCode.hashCode;
  }
}
