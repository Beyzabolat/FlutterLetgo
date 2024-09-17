// ignore_for_file: prefer_const_literals_to_create_immutables, prefer_const_constructors, sized_box_for_whitespace, use_key_in_widget_constructors, unused_import, file_names, prefer_const_constructors_in_immutables, library_private_types_in_public_api, avoid_print, prefer_interpolation_to_compose_strings

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:io';
import 'package:project/ApiHandler.dart';
import 'package:project/Screens/AdvertAddScreen.dart';
import 'package:project/Screens/AdvertListScreen.dart';
import 'package:project/Screens/CategoryProductsScreen.dart';
import 'package:project/Screens/FavoriteScreen.dart';
import 'package:project/Screens/LoginScreen.dart';
import 'package:project/Screens/MessageScreen.dart';
import 'package:project/Screens/ProfileDetails.dart';
import 'package:project/Screens/ProfileScreen.dart';


void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Navigation Bar',
      theme: ThemeData(
        primarySwatch: Colors.red,
      ),
      home: MyHomePage(clientRef: ''),
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
      HomeScreen(),
      FavoritesScreen(),
      Messagescreen(),
      ProfileScreen(clientRef: widget.clientRef),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, 
      appBar: AppBar(
        title: Text('Benim Parçam'),
           backgroundColor: Colors.red, // Optional: Set the AppBar color
      ),
      body: _tabs[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (int index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home, size: 28),
            label: 'Ana Sayfa',
            tooltip: 'Ana Sayfa',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite, size: 28),
            label: 'Favoriler',
            tooltip: 'Favoriler',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.message, size: 28),
            label: 'Mesajlar',
            tooltip: 'Mesajlar',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person, size: 28),
            label: 'Profil',
            tooltip: 'Profil',
          ),
        ],
        selectedItemColor: Colors.redAccent,
        unselectedItemColor: Colors.grey[600],
        backgroundColor: Colors.white,
        type: BottomNavigationBarType.fixed,
        showUnselectedLabels: true,
        showSelectedLabels: true,
        selectedLabelStyle: TextStyle(fontWeight: FontWeight.bold),
        unselectedLabelStyle: TextStyle(fontWeight: FontWeight.normal),
        elevation: 8.0,
      ),
    );
  }
}

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
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
        ads = List<Map<String, dynamic>>.from(response).where((ad) => ad['status'] != 0).toList();
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
    return ListView(
      padding: EdgeInsets.all(16.0),
      children: [
        Text(
          'Kategoriler',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 10),
       Container(
  height: 100,
  child: SingleChildScrollView(
    scrollDirection: Axis.horizontal,
    child: Row(
      children: categories.map((category) {
        return _buildCategoryCard(
          category['Name'] ?? 'Kategori',
          Icons.category,
          Colors.red,
          context,
          category,
        );
      }).toList(),
    ),
  ),
),

        SizedBox(height: 20),
        Text(
          'Ürünler',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 10),
        TextField(
          controller: searchController,
          decoration: InputDecoration(
            hintText: 'Arama yapın..',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20.0),
            ),
            prefixIcon: Icon(Icons.search),
          ),
        ),
        SizedBox(height: 10),
        GridView.builder(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 10.0,
            mainAxisSpacing: 10.0,
            childAspectRatio: 0.75,
          ),
          itemCount: filteredAds.length,
          itemBuilder: (BuildContext context, int index) {
            final ad = filteredAds[index];
            return _buildProductCard(
              ad['Name'] ?? 'error',
              (ad['Price'] ?? 0).toString() + ' TL',
              ad['Image'] ?? '',
              Icons.shopping_bag,
              Colors.blueAccent,
              context,
            );
          },
        ),
      ],
    );
  }

  Widget _buildCategoryCard(String title, IconData icon, Color color, BuildContext context, Map<String, dynamic> category) {
  return Container(
    width: 150,
    margin: EdgeInsets.only(right: 10),
    decoration: BoxDecoration(
      color: color.withOpacity(0.2),
      borderRadius: BorderRadius.circular(10),
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
            ),
          ),
        );
      },
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 40, color: color),
          SizedBox(height: 10),
          Text(
            title,
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    ),
  );
}

  Widget _buildProductCard(String title, String description, String imageUrl, IconData icon, Color color, BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
      child: Column(
        children: [
          Expanded(
            child: imageUrl.isNotEmpty
                ? Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.vertical(top: Radius.circular(15.0)),
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

extension on ApiHandler {
  // ignore: unused_element
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