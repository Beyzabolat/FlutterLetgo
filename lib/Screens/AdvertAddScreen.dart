// ignore_for_file: prefer_const_constructors, use_build_context_synchronously, prefer_const_declarations, use_key_in_widget_constructors, library_private_types_in_public_api, file_names, sort_child_properties_last, unused_local_variable, unused_element, non_constant_identifier_names, unused_field, prefer_null_aware_operators, prefer_const_constructors_in_immutables, unused_import, avoid_print

import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_guid/flutter_guid.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:project/apihandler.dart';

class AdvertAddScreen extends StatefulWidget {
  final String clientRef;
  final String categoryRef;

  AdvertAddScreen({required this.clientRef, required this.categoryRef});

  @override
  _AdvertAddScreenState createState() => _AdvertAddScreenState();
}

class _AdvertAddScreenState extends State<AdvertAddScreen> {
  final _formKey = GlobalKey<FormState>();

  final _codeController = TextEditingController();
  final _categoryRefController = TextEditingController();
  final _brandController = TextEditingController();
  final _modelController = TextEditingController();
  final _nameController = TextEditingController();
  final _artikelNoController = TextEditingController();
  final _priceController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _statusController = TextEditingController();
  final _locationController = TextEditingController();
  final _quantityController = TextEditingController();


final ImagePicker _picker = ImagePicker();
Uint8List? _imageBytes;
XFile? _image;
  String? _selectedCategory;

  List<Map<String, dynamic>> _categories = []; 

@override
void initState() {
  super.initState();
  _loadCategories();
}

Future<void> _loadCategories() async {
  final apiHandler = ApiHandler();
  final categories = await apiHandler.fetchCategories();
  
  print("Yüklenen Kategoriler: ${categories.map((cat) => cat['Ref']).toList()}");
  
  setState(() {
    _categories = categories;
    if (_categories.isNotEmpty) {
      _selectedCategory = _categories.first['Ref'];
      print("Başlangıç Seçili Kategori: $_selectedCategory");
    }
  });
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('İlan Ekle',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.red,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: <Widget>[
              _buildDropdownFormField(),
              _buildTextFormField(
                  _brandController, 'Marka', Icons.branding_watermark),
              _buildTextFormField(
                  _modelController, 'Model', Icons.device_unknown),
              _buildTextFormField(_nameController, 'İsim', Icons.label),
              _buildTextFormField(_priceController, 'Fiyat', Icons.attach_money,
                  keyboardType: TextInputType.number),
              SizedBox(height: 20),
              _buildTextFormField(
                  _descriptionController, 'Açıklama', Icons.description),
              _buildTextFormField(
                  _locationController, 'Konum', Icons.location_on),
              SizedBox(height: 20),
              _buildImagePicker(),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState?.validate() ?? false) {
                    final apiHandler = ApiHandler();
                    final success = await apiHandler.addAdvert(
                      ref: Guid.generate(),
                      code: '0',
                      categoryRef: _selectedCategory,
                      brand: _brandController.text,
                      model: _modelController.text,
                      name: _nameController.text,
                      artikelNo: _artikelNoController.text,
                      price: double.tryParse(_priceController.text) ?? 0.0,
                      kdv: double.tryParse(_priceController.text) ?? 0.0,
                      imageBytes: _imageBytes,   
                      description: _descriptionController.text,
                      status: 1,
                      location: _locationController.text,
                      quantity: 1,
                      clientRef: widget.clientRef,
                    );

                    if (success) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('İlan başarıyla eklendi!')),
                      );
                      _formKey.currentState?.reset();
                      setState(() {
                        _image = null;
                        _selectedCategory = null;
                      });
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Bir hata oluştu.')),
                      );
                    }
                  }
                },
                child: Text('İlanı Ekle',
                    style:
                        TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  padding: EdgeInsets.symmetric(vertical: 15),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextFormField(
      TextEditingController controller, String labelText, IconData icon,
      {TextInputType keyboardType = TextInputType.text}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: Colors.red),
          labelText: labelText,
          border: OutlineInputBorder(),
          contentPadding:
              EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          labelStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
        keyboardType: keyboardType,
        validator: (value) {
          if (value == null || value.isEmpty) {
            return '$labelText boş olamaz';
          }
          return null;
        },
      ),
    );
  }

  Widget _buildDropdownFormField() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: DropdownButtonFormField<String>(
       value: _categories.isNotEmpty && _categories.any((cat) => cat['Ref'] == _selectedCategory) 
        ? _selectedCategory 
        : null,
        decoration: InputDecoration(
          prefixIcon: Icon(Icons.category, color: Colors.red),
          labelText: 'Kategori',
          border: OutlineInputBorder(),
          contentPadding:
              EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          labelStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
       items: _categories.map<DropdownMenuItem<String>>((category) {
  return DropdownMenuItem<String>(
    value: category['Ref'],
    child: Text(category['Name']),
  );
}).toList(),

        onChanged: (value) {
          setState(() {
            _selectedCategory = value;
          });
            print('Selected Category Changed: $value');
        },
        validator: (value) {
          if (value == null) {
            return 'Kategori seçmelisiniz';
          }
          return null;
        },
      ),
    );
  }

 Widget _buildImagePicker() {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text('Fotoğraf',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
      SizedBox(height: 10),
      GestureDetector(
        onTap: () {
          _pickImage();
        },
        child: Container(
          width: double.infinity,
          height: 200,
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.red, width: 2),
          ),
          child: _image != null
              ? Image.file(
                  File(_image!.path),
                  fit: BoxFit.cover,
                )
              : Center(
                  child: Icon(Icons.camera_alt, size: 50, color: Colors.grey),
                ),
        ),
      ),
    ],
  );
}
 
Future<void> _pickImage() async {
  final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
  if (image != null) {
    _imageBytes = await image.readAsBytes();
    setState(() {
      _image = image;
    });
  }
}
}