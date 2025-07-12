import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:stayzi_ui/screens/search/general_filtered_sheet.dart';
import 'package:stayzi_ui/screens/search/search_screen.dart';

class FilteredScreen extends StatefulWidget {
  const FilteredScreen({super.key});

  @override
  State<FilteredScreen> createState() => _FilteredScreenState();
}

class _FilteredScreenState extends State<FilteredScreen> {
  final double _mapHeightFraction = 0.6;

  Future<List<dynamic>> fetchListings() async {
    final response = await http.get(
      Uri.parse('http://localhost:8000/listings/'),
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
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text("Filtered results"),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 15),
            child: IconButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => GeneralFilteredSheet(),
                  ),
                );
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
                  return FutureBuilder<List<dynamic>>(
                    future: fetchListings(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      } else if (snapshot.hasError) {
                        return Center(child: Text('Error: ${snapshot.error}'));
                      } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return const Center(child: Text('No listings found'));
                      }

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
                          itemCount: snapshot.data!.length,
                          itemBuilder: (context, index) {
                            return TinyHomeCard(listing: snapshot.data![index]);
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
