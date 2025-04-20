import 'package:flutter/material.dart';
import 'package:stayzi_ui/screens/search/general_filtered_sheet.dart';
import 'package:stayzi_ui/screens/search/search_screen.dart';

class FilteredScreen extends StatefulWidget {
  const FilteredScreen({super.key});

  @override
  State<FilteredScreen> createState() => _FilteredScreenState();
}

class _FilteredScreenState extends State<FilteredScreen> {
  double _mapHeightFraction = 0.6;

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
                  return NotificationListener<DraggableScrollableNotification>(
                    //
                    onNotification: (notification) {
                      setState(() {
                        _mapHeightFraction =
                            1 -
                            notification
                                .extent; //notification.extent ile harita yüksekligini güncelliyoruz
                      });
                      return true;
                    },
                    child: Container(
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
                        itemCount: 10, // İlan sayısı
                        itemBuilder: (context, index) => TinyHomeCard(),
                      ),
                    ),
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
