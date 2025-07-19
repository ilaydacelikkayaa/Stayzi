import 'package:flutter/material.dart';

class OlanaklarVeKurallar extends StatefulWidget {
  final Map<String, dynamic> listing;

  const OlanaklarVeKurallar({super.key, required this.listing});

  @override
  State<OlanaklarVeKurallar> createState() => _OlanaklarVeKurallarState();
}

class _OlanaklarVeKurallarState extends State<OlanaklarVeKurallar> {
  @override
  Widget build(BuildContext context) {
    final List<dynamic>? amenities = widget.listing['amenities'];
    final String homeRules =
        widget.listing['home_rules'] ?? 'Ev kuralları belirtilmemiş.';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10),
          child: Text(
            "Olanaklar",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 25.0, vertical: 10),
          child:
              amenities != null && amenities.isNotEmpty
                  ? Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children:
                        amenities.map((item) {
                          return Chip(
                            label: Text(item.toString()),
                            backgroundColor: Colors.grey[200],
                            padding: EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 5,
                            ),
                          );
                        }).toList(),
                  )
                  : Text("Bu ilana ait olanak bilgisi bulunmamaktadır."),
        ),
        SizedBox(height: 20),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10),
          child: Text(
            "Ev Kuralları",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 25.0),
          child: Card(
            color: Colors.grey[100],
            elevation: 2,
            margin: EdgeInsets.only(bottom: 20),
            child: Padding(
              padding: const EdgeInsets.all(15.0),
              child: Text(
                homeRules,
                style: TextStyle(fontSize: 16, color: Colors.black87),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
