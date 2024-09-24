// ignore_for_file: prefer_const_literals_to_create_immutables, prefer_const_constructors, sized_box_for_whitespace, use_key_in_widget_constructors, unused_import, file_names, prefer_const_constructors_in_immutables, library_private_types_in_public_api, avoid_print, prefer_interpolation_to_compose_strings, unused_element

import 'dart:convert';
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
    print('ClientRef: ${widget.clientRef}');

    _tabs.addAll([
      HomePage(clientRef: widget.clientRef),
      FavoritesScreen(),
      Messagescreen(),
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
        selectedItemColor:Color.fromRGBO(255, 145, 77, 1), 
      unselectedItemColor: Color.fromRGBO(255, 145, 77, 1), 
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: "Home",
           
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite_border),
            label: "Favorites",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.chat_bubble_outline_outlined),
            label: "Messages",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: "Profile",
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
                  categoryRef:
                      'Ref', 
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
        backgroundColor:  const Color(0xff151617),
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
      body: Homescreen(
        clientRef: '',
      ), 
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
  List<Map<String, dynamic>> categories = [];
  List<Map<String, dynamic>> ads = [];
  List<Map<String, dynamic>> filteredAds = [];
  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadCategories();
    _loadAds();

    searchController.addListener(() {
      _filterAds();
    });
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
            .where((ad) => ad['status'] != 0)
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
        Icons.category, // You can change this to an appropriate icon
        Color.fromRGBO(255, 145, 77, 1), // You can customize the color
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
  height: 220,
  child: ListView.separated(
    scrollDirection: Axis.horizontal,
    padding: const EdgeInsets.only(left: 16),
    itemBuilder: (context, index) {
       final ad = filteredAds[index];

      return GestureDetector(
        onTap: () {
          // Navigate to product detail page
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
        child: SizedBox(
          width: 200,
          child: _buildProductCard(
            ad['Name'] ?? 'error',
            (ad['Price'] ?? 0).toString() + ' TL',
            ad['Image'] ?? 'assets/screwdriver.png', // Default image if no image URL
            Icons.shopping_cart, // Default icon if needed
            Colors.grey.shade100, // Default color for background
            context,
          ),
        ),
      );
    },
    separatorBuilder: (context, index) => const SizedBox(width: 15),
    itemCount: ads.length,
  ),
)
            ],
          ),
        )
      ],
    );
  }
// Product Card Function
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
 Widget _buildCategoryCard(String title, IconData icon, Color color, BuildContext context, Map<String, dynamic> category) {
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
            'assets/screwdriver.png', // Replace with category-specific image if available
            width: 50,
          ),
          SizedBox(height: 4), // Adjusted height for better spacing
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
