import 'package:flutter/material.dart';
import 'package:stayzi_ui/screens/detail/comment_page.dart';

class IlanBaslik extends StatelessWidget {
  const IlanBaslik({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          const Text(
            "Virgina Hotel & Spa",
            style: TextStyle(
              fontSize: 27,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            "Hotel, West Virgina, USA",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 5),
          const Text("2 misafir - 2 oda - 2 yatak - 1 banyo"),
          const SizedBox(height: 20),
          Row(
            children: [
              const Icon(Icons.star, size: 16, color: Colors.black),
              const SizedBox(width: 4),
              const Text("4.56"),
              TextButton(
                style: ButtonStyle(
                  foregroundColor: WidgetStateProperty.all(Colors.black),
                  textStyle: WidgetStateProperty.all(
                    const TextStyle(decoration: TextDecoration.underline),
                  ),
                ),
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const CommentPage(),
                    ),
                  );
                },
                child: const Text("35 değerlendirme"),
              ),
            ],
          ),
          const SizedBox(height: 10),
        ],
      ),
    );
  }
}
