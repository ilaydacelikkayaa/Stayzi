import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stayzi_ui/screens/onboard/notification_screen.dart';
import 'package:stayzi_ui/screens/onboard/onboard_screen.dart';
import 'package:stayzi_ui/screens/onboard/widgets/basic_button.dart';
import 'package:stayzi_ui/screens/onboard/widgets/form_widget.dart';
import 'package:stayzi_ui/services/api_constants.dart';
import 'package:stayzi_ui/services/api_service.dart';
import 'package:stayzi_ui/services/storage_service.dart';

class GetInfoScreen extends StatefulWidget {
  final String? phone;
  final String? country;
  final String? email;

  const GetInfoScreen({super.key, this.phone, this.country, this.email});

  @override
  State<GetInfoScreen> createState() => _GetInfoScreenState();
}

class _GetInfoScreenState extends State<GetInfoScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isButtonEnabled = false;

  final Map<String, TextEditingController> _controllers = {
    'firstName': TextEditingController(),
    'lastName': TextEditingController(),
    'birthday': TextEditingController(),
    'email': TextEditingController(),
    'password': TextEditingController(),
  };

  Future<void> registerUser() async {
    // Ensure phone is in standardized format
    final standardizedPhone = widget.phone ?? '';
    print("📱 Registering with phone: $standardizedPhone");
    
    final response = await http.post(
      Uri.parse('${ApiConstants.baseUrl}/users/register-phone'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        "name": _controllers['firstName']!.text.trim(),
        "surname": _controllers['lastName']!.text.trim(),
        "birthdate": _controllers['birthday']!.text.trim(),
        "phone": standardizedPhone,
        "email": _controllers['email']!.text.trim(),
        "password": _controllers['password']!.text.trim(),
        "country": widget.country,
      }),
    );

    if (response.statusCode == 201 || response.statusCode == 200) {
      print("✅ Kullanıcı başarıyla kaydedildi.");

      // Giriş yap ve token al
      final token = await ApiService().loginWithPhone(
        standardizedPhone,
        _controllers['password']!.text.trim(),
      );

      // Token'ı API service'e set et
      ApiService().setAuthToken(token.accessToken);

      // Token'ı StorageService ile kaydet
      await StorageService().saveToken(token);

      // ✅ Şifreyi de kaydet
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_password', _controllers['password']!.text.trim());
      
      // ✅ Standardized phone'u da kaydet
      await prefs.setString('user_phone', standardizedPhone);

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => NotificationScreen()),
      );
    } else {
      print("❌ Kayıt başarısız: ${response.body}");
      
      // Check for specific error messages
      try {
        final errorData = jsonDecode(response.body);
        if (errorData['detail'] == "Phone already registered") {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                "Bu telefon numarası zaten kayıtlı. Lütfen giriş yapın.",
              ),
              duration: Duration(seconds: 4),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                "Kayıt sırasında hata oluştu: ${errorData['detail'] ?? 'Bilinmeyen hata'}",
              ),
            ),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Kayıt sırasında hata oluştu.")));
      }
    }
  }

  void _checkFormValid() {
    setState(() {
      _isButtonEnabled = _controllers.values.every(
        (controller) => controller.text.isNotEmpty,
      );
    });
  }

  @override
  void initState() {
    super.initState();
    for (var controller in _controllers.values) {
      controller.addListener(_checkFormValid);
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    print(
      "Phone: ${widget.phone}, Country: ${widget.country}, Email: ${widget.email}",
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(), // ihtiyac olmadigi icin yorum satırına alindi
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Form(
              key: _formKey,
              child: Column(
                //mainAxisAlignment: MainAxisAlignment.center, // yapi korunmak istenmezse dahil edilebilir.
                children: [
                  Row(
                    children: [
                      IconButton(
                        onPressed: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => OnboardScreen(),
                            ),
                          );
                        },
                        icon: Icon(Icons.cancel),
                        padding: EdgeInsets.only(left: 12),
                      ),
                      SizedBox(width: 50),
                      Text(
                        'Finish signing up',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                  Divider(),
                  SizedBox(height: 30),
                  SizedBox(
                    width: 342,
                    //height: 120,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: EdgeInsets.only(bottom: 12),
                          child: Text(
                            'Legal Name',
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                        ),
                        FormWidget(
                          controller: _controllers['firstName'],
                          hintText: 'First Name',
                          keyboardType: TextInputType.name,
                          textInputAction: TextInputAction.next,
                        ),
                        SizedBox(height: 0.3),
                        FormWidget(
                          controller: _controllers['lastName'],
                          helperText:
                              'Make sure this matches the name on your goverment ID.',
                          hintText: 'Last Name',
                          keyboardType: TextInputType.name,
                          textInputAction: TextInputAction.next,
                        ),
                        SizedBox(height: 12),
                        Padding(
                          padding: EdgeInsets.only(bottom: 12),
                          child: Text(
                            'Date of Birth',
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: () async {
                            DateTime? picked = await showDatePicker(
                              context: context,
                              initialDate: DateTime(2000),
                              firstDate: DateTime(1900),
                              lastDate: DateTime.now().subtract(
                                Duration(days: 365 * 18),
                              ),
                            );
                            if (picked != null) {
                              _controllers['birthday']!.text =
                                  "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
                            }
                          },
                          child: AbsorbPointer(
                            child: FormWidget(
                              readOnly: true,
                              controller: _controllers['birthday'],
                              helperText:
                                  'To sign up, you need to be at least 18. Your birthday wont be shared with other people who use Stayzi.',
                              hintText: 'Birthday (mm/dd/yyyy)',
                              keyboardType: TextInputType.datetime,
                              textInputAction: TextInputAction.next,
                            ),
                          ),
                        ),
                        SizedBox(height: 12),
                        Padding(
                          padding: EdgeInsets.only(bottom: 12),
                          child: Text(
                            'Email',
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                        ),
                        FormWidget(
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                          controller: _controllers['email'],
                          helperText:
                              'We will email you trip confirmations and receipts.',
                          hintText: 'Email',
                          keyboardType: TextInputType.emailAddress,
                          textInputAction: TextInputAction.next,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Email is required';
                            }
                            final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
                            if (!emailRegex.hasMatch(value)) {
                              return 'Enter a valid email';
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: 12),
                        Padding(
                          padding: EdgeInsets.only(bottom: 12),
                          child: Text(
                            'Password',
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                        ),
                        FormWidget(
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                          obscureText: true,
                          controller: _controllers['password'],
                          hintText: 'Password',
                          keyboardType: TextInputType.visiblePassword,
                          textInputAction: TextInputAction.done,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Password is required';
                            }
                            if (value.length < 8) {
                              return 'Password must be at least 8 characters';
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: 40),
                        SizedBox(
                          width: 350,
                          child: ElevatedButtonWidget(
                            onPressed:
                                _isButtonEnabled
                                    ? () async {
                                      if (_formKey.currentState!.validate()) {
                                        await registerUser();
                                      }
                                    }
                                    : null,
                            buttonText: 'Agree and Continue',
                            buttonColor: Colors.black,
                            textColor: Colors.white,
                            elevation: 10,
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
      ),
    );
  }
}
