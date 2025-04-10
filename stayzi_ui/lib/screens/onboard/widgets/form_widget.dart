import 'package:flutter/material.dart';

class FormWidget extends StatelessWidget {
  const FormWidget({
    super.key,
    this.labelText,
    this.textInputAction,
    this.keyboardType,
    this.hintText,
    this.helperText,
    this.controller,
    this.obscureText,
  });

  final String? labelText;
  final TextInputAction? textInputAction;
  final TextInputType? keyboardType;
  final String? hintText;
  final String? helperText;
  final TextEditingController? controller;
  final bool? obscureText;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      obscureText: obscureText ?? false,
      controller: controller,
      keyboardType: keyboardType,
      cursorColor: Colors.black,
      textInputAction: textInputAction,
      decoration: InputDecoration(
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Colors.black, width: 2),
        ),
        //filled: true, // daha koyu renkte ve dolu bir textField icin bunu yorum satırından cikar
        hintText: hintText,
        helperText: helperText,
        helperMaxLines: 4,
        labelText: labelText,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Colors.black, width: 1),
        ),
      ),
    );
  }
}
