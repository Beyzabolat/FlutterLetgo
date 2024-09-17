// ignore_for_file: prefer_const_constructors, no_logic_in_create_state, non_constant_identifier_names, file_names, use_key_in_widget_constructors

import 'package:flutter/material.dart';

class MyWidget extends StatefulWidget {
  const MyWidget({super.key});

  @override
  State<MyWidget> createState() => _MyWidgetState();
}

_MyWidgetState() {
}

class FavoritesScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Favoriler',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 10),
          Expanded(
            child: ListView.builder(
              itemCount: 5,
              itemBuilder: (context, index) {
                return _buildFavoriteItem(
                  context,
                  'Ürün ${index + 1}',
                  'Açıklama ${index + 1}',
                  Icons.favorite_border,
                  Colors.red,
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFavoriteItem(BuildContext context, String title, String subtitle, IconData icon, Color color) {
    return Card(
      child: ListTile(
        leading: Icon(icon, color: color),
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: IconButton(
          icon: Icon(Icons.remove_circle_outline),
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('$title favorilerden kaldırıldı')),
            );
          },
        ),
      ),
    );
  }
}