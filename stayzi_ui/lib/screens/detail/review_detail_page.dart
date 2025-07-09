import 'package:flutter/material.dart';

class Review {
  final String name;
  final String comment;
  final String date;
  final String profileImage;

  Review({
    required this.name,
    required this.comment,
    required this.date,
    required this.profileImage,
  });
}

class ReviewDetailPage extends StatelessWidget {
  final Review review;

  const ReviewDetailPage({super.key, required this.review});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                  backgroundImage: AssetImage(review.profileImage),
                  radius: 25,
                ),
                SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      review.name,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(review.date),
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
