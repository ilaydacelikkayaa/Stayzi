import 'package:flutter/material.dart';
import 'package:stayzi_ui/screens/onboard/widgets/basic_button.dart';
import 'package:stayzi_ui/screens/onboard/widgets/form_widget.dart';
import 'package:stayzi_ui/screens/search/date_time_picker.dart';
import 'package:stayzi_ui/screens/search/filtered_screen.dart';

class SearchFilterScreen extends StatefulWidget {
  const SearchFilterScreen({super.key});

  @override
  State<SearchFilterScreen> createState() => _SearchFilterScreenState();
}

class _SearchFilterScreenState extends State<SearchFilterScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_sharp),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        title: Text('Search Filter'),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(19),
            child: Column(
              children: [
                customCardWidget(
                  labelText: 'Where to?',
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: FormWidget(hintText: 'Search Destinations'),
                  ),
                ),
                customCardWidget(
                  labelText: 'When is your trips?',
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: DateRangePickerWidget(),
                  ),
                ),
                customCardWidget(
                  labelText: 'Who is coming?',
                  child: GuestSelector(),
                ),
                //En altta yer alan butonlar
                Padding(
                  padding: const EdgeInsets.all(10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      TextButton(
                        onPressed: () {},
                        child: Text(
                          'Clear all',
                          style: TextStyle(
                            color: Colors.black,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                      SizedBox(
                        width: 200,
                        child: ElevatedButtonWidget(
                          elevation: 8,
                          buttonText: 'Search',
                          buttonColor: Color.fromRGBO(213, 56, 88, 1),
                          textColor: Colors.white,
                          onPressed: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => FilteredScreen(),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class customCardWidget extends StatelessWidget {
  const customCardWidget({
    super.key,
    required this.labelText,
    required this.child,
  });

  final String labelText;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 8,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 20, left: 10, bottom: 0),
            child: Text(
              labelText,
              style: TextStyle(fontSize: 27, fontWeight: FontWeight.bold),
            ),
          ),
          child,
        ],
      ),
    );
  }
}

//Misafir seçmek icin kullanılan widget
class GuestSelector extends StatelessWidget {
  final categories = [
    {'label': 'Adults', 'subLabel': 'Ages 13 or above'},
    {'label': 'Children', 'subLabel': 'Ages 2 – 12'},
    {'label': 'Infants', 'subLabel': 'Under 2'},
    {'label': 'Pets', 'subLabel': 'Bringing a service animal?'},
  ];

  GuestSelector({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      //padding: EdgeInsets.all(5),
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      decoration: BoxDecoration(
        //color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          //SizedBox(height: 16),
          ...List.generate(categories.length * 2 - 1, (index) {
            if (index.isEven) {
              final category = categories[index ~/ 2];
              return CategoryRow(
                label: category['label']!,
                subLabel: category['subLabel']!,
              );
            } else {
              return Divider(thickness: 1, height: 24);
            }
          }),
        ],
      ),
    );
  }
}

class CategoryRow extends StatefulWidget {
  final String label;
  final String subLabel;

  const CategoryRow({super.key, required this.label, required this.subLabel});

  @override
  _CategoryRowState createState() => _CategoryRowState();
}

class _CategoryRowState extends State<CategoryRow> {
  int count = 0;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(widget.label, style: TextStyle(fontSize: 16)),
                SizedBox(height: 4),
                Text(
                  widget.subLabel,
                  style: TextStyle(color: Colors.grey[600], fontSize: 14),
                ),
              ],
            ),
          ),
          SizedBox(width: 16),
          Row(
            children: [
              IconButton(
                icon: Icon(Icons.remove_circle_outline),
                onPressed: () {
                  setState(() {
                    if (count > 0) count--;
                  });
                },
              ),
              Text('$count', style: TextStyle(fontSize: 16)),
              IconButton(
                icon: Icon(Icons.add_circle_outline),
                onPressed: () {
                  setState(() {
                    count++;
                  });
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}
