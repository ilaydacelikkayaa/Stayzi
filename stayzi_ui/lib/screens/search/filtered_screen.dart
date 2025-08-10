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
        if (widget.filters['home_type'] != null)
          'home_type': widget.filters['home_type'].toString(),
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
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Filtrelenmiş Sonuçlar',
          style: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        centerTitle: true,
        actions: [
          Padding(
            padding: EdgeInsets.only(right: 15),
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
              icon: Icon(Icons.filter_list, color: Colors.black),
            ),
          ),
        ],
      ),
      body: FutureBuilder<List<Listing>>(
        future: fetchFilteredListings(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text(
                'Sonuç bulunamadı',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey,
                ),
              ),
            );
          }

          final allListings = snapshot.data!;
          final double? minPrice =
              widget.filters['min_price'] != null
                  ? double.tryParse(widget.filters['min_price'].toString())
                  : null;
          final double? maxPrice =
              widget.filters['max_price'] != null
                  ? double.tryParse(widget.filters['max_price'].toString())
                  : null;

          final listings =
              allListings.where((listing) {
                if (minPrice != null && listing.price < minPrice) return false;
                if (maxPrice != null && listing.price > maxPrice) return false;
                if (widget.filters['home_type'] != null &&
                    listing.homeType?.toLowerCase() !=
                        widget.filters['home_type'].toString().toLowerCase()) {
                  return false;
                }
                return true;
              }).toList();

          return ListView.builder(
            itemCount: listings.length,
            itemBuilder: (context, index) {
              return TinyHomeCard(listing: listings[index].toJson());
            },
          );
        },
      ),
    );
  }
}
