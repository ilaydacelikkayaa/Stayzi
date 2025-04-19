import 'package:flutter/material.dart';

class EditHomeScreen extends StatefulWidget {
  final Map<String, String> ilan;

  const EditHomeScreen({super.key, required this.ilan});

  @override
  State<EditHomeScreen> createState() => _EditHomeScreenState();
}

class _EditHomeScreenState extends State<EditHomeScreen> {
  late TextEditingController baslikController;
  late TextEditingController konumController;
  late TextEditingController fiyatController;

  @override
  void initState() {
    super.initState();
    baslikController = TextEditingController(text: widget.ilan['baslik']);
    konumController = TextEditingController(text: widget.ilan['konum']);
    fiyatController = TextEditingController(text: widget.ilan['fiyat']);
  }

  @override
  void dispose() {
    baslikController.dispose();
    konumController.dispose();
    fiyatController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("İlanı Düzenle")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: baslikController,
              decoration: const InputDecoration(labelText: "Başlık"),
            ),
            TextField(
              controller: konumController,
              decoration: const InputDecoration(labelText: "Konum"),
            ),
            TextField(
              controller: fiyatController,
              decoration: const InputDecoration(labelText: "Fiyat"),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Backend'e kaydetme işlemi yapılabilir
                Navigator.pop(context);
              },
              child: const Text("Kaydet"),
            ),
          ],
        ),
      ),
    );
  }
}
