// ignore_for_file: prefer_const_literals_to_create_immutables, prefer_const_constructors, sized_box_for_whitespace, use_key_in_widget_constructors, unused_import, file_names, prefer_const_constructors_in_immutables, library_private_types_in_public_api, avoid_print, prefer_interpolation_to_compose_strings, unused_element, prefer_final_fields, unused_field, use_build_context_synchronously, unused_label, unused_local_variable

import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_iconly/flutter_iconly.dart';
import 'package:http/http.dart' as http;
import 'package:project/ApiHandler.dart';
import 'package:project/Screens/AdvertAddScreen.dart';
import 'package:project/Screens/AdvertDetails.dart';
import 'package:project/Screens/AdvertListScreen.dart';
import 'package:project/Screens/CategoryProductsScreen.dart';
import 'package:project/Screens/FavoriteScreen.dart';
import 'package:project/Screens/LoginScreen.dart';
import 'package:project/Screens/MessageScreen.dart';
import 'package:project/Screens/ProfileDetails.dart';
import 'package:project/Screens/ProfileScreen.dart';
import 'package:project/constants.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: MyHomePage(clientRef: 'your_client_ref_here'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  final String clientRef;
  MyHomePage({required this.clientRef});
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _currentIndex = 0;

  final List<Widget> _tabs = [];

  @override
  void initState() {
    super.initState();
    _tabs.addAll([
      HomePage(clientRef: widget.clientRef),
      FavoritesScreen(clientRef: widget.clientRef),
      Messagescreen(clientRef: widget.clientRef),
      ProfileScreen(clientRef: widget.clientRef),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: _tabs[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (int index) {
          setState(() {
            _currentIndex = index;
          });
        },
        showSelectedLabels: false,
        showUnselectedLabels: false,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Color.fromRGBO(255, 145, 77, 1),
        unselectedItemColor: Color.fromRGBO(255, 145, 77, 1),
        items: [
          BottomNavigationBarItem(
            icon: _currentIndex == 0
                ? Icon(Icons.home, color: Color.fromRGBO(255, 145, 77, 1))
                : Icon(Icons.home_outlined,
                    color: Color.fromRGBO(255, 145, 77, 1)),
            label: 'Ana Sayfa',
            tooltip: 'Ana Sayfa',
          ),
          BottomNavigationBarItem(
            icon: _currentIndex == 1
                ? Icon(Icons.favorite, color: Color.fromRGBO(255, 145, 77, 1))
                : Icon(Icons.favorite_border,
                    color: Color.fromRGBO(255, 145, 77, 1)),
            label: 'Favoriler',
            tooltip: 'Favoriler',
          ),
          BottomNavigationBarItem(
            icon: _currentIndex == 2
                ? Icon(Icons.chat_bubble,
                    color: Color.fromRGBO(255, 145, 77, 1))
                : Icon(Icons.chat_bubble_outline,
                    color: Color.fromRGBO(255, 145, 77, 1)),
            label: 'Mesajlar',
            tooltip: 'Mesajlar',
          ),
          BottomNavigationBarItem(
            icon: _currentIndex == 3
                ? Icon(Icons.person, color: Color.fromRGBO(255, 145, 77, 1))
                : Icon(Icons.person_outline,
                    color: Color.fromRGBO(255, 145, 77, 1)),
            label: 'Profil',
            tooltip: 'Profil',
          ),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.red.withOpacity(0.2),
              spreadRadius: 5,
            )
          ],
        ),
        child: FloatingActionButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => AdvertAddScreen(
                  clientRef: widget.clientRef,
                  categoryRef: 'Ref',
                ),
              ),
            );
          },
          elevation: 0,
          backgroundColor: const Color.fromRGBO(255, 145, 77, 1),
          foregroundColor: Colors.white,
          child: const Icon(Icons.add),
        ),
      ),
    );
  }
}

class HomePage extends StatelessWidget {
  final String clientRef;
  HomePage({required this.clientRef});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: const Color(0xff151617),
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: const Color(0xff151617),
        foregroundColor: Colors.white,
        leading:
            IconButton(onPressed: () {}, icon: const Icon(IconlyLight.search)),
        title: ActionChip(
          label: const Text("Konum Giriniz"),
          shape: const StadiumBorder(),
          backgroundColor: const Color(0xff272b30),
          labelStyle: const TextStyle(color: Colors.white),
          avatar: const Icon(IconlyLight.location, color: Colors.white),
          side: const BorderSide(width: 0),
          onPressed: () {},
        ),
        actions: [
          IconButton(
            onPressed: () {},
            icon: Badge(
              backgroundColor: theme.colorScheme.primary,
              alignment: const Alignment(1, -1.5),
              child: const Icon(IconlyLight.notification),
            ),
          ),
        ],
      ),
      body: Homescreen(clientRef: clientRef),
    );
  }
}

class Homescreen extends StatefulWidget {
  final String clientRef;
  Homescreen({required this.clientRef});
  @override
  _HomePageBodyState createState() => _HomePageBodyState();
}

class _HomePageBodyState extends State<Homescreen> {
  bool _isSearchEnabled = false;
  TextEditingController searchController = TextEditingController();
  List<Map<String, dynamic>> categories = [];
  List<Map<String, dynamic>> ads = [];
  List<Map<String, dynamic>> filteredAds = [];
  Set<String> favoriteAdvertRefs = {};
  bool isFavorite = false;
  final ApiHandler apiHandler = ApiHandler();
  List<Map<String, dynamic>> favoriteAds = [];
  List<dynamic> favoriteAdss = [];

  Future<void> addToFavorites(String advertRef, String clientRef) async {
    setState(() {
      if (!favoriteAds.any((fav) => fav['AdvertRef'] == advertRef)) {
        favoriteAds.add({
          'AdvertRef': advertRef,
          'ClientRef': clientRef,
        });
      } else {
        favoriteAds.removeWhere((fav) => fav['AdvertRef'] == advertRef);
        favoriteAds.remove({
          'AdvertRef': advertRef,
          'ClientRef': clientRef,
        });
      }
    });
  }

  @override
  void initState() {
    super.initState();
    _loadCategories();
    _loadAds();
    loadFavorites(widget.clientRef);
    searchController.addListener(() {
      _filterAds();
    });
  }

  Future<void> _toggleFavorite(String advertRef, String clientRef) async {
    try {
      bool isFavorite = favoriteAds.any((fav) => fav['AdvertRef'] == advertRef);

      if (isFavorite) {
        await apiHandler.removeFromFavorites(advertRef, clientRef);

        setState(() {
          favoriteAds.removeWhere((fav) => fav['AdvertRef'] == advertRef);
        });
        
      } else {
        await apiHandler.addToFavorites(advertRef, clientRef);

        setState(() {
          favoriteAds.add({'AdvertRef': advertRef, 'ClientRef': clientRef});
        });
        
      }

      await loadFavorites(clientRef);
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(
                'Favori işlemi sırasında bir hata oluştu: ${error.toString()}')), // Hata detayını göster
      );
    }
  }

  Future<void> loadFavorites(String clientRef) async {
    try {
      List<Map<String, dynamic>> favorites =
          await apiHandler.getFavorites(clientRef);

      if (favorites.isNotEmpty) {
      } else {
        print('Favori yok veya yüklenemedi.');
      }
      setState(() {
        favoriteAds = favorites;
      });
    } catch (e) {
      print('Favoriler yüklenemedi: $e');
    }
  }

  Future<void> _loadCategories() async {
    try {
      final response = await ApiHandler().fetchCategories();
      setState(() {
        categories = List<Map<String, dynamic>>.from(response);
      });
    } catch (e) {
      print('Error loading categories: $e');
    }
  }

  Future<void> _loadAds() async {
    try {
      final response = await ApiHandler().fetchAds();
      setState(() {
        ads = List<Map<String, dynamic>>.from(response)
            .where((ad) => ad['Status'] != 0)
            .toList();
        filteredAds = ads;
      });
    } catch (e) {
      print('Error loading ads: $e');
    }
  }

  void _filterAds() {
    final query = searchController.text.toLowerCase();
    setState(() {
      filteredAds = ads.where((ad) {
        final name = (ad['Name'] ?? '').toLowerCase();
        return name.contains(query);
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ListView(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Text(
                  "Kategoriler",
                  style: theme.textTheme.headlineMedium
                      ?.copyWith(color: Colors.white),
                ),
              ),
              SizedBox(
                height: 100,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemBuilder: (context, index) {
                    final category = categories[index];
                    return _buildCategoryCard(
                      category['Name'] ?? 'Kategori',
                      Icons.category,
                      Color.fromRGBO(255, 145, 77, 1),
                      context,
                      category,
                    );
                  },
                  separatorBuilder: (context, index) =>
                      const SizedBox(width: 15),
                  itemCount: categories.length,
                ),
              )
            ],
          ),
        ),
        Container(
          margin: const EdgeInsets.only(top: 10),
          constraints: BoxConstraints(
              minHeight: MediaQuery.of(context).size.height * 0.7),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "İlanlar",
                      style: theme.textTheme.titleLarge
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    TextButton.icon(
                      onPressed: () {},
                      icon: const Text("Tümünü Gör"),
                      label: const Icon(IconlyLight.arrowRight2, size: 20),
                    )
                  ],
                ),
              ),
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.6,
                child: GridView.builder(
                  padding: const EdgeInsets.all(16),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 2 / 3,
                  ),
                  itemCount: filteredAds.length,
                  itemBuilder: (context, index) {
                    final ad = filteredAds[index];
                    bool isFavorite = favoriteAdvertRefs.contains(ad['Ref']);
                    return GestureDetector(
                      behavior: HitTestBehavior.translucent,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => Advertdetails(
                              clientRef: widget.clientRef,
                              advertRef: ad['Ref'] ?? '',
                              title: ad['Name'] ?? 'Başlık',
                              description: ad['Description'] ?? 'Açıklama',
                              imageUrl: ad['Image'] ?? '',
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
                      child: Stack(
                        alignment: Alignment.topRight,
                        children: [
                          _buildProductCard(
                            ad['Name'] ?? 'Hata: Başlık Yok',
                            (ad['Price']?.toString() ?? '0') + ' TL',
                            ad['Location'] ?? 'Konum',
                            ad['Image'] ?? 'assets/screwdriver.png',
                            Icons.shopping_cart,
                            Colors.grey.shade100,
                            context,
                          ),
                          Positioned(
                            top: 8,
                            right: 8,
                            child: IconButton(
                              icon: Icon(
                                favoriteAds.any(
                                        (fav) => fav['AdvertRef'] == ad['Ref'])
                                    ? Icons.favorite
                                    : Icons.favorite_border,
                                color: favoriteAds.any(
                                        (fav) => fav['AdvertRef'] == ad['Ref'])
                                    ? Colors.red
                                    : Colors.grey,
                              ),
                              onPressed: () async {
                                String advertRef = ad['Ref'];
                                String clientRef = ad['ClientRef'];
                                await _toggleFavorite(advertRef, clientRef);
                                await loadFavorites(clientRef);
                              },
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              )
            ],
          ),
        )
      ],
    );
  }

  void _showImageDialog(String base64Image) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        Uint8List imageBytes =
            base64Decode(base64Image); // Base64'ü decode ediyoruz
        return Dialog(
          child: imageBytes.isNotEmpty
              ? Image.memory(
                  imageBytes,
                  fit: BoxFit.cover,
                )
              : Placeholder(fallbackHeight: 300, fallbackWidth: 300),
        );
      },
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
                    height: 100,
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

  Widget _buildCategoryCard(String title, IconData icon, Color color,
      BuildContext context, Map<String, dynamic> category) {
    return Container(
      height: double.maxFinite,
      width: 100,
      margin: EdgeInsets.only(right: 10),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Color.fromRGBO(255, 145, 77, 1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CategoryProductsScreen(
                categoryName: title,
                categoryRef: category['Ref'],
                allAds: ads,
                clientRef: widget.clientRef,
              ),
            ),
          );
        },
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/screwdriver.png',
              width: 50,
            ),
            SizedBox(height: 4),
            Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}

extension on ApiHandler {
  fetchAds() async {
    final uri = Uri.parse('$baseUri/Advert');
    try {
      final response = await client.get(uri, headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      });
      return json.decode(response.body);
    } catch (e) {
      print('Error fetching ads: $e');
      return [];
    }
  }
}
