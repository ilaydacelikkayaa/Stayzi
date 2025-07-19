import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:stayzi_ui/screens/detail/detail_scren.dart';
import 'package:stayzi_ui/screens/search/widgets/custom_search_appbar.dart';
import 'package:stayzi_ui/services/api_constants.dart';

final String baseUrl = "'http://localhost:8000";
String getListingImageUrl(String? path) {
  if (path == null || path.isEmpty) return 'assets/images/user.jpg';
  if (path.startsWith('/uploads')) {
    return baseUrl + path;
  }
  return path;
}

class SearchScreen extends StatelessWidget {
  const SearchScreen({super.key});

  Future<List<dynamic>> fetchListings() async {
    final response = await http.get(
      Uri.parse('${ApiConstants.baseUrl}/listings/'),
    );
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load listings');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomSearchAppbar(),
      body: FutureBuilder<List<dynamic>>(
        future: fetchListings(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No listings available'));
          }

          return ListView.builder(
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              final listing = snapshot.data![index];
              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ListingDetailPage(listing: listing),
                    ),
                  );
                },
                child: TinyHomeCard(listing: listing),
              );
            },
          );
        },
      ),
    );
  }
}

class TinyHomeCard extends StatefulWidget {
  final Map<String, dynamic> listing;
  const TinyHomeCard({super.key, required this.listing});

  @override
  State<TinyHomeCard> createState() => _TinyHomeCardState();
}

class _TinyHomeCardState extends State<TinyHomeCard> {
  bool isFavorite = false;

  @override
  Widget build(BuildContext context) {
    final listing = widget.listing;
    final rawUrl =
        (listing['image_urls'] as List<dynamic>).isNotEmpty
            ? listing['image_urls'][0]
            : null;

    final imageUrl =
        (rawUrl != null && rawUrl.startsWith('http'))
            ? rawUrl
            : '${ApiConstants.baseUrl}$rawUrl';

    return Material(
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ListingDetailPage(listing: listing),
            ),
          );
        },
        child: Card(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(13),
          ),
          margin: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(16),
                    ),
                    child: Image.network(
                      getListingImageUrl(imageUrl),
                      height: 200,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Icon(
                          Icons.broken_image,
                          size: 100,
                          color: Colors.grey,
                        );
                      },
                    ),
                  ),
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
                        icon: Icon(
                          isFavorite ? Icons.favorite : Icons.favorite_border,
                        ),
                        color: Colors.black,
                      ),
                    ),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      listing['location'] ?? 'Unknown Location',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(listing['title'] ?? ''),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '\$${listing['price']} night',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Row(
                          children: [
                            const Icon(
                              Icons.star,
                              size: 16,
                              color: Colors.black,
                            ),
                            const SizedBox(width: 4),
                            Text('${listing['average_rating'] ?? "0.0"}'),
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
      ),
    );
  }
}

Widget buildListingImage(String imageUrl) {
  if (imageUrl.startsWith('assets/')) {
    return Image.asset(
      imageUrl,
      height: 150,
      width: double.infinity,
      fit: BoxFit.cover,
    );
  } else {
    return Image.network(
      imageUrl,
      height: 150,
      width: double.infinity,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) {
        return Container(
          height: 150,
          width: double.infinity,
          color: Colors.grey[200],
          child: const Icon(Icons.home_outlined, size: 64, color: Colors.grey),
        );
      },
    );
  }
}
