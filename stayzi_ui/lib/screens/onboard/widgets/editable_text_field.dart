import 'package:flutter/material.dart';

// ProfileİnfoScreen de kullanılan editable text field , zaman olursa animasyon eklenebilir
class EditableTextField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final String hint;
  final bool isEditable;
  final VoidCallback onEditPressed;

  const EditableTextField({
    super.key,
    required this.label,
    required this.controller,
    required this.hint,
    required this.isEditable,
    required this.onEditPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 16,
                  color: Color.fromARGB(255, 0, 0, 0),
                ),
              ),
              GestureDetector(
                onTap: onEditPressed,
                child: Text(
                  isEditable ? 'Kaydet' : 'Düzenle',
                  style: const TextStyle(
                    color: Color.fromARGB(255, 0, 0, 0),
                    fontSize: 16,
                    decoration: TextDecoration.underline,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          TextField(
            controller: controller,
            enabled: isEditable,
            decoration: InputDecoration(
              hintText: hint,
              border: const OutlineInputBorder(),
            ),
          ),
        ],
      ),
    );
  }
}
