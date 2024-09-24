
// ignore_for_file: unnecessary_import

import 'dart:ui';

import 'package:flutter/material.dart';

class Category {
  final String image;
  final Color color;

  Category({required this.image, required this.color});
}

List<Category> categories = [
  Category(
    
    image: "assets/screwdriver.png",
    color: const Color(0xffc2f6bf),
  ),
  Category(
   
    image: "assets/fridge.png",
    color: const Color(0xffc8a0f1),
  ),
  Category(
    
    image: "assets/fitness.png",
    color: const Color(0xfff5c385),
  ),
  Category(
   
    image: "assets/screwdriver.png",
    color: const Color(0xfff19baa),
  ),
  Category(
    
    image: "assets/screwdriver.png",
    color: Colors.orange,
  ),
];