// ignore_for_file: unnecessary_string_interpolations, avoid_print, unused_import, depend_on_referenced_packages, non_constant_identifier_names, unused_local_variable

import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter_guid/flutter_guid.dart';
import 'package:http/io_client.dart';
import 'package:http/http.dart' as http;

class ApiHandler {
  final String baseUri = "https://192.168.1.145:7110/api/tables";

  final http.Client client = IOClient(
    HttpClient()
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true,
  );

  Future<bool> login(
      {required String name,
      required String password,
      required String clientRef}) async {
    final uri = Uri.parse(baseUri);
    try {
      final response = await client.post(
        uri,
        headers: <String, String>{
          'Content-type': 'application/json; charset=UTF-8',
        },
        body:
            json.encode({'Name': name, 'Password': password, 'Ref': clientRef}),
      );

      if (response.statusCode == 200) {
        return true;
      } else {
        return false;
      }
    } catch (e) {
      print('Error: $e');
      return false;
    }
  }

  Future<Map<String, List<Map<String, dynamic>>>> getTablesWithData() async {
    final uri = Uri.parse(baseUri);
    try {
      final response = await client.get(uri, headers: <String, String>{
        'Content-type': 'application/json; charset=UTF-8'
      });

      if (response.statusCode >= 200 && response.statusCode <= 299) {
        final Map<String, dynamic> jsonData = json.decode(response.body);
        return jsonData.map((key, value) =>
            MapEntry(key, List<Map<String, dynamic>>.from(value)));
      } else {
        throw Exception('Failed to load data');
      }
    } catch (e) {
      print('Error: $e');
      return {};
    }
  }

  Future<List<Map<String, dynamic>>> fetchCategories() async {
    final data = await getTablesWithData();
    return data['Categories']?.map((category) {
          return {
            'Ref': category['Ref'] ?? 'Ref',
            'Name': category['Name'] ?? 'Kategori',
            'Description': category['Description'] ?? '',
          };
        }).toList() ??
        [];
  }

  Future<Map<String, dynamic>> fetchClientCard(String clientRef) async {
    final uri = Uri.parse('$baseUri/ClientCard?Ref=$clientRef');
    try {
      final response = await client.get(uri, headers: <String, String>{
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

  Future<List<Map<String, dynamic>>> fetchAds() async {
    final uri = Uri.parse('$baseUri/Advert');
    try {
      final response = await client.get(uri, headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      });

      if (response.statusCode >= 200 && response.statusCode <= 299) {
        final List<dynamic> jsonData = json.decode(response.body);
        return List<Map<String, dynamic>>.from(jsonData);
      } else {
        throw Exception('İlanlar alınamadı.');
      }
    } catch (e) {
      print('Error: $e');
      return [];
    }
  }

  Future<bool> addAdvert({
    required Guid? ref,
    required String code,
    required String? categoryRef,
    required String brand,
    required String model,
    required String name,
    required String artikelNo,
    required double price,
    required double kdv,
    required Uint8List? imageBytes,
    required String description,
    required int status,
    required String location,
    required int quantity,
    required String clientRef,
  }) async {
    final uri = Uri.parse('$baseUri/Advert');
    // Base64 formatında resim verisi oluştur
   String? base64Image = imageBytes != null ? base64Encode(imageBytes) : null;
    final advertData = {
      'Ref': ref?.toString(),
      'Code': code,
      'CategoryRef': categoryRef,
      'Brand': brand,
      'Model': model,
      'Name': name,
      'ArtikelNo': artikelNo,
      'Price': price,
      'KDV': kdv,
      'Image': base64Image,
      'Description': description,
      'Status': status,
      'Location': location,
      'Quantity': quantity,
      'ClientRef': clientRef,
    };

    try {
      final response = await client.post(
        uri,
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: json.encode(advertData),
      );
 print('API Yanıt Kodu: ${response.statusCode}');
  print('API Yanıtı: ${response.body}');
      return response.statusCode == 200;
    } catch (e) {
      print('Error: $e');
      return false;
    }
  }

  Future<bool> registerClient({
    required Guid? ref,
    required String username,
    required String businessName,
    required String phone,
    required String description,
    required String businessPhone,
    required String email,
    required String address,
    required String password,
    required bool isPassive,
    required double discount,
    required double sales,
    required double purchase,
  }) async {
    final uri = Uri.parse('$baseUri/ClientCard');
    final clientData = {
      'Ref': ref?.toString(),
      'Code': '0',
      'UserName': username,
      'Name': businessName,
      'Phone': phone,
      'Fax': businessPhone,
      'Email': email,
      'Address': address,
      'UserPassword': password,
      'Description': description,
      'IsPassive': isPassive,
      'Discount': discount,
      'Sales': sales,
      'Purchase': purchase,
    };

    try {
      final response = await client.post(
        uri,
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: json.encode(clientData),
      );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        return true;
      } else {
        print('Error: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      print('Error: $e');
      return false;
    }
  }

  Future<List<Map<String, dynamic>>> fetchMessages(String clientRef) async {
    final uri = Uri.parse('$baseUri/Messages?clientRef=$clientRef');
    try {
      final response = await client.get(uri, headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      });

      if (response.statusCode >= 200 && response.statusCode <= 299) {
        final List<dynamic> jsonData = json.decode(response.body);

        return List<Map<String, dynamic>>.from(
          jsonData.map((message) {
            return {
              'Ref': message['Ref'] ?? '',
              'SenderRef': message['SenderRef'] ?? '',
              'AreaRef': message['AreaRef'] ?? '',
              'CreatedDateTime': message['CreatedDateTime'] ?? '',
            };
          }),
        );
      } else {
        throw Exception('Mesajlar alınamadı.');
      }
    } catch (e) {
      print('Error: $e');
      return [];
    }
  }

  Future<String> fetchClientName(String clientRef) async {
    final uri = Uri.parse('$baseUri/ClientCard?Ref=$clientRef');
    try {
      final response = await client.get(uri, headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      });

      if (response.statusCode >= 200 && response.statusCode <= 299) {
        final Map<String, dynamic> jsonData = json.decode(response.body);
        return jsonData['Name'] ?? 'Bilinmiyor';
      } else {
        throw Exception('Kullanıcı adı alınamadı.');
      }
    } catch (e) {
      print('Error: $e');
      return 'Hata';
    }
  }

  Future<String> fetchAdvertName(String advertRef) async {
    final uri = Uri.parse('$baseUri/Advert?Ref=$advertRef');
    try {
      final response = await client.get(uri, headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      });

      if (response.statusCode >= 200 && response.statusCode <= 299) {
        final Map<String, dynamic> jsonData = json.decode(response.body);
        return jsonData['Name'] ?? 'Bilinmiyor';
      } else {
        throw Exception('İlan adı alınamadı.');
      }
    } catch (e) {
      print('Error: $e');
      return 'Hata';
    }
  }

  Future<List<Map<String, dynamic>>> getFavorites(String clientRef) async {
    final url = Uri.parse('$baseUri/favorites?clientRef=$clientRef');
    try {
  final response = await client.get(url, headers: <String, String>{
    'Content-Type': 'application/json; charset=UTF-8',
  });

  if (response.statusCode == 200) {
    List<dynamic> data = json.decode(response.body);
    return data.map((item) => item as Map<String, dynamic>).toList();
  } else {
    print('Status Code: ${response.statusCode}');
    print('Response Body: ${response.body}');
    print('ClientRef: $clientRef'); // clientRef değerini kontrol edin
    

    throw Exception('Failed to load favorites');
  }
} catch (e) {
  print('Error occurred: $e');
  throw Exception('Failed to load favorites');
}


  }

  Future<bool> isAdvertFavorite(String advertRef, String clientRef) async {
    final uri = Uri.parse('$baseUri/Favorite/$clientRef/$advertRef');
    print('Request URI: $uri'); // İstek URI'sini yazdır

    final response = await client.get(uri);

    if (response.statusCode == 200) {
      print('API yanıtı: ${response.body}'); // API yanıtını yazdır
      return jsonDecode(response.body)['isFavorite'] ?? false;
    } else {
      print('Hata durum kodu: ${response.statusCode}'); // Durum kodunu yazdır
      print(
          'Hata gövdesi: ${response.body}'); // Daha fazla bilgi için yanıt gövdesini yazdır
      throw Exception('Favoriler kontrol edilemedi.');
    }
  }

  Future<void> addToFavorites(String advertRef, String clientRef) async {
    final ref = Guid.newGuid.toString();

    final body = jsonEncode({
      'Ref': ref,
      'AdvertRef': advertRef,
      'ClientRef': clientRef,
    });

    final uri = Uri.parse('$baseUri/Favorite');
    final response = await client.post(
      uri,
      headers: {
        'Content-Type': 'application/json',
      },
      body: body,
    );

    if (response.statusCode != 200) {
      print('Response body: ${response.body}');
      throw Exception('Favorilere eklenirken bir hata oluştu.');
    }
  }

  Future<List<dynamic>> fetchFavoritesByClientRef(String clientRef) async {
    try {
      final response = await client
          .get(Uri.parse('$baseUri/favorites?clientRef=$clientRef'));
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Favori ürünler alınamadı: ${response.statusCode}');
      }
    } catch (e) {
      print("Favori ürünleri çekerken hata: $e");
      return [];
    }
  }

  Future<void> removeFromFavorites(String advertRef, String clientRef) async {
    final uri = Uri.parse('$baseUri/Favorite/$clientRef/$advertRef');
    print('URI: $uri');

    final response = await client.delete(
      uri,
      headers: {
        'Content-Type': 'application/json',
      },
    );

    print(
        'Response Status Code: ${response.statusCode}'); // Yanıt durum kodunu kontrol et
    print('Response Body: ${response.body}'); // Yanıt gövdesini kontrol et

    if (response.statusCode == 200) {
      print('Favorilerden çıkarıldı.');
    } else {
      throw Exception(
          'Favorilerden çıkarılamadı: ${response.body}'); // Hata mesajını güncelle
    }
  }
}
