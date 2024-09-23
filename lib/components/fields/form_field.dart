import 'package:flutter/material.dart';
import 'package:park_in_web/components/theme/color_scheme.dart';

class PRKFormField extends StatefulWidget {
  final IconData? prefixIcon;
  final String labelText;
  final IconData? suffixIcon;
  final TextEditingController controller;
  final bool obscureText;
  final TextInputType? keyboardType;
  final void Function(String)? onChanged;

  const PRKFormField({
    super.key,
    required this.prefixIcon,
    required this.labelText,
    this.suffixIcon,
    required this.controller,
    this.obscureText = false,
    this.keyboardType,
    this.onChanged,
  });

  @override
  _PRKFormFieldState createState() => _PRKFormFieldState();
}

class _PRKFormFieldState extends State<PRKFormField> {
  bool _obscureText = true;
  bool _isFocused = false;

  late FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(_onFocusChange);
    _obscureText = widget.obscureText;
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  void _onFocusChange() {
    setState(() {
      _isFocused = _focusNode.hasFocus;
    });
  }

  void _toggleObscureText() {
    setState(() {
      _obscureText = !_obscureText;
    });
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      focusNode: _focusNode,
      obscureText: _obscureText,
      keyboardType: widget.keyboardType,
      style: const TextStyle(
        fontSize: 12,
        color: blackColor,
      ),
      decoration: InputDecoration(
        filled: true,
        fillColor: whiteColor,
        prefixIcon: Icon(
          size: 20,
          widget.prefixIcon,
          color: _isFocused ? blueColor : blackColor,
        ),
        suffixIcon: widget.suffixIcon != null
            ? IconButton(
                icon: Icon(
                  _obscureText ? widget.suffixIcon : Icons.visibility_rounded,
                  color: _isFocused ? blueColor : blackColor,
                ),
                onPressed: () {
                  if (widget.suffixIcon != null) {
                    _toggleObscureText();
                  }
                },
              )
            : null,
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(
            width: 1,
            color: blueColor,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(
            width: 0.5,
            color: borderBlack,
          ),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(
            width: 0.1,
          ),
        ),
        labelText: widget.labelText,
        labelStyle: TextStyle(
          fontSize: 12,
          color: _isFocused ? blueColor : blackColor,
        ),
      ),
      onFieldSubmitted: (_) {
        setState(() {
          _isFocused = false;
        });
      },
    );
  }
}
