import 'package:flutter/material.dart';
import 'package:stayzi_ui/models/listing_model.dart';
import 'package:stayzi_ui/models/user_model.dart';
import 'package:stayzi_ui/screens/favorite/widgets/ev_sahibi_bilgisi.dart';
import 'package:stayzi_ui/screens/favorite/widgets/ilan_baslik.dart';
import 'package:stayzi_ui/screens/favorite/widgets/image_gallery.dart';
import 'package:stayzi_ui/screens/favorite/widgets/konum_harita.dart';
import 'package:stayzi_ui/screens/favorite/widgets/mekan_aciklamasi.dart';
import 'package:stayzi_ui/screens/favorite/widgets/olanaklar_ve_kurallar.dart';
import 'package:stayzi_ui/screens/favorite/widgets/takvim_bilgisi.dart';
import 'package:stayzi_ui/screens/favorite/widgets/yorumlar_degerlendirmeler.dart';
import 'package:stayzi_ui/services/api_service.dart';

class FavoriteHomeDetailScreen extends StatefulWidget {
  final Map<String, dynamic> ilan;
  final ScrollController? scrollController;

  const FavoriteHomeDetailScreen({
    super.key,
    required this.ilan,
    this.scrollController,
  });

  @override
  State<FavoriteHomeDetailScreen> createState() =>
      _FavoriteHomeDetailScreenState();
}

class _FavoriteHomeDetailScreenState extends State<FavoriteHomeDetailScreen> {
  Listing? detailedListing;
  User? hostUser;
  bool isLoading = false;
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
      if (widget.ilan['id'] != null) {
        int? listingId;
        if (widget.ilan['id'] is int) {
          listingId = widget.ilan['id'] as int;
        } else {
          listingId = int.tryParse(widget.ilan['id'].toString());
        }
        if (listingId != null) {
          detailedListing = await ApiService().getListingById(listingId);
        }
      }

      // Ev sahibi bilgilerini yükle
      if (widget.ilan['host_name'] != null) {
        final hostId = int.tryParse(widget.ilan['host_name'].toString());
        if (hostId != null) {
          hostUser = await ApiService().getUserById(hostId);
        }
      }

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
    // Fotoğraf galerisi için image list
    List<String> imageList = [];
    try {
      final galeri = widget.ilan['galeri'] as List<dynamic>?;
      if (galeri != null) {
        imageList =
            galeri
                .where((url) => url != null)
                .map((url) => url.toString())
                .toList();
      } else if (widget.ilan['foto'] != null) {
        imageList = [widget.ilan['foto']];
      }
    } catch (e) {
      imageList = widget.ilan['foto'] != null ? [widget.ilan['foto']] : [];
    }

    // Detaylı listing verilerini kullan
    final listingData =
        detailedListing != null ? _listingToMap(detailedListing!) : widget.ilan;

    // Ev sahibi bilgilerini güncelle
    if (hostUser != null) {
      listingData['host_name'] = '${hostUser!.name} ${hostUser!.surname}';
      listingData['host_user'] = {
        'name': hostUser!.name,
        'surname': hostUser!.surname,
        'email': hostUser!.email,
        'phone': hostUser!.phone,
        'profile_image': hostUser!.profileImage,
      };
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
          locationName: listingData['location']?.toString(),
        ),
        Divider(thickness: 1, color: Colors.grey, endIndent: 20, indent: 20),
        TakvimBilgisi(),
        if (listingData['id'] != null && listingData['id'] is int) ...[
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
            child: Yorumlar(listingId: listingData['id'] as int),
          ),
          Divider(thickness: 1, color: Colors.grey, endIndent: 20, indent: 20),
        ],
        OlanaklarVeKurallar(listing: listingData),
        const SizedBox(height: 100),
      ],
    );
  }

  Map<String, dynamic> _listingToMap(Listing listing) {
    return {
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
    };
  }
}

// Bilgi kutusu widget'ı
class _InfoBox extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color? color;
  final Color? iconColor;
  const _InfoBox({
    required this.icon,
    required this.label,
    required this.value,
    this.color,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 100,
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(
        color: color ?? Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        children: [
          Icon(icon, color: iconColor ?? Colors.black, size: 22),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(fontSize: 12, color: Colors.black54),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
