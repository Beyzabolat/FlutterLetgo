// ignore_for_file: file_names, prefer_const_constructors_in_immutables, use_super_parameters, library_private_types_in_public_api, prefer_const_constructors, use_build_context_synchronously, avoid_print

import 'package:flutter/material.dart';
import 'package:project/Screens/MessageDetails.dart';
import 'package:project/apihandler.dart';

class Advertdetails extends StatefulWidget {
  final String title;
  final String description;
  final String imageUrl;
  final String category;
  final String brand;
  final String model;
  final double price;
  final String location;
  final int quantity;
  final String advertRef;
  final String clientRef;

  Advertdetails({
    Key? key,
    required this.title,
    required this.description,
    required this.imageUrl,
    required this.category,
    required this.brand,
    required this.model,
    required this.price,
    required this.location,
    required this.quantity,
    required this.advertRef,
    required this.clientRef,
  }) : super(key: key);



  @override
  _AdvertdetailsState createState() => _AdvertdetailsState();
}

class _AdvertdetailsState extends State<Advertdetails> {
  bool isFavorite = false;
  final ApiHandler apiHandler = ApiHandler();
  

  @override
  void initState() {
    super.initState();
    _checkIfFavorite();
    print(widget.advertRef);print(widget.clientRef);
  }

  Future<void> _checkIfFavorite() async {
    try {
      bool result =
          await apiHandler.isAdvertFavorite(widget.advertRef, widget.clientRef);
      setState(() {
        isFavorite = result;
      });
    } catch (error) {
      print('Favori kontrol edilirken hata oluştu: $error');
    }
  }

  Future<void> _addToFavorites() async {
    if (!isFavorite) {
      try {
        await apiHandler.addToFavorites(widget.advertRef, widget.clientRef);
        setState(() {
          isFavorite = true;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Favorilere eklendi.')),
        );
      } catch (error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Favorilere eklenirken hata oluştu.')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Bu ilan zaten favorilerde.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'İlan Detayları',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        backgroundColor: Colors.redAccent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 250,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  image: widget.imageUrl.isNotEmpty
                      ? DecorationImage(
                          image: NetworkImage(widget.imageUrl),
                          fit: BoxFit.cover,
                        )
                      : null,
                  color: widget.imageUrl.isEmpty ? Colors.grey[300] : null,
                ),
                child: widget.imageUrl.isEmpty
                    ? Center(
                        child: Icon(
                          Icons.image,
                          size: 100,
                          color: Colors.grey,
                        ),
                      )
                    : null,
              ),
              SizedBox(height: 16),
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.title,
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      SizedBox(height: 8),
                      _buildInfoRow(
                          Icons.category, widget.category, Colors.redAccent),
                      SizedBox(height: 8),
                      _buildInfoRow(Icons.build,
                          '${widget.brand} ${widget.model}', Colors.blueGrey),
                      SizedBox(height: 8),
                      _buildInfoRow(
                          Icons.attach_money,
                          'Fiyat: ${widget.price.toStringAsFixed(2)} TL',
                          Colors.green),
                      SizedBox(height: 8),
                      _buildInfoRow(Icons.location_on,
                          'Konum: ${widget.location}', Colors.orangeAccent),
                      SizedBox(height: 16),
                      Text(
                        'Açıklama',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        widget.description,
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[800],
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                Messagedetails(clientRef: widget.clientRef),
                          ),
                        );
                      },
                      icon: Icon(Icons.chat_sharp, color: Colors.white),
                      label: Text(
                        'Mesaj Gönder',
                        style: TextStyle(fontSize: 16),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green.shade300,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        padding: EdgeInsets.symmetric(vertical: 14),
                      ),
                    ),
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _addToFavorites,
                      icon: Icon(
                          isFavorite ? Icons.favorite : Icons.favorite_border,
                          color: Colors.white),
                      label: Text(
                        isFavorite ? 'Favorilerde' : 'Favorilere Ekle',
                        style: TextStyle(fontSize: 16),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red.shade300,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        padding: EdgeInsets.symmetric(vertical: 14),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text, Color iconColor) {
    return Row(
      children: [
        Icon(icon, color: iconColor),
        SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
          ),
        ),
      ],
    );
  }
}
