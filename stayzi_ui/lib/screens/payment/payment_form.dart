import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:stayzi_ui/screens/onboard/widgets/form_widget.dart';

class CreditCardInfo extends StatelessWidget {
  const CreditCardInfo({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        FormWidget(
          labelText: 'Kart Sahibi',
          hintText: 'Ad Soyad',
          textInputAction: TextInputAction.next,
          inputFormatters: [
            FilteringTextInputFormatter.allow(
              RegExp(r'[a-zA-ZğüşöçıİĞÜŞÖÇ\s]'),
            ),
          ],
        ),
        const SizedBox(height: 16),
        FormWidget(
          labelText: 'Kart Numarası',
          hintText: '1234 5678 9012 3456',
          keyboardType: TextInputType.number,
          textInputAction: TextInputAction.next,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: FormWidget(
                labelText: 'SKT',
                hintText: 'AA/YY',
                keyboardType: TextInputType.datetime,
                textInputAction: TextInputAction.next,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: FormWidget(
                labelText: 'CVV',
                hintText: '123',
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              ),
            ),
          ],
        ),
      ],
    );
  }
}
