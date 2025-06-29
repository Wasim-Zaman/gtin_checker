import 'package:flutter/material.dart';

enum ButtonState { idle, loading, success, error }

class CustomButtonWidget extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final ButtonState state;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final double? elevation;
  final EdgeInsetsGeometry? padding;
  final BorderRadius? borderRadius;
  final double? fontSize;
  final FontWeight? fontWeight;
  final IconData? icon;
  final double? width;
  final double? height;

  const CustomButtonWidget({
    super.key,
    required this.text,
    this.onPressed,
    this.state = ButtonState.idle,
    this.backgroundColor,
    this.foregroundColor,
    this.elevation,
    this.padding,
    this.borderRadius,
    this.fontSize,
    this.fontWeight,
    this.icon,
    this.width,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    Color getBackgroundColor() {
      switch (state) {
        case ButtonState.loading:
          return backgroundColor?.withValues(alpha: 0.8) ??
              colorScheme.primary.withValues(alpha: 0.8);
        case ButtonState.success:
          return colorScheme.tertiary;
        case ButtonState.error:
          return colorScheme.error;
        case ButtonState.idle:
          return backgroundColor ?? colorScheme.primary;
      }
    }

    Color getForegroundColor() {
      switch (state) {
        case ButtonState.loading:
          return foregroundColor ?? colorScheme.onPrimary;
        case ButtonState.success:
          return colorScheme.onTertiary;
        case ButtonState.error:
          return colorScheme.onError;
        case ButtonState.idle:
          return foregroundColor ?? colorScheme.onPrimary;
      }
    }

    Widget getChild() {
      switch (state) {
        case ButtonState.loading:
          return SizedBox(
            height: 20,
            width: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(getForegroundColor()),
            ),
          );
        case ButtonState.success:
          return Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.check, color: getForegroundColor(), size: 18),
              const SizedBox(width: 8),
              Text(
                'Success',
                style: TextStyle(
                  color: getForegroundColor(),
                  fontSize: fontSize ?? 14,
                  fontWeight: fontWeight ?? FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          );
        case ButtonState.error:
          return Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.error_outline, color: getForegroundColor(), size: 18),
              const SizedBox(width: 8),
              Text(
                'Error',
                style: TextStyle(
                  color: getForegroundColor(),
                  fontSize: fontSize ?? 14,
                  fontWeight: fontWeight ?? FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          );
        case ButtonState.idle:
          return Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                Icon(icon, color: getForegroundColor(), size: 18),
                const SizedBox(width: 8),
              ],
              Text(
                text,
                style: TextStyle(
                  color: getForegroundColor(),
                  fontSize: fontSize ?? 14,
                  fontWeight: fontWeight ?? FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          );
      }
    }

    return SizedBox(
      width: width ?? double.infinity,
      height: height,
      child: ElevatedButton(
        onPressed: state == ButtonState.loading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          elevation: elevation ?? 2,
          padding:
              padding ??
              const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          backgroundColor: getBackgroundColor(),
          foregroundColor: getForegroundColor(),
          shape: RoundedRectangleBorder(
            borderRadius: borderRadius ?? BorderRadius.circular(16),
          ),
        ),
        child: getChild(),
      ),
    );
  }
}
