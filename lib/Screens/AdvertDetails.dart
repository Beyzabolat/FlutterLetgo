// ignore_for_file: file_names, prefer_const_constructors_in_immutables, use_super_parameters, library_private_types_in_public_api, prefer_const_constructors, use_build_context_synchronously, avoid_print, sized_box_for_whitespace, unused_import, unnecessary_brace_in_string_interps, unnecessary_null_comparison, unnecessary_type_check

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:project/Screens/MessageDetails.dart';
import 'package:project/apihandler.dart';
import 'package:project/constants.dart';
import 'package:http/http.dart' as http;

class Advertdetails extends StatefulWidget {
  final String title;
  final String description;
  final List<String>
      imageUrl; 
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
  List<String> imageList = [];

  @override
  void initState() {
    super.initState();
    _checkIfFavorite();
    fetchImages();
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

  Future<void> fetchImages() async {
    try {
      final response = await http.get(
        Uri.parse(
            'https://192.168.1.104:7110/api/Tables/Advert?Ref=${widget.advertRef}'),
      );
      if (response.statusCode == 200) {
        print("API Yanıtı: ${response.body}");
        final jsonResponse = json.decode(response.body);
        if (jsonResponse is List) {
          List<String> images = [];
          jsonResponse.forEach((ad) {
            if (ad['Ref'] == widget.advertRef) {
              String image = ad['Image'] as String;
              if (image.isNotEmpty) {
                images.addAll(List<String>.generate(5, (_) => image));
              }
            }
          });
          setState(() {
            imageList = images;
          });
        } else {
          print("Gelen yanıt beklenen formatta değil.");
        }
      } else {
        throw Exception('Görseller yüklenemedi: ${response.statusCode}');
      }
    } catch (error) {
      print("Hata: $error");
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
        title: Text('İlan Detayları'),
        actions: [
          IconButton(
            icon: Icon(
              isFavorite ? Icons.favorite : Icons.favorite_border,
              color: Colors.white,
            ),
            onPressed: _addToFavorites,
          ),
        ],
      ),
      body: ListView(
        children: <Widget>[
          Stack(
            children: <Widget>[
              Container(
                color: Colors.white,
                child: Column(
                  children: <Widget>[
                    Stack(
                      children: <Widget>[
                        CarouselSlider(
                          options: CarouselOptions(
                            height: 320.0,
                            viewportFraction: 1.0,
                            enableInfiniteScroll: false,  autoPlay: true, // Otomatik geçiş ekledik.
                          autoPlayInterval: Duration(seconds: 3),
                          ),
                          items: imageList.map((base64Image) {
                            try {
                              return Image.memory(
                                base64Decode(
                                    base64Image), // Base64'ü binary veriye çevirir.
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Center(
                                    child: Icon(Icons.broken_image,
                                        size: 100, color: Colors.grey),
                                  );
                                },
                              );
                            } catch (e) {
                              print("Görsel yükleme hatası: $e");
                              return Center(
                                child: Icon(Icons.broken_image,
                                    size: 100, color: Colors.grey),
                              );
                            }
                          }).toList(),
                        ),
                      ],
                    ),

                    // Product Details Section
                    Container(
                      width: MediaQuery.of(context).size.width,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.fromLTRB(15, 15, 5, 0),
                            child: Text(
                              widget.title,
                              style: TextStyle(
                                color: Color.fromRGBO(0, 48, 52, 1),
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.fromLTRB(15, 3, 5, 5),
                            child: Text(
                              widget.model,
                              style: TextStyle(
                                color: Color.fromRGBO(0, 48, 52, 1),
                                fontSize: 12,
                                fontWeight: FontWeight.w300,
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.fromLTRB(15, 10, 10, 5),
                            child: Text(
                              '${widget.price.toStringAsFixed(2)} TL',
                              style: TextStyle(
                                color: Color.fromRGBO(0, 48, 52, 1),
                                fontSize: 19,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.fromLTRB(15, 17, 17, 10),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                _buildInfoIconRow(
                                  icon: Icons.fullscreen_exit_outlined,
                                  text: widget.category,
                                ),
                                _buildInfoIconRow(
                                  icon: Icons.speed,
                                  text: '70,000 KM', // Optional
                                ),
                                _buildInfoIconRow(
                                  icon: Icons.filter,
                                  text: 'MANUAL', // Optional
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(15, 0, 15, 15),
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border(
                            top: BorderSide(
                              width: 2.5,
                              color: Color.fromRGBO(218, 218, 218, 1),
                            ),
                          ),
                        ),
                      ),
                    ),
                    // Description Section
                    Padding(
                      padding: const EdgeInsets.fromLTRB(15, 0, 5, 15),
                      child: Text(
                        "Açıklama",
                        style: TextStyle(
                          color: Color.fromRGBO(0, 48, 52, 1),
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(15, 0, 15, 10),
                      child: Container(
                        width: MediaQuery.of(context).size.width - 30,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 10),
                        color: Color.fromRGBO(248, 249, 251, 1),
                        child: Text(
                          widget.description,
                          style: TextStyle(
                            color: Color.fromRGBO(0, 48, 52, 1),
                            fontSize: 12,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ),
                    ),
                    // Buttons for Message and Favorites
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16.0, vertical: 8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => Messagedetails(
                                        clientRef: widget.clientRef),
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
                                  isFavorite
                                      ? Icons.favorite
                                      : Icons.favorite_border,
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
                    ),
                  ],
                ),
              )
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoIconRow({required IconData icon, required String text}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
      color: Color.fromRGBO(248, 249, 251, 1),
      child: Row(
        children: [
          Icon(icon, color: Color.fromRGBO(0, 48, 52, 1), size: 14),
          Padding(
            padding: const EdgeInsets.only(left: 7),
            child: Text(
              text,
              style: TextStyle(
                color: Color.fromRGBO(0, 48, 52, 1),
                fontSize: 13,
                fontWeight: FontWeight.w300,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
