// ignore_for_file: library_private_types_in_public_api, prefer_const_literals_to_create_immutables, prefer_const_constructors, file_names

import 'package:flutter/material.dart';
import 'package:project/apihandler.dart';

class FavoritesScreen extends StatefulWidget {
  final String clientRef; 

  const FavoritesScreen({super.key, required this.clientRef});

  @override
  _FavoritesScreenState createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  late Future<List<dynamic>> favoritesFuture;

  @override
  void initState() {
    super.initState();
    favoritesFuture = ApiHandler().fetchFavoritesByClientRef(widget.clientRef);
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            'İlanlarım ve Favorilerim',
            style: TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          elevation: 0,
          backgroundColor: Colors.white,
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
          return Center(child: Text('Favori ürünler yüklenirken hata oluştu'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(child: Text('Favori ürün bulunamadı'));
        }

        final favorites = snapshot.data!;
        return ListView.builder(
          itemCount: favorites.length,
          itemBuilder: (context, index) {
            final item = favorites[index];
            return _buildFavoriteItem(
              context,
              item['Name'] ?? 'Ürün',
              item['Description'] ?? 'Açıklama',
              Icons.favorite_border,
              Colors.red,
            );
          },
        );
      },
    );
  }

  Widget _buildAdvertisementsTab(BuildContext context) {
    return ListView.builder(
      itemCount: 5,
      itemBuilder: (context, index) {
        return _buildAdvertisementItem(
          context,
          'İlan ${index + 1}',
          'Açıklama ${index + 1}',
          Icons.business,
          Colors.blue,
        );
      },
    );
  }

  Widget _buildFavoriteItem(BuildContext context, String title, String subtitle, IconData icon, Color color) {
    return Card(
      elevation: 5,
      margin: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: ListTile(
        contentPadding: EdgeInsets.all(15),
        leading: CircleAvatar(
          backgroundColor: color.withOpacity(0.2),
          child: Icon(icon, color: color),
        ),
        title: Text(title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        subtitle: Text(subtitle, style: TextStyle(color: Colors.grey[600])),
        trailing: IconButton(
          icon: Icon(Icons.remove_circle_outline, color: Colors.red),
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('$title favorilerden kaldırıldı')),
            );
          },
        ),
      ),
    );
  }

  Widget _buildAdvertisementItem(BuildContext context, String title, String subtitle, IconData icon, Color color) {
    return Card(
      elevation: 5,
      margin: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: ListTile(
        contentPadding: EdgeInsets.all(15),
        leading: CircleAvatar(
          backgroundColor: color.withOpacity(0.2),
          child: Icon(icon, color: color),
        ),
        title: Text(title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        subtitle: Text(subtitle, style: TextStyle(color: Colors.grey[600])),
      ),
    );
  }
}