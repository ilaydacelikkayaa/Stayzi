import 'package:flutter/material.dart';

class OlanaklarVeKurallar extends StatelessWidget {
  final Map<String, dynamic>? listing;

  const OlanaklarVeKurallar({super.key, this.listing});

  @override
  Widget build(BuildContext context) {
    final amenities = listing?['amenities'] as List<dynamic>?;
    final homeRules = listing?['home_rules'] as String?;

    // Yeni izin alanları
    final allowEvents = listing?['allow_events'] as int?;
    final allowSmoking = listing?['allow_smoking'] as int?;
    final allowCommercialPhoto = listing?['allow_commercial_photo'] as int?;
    final maxGuests = listing?['max_guests'] as int?;


    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10),
          child: Text(
            "Ev Olanakları",
            style: TextStyle(fontSize: 23, fontWeight: FontWeight.bold),
          ),
        ),
        if (amenities != null && amenities.isNotEmpty) ...[
          Padding(
            padding: const EdgeInsets.all(25.0),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children:
                  amenities
                      .map(
                        (amenity) => Chip(
                          label: Text(amenity.toString()),
                          backgroundColor: Colors.grey[200],
                          side: BorderSide(color: Colors.grey[300]!),
                        ),
                      )
                      .toList(),
            ),
          ),
        ] else ...[
          Padding(
            padding: const EdgeInsets.all(25.0),
            child: Text(
              "Bu ev için belirtilmiş olanak bulunmamaktadır.",
              style: TextStyle(color: Colors.grey[600]),
            ),
          ),
        ],
        Divider(thickness: 1, color: Colors.grey, endIndent: 20, indent: 20),
        SizedBox(height: 15),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10),
          child: Text(
            "Ev Kuralları",
            style: TextStyle(fontSize: 23, fontWeight: FontWeight.bold),
          ),
        ),
        if (homeRules != null && homeRules.isNotEmpty) ...[
          Padding(
            padding: const EdgeInsets.all(25.0),
            child: Text(
              homeRules,
              style: TextStyle(fontSize: 16, color: Colors.black87),
            ),
          ),
        ] else ...[
          Padding(
            padding: const EdgeInsets.all(25.0),
            child: Text(
              "Bu ev için belirtilmiş kural bulunmamaktadır.",
              style: TextStyle(color: Colors.grey[600]),
            ),
          ),
        ],

        // Yeni izin alanları bölümü
        SizedBox(height: 20),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10),
          child: Text(
            "İzinler ve Kısıtlamalar",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 25.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildPermissionItem(
                "Etkinlik Düzenleme",
                (allowEvents ?? 0) == 1 ? "İzin Veriliyor" : "İzin Verilmiyor",
                (allowEvents ?? 0) == 1 ? Icons.check_circle : Icons.cancel,
                (allowEvents ?? 0) == 1 ? Colors.green : Colors.red,
              ),
              SizedBox(height: 12),
              _buildPermissionItem(
                "Sigara İçme",
                (allowSmoking ?? 0) == 1 ? "İzin Veriliyor" : "İzin Verilmiyor",
                (allowSmoking ?? 0) == 1 ? Icons.check_circle : Icons.cancel,
                (allowSmoking ?? 0) == 1 ? Colors.green : Colors.red,
              ),
              SizedBox(height: 12),
              _buildPermissionItem(
                "Ticari Fotoğraf Çekimi",
                (allowCommercialPhoto ?? 0) == 1
                    ? "İzin Veriliyor"
                    : "İzin Verilmiyor",
                (allowCommercialPhoto ?? 0) == 1
                    ? Icons.check_circle
                    : Icons.cancel,
                (allowCommercialPhoto ?? 0) == 1 ? Colors.green : Colors.red,
              ),
              SizedBox(height: 12),
              if (maxGuests != null && maxGuests > 0) ...[
                _buildPermissionItem(
                  "Maksimum Misafir Sayısı",
                  "$maxGuests kişi",
                  Icons.people,
                  Colors.blue,
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPermissionItem(
    String title,
    String status,
    IconData icon,
    Color color,
  ) {
    return Row(
      children: [
        Icon(icon, color: color, size: 20),
        SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                ),
              ),
              Text(
                status,
                style: TextStyle(
                  fontSize: 14,
                  color: color,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
