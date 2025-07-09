import 'package:flutter/material.dart';

class HostDetailScreen extends StatelessWidget {
  const HostDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Ev Sahibi Bilgileri')),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundImage: NetworkImage(
                      'https://randomuser.me/api/portraits/men/32.jpg',
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Mehmet Çelikkaya',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  Text('Ev sahibi, 2018\'den beri'),
                ],
              ),
            ),
            SizedBox(height: 30),
            Row(
              children: [
                Icon(Icons.star, color: Colors.orange),
                SizedBox(width: 5),
                Text('4.8 · 72 değerlendirme'),
              ],
            ),
            SizedBox(height: 20),
            Text(
              'Hakkında',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text(
              'Merhaba! Ben Mehmet. Seyahat etmeyi ve yeni insanlarla tanışmayı çok severim. Konuklarımın rahat ve mutlu olması benim için çok önemli.',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 20),
            Text(
              'Yanıt Süresi: Ortalama 1 saat içinde',
              style: TextStyle(color: Colors.grey[700]),
            ),
            SizedBox(height: 5),
            Text(
              'Dil: Türkçe, İngilizce',
              style: TextStyle(color: Colors.grey[700]),
            ),
            SizedBox(height: 30),
            Center(
              child: ElevatedButton(
                onPressed: () {
                  // mesaj gönderme aksiyonu
                },
                child: Text('Mesaj Gönder'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
