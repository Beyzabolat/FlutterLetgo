// ignore_for_file: prefer_const_constructors, no_logic_in_create_state, non_constant_identifier_names, prefer_const_constructors_in_immutables, use_key_in_widget_constructors, unnecessary_string_interpolations, file_names

import 'package:flutter/material.dart';
import 'package:project/Screens/AdvertAddScreen.dart';
import 'package:project/Screens/AdvertListScreen.dart';
import 'package:project/Screens/LoginScreen.dart';
import 'package:project/Screens/ProfileDetails.dart';

class Profilescreen extends StatefulWidget {
  const Profilescreen({super.key});

  @override
  State<Profilescreen> createState() => _ProfilescreenState();
}

_ProfilescreenState() {
}

class ProfileScreen extends StatelessWidget {
  final String clientRef;

  ProfileScreen({required this.clientRef});
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: 40),
              CircleAvatar(
                radius: 60,
                backgroundImage: AssetImage('assets/profile.png'),
              ),
              SizedBox(height: 20),
              Text(
                'Kullanıcı Adı',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 10),
              Text(
                'kullanici@example.com',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.grey,
                ),
              ),
              SizedBox(height: 20),
              _buildProfileOption(Icons.person, 'Profil Bilgileri', context),
              _buildProfileOption(Icons.add_box, 'İlan Ver', context),
              _buildProfileOption(Icons.receipt, 'İlanlarım', context),
              _buildProfileOption(Icons.exit_to_app, 'Çıkış Yap', context, isLogout: true),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileOption(IconData icon, String title, BuildContext context, {bool isLogout = false}) {
    return ListTile(
      leading: Icon(icon, size: 30, color: Colors.redAccent),
      title: Text(title, style: TextStyle(fontSize: 18)),
      onTap: () {
        if (isLogout) {
          _logout(context);
        } else if (title == 'Profil Bilgileri') {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => Profiledetails(clientRef: clientRef)),
          );
        } else if (title == 'İlan Ver') {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AdvertAddScreen(clientRef: clientRef, categoryRef: 'Ref',)),
          );
        } else if (title == 'İlanlarım') {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AdvertListScreen(clientRef: clientRef,)),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('$title')),
          );
        }
      },
    );
  }

  void _logout(BuildContext context) {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => Loginscreen()),
      (Route<dynamic> route) => false,
    );
  }
}