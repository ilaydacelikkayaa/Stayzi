// lib/screens/detail/host_detail_screen.dart

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
        "✅ Host user geldi: ${listing.user?.name} ${listing.user?.surname}",
      );
      setState(() {
        hostUser = listing.user;
      });
    } catch (e) {
      print("❌ Host bilgisi alınamadı: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Ev Sahibi Detayı")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            CircleAvatar(
              radius: 50,
              backgroundImage:
                  hostUser?.profileImage != null
                      ? NetworkImage(hostUser!.profileImage!)
                      : null,
              child:
                  hostUser?.profileImage == null
                      ? const Icon(Icons.person, size: 50)
                      : null,
            ),
            const SizedBox(height: 16),
            Text(
              '${hostUser?.name} ${hostUser?.surname}',
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text('Ülke: ${hostUser?.country ?? "Bilinmiyor"}'),
            const SizedBox(height: 8),
            Text('Telefon: ${hostUser?.phone ?? "Gizli"}'),
            const SizedBox(height: 8),
            Text('E-posta: ${hostUser?.email ?? "Yok"}'),
          ],
        ),
      ),
    );
  }
}
