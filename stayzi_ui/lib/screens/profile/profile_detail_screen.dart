import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../services/api_service.dart';

class ProfileDetailScreen extends StatefulWidget {
  const ProfileDetailScreen({super.key});

  @override
  State<ProfileDetailScreen> createState() => _ProfileDetailScreenState();
}

class _ProfileDetailScreenState extends State<ProfileDetailScreen> {
  final String name = "Ahmet Koca";
  final String email = "ahmet@example.com";
  final String phone = "+90 555 555 55 55";

  File? _imageFile;
  bool _isUploading = false;
  String? _uploadError;
  String? _uploadSuccess;

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedImage = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );
    if (pickedImage != null) {
      setState(() {
        _imageFile = File(pickedImage.path);
      });
    }
  }

  Future<void> _uploadProfileImage() async {
    if (_imageFile == null) return;
    setState(() {
      _isUploading = true;
      _uploadError = null;
      _uploadSuccess = null;
    });
    try {
      await ApiService().updateProfile(profileImage: _imageFile);
      setState(() {
        _uploadSuccess = 'Profil fotoğrafı başarıyla yüklendi!';
      });
    } catch (e) {
      setState(() {
        _uploadError = 'Yükleme başarısız: $e';
      });
    } finally {
      setState(() {
        _isUploading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    String initial = name.isNotEmpty ? name[0].toUpperCase() : '?';

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              height: 230,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black26,
                    offset: Offset(0, 4),
                    blurRadius: 6,
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    GestureDetector(
                      onTap: _pickImage,
                      child:
                          _imageFile != null
                              ? CircleAvatar(
                                radius: 45,
                                backgroundImage: FileImage(_imageFile!),
                              )
                              : CircleAvatar(
                                radius: 45,
                                backgroundColor: Colors.black,
                                child: Text(
                                  initial,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 40,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                    ),
                    const SizedBox(height: 8),
                    if (_isUploading) const CircularProgressIndicator(),
                    if (_uploadError != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Text(
                          _uploadError!,
                          style: const TextStyle(color: Colors.red),
                        ),
                      ),
                    if (_uploadSuccess != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Text(
                          _uploadSuccess!,
                          style: const TextStyle(color: Colors.green),
                        ),
                      ),
                    if (_imageFile != null && !_isUploading)
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: ElevatedButton(
                          onPressed: _uploadProfileImage,
                          child: const Text('Kaydet'),
                        ),
                      ),
                    const SizedBox(height: 8),
                    Text(
                      name,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Misafir',
                      style: TextStyle(
                        fontSize: 16,
                        color: Color.fromARGB(179, 0, 0, 0),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text('Ad Soyad: $name', style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 10),
            Text('Email: $email', style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 10),
            Text('Telefon: $phone', style: const TextStyle(fontSize: 18)),
          ],
        ),
      ),
    );
  }
}
