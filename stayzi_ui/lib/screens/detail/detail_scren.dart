import 'package:flutter/material.dart';
import 'package:stayzi_ui/screens/detail/comment_page.dart';
import 'package:stayzi_ui/screens/detail/widgets/ev_sahibi_bilgisi.dart';
import 'package:stayzi_ui/screens/detail/widgets/ilan_baslik.dart';
import 'package:stayzi_ui/screens/detail/widgets/image_gallery.dart';
import 'package:stayzi_ui/screens/detail/widgets/konum_harita.dart';
import 'package:stayzi_ui/screens/detail/widgets/mekan_aciklamasi.dart';
import 'package:stayzi_ui/screens/detail/widgets/olanaklar_ve_kurallar.dart';
import 'package:stayzi_ui/screens/detail/widgets/takvim_bilgisi.dart';
import 'package:stayzi_ui/screens/detail/widgets/yorumlar_degerlendirmeler.dart';
import 'package:stayzi_ui/screens/onboard/widgets/basic_button.dart';
import 'package:stayzi_ui/screens/payment/payment_screen.dart';

class ListingDetailPage extends StatefulWidget {
  const ListingDetailPage({super.key});

  @override
  State<ListingDetailPage> createState() => _ListingDetailPageState();
}

class _ListingDetailPageState extends State<ListingDetailPage> {
  bool isFavorite = false;

  @override
  Widget build(BuildContext context) {
    //şimdilik burası bu sekilde api baglantisiyla burası degisecek..
    final List<String> imageList = [
      'assets/images/ilan2.jpg',
      'assets/images/ilan2.jpg',
      'assets/images/ilan2.jpg',
    ];
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              children: [
                // Fotoğraf Galerisi
                ListingImageGallery(imageList: imageList),
                //İlan basligi
                IlanBaslik(),
                // İçerik
                Divider(
                  thickness: 1,
                  color: Colors.grey,
                  endIndent: 20,
                  indent: 20,
                ),
                EvSahibiBilgisi(),
                Divider(
                  thickness: 1,
                  color: Colors.grey,
                  endIndent: 20,
                  indent: 20,
                ),

                // "Bu mekan hakkında" kısmı ve açıklama
                MekanAciklamasi(),
                Divider(
                  thickness: 1,
                  color: Colors.grey,
                  endIndent: 20,
                  indent: 20,
                ),

                KonumBilgisi(),

                Divider(
                  thickness: 1,
                  color: Colors.grey,
                  endIndent: 20,
                  indent: 20,
                ),
                TakvimBilgisi(),
                Divider(
                  thickness: 1,
                  color: Colors.grey,
                  endIndent: 20,
                  indent: 20,
                ),
                SizedBox(height: 15),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    "Yorumlar ve Değerlendirmeler",
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                ),
                Yorumlar(),
                SizedBox(
                  width: 250,
                  height: 60,
                  child: ElevatedButtonWidget(
                    side: BorderSide(color: Colors.black, width: 1),
                    elevation: 0,
                    buttonText: 'Yorumların hepsini göster',
                    buttonColor: Colors.transparent,
                    textColor: Colors.black,
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (context) => CommentPage()),
                      );
                    },
                  ),
                ),
                SizedBox(height: 15),
                Divider(
                  thickness: 1,
                  color: Colors.grey,
                  endIndent: 20,
                  indent: 20,
                ),
                OlanaklarVeKurallar(),
                SizedBox(
                  width: 120,
                  child: ElevatedButtonWidget(
                    buttonText: 'Rezerve Et',
                    buttonColor: Colors.black,
                    textColor: Colors.white,
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const PaymentScreen(),
                        ),
                      );
                    },
                  ),
                ),
                SizedBox(height: 100),
              ],
            ),
          ),

          // Üst Butonlar
          Positioned(
            top: MediaQuery.of(context).padding.top + 16,
            left: 16,
            right: 16,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                CircleAvatar(
                  backgroundColor: Colors.white,
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.black),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
                Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: Colors.white.withOpacity(0.9),
                      child: IconButton(
                        icon: const Icon(Icons.ios_share, color: Colors.black),
                        onPressed: () {},
                      ),
                    ),
                    const SizedBox(width: 8),
                    CircleAvatar(
                      backgroundColor: Colors.white.withOpacity(0.9),
                      child: IconButton(
                        icon:
                            isFavorite
                                ? const Icon(Icons.favorite, color: Colors.red)
                                : const Icon(
                                  Icons.favorite_border,
                                  color: Colors.black,
                                ),
                        onPressed: () {
                          setState(() {
                            isFavorite = !isFavorite;
                          });
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
