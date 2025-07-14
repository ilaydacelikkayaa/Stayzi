import 'package:flutter/material.dart';
import 'package:stayzi_ui/screens/detail/widgets/ev_sahibi_bilgisi.dart';
import 'package:stayzi_ui/screens/detail/widgets/ilan_baslik.dart';
import 'package:stayzi_ui/screens/detail/widgets/image_gallery.dart';
import 'package:stayzi_ui/screens/detail/widgets/konum_harita.dart';
import 'package:stayzi_ui/screens/detail/widgets/mekan_aciklamasi.dart';
import 'package:stayzi_ui/screens/detail/widgets/olanaklar_ve_kurallar.dart';
import 'package:stayzi_ui/screens/detail/widgets/takvim_bilgisi.dart';
import 'package:stayzi_ui/screens/detail/widgets/yorumlar_degerlendirmeler.dart';

class FavoriteHomeDetailScreen extends StatelessWidget {
  final Map<String, dynamic> ilan;
  final ScrollController? scrollController;

  const FavoriteHomeDetailScreen({
    super.key,
    required this.ilan,
    this.scrollController,
  });

  @override
  Widget build(BuildContext context) {
    // Fotoğraf galerisi için image list
    List<String> imageList = [];
    try {
      final galeri = ilan['galeri'] as List<dynamic>?;
      if (galeri != null) {
        imageList =
            galeri
                .where((url) => url != null)
                .map((url) => url.toString())
                .toList();
      } else if (ilan['foto'] != null) {
        imageList = [ilan['foto']];
      }
    } catch (e) {
      imageList = ilan['foto'] != null ? [ilan['foto']] : [];
    }
    return ListView(
      controller: scrollController,
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
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        // İlan başlığı ve temel bilgiler
        IlanBaslik(listing: ilan),
        Divider(thickness: 1, color: Colors.grey, endIndent: 20, indent: 20),
        EvSahibiBilgisi(listing: ilan),
        Divider(thickness: 1, color: Colors.grey, endIndent: 20, indent: 20),
        MekanAciklamasi(description: ilan['description']?.toString() ?? ''),
        Divider(thickness: 1, color: Colors.grey, endIndent: 20, indent: 20),
        KonumBilgisi(
          latitude: (ilan['latitude'] as num?)?.toDouble() ?? 0.0,
          longitude: (ilan['longitude'] as num?)?.toDouble() ?? 0.0,
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
        Padding(padding: EdgeInsets.all(20), child: Yorumlar()),
        Divider(thickness: 1, color: Colors.grey, endIndent: 20, indent: 20),
        OlanaklarVeKurallar(),
        const SizedBox(height: 100),
      ],
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
