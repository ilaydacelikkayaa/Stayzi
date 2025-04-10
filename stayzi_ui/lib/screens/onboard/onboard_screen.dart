import 'package:flutter/material.dart';
import 'package:stayzi_ui/screens/onboard/get_info_screen.dart';
import 'package:stayzi_ui/screens/onboard/mail_login_sheet.dart';
import 'package:stayzi_ui/screens/onboard/widgets/basic_button.dart';
import 'package:stayzi_ui/screens/onboard/widgets/divider_widget.dart';
import 'package:stayzi_ui/screens/onboard/widgets/form_widget.dart';

class OnboardScreen extends StatefulWidget {
  const OnboardScreen({super.key});

  @override
  State<OnboardScreen> createState() => _OnboardScreenState();
}

class _OnboardScreenState extends State<OnboardScreen> {
  // TextEditingController'lar, form elemanlarının değerlerini almak için kullanılır.
  // Burada aynı zamanda value girilmeden butonun aktif olmamasını sağlamak icin kullanıldı.
  bool _isButtonEnabled = false;
  final TextEditingController _textEditingController1 = TextEditingController();
  final TextEditingController _textEditingController2 = TextEditingController();

  @override
  void dispose() {
    _textEditingController1.dispose();
    _textEditingController2.dispose();
    super.dispose();
  }

  void _checkFormValid() {
    setState(() {
      _isButtonEnabled =
          _textEditingController1.text.isNotEmpty &&
          _textEditingController2.text.isNotEmpty;
    });
  }

  @override
  void initState() {
    super.initState();
    _textEditingController1.addListener(_checkFormValid);
    _textEditingController2.addListener(_checkFormValid);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Text(
              textAlign: TextAlign.start,
              'Log in or Sign up to Stayzi',
              style: TextStyle(
                fontSize: 21,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            //Divider(color: Colors.grey),
            SizedBox(height: 20),
            //FormWidget, Text ve Buton'u bir arada tutan SizedBox
            SizedBox(
              width: 350,
              child: Column(
                children: [
                  FormWidget(
                    controller: _textEditingController1,
                    hintText: 'Country/Region',
                    textInputAction: TextInputAction.next,
                  ),
                  FormWidget(
                    controller: _textEditingController2,
                    hintText: 'Phone Number',
                    textInputAction: TextInputAction.done,
                    keyboardType: TextInputType.phone,
                  ),
                  SizedBox(height: 20),
                  Text(
                    'We will call or text to confirm your number.',

                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  SizedBox(height: 20),
                  SizedBox(
                    width: 350,
                    child: ElevatedButtonWidget(
                      elevation: 10,
                      onPressed:
                          _isButtonEnabled
                              ? () {
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => GetInfoScreen(),
                                  ),
                                );
                              }
                              : null,
                      buttonText: 'Continue',
                      buttonColor: const Color.fromRGBO(213, 56, 88, 1),
                      textColor: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),
            DividerWidget(),
            const SizedBox(height: 30),
            SizedBox(
              width: 350,
              child: ElevatedButtonWidget(
                elevation: 10,
                onPressed: () {
                  showModalBottomSheet(
                    enableDrag: true,
                    context: context,
                    isScrollControlled: true, // Tam ekran gibi olsun
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(25),
                      ),
                    ),
                    builder: (context) => MailLogInSheet(),
                  );
                },
                buttonText: 'Continue with Email',
                buttonColor: Colors.white,
                textColor: Colors.black,
                icon: Icon(Icons.email_outlined),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
