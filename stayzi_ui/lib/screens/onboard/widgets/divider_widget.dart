import 'package:flutter/material.dart';

class DividerWidget extends StatelessWidget {
  const DividerWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Expanded(
          child: Divider(
            thickness: 1,
            color: Colors.grey,
            endIndent: 12,
            indent: 20,
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Text('or', style: TextStyle(color: Colors.grey)),
        ),
        const Expanded(
          child: Divider(
            thickness: 1,
            color: Colors.grey,
            endIndent: 20,
            indent: 12,
          ),
        ),
      ],
    );
  }
}
