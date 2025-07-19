import 'package:flutter/material.dart';

class HostDetailScreen extends StatelessWidget {
  final Map<String, dynamic>? hostUser;

  const HostDetailScreen({super.key, this.hostUser});

  @override
  Widget build(BuildContext context) {
    final hostName =
        hostUser != null
            ? '${hostUser!['name'] ?? ''} ${hostUser!['surname'] ?? ''}'.trim()
            : 'Ev Sahibi';
    final hostEmail = hostUser?['email'] ?? 'Bilinmiyor';
    final hostPhone = hostUser?['phone'] ?? 'Bilinmiyor';
    
    return Scaffold(
      appBar: AppBar(
        title: Text('Ev Sahibi Bilgileri'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
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
                    backgroundColor: Colors.grey[200],
                    child:
                        hostUser != null && hostUser!['profile_image'] != null
                            ? ClipOval(
                              child: Image.network(
                                hostUser!['profile_image'],
                                width: 100,
                                height: 100,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return const Icon(
                                    Icons.person,
                                    size: 50,
                                    color: Colors.grey,
                                  );
                                },
                              ),
                            )
                            : const Icon(
                              Icons.person,
                              size: 50,
                              color: Colors.grey,
                            ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    hostName,
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  Text('Ev sahibi'),
                ],
              ),
            ),
            SizedBox(height: 30),
            if (hostUser != null) ...[
              _buildInfoRow(Icons.email, 'E-posta', hostEmail),
              SizedBox(height: 15),
              _buildInfoRow(Icons.phone, 'Telefon', hostPhone),
              SizedBox(height: 15),
            ],
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
              hostUser != null
                  ? 'Bu ev sahibi hakkında detaylı bilgi mevcut değil.'
                  : 'Ev sahibi bilgileri yüklenemedi.',
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
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Mesaj özelliği yakında eklenecek'),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 30,
                    vertical: 15,
                  ),
                ),
                child: Text('Mesaj Gönder'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, color: Colors.grey[600], size: 20),
        SizedBox(width: 10),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
            Text(
              value,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ],
    );
  }
}
