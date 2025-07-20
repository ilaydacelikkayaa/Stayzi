import 'package:flutter/material.dart';

import '../../models/user_model.dart';
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
  User? _currentUser;

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
      print('🟢 Backendden gelen kullanıcı:');
      print(
        'name: \'${user.name}\', surname: \'${user.surname}\', phone: \'${user.phone}\', email: \'${user.email}\', country: \'${user.country}\'',
      );
      print('📱 Telefon numarası: ${user.phone}');
      print('📧 E-posta: ${user.email}');
      print('🏠 Ülke: ${user.country}');
      
      setState(() {
        _fullNameController.text = '${user.name} ${user.surname}';
        _preferredNameController.text = user.name;
        _currentUser = user;
        _phoneNumberController.text = user.phone ?? '';
        _emailController.text = user.email ?? '';
        _addressController.text = user.country ?? '';
        _isLoading = false;
      });
      
      // Eğer veri eksikse kullanıcıya uyarı göster
      if ((user.name.isEmpty && user.surname.isEmpty) &&
          (user.email == null || user.email!.isEmpty)) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Uyarı: Kullanıcı verisi eksik veya boş geldi!'),
              backgroundColor: Colors.orange,
            ),
          );
        }
      }
    } catch (e) {
      setState(() {
        _error = 'Kullanıcı bilgileri alınamadı: $e';
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
      
      // Telefon numarasını güvenli şekilde al
      final phone = _phoneNumberController.text.trim();
      final email = _emailController.text.trim();
      final country = _addressController.text.trim();
      
      await ApiService().updateProfile(
        name: name,
        surname: surname,
        email: email.isNotEmpty ? email : null,
        phone: phone.isNotEmpty ? phone : null,
        country: country.isNotEmpty ? country : null,
      );
      
      setState(() {
        _success = 'Bilgiler başarıyla güncellendi!';
        // Tüm düzenleme alanlarını kapat
        _isFullNameEditable = false;
        _isPreferredNameEditable = false;
        _isPhoneNumberEditable = false;
        _isEmailEditable = false;
        _isAddressEditable = false;
      });
      
      // Veriyi yeniden çek
      await _fetchUserInfo();

      // Başarı mesajını göster
      if (mounted && _success != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_success!),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      setState(() {
        _error = 'Güncelleme başarısız: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _saveField(String fieldName, String value) async {
    // Boş değerleri kontrol et
    if (value.trim().isEmpty) {
      setState(() {
        _error = 'Bu alan boş bırakılamaz';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
      _success = null;
    });

    try {
      String? name, surname, email, phone, country;

      switch (fieldName) {
        case 'name':
          final names = value.trim().split(' ');
          name = names.isNotEmpty ? names.first : null;
          surname = names.length > 1 ? names.sublist(1).join(' ') : null;
          break;
        case 'preferredName':
          name = value.trim();
          break;
        case 'phone':
          phone = value.trim();
          break;
        case 'email':
          email = value.trim();
          break;
        case 'country':
          country = value.trim();
          break;
      }

      await ApiService().updateProfile(
        name: name,
        surname: surname,
        email: email,
        phone: phone,
        country: country,
      );

      setState(() {
        _success = 'Bilgiler başarıyla güncellendi!';
      });

      // Veriyi yeniden çek
      await _fetchUserInfo();

      // Başarı mesajını göster
      if (mounted && _success != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_success!),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      setState(() {
        _error = 'Güncelleme başarısız: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        title: const Text(
          'Kişisel Bilgiler',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
            color: Colors.black,
          ),
        ),
        centerTitle: true,
      ),
      body:
          _isLoading
              ? const Center(
                child: CircularProgressIndicator(color: Colors.black),
              )
              : SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                      // Header Section
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.08),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(
                                Icons.person,
                                color: Colors.black,
                                size: 24,
                              ),
                            ),
                            const SizedBox(width: 16),
                            const Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Kişisel Bilgiler',
                                    style: TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black,
                                    ),
                                  ),
                                  SizedBox(height: 4),
                                  Text(
                                    'Bilgilerinizi güncelleyin',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Status Messages
                    if (_error != null)
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.red.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: Colors.red.withOpacity(0.3),
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.error_outline, color: Colors.red[600]),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  _error!,
                                  style: TextStyle(
                                    color: Colors.red[700],
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            ],
                        ),
                      ),
                    if (_success != null)
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.green.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: Colors.green.withOpacity(0.3),
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.check_circle_outline,
                                color: Colors.green[600],
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  _success!,
                                  style: TextStyle(
                                    color: Colors.green[700],
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      if (_error != null || _success != null)
                        const SizedBox(height: 20),

                      // Form Section
                    Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.08),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Form(
                            key: _formKey,
                            child: ListView(
                              padding: const EdgeInsets.all(20),
                              children: [
                                _buildInfoSection(
                                  title: 'Temel Bilgiler',
                                  icon: Icons.person_outline,
                                  children: [
                                    _buildEditableField(
                                      label: 'Yasal Ad',
                                      controller: _fullNameController,
                                      hint: 'Ad Soyad',
                                      isEditable: _isFullNameEditable,
                                      onEditPressed: () async {
                                        if (_isFullNameEditable) {
                                          await _saveField(
                                            'name',
                                            _fullNameController.text,
                                          );
                                        }
                                        setState(() {
                                          _isFullNameEditable =
                                              !_isFullNameEditable;
                                        });
                                      },
                                    ),
                                    const SizedBox(height: 20),
                                    _buildEditableField(
                                      label: 'Tercih Edilen Ad',
                                      controller: _preferredNameController,
                                      hint: 'Ad',
                                      isEditable: _isPreferredNameEditable,
                                      onEditPressed: () async {
                                        if (_isPreferredNameEditable) {
                                          await _saveField(
                                            'preferredName',
                                            _preferredNameController.text,
                                          );
                                        }
                                        setState(() {
                                          _isPreferredNameEditable =
                                              !_isPreferredNameEditable;
                                        });
                                      },
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 24),

                                _buildInfoSection(
                                  title: 'İletişim Bilgileri',
                                  icon: Icons.contact_phone,
                                  children: [
                                    _buildEditableField(
                                      label: 'Telefon Numarası',
                                      controller: _phoneNumberController,
                                      hint: '+90 555 123 45 67',
                                      isEditable: _isPhoneNumberEditable,
                                      onEditPressed: () async {
                                        if (_isPhoneNumberEditable) {
                                          await _saveField(
                                            'phone',
                                            _phoneNumberController.text,
                                          );
                                        }
                                        setState(() {
                                          _isPhoneNumberEditable =
                                              !_isPhoneNumberEditable;
                                        });
                                      },
                                    ),
                                    const SizedBox(height: 20),
                                    _buildEditableField(
                                      label: 'E-posta',
                                      controller: _emailController,
                                      hint: 'eposta@example.com',
                                      isEditable: _isEmailEditable,
                                      onEditPressed: () async {
                                        if (_isEmailEditable) {
                                          await _saveField(
                                            'email',
                                            _emailController.text,
                                          );
                                        }
                                        setState(() {
                                          _isEmailEditable = !_isEmailEditable;
                                        });
                                      },
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 24),

                                _buildInfoSection(
                                  title: 'Adres Bilgileri',
                                  icon: Icons.location_on_outlined,
                                  children: [
                                    _buildEditableField(
                                      label: 'Adres',
                                      controller: _addressController,
                                      hint: 'Şehir, Ülke',
                                      isEditable: _isAddressEditable,
                                      onEditPressed: () async {
                                        if (_isAddressEditable) {
                                          await _saveField(
                                            'country',
                                            _addressController.text,
                                          );
                                        }
                                        setState(() {
                                          _isAddressEditable =
                                              !_isAddressEditable;
                                        });
                                      },
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 32),
                              
                                // Save Button
                                Container(
                                  width: double.infinity,
                                  height: 56,
                                  decoration: BoxDecoration(
                                    color: Colors.black,
                                    borderRadius: BorderRadius.circular(16),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.2),
                                        blurRadius: 8,
                                        offset: const Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  child: ElevatedButton(
                                    onPressed: _saveProfile,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.transparent,
                                      shadowColor: Colors.transparent,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                    ),
                                    child: const Text(
                                      'Değişiklikleri Kaydet',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
    );
  }

  Widget _buildInfoSection({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: Colors.black, size: 20),
            ),
            const SizedBox(width: 12),
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        ...children,
      ],
    );
  }

  Widget _buildEditableField({
    required String label,
    required TextEditingController controller,
    required String hint,
    required bool isEditable,
    required Future<void> Function() onEditPressed,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color:
              isEditable
                  ? Colors.black.withOpacity(0.3)
                  : Colors.grey.withOpacity(0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[700],
                ),
              ),
              TextButton(
                onPressed: () async {
                  await onEditPressed();
                },
                child: Text(
                  isEditable ? 'Kaydet' : 'Düzenle',
                  style: TextStyle(
                    color: isEditable ? Colors.green : Colors.black,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          TextField(
            controller: controller,
            enabled: isEditable,
            decoration: InputDecoration(
              hintText: hint,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(
                  color:
                      isEditable
                          ? Colors.black.withOpacity(0.3)
                          : Colors.grey.withOpacity(0.3),
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(
                  color:
                      isEditable
                          ? Colors.black.withOpacity(0.3)
                          : Colors.grey.withOpacity(0.3),
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.black.withOpacity(0.5)),
              ),
              filled: !isEditable,
              fillColor: isEditable ? Colors.white : Colors.grey[100],
            ),
          ),
        ],
      ),
    );
  }
}
