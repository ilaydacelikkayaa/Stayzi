import 'package:flutter/material.dart';
import 'package:stayzi_ui/screens/detail/comment_page.dart';
import 'package:stayzi_ui/services/api_service.dart';

class IlanBaslik extends StatefulWidget {
  final Map<String, dynamic> listing;

  const IlanBaslik({super.key, required this.listing});

  @override
  State<IlanBaslik> createState() => _IlanBaslikState();
}

class _IlanBaslikState extends State<IlanBaslik> {
  int _reviewCount = 0;
  double _averageRating = 0.0;
  bool _isLoading = true;

  Future<void> _fetchReviewData() async {
    try {
      final reviews = await ApiService().fetchReviews(widget.listing['id']);

      double totalRating = 0.0;
      for (var review in reviews) {
        totalRating += review.rating;
      }

      setState(() {
        _reviewCount = reviews.length;
        _averageRating =
            reviews.isNotEmpty ? totalRating / reviews.length : 0.0;
        _isLoading = false;
      });
    } catch (e) {
      print("Yorum bilgileri alınamadı: $e");
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchReviewData();
  }

  @override
  Widget build(BuildContext context) {
    final ratingText = _averageRating.toStringAsFixed(1);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          Text(
            widget.listing['title'] ?? 'Başlık bulunamadı',
            style: const TextStyle(
              fontSize: 27,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            widget.listing['location'] ?? 'Lokasyon bulunamadı',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              const Icon(Icons.star, size: 16, color: Colors.black),
              const SizedBox(width: 4),
              Text(
                ratingText,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(width: 10),
              if (_isLoading)
                const CircularProgressIndicator()
              else if (_reviewCount > 0)
                TextButton(
                  style: ButtonStyle(
                    foregroundColor: WidgetStateProperty.all(Colors.black),
                    textStyle: WidgetStateProperty.all(
                      const TextStyle(decoration: TextDecoration.underline),
                    ),
                  ),
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder:
                            (context) =>
                                CommentPage(listingId: widget.listing['id']),
                      ),
                    );
                  },
                  child: Text("$_reviewCount değerlendirme"),
                )
              else
                const Text(
                  "Henüz değerlendirme yok",
                  style: TextStyle(color: Colors.grey),
                ),
            ],
          ),
          const SizedBox(height: 10),
        ],
      ),
    );
  }
}
