// ignore_for_file: file_names, use_super_parameters, prefer_const_constructors, sort_child_properties_last, prefer_const_literals_to_create_immutables

import 'package:flutter/material.dart';

class Advertdetails extends StatelessWidget {
  final String title;
  final String description;
  final String imageUrl;
  final String category;
  final String brand;
  final String model;
  final double price;
  final String location;
  final int quantity;
  final String advertRef; 
  final String clientRef;   


  const Advertdetails({
    Key? key,
    required this.title,
    required this.description,
    required this.imageUrl,
    required this.category,
    required this.brand,
    required this.model,
    required this.price,
    required this.location,
    required this.quantity,
    required this.advertRef,
    required this.clientRef,

  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('İlan Detayları', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.red,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            Container(
              width: double.infinity,
              height: 250,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    offset: Offset(0, 4),
                    blurRadius: 10,
                  ),
                ],
                image: imageUrl.isNotEmpty
                    ? DecorationImage(
                        image: NetworkImage(imageUrl),
                        fit: BoxFit.cover,
                      )
                    : null,
                color: imageUrl.isEmpty ? Colors.grey[300] : null,
              ),
              child: imageUrl.isEmpty
                  ? Center(
                      child: Icon(Icons.image, size: 80, color: Colors.grey),
                    )
                  : null,
            ),
            SizedBox(height: 16),
            Text(
              title,
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            Row(
              children: [
                Icon(Icons.category, color: Colors.red),
                SizedBox(width: 8),
                Text(
                  category,
                  style: TextStyle(fontSize: 18, color: Colors.red, fontWeight: FontWeight.w500),
                ),
              ],
            ),
            SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.car_repair, color: Colors.grey),
                SizedBox(width: 8),
                Text(
                  '$brand $model',
                  style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                ),
              ],
            ),
            SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.attach_money, color: Colors.green),
                SizedBox(width: 8),
                Text(
                  'Fiyat: ${price.toStringAsFixed(2)} TL',
                  style: TextStyle(fontSize: 18, color: Colors.green, fontWeight: FontWeight.w600),
                ),
              ],
            ),
            SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.location_on, color: Colors.blue),
                SizedBox(width: 8),
                Text(
                  'Konum: $location',
                  style: TextStyle(fontSize: 18, color: Colors.grey[700]),
                ),
              ],
            ),
            SizedBox(height: 8),
            SizedBox(height: 16),
            Text(
              description,
              style: TextStyle(fontSize: 16, color: Colors.grey[800]),
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton.icon(
                  onPressed: () {},
                  icon: Icon(Icons.remove, color: Colors.white),
                  label: Text('İlanı Kaldır'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    textStyle: TextStyle(fontSize: 16),
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