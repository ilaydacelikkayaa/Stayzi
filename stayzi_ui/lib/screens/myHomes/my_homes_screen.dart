import 'package:flutter/material.dart';

import 'home_detail_screen.dart';

class MyHomesScreen extends StatelessWidget {
  const MyHomesScreen({super.key});

  final List<Map<String, String>> ilanlar = const [
    {
      'baslik': 'Geniş ve Ferah 2+1',
      'konum': 'İstanbul, Kadıköy',
      'fiyat': '12.000 TL',
      'foto':
          ' https://tekce.net/files/emlaklar/ic/650x450/ist-0784-spacious-apartment-with-sea-view-in-istanbul-asian-side-ih-1.jpeg',
    },
    {
      'baslik': 'Modern 1+1 Daire',
      'konum': 'Ankara, Çankaya',
      'fiyat': '9.500 TL',
      'foto':
          'https://imaj.emlakjet.com/cms/resize/900/675/projects/98/e8acbijul6ssjxkss4yx.jpg',
    },
    {
      'baslik': 'Deniz Manzaralı 3+1',
      'konum': 'İzmir, Karşıyaka',
      'fiyat': '15.000 TL',
      'foto':
          'https://beta-images.endeksa.com/images/projectimages/atilgan-royal-atilgan-insaat',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("İlanlarım"),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_box_outlined),
            iconSize: 30,
            onPressed: () {
              Navigator.pushNamed(context, '/add_home');
            },
          ),
        ],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: ilanlar.length,
        itemBuilder: (context, index) {
          final ilan = ilanlar[index];
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
                    ilan['baslik']!,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text("${ilan['konum']} • ${ilan['fiyat']}"),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder:
                            (context) => HomeDetailScreen(ilan: ilanlar[index]),
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
