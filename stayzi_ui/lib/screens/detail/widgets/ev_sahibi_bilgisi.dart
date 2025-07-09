import 'package:flutter/material.dart';
import 'package:stayzi_ui/screens/detail/host_detail_screen.dart';

class EvSahibiBilgisi extends StatelessWidget {
  const EvSahibiBilgisi({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Padding(
          padding: const EdgeInsets.all(20.0),
          child: CircleAvatar(backgroundColor: Colors.black),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => HostDetailScreen()),
                );
              },
              style: ButtonStyle(
                textStyle: WidgetStateProperty.all(
                  TextStyle(
                    decoration: TextDecoration.underline,
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ),
              child: Text("Ev Sahibi : Mehmet Çelikkaya"),
            ),
            Text("5 yıldır ev sahibi"),
          ],
        ),
      ],
    );
  }
}
