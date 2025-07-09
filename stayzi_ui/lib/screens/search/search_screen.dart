import 'package:flutter/material.dart';
import 'package:stayzi_ui/screens/detail/detail_scren.dart';
import 'package:stayzi_ui/screens/search/widgets/custom_search_appbar.dart';

class SearchScreen extends StatelessWidget {
  const SearchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //backgroundColor: Colors.white,
      appBar: CustomSearchAppbar(),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            children: [TinyHomeCard(), TinyHomeCard(), TinyHomeCard()],
          ),
        ),
      ),
    );
  }
}

class TinyHomeCard extends StatefulWidget {
  const TinyHomeCard({super.key});

  @override
  State<TinyHomeCard> createState() => _TinyHomeCardState();
}

class _TinyHomeCardState extends State<TinyHomeCard> {
  bool isFavorite = false;

  final Widget icon = Icon(Icons.favorite_border);

  final Widget icon2 = Icon(Icons.favorite);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => ListingDetailPage()),
        );
      },
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(13),
        ), //Card widgetının köşe yuvarlık derecesi
        margin: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Fotoğraf kısmı
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(16),
                  ),
                  child: Image.network(
                    // şuanlık network daha sonra db'den gelmesi lazım güncellencek burası
                    'https://a0.muscache.com/im/pictures/e1387ceb-abdb-4fcb-9236-bd90da2e8c55.jpg?im_w=1200',
                    height: 200,
                    width: double.infinity,
                    fit: BoxFit.cover, // tam olarak doldursun boşluk bırakmasın
                  ),
                ),

                // "Guest Favorite" etiketi
                /*Positioned(
                  top: 12,
                  left: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      'Guest favorite',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                    ),
                  ),
                ),*/

                // Kalp ikonu
                Positioned(
                  top: 12,
                  right: 12,
                  child: CircleAvatar(
                    backgroundColor: Colors.white,
                    child: IconButton(
                      onPressed: () {
                        setState(() {
                          isFavorite = !isFavorite;
                        });
                      },
                      icon: isFavorite ? icon2 : icon,
                      color: Colors.black,
                    ),
                  ),
                ),
              ],
            ),
            // Yazılar kısmı
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    'Berkeley Springs, West Virginia',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 4),
                  Text('56 miles away'),
                  Text('Feb 4 – 9'),
                  SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '\$290 night',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Row(
                        children: [
                          Icon(Icons.star, size: 16, color: Colors.black),
                          SizedBox(width: 4),
                          Text('4.99'),
                        ],
                      ),
                    ],
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
