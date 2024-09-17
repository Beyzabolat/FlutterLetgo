// ignore_for_file: prefer_const_constructors, use_key_in_widget_constructors, file_names, unused_import, prefer_const_constructors_in_immutables, library_private_types_in_public_api 

import 'package:flutter/material.dart';
import 'package:project/Screens/AdvertDetails.dart';
import 'package:project/apihandler.dart';
import 'package:flutter_guid/flutter_guid.dart';

class AdvertListScreen extends StatefulWidget {
  final String clientRef;

  AdvertListScreen({required this.clientRef});

  @override
  _AdvertListScreenState createState() => _AdvertListScreenState();
}

class _AdvertListScreenState extends State<AdvertListScreen> {
  late Future<List<Map<String, dynamic>>> _adsFuture;

  @override
  void initState() {
    super.initState();
    _adsFuture = _fetchAds();
  }

  Future<List<Map<String, dynamic>>> _fetchAds() async {
    final apiHandler = ApiHandler();
    final allAds = await apiHandler.fetchAds();
    return allAds.where((ad) => ad['ClientRef'] == widget.clientRef).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('İlanlarım', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.red,
        elevation: 0,
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>( 
        future: _adsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Bir hata oluştu: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('İlanınız bulunamadı.'));
          } else {
            final ads = snapshot.data!;
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: ListView.builder(
                itemCount: ads.length,
                itemBuilder: (context, index) {
                  final ad = ads[index];
                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => Advertdetails(
                            title: ad['Name'] ?? 'İlan ${index + 1}',
                            description: ad['Description'] ?? 'İlan Açıklaması ${index + 1}',
                            imageUrl: ad['ImageUrl'] ?? '', 
                            category: ad['Category'] ?? 'Kategori ${index + 1}',
                            brand: ad['Brand'] ?? 'Marka ${index + 1}', 
                            model: ad['Model'] ?? 'Model ${index + 1}', 
                            price: ad['Price']?.toDouble() ?? 0.0, 
                            location: ad['Location'] ?? 'Konum ${index + 1}', 
                            quantity: ad['Quantity'] ?? 1, 
                          ),
                        ),
                      );
                    },
                    child: _buildAdvertCard(
                      context,
                      ad['Name'] ?? 'İlan ${index + 1}',
                      ad['Description'] ?? 'İlan Açıklaması ${index + 1}',
                      Icons.description,
                      Colors.red,
                    ),
                  );
                },
              ),
            );
          }
        },
      ),
    );
  }

  Widget _buildAdvertCard(BuildContext context, String title, String description, IconData icon, Color color) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
      elevation: 4.0,
      margin: EdgeInsets.only(bottom: 16.0),
      child: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.vertical(top: Radius.circular(15.0)),
            ),
            height: 150,
            child: Center(
              child: Icon(icon, size: 50, color: Colors.white),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8),
                Text(
                  description,
                  style: TextStyle(color: Colors.grey[700]),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}