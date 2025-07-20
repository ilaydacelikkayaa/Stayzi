import 'package:flutter/material.dart';
import 'package:stayzi_ui/screens/detail/widgets/ilan_baslik.dart';
import 'package:stayzi_ui/screens/detail/widgets/image_gallery.dart';
import 'package:stayzi_ui/screens/detail/widgets/konum_harita.dart';
import 'package:stayzi_ui/screens/detail/widgets/mekan_aciklamasi.dart';
import 'package:stayzi_ui/screens/detail/widgets/olanaklar_ve_kurallar.dart';
import 'package:stayzi_ui/screens/detail/widgets/takvim_bilgisi.dart';
import 'package:stayzi_ui/screens/detail/widgets/yorumlar_degerlendirmeler.dart';
import 'package:stayzi_ui/screens/favorite/widgets/ev_sahibi_bilgisi.dart';
import 'package:stayzi_ui/screens/onboard/widgets/basic_button.dart';
import 'package:stayzi_ui/screens/payment/payment_screen.dart';

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
  DateTimeRange? selectedRange;

  @override
  Widget build(BuildContext context) {
    print("🏠 FavoriteHomeDetailScreen - İlan verisi:");
    print("  ID: ${widget.ilan['id']}");
    print("  Başlık: ${widget.ilan['title']}");
    print("  Açıklama: ${widget.ilan['description']}");
    print("  Fiyat: ${widget.ilan['price']}");
    print("  Konum: ${widget.ilan['location']}");
    print("  Ev sahibi: ${widget.ilan['host']}");
    print("  Olanaklar: ${widget.ilan['amenities']}");
    print("  Ev kuralları: ${widget.ilan['home_rules']}");
    
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
      } else if (widget.ilan['image_urls'] != null) {
        final imageUrls = widget.ilan['image_urls'] as List<dynamic>?;
        if (imageUrls != null) {
          imageList =
              imageUrls
                  .where((url) => url != null)
                  .map((url) => url.toString())
                  .toList();
        }
      }
    } catch (e) {
      print("❌ Fotoğraf listesi oluşturulurken hata: $e");
      imageList = widget.ilan['foto'] != null ? [widget.ilan['foto']] : [];
    }
    
    print("📸 Fotoğraf sayısı: ${imageList.length}");

    return Scaffold(
      body: ListView(
        controller: widget.scrollController,
        padding: EdgeInsets.zero,
        children: [
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
          // İlan başlığı ve temel bilgiler
          IlanBaslik(listing: widget.ilan),
          Divider(thickness: 1, color: Colors.grey, endIndent: 20, indent: 20),
          // Ev sahibi bilgisi
          EvSahibiBilgisi(listing: widget.ilan),
          Divider(thickness: 1, color: Colors.grey, endIndent: 20, indent: 20),
          MekanAciklamasi(
            description: widget.ilan['description']?.toString() ?? '',
          ),
          Divider(thickness: 1, color: Colors.grey, endIndent: 20, indent: 20),
          KonumBilgisi(
            latitude: (widget.ilan['latitude'] as num?)?.toDouble() ?? 0.0,
            longitude: (widget.ilan['longitude'] as num?)?.toDouble() ?? 0.0,
          ),
          Divider(thickness: 1, color: Colors.grey, endIndent: 20, indent: 20),
          TakvimBilgisi(
            onDateRangeChanged: (range) {
              setState(() {
                selectedRange = range;
              });
            },
          ),
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
            child: Yorumlar(listingId: widget.ilan['id']),
          ),
          Divider(thickness: 1, color: Colors.grey, endIndent: 20, indent: 20),
          OlanaklarVeKurallar(listing: widget.ilan),
          const SizedBox(height: 100),
        ],
      ),
      bottomNavigationBar: Container(
        padding: EdgeInsets.symmetric(horizontal: 35, vertical: 35),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 12,
              offset: Offset(0, -3),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Builder(
                  builder: (context) {
                    final double nightlyPrice =
                        (widget.ilan['price'] ?? 0).toDouble();
                    double? dayCount =
                        selectedRange?.duration.inDays.toDouble();
                    double totalPrice =
                        dayCount != null
                            ? nightlyPrice * dayCount
                            : nightlyPrice;
                    return Text(
                      '₺${totalPrice.toInt()}',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    );
                  },
                ),
                SizedBox(height: 4),
                Text(
                  'Total before taxes',
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                ),
              ],
            ),
            SizedBox(width: 60),
            Expanded(
              child: SizedBox(
                height: 55,
                child: ElevatedButtonWidget(
                  buttonText: 'Rezerve Et',
                  buttonColor: const Color.fromRGBO(213, 56, 88, 1),
                  textColor: Colors.white,
                  onPressed: () {
                    if (selectedRange == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Lütfen tarih seçiniz')),
                      );
                      return;
                    }
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder:
                            (context) => PaymentScreen(
                              listing: widget.ilan,
                              selectedRange: selectedRange!,
                            ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
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
