import 'package:flutter/material.dart';
import 'package:stayzi_ui/models/favorite_model.dart';
import 'package:stayzi_ui/screens/detail/detail_scren.dart';
import 'package:stayzi_ui/screens/search/widgets/custom_search_appbar.dart';
import 'package:stayzi_ui/services/api_constants.dart';
import 'package:stayzi_ui/services/api_service.dart';
import 'package:stayzi_ui/services/storage_service.dart';

final String baseUrl = ApiConstants.baseUrl;
String getListingImageUrl(String? path) {
  if (path == null || path.isEmpty) return 'assets/images/user.jpg';
  if (path.startsWith('/uploads')) {
    return baseUrl + path;
  }
  return path;
}

class SearchScreen extends StatelessWidget {
  const SearchScreen({super.key});

  Future<List<dynamic>> fetchListings() async {
    try {
      // Token'ı StorageService'den al ve API service'e set et
      final token = await StorageService().getAccessToken();
      if (token != null) {
        ApiService().setAuthToken(token);
      }

      // ApiService kullanarak listings'i al
      final listings = await ApiService().getListings();

      // Listing objelerini Map'e çevir
      return listings.map((listing) => listing.toJson()).toList();
    } catch (e) {
      print('Error fetching listings: $e');
      throw Exception('Failed to load listings: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomSearchAppbar(),
      body: FutureBuilder<List<dynamic>>(
        future: fetchListings(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No listings available'));
          }

          return ListView.builder(
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              final listing = snapshot.data![index];
              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ListingDetailPage(listing: listing),
                    ),
                  );
                },
                child: TinyHomeCard(listing: listing),
              );
            },
          );
        },
      ),
    );
  }
}

class TinyHomeCard extends StatefulWidget {
  final Map<String, dynamic> listing;
  const TinyHomeCard({super.key, required this.listing});

  @override
  State<TinyHomeCard> createState() => _TinyHomeCardState();
}

class _TinyHomeCardState extends State<TinyHomeCard> {
  bool isFavorite = false;

  Future<void> _showListNameDialog() async {
    final TextEditingController listNameController = TextEditingController();

    final String? listName = await showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          elevation: 0,
          backgroundColor: Colors.transparent,
          child: Container(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.8,
            ),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Başlık ve ikon
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.favorite,
                      size: 40,
                      color: Colors.red.shade400,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Başlık
                  const Text(
                    'Favori Listesi Oluştur',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),

                  // Açıklama
                  const Text(
                    'Bu ilanı hangi isimle favori listenize eklemek istiyorsunuz?',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                      height: 1.4,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),

                  // Örnek liste isimleri
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          '💡 Örnek liste isimleri:',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Wrap(
                          spacing: 6,
                          runSpacing: 4,
                          children: [
                            _buildExampleChip('Yaz Tatili', listNameController),
                            _buildExampleChip(
                              'İş Seyahati',
                              listNameController,
                            ),
                            _buildExampleChip('Hafta Sonu', listNameController),
                            _buildExampleChip(
                              'Aile Ziyareti',
                              listNameController,
                            ),
                            _buildExampleChip(
                              'Romantik Kaçamak',
                              listNameController,
                            ),
                            _buildExampleChip(
                              'Arkadaş Buluşması',
                              listNameController,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Input alanı
                  TextField(
                    controller: listNameController,
                    decoration: InputDecoration(
                      labelText: 'Liste Adı',
                      hintText: 'Liste adınızı yazın...',
                      prefixIcon: const Icon(
                        Icons.edit,
                        color: Colors.grey,
                        size: 20,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: Colors.red.shade400,
                          width: 2,
                        ),
                      ),
                      filled: true,
                      fillColor: Colors.grey.shade50,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                    autofocus: true,
                    textCapitalization: TextCapitalization.words,
                  ),
                  const SizedBox(height: 16),

                  // Butonlar
                  Row(
                    children: [
                      Expanded(
                        child: TextButton(
                          onPressed: () => Navigator.of(context).pop(),
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                              side: BorderSide(color: Colors.grey.shade300),
                            ),
                          ),
                          child: const Text(
                            'İptal',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            if (listNameController.text.trim().isNotEmpty) {
                              Navigator.of(
                                context,
                              ).pop(listNameController.text.trim());
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red.shade400,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 0,
                          ),
                          child: const Text(
                            'Kaydet',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );

    if (listName != null) {
      await _addToFavorites(listName);
    }
  }

  Future<void> _addToFavorites(String listName) async {
    try {
      // Token'ı al
      final token = await StorageService().getAccessToken();
      if (token != null) {
        ApiService().setAuthToken(token);
      }

      // Favori oluştur
      final favoriteData = FavoriteCreate(
        listingId: widget.listing['id'],
        listName: listName,
      );

      await ApiService().createFavorite(favoriteData);

      setState(() {
        isFavorite = true;
      });

      // Başarı mesajı göster
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('İlan "$listName" listesine eklendi!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      print('❌ Favori ekleme hatası: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Favori eklenirken hata oluştu: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Widget _buildExampleChip(String text, TextEditingController controller) {
    return GestureDetector(
      onTap: () {
        controller.text = text;
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Text(
          text,
          style: const TextStyle(fontSize: 12, color: Colors.black87),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final listing = widget.listing;
    final rawUrl =
        (listing['image_urls'] as List<dynamic>).isNotEmpty
            ? listing['image_urls'][0]
            : null;

    final imageUrl =
        (rawUrl != null && rawUrl.startsWith('http'))
            ? rawUrl
            : '${ApiConstants.baseUrl}$rawUrl';

    return Material(
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ListingDetailPage(listing: listing),
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
                    child: Image.network(
                      getListingImageUrl(imageUrl),
                      height: 200,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Icon(
                          Icons.broken_image,
                          size: 100,
                          color: Colors.grey,
                        );
                      },
                    ),
                  ),
                  Positioned(
                    top: 12,
                    right: 12,
                    child: CircleAvatar(
                      backgroundColor: Colors.white,
                      child: IconButton(
                        onPressed: _showListNameDialog,
                        icon: Icon(
                          isFavorite ? Icons.favorite : Icons.favorite_border,
                        ),
                        color: Colors.black,
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
                      listing['location'] ?? 'Unknown Location',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(listing['title'] ?? ''),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '₺${listing['price']} night',
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
                            Text('${listing['average_rating'] ?? "0.0"}'),
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
