// ignore_for_file: prefer_const_constructors, use_key_in_widget_constructors, avoid_print, file_names, non_constant_identifier_names

import 'package:flutter/material.dart';
import 'package:project/apihandler.dart';

class Profiledetails extends StatefulWidget {
  final String clientRef;

  const Profiledetails({required this.clientRef});
  
  @override
  State<Profiledetails> createState() => _ProfiledetailsState();
}

class _ProfiledetailsState extends State<Profiledetails> {
  late Future<Map<String, dynamic>> _clientCardFuture;

  @override
  void initState() {
    super.initState();
    print('ClientRef: ${widget.clientRef}');
    _clientCardFuture = ApiHandler().fetchClientCard(widget.clientRef);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profil', style: TextStyle(fontSize: 20)),
        backgroundColor: Colors.red,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: FutureBuilder<Map<String, dynamic>>(
          future: _clientCardFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Bir hata oluştu: ${snapshot.error}'));
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return Center(child: Text('Müşteri bilgileri bulunamadı.'));
            }

            final clientData = snapshot.data!;
            final Name = clientData['Name'] ?? 'İsim yok';
            final userName = clientData['UserName'] ?? 'Kullanıcı Adı';
            final email = clientData['Email'] ?? 'kullanici@mail.com';
            final phone = clientData['Phone'] ?? 'Telefon Bilgisi Yok';
            final address = clientData['Address'] ?? 'Adres Bilgisi Yok';
            final fax = clientData['Fax'] ?? 'Fax Bilgisi Yok';
            final description = clientData['Description'] ?? 'Açıklama Yok';
            final isPassive = clientData['IsPassive'] ?? false;

            return SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(height: 20),
                  Center(
                    child: CircleAvatar(
                      radius: 60,
                      backgroundImage: AssetImage('assets/profile.png'),
                      backgroundColor: Colors.grey[200],
                    ),
                  ),
                  SizedBox(height: 20),
                  Text(
                    userName,
                    style: TextStyle(
                      fontSize: 28, 
                      fontWeight: FontWeight.bold,
                      color: Colors.black87
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    email,
                    style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                  ),
                  SizedBox(height: 20),
                  Card(
                    elevation: 5,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    margin: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ProfileInfoRow(icon: Icons.factory, title: 'İşletme', value: Name),
                          Divider(),
                          ProfileInfoRow(icon: Icons.phone, title: 'Telefon', value: phone),
                          Divider(),
                          ProfileInfoRow(icon: Icons.home, title: 'Adres', value: address),
                          Divider(),
                          ProfileInfoRow(icon: Icons.fax, title: 'Fax', value: fax),
                          Divider(),
                          ProfileInfoRow(icon: Icons.description, title: 'Açıklama', value: description),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                  Text(
                    isPassive ? 'Pasif' : 'Aktif',
                    style: TextStyle(
                      fontSize: 16,
                      color: isPassive ? Colors.red : Colors.green,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 30),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class ProfileInfoRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;

  const ProfileInfoRow({required this.icon, required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: Colors.red, size: 30),
        SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              Text(
                value,
                style: TextStyle(fontSize: 16, color: Colors.grey[700]),
              ),
            ],
          ),
        ),
      ],
    );
  }
}