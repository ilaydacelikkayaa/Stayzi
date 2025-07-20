import 'package:flutter/material.dart';
import 'package:stayzi_ui/screens/detail/host_detail_screen.dart';
import 'package:stayzi_ui/services/api_constants.dart';

class EvSahibiBilgisi extends StatelessWidget {
  final Map<String, dynamic> listing;

  const EvSahibiBilgisi({super.key, required this.listing});

  @override
  Widget build(BuildContext context) {
    print("🏠 EvSahibiBilgisi - İlan verisi: $listing");
    
    // Host bilgisini al
    final hostData = listing['host'];
    print("🏠 Host verisi: $hostData");
    
    if (hostData == null) {
      return Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Icon(Icons.person_off, color: Colors.grey, size: 40),
            SizedBox(height: 8),
            Text(
              'Ev sahibi bilgisi bulunamadı',
              style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      );
    }

    final int hostId = hostData['id'] ?? 0;
    final String hostName = hostData['name'] ?? 'Bilinmiyor';
    final String? profileImageRaw = hostData['profile_image'];
    final String? profileImage =
        (profileImageRaw != null && profileImageRaw.isNotEmpty)
            ? (profileImageRaw.startsWith('/')
                ? '${ApiConstants.baseUrl}$profileImageRaw'
                : profileImageRaw)
            : null;

    print("🏠 Host bilgileri:");
    print("  ID: $hostId");
    print("  İsim: $hostName");
    print("  Profil resmi: $profileImage");

    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Row(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundImage:
                profileImage != null ? NetworkImage(profileImage) : null,
            child:
                profileImage == null
                    ? const Icon(Icons.person, size: 30)
                    : null,
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
                            (context) => HostDetailScreen(
                              listingID: listing['id'],
                            ),
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
                child: Text('Ev Sahibi: $hostName'),
              ),
              const Text("5 yıldır ev sahibi"),
            ],
          ),
        ],
      ),
    );
  }
}
