import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:stayzi_ui/models/listing_model.dart';
import 'package:stayzi_ui/screens/search/general_filtered_sheet.dart';
import 'package:stayzi_ui/screens/search/search_screen.dart';
import 'package:stayzi_ui/services/api_constants.dart';

class FilteredScreen extends StatefulWidget {
  final Map<String, dynamic> filters;
  const FilteredScreen({super.key, required this.filters});

  @override
  State<FilteredScreen> createState() => _FilteredScreenState();
}

class _FilteredScreenState extends State<FilteredScreen> {
  final double _mapHeightFraction = 0.6;

  Future<List<Listing>> fetchFilteredListings() async {
    final uri = Uri.parse('${ApiConstants.baseUrl}/listings/filter').replace(
      queryParameters: {
        if (widget.filters['location'] != null)
          'location': widget.filters['location'].toString(),
        if (widget.filters['start_date'] != null)
          'start_date': widget.filters['start_date'].toString(),
        if (widget.filters['end_date'] != null)
          'end_date': widget.filters['end_date'].toString(),
        if (widget.filters['guests'] != null)
          'guests': widget.filters['guests'].toString(),
        if (widget.filters['min_price'] != null)
          'min_price': widget.filters['min_price'].toString(),
        if (widget.filters['max_price'] != null)
          'max_price': widget.filters['max_price'].toString(),
      },
    );

    final response = await http.get(uri);

    if (response.statusCode == 200) {
      List data = jsonDecode(response.body);
      return data.map((json) => Listing.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load filtered listings');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text("Filterelenmiş Sonuçlar"),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 15),
            child: IconButton(
              onPressed: () async {
                final updated = await Navigator.of(
                  context,
                ).push<Map<String, dynamic>>(
                  MaterialPageRoute(
                    builder:
                        (context) =>
                            GeneralFilteredSheet(filters: widget.filters),
                  ),
                );
                if (updated != null) {
                  setState(() {
                    widget.filters.clear();
                    widget.filters.addAll(updated);
                  });
                }
              },
              icon: Icon(Icons.filter_list),
            ),
          ),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return Stack(
            // stack koymamızın sebebi altta harita üstte bir bottomsheet olcak.
            children: [
              // Harita Alanının buyuyup kuculmesi icin gerekli olan basit animasyon
              AnimatedContainer(
                duration: Duration(milliseconds: 300),
                height: constraints.maxHeight * _mapHeightFraction, //gpt yapti
                width: double.infinity,
                color: Colors.blueGrey, // Harita yerine dummy renk
                child: Center(
                  child: Text(
                    'MAP',
                    style: TextStyle(color: Colors.white, fontSize: 24),
                  ),
                ),
              ),

              // Draggable BottomSheet
              DraggableScrollableSheet(
                snap: true,
                initialChildSize: 0.4,
                minChildSize: 0.2,
                maxChildSize: 0.8,
                builder: (context, scrollController) {
                  return FutureBuilder<List<Listing>>(
                    future: fetchFilteredListings(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      } else if (snapshot.hasError) {
                        return Center(child: Text('Error: ${snapshot.error}'));
                      } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return const Center(child: Text('No listings found'));
                      }

                      // apply client-side price filtering
                      final allListings = snapshot.data!;
                      final double? minPrice =
                          widget.filters['min_price'] != null
                              ? double.tryParse(
                                widget.filters['min_price'].toString(),
                              )
                              : null;
                      final double? maxPrice =
                          widget.filters['max_price'] != null
                              ? double.tryParse(
                                widget.filters['max_price'].toString(),
                              )
                              : null;
                      final listings =
                          allListings.where((listing) {
                            if (minPrice != null && listing.price < minPrice)
                              return false;
                            if (maxPrice != null && listing.price > maxPrice)
                              return false;
                            return true;
                          }).toList();

                      return Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.vertical(
                            top: Radius.circular(20),
                          ),
                          boxShadow: [
                            BoxShadow(color: Colors.black26, blurRadius: 10),
                          ],
                        ),
                        child: ListView.builder(
                          controller: scrollController,
                          itemCount: listings.length,
                          itemBuilder: (context, index) {
                            return TinyHomeCard(
                              listing: listings[index].toJson(),
                            );
                          },
                        ),
                      );
                    },
                  );
                },
              ),
            ],
          );
        },
      ),
    );
  }
}
