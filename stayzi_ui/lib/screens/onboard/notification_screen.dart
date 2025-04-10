import 'package:flutter/material.dart';
import 'package:stayzi_ui/screens/navigation/bottom_nav.dart';
import 'package:stayzi_ui/screens/onboard/widgets/basic_button.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  bool _isChecked = true;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          children: [
            Text(
              'Turn on notifications',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 40,
                fontWeight: FontWeight.bold,
                //decoration: TextDecoration.underline,
              ),
            ),
            SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Text(
                'Dont miss important messages like check-in details and account activity.',
                style: TextStyle(
                  fontSize: 18,
                  color: const Color.fromARGB(255, 124, 124, 124),
                ),
                textAlign: TextAlign.center,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Image.asset(
                'assets/images/notification.png',
                width: 200,
                //height: 300,
              ),
            ),
            SizedBox(height: 20),
            Container(
              width: 350,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color.fromRGBO(221, 221, 221, 0.4),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.transparent, width: 1),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      textAlign: TextAlign.start,
                      'Get travel deals, personalized recommendations, and more.',
                      style: TextStyle(fontSize: 16),
                      maxLines: 2,
                    ),
                  ),
                  Switch(
                    value: _isChecked,
                    onChanged: (bool? value) {
                      setState(() {
                        _isChecked = value!;
                      });
                    },
                    activeColor: Colors.white,
                    inactiveTrackColor: Colors.grey,
                    activeTrackColor: Colors.black,
                    thumbIcon: WidgetStateProperty.all(
                      const Icon(Icons.notifications, color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 20),
            SizedBox(
              width: 350,
              child: ElevatedButtonWidget(
                elevation: 10,
                buttonText: 'Yes, notify me',
                buttonColor: Colors.black,
                textColor: _isChecked ? Colors.white : Colors.grey,
                onPressed:
                    _isChecked
                        ? () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder:
                                  (context) => const BottomNavigationWidget(),
                            ),
                          );
                        }
                        : null,
              ),
            ),
            SizedBox(height: 20),
            SizedBox(
              width: 350,
              child: ElevatedButtonWidget(
                elevation: 0,
                buttonText: 'Skip',
                buttonColor: Colors.transparent,
                textColor: Colors.black,
                onPressed:
                    !_isChecked
                        ? () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder:
                                  (context) => const BottomNavigationWidget(),
                            ),
                          );
                        }
                        : null,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
