import 'package:flutter/material.dart';

import 'favorite_list_detail_screen.dart';

class FavoriteScreen extends StatelessWidget {
  final List<Map<String, dynamic>> favoriListeleri;

  const FavoriteScreen({
    super.key,
    this.favoriListeleri = const [
      {
        'listeAdi': 'Deniz Manzaralılar',
        'ilanlar': [
          {
            'id': 1,
            'baslik': 'Denize Sıfır',
            'foto':
                'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRkW7wNqbHHS1Wqtm9WC4jnsGsJklHEy5Wekg&s',
            'fiyat': '10.000 TL',
            'konum': 'İstanbul, Kadıköy',
          },
          {
            'id': 2,
            'baslik': 'Yüksek Kat',
            'foto':
                'https://media.istockphoto.com/id/483773209/tr/foto%C4%9Fraf/new-cozy-cottage.jpg?s=612x612&w=0&k=20&c=O983Ujj0wX562XAD4KQPALe3PWu_nIr0OLPzsoGfrQg=',
            'fiyat': '10.000 TL',
            'konum': 'İstanbul, Kadıköy',
          },
          {
            'id': 3,
            'baslik': 'Havuzlu Site',
            'foto':
                'https://media.istockphoto.com/id/503044702/tr/foto%C4%9Fraf/illuminated-sky-and-outside-of-waterfront-buiding.jpg?s=612x612&w=0&k=20&c=x2EFB0Ki7IK0btUG8CS3CV6-zwhdpzud2LNMEJUencw=',
            'fiyat': '10.000 TL',
            'konum': 'İstanbul, Kadıköy',
          },
          {
            'id': 4,
            'baslik': 'Yeni Bina',
            'foto':
                'https://media.istockphoto.com/id/506903162/tr/foto%C4%9Fraf/luxurious-villa-with-pool.jpg?s=612x612&w=0&k=20&c=8Ajn2ormM8zfs7E8H7p4QWzy-Zj56RAF1bnXG67R_rg=',
            'fiyat': '10.000 TL',
            'konum': 'İstanbul, Kadıköy',
          },
        ],
      },
      {
        'listeAdi': 'Merkez Daireler',
        'ilanlar': [
          {
            'id': 5,
            'baslik': 'Merkezde',
            'foto':
                'https://images.squarespace-cdn.com/content/v1/58412fc9b3db2b11ba9398df/1582209923341-LP764XVQRSG07IJAP0BW/cam-ev-tasarimi',
            'fiyat': '10.000 TL',
            'konum': 'İstanbul, Kadıköy',
          },
          {
            'id': 6,
            'baslik': 'Toplu Taşımaya Yakın',
            'foto':
                'https://www.evmimarileri.com/wp-content/uploads/2014/05/m%C3%BCkemmel-ev.jpg',
            'fiyat': '10.000 TL',
            'konum': 'İstanbul, Kadıköy',
          },
        ],
      },
      {
        'listeAdi': 'Ispartadaki Evler',
        'ilanlar': [
          {
            'id': 7,
            'baslik': 'Merkezde',
            'foto':
                'https://cdn.pixabay.com/photo/2013/08/30/12/56/holiday-house-177401_1280.jpg',
            'fiyat': '10.000 TL',
            'konum': 'İstanbul, Kadıköy',
          },
          {
            'id': 8,
            'baslik': 'Toplu Taşımaya Yakın',
            'foto':
                'https://www.shutterstock.com/image-photo/modern-white-house-large-windows-260nw-2540846177.jpg',
            'fiyat': '10.000 TL',
            'konum': 'İstanbul, Kadıköy',
          },
        ],
      },
    ],
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Favori Listeler')),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: GridView.builder(
          itemCount: favoriListeleri.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
            childAspectRatio: 1, // Kare yapı
          ),
          itemBuilder: (context, index) {
            final liste = favoriListeleri[index];
            final ilanlar = List<Map<String, dynamic>>.from(liste['ilanlar']);
            final gosterilecekResimler =
                ilanlar.take(4).toList(); // en fazla 4 resim al

            return GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder:
                        (_) => FavoriteListDetailScreen(
                          listeAdi: liste['listeAdi'],
                          ilanlar: ilanlar,
                        ),
                  ),
                );
              },
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 6,
                      offset: Offset(2, 2),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    // Fotoğraf kolajı
                    SizedBox(
                      height: 120,
                      width: double.infinity,
                      child: ClipRRect(
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(22),
                        ),
                        child: Table(
                          defaultColumnWidth: const FlexColumnWidth(1),
                          children: [
                            TableRow(
                              children: [
                                _buildCollageImage(
                                  gosterilecekResimler,
                                  0,
                                  topLeft: true,
                                ),
                                _buildCollageImage(
                                  gosterilecekResimler,
                                  1,
                                  topRight: true,
                                ),
                              ],
                            ),
                            TableRow(
                              children: [
                                _buildCollageImage(
                                  gosterilecekResimler,
                                  2,
                                  bottomLeft: true,
                                ),
                                _buildCollageImage(
                                  gosterilecekResimler,
                                  3,
                                  bottomRight: true,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(
                        top: 10,
                        left: 8,
                        right: 8,
                        bottom: 4,
                      ),
                      child: Column(
                        children: [
                          Text(
                            liste['listeAdi'],
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 17,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.grey[200],
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              '${ilanlar.length} ilan',
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.black54,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

// Kolaj için yardımcı fonksiyon
Widget _buildCollageImage(
  List<Map<String, dynamic>> resimler,
  int index, {
  bool topLeft = false,
  bool topRight = false,
  bool bottomLeft = false,
  bool bottomRight = false,
}) {
  BorderRadius radius = BorderRadius.only(
    topLeft: topLeft ? const Radius.circular(22) : Radius.zero,
    topRight: topRight ? const Radius.circular(22) : Radius.zero,
    bottomLeft: bottomLeft ? const Radius.circular(22) : Radius.zero,
    bottomRight: bottomRight ? const Radius.circular(22) : Radius.zero,
  );
  if (index < resimler.length) {
    return ClipRRect(
      borderRadius: radius,
      child:
          resimler[index]['foto']?.toString().startsWith('http') == true
              ? Image.network(
                resimler[index]['foto']!.toString(),
                fit: BoxFit.cover,
                height: 60,
                width: 60,
              )
              : Image.asset(
                'assets/images/user.jpg',
                fit: BoxFit.cover,
                height: 60,
                width: 60,
              ),
    );
  } else {
    return Container(color: Colors.grey[300]);
  }
}
