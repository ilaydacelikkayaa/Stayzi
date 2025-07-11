import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../services/api_service.dart';

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
  File? _selectedImage;
  bool _isLoading = false;
  String? _error;
  String? _success;

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

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

  Future<void> _submitForm() async {
    setState(() {
      _isLoading = true;
      _error = null;
      _success = null;
    });
    try {
      await ApiService().updateListing(
        id: int.parse(widget.ilan['id']!),
        title: baslikController.text.trim(),
        location: konumController.text.trim(),
        price: fiyatController.text.trim(),
        image: _selectedImage,
      );
      setState(() {
        _success = 'İlan başarıyla güncellendi!';
      });
      if (context.mounted) {
        Navigator.pop(context);
      }
    } catch (e) {
      setState(() {
        _error = 'İlan güncellenemedi: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("İlanı Düzenle")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            GestureDetector(
              onTap: _pickImage,
              child: Container(
                height: 150,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(10),
                  image:
                      _selectedImage != null
                          ? DecorationImage(
                            image: FileImage(_selectedImage!),
                            fit: BoxFit.cover,
                          )
                          : null,
                ),
                child:
                    _selectedImage == null
                        ? const Center(
                          child: Text("Fotoğraf Ekle veya Değiştir"),
                        )
                        : null,
              ),
            ),
            const SizedBox(height: 16),
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
              onPressed: _isLoading ? null : _submitForm,
              child:
                  _isLoading
                      ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                      : const Text("Kaydet"),
            ),
            if (_error != null)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(_error!, style: const TextStyle(color: Colors.red)),
              ),
            if (_success != null)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(
                  _success!,
                  style: const TextStyle(color: Colors.green),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
