import 'package:flutter/material.dart';
import 'package:stayzi_ui/screens/onboard/widgets/basic_button.dart';
import 'package:stayzi_ui/screens/search/filtered_screen.dart';

class GeneralFilteredSheet extends StatefulWidget {
  final Map<String, dynamic> filters;

  const GeneralFilteredSheet({super.key, required this.filters});

  @override
  State<GeneralFilteredSheet> createState() => _GeneralFilteredSheetState();
}

class _GeneralFilteredSheetState extends State<GeneralFilteredSheet> {
  List<bool> isSelected = [false, false, false, false];

  RangeValues _priceRange = const RangeValues(1000, 100000);

  bool isTurkishSelected = false;
  bool isEnglishSelected = false;
  bool isFrenchSelected = false;
  bool isGermanSelected = false;
  bool isSpanishSelected = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Filters"),
        leading: IconButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          icon: Icon(Icons.cancel_outlined),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Divider(
              thickness: 1,
              color: Colors.grey,
              endIndent: 20,
              indent: 20,
            ),

            /// Yer Türü Başlık
            Padding(
              padding: const EdgeInsets.only(top: 15, left: 40),
              child: Text(
                'Place Type',
                style: TextStyle(fontSize: 23, fontWeight: FontWeight.bold),
              ),
            ),

            /// Toggle Butonlar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 30),
              child: ToggleButtons(
                isSelected: isSelected,
                onPressed: (int index) {
                  setState(() {
                    isSelected[index] = !isSelected[index];
                  });
                },
                borderRadius: BorderRadius.circular(10),
                selectedColor: Colors.white,
                fillColor: Colors.black,
                borderColor: Colors.black,
                color: Colors.black,
                borderWidth: 2,
                children: [
                  SizedBox(
                    height: 80,
                    width: 80,
                    child: Icon(Icons.house, size: 40),
                  ),
                  SizedBox(
                    height: 80,
                    width: 80,
                    child: Icon(Icons.apartment, size: 40),
                  ),
                  SizedBox(
                    height: 80,
                    width: 80,
                    child: Icon(Icons.holiday_village_rounded, size: 40),
                  ),
                  SizedBox(
                    height: 80,
                    width: 80,
                    child: Icon(Icons.other_houses_rounded, size: 40),
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

            /// Fiyat Aralığı Başlık
            Padding(
              padding: const EdgeInsets.only(top: 15, left: 40),
              child: Text(
                'Price Range',
                style: TextStyle(fontSize: 23, fontWeight: FontWeight.bold),
              ),
            ),

            /// Range Slider
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: Column(
                children: [
                  RangeSlider(
                    activeColor: Colors.black,
                    inactiveColor: Colors.grey,
                    values: _priceRange,
                    min: 0,
                    max: 100000,
                    divisions: 100,
                    labels: RangeLabels(
                      '₺${_priceRange.start.round()}',
                      '₺${_priceRange.end.round()}',
                    ),
                    onChanged: (RangeValues values) {
                      setState(() {
                        _priceRange = values;
                      });
                    },
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text('Min: ₺${_priceRange.start.round()}'),
                        ),
                      ),
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text('Max: ₺${_priceRange.end.round()}'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(height: 20),
            Divider(
              thickness: 1,
              color: Colors.grey,
              endIndent: 20,
              indent: 20,
            ),
            // build metodundaki checkbox kısmı (sadece bu kısmı güncelle)
            Padding(
              padding: const EdgeInsets.only(top: 15, left: 40),
              child: Text(
                'Host Language',
                style: TextStyle(fontSize: 23, fontWeight: FontWeight.bold),
              ),
            ),
            Column(
              children: [
                buildLanguageCheckbox("Turkish", isTurkishSelected, (val) {
                  setState(() => isTurkishSelected = val!);
                }),
                buildLanguageCheckbox("English", isEnglishSelected, (val) {
                  setState(() => isEnglishSelected = val!);
                }),
                buildLanguageCheckbox("French", isFrenchSelected, (val) {
                  setState(() => isFrenchSelected = val!);
                }),
                buildLanguageCheckbox("German", isGermanSelected, (val) {
                  setState(() => isGermanSelected = val!);
                }),
                buildLanguageCheckbox("Spanish", isSpanishSelected, (val) {
                  setState(() => isSpanishSelected = val!);
                }),
              ],
            ),
            SizedBox(height: 20),

            Center(
              child: SizedBox(
                width: 200,
                child: ElevatedButtonWidget(
                  elevation: 8,
                  buttonText: 'Save & Continue',
                  buttonColor: Colors.black,
                  textColor: Colors.white,
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder:
                            (context) =>
                                FilteredScreen(filters: widget.filters),
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// checkbox icin widget bu sayede başk dilleri de kolayca ekleriz
Widget buildLanguageCheckbox(
  String label,
  bool value,
  ValueChanged<bool?> onChanged,
) {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 8),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(fontSize: 18)),
        Checkbox(
          value: value,
          onChanged: onChanged,
          activeColor: Colors.black,
          checkColor: Colors.white,
        ),
      ],
    ),
  );
}
