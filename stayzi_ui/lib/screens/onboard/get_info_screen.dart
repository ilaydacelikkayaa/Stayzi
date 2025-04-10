import 'package:flutter/material.dart';
import 'package:stayzi_ui/screens/onboard/notification_screen.dart';
import 'package:stayzi_ui/screens/onboard/onboard_screen.dart';
import 'package:stayzi_ui/screens/onboard/widgets/basic_button.dart';
import 'package:stayzi_ui/screens/onboard/widgets/form_widget.dart';

class GetInfoScreen extends StatefulWidget {
  const GetInfoScreen({super.key});

  @override
  State<GetInfoScreen> createState() => _GetInfoScreenState();
}

class _GetInfoScreenState extends State<GetInfoScreen> {
  bool _isButtonEnabled = false;

  final Map<String, TextEditingController> _controllers = {
    'firstName': TextEditingController(),
    'lastName': TextEditingController(),
    'birthday': TextEditingController(),
    'email': TextEditingController(),
    'password': TextEditingController(),
  };

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
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(), // ihtiyac olmadigi icin yorum satırına alindi
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
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
                      FormWidget(
                        controller: _controllers['birthday'],
                        helperText:
                            'To sign up, you need to be at least 18. Your birthday wont be shared with other people who use Stayzi.',
                        hintText: 'Birthday (mm/dd/yyyy)',
                        keyboardType: TextInputType.datetime,
                        textInputAction: TextInputAction.next,
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
                        controller: _controllers['email'],
                        helperText:
                            'We will email you trip confirmations and receipts.',
                        hintText: 'Email',
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.next,
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
                        obscureText: true,
                        controller: _controllers['password'],
                        hintText: 'Password',
                        keyboardType: TextInputType.visiblePassword,
                        textInputAction: TextInputAction.done,
                      ),
                      SizedBox(height: 40),
                      SizedBox(
                        width: 350,
                        child: ElevatedButtonWidget(
                          onPressed:
                              _isButtonEnabled
                                  ? () {
                                    Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(
                                        builder:
                                            (context) => NotificationScreen(),
                                      ),
                                    );
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
    );
  }
}
