import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:project/ApiHandler.dart';
import 'package:project/Screens/AdvertDetails.dart';
import 'package:project/constants.dart';

class AllAdsScreen extends StatefulWidget {
  final String clientRef;

  AllAdsScreen({required this.clientRef}); // clientRef'i al

  @override
  _AllAdsScreenState createState() => _AllAdsScreenState();
}

class _AllAdsScreenState extends State<AllAdsScreen> {
  List<Map<String, dynamic>> ads = [];
  List<Map<String, dynamic>> filteredAds = [];
  TextEditingController searchController = TextEditingController();
  bool _isSearchEnabled = false;

  String _selectedSortOption =
      'Fiyata Göre Artan'; // Varsayılan sıralama seçeneği

  @override
  void initState() {
    super.initState();
    _loadAds(); // İlanları yükle
    searchController.addListener(_searchController); // Arama dinleyicisi ekle
  }

  Future<void> _loadAds() async {
    try {
      final response = await ApiHandler().fetchAds(); // API'den ilanları al
      setState(() {
        ads = List<Map<String, dynamic>>.from(response)
            .where((ad) => ad['Status'] != 0) // Aktif ilanları filtrele
            .toList();
        filteredAds = ads; // İlk başta tüm ilanları göster
      });
    } catch (e) {
      print('Error loading ads: $e'); // Hata mesajını yazdır
    }
  }

  void _searchController() {
    final query = searchController.text.toLowerCase().trim();
    setState(() {
      filteredAds = ads.where((ad) {
        final name = (ad['Name'] ?? '').toLowerCase();
        return name.contains(query); // Arama koşulunu kontrol et
      }).toList();
      _sortAds(); // Arama yapıldığında sıralamayı yeniden uygula
    });
  }

  void _sortAds() {
    setState(() {
      if (_selectedSortOption == 'Fiyata Göre Artan') {
        filteredAds
            .sort((a, b) => (a['Price'] ?? 0).compareTo(b['Price'] ?? 0));
      } else if (_selectedSortOption == 'Fiyata Göre Azalan') {
        filteredAds
            .sort((a, b) => (b['Price'] ?? 0).compareTo(a['Price'] ?? 0));
      } else if (_selectedSortOption == 'Tarihe Göre') {
        filteredAds.sort((a, b) => (b['CreatedAt'] ?? DateTime.now())
            .compareTo(a['CreatedAt'] ?? DateTime.now()));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackGroundColor,
      appBar: AppBar(
        backgroundColor: kBackGroundColor,
        title: Text('Tüm İlanlar'),
        actions: [
          IconButton(
            icon: Icon(_isSearchEnabled ? Icons.close : Icons.search),
            onPressed: () {
              setState(() {
                _isSearchEnabled = !_isSearchEnabled;
                if (!_isSearchEnabled) {
                  searchController.clear();
                  filteredAds = ads; // Arama kapatıldığında tüm ilanları göster
                }
              });
            },
          ),
        ],
      ),
      body: Column(
        children: [
          if (_isSearchEnabled)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                controller: searchController,
                decoration: InputDecoration(
                  hintText: 'Arama yap...',
                  border: OutlineInputBorder(),
                ),
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Sırala:', style: TextStyle(fontWeight: FontWeight.bold)),
                DropdownButton<String>(
                  value: _selectedSortOption,
                  onChanged: (String? newValue) {
                    setState(() {
                      _selectedSortOption = newValue!;
                      _sortAds(); // Sıralama seçeneği değiştiğinde sıralamayı uygula
                    });
                  },
                  items: <String>[
                    'Fiyata Göre Artan',
                    'Fiyata Göre Azalan',
                    'Tarihe Göre',
                  ].map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
          Expanded(
            child: filteredAds.isEmpty
                ? Center(child: Text('Sonuç bulunamadı'))
                : GridView.builder(
                    padding: const EdgeInsets.all(16),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      childAspectRatio: 2 / 3,
                    ),
                    itemCount: filteredAds.length,
                    itemBuilder: (context, index) {
                      final ad = filteredAds[index];
                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => Advertdetails(
                                clientRef: widget.clientRef,
                                advertRef: ad['Ref'] ?? '',
                                title: ad['Name'] ?? 'Başlık',
                                description: ad['Description'] ?? 'Açıklama',
                                imageUrl: ad['Images'] is String
                                    ? [ad['Images']]
                                    : ad['Images'] ?? [],
                                category: ad['Category'] ?? 'Kategori',
                                brand: ad['Brand'] ?? 'Marka',
                                model: ad['Model'] ?? 'Model',
                                price: ad['Price']?.toDouble() ?? 0.0,
                                location: ad['Location'] ?? 'Konum',
                                quantity: ad['Quantity'] ?? 0,
                              ),
                            ),
                          );
                        },
                        child: _buildProductCard(
                          ad['Name'] ?? 'Hata: Başlık Yok',
                          (ad['Price']?.toString() ?? '0') + ' TL',
                          ad['Location'] ?? 'Konum',
                          ad['Image'] ?? 'assets/screwdriver.png',
                          Icons.shopping_cart,
                          Colors.grey.shade100,
                          context,
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductCard(String title, String price, String location,
      String imageUrl, IconData icon, Color color, BuildContext context) {
    return ClipRRect(
      borderRadius:
          BorderRadius.circular(15.0), // Hem üst hem de alt köşeleri yuvarla
      child: Card(
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
                        style: TextStyle(
                            fontSize: 12, color: Colors.grey.shade700),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
