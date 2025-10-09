import 'package:flutter/material.dart';
import 'package:rtsp31_mobile/constants/app_color.dart';

SizedBox sizedBW(double width) => SizedBox(width: width);
SizedBox sizedBH(double height) => SizedBox(height: height);

Widget customButton(String text, VoidCallback onPressed) {
  return ElevatedButton(
    onPressed: onPressed,
    style: ElevatedButton.styleFrom(
      backgroundColor: AppColors.colorPrimary,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
    ),
    child: Text(text, style: const TextStyle(color: Colors.white)),
  );
}

Widget buildDivider() {
  return Align(
    alignment: Alignment.center,
    child: FractionallySizedBox(
      widthFactor: 1.5,
      child: Container(height: 8, color: Colors.grey.shade300),
    ),
  );
}
