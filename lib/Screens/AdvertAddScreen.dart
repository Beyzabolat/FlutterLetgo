// ignore_for_file: prefer_const_constructors, use_build_context_synchronously, prefer_const_declarations, use_key_in_widget_constructors, library_private_types_in_public_api, file_names, sort_child_properties_last, unused_local_variable, unused_element, non_constant_identifier_names, unused_field, prefer_null_aware_operators, prefer_const_constructors_in_immutables, unused_import, avoid_print, prefer_final_fields, prefer_const_literals_to_create_immutables, no_leading_underscores_for_local_identifiers

import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:project/apihandler.dart';
import 'package:image_picker/image_picker.dart';
import 'package:project/constants.dart';

class AdvertAddScreen extends StatefulWidget {
  final String clientRef;
  final String categoryRef;

  AdvertAddScreen({required this.clientRef, required this.categoryRef});

  @override
  _AdvertAddScreenState createState() => _AdvertAddScreenState();
}

class _AdvertAddScreenState extends State<AdvertAddScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  TabController? _tabController;
  String? _selectedCategory;
  List<Map<String, dynamic>> _categories = [];
  TextEditingController _brandController = TextEditingController();
  TextEditingController _modelController = TextEditingController();
  TextEditingController _nameController = TextEditingController();
  TextEditingController _priceController = TextEditingController();
  TextEditingController _descriptionController = TextEditingController();
  TextEditingController _locationController = TextEditingController();

  String? _imagePath;

  @override
  void initState() {
    super.initState();
    _loadCategories();
    _tabController = TabController(length: 4, vsync: this);
  }

  Future<void> _loadCategories() async {
    final apiHandler = ApiHandler();
    final categories = await apiHandler.fetchCategories();

    print(
        "Yüklenen Kategoriler: ${categories.map((cat) => cat['Ref']).toList()}");

    setState(() {
      _categories = categories;
      if (_categories.isNotEmpty) {
        _selectedCategory = _categories.first['Ref'];
        print("Başlangıç Seçili Kategori: $_selectedCategory");
      }
    });
  }

  Future<void> _pickImage() async {
    final ImagePicker _picker = ImagePicker();
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      setState(() {
        _imagePath = image.path;
      });
    }
  }

  @override
  void dispose() {
    _tabController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackGroundColor,
      appBar: AppBar(
        title: Text('İlan Ekle',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        backgroundColor: kBackGroundColor,
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(icon: Icon(Icons.category), text: 'Kategori'),
            Tab(icon: Icon(Icons.info), text: 'Detaylar'),
            Tab(icon: Icon(Icons.image), text: 'Fotoğraf'),
            Tab(icon: Icon(Icons.check), text: 'Özet'),
          ],
        ),
      ),
      body: Form(
        key: _formKey,
        child: TabBarView(
          controller: _tabController,
          children: [
            _buildCategoryTab(),
            _buildDetailsTab(),
            _buildPhotoTab(),
            _buildSummaryTab(),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryTab() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildDropdownFormField(),
        ],
      ),
    );
  }

  Widget _buildDetailsTab() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: ListView(
        children: [
          _buildTextFormField(
              _brandController, 'Marka', Icons.branding_watermark),
          _buildTextFormField(_modelController, 'Model', Icons.device_unknown),
          _buildTextFormField(_nameController, 'İsim', Icons.label),
          _buildTextFormField(_priceController, 'Fiyat', Icons.attach_money,
              keyboardType: TextInputType.number),
          _buildTextFormField(
              _descriptionController, 'Açıklama', Icons.description),
          _buildTextFormField(_locationController, 'Konum', Icons.location_on),
        ],
      ),
    );
  }

  Widget _buildPhotoTab() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.5),
                  spreadRadius: 2,
                  blurRadius: 7,
                  offset: Offset(0, 3),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: _imagePath != null
                  ? Image.file(File(_imagePath!),
                      height: 200, fit: BoxFit.cover)
                  : Container(
                      height: 200,
                      color: Colors.grey[200],
                      child: Center(
                        child: Icon(Icons.add_a_photo,
                            size: 50, color: Colors.grey),
                      ),
                    ),
            ),
          ),
          SizedBox(height: 10),
          Text('Fotoğraf Ekle',
              style: TextStyle(fontSize: 18, color: Colors.grey)),
          SizedBox(height: 10),
          ElevatedButton(
            onPressed: _pickImage,
            style: ElevatedButton.styleFrom(
              backgroundColor: kBackGroundColor,
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: Text('Fotoğraf Yükle', style: TextStyle(fontSize: 16)),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryTab() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSummaryItem(
                'Kategori', _selectedCategory ?? "Seçilmedi", Icons.category),
            _buildSummaryItem(
                'Marka', _brandController.text, Icons.branding_watermark),
            _buildSummaryItem(
                'Model', _modelController.text, Icons.device_unknown),
            _buildSummaryItem('İsim', _nameController.text, Icons.label),
            _buildSummaryItem(
                'Fiyat', _priceController.text, Icons.attach_money),
            _buildSummaryItem(
                'Açıklama', _descriptionController.text, Icons.description),
            _buildSummaryItem(
                'Konum', _locationController.text, Icons.location_on),
            SizedBox(height: 20),
            if (_imagePath != null) _buildImagePreview(),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                if (_formKey.currentState!.validate()) {
                  bool isSuccess = await ApiHandler().addAdvert(
                    categoryRef: _selectedCategory!,
                    brand: _brandController.text,
                    model: _modelController.text,
                    name: _nameController.text,
                    price: _priceController.text,
                    description: _descriptionController.text,
                    location: _locationController.text,
                    clientRef: widget.clientRef,
                    imagePath: _imagePath,
                  );

                  if (isSuccess) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('İlan başarıyla eklendi!')),
                    );
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.black,
                backgroundColor: kBackGroundColor,
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                elevation: 5,
              ),
              child: Text(
                'İlanı Yayınla',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryItem(String label, String value, IconData icon) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      elevation: 4,
      child: ListTile(
        leading: Icon(icon, color: Colors.red, size: 30),
        title: Text(label, style: TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(value),
      ),
    );
  }

  Widget _buildImagePreview() {
    return Card(
      elevation: 5,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Seçilen Fotoğraf',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 10),
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.file(
                File(_imagePath!),
                height: 200,
                fit: BoxFit.cover,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDropdownFormField() {
    return DropdownButtonFormField<String>(
      value: _categories.isNotEmpty &&
              _categories.any((cat) => cat['Ref'] == _selectedCategory)
          ? _selectedCategory
          : null,
      decoration: InputDecoration(
        prefixIcon: Icon(Icons.category, color: Colors.red),
        labelText: 'Kategori',
        border: OutlineInputBorder(),
        contentPadding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
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
    );
  }

  Widget _buildTextFormField(
      TextEditingController controller, String label, IconData icon,
      {TextInputType keyboardType = TextInputType.text}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: Colors.red),
          labelText: label,
          border: OutlineInputBorder(),
          contentPadding:
              EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return '$label girilmelidir';
          }
          return null;
        },
      ),
    );
  }
}
