import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stayzi_ui/screens/navigation/bottom_nav.dart';
import 'package:stayzi_ui/screens/onboard/get_info_screen.dart';
import 'package:stayzi_ui/services/api_service.dart';
import 'package:stayzi_ui/services/storage_service.dart';

class PhoneCodeScreen extends StatefulWidget {
  final String phone;
  final String country;
  const PhoneCodeScreen({Key? key, required this.phone, required this.country})
    : super(key: key);

  @override
  State<PhoneCodeScreen> createState() => _PhoneCodeScreenState();
}

class _PhoneCodeScreenState extends State<PhoneCodeScreen> {
  final TextEditingController _codeController = TextEditingController();
  bool _isLoading = false;
  String? _errorText;

  void _verifyCode() async {
    setState(() {
      _isLoading = true;
      _errorText = null;
    });
    final code = _codeController.text.trim();
    if (code != '5882') {
      setState(() {
        _isLoading = false;
        _errorText = 'Kod yanlış. Lütfen tekrar deneyin.';
      });
      return;
    }
    // Kod doğruysa eski login akışını uygula
    try {
      final exists = await ApiService().checkPhoneExists(widget.phone);
      if (exists) {
        final prefs = await SharedPreferences.getInstance();
        final token = await ApiService().loginWithPhone(widget.phone);
        ApiService().setAuthToken(token.accessToken);
        await StorageService().saveToken(token);
        await prefs.setString('user_phone', widget.phone);
        if (!mounted) return;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const BottomNavigationWidget(),
          ),
        );
      } else {
        if (!mounted) return;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder:
                (context) =>
                    GetInfoScreen(phone: widget.phone, country: widget.country),
          ),
        );
      }
    } catch (e) {
      setState(() {
        _errorText = 'Bir hata oluştu: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(title: const Text('Telefon Doğrulama')),
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16),
            child: Card(
              elevation: 6,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 28,
                  vertical: 36,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.red.shade50,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.sms,
                        size: 38,
                        color: Colors.red.shade400,
                      ),
                    ),
                    const SizedBox(height: 18),
                    const Text(
                      'Telefonunu Doğrula',
                      style: TextStyle(
                        fontSize: 21,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${widget.phone} numarasına gönderilen 4 haneli kodu girin',
                      style: const TextStyle(
                        fontSize: 15,
                        color: Colors.grey,
                        height: 1.4,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 28),
                    // Kod kutucukları
                    _CodeInputRow(
                      controller: _codeController,
                      enabled: !_isLoading,
                      error: _errorText,
                    ),
                    if (_errorText != null) ...[
                      const SizedBox(height: 10),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.red.shade50,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.error_outline,
                              color: Colors.red.shade400,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Flexible(
                              child: Text(
                                _errorText!,
                                style: TextStyle(
                                  color: Colors.red.shade400,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                    const SizedBox(height: 28),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _verifyCode,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red.shade400,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          elevation: 0,
                        ),
                        child:
                            _isLoading
                                ? const SizedBox(
                                  height: 22,
                                  width: 22,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2.5,
                                  ),
                                )
                                : const Text(
                                  'Doğrula',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 17,
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
        ),
      ),
    );
  }
}

// 4 haneli kod kutucukları için widget
class _CodeInputRow extends StatefulWidget {
  final TextEditingController controller;
  final bool enabled;
  final String? error;
  const _CodeInputRow({
    required this.controller,
    required this.enabled,
    this.error,
  });

  @override
  State<_CodeInputRow> createState() => _CodeInputRowState();
}

class _CodeInputRowState extends State<_CodeInputRow> {
  late List<FocusNode> _focusNodes;
  late List<TextEditingController> _controllers;

  @override
  void initState() {
    super.initState();
    _focusNodes = List.generate(4, (_) => FocusNode());
    _controllers = List.generate(4, (i) {
      final c = TextEditingController();
      if (widget.controller.text.length > i) {
        c.text = widget.controller.text[i];
      }
      return c;
    });
  }

  @override
  void dispose() {
    for (var f in _focusNodes) {
      f.dispose();
    }
    for (var c in _controllers) {
      c.dispose();
    }
    super.dispose();
  }

  void _onChanged(int idx, String val) {
    if (val.length > 1) {
      val = val.substring(val.length - 1);
      _controllers[idx].text = val;
    }
    // Diğer kutuların değerlerini birleştirip ana controller'a yaz
    String code = _controllers.map((c) => c.text).join();
    widget.controller.text = code;
    if (val.isNotEmpty && idx < 3) {
      _focusNodes[idx + 1].requestFocus();
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(4, (i) {
        return Container(
          width: 48,
          margin: EdgeInsets.symmetric(horizontal: 6),
          child: TextField(
            controller: _controllers[i],
            focusNode: _focusNodes[i],
            enabled: widget.enabled,
            keyboardType: TextInputType.number,
            textAlign: TextAlign.center,
            maxLength: 1,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              letterSpacing: 2,
            ),
            decoration: InputDecoration(
              counterText: '',
              filled: true,
              fillColor:
                  widget.error != null
                      ? Colors.red.shade50
                      : Colors.grey.shade100,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color:
                      widget.error != null
                          ? Colors.red.shade400
                          : Colors.grey.shade300,
                  width: 2,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color:
                      widget.error != null ? Colors.red.shade400 : Colors.black,
                  width: 2.2,
                ),
              ),
            ),
            onChanged: (val) => _onChanged(i, val),
            onTap:
                () =>
                    _controllers[i].selection = TextSelection(
                      baseOffset: 0,
                      extentOffset: _controllers[i].text.length,
                    ),
          ),
        );
      }),
    );
  }
}
