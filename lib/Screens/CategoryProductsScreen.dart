// ignore: file_names
// ignore_for_file: prefer_const_constructors, prefer_interpolation_to_compose_strings, library_private_types_in_public_api, use_key_in_widget_constructors, prefer_const_constructors_in_immutables, file_names, duplicate_ignore

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:project/Screens/Advertdetails.dart';
import 'package:project/constants.dart';

class CategoryProductsScreen extends StatefulWidget {
  final String categoryName;
  final String categoryRef;
  final List<Map<String, dynamic>> allAds;
  final String clientRef;

  CategoryProductsScreen({
    required this.categoryName,
    required this.categoryRef,
    required this.allAds,
    required this.clientRef,
  });

  @override
  _CategoryProductsScreenState createState() => _CategoryProductsScreenState();
}

class _CategoryProductsScreenState extends State<CategoryProductsScreen> {
  List<Map<String, dynamic>> categoryAds = [];

  @override
  void initState() {
    super.initState();
    _filterAdsByCategory();
  }

  void _filterAdsByCategory() {
    setState(() {
      categoryAds = widget.allAds.where((ad) {
        return ad['CategoryRef'] == widget.categoryRef;
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackGroundColor,
      appBar: AppBar(
        title: Text('${widget.categoryName} Ürünleri'),
      ),
      body: categoryAds.isEmpty
          ? Center(child: Text('Bu kategoriye ait ürün bulunamadı.'))
          : GridView.builder(
              padding: EdgeInsets.all(16.0),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 10.0,
                mainAxisSpacing: 10.0,
                childAspectRatio: 0.75,
              ),
              itemCount: categoryAds.length,
              itemBuilder: (BuildContext context, int index) {
                final ad = categoryAds[index];
                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => Advertdetails(
                          title: ad['Name'] ?? 'Başlık Yok',
                          description: ad['Description'] ?? 'Açıklama Yok',
                          imageUrl: ad['Images'] ?? [],
                          category: ad['Category'] ?? 'Kategori Yok',
                          brand: ad['Brand'] ?? 'Marka Yok',
                          model: ad['Model'] ?? 'Model Yok',
                          price: ad['Price']?.toDouble() ?? 0.0,
                          location: ad['Location'] ?? 'Konum Yok',
                          quantity: ad['Quantity'] ?? 0,
                          clientRef: widget.clientRef,
                          advertRef: ad['Ref'] ?? '',
                        ),
                      ),
                    );
                  },
                  child: _buildProductCard(
                    ad['Name'] ?? 'error',
                    (ad['Price'] ?? 0).toString() + ' TL',
                    ad['Location'] ?? 'Konum Yok',
                    ad['Image'] ?? '',
                    Icons.shopping_bag,
                    Colors.blueAccent,
                    context,
                  ),
                );
              },
            ),
    );
  }

  Widget _buildProductCard(String title, String price, String location,
      String imageUrl, IconData icon, Color color, BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
      elevation: 3,
      child: Column(
        children: [
          Expanded(
            child: imageUrl.isNotEmpty
                ? Image.memory(
                    base64Decode(imageUrl),
                    fit: BoxFit.cover,
                    width: double.infinity,
                    height: double.infinity,
                  )
                : Placeholder(
                    fallbackHeight: 200,
                    fallbackWidth: double.infinity,
                  ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 4),
                Text(
                  price,
                  style: TextStyle(fontSize: 16, color: Colors.green),
                ),
                SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.location_on,
                        size: 16, color: Colors.grey.shade700),
                    SizedBox(width: 4),
                    Text(
                      'Konum: $location',
                      style:
                          TextStyle(fontSize: 12, color: Colors.grey.shade700),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
