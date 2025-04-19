import 'package:flutter/material.dart';

class AddHomeScreen extends StatefulWidget {
  const AddHomeScreen({super.key});

  @override
  State<AddHomeScreen> createState() => _AddHomeScreenState();
}

class _AddHomeScreenState extends State<AddHomeScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();

  String? selectedImage; // geçici olarak string


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Ev İlanı Ekle')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              GestureDetector(
                onTap: () {
                  // ileride image picker burada eklenecek
                  setState(() {
                    selectedImage =
                        'https://tekce.net/files/emlaklar/ic/650x450/ist-0784-spacious-apartment-with-sea-view-in-istanbul-asian-side-ih-8.jpeg';
                  });
                },
                child: Container(
                  height: 150,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(10),
                    image:
                        selectedImage != null
                            ? DecorationImage(
                              image: NetworkImage(selectedImage!),
                              fit: BoxFit.cover,
                            )
                            : null,
                  ),
                  child:
                      selectedImage == null
                          ? const Center(child: Text("Fotoğraf Ekle"))
                          : null,
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'Başlık'),
                validator: (value) => value!.isEmpty ? 'Başlık giriniz' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _locationController,
                decoration: const InputDecoration(labelText: 'Konum'),
                validator: (value) => value!.isEmpty ? 'Konum giriniz' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _priceController,
                decoration: const InputDecoration(labelText: 'Fiyat (TL)'),
                keyboardType: TextInputType.number,
                validator: (value) => value!.isEmpty ? 'Fiyat giriniz' : null,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    // burada backend'e kayıt işlemi yapılacak
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('İlan eklendi')),
                    );
                    Navigator.pop(context);
                  }
                },
                child: const Text(
                  'Kaydet',
                  style: TextStyle(color: Colors.black),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
