import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:gtin_checker/models/auth_models.dart';

import '../../../widgets/custom_button_widget.dart';
import '../../../widgets/custom_text_field_widget.dart';
import '../providers/auth_providers.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final FocusNode _emailFocusNode = FocusNode();
  final FocusNode _passwordFocusNode = FocusNode();

  bool _rememberMe = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter both email and password'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    await ref.read(authProvider.notifier).login(email, password);
  }

  Future<void> _handleNfcLogin() async {
    try {
      await ref.read(authProvider.notifier).nfcLogin();

      // Navigate to home screen on successful login
      if (mounted) {
        context.go('/');
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('NFC Login failed: ${error.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final authState = ref.watch(authProvider);

    // Listen to auth state changes
    ref.listen<AsyncValue<User?>>(authProvider, (previous, next) {
      next.when(
        data: (user) {
          if (user != null) {
            // User logged in successfully
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Welcome, ${user.name}!'),
                backgroundColor: Colors.green,
              ),
            );
            context.go('/');
          }
        },
        loading: () {
          // Handle loading state if needed
        },
        error: (error, stackTrace) {
          // Show error message
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: ${error.toString()}'),
              backgroundColor: Colors.red,
            ),
          );
        },
      );
    });

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/login_background.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Logo section
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      color: colorScheme.primary,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: colorScheme.primary.withValues(alpha: 0.3),
                          blurRadius: 20,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.qr_code_scanner,
                          color: colorScheme.onPrimary,
                          size: 40,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'GTIN CHECKER',
                          style: TextStyle(
                            color: colorScheme.onPrimary,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 40),

                  // Title
                  Text(
                    'Sign in to your account',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      shadows: [
                        Shadow(
                          color: Colors.black.withValues(alpha: 0.5),
                          offset: const Offset(0, 2),
                          blurRadius: 4,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 40),

                  // Login form
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.95),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.2),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        // Email field
                        CustomTextFieldWidget(
                          controller: _emailController,
                          focusNode: _emailFocusNode,
                          hintText: 'Email',
                          keyboardType: TextInputType.emailAddress,
                          textInputAction: TextInputAction.next,
                          prefixIcon: Icons.email_outlined,
                          prefixIconColor: Colors.grey[600],
                          fillColor: Colors.grey[100],
                          hintStyle: TextStyle(color: Colors.grey[500]),
                          onSubmitted: (_) {
                            _passwordFocusNode.requestFocus();
                          },
                        ),

                        const SizedBox(height: 16),

                        // Password field
                        CustomTextFieldWidget(
                          controller: _passwordController,
                          focusNode: _passwordFocusNode,
                          hintText: 'Password',
                          isPassword: true,
                          textInputAction: TextInputAction.done,
                          prefixIcon: Icons.lock_outline,
                          prefixIconColor: Colors.grey[600],
                          fillColor: Colors.grey[100],
                          hintStyle: TextStyle(color: Colors.grey[500]),
                          onSubmitted: (_) {
                            _handleLogin();
                          },
                        ),

                        const SizedBox(height: 16),

                        // Remember me and forgot password
                        Row(
                          children: [
                            Checkbox(
                              value: _rememberMe,
                              onChanged: (value) {
                                setState(() {
                                  _rememberMe = value ?? false;
                                });
                              },
                              activeColor: colorScheme.primary,
                            ),
                            Text(
                              'Remember me',
                              style: TextStyle(
                                color: Colors.grey[700],
                                fontSize: 14,
                              ),
                            ),
                            const Spacer(),
                            TextButton(
                              onPressed: () {
                                // Handle forgot password
                              },
                              child: Text(
                                'Forgot Password?',
                                style: TextStyle(
                                  color: colorScheme.primary,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 24),

                        // Login button
                        CustomButtonWidget(
                          text: 'LOGIN',
                          state: authState.when(
                            data: (_) => ButtonState.idle,
                            loading: () => ButtonState.loading,
                            error: (_, __) => ButtonState.error,
                          ),
                          onPressed: authState.isLoading ? null : _handleLogin,
                          width: double.infinity,
                          backgroundColor: colorScheme.primary,
                          foregroundColor: colorScheme.onPrimary,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          fontSize: 16,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),

                  // NFC login section
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.95),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.2),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Text(
                          'Or login with NFC Card',
                          style: TextStyle(
                            color: Colors.grey[700],
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),

                        const SizedBox(height: 16),

                        CustomButtonWidget(
                          text: 'TAP NFC CARD',
                          onPressed: authState.isLoading
                              ? null
                              : _handleNfcLogin,
                          width: double.infinity,
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                          icon: Icons.nfc,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          fontSize: 16,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
