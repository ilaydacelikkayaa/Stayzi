import 'package:flutter/material.dart';
import 'package:stayzi_ui/models/review_model.dart';
import 'package:stayzi_ui/services/api_constants.dart';
import 'package:stayzi_ui/services/api_service.dart';

class Yorumlar extends StatefulWidget {
  final int listingId;
  final void Function(int)? onCommentCountChanged;
  const Yorumlar({
    super.key,
    required this.listingId,
    this.onCommentCountChanged,
  });

  @override
  State<Yorumlar> createState() => _YorumlarState();
}

class _YorumlarState extends State<Yorumlar> {
  List<Review> reviews = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchReviews();
  }

  Future<void> fetchReviews() async {
    try {
      final data = await ApiService().fetchReviews(widget.listingId);
      setState(() {
        reviews = data;
        isLoading = false;
      });
      widget.onCommentCountChanged?.call(data.length);
    } catch (e) {
      print("Yorumlar alınamadı: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (reviews.isEmpty) {
      return const Text("Henüz yorum yok.");
    }

    return Column(
      children: reviews.take(3).map((review) {
        final profileImageUrl =
            review.user.profileImage != null
                ? '${ApiConstants.baseUrl}${review.user.profileImage}'
                : 'https://via.placeholder.com/150';

        return Container(
          margin: EdgeInsets.only(bottom: 16),
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey[300]!),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    backgroundImage: NetworkImage(profileImageUrl),
                    radius: 16,
                  ),
                  SizedBox(width: 8),
                  Text(
                    '${review.user.name ?? ''} ${review.user.surname ?? ''}',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Spacer(),
                  Text(review.date ?? '', style: TextStyle(fontSize: 12)),
                ],
              ),
              SizedBox(height: 8),
              Text(
                review.comment ?? '',
                style: TextStyle(fontSize: 14),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}
