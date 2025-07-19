import 'package:flutter/material.dart';
import 'package:stayzi_ui/screens/onboard/widgets/basic_button.dart'; // for ElevatedButtonWidget
import 'package:stayzi_ui/screens/onboard/widgets/form_widget.dart';
import 'package:stayzi_ui/screens/search/date_time_picker.dart';
import 'package:stayzi_ui/screens/search/filtered_screen.dart';

class SearchFilterScreen extends StatefulWidget {
  const SearchFilterScreen({super.key});

  @override
  State<SearchFilterScreen> createState() => _SearchFilterScreenState();
}

class _SearchFilterScreenState extends State<SearchFilterScreen> {
  final TextEditingController _destinationController = TextEditingController();
  final FocusNode _destinationFocusNode = FocusNode();

  DateTimeRange? _selectedDateRange;

  int _adults = 0;
  int _children = 0;
  int _infants = 0;
  int _pets = 0;

  double? _minPrice;
  double? _maxPrice;

  String? _dateSummary;

  @override
  void initState() {
    super.initState();
    // Set focus to destination input when screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      FocusScope.of(context).requestFocus(_destinationFocusNode);
    });
  }

  void _clearAll() {
    setState(() {
      _destinationController.clear();
      _selectedDateRange = null;
      _dateSummary = null;
      _adults = 0;
      _children = 0;
      _infants = 0;
      _pets = 0;
    });
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('All filters cleared')));
    FocusScope.of(context).requestFocus(_destinationFocusNode);
  }

  bool get _hasGuestsSelected => _adults + _children + _infants + _pets > 0;

  void _onSearch() {
    if (_destinationController.text.trim().isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Please enter a destination')));
      FocusScope.of(context).requestFocus(_destinationFocusNode);
      return;
    }

    if (!_hasGuestsSelected) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please select at least one guest')),
      );
      return;
    }

    final filters = {
      "location": _destinationController.text.trim(),
      "guests": _adults + _children + _infants + _pets,
      "start_date": _selectedDateRange?.start.toIso8601String(),
      "end_date": _selectedDateRange?.end.toIso8601String(),
      "min_price": _minPrice?.toString(), // ekle
      "max_price": _maxPrice?.toString(),
    };

    print("Applied Filters: $filters");

    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => FilteredScreen(filters: filters)),
    );
  }

  void _onDateRangeChanged(DateTimeRange? newRange) {
    setState(() {
      _selectedDateRange = newRange;
      if (newRange != null) {
        _dateSummary =
            '${newRange.start.month}/${newRange.start.day}/${newRange.start.year} - ${newRange.end.month}/${newRange.end.day}/${newRange.end.year}';
      } else {
        _dateSummary = null;
      }
    });
  }

  void _onGuestCountChanged(String category, int count) {
    setState(() {
      switch (category) {
        case 'Adults':
          _adults = count;
          break;
        case 'Children':
          _children = count;
          break;
        case 'Infants':
          _infants = count;
          break;
        case 'Pets':
          _pets = count;
          break;
      }
    });
  }

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
        elevation: 0,
      ),
      body: SingleChildScrollView(
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        child: Center(
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: MediaQuery.of(context).size.width * 0.05,
              vertical: 16,
            ),
            child: Column(
              children: [
                CustomCardWidget(
                  labelText: 'Where to?',
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: FormWidget(
                      hintText: 'Search Destinations',
                      controller: _destinationController,
                      focusNode: _destinationFocusNode,
                    ),
                  ),
                ),
                CustomCardWidget(
                  labelText: 'When is your trips?',
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        DateRangePickerWidget(
                          initialDateRange: _selectedDateRange,
                          onDateRangeChanged: _onDateRangeChanged,
                        ),
                        if (_dateSummary != null) ...[
                          SizedBox(height: 8),
                          Text(
                            'Selected dates: $_dateSummary',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                CustomCardWidget(
                  labelText: 'Who is coming?',
                  child: GuestSelector(
                    adults: _adults,
                    children: _children,
                    infants: _infants,
                    pets: _pets,
                    onGuestCountChanged: _onGuestCountChanged,
                  ),
                ),
                //En altta yer alan butonlar
                Padding(
                  padding: const EdgeInsets.all(10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      TextButton(
                        onPressed: _clearAll,
                        child: Text(
                          'Clear all',
                          style: TextStyle(
                            color: Colors.black,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                      SizedBox(
                        width: MediaQuery.of(context).size.width * 0.5,
                        child: ElevatedButtonWidget(
                          elevation: 8,
                          buttonText: 'Search',
                          buttonColor: Color.fromRGBO(213, 56, 61, 1),
                          textColor: Colors.white,
                          onPressed: _onSearch,
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

class CustomCardWidget extends StatelessWidget {
  const CustomCardWidget({
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
            padding: EdgeInsets.only(
              top: 20,
              left: MediaQuery.of(context).size.width * 0.03,
              bottom: 0,
            ),
            child: Text(
              labelText,
              style: TextStyle(
                fontSize: MediaQuery.of(context).size.width * 0.06,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Padding(padding: const EdgeInsets.all(16.0), child: child),
        ],
      ),
    );
  }
}

//Misafir seçmek icin kullanılan widget
class GuestSelector extends StatelessWidget {
  final int adults;
  final int children;
  final int infants;
  final int pets;
  final Function(String category, int count) onGuestCountChanged;

  final categories = [
    {'label': 'Adults', 'subLabel': 'Ages 13 or above'},
    {'label': 'Children', 'subLabel': 'Ages 2 – 12'},
    {'label': 'Infants', 'subLabel': 'Under 2'},
    {'label': 'Pets', 'subLabel': 'Bringing a service animal?'},
  ];

  GuestSelector({
    super.key,
    required this.adults,
    required this.children,
    required this.infants,
    required this.pets,
    required this.onGuestCountChanged,
  });

  int _getCountByLabel(String label) {
    switch (label) {
      case 'Adults':
        return adults;
      case 'Children':
        return children;
      case 'Infants':
        return infants;
      case 'Pets':
        return pets;
      default:
        return 0;
    }
  }

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
              final label = category['label']!;
              final subLabel = category['subLabel']!;
              return CategoryRow(
                label: label,
                subLabel: subLabel,
                count: _getCountByLabel(label),
                onCountChanged:
                    (newCount) => onGuestCountChanged(label, newCount),
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

class CategoryRow extends StatelessWidget {
  final String label;
  final String subLabel;
  final int count;
  final ValueChanged<int> onCountChanged;

  const CategoryRow({
    super.key,
    required this.label,
    required this.subLabel,
    required this.count,
    required this.onCountChanged,
  });

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
                Text(label, style: TextStyle(fontSize: 16)),
                SizedBox(height: 4),
                Text(
                  subLabel,
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
                  if (count > 0) {
                    onCountChanged(count - 1);
                  }
                },
              ),
              Text('$count', style: TextStyle(fontSize: 16)),
              IconButton(
                icon: Icon(Icons.add_circle_outline),
                onPressed: () {
                  onCountChanged(count + 1);
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}
