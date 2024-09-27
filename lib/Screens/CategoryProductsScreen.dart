// ignore: file_names
// ignore_for_file: prefer_const_constructors, prefer_interpolation_to_compose_strings, library_private_types_in_public_api, use_key_in_widget_constructors, prefer_const_constructors_in_immutables, file_names, duplicate_ignore

import 'package:flutter/material.dart';
import 'package:project/Screens/Advertdetails.dart';

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
                          imageUrl: ad['Image'] ?? '',
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

  Widget _buildProductCard(String title, String description, String imageUrl,
      IconData icon, Color color, BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
      child: Column(
        children: [
          Expanded(
            child: imageUrl.isNotEmpty
                ? Container(
                    decoration: BoxDecoration(
                      borderRadius:
                          BorderRadius.vertical(top: Radius.circular(15.0)),
                      image: DecorationImage(
                        image: NetworkImage(imageUrl),
                        fit: BoxFit.cover,
                      ),
                    ),
                  )
                : Container(
                    color: color,
                    child: Center(
                      child: Icon(icon, size: 50, color: Colors.white),
                    ),
                  ),
          ),
          Padding(
            padding: EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(fontSize: 14, color: Colors.grey.shade700),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
