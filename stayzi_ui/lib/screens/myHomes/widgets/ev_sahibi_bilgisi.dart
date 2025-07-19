import 'package:flutter/material.dart';
import 'package:stayzi_ui/services/api_constants.dart';
import 'package:stayzi_ui/services/api_service.dart';

class EvSahibiBilgisi extends StatefulWidget {
  final Map<String, dynamic> listing;

  const EvSahibiBilgisi({super.key, required this.listing});

  @override
  State<EvSahibiBilgisi> createState() => _EvSahibiBilgisiState();
}

class _EvSahibiBilgisiState extends State<EvSahibiBilgisi> {
  Map<String, dynamic>? currentUser;

  @override
  void initState() {
    super.initState();
    _loadCurrentUser();
  }

  Future<void> _loadCurrentUser() async {
    try {
      // My Homes'ta her zaman giriş yapan kullanıcının bilgilerini al
      final user = await ApiService().getCurrentUser();
      setState(() {
        currentUser = user.toJson();
      });
    } catch (e) {
      print("❌ Kullanıcı bilgisi alınamadı: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    if (currentUser == null) {
      return const Center(child: CircularProgressIndicator());
    }

    final String hostName =
        '${currentUser!['name'] ?? ''} ${currentUser!['surname'] ?? ''}'.trim();
    final String? profileImageRaw = currentUser!['profile_image'];
    final String? profileImage =
        (profileImageRaw != null && profileImageRaw.isNotEmpty)
            ? (profileImageRaw.startsWith('/')
                ? '${ApiConstants.baseUrl}$profileImageRaw'
                : profileImageRaw)
            : null;

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
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Bu sizin ilanınız")),
                  );
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
                child: Text('Ev Sahibi: Siz ($hostName)'),
              ),
              const Text("Sizin ilanınız"),
            ],
          ),
        ],
      ),
    );
  }
}
