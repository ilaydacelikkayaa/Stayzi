import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

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
    this.inputFormatters,
    this.validator,
    this.readOnly,
    this.autovalidateMode,
    this.focusNode,
    this.labelStyle,
  });

  final String? labelText;
  final TextInputAction? textInputAction;
  final TextInputType? keyboardType;
  final String? hintText;
  final String? helperText;
  final TextEditingController? controller;
  final bool? obscureText;
  final List<TextInputFormatter>? inputFormatters;
  final String? Function(String?)? validator;
  final bool? readOnly;
  final AutovalidateMode? autovalidateMode;
  final FocusNode? focusNode;
  final TextStyle? labelStyle;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      obscureText: obscureText ?? false,
      controller: controller,
      keyboardType: keyboardType,
      focusNode: focusNode,
      inputFormatters: inputFormatters,
      autovalidateMode: autovalidateMode ?? AutovalidateMode.disabled,
      validator: validator,
      readOnly: readOnly ?? false,
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
        labelStyle:
            labelStyle ??
            const TextStyle(color: Colors.black, fontWeight: FontWeight.normal),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Colors.black, width: 1),
        ),
      ),
    );
  }
}
