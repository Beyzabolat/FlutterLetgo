// ignore_for_file: library_private_types_in_public_api, prefer_const_literals_to_create_immutables, prefer_const_constructors, file_names, avoid_print, unused_element, unused_local_variable

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:project/apihandler.dart';
import 'package:project/constants.dart';
import 'package:intl/intl.dart';

class FavoritesScreen extends StatefulWidget {
  final String clientRef;

  const FavoritesScreen({super.key, required this.clientRef});

  @override
  _FavoritesScreenState createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  late Future<List<dynamic>> favoritesFuture;
  late Future<List<Map<String, dynamic>>> advertisementsFuture;

  @override
  void initState() {
    super.initState();
    favoritesFuture = ApiHandler().fetchFavoritesByClientRef(widget.clientRef);
    advertisementsFuture = _fetchAds();
    print('Client Ref: ${widget.clientRef}');  
  }

  final ApiHandler apiHandler = ApiHandler();
  List<Map<String, dynamic>> favoriteAds = [];
  Future<List<Map<String, dynamic>>> _fetchAds() async {
    final allAds = await apiHandler.fetchAds();
    return allAds.where((ad) => ad['ClientRef'] == widget.clientRef).toList();
  }

  Future<void> _removeFromFavorites(String advertRef, String clientRef) async {
    try {
      await apiHandler.removeFromFavorites(advertRef, clientRef);

      setState(() {
        favoriteAds.removeWhere((fav) => fav['AdvertRef'] == advertRef);
      });
      await loadFavorites(clientRef);
    } catch (error) {
      _showErrorSnackBar(error);
    }
  }

  void _showErrorSnackBar(dynamic error) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
            'Favori kaldırma işlemi sırasında bir hata oluştu: ${error.toString()}'),
      ),
    );
  }

  Future<void> loadFavorites(String clientRef) async {
    try {
      List<Map<String, dynamic>> favorites =
          await apiHandler.getFavorites(clientRef);

      setState(() {
        favoriteAds = favorites;
      });
    } catch (e) {
      print('Favoriler yüklenemedi: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: kBackGroundColor,
        appBar: AppBar(
          title: Text(
            'İlanlarım ve Favorilerim',
            style: TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          elevation: 0,
          backgroundColor: kBackGroundColor,
          automaticallyImplyLeading: false,
          bottom: TabBar(
            tabs: [
              Tab(text: 'Favoriler'),
              Tab(text: 'İlanlarım'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildFavoritesTab(context),
            _buildAdvertisementsTab(context),
          ],
        ),
      ),
    );
  }

  Widget _buildFavoritesTab(BuildContext context) {
    return FutureBuilder<List<dynamic>>(
      future: favoritesFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(
              child: Text(
                  'Favori ilanlar yüklenirken hata oluştu: ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(child: Text('Favori ilan bulunamadı.'));
        }

        final favorites = snapshot.data!;
        return ListView.builder(
          itemCount: favorites.length,
          itemBuilder: (context, index) {
            final item = favorites[index];
            return _buildFavoriteItem(
              context,
              item['Name'] ?? 'Ürün',
              item['Model'] ?? 'Model',
              item['Price']?.toString() ?? '0',
              item['Image'] ?? '',
              item['isFavorited'] ?? false,
            );
          },
        );
      },
    );
  }

  Widget _buildAdvertisementsTab(BuildContext context) {
    return Column(
      children: [
        _buildFilterSection(),
        Expanded(
          child: FutureBuilder<List<dynamic>>(
            future: advertisementsFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Center(
                    child: Text(
                        'İlanlar yüklenirken hata oluştu: ${snapshot.error}'));
              } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return Center(child: Text('İlanınız bulunamadı.'));
              }

              final ads = snapshot.data!;
              return ListView.builder(
                itemCount: ads.length,
                itemBuilder: (context, index) {
                  final ad = ads[index];
                  String statusText =
                      ad['Status'] == 1 ? 'Yeni' : 'Aktif'; 
                  return _buildAdItem(context, ad);
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildFavoriteItem(BuildContext context, String title, String model,
      String price, String imageUrl, bool isFavorited) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      elevation: 3,
      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 10),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.horizontal(left: Radius.circular(10.0)),
            child: imageUrl.isNotEmpty
                ? Image.memory(
                    base64Decode(imageUrl),
                    fit: BoxFit.cover,
                    height: 80,
                    width: 80,
                  )
                : Placeholder(
                    fallbackHeight: 80,
                    fallbackWidth: 80,
                  ),
          ),
          SizedBox(width: 8),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Model: $model',
                    style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                  ),
                  SizedBox(height: 4),
                  Text(
                    '$price TL',
                    style: TextStyle(fontSize: 14, color: Colors.green),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(
                right: 8.0),  
            child: IconButton(
              icon: Icon(
                Icons.favorite,
                color: Colors.red,
              ),
              onPressed: () {
                print('Favorilerden çıkarıldı: $title');
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterSection() {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Filtrele',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          Row(
            children: [
              ElevatedButton(
                onPressed: () {
                  // Etkin filtreleme işlemleri
                },
                child: Text('Etkin'),
              ),
              SizedBox(width: 8),
              ElevatedButton(
                onPressed: () {
                  // Yeni filtreleme işlemleri
                },
                child: Text('Yeni'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAdItemm(BuildContext context, Map<String, dynamic> ad) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
      decoration: BoxDecoration(
        border: Border.all(width: 2, color: Colors.grey),
        borderRadius: BorderRadius.circular(15.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(10.0),
                  child: ad['Image'] != null && ad['Image'].isNotEmpty
                      ? Image.memory(
                          base64Decode(ad['Image']),
                          fit: BoxFit.cover,
                          height: 120,
                          width: 120,
                        )
                      : Placeholder(
                          fallbackHeight: 120,
                          fallbackWidth: 120,
                        ),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        ad['Name'] ?? 'İlan ismi yok',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 5),
                      Text(
                        'Model: ${ad['Model'] ?? 'Model yok'}',
                        style: TextStyle(
                            fontSize: 16, color: Colors.grey.shade600),
                      ),
                      SizedBox(height: 5),
                      Text(
                        '${ad['Price']?.toString() ?? '0'} TL',
                        style: TextStyle(fontSize: 16, color: Colors.green),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10.0),
            child: Text(
              ad['Status'] == 1 ? 'Durum: Yeni' : 'Durum: Etkin',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ),
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 10.0, vertical: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton(
                  onPressed: () {
                    // Satıldı işlemi
                  },
                  child: Text('Satıldı'),
                ),
                ElevatedButton(
                  onPressed: () {
                    // Daha hızlı sat işlemi
                  },
                  child: Text('Daha Hızlı Sat'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAdItem(BuildContext context, Map<String, dynamic> ad) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20.0),
      ),
      elevation: 8,
      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.white, Colors.grey.shade100],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color.fromARGB(111, 0, 0, 0),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'Yayınlanma Tarihi: ${ad['CreatedDateTime'] != null ? DateFormat('dd/MM/yyyy').format(DateTime.parse(ad['CreatedDateTime'])) : 'Bilinmiyor'}',
                      style: TextStyle(fontSize: 11, color: Colors.white),
                    ),
                  ),
                  MenuAnchor(
                    builder: (BuildContext context, MenuController controller,
                        Widget? child) {
                      return IconButton(
                        onPressed: () {
                          if (controller.isOpen) {
                            controller.close();
                          } else {
                            controller.open();
                          }
                        },
                        icon: const Icon(Icons.more_horiz),
                        tooltip: 'Show menu',
                      );
                    },
                    menuChildren: [
                      MenuItemButton(
                        onPressed: () {
                          // İlanı güncelleme işlemi
                          //   _updateAdvert(ad);
                        },
                        child: const Text('İlanı Güncelle'),
                      ),
                      MenuItemButton(
                        onPressed: () {
                          // İlanı kaldırma işlemi
                          _removeAdvert(ad);
                        },
                        child: const Text('İlanı Kaldır'),
                      ),
                      MenuItemButton(
                        onPressed: () {
                          // İlanı kaldırma işlemi
                          _removeAdvert(ad);
                        },
                        child: const Text('Devre Dışı Bırak'),
                      ),
                    ],
                  ),
                ],
              ),
              //SizedBox(height: 8), // Boşluğu azalt
              SizedBox(height: 10),
              Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12.0),
                    child: ad['Image'] != null && ad['Image'].isNotEmpty
                        ? Image.memory(
                            base64Decode(ad['Image']),
                            fit: BoxFit.cover,
                            height: 100,
                            width: 100,
                          )
                        : Container(
                            height: 100,
                            width: 100,
                            decoration: BoxDecoration(
                              color: Colors.grey.shade200,
                              borderRadius: BorderRadius.circular(12.0),
                            ),
                            child: Icon(
                              Icons.image_not_supported,
                              size: 30,
                              color: Colors.grey,
                            ),
                          ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          ad['Name'] ?? 'İlan ismi yok',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        SizedBox(height: 6),
                        Text(
                          'Model: ${ad['Model'] ?? 'Model yok'}',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        SizedBox(height: 6),
                        Text(
                          '${ad['Price']?.toString() ?? '0'} TL',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.green.shade700,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(height: 6),
                        if (ad['Status'] == 1)
                          _buildStatusLabel('Yeni', Colors.blueAccent),
                        if (ad['Status'] == 2)
                          _buildStatusLabel(
                              'Aktif', Colors.greenAccent.shade700),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildActionButton('Satıldı', Icons.check,
                      Colors.orange.shade400, Colors.white),
                  _buildActionButton('Daha Hızlı Sat', Icons.speed,
                      Colors.orange.shade600, Colors.white),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusLabel(String text, Color color) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: Colors.white,
          fontSize: 11,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildActionButton(
      String text, IconData icon, Color backgroundColor, Color textColor) {
    return ElevatedButton.icon(
      onPressed: () {
        // Satıldı işlemi
      },
      icon: Icon(icon, color: textColor),
      label: Text(
        text,
        style: TextStyle(fontSize: 14, color: textColor),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: backgroundColor,
        padding: EdgeInsets.symmetric(vertical: 10, horizontal: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  void _removeAdvert(Map<String, dynamic> ad) {
    // İlan kaldırma işlemleri burada yapılabilir
    print('İlan kaldırıldı: ${ad['Name']}');
  }
}
