import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
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
  final Map<String, dynamic> listing;
  const ListingDetailPage({super.key, required this.listing});

  @override
  State<ListingDetailPage> createState() => _ListingDetailPageState();
}

class _ListingDetailPageState extends State<ListingDetailPage> {
  bool isFavorite = false;
  DateTimeRange? selectedRange;
  late Future<Map<String, dynamic>> _listingFuture;

  @override
  void initState() {
    super.initState();
    _listingFuture = fetchUpdatedListing();
  }

  void refreshListing() {
    setState(() {
      _listingFuture = fetchUpdatedListing();
    });
  }

  Future<Map<String, dynamic>> fetchUpdatedListing() async {
    try {
      final response = await http.get(
        Uri.parse('http://localhost:8000/listings/${widget.listing['id']}'),
      );
      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to load listing');
      }
    } catch (e) {
      // Hata durumunda orijinal veriyi döndür
      return widget.listing;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: FutureBuilder<Map<String, dynamic>>(
        future: _listingFuture,
        builder: (context, snapshot) {
          print('DEBUG - Detail Screen FutureBuilder:');
          print('ConnectionState: ${snapshot.connectionState}');
          print('HasData: ${snapshot.hasData}');
          print('HasError: ${snapshot.hasError}');

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final listing = snapshot.data ?? widget.listing;

          // Debug: İzin alanlarını yazdır
          print('DEBUG - Detail Screen Listing Data:');
          print('allow_events: ${listing['allow_events']}');
          print('allow_smoking: ${listing['allow_smoking']}');
          print('allow_commercial_photo: ${listing['allow_commercial_photo']}');
          print('max_guests: ${listing['max_guests']}');
          print('Full API Response: $listing');

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
          
          return Stack(
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
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Padding(padding: EdgeInsets.all(20), child: Yorumlar()),
                    SizedBox(
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
                              builder: (context) => CommentPage(),
                            ),
                          );
                        },
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
          );
        },
      ),
      bottomNavigationBar: FutureBuilder<Map<String, dynamic>>(
        future: _listingFuture,
        builder: (context, snapshot) {
          final listing = snapshot.data ?? widget.listing;
          return Container(
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
                          ' 24${totalPrice.toInt()}',
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
                      buttonColor: Colors.black,
                      textColor: Colors.white,
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => PaymentScreen(),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
