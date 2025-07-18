import 'package:flutter/material.dart';

import '../../models/user_model.dart';
import '../../services/api_service.dart';

class HostDetailScreen extends StatefulWidget {
  final int listingID;
  const HostDetailScreen({super.key, required this.listingID});

  @override
  State<HostDetailScreen> createState() => _HostDetailScreenState();
}

class _HostDetailScreenState extends State<HostDetailScreen> {
  User? hostUser;

  @override
  void initState() {
    super.initState();
    fetchHostUser();
  }

  Future<void> fetchHostUser() async {
    try {
      print("📬 Host ID: ${widget.listingID}");

      final listing = await ApiService().getListingWithHostById(
        widget.listingID,
      );
      print("📦 Listing verisi: $listing");
      print(
        "✅ Host user geldi: ${listing.host?.name} ${listing.host?.surname}",
      );
      setState(() {
        hostUser = listing.host;
      });
    } catch (e) {
      print("❌ Host bilgisi alınamadı: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Ev Sahibi Bilgileri')),
      body:
          hostUser == null
              ? Center(child: CircularProgressIndicator())
              : Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Column(
                        children: [
                          CircleAvatar(
                            radius: 50,
                            backgroundImage:
                                (hostUser?.profileImage != null &&
                                        hostUser!.profileImage!.isNotEmpty)
                                    ? NetworkImage(hostUser!.profileImage!)
                                    : const AssetImage(
                                          'assets/default_user.png',
                                        )
                                        as ImageProvider,
                          ),
                          SizedBox(height: 10),
                          Text(
                            '${hostUser!.name} ${hostUser!.surname}',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
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
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 10),
                    Text(
                      hostUser!.country != null
                          ? 'Ülke: ${hostUser!.country}'
                          : 'Ülke bilgisi mevcut değil',
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
