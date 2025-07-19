import 'package:flutter/material.dart';
import 'package:stayzi_ui/screens/detail/host_detail_screen.dart';
import 'package:stayzi_ui/screens/favorite/favorite_list_detail_screen.dart'
    as ApiConstants;
import 'package:stayzi_ui/services/api_service.dart';

class EvSahibiBilgisi extends StatefulWidget {
  final Map<String, dynamic> listing;

  const EvSahibiBilgisi({super.key, required this.listing});

  @override
  State<EvSahibiBilgisi> createState() => _EvSahibiBilgisiState();
}

class _EvSahibiBilgisiState extends State<EvSahibiBilgisi> {
  Map<String, dynamic>? listingWithHost;
  Map<String, dynamic>? currentUser;

  @override
  void initState() {
    super.initState();
    _loadHostData();
  }

  Future<void> _loadHostData() async {
    try {
      // Eğer bu benim ilanımsa, giriş yapan kullanıcının bilgilerini al
      if (widget.listing['is_my_listing'] == true) {
        final user = await ApiService().getCurrentUser();
        setState(() {
          currentUser = user.toJson();
        });
      } else {
        // Değilse, normal ev sahibi bilgilerini al
        final listing = await ApiService().getListingWithHostById(
          widget.listing['id'],
        );
        setState(() {
          listingWithHost = listing.toJson();
        });
      }
    } catch (e) {
      print("❌ Host bilgisi alınamadı: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    // Eğer bu benim ilanımsa, giriş yapan kullanıcının bilgilerini kullan
    if (widget.listing['is_my_listing'] == true) {
      if (currentUser == null) {
        return const Center(child: CircularProgressIndicator());
      }

      final String hostName =
          '${currentUser!['name'] ?? ''} ${currentUser!['surname'] ?? ''}'
              .trim();
      final String? profileImageRaw = currentUser!['profile_image'];
      final String? profileImage =
          (profileImageRaw != null && profileImageRaw.isNotEmpty)
              ? (profileImageRaw.startsWith('/')
                  ? '${ApiConstants.baseUrl}$profileImageRaw'
                  : profileImageRaw)
              : null;

      return _buildHostInfo(hostName, profileImage, isMyListing: true);
    } else {
      // Normal ev sahibi bilgileri
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

      return _buildHostInfo(hostName, profileImage, hostId: hostId);
    }
  }

  Widget _buildHostInfo(
    String hostName,
    String? profileImage, {
    int? hostId,
    bool isMyListing = false,
  }) {
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
                  if (isMyListing) {
                    // Benim ilanımsa, profil sayfasına yönlendir
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Bu sizin ilanınız")),
                    );
                  } else if (hostId != null && hostId != 0) {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder:
                            (context) => HostDetailScreen(
                              listingID: widget.listing['id'],
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
                child: Text(
                  isMyListing
                      ? 'Ev Sahibi: Siz ($hostName)'
                      : 'Ev Sahibi: $hostName',
                ),
              ),
              Text(isMyListing ? "Sizin ilanınız" : "5 yıldır ev sahibi"),
            ],
          ),
        ],
      ),
    );
  }
}
