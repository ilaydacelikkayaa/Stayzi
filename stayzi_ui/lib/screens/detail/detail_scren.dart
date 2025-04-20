import 'package:flutter/material.dart';
import 'package:stayzi_ui/screens/onboard/widgets/basic_button.dart';
import 'package:stayzi_ui/screens/onboard/widgets/form_widget.dart';
import 'package:table_calendar/table_calendar.dart';

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

class ListingDetailPage extends StatefulWidget {
  const ListingDetailPage({super.key});

  @override
  State<ListingDetailPage> createState() => _ListingDetailPageState();
}

class _ListingDetailPageState extends State<ListingDetailPage> {
  bool isFavorite = false;

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
    final List<String> imageList = [
      'assets/images/ilan2.jpg',
      'assets/images/ilan2.jpg',
      'assets/images/ilan2.jpg',
    ];

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              children: [
                // Fotoğraf Galerisi
                SizedBox(
                  width: double.infinity,
                  height: MediaQuery.of(context).size.height * 0.35,
                  child: PageView.builder(
                    itemCount: imageList.length,
                    itemBuilder:
                        (context, index) =>
                            Image.asset(imageList[index], fit: BoxFit.cover),
                  ),
                ),

                // İçerik
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 20),
                      const Text(
                        "Virgina Hotel & Spa",
                        style: TextStyle(
                          fontSize: 27,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        "Hotel, West Virgina, USA",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 5),
                      const Text("2 misafir - 2 oda - 2 yatak - 1 banyo"),
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          Icon(Icons.star, size: 16, color: Colors.black),
                          SizedBox(width: 4),
                          Text("4.56"),
                          TextButton(
                            style: ButtonStyle(
                              foregroundColor: WidgetStateProperty.all(
                                Colors.black,
                              ),
                              textStyle: WidgetStateProperty.all(
                                const TextStyle(
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                            ),
                            onPressed: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) => CommentPage(),
                                ),
                              );
                            },
                            child: Text("35 değerlendirme"),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                    ],
                  ),
                ),
                Divider(
                  thickness: 1,
                  color: Colors.grey,
                  endIndent: 20,
                  indent: 20,
                ),
                Row(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: CircleAvatar(backgroundColor: Colors.black),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => HostDetailScreen(),
                              ),
                            );
                          },
                          style: ButtonStyle(
                            textStyle: WidgetStateProperty.all(
                              TextStyle(
                                decoration: TextDecoration.underline,
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                          ),
                          child: Text("Ev Sahibi : Mehmet Çelikkaya"),
                        ),
                        Text("5 yıldır ev sahibi"),
                      ],
                    ),
                  ],
                ),
                Divider(
                  thickness: 1,
                  color: Colors.grey,
                  endIndent: 20,
                  indent: 20,
                ),

                // "Bu mekan hakkında" kısmı ve açıklama
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Bu mekan hakkında",
                        style: TextStyle(
                          fontSize: 23,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 10),
                      Text(
                        "Virginia Hotel & Spa, doğayla iç içe huzurlu bir konaklama deneyimi sunar. "
                        "Modern dekorasyonu, spa olanakları ve güler yüzlü hizmetiyle konuklarına eşsiz bir tatil atmosferi sağlar. "
                        "Plaja ve yerel restoranlara sadece birkaç dakika mesafededir. Çiftler, aileler ve iş seyahati yapanlar için mükemmel bir tercihtir.",
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.black87,
                          height: 1.5,
                        ),
                      ),
                      SizedBox(height: 20),
                    ],
                  ),
                ),
                Divider(
                  thickness: 1,
                  color: Colors.grey,
                  endIndent: 20,
                  indent: 20,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 20,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Nerede Olacaksınız ?",
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        "Berkeley Springs, West Virginia, United States",
                        style: TextStyle(fontSize: 16),
                      ),
                      const SizedBox(height: 16),

                      // Harita yerine geçici görsel
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.asset(
                          'assets/images/harita.png', // geçici harita görseli
                          fit: BoxFit.cover,
                        ),
                      ),

                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(
                            Icons.verified,
                            color: Colors.green,
                            size: 20,
                          ),
                          const SizedBox(width: 6),
                          const Text(
                            "Verified listing",
                            style: TextStyle(fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        "We verified that this listing’s location is accurate.",
                        style: TextStyle(color: Colors.black87),
                      ),
                      TextButton(
                        onPressed: () {},

                        style: TextButton.styleFrom(
                          padding: EdgeInsets.zero,
                          foregroundColor: Colors.black,
                        ),
                        child: const Text("Learn more"),
                      ),
                    ],
                  ),
                ),
                Divider(
                  thickness: 1,
                  color: Colors.grey,
                  endIndent: 20,
                  indent: 20,
                ),

                TableCalendar(
                  firstDay: DateTime.now(),
                  lastDay: DateTime.now().add(Duration(days: 365)),
                  focusedDay: DateTime.now(),
                  calendarFormat: CalendarFormat.month,
                  availableCalendarFormats: const {
                    CalendarFormat.month: 'Ay',
                    CalendarFormat.twoWeeks: '2 Hafta',
                    CalendarFormat.week: 'Hafta',
                  },
                  selectedDayPredicate: (day) {
                    // Seçili gün kontrolü — istersen burada kendi mantığını kur
                    return false;
                  },
                  calendarStyle: CalendarStyle(
                    todayDecoration: BoxDecoration(
                      color: Colors.orange,
                      shape: BoxShape.circle,
                    ),
                    selectedDecoration: BoxDecoration(
                      color: Colors.black,
                      shape: BoxShape.circle,
                    ),
                  ),
                  headerStyle: HeaderStyle(
                    formatButtonVisible: true,
                    titleCentered: true,
                  ),
                  onDaySelected: (selectedDay, focusedDay) {
                    // Bir gün seçildiğinde yapılacaklar
                    print('Seçilen gün: $selectedDay');
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
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                ),
                SizedBox(
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
                              builder:
                                  (context) => ReviewDetailPage(review: review),
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
                                    backgroundImage: AssetImage(
                                      review.profileImage,
                                    ),
                                    radius: 16,
                                  ),
                                  SizedBox(width: 8),
                                  Text(
                                    review.name,
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Spacer(),
                                  Text(
                                    review.date,
                                    style: TextStyle(fontSize: 12),
                                  ),
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
                ),
                SizedBox(
                  width: 250,
                  height: 60,
                  child: ElevatedButtonWidget(
                    side: BorderSide(color: Colors.black, width: 1),
                    elevation: 0,
                    buttonText: 'Yorumların hepsini göster',
                    buttonColor: Colors.transparent,
                    textColor: Colors.black,
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (context) => CommentPage()),
                      );
                    },
                  ),
                ),
                SizedBox(height: 25),
                Divider(
                  thickness: 1,
                  color: Colors.grey,
                  endIndent: 20,
                  indent: 20,
                ),
                Padding(
                  padding: const EdgeInsets.only(right: 220),
                  child: Text(
                    "Ev Olanakları",
                    style: TextStyle(fontSize: 23, fontWeight: FontWeight.bold),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(25.0),
                  child: Text(
                    "Eve ait olanaklar burada database üzerinden yerleştirilecek. Bu yüzden burası şu an boş.",
                  ),
                ),
                Divider(
                  thickness: 1,
                  color: Colors.grey,
                  endIndent: 20,
                  indent: 20,
                ),
                SizedBox(height: 15),
                Padding(
                  padding: const EdgeInsets.only(right: 240),
                  child: Text(
                    "Ev Kuralları",
                    style: TextStyle(fontSize: 23, fontWeight: FontWeight.bold),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(25.0),
                  child: Text(
                    "Eve ait olanaklar burada database üzerinden yerleştirilecek. Bu yüzden burası şu an boş.",
                  ),
                ),
                SizedBox(
                  width: 120,
                  child: ElevatedButtonWidget(
                    buttonText: 'Rezerve Et',
                    buttonColor: Colors.black,
                    textColor: Colors.white,
                    onPressed: () {},
                  ),
                ),
              ],
            ),
          ),

          // Üst Butonlar
          Positioned(
            top: MediaQuery.of(context).padding.top + 16,
            left: 16,
            right: 16,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                CircleAvatar(
                  backgroundColor: Colors.white,
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.black),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
                Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: Colors.white.withOpacity(0.9),
                      child: IconButton(
                        icon: const Icon(Icons.ios_share, color: Colors.black),
                        onPressed: () {},
                      ),
                    ),
                    const SizedBox(width: 8),
                    CircleAvatar(
                      backgroundColor: Colors.white.withOpacity(0.9),
                      child: IconButton(
                        icon:
                            isFavorite
                                ? const Icon(Icons.favorite, color: Colors.red)
                                : const Icon(
                                  Icons.favorite_border,
                                  color: Colors.black,
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
      ),
    );
  }
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

class HostDetailScreen extends StatelessWidget {
  const HostDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Ev Sahibi Bilgileri')),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundImage: NetworkImage(
                      'https://randomuser.me/api/portraits/men/32.jpg',
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Mehmet Çelikkaya',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  Text('Ev sahibi, 2018\'den beri'),
                ],
              ),
            ),
            SizedBox(height: 30),
            Row(
              children: [
                Icon(Icons.star, color: Colors.orange),
                SizedBox(width: 5),
                Text('4.8 · 72 değerlendirme'),
              ],
            ),
            SizedBox(height: 20),
            Text(
              'Hakkında',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text(
              'Merhaba! Ben Mehmet. Seyahat etmeyi ve yeni insanlarla tanışmayı çok severim. Konuklarımın rahat ve mutlu olması benim için çok önemli.',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 20),
            Text(
              'Yanıt Süresi: Ortalama 1 saat içinde',
              style: TextStyle(color: Colors.grey[700]),
            ),
            SizedBox(height: 5),
            Text(
              'Dil: Türkçe, İngilizce',
              style: TextStyle(color: Colors.grey[700]),
            ),
            SizedBox(height: 30),
            Center(
              child: ElevatedButton(
                onPressed: () {
                  // mesaj gönderme aksiyonu
                },
                child: Text('Mesaj Gönder'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
