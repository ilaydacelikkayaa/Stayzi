import 'package:flutter/material.dart';
import 'package:stayzi_ui/screens/detail/review_detail_page.dart';

class Yorumlar extends StatelessWidget {
  Yorumlar({super.key});

  final List<Review> reviews = [
    Review(
      name: "Tarık Furkan",
      comment: "Konum olarak doğayla iç içeydi, temizdi.",
      date: "3 hafta önce",
      profileImage: "assets/images/user.jpg",
    ),
    Review(
      name: "Emre",
      comment: "Her şey fotoğraflarda olduğu gibiydi. Çok beğendik.",
      date: "Şubat 2025",
      profileImage: "assets/images/user.jpg",
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 160,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: reviews.length,
        itemBuilder: (context, index) {
          final review = reviews[index];
          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ReviewDetailPage(review: review),
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
                        backgroundImage: AssetImage(review.profileImage),
                        radius: 16,
                      ),
                      SizedBox(width: 8),
                      Text(
                        review.name,
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Spacer(),
                      Text(review.date, style: TextStyle(fontSize: 12)),
                    ],
                  ),
                  SizedBox(height: 10),
                  Text(
                    review.comment,
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
}
