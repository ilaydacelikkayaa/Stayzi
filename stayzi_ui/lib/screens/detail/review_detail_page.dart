import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:stayzi_ui/models/review_model.dart';
import 'package:stayzi_ui/services/api_constants.dart';

class ReviewDetailPage extends StatelessWidget {
  final Review review;

  const ReviewDetailPage({super.key, required this.review});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('Yorum Detayı'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundImage: NetworkImage(
                    '${ApiConstants.baseUrl}${review.profileImage}',
                  ),
                  radius: 25,
                ),
                SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${review.user.name ?? ''} ${review.user.surname ?? ''}',
                    ),
                    Text(DateFormat('dd MMMM yyyy').format(review.createdAt)),
                  ],
                ),
              ],
            ),
            SizedBox(height: 20),
            Text(review.comment, style: TextStyle(fontSize: 16, height: 1.5)),
          ],
        ),
      ),
    );
  }
}
