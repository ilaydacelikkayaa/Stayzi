import 'package:flutter/material.dart';
import 'package:stayzi_ui/screens/onboard/widgets/editable_text_field.dart';

import '../../services/api_service.dart';

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

  bool _isLoading = false;
  String? _error;
  String? _success;

  @override
  void initState() {
    super.initState();
    _fetchUserInfo();
  }

  Future<void> _fetchUserInfo() async {
    setState(() {
      _isLoading = true;
      _error = null;
      _success = null;
    });
    try {
      final user = await ApiService().getCurrentUser();
      _fullNameController.text = '${user.name} ${user.surname}';
      _preferredNameController.text = user.name;
      _phoneNumberController.text = user.phone ?? '';
      _emailController.text = user.email ?? '';
      _addressController.text = user.country ?? '';
    } catch (e) {
      _error = 'Kullanıcı bilgileri alınamadı: $e';
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _saveProfile() async {
    setState(() {
      _isLoading = true;
      _error = null;
      _success = null;
    });
    try {
      final names = _fullNameController.text.trim().split(' ');
      final name = names.isNotEmpty ? names.first : '';
      final surname = names.length > 1 ? names.sublist(1).join(' ') : '';
      await ApiService().updateProfile(
        name: name,
        surname: surname,
        email: _emailController.text.trim(),
        country: _addressController.text.trim(),
        // phone ve preferredName backend'de yoksa eklenmez
      );
      _success = 'Bilgiler başarıyla güncellendi!';
    } catch (e) {
      _error = 'Güncelleme başarısız: $e';
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

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
        child:
            _isLoading
                ? const Center(child: CircularProgressIndicator())
                : Column(
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
                    if (_error != null)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: Text(
                          _error!,
                          style: const TextStyle(color: Colors.red),
                        ),
                      ),
                    if (_success != null)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: Text(
                          _success!,
                          style: const TextStyle(color: Colors.green),
                        ),
                      ),
                    Expanded(
                      child: Form(
                        key: _formKey,
                        child: ListView(
                          children: [
                            const SizedBox(height: 20),
                            EditableTextField(
                              label: 'Yasal Ad',
                              controller: _fullNameController,
                              hint: 'Ad Soyad',
                              isEditable: _isFullNameEditable,
                              onEditPressed: () {
                                setState(() {
                                  _isFullNameEditable = !_isFullNameEditable;
                                });
                              },
                            ),
                            const Divider(color: Colors.grey),
                            const SizedBox(height: 15),
                            EditableTextField(
                              label: 'Tercih Edilen Ad',
                              controller: _preferredNameController,
                              hint: 'Ad',
                              isEditable: _isPreferredNameEditable,
                              onEditPressed: () {
                                setState(() {
                                  _isPreferredNameEditable =
                                      !_isPreferredNameEditable;
                                });
                              },
                            ),
                            const Divider(color: Colors.grey),
                            const SizedBox(height: 15),
                            EditableTextField(
                              label: 'Telefon Numarası',
                              controller: _phoneNumberController,
                              hint: '+90 555 123 45 67',
                              isEditable: _isPhoneNumberEditable,
                              onEditPressed: () {
                                setState(() {
                                  _isPhoneNumberEditable =
                                      !_isPhoneNumberEditable;
                                });
                              },
                            ),
                            const Divider(color: Colors.grey),
                            const SizedBox(height: 15),
                            EditableTextField(
                              label: 'E-posta',
                              controller: _emailController,
                              hint: 'eposta@example.com',
                              isEditable: _isEmailEditable,
                              onEditPressed: () {
                                setState(() {
                                  _isEmailEditable = !_isEmailEditable;
                                });
                              },
                            ),
                            const Divider(color: Colors.grey),
                            const SizedBox(height: 15),
                            EditableTextField(
                              label: 'Adres',
                              controller: _addressController,
                              hint: 'Şehir, Ülke',
                              isEditable: _isAddressEditable,
                              onEditPressed: () {
                                setState(() {
                                  _isAddressEditable = !_isAddressEditable;
                                });
                              },
                            ),
                            const SizedBox(height: 32),
                            ElevatedButton(
                              onPressed: _saveProfile,
                              child: const Text('Kaydet'),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
      ),
    );
  }
}
