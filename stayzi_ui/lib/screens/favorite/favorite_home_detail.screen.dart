import 'package:flutter/material.dart';

class FavoriteHomeDetailScreen extends StatelessWidget {
  final Map<String, dynamic> ilan;

  const FavoriteHomeDetailScreen({super.key, required this.ilan});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(ilan['baslik'] ?? 'Favori Ev Detayı'),
        actions: [
          IconButton(
            icon: const Icon(Icons.favorite),
            onPressed: () {
              // Favorilerden çıkarma işlemi için bir fonksiyon eklenicek
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(" {ilan['baslik']} favorilerden çıkarıldı"),
                ),
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.network(
              ilan['foto']!.trim(),
              height: 200,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder:
                  (context, error, stackTrace) => const Icon(Icons.error),
            ),
            const SizedBox(height: 16),
            Text(
              ilan['baslik'] ?? '',
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              ilan['konum'] ?? '',
              style: const TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 8),
            Text(
              ilan['fiyat'] ?? '',
              style: const TextStyle(fontSize: 18, color: Colors.green),
            ),
            const SizedBox(height: 16),
            const Text(
              'Favori ev hakkında daha fazla açıklama burada yer alabilir.',
              style: TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}
