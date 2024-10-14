// ignore_for_file: use_super_parameters, file_names, library_private_types_in_public_api, prefer_const_constructors, use_build_context_synchronously, avoid_print, unused_element

import 'dart:convert'; 
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart'; 
import 'package:project/Screens/HomeScreen.dart';
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
  String base64Image = ""; 
  bool isImageAvailable = false; 
  String? temporaryBase64Image;

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
      'image': temporaryBase64Image ??
          base64Image 
    };
  
    final response =
        await ApiHandler().updateClientCard(widget.clientRef, updatedData);
    if (response) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (context) => MyHomePage(clientRef: widget.clientRef)),
      );
      setState(() {
        _clientCardFuture = ApiHandler()
            .fetchClientCard(widget.clientRef); 
      });
    }
  }

  void _pickImage() async {
    final ImagePicker picker = ImagePicker();

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
                Navigator.pop(context);
                final XFile? pickedFile =
                    await picker.pickImage(source: ImageSource.camera);
                _processPickedFile(pickedFile);
              },
            ),
            ListTile(
              leading: Icon(Icons.photo),
              title: Text('Galeriden Seç'),
              onTap: () async {
                Navigator.pop(context); 
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

  void _processPicCkedFile(XFile? pickedFile) async {
    if (pickedFile != null) {
      final bytes = await pickedFile.readAsBytes();
      String newBase64Image =
          base64Encode(bytes);

      setState(() {
        base64Image = newBase64Image; 
        isImageAvailable = true; 
      });

      _showImageDialog(newBase64Image); 
    }
  }

  void _processPickedFilee(XFile? pickedFile) async {
    if (pickedFile != null) {
      final bytes = await pickedFile.readAsBytes();
      String newBase64Image =
          base64Encode(bytes); 


      setState(() {
        base64Image = newBase64Image; 
        isImageAvailable = true; 
      });

      
      await updateClientCard();

      _showImageDialog(newBase64Image);
    }
  }

  void _processsPickedFile(XFile? pickedFile) async {
    if (pickedFile != null) {
      final bytes = await pickedFile.readAsBytes();
      String newBase64Image =
          base64Encode(bytes); 


      setState(() {
        base64Image = newBase64Image; 
        isImageAvailable = true; 
      });

      _showImageDialog(newBase64Image);
    }
  }

  void _processPickedFile(XFile? pickedFile) async {
    if (pickedFile != null) {
      final bytes = await pickedFile.readAsBytes();
      String newBase64Image =
          base64Encode(bytes); 


      setState(() {
        temporaryBase64Image = newBase64Image; 
        isImageAvailable = true; 
      });

      _showImageDialog(newBase64Image); 
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackGroundColor,
      appBar: AppBar(
        backgroundColor: kBackGroundColor,
        elevation: 0,
        leading: IconButton(
          icon:
              Icon(Icons.arrow_back, color: Color.fromRGBO(100, 10, 120, 147)),
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

          if (clientData['Image'] != null && clientData['Image'].isNotEmpty) {
            try {
              base64Image = clientData['Image'];
              base64Decode(
                  base64Image); 
              isImageAvailable = true;
            } catch (e) {
              isImageAvailable = false; 
            }
          } else {
            base64Image = ""; 
            isImageAvailable = false;
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
                              color: Color.fromRGBO(100, 10, 120, 147),
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
                            image: isImageAvailable
                                ? DecorationImage(
                                    fit: BoxFit.cover,
                                    image:
                                        MemoryImage(base64Decode(base64Image)),
                                  )
                                : DecorationImage(
                                    fit: BoxFit.cover,
                                    image:
                                        AssetImage('assets/images/profile.png'),
                                  ),
                          ),
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: GestureDetector(
                            onTap:
                                _pickImage,
                            child: Container(
                              height: 40,
                              width: 40,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Color.fromRGBO(100, 10, 120, 30),
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
                              color: Color.fromRGBO(100, 10, 120, 147),
                              width: 2),
                        ),
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: Text(
                          "İptal",
                          style: TextStyle(
                            fontSize: 16,
                            letterSpacing: 1.2,
                            color: Color.fromRGBO(100, 10, 120, 147),
                          ),
                        ),
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color.fromRGBO(100, 10, 120, 147),
                          padding: EdgeInsets.symmetric(
                              horizontal: 40, vertical: 15),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                        onPressed: () {
                          updateClientCard(); 
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
                  )
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
      padding: const EdgeInsets.only(bottom: 25.0),
      child: TextField(
        controller: controller,
        obscureText: isPasswordTextField ? showPassword : false,
        decoration: InputDecoration(
          contentPadding: EdgeInsets.only(bottom: 3),
          labelText: labelText,
          floatingLabelBehavior: FloatingLabelBehavior.always,
        ),
      ),
    );
  }
}
