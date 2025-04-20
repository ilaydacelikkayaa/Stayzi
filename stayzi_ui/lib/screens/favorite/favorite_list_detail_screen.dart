import 'package:flutter/material.dart';
import 'package:stayzi_ui/screens/favorite/favorite_home_detail.screen.dart';

class FavoriteListDetailScreen extends StatefulWidget {
  final String listeAdi;
  final List<Map<String, dynamic>> ilanlar;

  const FavoriteListDetailScreen({
    super.key,
    required this.listeAdi,
    required this.ilanlar,
  });

  @override
  _FavoriteListDetailScreenState createState() =>
      _FavoriteListDetailScreenState();
}

class _FavoriteListDetailScreenState extends State<FavoriteListDetailScreen> {
  bool isEditing = false;

  void _showDeleteConfirmation() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Listeyi Sil'),
          content: const Text('Bu listeyi silmek istediğinizden emin misiniz?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Hayır'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Evet'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.listeAdi),
        actions: [
          if (!isEditing)
            TextButton.icon(
              onPressed: _showDeleteConfirmation,
              icon: const Icon(Icons.delete),
              label: const Text('Listeyi Sil'),
              style: TextButton.styleFrom(foregroundColor: Colors.black),
            ),
          if (isEditing)
            ElevatedButton(
              onPressed: () {
                setState(() {
                  isEditing = false;
                });
              },
              child: const Text('Bitti'),
            ),
        ],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: widget.ilanlar.length,
        itemBuilder: (context, index) {
          final ilan = widget.ilanlar[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 4,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(12),
                  ),
                  child: Image.network(
                    ilan['foto']!.trim(),
                    height: 180,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
                ListTile(
                  title: Text(
                    ilan['baslik'] ?? '',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    "${ilan['konum'] ?? ''} • ${ilan['fiyat'] ?? ''}",
                  ),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder:
                            (context) => FavoriteHomeDetailScreen(ilan: ilan),
                      ),
                    );
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
