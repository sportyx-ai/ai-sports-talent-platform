import 'package:flutter/material.dart';
import '../core/colors.dart';

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final EdgeInsets? padding;
  final double? borderRadius;
  final double? width;
  final double? fontSize;
  final bool outlined;

  const CustomButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.padding,
    this.borderRadius,
    this.width,
    this.fontSize,
    this.outlined = false,
  });

  @override
  Widget build(BuildContext context) {
    if (outlined) {
      return SizedBox(
        width: width ?? double.infinity,
        child: OutlinedButton(
          style: OutlinedButton.styleFrom(
            side: const BorderSide(color: AppColors.primary, width: 2),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(borderRadius ?? 8),
            ),
            backgroundColor: Colors.white,
          ),
          onPressed: onPressed,
          child: Padding(
            padding: padding ?? const EdgeInsets.symmetric(vertical: 14),
            child: Text(
              text,
              style: TextStyle(
                fontSize: fontSize ?? 16,
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      );
    }

    return SizedBox(
      width: width ?? double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius ?? 8),
          ),
        ),
        onPressed: onPressed,
        child: Padding(
          padding: padding ?? const EdgeInsets.symmetric(vertical: 14),
          child: Text(
            text,
            style: TextStyle(fontSize: fontSize ?? 16),
          ),
        ),
      ),
    );
  }
}