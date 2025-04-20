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
            'baslik': 'Denize Sıfır',
            'foto':
                'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRkW7wNqbHHS1Wqtm9WC4jnsGsJklHEy5Wekg&s',
            'fiyat': '10.000 TL',
            'konum': 'İstanbul, Kadıköy',
          },
          {
            'baslik': 'Yüksek Kat',
            'foto':
                'https://media.istockphoto.com/id/483773209/tr/foto%C4%9Fraf/new-cozy-cottage.jpg?s=612x612&w=0&k=20&c=O983Ujj0wX562XAD4KQPALe3PWu_nIr0OLPzsoGfrQg=',
            'fiyat': '10.000 TL',
            'konum': 'İstanbul, Kadıköy',
          },
          {
            'baslik': 'Havuzlu Site',
            'foto':
                'https://media.istockphoto.com/id/503044702/tr/foto%C4%9Fraf/illuminated-sky-and-outside-of-waterfront-buiding.jpg?s=612x612&w=0&k=20&c=x2EFB0Ki7IK0btUG8CS3CV6-zwhdpzud2LNMEJUencw=',
            'fiyat': '10.000 TL',
            'konum': 'İstanbul, Kadıköy',
          },
          {
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
            'baslik': 'Merkezde',
            'foto':
                'https://images.squarespace-cdn.com/content/v1/58412fc9b3db2b11ba9398df/1582209923341-LP764XVQRSG07IJAP0BW/cam-ev-tasarimi',
            'fiyat': '10.000 TL',
            'konum': 'İstanbul, Kadıköy',
          },
          {
            'baslik': 'Toplu Taşımaya Yakın',
            'foto':
                'https://www.evmimarileri.com/wp-content/uploads/2014/05/m%C3%BCkemmel-ev.jpg',
            'fiyat': '10.000 TL',
            'konum': 'İstanbul, Kadıköy',
          },
        ],
      },
      {
        'listeAdi': 'Can Ispartamdakiler',
        'ilanlar': [
          {
            'baslik': 'Merkezde',
            'foto':
                'https://cdn.pixabay.com/photo/2013/08/30/12/56/holiday-house-177401_1280.jpg',
            'fiyat': '10.000 TL',
            'konum': 'İstanbul, Kadıköy',
          },
          {
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
            final ilanlar = List<Map<String, String>>.from(liste['ilanlar']);
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
                    Expanded(
                      child: GridView.builder(
                        physics: const NeverScrollableScrollPhysics(),
                        padding: EdgeInsets.zero,
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              mainAxisSpacing: 1,
                              crossAxisSpacing: 1,
                            ),
                        itemCount: 4,
                        itemBuilder: (context, i) {
                          if (i < gosterilecekResimler.length) {
                            return ClipRRect(
                              borderRadius:
                                  i == 0
                                      ? const BorderRadius.only(
                                        topLeft: Radius.circular(16),
                                      )
                                      : i == 1
                                      ? const BorderRadius.only(
                                        topRight: Radius.circular(16),
                                      )
                                      : BorderRadius.zero,
                              child: Image.network(
                                gosterilecekResimler[i]['foto']!,
                                fit: BoxFit.cover,
                              ),
                            );
                          } else {
                            return Container(color: Colors.grey[300]);
                          }
                        },
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        liste['listeAdi'],
                        style: const TextStyle(fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
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
