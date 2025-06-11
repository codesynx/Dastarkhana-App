import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class SpecialOffersWidget extends StatefulWidget {
  const SpecialOffersWidget({super.key});

  @override
  State<SpecialOffersWidget> createState() => _SpecialOffersWidgetState();
}

class _SpecialOffersWidgetState extends State<SpecialOffersWidget> {
  @override
  Widget build(BuildContext) {
    return Container(
      height: 150,
      decoration: BoxDecoration(
        color: Colors.green,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Stack(
        children: [
          Positioned(
            right: 0,
            bottom: 0,
            child: Image.asset(
              'assets/images/food.png',
              height: 120,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 25),
                Text(
                  "30 % ЖЕҢІЛДІК \nБАРЛЫҚ ТАМАҚҚА \nТЕК БҮГІН!",
                  style: TextStyle(
                      fontFamily: "SF-Pro-Text-Bold", // Changed to use the family name
                      fontWeight: FontWeight.w800, // Specify bold weight
                      fontSize: 21,
                      color: Colors.white
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
