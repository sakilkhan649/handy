import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:handy/config/themes/app_theme.dart';

/// ===================== CUSTOM TEXT FIELD =====================
/// A styled text field with optional label, icons, and validation.
/// Follows the app's design system with consistent border radius and fill color.
class CustomTextField extends StatelessWidget {
  final String hintText;
  final String? label;
  final TextEditingController? controller;
  final bool obscureText;
  final String? Function(String?)? validator;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final bool showLabel;
  final int maxLines;
  final int? maxLength;
  final bool readOnly;
  final bool enabled;
  final TextInputType keyboardType;
  final TextInputAction? textInputAction;
  final VoidCallback? onTap;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onFieldSubmitted;
  final List<TextInputFormatter>? inputFormatters;
  final Color? fillColor;
  final FocusNode? focusNode;
  final TextCapitalization textCapitalization;

  const CustomTextField({
    super.key,
    required this.hintText,
    this.label,
    this.controller,
    this.obscureText = false,
    this.validator,
    this.prefixIcon,
    this.suffixIcon,
    this.showLabel = true,
    this.maxLines = 1,
    this.maxLength,
    this.readOnly = false,
    this.enabled = true,
    this.keyboardType = TextInputType.text,
    this.textInputAction,
    this.onTap,
    this.onChanged,
    this.onFieldSubmitted,
    this.inputFormatters,
    this.fillColor,
    this.focusNode,
    this.textCapitalization = TextCapitalization.none,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // ─── LABEL ───
        if (showLabel && label != null)
          Padding(
            padding: EdgeInsets.only(bottom: 6.h),
            child: Text(
              label!,
              style: GoogleFonts.manrope(
                fontSize: 16.sp,
                fontWeight: FontWeight.w500,
                color: AppTheme.white.withValues(alpha: 0.9),
              ),
            ),
          ),

        // ─── TEXT FIELD ───
        TextFormField(
          controller: controller,
          validator: validator,
          obscureText: obscureText,
          maxLines: maxLines,
          maxLength: maxLength,
          readOnly: readOnly,
          enabled: enabled,
          keyboardType: keyboardType,
          textInputAction: textInputAction,
          onTap: onTap,
          onChanged: onChanged,
          onFieldSubmitted: onFieldSubmitted,
          inputFormatters: inputFormatters,
          focusNode: focusNode,
          textCapitalization: textCapitalization,
          style: GoogleFonts.manrope(
            fontSize: 15.sp,
            fontWeight: FontWeight.w400,
            color: AppTheme.white,
          ),
          decoration: _buildDecoration(),
        ),
      ],
    );
  }

  InputDecoration _buildDecoration() {
    final borderRadius = BorderRadius.circular(16.r);
    final border = OutlineInputBorder(
      borderRadius: borderRadius,
      borderSide: BorderSide(color: AppTheme.white.withValues(alpha: 0.05), width: 1),
    );
    final focusBorder = OutlineInputBorder(
      borderRadius: borderRadius,
      borderSide: const BorderSide(color: AppTheme.accentBlue, width: 1.5),
    );

    return InputDecoration(
      hintText: hintText,
      hintStyle: GoogleFonts.arimo(
        fontSize: 15.sp,
        fontWeight: FontWeight.w400,
        color: AppTheme.white.withValues(alpha: 0.4),
      ),
      contentPadding: EdgeInsets.symmetric(
        vertical: 16.h,
        horizontal: 16.w,
      ),
      prefixIcon: prefixIcon,
      suffixIcon: suffixIcon,
      filled: true,
      fillColor: fillColor ?? const Color(0xFF1E2336),
      border: border,
      enabledBorder: border,
      focusedBorder: focusBorder,
      errorBorder: border.copyWith(borderSide: const BorderSide(color: Colors.red, width: 1)),
      focusedErrorBorder: border.copyWith(borderSide: const BorderSide(color: Colors.red, width: 1)),
      counterText: '',
      errorStyle: GoogleFonts.arimo(
        fontSize: 11.sp,
        color: Colors.redAccent,
      ),
    );
  }
}
