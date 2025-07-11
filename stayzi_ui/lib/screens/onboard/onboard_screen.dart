import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:stayzi_ui/screens/onboard/get_info_screen.dart';
import 'package:stayzi_ui/screens/onboard/mail_login_sheet.dart';
import 'package:stayzi_ui/screens/onboard/widgets/basic_button.dart';
import 'package:stayzi_ui/screens/onboard/widgets/divider_widget.dart';
import 'package:stayzi_ui/screens/onboard/widgets/form_widget.dart';
import 'package:stayzi_ui/services/api_constants.dart';

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

  Future<bool> checkPhoneExists(String phone) async {
    final response = await http.get(
      Uri.parse('${ApiConstants.baseUrl}/users/phone-exists/$phone'),
    );
    if (response.statusCode == 200) {
      final result = jsonDecode(response.body);
      return result['exists'];
    } else {
      throw Exception('Failed to check phone existence');
    }
  }

  Future<bool> checkEmailExists(String email) async {
    final response = await http.get(
      Uri.parse('${ApiConstants.baseUrl}/users/email-exists/$email'),
    );
    if (response.statusCode == 200) {
      final result = jsonDecode(response.body);
      return result['exists'];
    } else {
      throw Exception('Failed to check email existence');
    }
  }

  void _checkFormValid() {
    setState(() {
      _isButtonEnabled =
          _textEditingController1.text.isNotEmpty &&
          _textEditingController2.text.isNotEmpty;
    });
  }

  @override
  void dispose() {
    _textEditingController1.dispose();
    _textEditingController2.dispose();
    super.dispose();
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
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(
                        10,
                      ), // 10 haneli telefon numarası
                    ],
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
                              ? () async {
                                final phone =
                                    _textEditingController2.text.trim();
                                final country =
                                    _textEditingController1.text.trim();
                                final exists = await checkPhoneExists(phone);
                                if (exists) {
                                  Navigator.pushReplacementNamed(
                                    context,
                                    '/home',
                                  );
                                } else {
                                  Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                      builder:
                                          (context) => GetInfoScreen(
                                            phone: phone,
                                            country: country,
                                          ),
                                    ),
                                  );
                                }
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
