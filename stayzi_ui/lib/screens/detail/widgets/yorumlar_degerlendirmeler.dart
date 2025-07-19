import 'package:flutter/material.dart';
import 'package:stayzi_ui/screens/detail/review_detail_page.dart';
import 'package:stayzi_ui/services/api_service.dart';

class Yorumlar extends StatefulWidget {
  final int? listingId;
  
  const Yorumlar({super.key, this.listingId});

  @override
  State<Yorumlar> createState() => _YorumlarState();
}

class _YorumlarState extends State<Yorumlar> {
  List<Map<String, dynamic>> reviews = [];
  bool isLoading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    _loadReviews();
  }

  Future<void> _loadReviews() async {
    if (widget.listingId == null) {
      setState(() {
        isLoading = false;
      });
      return;
    }

    try {
      final apiReviews = await ApiService().getListingReviews(
        widget.listingId!,
      );
      setState(() {
        reviews = apiReviews;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        error = e.toString();
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const SizedBox(
        height: 160,
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (error != null) {
      return SizedBox(
        height: 160,
        child: Center(
          child: Text(
            'Yorumlar yüklenemedi: $error',
            style: const TextStyle(color: Colors.red),
          ),
        ),
      );
    }

    if (reviews.isEmpty) {
      return const SizedBox(
        height: 160,
        child: Center(
          child: Text(
            'Bu ilan için henüz yorum bulunmamaktadır.',
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
        ),
      );
    }

    return SizedBox(
      height: 160,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: reviews.length,
        itemBuilder: (context, index) {
          final review = reviews[index];
          final reviewObj = Review(
            name: review['user_name'] ?? 'Anonim',
            comment: review['comment'] ?? '',
            date: _formatDate(review['created_at']),
            profileImage: "assets/images/user.jpg",
          );
          
          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ReviewDetailPage(review: reviewObj),
                ),
              );
            },
            child: Container(
              width: 280,
              margin: EdgeInsets.all(10),
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        backgroundImage: AssetImage(reviewObj.profileImage),
                        radius: 16,
                      ),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          reviewObj.name,
                          style: TextStyle(fontWeight: FontWeight.bold),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text(reviewObj.date, style: TextStyle(fontSize: 12)),
                    ],
                  ),
                  SizedBox(height: 10),
                  Text(
                    reviewObj.comment,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: Colors.black87),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  String _formatDate(String? dateString) {
    if (dateString == null) return 'Bilinmiyor';

    try {
      final date = DateTime.parse(dateString);
      final now = DateTime.now();
      final difference = now.difference(date);

      if (difference.inDays == 0) {
        return 'Bugün';
      } else if (difference.inDays == 1) {
        return 'Dün';
      } else if (difference.inDays < 7) {
        return '${difference.inDays} gün önce';
      } else if (difference.inDays < 30) {
        final weeks = (difference.inDays / 7).floor();
        return '$weeks hafta önce';
      } else if (difference.inDays < 365) {
        final months = (difference.inDays / 30).floor();
        return '$months ay önce';
      } else {
        final years = (difference.inDays / 365).floor();
        return '$years yıl önce';
      }
    } catch (e) {
      return 'Bilinmiyor';
    }
  }
}
