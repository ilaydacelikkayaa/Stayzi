import 'package:flutter/material.dart';

class MekanAciklamasi extends StatelessWidget {
  const MekanAciklamasi({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Bu mekan hakkında",
            style: TextStyle(fontSize: 23, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 10),
          Text(
            "Virginia Hotel & Spa, doğayla iç içe huzurlu bir konaklama deneyimi sunar. "
            "Modern dekorasyonu, spa olanakları ve güler yüzlü hizmetiyle konuklarına eşsiz bir tatil atmosferi sağlar. "
            "Plaja ve yerel restoranlara sadece birkaç dakika mesafededir. Çiftler, aileler ve iş seyahati yapanlar için mükemmel bir tercihtir.",
            style: TextStyle(fontSize: 16, color: Colors.black87, height: 1.5),
          ),
          SizedBox(height: 20),
        ],
      ),
    );
  }
}
