import 'package:flutter/material.dart';

class FFButtonOptions {
  const FFButtonOptions({
    this.textStyle,
    this.elevation,
    this.height,
    this.width,
    this.padding,
    this.color,
    this.disabledColor,
    this.disabledTextColor,
    this.splashColor,
    this.iconSize,
    this.iconColor,
    this.iconPadding,
    this.borderRadius,
    this.borderSide,
  });

  final TextStyle? textStyle;
  final double? elevation;
  final double? height;
  final double? width;
  final EdgeInsetsGeometry? padding;
  final Color? color;
  final Color? disabledColor;
  final Color? disabledTextColor;
  final Color? splashColor;
  final double? iconSize;
  final Color? iconColor;
  final EdgeInsetsGeometry? iconPadding;
  final BorderRadius? borderRadius;
  final BorderSide? borderSide;
}

class FFButtonWidget extends StatelessWidget {
  const FFButtonWidget({
    super.key,
    required this.text,
    required this.onPressed,
    required this.options,
    this.icon,
    this.iconData,
    this.showLoadingIndicator = false,
  });

  final String text;
  final VoidCallback? onPressed;
  final Widget? icon;
  final IconData? iconData;
  final FFButtonOptions options;
  final bool showLoadingIndicator;

  @override
  Widget build(BuildContext context) {
    final Widget textWidget = showLoadingIndicator
        ? const SizedBox(
            width: 22,
            height: 22,
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              strokeWidth: 2.5,
            ),
          )
        : Text(
            text,
            style: options.textStyle,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          );

    final BorderRadius radius = options.borderRadius ?? BorderRadius.circular(16);
    final BorderSide border = options.borderSide ?? BorderSide.none;

    final ButtonStyle style = ElevatedButton.styleFrom(
      foregroundColor: options.textStyle?.color ?? Colors.white,
      backgroundColor: options.color ?? const Color(0xFF0A1C6A),
      disabledBackgroundColor: options.disabledColor ?? const Color(0xFFCBD5E1),
      disabledForegroundColor: options.disabledTextColor ?? const Color(0xFF94A3B8),
      elevation: options.elevation ?? 0,
      padding: options.padding ?? const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      shape: RoundedRectangleBorder(
        borderRadius: radius,
        side: border,
      ),
    );

    Widget btn;
    if (icon != null || iconData != null) {
      btn = ElevatedButton.icon(
        icon: icon ?? Icon(iconData, size: options.iconSize, color: options.iconColor),
        label: textWidget,
        onPressed: onPressed,
        style: style,
      );
    } else {
      btn = ElevatedButton(
        onPressed: onPressed,
        style: style,
        child: textWidget,
      );
    }

    return SizedBox(
      height: options.height ?? 54.0,
      width: options.width ?? double.infinity,
      child: btn,
    );
  }
}
