import 'package:flutter/material.dart';

Widget buildCard(Widget child) => Container(
  padding: const EdgeInsets.all(16),
  margin: const EdgeInsets.only(bottom: 16),
  decoration: BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(12),
    boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4)],
  ),
  child: child,
);
