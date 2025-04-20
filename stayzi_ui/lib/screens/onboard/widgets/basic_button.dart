import 'package:flutter/material.dart';

// Uygulamanın cogu yerinde kullanabilecegimiz ve cogu parametresini ayarlayabildigimiz button turu
class ElevatedButtonWidget extends StatelessWidget {
  const ElevatedButtonWidget({
    super.key,
    this.icon,
    required this.buttonText,
    required this.buttonColor,
    required this.textColor,
    required this.onPressed,
    this.elevation,
    this.side,
  });

  final String buttonText;
  final Color buttonColor;
  final Color textColor;
  final Icon? icon;
  final void Function()? onPressed;
  final double? elevation;
  final BorderSide? side;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      label: Text(
        buttonText,
        style: TextStyle(
          fontSize: 17,
          fontWeight: FontWeight.bold,
          color: textColor,
        ),
      ),
      icon: icon,
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        side: side,
        padding: const EdgeInsets.only(top: 15, bottom: 15),
        backgroundColor: buttonColor,
        foregroundColor: Colors.black,
        elevation: elevation,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        iconAlignment: IconAlignment.start,
      ),
    );
  }
}
