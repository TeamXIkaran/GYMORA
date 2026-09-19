import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gymora_fitness_management/config/theme/app_colors.dart';


/// Frosted-glass styled text field with focus-aware accent coloring.
class GlassTextField extends StatefulWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final String hint;
  final IconData prefixIcon;
  final Color accentColor;

  final bool obscure;
  final Widget? suffixIcon;

  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final ValueChanged<String>? onSubmitted;

  final int? maxLength;

  // Validation
  final String? Function(String?)? validator;

  // Prefix
  final String? prefixText;

  // Text
  final TextCapitalization textCapitalization;

  // Input formatters
  final List<TextInputFormatter>? inputFormatters;

  const GlassTextField({
    super.key,
    required this.controller,
    required this.focusNode,
    required this.hint,
    required this.prefixIcon,
    required this.accentColor,
    this.obscure = false,
    this.suffixIcon,
    this.keyboardType,
    this.textInputAction,
    this.onSubmitted,
    this.maxLength,
    this.validator,
    this.prefixText,
    this.textCapitalization = TextCapitalization.none,
    this.inputFormatters, 
  });

  @override
  State<GlassTextField> createState() => _GlassTextFieldState();
}

class _GlassTextFieldState extends State<GlassTextField> {
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();

    widget.focusNode.addListener(_onFocusChange);
  }

  void _onFocusChange() {
    if (!mounted) return;

    setState(() {
      _isFocused = widget.focusNode.hasFocus;
    });
  }

  @override
  void dispose() {
    widget.focusNode.removeListener(_onFocusChange);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final accent = widget.accentColor;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
      decoration: BoxDecoration(
        color: _isFocused
            ? accent.withValues(alpha: 0.06)
            : Colors.white.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: _isFocused
              ? accent.withValues(alpha: 0.5)
              : Colors.white.withValues(alpha: 0.08),
          width: _isFocused ? 1.5 : 1,
        ),
        boxShadow: _isFocused
            ? [
                BoxShadow(
                  color: accent.withValues(alpha: 0.1),
                  blurRadius: 20,
                  spreadRadius: -2,
                ),
              ]
            : [],
      ),
      child: TextFormField(
        controller: widget.controller,
        focusNode: widget.focusNode,

        obscureText: widget.obscure,

        keyboardType: widget.keyboardType,
        textInputAction: widget.textInputAction,
        textCapitalization: widget.textCapitalization,

        onFieldSubmitted: widget.onSubmitted,

        maxLength: widget.maxLength,

        // IMPORTANT
        // Allows FilteringTextInputFormatter.digitsOnly
        inputFormatters: widget.inputFormatters,

        validator: widget.validator,

        style: const TextStyle(
          color: AppColors.white,
          fontSize: 14,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.3,
        ),

        cursorColor: accent,
        cursorWidth: 1.5,

        decoration: InputDecoration(
          counterText: '',

          hintText: widget.hint,

          hintStyle: TextStyle(
            color: Colors.white.withValues(alpha: 0.25),
            fontSize: 14,
            fontWeight: FontWeight.w400,
          ),

          prefixIcon: Padding(
            padding: const EdgeInsets.only(left: 16, right: 12),
            child: Icon(
              widget.prefixIcon,
              color: _isFocused
                  ? accent.withValues(alpha: 0.8)
                  : Colors.white.withValues(alpha: 0.3),
              size: 20,
            ),
          ),

          prefixIconConstraints: const BoxConstraints(
            minWidth: 48,
            minHeight: 48,
          ),

          prefixText: widget.prefixText,

          prefixStyle: TextStyle(
            color: accent,
            fontSize: 14,
            fontWeight: FontWeight.w700,
          ),

          suffixIcon: widget.suffixIcon != null
              ? Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: widget.suffixIcon,
                )
              : null,

          suffixIconConstraints: const BoxConstraints(
            minWidth: 40,
            minHeight: 40,
          ),

          errorStyle: TextStyle(
            color: Colors.redAccent.withValues(alpha: 0.9),
            fontSize: 10,
            fontWeight: FontWeight.w500,
          ),

          border: InputBorder.none,

          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
        ),
      ),
    );
  }
}
