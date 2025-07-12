import 'package:flutter/material.dart';
import 'package:stayzi_ui/screens/detail/comment_page.dart';

class IlanBaslik extends StatelessWidget {
  final Map<String, dynamic> listing;

  const IlanBaslik({super.key, required this.listing});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          Text(
            listing['title'] ?? 'Başlık bulunamadı',
            style: const TextStyle(
              fontSize: 27,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            listing['location'] ?? 'Lokasyon bulunamadı',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 5),
          const Text("2 misafir - 2 oda - 2 yatak - 1 banyo"),
          const SizedBox(height: 20),
          Row(
            children: [
              const Icon(Icons.star, size: 16, color: Colors.black),
              const SizedBox(width: 4),
              Text('${listing['average_rating'] ?? "0.0"}'),
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
