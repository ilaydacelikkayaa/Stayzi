import 'package:flutter/material.dart';

class KonumBilgisi extends StatelessWidget {
  const KonumBilgisi({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Nerede Olacaksınız ?",
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            "Berkeley Springs, West Virginia, United States",
            style: TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 16),

          // Harita yerine geçici görsel
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.asset(
              'assets/images/harita.jpg', // geçici harita görseli
              fit: BoxFit.cover,
            ),
          ),

          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.verified, color: Colors.green, size: 20),
              const SizedBox(width: 6),
              const Text(
                "Verified listing",
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            "We verified that this listing’s location is accurate.",
            style: TextStyle(color: Colors.black87),
          ),
          TextButton(
            onPressed: () {},

            style: TextButton.styleFrom(
              padding: EdgeInsets.zero,
              foregroundColor: Colors.black,
            ),
            child: const Text("Learn more"),
          ),
        ],
      ),
    );
  }
}
