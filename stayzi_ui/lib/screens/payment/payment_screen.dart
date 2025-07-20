import 'package:flutter/material.dart';
import 'package:stayzi_ui/screens/detail/detail_scren.dart';
import 'package:stayzi_ui/screens/onboard/widgets/basic_button.dart';
import 'package:stayzi_ui/screens/payment/payment_details.dart';
import 'package:stayzi_ui/screens/payment/payment_form.dart';
import 'package:stayzi_ui/services/api_service.dart';
import 'package:stayzi_ui/services/storage_service.dart';

class PaymentScreen extends StatelessWidget {
  final DateTimeRange selectedRange;
  final Map<String, dynamic> listing;

  const PaymentScreen({
    super.key,
    required this.selectedRange,
    required this.listing,
  });

  Future<void> _createBooking(BuildContext context) async {
    try {
      // Token'ı al
      final token = await StorageService().getToken();
      if (token != null) {
        ApiService().setAuthToken(token.accessToken);
      }

      // Toplam tutarı hesapla
      final int totalNights = selectedRange.duration.inDays;
      final double nightlyPrice = (listing['price'] ?? 0).toDouble();
      final double amount = nightlyPrice * totalNights;
      const double tax = 500;
      final double totalPrice = amount + tax;

      // Booking verilerini hazırla
      final bookingData = {
        'listing_id': listing['id'],
        'start_date': selectedRange.start.toIso8601String().split('T')[0],
        'end_date': selectedRange.end.toIso8601String().split('T')[0],
        'guests': 1, // Varsayılan değer, gerekirse değiştirilebilir
        'total_price': totalPrice, // ✅ Toplam fiyat eklendi
      };

      print('🔍 Booking oluşturuluyor: $bookingData');

      // Backend'e booking oluşturma isteği gönder
      final booking = await ApiService().createBooking(bookingData);
      print('✅ Booking başarıyla oluşturuldu: $booking');

      // Başarılı ödeme ekranına yönlendir
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const PaymentSuccessScreen()),
      );
    } catch (e) {
      print('❌ Booking oluşturma hatası: $e');
      // Hata durumunda kullanıcıya bilgi ver
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Rezervasyon oluşturulurken hata oluştu: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final int totalNights = selectedRange.duration.inDays;
    final double nightlyPrice = (listing['price'] ?? 0).toDouble();
    final double amount = nightlyPrice * totalNights;
    const double tax = 500;

    return Scaffold(
      appBar: AppBar(title: const Text("Ödeme")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            PaymentDetails(tax: tax, amount: amount, totalNights: totalNights),
            const SizedBox(height: 20),
            const Text(
              "Kart Bilgileri",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            const CreditCardInfo(),
            const SizedBox(height: 30),
            Column(
              children: [
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButtonWidget(
                    buttonText: "Ödemeyi Tamamla",
                    buttonColor: Colors.black,
                    textColor: Colors.white,
                    onPressed: () => _createBooking(context),
                  ),
                ),
                SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButtonWidget(
                    buttonText: "Rezervasyonu İptal Et",
                    buttonColor: const Color.fromRGBO(213, 56, 88, 1),
                    textColor: Colors.white,
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder:
                              (context) => ListingDetailPage(listing: listing),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class PaymentSuccessScreen extends StatelessWidget {
  const PaymentSuccessScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.check_circle_outline, color: Colors.green, size: 100),
              const SizedBox(height: 20),
              const Text(
                "Ödeme Başarıyla Tamamlandı!",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 15),
              const Text(
                "İşleminiz başarıyla gerçekleştirildi. Tatilinizin keyfini çıkarın!",
                style: TextStyle(fontSize: 16),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 14,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: () {
                  Navigator.of(context).popUntil((route) => route.isFirst);
                },
                child: const Text(
                  "Gezinmeye Devam Et",
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
