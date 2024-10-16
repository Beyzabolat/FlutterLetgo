// ignore_for_file: file_names, prefer_const_constructors_in_immutables, use_super_parameters, library_private_types_in_public_api, prefer_const_constructors, use_build_context_synchronously, avoid_print, sized_box_for_whitespace, unused_import, unnecessary_brace_in_string_interps, unnecessary_null_comparison, unnecessary_type_check, avoid_function_literals_in_foreach_calls, prefer_const_literals_to_create_immutables, use_key_in_widget_constructors, unused_element

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:project/Screens/MessageDetails.dart';
import 'package:project/apihandler.dart';
import 'package:project/constants.dart';
import 'package:photo_view/photo_view_gallery.dart';
import 'package:photo_view/photo_view.dart';
import 'package:http/http.dart' as http;

class Advertdetails extends StatefulWidget {
  final String title;
  final String description;
  final List<String> imageUrl;
  final String category;
  final String brand;
  final String model;
  final double price;
  final String location;
  final int quantity;
  final String advertRef;
  final String clientRef;
  //final String categoryRef;
  //final DateTime creationDate; // Eklendi

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
    //required this.categoryRef
    // required this.creationDate, // Eklendi
  }) : super(key: key);

  @override
  _AdvertdetailsState createState() => _AdvertdetailsState();
}

class FullScreenGallery extends StatefulWidget {
  final List<String> imageList;
  final int initialIndex;

  FullScreenGallery({required this.imageList, required this.initialIndex});

  @override
  _FullScreenGalleryState createState() => _FullScreenGalleryState();
}

class _FullScreenGalleryState extends State<FullScreenGallery> {
  late PageController _pageController;
  int currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: widget.initialIndex);
    currentIndex = widget.initialIndex; // Başlangıçtaki resim numarası
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black, // Tam ekran siyah arka plan
      appBar: AppBar(
        backgroundColor: Colors.black, // Siyah AppBar
        title: Text(
          '${currentIndex + 1}/${widget.imageList.length}', // Mevcut fotoğraf numarası / toplam sayı
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true, // Sayfa numarası ortada
        actions: [
          IconButton(
            icon: Icon(Icons.close, color: Colors.white),
            onPressed: () {
              Navigator.of(context).pop(); // Kapatmak için
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          PhotoViewGallery.builder(
            itemCount: widget.imageList.length,
            builder: (context, index) {
              return PhotoViewGalleryPageOptions(
                imageProvider:
                    MemoryImage(base64Decode(widget.imageList[index])),
                minScale: PhotoViewComputedScale.contained,
                maxScale: PhotoViewComputedScale.covered * 2,
              );
            },
            pageController: _pageController,
            scrollPhysics: BouncingScrollPhysics(),
            onPageChanged: (index) {
              setState(() {
                currentIndex = index;
              });
            },
            backgroundDecoration: BoxDecoration(color: Colors.black),
          ),
          Positioned(
            bottom: 20,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(widget.imageList.length, (index) {
                return Container(
                  margin: EdgeInsets.symmetric(horizontal: 4),
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: currentIndex == index
                        ? Colors.white
                        : Colors.white.withOpacity(0.4),
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}

class _AdvertdetailsState extends State<Advertdetails> {
  bool isFavorite = false;
  final ApiHandler apiHandler = ApiHandler();
  List<String> imageList = [];
  String _selectedCategory = ''; // Burayı ekle

  List<dynamic> _categories = []; // Kategoriler için listeyi tanımla

  @override
  void initState() {
    super.initState();
    _checkIfFavorite();
    fetchImages();
    _loadCategories();
  }

  void openFullScreenGallery(int initialIndex) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FullScreenGallery(
          imageList: imageList,
          initialIndex: initialIndex,
        ),
      ),
    );
  }
Future<void> _loadCategories() async {
  final apiHandler = ApiHandler();
  final categories = await apiHandler.fetchCategories();

  print(
      "Yüklenen Kategoriler: ${categories.map((cat) => cat['Ref']).toList()}");

  // Widget hala ağacın bir parçasıysa setState() çağır
  if (mounted) {
    setState(() {
      _categories = categories;
      if (_categories.isNotEmpty) {
        _selectedCategory = _categories.first['Ref'];
        print("Başlangıç Seçili Kategori: $_selectedCategory");
      }
    });
  }
}

// Kategori ismini almak için yardımcı fonksiyon
  String _getCategoryName(String categoryRef) {
    final category = _categories.firstWhere(
      (cat) => cat['Ref'] == categoryRef,
      orElse: () => null, // Eğer kategori bulunmazsa null döndür
    );

    return category != null
        ? category['Name']
        : 'Kategori Yok'; // Kategori varsa adı, yoksa "Kategori Yok"
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
      backgroundColor: kBackGroundColor,
      appBar: AppBar(
        backgroundColor: kBackGroundColor,
        title: Text(
          'İlan Detayları',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
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
      body: Stack(
        children: <Widget>[
          ListView(
            children: <Widget>[
              Stack(
                children: <Widget>[
                  Container(
                    color: Colors.white,
                    child: Column(
                      children: <Widget>[
                        CarouselSlider(
                          options: CarouselOptions(
                            height: 320.0,
                            viewportFraction: 1.0,
                            enableInfiniteScroll: false,
                            autoPlay: true,
                            autoPlayInterval: Duration(seconds: 3),
                          ),
                          items: imageList.asMap().entries.map((entry) {
                            int index = entry.key;
                            String base64Image = entry.value;
                            try {
                              return GestureDetector(
                                onTap: () => openFullScreenGallery(index),
                                child: Image.memory(
                                  base64Decode(base64Image),
                                  fit: BoxFit.cover, width: double.infinity,
                                  height: double
                                      .infinity, // Görselin tam ekran kaplamas
                                  errorBuilder: (context, error, stackTrace) {
                                    return Center(
                                      child: Icon(Icons.broken_image,
                                          size: 100, color: Colors.grey),
                                    );
                                  },
                                ),
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

                        // Product Details Section
                        Container(
                          width: MediaQuery.of(context).size.width,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding:
                                    const EdgeInsets.fromLTRB(15, 15, 5, 0),
                                child: Text(
                                  widget.title,
                                  style: TextStyle(
                                    color: Color.fromRGBO(0, 48, 52, 1),
                                    fontSize: 18, // Boyut artırıldı
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.fromLTRB(15, 3, 5, 5),
                                child: Text(
                                  'Marka: ${widget.brand} | Model: ${widget.model}',
                                  style: TextStyle(
                                    color: Color.fromRGBO(0, 48, 52, 1),
                                    fontSize: 16, // Boyut artırıldı
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                              ),
                              Padding(
                                padding:
                                    const EdgeInsets.fromLTRB(15, 10, 10, 5),
                                child: Text(
                                  '${widget.price.toStringAsFixed(2)} TL',
                                  style: TextStyle(
                                    color: Color.fromRGBO(0, 48, 52, 1),
                                    fontSize: 22, // Boyut artırıldı
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              Padding(
                                  padding:
                                      const EdgeInsets.fromLTRB(15, 17, 17, 10),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      _buildInfoIconRow(
                                          icon: Icons.fullscreen_exit_outlined,
                                          text: widget.category),
                                      _buildInfoIconRow(
                                          icon: Icons.speed,
                                          text:
                                              '70,000 KM'), // Buraya doğru bir şekilde ekleyin
                                      _buildInfoIconRow(
                                          icon: Icons.filter,
                                          text: 'MANUAL'), // Buraya da
                                    ],
                                  )),
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
                        Padding(
                          padding: const EdgeInsets.fromLTRB(15, 0, 5, 15),
                          child: Text(
                            "Açıklama",
                            style: TextStyle(
                              color: Color.fromRGBO(0, 48, 52, 1),
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
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
                                color: Color.fromRGBO(
                                    0, 48, 52, 1), // Renk eklendi
                                fontSize: 14, // Boyut tutarlı
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(15, 0, 5, 15),
                          child: Text(
                            "Detaylar",
                            style: TextStyle(
                              color: Color.fromRGBO(0, 48, 52, 1),
                              fontSize: 18, // Boyut tutarlı
                              fontWeight: FontWeight.bold,
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
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'İlan Oluşturulma Tarihi: ${widget.location}', // İlan oluşturulma tarihi eklendi
                                  style: TextStyle(
                                    color: Color.fromRGBO(
                                        0, 48, 52, 1), // Renk eklendi
                                    fontSize: 14, // Boyut tutarlı
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                                Text(
                                  'Marka: ${widget.brand}', // Marka eklendi
                                  style: TextStyle(
                                    color: Color.fromRGBO(
                                        0, 48, 52, 1), // Renk eklendi
                                    fontSize: 14, // Boyut tutarlı
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                                Text(
                                  'Model: ${widget.model}', // Model eklendi
                                  style: TextStyle(
                                    color: Color.fromRGBO(
                                        0, 48, 52, 1), // Renk eklendi
                                    fontSize: 14, // Boyut tutarlı
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                                Text(
                                  'İlan Kodu: ${widget.advertRef}', // İlan kodu eklendi
                                  style: TextStyle(
                                    color: Color.fromRGBO(
                                        0, 48, 52, 1), // Renk eklendi
                                    fontSize: 14, // Boyut tutarlı
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                                Text(
                                  'Konum: ${widget.location}', // Konum eklendi
                                  style: TextStyle(
                                    color: Color.fromRGBO(
                                        0, 48, 52, 1), // Renk eklendi
                                    fontSize: 14, // Boyut tutarlı
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                                // Diğer detaylar buraya eklenebilir
                              ],
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(
                              bottom: 100), // Alt kısmı boş bırak
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
          // Sabit Butonlar
          // Fixed Buttons Section
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              color: Colors.white,
              child: Row(
                children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color.fromRGBO(108, 241, 115, 0.784),
                          padding: EdgeInsets.symmetric(vertical: 15),
                        ),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => Messagedetails(
                                clientRef: widget.clientRef,
                              ),
                            ),
                          );
                        },
                        child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.chat,
                                  color: Colors.white), // Simge eklendi
                              SizedBox(
                                  width: 8), // Simge ve metin arasında boşluk
                              Text(
                                'Mesaj Gönder',
                                style: TextStyle(
                                  fontSize: 16, // Büyütüldü
                                  color: Colors.white, // Yazı rengi beyaz
                                  // Büyütüldü   ),
                                ),
                              ),
                            ]),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isFavorite
                              ? Colors.red
                              : Color.fromRGBO(0, 48, 52, 1),
                          padding: EdgeInsets.symmetric(vertical: 15),
                        ),
                        onPressed: _addToFavorites,
                        child: Text(
                          'Favorilere Ekle',
                          style: TextStyle(fontSize: 16), // Büyütüldü
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Row _buildInfoIconRow({required IconData icon, required String text}) {
    return Row(
      children: [
        Icon(icon, color: Color.fromARGB(255, 0, 48, 52), size: 18),
        SizedBox(width: 5),
        Text(
          text,
          style: TextStyle(
            color: Color.fromRGBO(0, 48, 52, 1),
            fontSize: 12,
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
    );
  }
}
