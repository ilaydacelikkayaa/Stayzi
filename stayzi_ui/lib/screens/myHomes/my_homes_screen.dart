import 'package:flutter/material.dart';
import 'package:stayzi_ui/services/api_constants.dart';

import '../../models/listing_model.dart';
import '../../services/api_service.dart';
import '../../services/storage_service.dart';
import 'add_home_screen.dart';
import 'edit_home_screen.dart';
import 'home_detail_screen.dart';

class MyHomesScreen extends StatefulWidget {
  const MyHomesScreen({super.key});

  @override
  State<MyHomesScreen> createState() => _MyHomesScreenState();
}

class _MyHomesScreenState extends State<MyHomesScreen> {
  List<Listing> _listings = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadMyListings();
  }

  Future<void> _loadMyListings() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      // Token'ı StorageService'den al ve API service'e set et
      final token = await StorageService().getAccessToken();
      if (token == null) {
        setState(() {
          _error = 'Lütfen önce giriş yapın';
          _isLoading = false;
        });
        return;
      }

      ApiService().setAuthToken(token);
      final listings = await ApiService().getMyListings();

      if (!mounted) return;
      setState(() {
        _listings = listings;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = 'İlanlarınız yüklenemedi: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _deleteListing(Listing listing) async {
    try {
      await ApiService().deleteListing(listing.id);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('İlan başarıyla silindi'),
          backgroundColor: Colors.green,
        ),
      );
      _loadMyListings(); // Refresh the list
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('İlan silinemedi: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showDeleteDialog(Listing listing) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: const Text(
              'İlanı Sil',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            content: Text(
              '"${listing.title}" ilanını silmek istediğinize emin misiniz?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('İptal'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  _deleteListing(listing);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Sil'),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.home,
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
                            'İlanlarım',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Tüm ilanların burada',
                            style: TextStyle(fontSize: 14, color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child:
                _isLoading
                    ? const Center(
                      child: CircularProgressIndicator(color: Colors.black),
                    )
                    : _error != null
                    ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.error_outline,
                            size: 64,
                            color: Colors.grey[400],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            _error!,
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey[600],
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: _loadMyListings,
                            child: const Text('Tekrar Dene'),
                          ),
                        ],
                      ),
                    )
                    : _listings.isEmpty
                    ? _buildEmptyState()
                    : _buildListingsList(),
          ),
        ],
      ),
      floatingActionButton:
          _error == null || !_error!.contains('giriş yapın')
              ? FloatingActionButton.extended(
                onPressed: () async {
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const AddHomeScreen(),
                    ),
                  );
                  if (!mounted) return;
                  if (result == true) {
                    _loadMyListings();
                  }
                },
                backgroundColor: Colors.black,
                foregroundColor: Colors.white,
                icon: const Icon(Icons.add),
                label: const Text('Yeni İlan'),
              )
              : null,
    );
  }

  Widget _buildEmptyState() {
    // Eğer hata varsa ve "giriş yapın" mesajıysa, farklı bir UI göster
    if (_error != null && _error!.contains('giriş yapın')) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(50),
              ),
              child: Icon(Icons.login, size: 64, color: Colors.grey[600]),
            ),
            const SizedBox(height: 24),
            const Text(
              'Giriş Yapın',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'İlanlarınızı görmek için lütfen giriş yapın',
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () {
                // Ana sayfaya yönlendir veya giriş sayfasına
                Navigator.pop(context);
              },
              icon: const Icon(Icons.login),
              label: const Text('Giriş Yap'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
            ),
          ],
        ),
      );
    }

    // Normal boş durum
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(50),
            ),
            child: Icon(Icons.home_outlined, size: 64, color: Colors.grey[600]),
          ),
          const SizedBox(height: 24),
          const Text(
            'Henüz İlanınız Yok',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'İlk ilanınızı ekleyerek başlayın',
            style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AddHomeScreen()),
              );
              if (!mounted) return;
              if (result == true) {
                _loadMyListings();
              }
            },
            icon: const Icon(Icons.add),
            label: const Text('İlk İlanınızı Ekleyin'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.black,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildListingsList() {
    return RefreshIndicator(
      onRefresh: _loadMyListings,
      color: Colors.black,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _listings.length,
        itemBuilder: (context, index) {
          final listing = _listings[index];
          return _buildListingCard(listing);
        },
      ),
    );
  }

  Widget _buildListingCard(Listing listing) {
    final imageUrl =
        listing.imageUrls != null && listing.imageUrls!.isNotEmpty
            ? '${ApiConstants.baseUrl.replaceFirst(RegExp(r'/$'), '')}/${listing.imageUrls!.first.replaceFirst(RegExp(r'^/'), '')}'
            : 'https://placehold.co/300x200?text=Resim+';

    return Material(
      child: InkWell(
        onTap: () {
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
                        child: HomeDetailScreen(
                          listingId: listing.id,
                          scrollController: scrollController,
                        ),
                      ),
                ),
          );
        },
        child: Card(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(13),
          ),
          margin: const EdgeInsets.all(16),
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
                    child: PopupMenuButton<String>(
                      icon: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.more_vert,
                          color: Colors.black,
                          size: 20,
                        ),
                      ),
                      onSelected: (value) {
                        switch (value) {
                          case 'edit':
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (context) =>
                                        EditHomeScreen(listing: listing),
                              ),
                            ).then((result) {
                              if (result == true) {
                                _loadMyListings();
                              }
                            });
                            break;
                          case 'delete':
                            _showDeleteDialog(listing);
                            break;
                        }
                      },
                      itemBuilder:
                          (context) => [
                            const PopupMenuItem(
                              value: 'edit',
                              child: Row(
                                children: [
                                  Icon(Icons.edit, color: Colors.black),
                                  SizedBox(width: 8),
                                  Text('Düzenle'),
                                ],
                              ),
                            ),
                            const PopupMenuItem(
                              value: 'delete',
                              child: Row(
                                children: [
                                  Icon(Icons.delete, color: Colors.red),
                                  SizedBox(width: 8),
                                  Text('Sil'),
                                ],
                              ),
                            ),
                          ],
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
                      listing.location ?? 'Konum Belirtilmemiş',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      listing.title,
                      style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '₺${listing.price.toStringAsFixed(0)}/gece',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Colors.black,
                          ),
                        ),
                        Row(
                          children: [
                            const Icon(
                              Icons.star,
                              size: 16,
                              color: Colors.amber,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              listing.averageRating.toStringAsFixed(1),
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    if (listing.capacity != null) ...[
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(
                            Icons.people_outline,
                            size: 16,
                            color: Colors.grey[600],
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${listing.capacity} misafir',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ],
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder:
                                      (context) =>
                                          EditHomeScreen(listing: listing),
                                ),
                              ).then((result) {
                                if (result == true) {
                                  _loadMyListings();
                                }
                              });
                            },
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.black,
                              side: const BorderSide(color: Colors.black),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 8),
                            ),
                            child: const Text(
                              'Düzenle',
                              style: TextStyle(fontSize: 12),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
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
                                          (context, scrollController) =>
                                              Container(
                                                decoration: const BoxDecoration(
                                                  color: Colors.white,
                                                  borderRadius:
                                                      BorderRadius.vertical(
                                                        top: Radius.circular(
                                                          24,
                                                        ),
                                                      ),
                                                ),
                                                child: HomeDetailScreen(
                                                  listingId: listing.id,
                                                  scrollController:
                                                      scrollController,
                                                ),
                                              ),
                                    ),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.black,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 8),
                            ),
                            child: const Text(
                              'Detaylar',
                              style: TextStyle(fontSize: 12),
                            ),
                          ),
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
    );
  }
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
    'amenities':
        listing.amenities != null
            ? listing.amenities!.map((amenity) => amenity.name).toList()
            : [],
    'home_rules': listing.homeRules,
    'home_type': listing.homeType,
    'room_count': listing.roomCount,
    'bed_count': listing.bedCount,
    'bathroom_count': listing.bathroomCount,
    'allow_events': listing.allowEvents,
    'allow_smoking': listing.allowSmoking,
    'allow_commercial_photo': listing.allowCommercialPhoto,
    'max_guests': listing.maxGuests,
    // Ev sahibi bilgisi olarak giriş yapan kullanıcıyı göster
    'is_my_listing': true,
  };
}

// Android emülatörü için bilgisayarın localhost'una erişim:
final String baseUrl = ApiConstants.baseUrl;
String getListingImageUrl(String? path) {
  if (path == null || path.isEmpty) return '';
  if (path.startsWith('/uploads')) {
    return baseUrl + path;
  }
  return path;
}

Widget buildListingImage(String imageUrl) {
  print('DEBUG: imageUrl = $imageUrl');
  if (imageUrl.startsWith('assets/')) {
    return Image.asset(
      imageUrl,
      height: 200,
      width: double.infinity,
      fit: BoxFit.cover,
    );
  } else {
    return Image.network(
      imageUrl,
      height: 200,
      width: double.infinity,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) {
        return Container(
          height: 200,
          width: double.infinity,
          color: Colors.grey[200],
          child: const Icon(Icons.home_outlined, size: 64, color: Colors.grey),
        );
      },
    );
  }
}
