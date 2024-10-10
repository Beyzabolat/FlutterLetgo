// ignore_for_file: use_super_parameters, file_names, library_private_types_in_public_api, prefer_const_constructors, use_build_context_synchronously, avoid_print

import 'dart:convert'; // Import for base64Decode
import 'dart:typed_data'; // Import for Uint8List
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart'; // Import the image_picker package
import 'package:project/Screens/HomeScreen.dart';
import 'package:project/Screens/ProfileScreen.dart';
import 'package:project/apihandler.dart';
import 'package:project/constants.dart';

class ProfileEditScreen extends StatefulWidget {
  final String clientRef;

  const ProfileEditScreen({Key? key, required this.clientRef})
      : super(key: key);

  @override
  _EditProfilePageState createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<ProfileEditScreen> {
  bool showPassword = false;
  late Future<Map<String, dynamic>> _clientCardFuture;
  late TextEditingController nameController;
  late TextEditingController emailController;
  late TextEditingController phoneController;
  late TextEditingController addressController;
  late TextEditingController faxController;
  String base64Image = ""; // To store the base64 string of the image

  @override
  void initState() {
    super.initState();
    _clientCardFuture = ApiHandler().fetchClientCard(widget.clientRef);
    nameController = TextEditingController();
    emailController = TextEditingController();
    phoneController = TextEditingController();
    addressController = TextEditingController();
    faxController = TextEditingController();
  }

  Future<void> updateClientCard() async {
    final updatedData = {
      'ref': widget.clientRef,
      'name': nameController.text,
      'email': emailController.text,
      'phone': phoneController.text,
      'address': addressController.text,
      'fax': faxController.text,
      'image': base64Image
    };
    print('Updated Data: $updatedData');

    final response =
        await ApiHandler().updateClientCard(widget.clientRef, updatedData);
    if (response) {
      print('Update successful');
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (context) => MyHomePage(clientRef: widget.clientRef)),
      );
    }
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();

    // Kamera ya da galeri seçeneğini sunan bir diyalog gösterelim
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            ListTile(
              leading: Icon(Icons.camera_alt),
              title: Text('Kameradan Çek'),
              onTap: () async {
                Navigator.pop(context); // Diyaloğu kapat
                final XFile? pickedFile =
                    await picker.pickImage(source: ImageSource.camera);
                _processPickedFile(pickedFile);
              },
            ),
            ListTile(
              leading: Icon(Icons.photo),
              title: Text('Galeriden Seç'),
              onTap: () async {
                Navigator.pop(context); // Diyaloğu kapat
                final XFile? pickedFile =
                    await picker.pickImage(source: ImageSource.gallery);
                _processPickedFile(pickedFile);
              },
            ),
          ],
        );
      },
    );
  }

  void _processPickedFile(XFile? pickedFile) async {
    if (pickedFile != null) {
      final bytes = await pickedFile.readAsBytes();
      setState(() {
        base64Image =
            base64Encode(bytes); // Resmi base64 formatına dönüştür ve sakla
      });

      _showImageDialog(base64Image); // Resmi göster
    }
  }

  void _showImageDialog(String base64Image) {
    Uint8List imageBytes = base64Decode(base64Image);
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          child: imageBytes.isNotEmpty
              ? Image.memory(
                  imageBytes,
                  fit: BoxFit.cover,
                )
              : Placeholder(fallbackHeight: 300, fallbackWidth: 300),
        );
      },
    );
  }

  void _showImageeDialog(String base64Image) {
    Uint8List imageBytes = base64Decode(base64Image);
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          child: imageBytes.isNotEmpty
              ? Image.memory(
                  imageBytes,
                  fit: BoxFit.cover,
                )
              : Placeholder(fallbackHeight: 300, fallbackWidth: 300),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackGroundColor,
      appBar: AppBar(
        backgroundColor: kBackGroundColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Color.fromRGBO(255, 145, 77, 1)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "Profili Düzenle",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: FutureBuilder<Map<String, dynamic>>(
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
          if (nameController.text.isEmpty) {
            nameController.text = clientData['Name'] ?? '';
            emailController.text = clientData['Email'] ?? '';
            phoneController.text = clientData['Phone'] ?? '';
            addressController.text = clientData['Address'] ?? '';
            faxController.text = clientData['Fax'] ?? '';
          }

          return Container(
            padding: EdgeInsets.only(left: 16, top: 25, right: 16),
            child: GestureDetector(
              onTap: () {
                FocusScope.of(context).unfocus();
              },
              child: ListView(
                children: [
                  SizedBox(height: 15),
                  Center(
                    child: Stack(
                      children: [
                        Container(
                          width: 130,
                          height: 130,
                          decoration: BoxDecoration(
                            border: Border.all(
                              width: 4,
                              color: Color.fromRGBO(255, 145, 77, 1),
                            ),
                            boxShadow: [
                              BoxShadow(
                                spreadRadius: 2,
                                blurRadius: 10,
                                color: Colors.white.withOpacity(0.1),
                                offset: Offset(0, 10),
                              )
                            ],
                            shape: BoxShape.circle,
                            image: base64Image.isNotEmpty
                                ? DecorationImage(
                                    fit: BoxFit.cover,
                                    image:
                                        MemoryImage(base64Decode(base64Image)),
                                  )
                                : DecorationImage(
                                    fit: BoxFit.cover,
                                    image: NetworkImage(
                                      "https://images.pexels.com/photos/3307758/pexels-photo-3307758.jpeg?auto=compress&cs=tinysrgb&dpr=3&h=250",
                                    ),
                                  ),
                          ),
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: GestureDetector(
                            onTap:
                                _pickImage, // Call the method to pick an image
                            child: Container(
                              height: 40,
                              width: 40,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Color.fromRGBO(255, 145, 77, 1),
                              ),
                              child: Icon(
                                Icons.camera_alt,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 35),
                  buildTextField("İşletme", nameController, false),
                  buildTextField("E-mail", emailController, false),
                  buildTextField("Telefon", phoneController, false),
                  buildTextField("Adres", addressController, false),
                  buildTextField("Fax", faxController, false),
                  SizedBox(height: 35),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          padding: EdgeInsets.symmetric(
                              horizontal: 40, vertical: 15),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          side: BorderSide(
                              color: Color.fromRGBO(255, 145, 77, 1), width: 2),
                        ),
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: Text(
                          "İptal",
                          style: TextStyle(
                            fontSize: 16,
                            letterSpacing: 1.2,
                            color: Color.fromRGBO(255, 145, 77, 1),
                          ),
                        ),
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color.fromRGBO(255, 145, 77, 1),
                          padding: EdgeInsets.symmetric(
                              horizontal: 40, vertical: 15),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                        onPressed: () async {
                          await updateClientCard();
                        },
                        child: Text(
                          "Kaydet",
                          style: TextStyle(
                            fontSize: 16,
                            letterSpacing: 1.2,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget buildTextField(String labelText, TextEditingController controller,
      bool isPasswordTextField) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 35.0),
      child: TextField(
        controller: controller,
        obscureText: isPasswordTextField ? showPassword : false,
        decoration: InputDecoration(
          suffixIcon: isPasswordTextField
              ? IconButton(
                  onPressed: () {
                    setState(() {
                      showPassword = !showPassword;
                    });
                  },
                  icon: Icon(
                    Icons.remove_red_eye,
                    color: Colors.grey,
                  ),
                )
              : null,
          contentPadding: EdgeInsets.only(bottom: 3),
          labelText: labelText,
          floatingLabelBehavior: FloatingLabelBehavior.always,
          hintStyle: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
      ),
    );
  }
}
