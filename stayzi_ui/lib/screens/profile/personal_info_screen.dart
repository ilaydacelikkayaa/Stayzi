import 'package:flutter/material.dart';

class PersonalInfoScreen extends StatefulWidget {
  const PersonalInfoScreen({super.key});

  @override
  _PersonalInfoScreenState createState() => _PersonalInfoScreenState();
}

class _PersonalInfoScreenState extends State<PersonalInfoScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _preferredNameController =
      TextEditingController();
  final TextEditingController _phoneNumberController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();

  bool _isFullNameEditable = false;
  bool _isPreferredNameEditable = false;
  bool _isPhoneNumberEditable = false;
  bool _isEmailEditable = false;
  bool _isAddressEditable = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 255, 255, 255),
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      backgroundColor: const Color.fromARGB(255, 255, 255, 255),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Kişisel bilgiler',
              style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.bold,
                color: Color.fromARGB(255, 0, 0, 0),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: Form(
                key: _formKey,
                child: ListView(
                  children: [
                    const SizedBox(height: 20),
                    _buildEditableTextField(
                      label: 'Yasal Ad',
                      controller: _fullNameController,
                      hint: 'Ahmet Koca',
                      isEditable: _isFullNameEditable,
                      onEditPressed: () {
                        setState(() {
                          _isFullNameEditable = !_isFullNameEditable;
                        });
                      },
                    ),
                    const Divider(color: Colors.grey),
                    const SizedBox(height: 15),

                    _buildEditableTextField(
                      label: 'Tercih Edilen Ad',
                      controller: _preferredNameController,
                      hint: 'Ahmet',
                      isEditable: _isPreferredNameEditable,
                      onEditPressed: () {
                        setState(() {
                          _isPreferredNameEditable = !_isPreferredNameEditable;
                        });
                      },
                    ),
                    const Divider(color: Colors.grey),
                    const SizedBox(height: 15),

                    _buildEditableTextField(
                      label: 'Telefon Numarası',
                      controller: _phoneNumberController,
                      hint: '+90 555 123 45 67',
                      isEditable: _isPhoneNumberEditable,
                      onEditPressed: () {
                        setState(() {
                          _isPhoneNumberEditable = !_isPhoneNumberEditable;
                        });
                      },
                    ),
                    const Divider(color: Colors.grey),
                    const SizedBox(height: 15),

                    _buildEditableTextField(
                      label: 'E-posta',
                      controller: _emailController,
                      hint: 'ahmet.koca@example.com',
                      isEditable: _isEmailEditable,
                      onEditPressed: () {
                        setState(() {
                          _isEmailEditable = !_isEmailEditable;
                        });
                      },
                    ),
                    const Divider(color: Colors.grey),
                    const SizedBox(height: 15),

                    _buildEditableTextField(
                      label: 'Adres',
                      controller: _addressController,
                      hint: 'Isparta, Türkiye',
                      isEditable: _isAddressEditable,
                      onEditPressed: () {
                        setState(() {
                          _isAddressEditable = !_isAddressEditable;
                        });
                      },
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEditableTextField({
    required String label,
    required TextEditingController controller,
    required String hint,
    required bool isEditable,
    required VoidCallback onEditPressed,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 16,
                  color: Color.fromARGB(255, 0, 0, 0),
                ),
              ),
              GestureDetector(
                onTap: onEditPressed,
                child: Text(
                  isEditable ? 'Kaydet' : 'Düzenle',
                  style: const TextStyle(
                    color: Color.fromARGB(255, 0, 0, 0),
                    fontSize: 16,
                    decoration: TextDecoration.underline,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          TextField(
            controller: controller,
            enabled: isEditable,
            decoration: InputDecoration(
              hintText: hint,
              border: const OutlineInputBorder(),
            ),
          ),
        ],
      ),
    );
  }
}
