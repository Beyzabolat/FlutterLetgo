// ignore_for_file: file_names, use_super_parameters, library_private_types_in_public_api, avoid_print, prefer_const_constructors, unnecessary_string_interpolations
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:project/Screens/AdvertListScreen.dart';
import 'package:project/Screens/LoginScreen.dart';
import 'package:project/Screens/ProfileDetails.dart';
import 'package:project/Screens/ProfileEditScreen.dart';
import 'package:project/Screens/Settings.dart';
import 'package:project/apihandler.dart';
import 'package:project/constants.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class ProfileScreen extends StatefulWidget {
  final String clientRef;

  const ProfileScreen({Key? key, required this.clientRef}) : super(key: key);

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

String formatDate(String dateStr) {
  try {
    DateTime dateTime = DateTime.parse(dateStr);
    return "${dateTime.day}.${dateTime.month}.${dateTime.year}";
  } catch (e) {
    print("Tarih formatlama hatası: $e");
    return "Geçersiz tarih";
  }
}

class _ProfileScreenState extends State<ProfileScreen> {
  late Future<Map<String, dynamic>> _clientCardFuture;
  String clientName = 'Yükleniyor...';
  String clientPosition =
      'Yükleniyor...';
  String createdTime = ' ';
  String? profileImageBase64;
  @override
  void initState() {
    super.initState();
    _clientCardFuture = ApiHandler().fetchClientCard(widget.clientRef);
    _fetchClientData();
  }

  String formatDate(String dateStr) {
    DateTime dateTime = DateTime.parse(dateStr);
    return "${dateTime.day}.${dateTime.month}.${dateTime.year}";
  }

  final String baseUri = "https://192.168.85.179:7110/api/tables";

  Future<void> _fetchClientData() async {
    try {
      final clientData = await _clientCardFuture;
      setState(() {
        clientName = clientData['Name'] ?? 'İsim yok';
        clientPosition = clientData['Email'] ?? 'Pozisyon yok';
        String? rawDate = clientData['CreatedDateTime'];
        if (rawDate != null && rawDate.isNotEmpty) {
          try {
            DateTime dateTime = DateTime.parse(rawDate);
            createdTime = "${dateTime.day}.${dateTime.month}.${dateTime.year}";
          } catch (e) {
            print("Geçersiz tarih formatı: $e");
            createdTime = 'Bilinmiyor'; 
          }
        } else {
          createdTime = 'Bilinmiyor';
        }
        profileImageBase64 = clientData['Image'];
      });
    } catch (e) {
      print('Hata: $e');
    }
  }

  Future<Map<String, dynamic>> fetchClientCard(String clientRef) async {
    final uri = Uri.parse('$baseUri/ClientCard?Ref=$clientRef');
    try {
      final response = await http.get(uri, headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      });

      if (response.statusCode >= 200 && response.statusCode <= 299) {
        final Map<String, dynamic> jsonData = json.decode(response.body);
        return jsonData;
      } else {
        throw Exception('Müşteri kartı alınırken bir hata oluştu.');
      }
    } catch (e) {
      print('Error : $e');
      return {};
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackGroundColor,
      appBar: AppBar(
        title: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Hesabım',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 1),
              Container(
                height: 1,
                color: Colors.black12,
                width: double.infinity,
              ),
            ],
          ),
        ),
        elevation: 0,
        backgroundColor: kBackGroundColor,
        automaticallyImplyLeading: false,
      ),
      body: ListView(
        padding: const EdgeInsets.all(10),
        children: [
          Column(
            children: [
              Stack(
                alignment: Alignment.bottomRight,
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundImage: profileImageBase64 != null
                        ? MemoryImage(base64Decode(profileImageBase64!))
                        : AssetImage('assets/images/profile.png'),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              ProfileEditScreen(clientRef: widget.clientRef),
                        ),
                      );
                    },
                    child: Container(
                      width: 30,
                      height: 30,
                      decoration: BoxDecoration(
                        color: Color.fromRGBO(100, 10, 120, 30),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.edit, 
                        color: Colors.white,
                        size: 18,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                clientName,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(clientPosition), 
              const SizedBox(height: 5),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.calendar_today, size: 16, color: Colors.grey),
                  const SizedBox(width: 5),
                  Text(
                    'Hesap Oluşturulma Tarihi: $createdTime', 
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 25),
          Row(
            children: const [
              Padding(
                padding: EdgeInsets.only(right: 5),
                child: Text(
                  "Profilinizi tamamlayın",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Text(
                "(1/5)",
                style: TextStyle(
                  color: Color.fromRGBO(100, 10, 120, 30),
                ),
              )
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: List.generate(5, (index) {
              return Expanded(
                child: Container(
                  height: 7,
                  margin: EdgeInsets.only(right: index == 4 ? 0 : 6),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: index == 0
                        ? Color.fromRGBO(100, 10, 120, 147)
                        : Colors.black12,
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: 35),
          ...List.generate(
            customListTiles.length,
            (index) {
              final tile = customListTiles[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: 5),
                child: Card(
                  elevation: 4,
                  shadowColor: Colors.black12,
                  child: _buildProfileOption(tile.icon, tile.title, context,
                      clientRef: widget.clientRef),
                ),
              );
            },
          )
        ],
      ),
    );
  }

  Widget _buildProfileOption(IconData icon, String title, BuildContext context,
      {required String clientRef}) {
    return ListTile(
      leading: Icon(icon, size: 30, color: kTextFieldFill),
      title: Text(title, style: const TextStyle(fontSize: 18)),
      onTap: () {
        if (title == 'Profil Bilgileri') {
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => Profiledetails(clientRef: clientRef)),
          );
        } else if (title == 'İlanlarım') {
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => AdvertListScreen(
                      clientRef: clientRef,
                    )),
          );
        } else if (title == 'Ayarlar') {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => SettingsPage()),
          );
        } else if (title == 'Çıkış Yap') {
          _logout(context); 
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('$title')),
          );
        }
      },
    );
  }
}

class CustomListTile {
  final IconData icon;
  final String title;
  final Function(BuildContext context)? onTap;

  CustomListTile({
    required this.icon,
    required this.title,
    this.onTap,
  });
}

List<CustomListTile> customListTiles = [
  CustomListTile(
    icon: Icons.settings,
    title: "Ayarlar",
    onTap: (context) {
      Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) =>
                SettingsPage()),
      );
    },
  ),
  CustomListTile(
    icon: Icons.location_on_outlined,
    title: "Adreslerim",
    onTap: (context) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Location')),
      );
    },
  ),
  CustomListTile(
    title: "Siparişlerim",
    icon: CupertinoIcons.bell,
    onTap: (context) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Notifications')),
      );
    },
  ),
  CustomListTile(
    title: "Profil Bilgileri",
    icon: Icons.person,
  ),
  CustomListTile(
    title: "Yardım Ve Destek",
    icon: Icons.help,
  ),
  CustomListTile(
    title: "İlanlarım",
    icon: Icons.list,
  ),
  CustomListTile(
    title: "Çıkış Yap",
    icon: CupertinoIcons.arrow_right_arrow_left,
    onTap: (context) {
      _logout(context);
    },
  ),
];

void _logout(BuildContext context) {
  Navigator.pushAndRemoveUntil(
    context,
    MaterialPageRoute(builder: (context) => Loginscreen()),
    (Route<dynamic> route) => false,
  );
}
