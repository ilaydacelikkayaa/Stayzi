import 'dart:io';

import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:image_picker/image_picker.dart';

import '../../models/listing_model.dart';
import '../../services/api_service.dart';
import '../../services/location_service.dart';
import 'location_picker_screen.dart';

class EditHomeScreen extends StatefulWidget {
  final Listing listing;

  const EditHomeScreen({super.key, required this.listing});

  @override
  State<EditHomeScreen> createState() => _EditHomeScreenState();
}

class _EditHomeScreenState extends State<EditHomeScreen> {
  late TextEditingController titleController;
  late TextEditingController descriptionController;
  late TextEditingController locationController;
  late TextEditingController priceController;
  late TextEditingController capacityController;

  late TextEditingController roomCountController;
  late TextEditingController bedCountController;
  late TextEditingController bathroomCountController;

  List<File> _selectedImages = [];
  File? _selectedImage;
  bool _isLoading = false;
  String? _error;
  String? _success;
  List<String> _selectedAmenities = [];
  
  // İzin alanları
  bool _allowEvents = false;
  bool _allowSmoking = false;
  bool _allowCommercialPhoto = false;
  int _maxGuests = 1;
  
  // Konum seçimi için yeni alanlar
  double? _selectedLatitude;
  double? _selectedLongitude;
  bool _isLocationLoading = false;
  String? _locationError;
  
  final List<String> _availableAmenities = [
    'WiFi',
    'Klima',
    'Mutfak',
    'Çamaşır Makinesi',
    'Bulaşık Makinesi',
    'TV',
    'Parking',
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
    titleController = TextEditingController(text: widget.listing.title);
    descriptionController = TextEditingController(
      text: widget.listing.description ?? '',
    );
    locationController = TextEditingController(
      text: widget.listing.location ?? '',
    );
    priceController = TextEditingController(
      text: widget.listing.price.toString(),
    );
    capacityController = TextEditingController(
      text: widget.listing.capacity?.toString() ?? '',
    );

    roomCountController = TextEditingController(
      text: widget.listing.roomCount?.toString() ?? '',
    );
    bedCountController = TextEditingController(
      text: widget.listing.bedCount?.toString() ?? '',
    );
    bathroomCountController = TextEditingController(
      text: widget.listing.bathroomCount?.toString() ?? '',
    );
    _selectedAmenities =
        widget.listing.amenities != null
            ? widget.listing.amenities!.map((amenity) => amenity.name).toList()
            : [];
    
    // İzin alanlarını mevcut değerlerle yükle
    _allowEvents = widget.listing.allowEvents == 1;
    _allowSmoking = widget.listing.allowSmoking == 1;
    _allowCommercialPhoto = widget.listing.allowCommercialPhoto == 1;
    _maxGuests = widget.listing.maxGuests ?? widget.listing.capacity ?? 1;
    
    // Mevcut koordinatları yükle
    _selectedLatitude = widget.listing.lat;
    _selectedLongitude = widget.listing.lng;
  }

  @override
  void dispose() {
    titleController.dispose();
    descriptionController.dispose();
    locationController.dispose();
    priceController.dispose();
    capacityController.dispose();

    roomCountController.dispose();
    bedCountController.dispose();
    bathroomCountController.dispose();
    super.dispose();
  }

  // 1. Fotoğraf seçme fonksiyonu
  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(
      source: ImageSource.gallery,
    );
    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
      print(
        'DEBUG: Fotoğraf seçildi:  [32m [1m [4m${_selectedImage!.path} [0m',
      );
    } else {
      print('DEBUG: Fotoğraf seçilmedi.');
    }
  }

  void _removeImage(int index) {
    setState(() {
      _selectedImages.removeAt(index);
    });
  }

  void _toggleAmenity(String amenity) {
    setState(() {
      if (_selectedAmenities.contains(amenity)) {
        _selectedAmenities.remove(amenity);
      } else {
        _selectedAmenities.add(amenity);
      }
    });
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
        _selectedLatitude!,
        _selectedLongitude!,
      );

      if (placemarks.isNotEmpty) {
        final placemark = placemarks.first;
        final address = [
          placemark.locality,
          placemark.subLocality,
          placemark.thoroughfare,
        ].where((e) => e != null && e.isNotEmpty).join(', ');

        setState(() {
          locationController.text = address;
        });
      }
    } catch (e) {
      print('Adres alınamadı: $e');
    }
  }

  // Adresten koordinat al
  Future<void> _getCoordinatesFromAddress() async {
    if (locationController.text.trim().isEmpty) return;

    setState(() {
      _isLocationLoading = true;
      _locationError = null;
    });

    try {
      List<Location> locations = await locationFromAddress(
        locationController.text.trim(),
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
                  locationController.text = address;
                });
              },
            ),
      ),
    );
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
    if (titleController.text.trim().isEmpty) {
      setState(() {
        _error = 'Başlık alanı zorunludur';
      });
      return;
    }

    if (priceController.text.trim().isEmpty) {
      setState(() {
        _error = 'Fiyat alanı zorunludur';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
      _success = null;
    });

    try {
      final price = double.tryParse(priceController.text.trim());
      final capacity = int.tryParse(capacityController.text.trim());

      if (price == null) {
        throw Exception('Geçerli bir fiyat giriniz');
      }

      // DEBUG: Seçilen fotoğrafı yazdır
      print(
        'Güncelleme için seçilen fotoğraf:  [32m [1m [4m${_selectedImage?.path} [0m',
      );
      if (_selectedImage == null) {
        print(
          'DEBUG: Fotoğraf seçilmedi, sadece metin alanları güncelleniyor.',
        );
      } else {
        print('DEBUG: Fotoğraf updateListing fonksiyonuna gönderiliyor.');
      }

      // Koordinatları belirle
      double? lat = _selectedLatitude;
      double? lng = _selectedLongitude;

      // Eğer koordinat seçilmemişse adresten al
      if (lat == null || lng == null) {
        try {
          List<Location> locations = await locationFromAddress(
            locationController.text.trim(),
          );
          if (locations.isNotEmpty) {
            lat = locations.first.latitude;
            lng = locations.first.longitude;
          }
        } catch (e) {
          print("Konumdan koordinatlar alınamadı: $e");
        }
      }

      await ApiService().updateListing(
        listingId: widget.listing.id,
        title: titleController.text.trim(),
        description:
            descriptionController.text.trim().isEmpty
                ? null
                : descriptionController.text.trim(),
        location:
            locationController.text.trim().isEmpty
                ? null
                : locationController.text.trim(),
        lat: lat,
        lng: lng,
        price: price,
        capacity: capacity,
        homeRules: _buildHomeRulesText(),
        amenities: _selectedAmenities.isNotEmpty ? _selectedAmenities : null,
        photo: _selectedImage,
        roomCount: int.tryParse(roomCountController.text.trim()),
        bedCount: int.tryParse(bedCountController.text.trim()),
        bathroomCount: int.tryParse(bathroomCountController.text.trim()),
        allowEvents: _allowEvents,
        allowSmoking: _allowSmoking,
        allowCommercialPhoto: _allowCommercialPhoto,
        maxGuests: _maxGuests,
      );

      setState(() {
        _success = 'İlan başarıyla güncellendi!';
      });

      if (context.mounted) {
        // Başarı mesajını göster ve geri dön
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_success!),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
        Navigator.pop(context, true);
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

  // Android emülatörü için bilgisayarın localhost'una erişim:
  final String baseUrl =
      "http://10.0.2.2:8000"; // Gerçek cihazda test için bilgisayarınızın IP adresini kullanın
  String getListingImageUrl(String? path) {
    if (path == null || path.isEmpty) {
      return "assets/images/user.jpg"; // assets klasörünüzdeki varsayılan görsel
    }
    if (path.startsWith('/uploads')) {
      return baseUrl + path;
    }
    return path;
  }

  Widget buildListingImage(String imageUrl) {
    if (imageUrl.startsWith('assets/')) {
      return Image.asset(imageUrl, width: 100, height: 100, fit: BoxFit.cover);
    } else {
      return Image.network(
        imageUrl,
        width: 100,
        height: 100,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            width: 100,
            height: 100,
            color: Colors.grey[200],
            child: const Icon(
              Icons.home_outlined,
              size: 40,
              color: Colors.grey,
            ),
          );
        },
      );
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
          'İlanı Düzenle',
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
                                Icons.edit,
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
                                    'İlanı Düzenle',
                                    style: TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black,
                                    ),
                                  ),
                                  SizedBox(height: 4),
                                  Text(
                                    'Bilgilerinizi güncelleyin',
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
                              Icon(Icons.error_outline, color: Colors.red[600]),
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
                                'Fotoğraflar',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                              ),
                              const SizedBox(height: 12),

                              // Current images
                              if (widget.listing.imageUrls != null &&
                                  widget.listing.imageUrls!.isNotEmpty) ...[
                                const Text(
                                  'Mevcut Fotoğraflar:',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.black,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                SizedBox(
                                  height: 100,
                                  child: ListView.builder(
                                    scrollDirection: Axis.horizontal,
                                    itemCount: widget.listing.imageUrls!.length,
                                    itemBuilder: (context, index) {
                                      return Container(
                                        margin: const EdgeInsets.only(right: 8),
                                        width: 100,
                                        height: 100,
                                        child: buildListingImage(
                                          getListingImageUrl(
                                            widget.listing.imageUrls![index],
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                                const SizedBox(height: 16),
                              ],

                              // New images
                              if (_selectedImages.isNotEmpty) ...[
                                const Text(
                                  'Yeni Fotoğraflar:',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.black,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                SizedBox(
                                  height: 100,
                                  child: ListView.builder(
                                    scrollDirection: Axis.horizontal,
                                    itemCount: _selectedImages.length,
                                    itemBuilder: (context, index) {
                                      return Stack(
                                        children: [
                                          Container(
                                            margin: const EdgeInsets.only(
                                              right: 8,
                                            ),
                                            width: 100,
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                              image: DecorationImage(
                                                image: FileImage(
                                                  _selectedImages[index],
                                                ),
                                                fit: BoxFit.cover,
                                              ),
                                            ),
                                          ),
                                          Positioned(
                                            top: 4,
                                            right: 12,
                                            child: GestureDetector(
                                              onTap: () => _removeImage(index),
                                              child: Container(
                                                padding: const EdgeInsets.all(
                                                  4,
                                                ),
                                                decoration: const BoxDecoration(
                                                  color: Colors.red,
                                                  shape: BoxShape.circle,
                                                ),
                                                child: const Icon(
                                                  Icons.close,
                                                  color: Colors.white,
                                                  size: 16,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      );
                                    },
                                  ),
                                ),
                                const SizedBox(height: 16),
                              ],

                              // Add images button
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

                              // Form Fields
                              _buildTextField(
                                controller: titleController,
                                label: 'Başlık *',
                                hint: 'İlan başlığı',
                              ),
                              const SizedBox(height: 16),

                              _buildTextField(
                                controller: descriptionController,
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
                                controller: locationController,
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
                                          'Koordinatlar alındı: ${_selectedLatitude!.toStringAsFixed(6)}, ${_selectedLongitude!.toStringAsFixed(6)}',
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
                                          _locationError!,
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
                                controller: priceController,
                                label: 'Fiyat (₺/gece) *',
                                hint: '0',
                                keyboardType: TextInputType.number,
                              ),
                              const SizedBox(height: 16),

                              _buildTextField(
                                controller: capacityController,
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
                              const SizedBox(height: 16),

                              // Oda, yatak, banyo alanları
                              _buildTextField(
                                controller: roomCountController,
                                label: 'Oda Sayısı',
                                hint: 'Oda sayısı',
                                keyboardType: TextInputType.number,
                              ),
                              const SizedBox(height: 16),
                              _buildTextField(
                                controller: bedCountController,
                                label: 'Yatak Sayısı',
                                hint: 'Yatak sayısı',
                                keyboardType: TextInputType.number,
                              ),
                              const SizedBox(height: 16),
                              _buildTextField(
                                controller: bathroomCountController,
                                label: 'Banyo Sayısı',
                                hint: 'Banyo sayısı',
                                keyboardType: TextInputType.number,
                              ),
                              const SizedBox(height: 16),

                              // Olanaklar (Amenities) Bölümü
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
                                          style: const TextStyle(
                                            color: Colors.black,
                                          ),
                                        ),
                                        selected: isSelected,
                                        onSelected:
                                            (selected) =>
                                                _toggleAmenity(amenity),
                                        selectedColor: Colors.black.withOpacity(
                                          0.1,
                                        ),
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
                                    'Değişiklikleri Kaydet',
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
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    TextInputType? keyboardType,
    int maxLines = 1,
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
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          maxLines: maxLines,
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
