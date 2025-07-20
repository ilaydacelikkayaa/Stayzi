import 'package:flutter/material.dart';
import 'package:stayzi_ui/screens/favorite/favorite_home_detail.screen.dart';
import 'package:stayzi_ui/services/api_constants.dart';
import 'package:stayzi_ui/services/api_service.dart';

class FavoriteListDetailScreen extends StatefulWidget {
  final String listeAdi;
  final List<Map<String, dynamic>> ilanlar;

  const FavoriteListDetailScreen({
    super.key,
    required this.listeAdi,
    required this.ilanlar,
  });

  @override
  _FavoriteListDetailScreenState createState() =>
      _FavoriteListDetailScreenState();
}

class _FavoriteListDetailScreenState extends State<FavoriteListDetailScreen> {
  bool isEditing = false;

  void _showDeleteConfirmation() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Listeyi Sil'),
          content: const Text('Bu listeyi silmek istediğinizden emin misiniz?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Hayır'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Evet'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.listeAdi),
        actions: [
          if (!isEditing)
            TextButton.icon(
              onPressed: _showDeleteConfirmation,
              icon: const Icon(Icons.delete),
              label: const Text('Listeyi Sil'),
              style: TextButton.styleFrom(foregroundColor: Colors.black),
            ),
          if (isEditing)
            ElevatedButton(
              onPressed: () {
                setState(() {
                  isEditing = false;
                });
              },
              child: const Text('Bitti'),
            ),
        ],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemCount: widget.ilanlar.length,
        itemBuilder: (context, index) {
          final ilan = widget.ilanlar[index];
          final imageUrl = ilan['foto'] ?? 'assets/images/user.jpg';
          // Favori durumu için local state
          return _FavoriteCardWithHeart(ilan: ilan, imageUrl: imageUrl);
        },
      ),
    );
  }
}

final String baseUrl = ApiConstants.baseUrl;
String getListingImageUrl(String? path) {
  if (path == null || path.isEmpty) return 'assets/images/user.jpg';
  if (path.startsWith('/uploads')) {
    return baseUrl + path;
  }
  return path;
}

// Ayrı bir stateful widget ile kalp ikonunu tıklanabilir yapıyoruz
class _FavoriteCardWithHeart extends StatefulWidget {
  final Map<String, dynamic> ilan;
  final String imageUrl;
  const _FavoriteCardWithHeart({required this.ilan, required this.imageUrl});

  @override
  State<_FavoriteCardWithHeart> createState() => _FavoriteCardWithHeartState();
}

class _FavoriteCardWithHeartState extends State<_FavoriteCardWithHeart> {
  bool isFavorite = true;

  void _toggleFavorite() {
    setState(() {
      isFavorite = !isFavorite;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          isFavorite ? 'Favorilere eklendi' : 'Favorilerden çıkarıldı',
        ),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  Future<void> _showListingDetail() async {
    try {
      print("📄 İlan detayı alınıyor: ID=${widget.ilan['id']}");

      // Backend'den tam ilan detaylarını al (ev sahibi bilgisi dahil)
      final listing = await ApiService().getListingWithHostById(
        widget.ilan['id'],
      );
      print("✅ İlan detayı alındı: ${listing.title}");
      print("🏠 Ev sahibi: ${listing.user?.name} ${listing.user?.surname}");

      // İlan verisini Map'e çevir
      final fullListingData = {
        'id': listing.id,
        'title': listing.title,
        'description': listing.description,
        'price': listing.price,
        'location': listing.location,
        'lat': listing.lat,
        'lng': listing.lng,
        'image_urls': listing.imageUrls,
        'foto':
            listing.imageUrls?.isNotEmpty == true
                ? listing.imageUrls!.first
                : null,
        'average_rating': listing.averageRating,
        'host': listing.user?.toJson(), // ✅ Ev sahibi bilgisi eklendi
        'amenities': listing.amenities?.map((a) => a.toJson()).toList(),
        'home_rules': listing.homeRules,
        'capacity': listing.capacity,
        'home_type': listing.homeType,
        'host_languages': listing.hostLanguages,
        'allow_events': listing.allowEvents,
        'allow_smoking': listing.allowSmoking,
        'allow_commercial_photo': listing.allowCommercialPhoto,
        'max_guests': listing.maxGuests,
      };

      print("🏠 Tam ilan verisi hazırlandı:");
      print("  Başlık: ${fullListingData['title']}");
      print("  Açıklama: ${fullListingData['description']}");
      print("  Ev sahibi: ${fullListingData['host']}");
      print("  Olanaklar: ${fullListingData['amenities']}");
      print("  Ev kuralları: ${fullListingData['home_rules']}");

      if (!mounted) return;

      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder:
            (context) => DraggableScrollableSheet(
              initialChildSize: 0.92,
              minChildSize: 0.7,
              maxChildSize: 0.98,
              expand: false,
              builder:
                  (context, scrollController) => Container(
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(24),
                      ),
                    ),
                    child: FavoriteHomeDetailScreen(
                      ilan: fullListingData,
                      scrollController: scrollController,
                    ),
                  ),
            ),
      );
    } catch (e) {
      print("❌ İlan detayı alınamadı: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('İlan detayı yüklenirken hata oluştu: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final ilan = widget.ilan;
    final imageUrl = widget.imageUrl;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(13),
          onTap: _showListingDetail,
          child: Card(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(13),
            ),
            margin: EdgeInsets.zero,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Stack(
                  children: [
                    ClipRRect(
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(16),
                      ),
                      child: buildListingImage(getListingImageUrl(imageUrl)),
                    ),
                    Positioned(
                      top: 12,
                      right: 12,
                      child: CircleAvatar(
                        backgroundColor: Colors.white,
                        child: IconButton(
                          icon: Icon(
                            isFavorite ? Icons.favorite : Icons.favorite_border,
                            color: Colors.red,
                          ),
                          onPressed: _toggleFavorite,
                        ),
                      ),
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        ilan['konum'] ?? 'Unknown Location',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(ilan['baslik'] ?? ''),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            ilan['fiyat'] ?? '',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Row(
                            children: [
                              const Icon(
                                Icons.star,
                                size: 16,
                                color: Colors.black,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                ilan['puan'] != null
                                    ? ilan['puan'].toString()
                                    : '0.0',
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

Widget buildListingImage(String imageUrl) {
  if (imageUrl.startsWith('assets/')) {
    return Image.asset(
      imageUrl,
      height: 150,
      width: double.infinity,
      fit: BoxFit.cover,
    );
  } else {
    return Image.network(
      imageUrl,
      height: 150,
      width: double.infinity,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) {
        return Container(
          height: 150,
          width: double.infinity,
          color: Colors.grey[200],
          child: const Icon(Icons.home_outlined, size: 64, color: Colors.grey),
        );
      },
    );
  }
}
