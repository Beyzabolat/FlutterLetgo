// ignore_for_file: prefer_const_constructors, use_key_in_widget_constructors, non_constant_identifier_names, file_names, no_logic_in_create_state

import 'package:flutter/material.dart';
import 'messagedetails.dart'; // Mesaj detayları sayfanızın importu

class Messagescreen extends StatefulWidget {
  const Messagescreen({super.key});

  @override
  State<Messagescreen> createState() => _MessagescreenState();
}

class _MessagescreenState extends State<Messagescreen> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Mesajlar',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 10),
          Expanded(
            child: ListView.builder(
              itemCount: 5, 
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => Messagedetails(
                        ),
                      ),
                    );
                  },
                  child: _buildMessageItem(
                    context,
                    'Mesaj ${index + 1}',
                    'Mesaj içeriği ${index + 1}',
                    Icons.message,
                    Colors.red,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageItem(BuildContext context, String title, String subtitle, IconData icon, Color color) {
    return Card(
      child: ListTile(
        leading: Icon(icon, color: color),
        title: Text(title),
        subtitle: Text(subtitle),
      ),
    );
  }
}