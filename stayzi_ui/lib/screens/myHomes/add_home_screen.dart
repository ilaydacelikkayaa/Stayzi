import 'dart:io';

import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:image_picker/image_picker.dart';

import '../../services/api_service.dart';
import '../../services/location_service.dart';
import 'location_picker_screen.dart';

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
  // final TextEditingController _capacityController = TextEditingController(); // kaldırıldı
  final TextEditingController _maxGuestsController = TextEditingController();
  final TextEditingController _bedCountController = TextEditingController();
  final TextEditingController _bathroomCountController =
      TextEditingController();
  final TextEditingController _roomCountController = TextEditingController();

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
  // int _maxGuests = 1; // kaldırıldı, sadece controller kullanılacak

  // Konum seçimi için yeni alanlar
  double? _selectedLatitude;
  double? _selectedLongitude;
  bool _isLocationLoading = false;
  String? _locationError;

  List<String> _availableAmenities = [
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
  void initState() {
    super.initState();
    _fetchAmenities();
  }

  Future<void> _fetchAmenities() async {
    try {
      print("🔍 _fetchAmenities başlatıldı");
      final amenities = await ApiService().fetchAmenities();
      print("🔍 Alınan amenities: $amenities");
      setState(() {
        _availableAmenities = amenities;
      });
    } catch (e) {
      print("❌ _fetchAmenities hatası: $e");
      // Hata yönetimi - varsayılan listeyi kullan
      setState(() {
        _availableAmenities = [
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
      });
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    _priceController.dispose();
    _maxGuestsController.dispose();
    _roomCountController.dispose();
    _bedCountController.dispose();
    _bathroomCountController.dispose();
    super.dispose();
  }

  // Mevcut konumu al
  Future<void> _getCurrentLocation() async {
    setState(() {
      _isLocationLoading = true;
      _locationError = null;
    });

    try {
      final locationService = LocationService();
      final position = await locationService.getCurrentLocation();

      setState(() {
        _selectedLatitude = position.latitude;
        _selectedLongitude = position.longitude;
        _isLocationLoading = false;
      });

      // Koordinatlardan adres al
      await _getAddressFromCoordinates();
    } catch (e) {
      setState(() {
        _locationError = 'Konum alınamadı: $e';
        _isLocationLoading = false;
      });
    }
  }

  // Koordinatlardan adres al
  Future<void> _getAddressFromCoordinates() async {
    if (_selectedLatitude == null || _selectedLongitude == null) return;

    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        _selectedLatitude ?? 0.0,
        _selectedLongitude ?? 0.0,
      );

      if (placemarks.isNotEmpty) {
        final placemark = placemarks.first;
        final address = [
          placemark.locality,
          placemark.subLocality,
          placemark.thoroughfare,
        ].where((e) => e != null && e.isNotEmpty).join(', ');

        setState(() {
          _locationController.text = address;
        });
      }
    } catch (e) {
      print('Adres alınamadı: $e');
    }
  }

  // Adresten koordinat al
  Future<void> _getCoordinatesFromAddress() async {
    if (_locationController.text.trim().isEmpty) return;

    setState(() {
      _isLocationLoading = true;
      _locationError = null;
    });

    try {
      List<Location> locations = await locationFromAddress(
        _locationController.text.trim(),
      );

      if (locations.isNotEmpty) {
        setState(() {
          _selectedLatitude = locations.first.latitude;
          _selectedLongitude = locations.first.longitude;
          _isLocationLoading = false;
        });
      } else {
        setState(() {
          _locationError = 'Bu adres için konum bulunamadı';
          _isLocationLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _locationError = 'Adres işlenirken hata oluştu';
        _isLocationLoading = false;
      });
    }
  }

  // Haritadan konum seç
  void _selectLocationFromMap() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder:
            (context) => LocationPickerScreen(
              initialLatitude:
                  _selectedLatitude ?? 39.9334, // İstanbul varsayılan
              initialLongitude: _selectedLongitude ?? 32.8597,
              onLocationSelected: (lat, lng, address) {
                setState(() {
                  _selectedLatitude = lat;
                  _selectedLongitude = lng;
                  _locationController.text = address;
                });
              },
            ),
      ),
    );
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
    permissions.add(
      'Maksimum misafir sayısı: ${_maxGuestsController.text.trim()}',
    );

    // İzinleri ekle
    if (permissions.isNotEmpty) {
      rules.add('İzinler ve Kısıtlamalar:\n${permissions.join('\n')}');
    }

    return rules.isEmpty ? null : rules.join('\n\n');
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState == null || !_formKey.currentState!.validate()) {
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
      // final capacity = int.tryParse(_capacityController.text.trim()); // kaldırıldı

      // Koordinatları belirle
      double? lat = _selectedLatitude;
      double? lng = _selectedLongitude;

      // Eğer koordinat seçilmemişse adresten al
      if (lat == null || lng == null) {
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
        maxGuests: int.tryParse(_maxGuestsController.text.trim()),
        roomCount: int.tryParse(_roomCountController.text.trim()),
        bedCount: int.tryParse(_bedCountController.text.trim()),
        bathroomCount: int.tryParse(_bathroomCountController.text.trim()),
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
                                    _error ?? 'Bilinmeyen hata',
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
                                    _success ?? 'Başarılı',
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

                                // Konum Seçimi
                                const Text(
                                  'Konum *',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.black,
                                  ),
                                ),
                                const SizedBox(height: 8),

                                // Konum giriş alanı
                                _buildTextField(
                                  controller: _locationController,
                                  label: 'Adres',
                                  hint: 'Şehir, mahalle, sokak',
                                  onChanged: (value) {
                                    // Adres değiştiğinde koordinatları sıfırla
                                    if (_selectedLatitude != null ||
                                        _selectedLongitude != null) {
                                      setState(() {
                                        _selectedLatitude = null;
                                        _selectedLongitude = null;
                                      });
                                    }
                                  },
                                ),

                                // Konum seçim butonları
                                const SizedBox(height: 12),
                                Row(
                                  children: [
                                    Expanded(
                                      child: OutlinedButton.icon(
                                        onPressed:
                                            _isLocationLoading
                                                ? null
                                                : _getCurrentLocation,
                                        icon:
                                            _isLocationLoading
                                                ? const SizedBox(
                                                  width: 16,
                                                  height: 16,
                                                  child:
                                                      CircularProgressIndicator(
                                                        strokeWidth: 2,
                                                      ),
                                                )
                                                : const Icon(
                                                  Icons.my_location,
                                                  size: 18,
                                                ),
                                        label: Text(
                                          _isLocationLoading
                                              ? 'Alınıyor...'
                                              : 'Mevcut Konum',
                                          style: const TextStyle(fontSize: 12),
                                        ),
                                        style: OutlinedButton.styleFrom(
                                          foregroundColor: Colors.black,
                                          side: const BorderSide(
                                            color: Colors.black,
                                          ),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                          ),
                                          padding: const EdgeInsets.symmetric(
                                            vertical: 8,
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: OutlinedButton.icon(
                                        onPressed:
                                            _isLocationLoading
                                                ? null
                                                : _selectLocationFromMap,
                                        icon: const Icon(Icons.map, size: 18),
                                        label: const Text(
                                          'Haritadan Seç',
                                          style: TextStyle(fontSize: 12),
                                        ),
                                        style: OutlinedButton.styleFrom(
                                          foregroundColor: Colors.black,
                                          side: const BorderSide(
                                            color: Colors.black,
                                          ),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                          ),
                                          padding: const EdgeInsets.symmetric(
                                            vertical: 8,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),

                                // Koordinat bilgisi
                                if (_selectedLatitude != null &&
                                    _selectedLongitude != null) ...[
                                  const SizedBox(height: 12),
                                  Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: Colors.green.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(
                                        color: Colors.green.withOpacity(0.3),
                                      ),
                                    ),
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.check_circle,
                                          color: Colors.green[600],
                                          size: 20,
                                        ),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Text(
                                            'Koordinatlar alındı: ${_selectedLatitude?.toStringAsFixed(6) ?? 'N/A'}, ${_selectedLongitude?.toStringAsFixed(6) ?? 'N/A'}',
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.green[700],
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],

                                // Hata mesajı
                                if (_locationError != null) ...[
                                  const SizedBox(height: 8),
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: Colors.red.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(
                                        color: Colors.red.withOpacity(0.3),
                                      ),
                                    ),
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.error_outline,
                                          color: Colors.red[600],
                                          size: 16,
                                        ),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Text(
                                            _locationError ?? 'Konum hatası',
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.red[700],
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
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

                                // Oda, yatak, banyo alanları
                                _buildTextField(
                                  controller: _roomCountController,
                                  label: 'Oda Sayısı',
                                  hint: 'Oda sayısı',
                                  keyboardType: TextInputType.number,
                                ),
                                const SizedBox(height: 16),
                                _buildTextField(
                                  controller: _bedCountController,
                                  label: 'Yatak Sayısı',
                                  hint: 'Yatak sayısı',
                                  keyboardType: TextInputType.number,
                                ),
                                const SizedBox(height: 16),
                                _buildTextField(
                                  controller: _bathroomCountController,
                                  label: 'Banyo Sayısı',
                                  hint: 'Banyo sayısı',
                                  keyboardType: TextInputType.number,
                                ),
                                const SizedBox(height: 16),
                                _buildTextField(
                                  controller: _maxGuestsController,
                                  label: 'İzin Verilen Misafir Sayısı *',
                                  hint: 'Misafir sayısı',
                                  keyboardType: TextInputType.number,
                                  validator: (value) {
                                    if (value == null || value.trim().isEmpty) {
                                      return 'Misafir sayısı zorunludur';
                                    }
                                    if (int.tryParse(value.trim()) == null) {
                                      return 'Geçerli bir misafir sayısı giriniz';
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 16),

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
                                          final currentValue =
                                              int.tryParse(
                                                _maxGuestsController.text
                                                    .trim(),
                                              ) ??
                                              1;
                                          if (currentValue > 1) {
                                            setState(() {
                                              _maxGuestsController.text =
                                                  (currentValue - 1)
                                                      .toString();
                                            });
                                          }
                                        },
                                        icon: const Icon(
                                          Icons.remove_circle_outline,
                                        ),
                                        color:
                                            (int.tryParse(
                                                      _maxGuestsController.text
                                                          .trim(),
                                                        ) ??
                                                        1) >
                                                    1
                                                ? Colors.black
                                                : Colors.grey,
                                      ),
                                      Text(
                                        _maxGuestsController.text.trim(),
                                        style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      IconButton(
                                        onPressed: () {
                                          final currentValue =
                                              int.tryParse(
                                                _maxGuestsController.text
                                                    .trim(),
                                              ) ??
                                              1;
                                          setState(() {
                                            _maxGuestsController.text =
                                                (currentValue + 1)
                                                    .toString();
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
                                        return GestureDetector(
                                          onTap: () => _toggleAmenity(amenity),
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 14,
                                              vertical: 8,
                                            ),
                                            decoration: BoxDecoration(
                                              color:
                                                  isSelected
                                                      ? Colors.grey[200]
                                                      : Colors.white,
                                              borderRadius:
                                                  BorderRadius.circular(16),
                                              border: Border.all(
                                                color:
                                                    isSelected
                                                        ? Colors.black
                                                        : Colors.grey
                                                            .withOpacity(0.3),
                                                width: 2,
                                              ),
                                            ),
                                            child: Text(
                                              amenity,
                                              style: TextStyle(
                                                color: Colors.black,
                                                fontWeight:
                                                    isSelected
                                                        ? FontWeight.bold
                                                        : FontWeight.normal,
                                              ),
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
    Function(String)? onChanged,
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
          onChanged: onChanged,
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
