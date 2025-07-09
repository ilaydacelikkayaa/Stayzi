import 'package:flutter/material.dart';

class OlanaklarVeKurallar extends StatelessWidget {
  const OlanaklarVeKurallar({super.key});

  @override
  Widget build(BuildContext context) {
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
        Padding(
          padding: const EdgeInsets.all(25.0),
          child: Text(
            "Eve ait olanaklar burada database üzerinden yerleştirilecek. Bu yüzden burası şu an boş.",
          ),
        ),
        Divider(thickness: 1, color: Colors.grey, endIndent: 20, indent: 20),
        SizedBox(height: 15),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10),
          child: Text(
            "Ev Kuralları",
            style: TextStyle(fontSize: 23, fontWeight: FontWeight.bold),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(25.0),
          child: Text(
            "Eve ait olanaklar burada database üzerinden yerleştirilecek. Bu yüzden burası şu an boş.",
          ),
        ),
      ],
    );
  }
}
