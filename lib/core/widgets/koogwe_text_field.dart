import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:koogwe/core/constants/app_colors.dart';
import 'package:koogwe/core/constants/app_spacing.dart';
import 'package:google_fonts/google_fonts.dart';

class KoogweTextField extends StatefulWidget {
  final String? label;
  final String? hint;
  final String? helperText;
  final String? errorText;
  final TextEditingController? controller;
  final bool obscureText;
  final TextInputType keyboardType;
  final int? maxLines;
  final int? maxLength;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onTap;
  final bool readOnly;
  final List<TextInputFormatter>? inputFormatters;
  final String? Function(String?)? validator;
  final bool enabled;

  const KoogweTextField({
    super.key,
    this.label,
    this.hint,
    this.helperText,
    this.errorText,
    this.controller,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
    this.maxLines = 1,
    this.maxLength,
    this.prefixIcon,
    this.suffixIcon,
    this.onChanged,
    this.onTap,
    this.readOnly = false,
    this.inputFormatters,
    this.validator,
    this.enabled = true,
  });

  @override
  State<KoogweTextField> createState() => _KoogweTextFieldState();
}

class _KoogweTextFieldState extends State<KoogweTextField> {
  bool _obscureText = false;

  @override
  void initState() {
    super.initState();
    _obscureText = widget.obscureText;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.label != null) ...[
          Text(
            widget.label!,
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: isDark ? KoogweColors.darkTextPrimary : KoogweColors.lightTextPrimary,
            ),
          ),
          const SizedBox(height: KoogweSpacing.sm),
        ],
        TextFormField(
          controller: widget.controller,
          obscureText: _obscureText,
          keyboardType: widget.keyboardType,
          maxLines: widget.maxLines,
          maxLength: widget.maxLength,
          onChanged: widget.onChanged,
          onTap: widget.onTap,
          readOnly: widget.readOnly,
          inputFormatters: widget.inputFormatters,
          validator: widget.validator,
          enabled: widget.enabled,
          style: GoogleFonts.inter(
            fontSize: 16,
            color: isDark ? KoogweColors.darkTextPrimary : KoogweColors.lightTextPrimary,
          ),
          decoration: InputDecoration(
            hintText: widget.hint,
            helperText: widget.helperText,
            errorText: widget.errorText,
            prefixIcon: widget.prefixIcon,
            suffixIcon: widget.obscureText
                ? IconButton(
                    icon: Icon(
                      _obscureText ? Icons.visibility_off : Icons.visibility,
                      color: isDark ? KoogweColors.darkTextSecondary : KoogweColors.lightTextSecondary,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscureText = !_obscureText;
                      });
                    },
                  )
                : widget.suffixIcon,
            filled: true,
            fillColor: isDark ? KoogweColors.darkSurface : KoogweColors.lightSurface,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: KoogweSpacing.lg,
              vertical: KoogweSpacing.lg,
            ),
            border: OutlineInputBorder(
              borderRadius: KoogweRadius.mdRadius,
              borderSide: BorderSide(
                color: isDark ? KoogweColors.darkBorder : KoogweColors.lightBorder,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: KoogweRadius.mdRadius,
              borderSide: BorderSide(
                color: isDark ? KoogweColors.darkBorder : KoogweColors.lightBorder,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(KoogweRadius.md),
              borderSide: BorderSide(color: KoogweColors.primary, width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(KoogweRadius.md),
              borderSide: BorderSide(color: KoogweColors.error),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(KoogweRadius.md),
              borderSide: BorderSide(color: KoogweColors.error, width: 2),
            ),
            disabledBorder: OutlineInputBorder(
              borderRadius: KoogweRadius.mdRadius,
              borderSide: BorderSide(
                color: (isDark ? KoogweColors.darkBorder : KoogweColors.lightBorder).withValues(alpha: 0.5),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
