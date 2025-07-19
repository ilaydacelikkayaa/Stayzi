import 'package:flutter/material.dart';
import 'package:stayzi_ui/models/listing_model.dart';
import 'package:stayzi_ui/models/user_model.dart';
import 'package:stayzi_ui/screens/detail/widgets/ev_sahibi_bilgisi.dart';
import 'package:stayzi_ui/screens/detail/widgets/ilan_baslik.dart';
import 'package:stayzi_ui/screens/detail/widgets/image_gallery.dart';
import 'package:stayzi_ui/screens/detail/widgets/konum_harita.dart';
import 'package:stayzi_ui/screens/detail/widgets/mekan_aciklamasi.dart';
import 'package:stayzi_ui/screens/detail/widgets/olanaklar_ve_kurallar.dart';
import 'package:stayzi_ui/screens/detail/widgets/takvim_bilgisi.dart';
import 'package:stayzi_ui/screens/detail/widgets/yorumlar_degerlendirmeler.dart';
import 'package:stayzi_ui/services/api_service.dart';

class HomeDetailScreen extends StatefulWidget {
  final int listingId;
  final ScrollController? scrollController;
  
  const HomeDetailScreen({
    super.key,
    required this.listingId,
    this.scrollController,
  });

  @override
  State<HomeDetailScreen> createState() => _HomeDetailScreenState();
}

class _HomeDetailScreenState extends State<HomeDetailScreen> {
  Listing? detailedListing;
  User? currentUser;
  bool isLoading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    _loadDetailedData();
  }



  Future<void> _loadDetailedData() async {
    setState(() {
      isLoading = true;
      error = null;
    });

    try {
      // Listing detaylarını yükle
      detailedListing = await ApiService().getListingById(widget.listingId);

      // Giriş yapmış kullanıcı bilgilerini al (ev sahibi)
      currentUser = await ApiService().getCurrentUser();

      setState(() {
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        error = e.toString();
        isLoading = false;
      });
      print('Detay yükleme hatası: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
            const SizedBox(height: 16),
            Text(
              'Veri yüklenirken hata: $error',
              style: const TextStyle(color: Colors.red),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadDetailedData,
              child: const Text('Tekrar Dene'),
            ),
          ],
        ),
      );
    }

    if (detailedListing == null) {
      return const Center(child: Text('İlan bulunamadı'));
    }

    // Listing verilerini Map'e çevir
    final listingData = _listingToMap(detailedListing!);

    // Ev sahibi bilgilerini giriş yapmış kullanıcıdan al
    if (currentUser != null) {
      listingData['host_name'] = '${currentUser!.name} ${currentUser!.surname}';
      listingData['host_user'] = {
        'name': currentUser!.name,
        'surname': currentUser!.surname,
        'email': currentUser!.email,
        'phone': currentUser!.phone,
        'profile_image': currentUser!.profileImage,
      };
    }

    // Fotoğraf galerisi için image list
    List<String> imageList = [];
    try {
      final galeri = listingData['galeri'] as List<dynamic>?;
      if (galeri != null) {
        imageList =
            galeri
                .where((url) => url != null)
                .map((url) => url.toString())
                .toList();
      } else if (listingData['foto'] != null) {
        imageList = [listingData['foto']];
      }
    } catch (e) {
      imageList = listingData['foto'] != null ? [listingData['foto']] : [];
    }

    return ListView(
      controller: widget.scrollController,
      padding: EdgeInsets.zero,
      children: [
        // Loading indicator
        if (isLoading)
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Center(child: CircularProgressIndicator()),
          ),

        // Error message
        if (error != null)
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Center(
              child: Text(
                'Veri yüklenirken hata: $error',
                style: const TextStyle(color: Colors.red),
              ),
            ),
          ),

        // Fotoğraf Galerisi
        ListingImageGallery(imageList: imageList),
        if (imageList.isEmpty)
          const Center(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                'Bu ilana ait fotoğraf bulunmamaktadır.',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
            ),
          ),
        IlanBaslik(listing: listingData),
        Divider(thickness: 1, color: Colors.grey, endIndent: 20, indent: 20),
        EvSahibiBilgisi(listing: listingData),
        Divider(thickness: 1, color: Colors.grey, endIndent: 20, indent: 20),
        MekanAciklamasi(
          description: listingData['description']?.toString() ?? '',
        ),
        Divider(thickness: 1, color: Colors.grey, endIndent: 20, indent: 20),
        KonumBilgisi(
          latitude: (listingData['latitude'] as num?)?.toDouble() ?? 0.0,
          longitude: (listingData['longitude'] as num?)?.toDouble() ?? 0.0,
        ),
        Divider(thickness: 1, color: Colors.grey, endIndent: 20, indent: 20),
        TakvimBilgisi(),
        Divider(thickness: 1, color: Colors.grey, endIndent: 20, indent: 20),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            "Yorumlar ve Değerlendirmeler",
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
        ),
        Padding(
          padding: EdgeInsets.all(20),
          child: Yorumlar(listingId: listingData['id']),
        ),
        Divider(thickness: 1, color: Colors.grey, endIndent: 20, indent: 20),
        OlanaklarVeKurallar(listing: listingData),
        const SizedBox(height: 100),
      ],
    );
  }

  Map<String, dynamic> _listingToMap(Listing listing) {
    final map = {
      'id': listing.id,
      'title': listing.title,
      'location': listing.location,
      'price': listing.price,
      'description': listing.description,
      'image_urls': listing.imageUrls,
      'average_rating': listing.averageRating,
      'host_name': listing.userId?.toString() ?? '',
      'latitude': listing.lat,
      'longitude': listing.lng,
      'capacity': listing.capacity,
      'galeri': listing.imageUrls,
      'amenities': listing.amenities,
      'home_rules': listing.homeRules,
      'home_type': listing.homeType,
      'room_count': listing.roomCount,
      'bed_count': listing.bedCount,
      'bathroom_count': listing.bathroomCount,
      'allow_events': listing.allowEvents,
      'allow_smoking': listing.allowSmoking,
      'allow_commercial_photo': listing.allowCommercialPhoto,
      'max_guests': listing.maxGuests,
    };

    return map;
  }
}
