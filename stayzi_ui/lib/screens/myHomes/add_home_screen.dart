import 'dart:io';

import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:image_picker/image_picker.dart';

import '../../services/api_service.dart';

class AddHomeScreen extends StatefulWidget {
  const AddHomeScreen({super.key});

  @override
  State<AddHomeScreen> createState() => _AddHomeScreenState();
}

class _AddHomeScreenState extends State<AddHomeScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _capacityController = TextEditingController();


  final List<File> _selectedImages = [];
  File? _selectedImage;
  final List<String> _selectedAmenities = [];
  bool _isLoading = false;
  String? _error;
  String? _success;
  
  // İzin alanları
  bool _allowEvents = false;
  bool _allowSmoking = false;
  bool _allowCommercialPhoto = false;
  int _maxGuests = 1;

  final List<String> _availableAmenities = [
    'WiFi',
    'Klima',
    'Mutfak',
    'Çamaşır Makinesi',
    'Bulaşık Makinesi',
    'TV',
    'Otopark',
    'Balkon',
    'Bahçe',
    'Havuz',
    'Spor Salonu',
    'Güvenlik',
    'Asansör',
    'Sigara İçilmez',
    'Evcil Hayvan Kabul',
  ];

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    _priceController.dispose();
    _capacityController.dispose();

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

  void _removeImage() {
    setState(() {
      _selectedImage = null;
    });
  }

  void _toggleAmenity(String amenityName) {
    setState(() {
      final index = _selectedAmenities.indexWhere((a) => a == amenityName);
      if (index >= 0) {
        _selectedAmenities.removeAt(index);
      } else {
        _selectedAmenities.add(amenityName);
      }
    });
  }

  String? _buildHomeRulesText() {
    List<String> rules = [];

    // İzin bilgileri
    List<String> permissions = [];
    if (_allowEvents) {
      permissions.add('✓ Etkinliklere izin verilir');
    } else {
      permissions.add('✗ Etkinliklere izin verilmez');
    }

    if (_allowSmoking) {
      permissions.add('✓ Sigara içilir');
    } else {
      permissions.add('✗ Sigara içilmez');
    }

    if (_allowCommercialPhoto) {
      permissions.add('✓ Ticari fotoğraf ve film çekilmesine izin verilir');
    } else {
      permissions.add('✗ Ticari fotoğraf ve film çekilmesine izin verilmez');
    }

    // Maksimum misafir sayısı
    permissions.add('Maksimum misafir sayısı: $_maxGuests');

    // İzinleri ekle
    if (permissions.isNotEmpty) {
      rules.add('İzinler ve Kısıtlamalar:\n${permissions.join('\n')}');
    }

    return rules.isEmpty ? null : rules.join('\n\n');
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Geçici olarak fotoğraf zorunluluğunu kaldır
    // if (_selectedImages.isEmpty) {
    //   setState(() {
    //     _error = 'En az bir fotoğraf eklemelisiniz';
    //   });
    //   return;
    // }

    setState(() {
      _isLoading = true;
      _error = null;
      _success = null;
    });

    try {
      final price = double.parse(_priceController.text.trim());
      final capacity = int.tryParse(_capacityController.text.trim());

      double? lat;
      double? lng;
      try {
        List<Location> locations = await locationFromAddress(
          _locationController.text.trim(),
        );
        if (locations.isNotEmpty) {
          lat = locations.first.latitude;
          lng = locations.first.longitude;
        }
      } catch (e) {
        print("Konumdan koordinatlar alınamadı: $e");
      }

      await ApiService().createListing(
        title: _titleController.text.trim(),
        description:
            _descriptionController.text.trim().isEmpty
                ? null
                : _descriptionController.text.trim(),
        location:
            _locationController.text.trim().isEmpty
                ? null
                : _locationController.text.trim(),
        price: price,
        capacity: capacity,
        amenities:
            _selectedAmenities.isNotEmpty
                ? _selectedAmenities.map((name) {
                  final amenityIndex = _availableAmenities.indexOf(name);
                  return {"id": amenityIndex + 1, "name": name};
                }).toList()
                : null,
        photo: _selectedImage,
        homeRules: _buildHomeRulesText(),
        lat: lat,
        lng: lng,
      );

      setState(() {
        _success = 'İlan başarıyla oluşturuldu!';
      });

      if (context.mounted) {
        Navigator.pop(context, true);
      }
    } catch (e) {
      setState(() {
        _error = 'İlan oluşturulamadı: $e';
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
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        title: const Text(
          'Yeni İlan Ekle',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
            color: Colors.black,
          ),
        ),
        centerTitle: true,
      ),
      body:
          _isLoading
              ? const Center(
                child: CircularProgressIndicator(color: Colors.black),
              )
              : SafeArea(
                child: Form(
                  key: _formKey,
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Header
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.08),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.grey[100],
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Icon(
                                  Icons.add_home,
                                  color: Colors.black,
                                  size: 24,
                                ),
                              ),
                              const SizedBox(width: 16),
                              const Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Yeni İlan Ekle',
                                      style: TextStyle(
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black,
                                      ),
                                    ),
                                    SizedBox(height: 4),
                                    Text(
                                      'Ev ilanınızı oluşturun',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 24),

                        // Status Messages
                        if (_error != null)
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.red.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: Colors.red.withOpacity(0.3),
                              ),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.error_outline,
                                  color: Colors.red[600],
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    _error!,
                                    style: TextStyle(
                                      color: Colors.red[700],
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        if (_success != null)
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.green.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: Colors.green.withOpacity(0.3),
                              ),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.check_circle_outline,
                                  color: Colors.green[600],
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    _success!,
                                    style: TextStyle(
                                      color: Colors.green[700],
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        if (_error != null || _success != null)
                          const SizedBox(height: 20),

                        // Form
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.08),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Images Section
                                const Text(
                                  'Fotoğraf',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                  ),
                                ),
                                const SizedBox(height: 12),

                                if (_selectedImage != null) ...[
                                  Container(
                                    width: double.infinity,
                                    height: 200,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: Colors.grey.withOpacity(0.3),
                                      ),
                                    ),
                                    child: Stack(
                                      children: [
                                        ClipRRect(
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                          child: Image.file(
                                            _selectedImage!,
                                            width: double.infinity,
                                            height: 200,
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                        Positioned(
                                          top: 8,
                                          right: 8,
                                          child: GestureDetector(
                                            onTap: _removeImage,
                                            child: Container(
                                              padding: const EdgeInsets.all(6),
                                              decoration: const BoxDecoration(
                                                color: Colors.red,
                                                shape: BoxShape.circle,
                                              ),
                                              child: const Icon(
                                                Icons.close,
                                                color: Colors.white,
                                                size: 18,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                ],

                                OutlinedButton.icon(
                                  onPressed: _pickImage,
                                  icon: const Icon(
                                    Icons.add_photo_alternate,
                                    color: Colors.black,
                                  ),
                                  label: const Text(
                                    'Fotoğraf Ekle',
                                    style: TextStyle(color: Colors.black),
                                  ),
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: Colors.black,
                                    side: const BorderSide(color: Colors.black),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                ),

                                const SizedBox(height: 24),

                                // Basic Information
                                const Text(
                                  'Temel Bilgiler',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                  ),
                                ),
                                const SizedBox(height: 16),

                                _buildTextField(
                                  controller: _titleController,
                                  label: 'Başlık *',
                                  hint: 'İlan başlığı',
                                  validator: (value) {
                                    if (value == null || value.trim().isEmpty) {
                                      return 'Başlık alanı zorunludur';
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 16),

                                _buildTextField(
                                  controller: _descriptionController,
                                  label: 'Açıklama',
                                  hint: 'İlan açıklaması',
                                  maxLines: 3,
                                ),
                                const SizedBox(height: 16),

                                _buildTextField(
                                  controller: _locationController,
                                  label: 'Konum',
                                  hint: 'Şehir, mahalle',
                                ),
                                const SizedBox(height: 16),

                                _buildTextField(
                                  controller: _priceController,
                                  label: 'Fiyat (₺/gece) *',
                                  hint: '0',
                                  keyboardType: TextInputType.number,
                                  validator: (value) {
                                    if (value == null || value.trim().isEmpty) {
                                      return 'Fiyat alanı zorunludur';
                                    }
                                    if (double.tryParse(value.trim()) == null) {
                                      return 'Geçerli bir fiyat giriniz';
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 16),

                                _buildTextField(
                                  controller: _capacityController,
                                  label: 'Kapasite',
                                  hint: 'Misafir sayısı',
                                  keyboardType: TextInputType.number,
                                ),

                                const SizedBox(height: 24),

                                // Ev Kuralları
                                const Text(
                                  'Ev Kuralları',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                  ),
                                ),
                                const SizedBox(height: 16),

                                // Etkinliklere izin
                                _buildPermissionRow(
                                  title: 'Etkinliklere izin verilir',
                                  value: _allowEvents,
                                  onChanged: (value) {
                                    setState(() {
                                      _allowEvents = value;
                                    });
                                  },
                                ),
                                const SizedBox(height: 12),

                                // Sigara içilir
                                _buildPermissionRow(
                                  title: 'Sigara içilir',
                                  value: _allowSmoking,
                                  onChanged: (value) {
                                    setState(() {
                                      _allowSmoking = value;
                                    });
                                  },
                                ),
                                const SizedBox(height: 12),

                                // Ticari fotoğraf ve film çekilmesine izin
                                _buildPermissionRow(
                                  title:
                                      'Ticari fotoğraf ve film çekilmesine izin verilir',
                                  value: _allowCommercialPhoto,
                                  onChanged: (value) {
                                    setState(() {
                                      _allowCommercialPhoto = value;
                                    });
                                  },
                                ),
                                const SizedBox(height: 16),

                                // İzin verilen misafir sayısı
                                const Text(
                                  'İzin verilen misafir sayısı',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.black,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 12,
                                  ),
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      color: Colors.grey.withOpacity(0.3),
                                    ),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      IconButton(
                                        onPressed: () {
                                          if (_maxGuests > 1) {
                                            setState(() {
                                              _maxGuests--;
                                            });
                                          }
                                        },
                                        icon: const Icon(
                                          Icons.remove_circle_outline,
                                        ),
                                        color:
                                            _maxGuests > 1
                                                ? Colors.black
                                                : Colors.grey,
                                      ),
                                      Text(
                                        '$_maxGuests',
                                        style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      IconButton(
                                        onPressed: () {
                                          setState(() {
                                            _maxGuests++;
                                          });
                                        },
                                        icon: const Icon(
                                          Icons.add_circle_outline,
                                        ),
                                        color: Colors.black,
                                      ),
                                    ],
                                  ),
                                ),

                                const SizedBox(height: 24),

                                // Amenities Section
                                const Text(
                                  'Olanaklar',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                  ),
                                ),
                                const SizedBox(height: 12),

                                Wrap(
                                  spacing: 8,
                                  runSpacing: 8,
                                  children:
                                      _availableAmenities.map((amenity) {
                                        final isSelected = _selectedAmenities
                                            .contains(amenity);
                                        return FilterChip(
                                          label: Text(
                                            amenity,
                                            style: TextStyle(
                                              color: Colors.black,
                                            ),
                                          ),
                                          selected: isSelected,
                                          onSelected:
                                              (selected) =>
                                                  _toggleAmenity(amenity),
                                          selectedColor: Colors.black
                                              .withOpacity(0.1),
                                          checkmarkColor: Colors.black,
                                          side: BorderSide(
                                            color:
                                                isSelected
                                                    ? Colors.black
                                                    : Colors.grey.withOpacity(
                                                      0.3,
                                                    ),
                                          ),
                                        );
                                      }).toList(),
                                ),

                                const SizedBox(height: 32),

                                // Submit Button
                                SizedBox(
                                  width: double.infinity,
                                  height: 56,
                                  child: ElevatedButton(
                                    onPressed: _submitForm,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.black,
                                      foregroundColor: Colors.white,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                    ),
                                    child: const Text(
                                      'İlanı Oluştur',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    TextInputType? keyboardType,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          maxLines: maxLines,
          validator: validator,
          decoration: InputDecoration(
            hintText: hint,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.withOpacity(0.3)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.withOpacity(0.3)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.black),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.red.withOpacity(0.5)),
            ),
            filled: true,
            fillColor: const Color(0xFFF8F9FA),
          ),
        ),
      ],
    );
  }

  Widget _buildPermissionRow({
    required String title,
    required bool value,
    required Function(bool) onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.withOpacity(0.3)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              title,
              style: const TextStyle(fontSize: 14, color: Colors.black),
            ),
          ),
          Row(
            children: [
              // Çarpı butonu (izin verilmiyor)
              GestureDetector(
                onTap: () => onChanged(false),
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: !value ? Colors.red : Colors.grey.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: !value ? Colors.red : Colors.grey.withOpacity(0.3),
                      width: 2,
                    ),
                  ),
                  child: Icon(
                    Icons.close,
                    color: !value ? Colors.white : Colors.grey,
                    size: 18,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // Tik butonu (izin veriliyor)
              GestureDetector(
                onTap: () => onChanged(true),
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: value ? Colors.green : Colors.grey.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color:
                          value ? Colors.green : Colors.grey.withOpacity(0.3),
                      width: 2,
                    ),
                  ),
                  child: Icon(
                    Icons.check,
                    color: value ? Colors.white : Colors.grey,
                    size: 18,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
