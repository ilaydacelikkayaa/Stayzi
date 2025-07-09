import 'package:flutter/material.dart';
import 'package:stayzi_ui/screens/onboard/widgets/form_widget.dart';

class CommentPage extends StatelessWidget {
  const CommentPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 65),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Text(
                '35 Değerlendirme',
                style: TextStyle(fontSize: 23, fontWeight: FontWeight.bold),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(15.0),
              child: FormWidget(
                hintText: 'Yorumlarda Arayın',
                helperText: "Aramak istediğiniz anahtar kelimeyi giriniz.",
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                children: [
                  _buildReview(
                    name: "Christian *****",
                    locationInfo: "Baltimore, Maryland",
                    timeAgo: "1 week ago",
                    stayInfo: "Birkaç gece kaldı",
                    rating: 5.0,
                    comment:
                        "This property was a pleasure to visit. Everything is perfectly as advertised, clean, and well maintained. The cabin is well equipped with lots of little convenient amenities.",
                    avatarUrl: "https://randomuser.me/api/portraits/men/11.jpg",
                  ),
                  _buildReview(
                    name: "Hillary *****",
                    locationInfo: "5 years on Airbnb",
                    timeAgo: "2 weeks ago",
                    stayInfo: "Bir evcil hayvan",
                    rating: 4.5,
                    comment:
                        "We loved Dreamtime! I booked the reservation on a whim based on the cute photos and it did not disappoint! The cleanliness of the entire place was impressive.",
                    avatarUrl:
                        "https://randomuser.me/api/portraits/women/44.jpg",
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
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
