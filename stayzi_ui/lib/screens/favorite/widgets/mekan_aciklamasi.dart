import 'package:flutter/material.dart';

class MekanAciklamasi extends StatelessWidget {
  final String description;

  const MekanAciklamasi({super.key, required this.description});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Bu mekan hakkında",
            style: TextStyle(fontSize: 23, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 10),
          Text(
            description,
            style: TextStyle(fontSize: 16, color: Colors.black87, height: 1.5),
          ),
          SizedBox(height: 20),
        ],
      ),
    );
  }
}
