import 'package:flutter/material.dart';
import 'package:stayzi_ui/screens/favorite/favorite_list_detail_screen.dart';
import 'package:stayzi_ui/services/api_service.dart';
import 'package:stayzi_ui/services/storage_service.dart';

class FavoriteScreen extends StatefulWidget {
  const FavoriteScreen({super.key});

  @override
  State<FavoriteScreen> createState() => _FavoriteScreenState();
}

class _FavoriteScreenState extends State<FavoriteScreen> {
  List<Map<String, dynamic>> favoriListeleri = [];
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _loadFavorites();
  }

  Future<void> _loadFavorites() async {
    try {
      setState(() {
        isLoading = true;
        errorMessage = null;
      });

      print("🔄 Favoriler yükleniyor...");

      // Token'ı al
      final token = await StorageService().getAccessToken();
      print("🔐 Token alındı: ${token != null ? 'VAR' : 'YOK'}");
      if (token != null) {
        print("🔐 Token başlangıcı: ${token.substring(0, 20)}...");
        ApiService().setAuthToken(token);
      }

      print("📡 Backend'e istek gönderiliyor...");
      // Backend'den favorileri al
      final favorites = await ApiService().getMyFavorites();
      print("✅ Favoriler alındı: ${favorites.length} adet");

      // Favorileri liste adına göre grupla
      final Map<String, List<Map<String, dynamic>>> groupedFavorites = {};

      for (final favorite in favorites) {
        final listName = favorite.listName ?? 'Genel Favoriler';
        print(
          "📋 Favori: ID=${favorite.id}, ListingID=${favorite.listingId}, ListName=$listName",
        );

        if (!groupedFavorites.containsKey(listName)) {
          groupedFavorites[listName] = [];
        }

        // Favori ilanının detaylarını al
        try {
          print("📄 İlan detayı alınıyor: ID=${favorite.listingId}");
          final listing = await ApiService().getListingById(favorite.listingId);
          print("✅ İlan detayı alındı: ${listing.title}");
          print("📸 İlan fotoğrafları: ${listing.imageUrls}");
          print("🏠 Ev sahibi: ${listing.user}");
          print("🔧 Olanaklar: ${listing.amenities}");
          print("📋 Ev kuralları: ${listing.homeRules}");

          String? fotoUrl;
          if (listing.imageUrls?.isNotEmpty == true) {
            fotoUrl = listing.imageUrls!.first;
            print("📸 Seçilen fotoğraf: $fotoUrl");
          }

          groupedFavorites[listName]!.add({
            'id': listing.id,
            'title': listing.title, // ✅ Başlık eklendi
            'baslik': listing.title,
            'description': listing.description, // ✅ Açıklama eklendi
            'foto': fotoUrl,
            'image_urls': listing.imageUrls, // ✅ Tüm fotoğraflar eklendi
            'fiyat': '₺${listing.price}',
            'price': listing.price, // ✅ Fiyat eklendi
            'konum': listing.location ?? 'Konum belirtilmemiş',
            'location': listing.location, // ✅ Konum eklendi
            'latitude': listing.lat, // ✅ Enlem eklendi
            'longitude': listing.lng, // ✅ Boylam eklendi
            'puan': listing.averageRating,
            'average_rating': listing.averageRating, // ✅ Puan eklendi
            'host': listing.user?.toJson(), // ✅ Ev sahibi bilgisi eklendi
            'amenities':
                listing.amenities
                    ?.map((a) => a.toJson())
                    .toList(), // ✅ Olanaklar eklendi
            'home_rules': listing.homeRules, // ✅ Ev kuralları eklendi
            'capacity': listing.capacity, // ✅ Kapasite eklendi
            'home_type': listing.homeType, // ✅ Ev tipi eklendi
            'host_languages':
                listing.hostLanguages, // ✅ Ev sahibi dilleri eklendi
            'allow_events': listing.allowEvents, // ✅ Etkinlik izni eklendi
            'allow_smoking': listing.allowSmoking, // ✅ Sigara izni eklendi
            'allow_commercial_photo':
                listing.allowCommercialPhoto, // ✅ Ticari fotoğraf izni eklendi
            'max_guests': listing.maxGuests, // ✅ Maksimum misafir eklendi
          });
        } catch (e) {
          print('❌ İlan detayı alınamadı: $e');
          // İlan detayı alınamazsa basit bir obje oluştur
          groupedFavorites[listName]!.add({
            'id': favorite.listingId,
            'title': 'İlan #${favorite.listingId}',
            'baslik': 'İlan #${favorite.listingId}',
            'description': 'İlan detayı alınamadı',
            'foto': null,
            'fiyat': 'Fiyat belirtilmemiş',
            'price': 0.0,
            'konum': 'Konum belirtilmemiş',
            'location': 'Konum belirtilmemiş',
            'puan': 0.0,
            'average_rating': 0.0,
          });
        }
      }

      // Gruplandırılmış favorileri listeye çevir
      final List<Map<String, dynamic>> result = [];
      groupedFavorites.forEach((listName, ilanlar) {
        print("📁 Liste: $listName (${ilanlar.length} ilan)");
        for (int i = 0; i < ilanlar.length; i++) {
          print(
            "  📋 İlan $i: ${ilanlar[i]['baslik']} - Fotoğraf: ${ilanlar[i]['foto']}",
          );
        }
        result.add({'listeAdi': listName, 'ilanlar': ilanlar});
      });

      print("🎉 Favori listeleri hazırlandı: ${result.length} liste");

      setState(() {
        favoriListeleri = result;
        isLoading = false;
      });
    } catch (e) {
      print('❌ Favoriler yüklenirken hata: $e');
      setState(() {
        errorMessage = 'Favoriler yüklenirken hata oluştu: $e';
        isLoading = false;
      });
    }
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
                        color: Colors.red.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.favorite,
                        color: Colors.red,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 16),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Favoriler',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Tüm favori listelerin burada',
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
                isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : errorMessage != null
                    ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            errorMessage!,
                            style: const TextStyle(color: Colors.red),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: _loadFavorites,
                            child: const Text('Tekrar Dene'),
                          ),
                        ],
                      ),
                    )
                    : favoriListeleri.isEmpty
                    ? const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.favorite_border,
                            size: 64,
                            color: Colors.grey,
                          ),
                          SizedBox(height: 16),
                          Text(
                            'Henüz favori listeniz yok',
                            style: TextStyle(fontSize: 18, color: Colors.grey),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'İlanları favorilere ekleyerek\nlisteler oluşturabilirsiniz',
                            style: TextStyle(fontSize: 14, color: Colors.grey),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    )
                    : Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: GridView.builder(
                        itemCount: favoriListeleri.length,
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              crossAxisSpacing: 8,
                              mainAxisSpacing: 8,
                              childAspectRatio: 1, // Kare yapı
                            ),
                        itemBuilder: (context, index) {
                          final liste = favoriListeleri[index];
                          final ilanlar = List<Map<String, dynamic>>.from(
                            liste['ilanlar'],
                          );
                          final gosterilecekResimler =
                              ilanlar.take(4).toList(); // en fazla 4 resim al

                          print(
                            "🎨 Liste $index (${liste['listeAdi']}) için ${gosterilecekResimler.length} fotoğraf hazırlanıyor",
                          );
                          for (
                            int i = 0;
                            i < gosterilecekResimler.length;
                            i++
                          ) {
                            print(
                              "  🖼️ Fotoğraf $i: ${gosterilecekResimler[i]['foto']}",
                            );
                          }

                          return GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder:
                                      (_) => FavoriteListDetailScreen(
                                        listeAdi: liste['listeAdi'],
                                        ilanlar: ilanlar,
                                      ),
                                ),
                              );
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: const [
                                  BoxShadow(
                                    color: Colors.black12,
                                    blurRadius: 6,
                                    offset: Offset(2, 2),
                                  ),
                                ],
                              ),
                              child: Column(
                                children: [
                                  // Fotoğraf kolajı
                                  SizedBox(
                                    height: 120,
                                    width: double.infinity,
                                    child: ClipRRect(
                                      borderRadius: const BorderRadius.vertical(
                                        top: Radius.circular(22),
                                      ),
                                      child: Table(
                                        defaultColumnWidth:
                                            const FlexColumnWidth(1),
                                        children: [
                                          TableRow(
                                            children: [
                                              _buildCollageImage(
                                                gosterilecekResimler,
                                                0,
                                                topLeft: true,
                                              ),
                                              _buildCollageImage(
                                                gosterilecekResimler,
                                                1,
                                                topRight: true,
                                              ),
                                            ],
                                          ),
                                          TableRow(
                                            children: [
                                              _buildCollageImage(
                                                gosterilecekResimler,
                                                2,
                                                bottomLeft: true,
                                              ),
                                              _buildCollageImage(
                                                gosterilecekResimler,
                                                3,
                                                bottomRight: true,
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(
                                      top: 10,
                                      left: 8,
                                      right: 8,
                                      bottom: 4,
                                    ),
                                    child: Column(
                                      children: [
                                        Text(
                                          liste['listeAdi'],
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 17,
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                        const SizedBox(height: 4),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 8,
                                            vertical: 2,
                                          ),
                                          decoration: BoxDecoration(
                                            color: Colors.grey[200],
                                            borderRadius: BorderRadius.circular(
                                              10,
                                            ),
                                          ),
                                          child: Text(
                                            '${ilanlar.length} ilan',
                                            style: const TextStyle(
                                              fontSize: 12,
                                              color: Colors.black54,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
          ),
        ],
      ),
    );
  }
}

// Kolaj için yardımcı fonksiyon
Widget _buildCollageImage(
  List<Map<String, dynamic>> resimler,
  int index, {
  bool topLeft = false,
  bool topRight = false,
  bool bottomLeft = false,
  bool bottomRight = false,
}) {
  BorderRadius radius = BorderRadius.only(
    topLeft: topLeft ? const Radius.circular(22) : Radius.zero,
    topRight: topRight ? const Radius.circular(22) : Radius.zero,
    bottomLeft: bottomLeft ? const Radius.circular(22) : Radius.zero,
    bottomRight: bottomRight ? const Radius.circular(22) : Radius.zero,
  );
  
  if (index < resimler.length) {
    final foto = resimler[index]['foto'];
    print("🖼️ Fotoğraf $index: $foto");

    String? imageUrl;
    if (foto != null && foto.toString().isNotEmpty) {
      if (foto.toString().startsWith('http')) {
        // Tam URL
        imageUrl = foto.toString();
      } else if (foto.toString().startsWith('/uploads')) {
        // Backend URL'i
        imageUrl = 'http://10.0.2.2:8000${foto.toString()}';
      } else {
        // Diğer durumlar
        imageUrl = foto.toString();
      }
    }

    print("🖼️ İşlenmiş URL $index: $imageUrl");
    
    return ClipRRect(
      borderRadius: radius,
      child:
          imageUrl != null
              ? Image.network(
                imageUrl,
                fit: BoxFit.cover,
                height: 60,
                width: 60,
                errorBuilder: (context, error, stackTrace) {
                  print("❌ Fotoğraf yüklenemedi $index: $error");
                  return Container(
                    color: Colors.grey[300],
                    height: 60,
                    width: 60,
                    child: const Icon(Icons.home_outlined, color: Colors.grey),
                  );
                },
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Container(
                    color: Colors.grey[200],
                    height: 60,
                    width: 60,
                    child: const Center(
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  );
                },
              )
              : Container(
                color: Colors.grey[300],
                height: 60,
                width: 60,
                child: const Icon(Icons.home_outlined, color: Colors.grey),
              ),
    );
  } else {
    return Container(color: Colors.grey[300]);
  }
}
