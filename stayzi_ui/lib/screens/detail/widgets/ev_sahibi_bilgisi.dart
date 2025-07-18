import 'package:flutter/material.dart';
import 'package:stayzi_ui/screens/detail/host_detail_screen.dart';
import 'package:stayzi_ui/services/api_constants.dart';
import 'package:stayzi_ui/services/api_service.dart';

class EvSahibiBilgisi extends StatefulWidget {
  final Map<String, dynamic> listing;

  const EvSahibiBilgisi({super.key, required this.listing});

  @override
  State<EvSahibiBilgisi> createState() => _EvSahibiBilgisiState();
}

class _EvSahibiBilgisiState extends State<EvSahibiBilgisi> {
  Map<String, dynamic>? listingWithHost;

  @override
  void initState() {
    super.initState();
    fetchListingWithHost();
  }

  Future<void> fetchListingWithHost() async {
    try {
      final response = await ApiService().getListingWithHostById(
        widget.listing['id'],
      );
      setState(() {
        listingWithHost =
            response.toJson(); // Assuming response is a Listing object
      });
    } catch (e) {
      print("❌ Host bilgisi alınamadı: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    if (listingWithHost == null) {
      return const Center(child: CircularProgressIndicator());
    }

    final host = listingWithHost!['host'];
    final int hostId = host?['id'] ?? 0;
    final String hostName = host?['name'] ?? 'Bilinmiyor';
    final String? profileImageRaw = host?['profile_image'];
    final String? profileImage =
        (profileImageRaw != null && profileImageRaw.isNotEmpty)
            ? (profileImageRaw.startsWith('/')
                ? '${ApiConstants.baseUrl}$profileImageRaw'
                : profileImageRaw)
            : null;
    print("👤 Gelen HOST JSON: $host");
    print("🖼️ profileImage: $profileImage");

    return Row(
      children: [
        Padding(
          padding: const EdgeInsets.all(20.0),
          child: CircleAvatar(
            radius: 30,
            backgroundImage:
                profileImage != null ? NetworkImage(profileImage) : null,
            child:
                profileImage == null
                    ? const Icon(Icons.person, size: 30)
                    : null,
          ),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextButton(
              onPressed: () {
                if (hostId != 0) {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder:
                          (context) =>
                              HostDetailScreen(listingID: widget.listing['id']),
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        "Bu ilana ait bir ev sahibi bilgisi bulunamadı.",
                      ),
                    ),
                  );
                }
              },
              style: ButtonStyle(
                foregroundColor: WidgetStateProperty.all(Colors.black),
                textStyle: WidgetStateProperty.all(
                  const TextStyle(
                    decoration: TextDecoration.underline,
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              child: Text('Ev Sahibi : $hostName'),
            ),
            const Text("5 yıldır ev sahibi"),
          ],
        ),
      ],
    );
  }
}
