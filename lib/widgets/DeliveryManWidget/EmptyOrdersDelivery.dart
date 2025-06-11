import 'package:flutter/material.dart';

class EmptyOrdersDelivery extends StatelessWidget {
  const EmptyOrdersDelivery({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              "assets/images/Frame.png", // Using the same image
              height: 180,
            ),
            SizedBox(height: 24),
            Text(
              "Тапсырыс жоқ", // Changed text
              style: TextStyle(
                fontSize: 24,
                fontFamily: 'SF-Pro-Text-Bold',
                color: Colors.black,
                fontWeight: FontWeight.w800,
              ),
            ),
            SizedBox(height: 8),
            Text(
              "Сізге әлі жаңа тапсырыстар тағайындалмады.", // Adjusted subtext
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                fontFamily: 'SF-Pro-Text-Medium',
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
