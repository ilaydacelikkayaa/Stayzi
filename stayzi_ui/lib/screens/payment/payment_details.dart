import 'package:flutter/material.dart';

class PaymentDetails extends StatelessWidget {
  final int totalNights;
  final double amount;
  final double tax;

  const PaymentDetails({
    super.key,
    required this.totalNights,
    required this.amount,
    required this.tax,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.black12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Ödeme Özeti",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          Text("Toplam Konaklama: $totalNights Gece"),
          Text("Tutar: ₺${amount.toStringAsFixed(2)}"),
          Text("Vergiler ve Ücretler: ₺${tax.toStringAsFixed(2)}"),
          const Divider(height: 20, thickness: 1),
          Text(
            "Genel Toplam: ₺${(amount + tax).toStringAsFixed(2)}",
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
