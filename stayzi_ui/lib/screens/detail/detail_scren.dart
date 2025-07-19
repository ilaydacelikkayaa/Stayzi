import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
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
import 'package:stayzi_ui/screens/onboard/widgets/form_widget.dart';
import 'package:stayzi_ui/screens/payment/payment_screen.dart';
import 'package:stayzi_ui/services/api_service.dart';
import 'package:stayzi_ui/services/storage_service.dart';

class ListingDetailPage extends StatefulWidget {
  final Map<String, dynamic> listing;
  const ListingDetailPage({super.key, required this.listing});

  @override
  State<ListingDetailPage> createState() => _ListingDetailPageState();
}

class _ListingDetailPageState extends State<ListingDetailPage> {
  bool isFavorite = false;
  DateTimeRange? selectedRange;
  int yorumSayisi = 0;
  bool isLoggedIn = false;
  double rating = 0;
  TextEditingController _commentController = TextEditingController();

  void _showCommentSheet(int listingId) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  "Yorum Ekle",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                FormWidget(
                  labelText: 'Yorumunuzu yazın',
                  controller: _commentController,
                  keyboardType: TextInputType.multiline,
                  textInputAction: TextInputAction.newline,
                ),
                const SizedBox(height: 16),
                Text("Puanınız:", style: TextStyle(fontSize: 16)),
                const SizedBox(height: 8),
                RatingBar.builder(
                  initialRating: 0,
                  minRating: 1,
                  direction: Axis.horizontal,
                  allowHalfRating: false,
                  itemCount: 5,
                  itemPadding: EdgeInsets.symmetric(horizontal: 4.0),
                  itemBuilder:
                      (context, _) => Icon(Icons.star, color: Colors.amber),
                  onRatingUpdate: (newRating) {
                    setState(() {
                      rating = newRating;
                    });
                  },
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: 200,
                  child: ElevatedButtonWidget(
                    elevation: 1,
                    buttonColor: const Color.fromRGBO(213, 56, 88, 1),
                    textColor: Colors.white,
                    onPressed: () async {
                      final comment = _commentController.text.trim();
                      if (comment.isEmpty || rating == 0) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Lütfen yorum ve puan giriniz'),
                          ),
                        );
                        return;
                      }
                      Navigator.of(context).pop();
                      final success = await ApiService().postReview(
                        listingId: listingId,
                        rating: rating,
                        comment: comment,
                      );
                      if (success) {
                        setState(() {
                          yorumSayisi++;
                        });
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Yorum eklendi')),
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Yorum eklenirken hata oluştu'),
                          ),
                        );
                      }
                    },
                    buttonText: 'Gönder',
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    _commentController = TextEditingController();
    Future.delayed(Duration.zero, () async {
      final token = await StorageService().getToken();
      debugPrint("💡 initState token: $token");
      setState(() {
        isLoggedIn = token != null && token.accessToken.isNotEmpty;
      });
    });
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final listing = widget.listing;
    // Safe image list extraction
    List<String> imageList = [];
    try {
      final imageUrls = listing['image_urls'] as List<dynamic>?;
      if (imageUrls != null) {
        imageList =
            imageUrls
                .where((url) => url != null)
                .map((url) => url.toString())
                .toList();
      }
    } catch (e) {
      print('Error extracting image URLs: $e');
    }
    imageList =
        imageList.map((url) {
          if (url.startsWith('/')) {
            return 'http://localhost:8000$url';
          }
          return url;
        }).toList();

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              children: [
                ListingImageGallery(imageList: imageList),
                if (imageList.isEmpty)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Text(
                        'Bu ilana ait fotoğraf bulunmamaktadır.',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                IlanBaslik(listing: listing),
                Divider(
                  thickness: 1,
                  color: Colors.grey,
                  endIndent: 20,
                  indent: 20,
                ),
                EvSahibiBilgisi(listing: listing),
                Divider(
                  thickness: 1,
                  color: Colors.grey,
                  endIndent: 20,
                  indent: 20,
                ),
                MekanAciklamasi(
                  description: listing['description']?.toString() ?? '',
                ),
                Divider(
                  thickness: 1,
                  color: Colors.grey,
                  endIndent: 20,
                  indent: 20,
                ),
                KonumBilgisi(
                  latitude: (listing['lat'] as num?)?.toDouble() ?? 0.0,
                  longitude: (listing['lng'] as num?)?.toDouble() ?? 0.0,
                ),
                Divider(
                  thickness: 1,
                  color: Colors.grey,
                  endIndent: 20,
                  indent: 20,
                ),
                TakvimBilgisi(
                  onDateRangeChanged: (range) {
                    setState(() {
                      selectedRange = range;
                    });
                  },
                ),
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
                Padding(
                  padding: EdgeInsets.all(20),
                  child: Yorumlar(
                    listingId: listing['id'],
                    onCommentCountChanged: (count) {
                      setState(() {
                        yorumSayisi = count;
                      });
                    },
                  ),
                ),
                if (isLoggedIn)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: SizedBox(
                      width: 250,
                      height: 60,
                      child: ElevatedButtonWidget(
                        buttonText: 'Yorum Ekle',
                        buttonColor: Colors.black,
                        textColor: Colors.white,
                        onPressed: () {
                          _showCommentSheet(listing['id']);
                        },
                      ),
                    ),
                  ),
                Visibility(
                  visible: yorumSayisi > 0,
                  child: SizedBox(
                    width: 250,
                    height: 60,
                    child: ElevatedButtonWidget(
                      side: BorderSide(color: Colors.black, width: 2),
                      elevation: 0,
                      buttonText: 'Yorumların hepsini göster',
                      buttonColor: Colors.transparent,
                      textColor: Colors.black,
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder:
                                (context) =>
                                    CommentPage(listingId: listing['id']),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                SizedBox(height: 20),
                Divider(
                  thickness: 1,
                  color: Colors.grey,
                  endIndent: 20,
                  indent: 20,
                ),
                OlanaklarVeKurallar(listing: listing),
                SizedBox(height: 100),
              ],
            ),
          ),
          Positioned(
            top: MediaQuery.of(context).padding.top + 16,
            left: 16,
            right: 16,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                CircleAvatar(
                  backgroundColor: Colors.black.withOpacity(0.5),
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
                Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: Colors.black.withOpacity(0.5),
                      child: IconButton(
                        icon: const Icon(
                          Icons.ios_share,
                          color: Colors.white,
                        ),
                        onPressed: () {},
                      ),
                    ),
                    const SizedBox(width: 8),
                    CircleAvatar(
                      backgroundColor: Colors.black.withOpacity(0.5),
                      child: IconButton(
                        icon:
                            isFavorite
                                ? const Icon(
                                  Icons.favorite,
                                  color: Colors.red,
                                )
                                : const Icon(
                                  Icons.favorite_border,
                                  color: Colors.white,
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
                        (listing['price'] ?? 0).toDouble();
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
                              listing: listing,
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
