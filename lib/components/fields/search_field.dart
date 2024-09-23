import 'package:flutter/material.dart';
import 'package:park_in_web/components/theme/color_scheme.dart';

class PRKSearchField extends StatefulWidget {
  final String hintText;
  final IconData? suffixIcon;
  final TextEditingController controller;

  const PRKSearchField({
    super.key,
    required this.hintText,
    this.suffixIcon,
    required this.controller,
  });

  @override
  _PRKSearchFieldState createState() => _PRKSearchFieldState();
}

class _PRKSearchFieldState extends State<PRKSearchField> {
  bool _isFocused = false;

  late FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(_onFocusChange);
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

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      focusNode: _focusNode,
      style: const TextStyle(
        fontSize: 12,
        color: blackColor,
      ),
      decoration: InputDecoration(
        filled: true,
        fillColor: whiteColor,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 16,
        ),
        suffixIcon: Icon(
          widget.suffixIcon,
          color: _isFocused ? blueColor : blackColor,
          size: 20,
        ),
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
        hintText: widget.hintText,
        hintStyle: TextStyle(
          fontSize: 12,
          color: _isFocused ? blueColor : blackColor.withOpacity(0.5),
          fontWeight: FontWeight.w400,
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
