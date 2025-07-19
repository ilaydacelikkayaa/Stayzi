import 'package:flutter/material.dart';
import 'package:stayzi_ui/screens/detail/host_detail_screen.dart';

class EvSahibiBilgisi extends StatelessWidget {
  final Map<String, dynamic> listing;

  const EvSahibiBilgisi({super.key, required this.listing});

  @override
  Widget build(BuildContext context) {
    final hostName = listing['host_name'] ?? 'Bilinmiyor';
    final hostUser = listing['host_user'];
    
    return Row(
      children: [
        Padding(
          padding: const EdgeInsets.all(20.0),
          child: CircleAvatar(
            backgroundColor: Colors.black,
            child:
                hostUser != null && hostUser['profile_image'] != null
                    ? ClipOval(
                      child: Image.network(
                        hostUser['profile_image'],
                        width: 40,
                        height: 40,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return const Icon(Icons.person, color: Colors.white);
                        },
                      ),
                    )
                    : const Icon(Icons.person, color: Colors.white),
          ),
        ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder:
                          (context) => HostDetailScreen(hostUser: hostUser),
                    ),
                  );
                },
                style: ButtonStyle(
                  textStyle: MaterialStateProperty.all(
                    const TextStyle(
                      decoration: TextDecoration.underline,
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ),
                child: Text(
                  'Ev Sahibi : $hostName'),
              ),
              Text(
                hostUser != null
                    ? "Ev sahibi"
                    : "Ev sahibi bilgisi mevcut değil",
                style: TextStyle(color: Colors.grey[600], fontSize: 12),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
