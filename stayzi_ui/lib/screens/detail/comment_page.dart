import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:stayzi_ui/models/review_model.dart';
import 'package:stayzi_ui/screens/onboard/widgets/form_widget.dart';
import 'package:stayzi_ui/services/api_constants.dart';
import 'package:stayzi_ui/services/api_service.dart';

class CommentPage extends StatefulWidget {
  final int listingId;
  const CommentPage({super.key, required this.listingId});

  @override
  State<CommentPage> createState() => _CommentPageState();
}

class _CommentPageState extends State<CommentPage> {
  List<Review> reviews = [];
  final TextEditingController _searchController = TextEditingController();
  List<Review> filteredReviews = [];

  @override
  void initState() {
    super.initState();
    loadReviews();
  }

  Future<void> loadReviews() async {
    try {
      final fetchedReviews = await ApiService().fetchReviews(widget.listingId);
      setState(() {
        reviews = fetchedReviews;
        filteredReviews = fetchedReviews;
      });
    } catch (e) {
      print('Yorumlar yüklenemedi: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body:
          filteredReviews.isEmpty
              ? const Center(child: CircularProgressIndicator())
              : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 65),
                  Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Text(
                      '${filteredReviews.length} Değerlendirme',
                      style: TextStyle(
                        fontSize: 23,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(15.0),
                    child: Builder(
                      builder: (context) {
                        _searchController.addListener(() {
                          final query = _searchController.text.toLowerCase();
                          setState(() {
                            filteredReviews =
                                reviews
                                    .where(
                                      (review) => review.comment
                                          .toLowerCase()
                                          .contains(query),
                                    )
                                    .toList();
                          });
                        });

                        return FormWidget(
                          controller: _searchController,
                          hintText: 'Yorumlarda Arayın',
                          helperText:
                              "Aramak istediğiniz anahtar kelimeyi giriniz.",
                          textInputAction: TextInputAction.search,
                          keyboardType: TextInputType.text,
                        );
                      },
                    ),
                  ),
                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      itemCount: filteredReviews.length,
                      itemBuilder: (context, index) {
                        final review = filteredReviews[index];
                        return _buildReview(
                          name: '${review.user.name} ${review.user.surname}',
                          locationInfo: '', // opsiyonel
                          timeAgo: DateFormat(
                            'dd MMMM yyyy',
                          ).format(review.createdAt),
                          stayInfo: '', // opsiyonel
                          rating: review.rating,
                          comment: review.comment,
                          avatarUrl:
                              review.user.profileImage != null &&
                                      review.user.profileImage!.isNotEmpty
                                  ? '${ApiConstants.baseUrl}${review.user.profileImage!}'
                                  : 'https://via.placeholder.com/150',
                        );
                      },
                    ),
                  ),
                ],
              ),
    );
  }

  Widget _buildReview({
    required String name,
    required String locationInfo,
    required String timeAgo,
    required String stayInfo,
    required double rating,
    required String comment,
    required String avatarUrl,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(backgroundImage: NetworkImage(avatarUrl), radius: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
                Text(locationInfo, style: const TextStyle(color: Colors.grey)),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.star, size: 16, color: Colors.black),
                    Text(
                      " $rating  ·  $timeAgo  ·  $stayInfo",
                      style: const TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(comment),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
