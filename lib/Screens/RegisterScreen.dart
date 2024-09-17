// ignore_for_file: file_names, use_key_in_widget_constructors, library_private_types_in_public_api, prefer_const_constructors, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter_guid/flutter_guid.dart';
import 'package:flutter/services.dart';
import 'package:project/Screens/LoginScreen.dart';
import 'package:project/apihandler.dart';
import 'package:flutter_svg_provider/flutter_svg_provider.dart';
import '../widgets/widget.dart';
import '../constants.dart';

class Registerscreen extends StatefulWidget {
  const Registerscreen({super.key});

  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<Registerscreen> {
  bool passwordVisibility = true;

  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _businessNameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _businessPhoneController =
      TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  void _register() async {
    final username = _usernameController.text;
    final businessName = _businessNameController.text;
    final phone = _phoneController.text;
    final businessPhone = _businessPhoneController.text;
    final email = _emailController.text;
    final address = _addressController.text;
    final password = _passwordController.text;
    final confirmPassword = _confirmPasswordController.text;

    if (username.isEmpty ||
        businessName.isEmpty ||
        phone.isEmpty ||
        businessPhone.isEmpty ||
        email.isEmpty ||
        address.isEmpty ||
        password.isEmpty ||
        confirmPassword.isEmpty) {
      _showDialog('Kayıt Başarısız', 'Tüm kutucuklar doldurulmalıdır.');
      return;
    }

    if (password != confirmPassword) {
      _showDialog('Kayıt Başarısız', 'Şifreler uyuşmuyor.');
      return;
    }

    final apiHandler = ApiHandler();
    final result = await apiHandler.registerClient(
      username: username,
      businessName: businessName,
      phone: phone,
      businessPhone: businessPhone,
      email: email,
      address: address,
      password: password,
      ref: Guid.newGuid,
      description: '-',
      isPassive: false,
      discount: 0,
      sales: 0,
      purchase: 0,
    );

     if (result) {
  // Diyaloğu göster ve tamamlanana kadar bekle
  await showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: Text('Kayıt Başarılı'),
      content: Text('Başarıyla kayıt oldunuz.'),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text('Tamam'),
        ),
      ],
    ),
  );
  
  // Alanları temizle
  _clearFields();

  // Yönlendirme işlemini diyalog kapandıktan sonra yap
  Navigator.pushReplacement(
    context,
    MaterialPageRoute(builder: (context) => Loginscreen()),
  );
} else {
  await showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: Text('Kayıt Başarısız'),
      content: Text('Kayıt sırasında bir hata oluştu.'),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text('Tamam'),
        ),
      ],
    ),
  );
}


  }

  void _showDialog(String title, String content) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Tamam'),
          ),
        ],
      ),
    );
  }

  void _clearFields() {
    _usernameController.clear();
    _businessNameController.clear();
    _phoneController.clear();
    _businessPhoneController.clear();
    _emailController.clear();
    _addressController.clear();
    _passwordController.clear();
    _confirmPasswordController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: kBackgroundColor,
        elevation: 0,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Image(
            width: 24,
            color: Colors.white,
            image: Svg('assets/images/back_arrow.svg'),
          ),
        ),
      ),
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverFillRemaining(
              hasScrollBody: false,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                ),
                child: Column(
                  children: [
                    Flexible(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Kayıt Ol",
                            style: kHeadline,
                          ),
                          Text(
                            "Yeni bir hesap oluştur ve hemen başla.",
                            style: kBodyText2,
                          ),
                          SizedBox(
                            height: 50,
                          ),
                          MyTextField(
                            controller: _usernameController,
                            hintText: 'Kullanıcı Adı',
                            inputType: TextInputType.text,
                            prefixIcon: Icons.person,
                          ),
                          SizedBox(height: 10),
                          MyTextField(
                            controller: _businessNameController,
                            hintText: 'İşletme Adı',
                            inputType: TextInputType.text,
                            prefixIcon: Icons.factory,
                          ),
                          SizedBox(height: 10),
                          MyTextField(
                            controller: _phoneController,
                            hintText: 'Telefon Numarası',
                            inputType: TextInputType.phone,
                            prefixIcon: Icons.phone,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                              LengthLimitingTextInputFormatter(10),
                              PhoneNumberFormatter(),
                            ],
                          ),
                          SizedBox(height: 10),
                          MyTextField(
                             controller: _businessPhoneController,
                            hintText: 'İşletme Telefon Numarası',
                            inputType: TextInputType.phone,
                            prefixIcon: Icons.fax,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                              LengthLimitingTextInputFormatter(10),
                              PhoneNumberFormatter(),
                            ],
                          ),
                          SizedBox(height: 10),
                          MyTextField(
                            controller: _emailController,
                            hintText: 'E-Mail',
                            inputType: TextInputType.emailAddress,
                            prefixIcon: Icons.mail,
                          ),
                          SizedBox(height: 10),
                          MyTextField(
                            controller: _addressController,
                            hintText: 'Adres',
                            inputType: TextInputType.text,
                            prefixIcon: Icons.map,
                          ),
                          SizedBox(height: 10),
                           MyTextField(
                            controller: _passwordController,
                            hintText: 'Şifre',
                            inputType: TextInputType.text,
                            prefixIcon: Icons.lock,
                            obscureText: passwordVisibility,
                            suffixIcon: passwordVisibility
                                ? Icons.visibility
                                : Icons.visibility_off,
                          ),
                          SizedBox(height: 10),
                           MyTextField(
                            controller: _confirmPasswordController,
                            hintText: 'Şifreyi Onayla',
                            inputType: TextInputType.text,
                            prefixIcon: Icons.lock,
                            obscureText: true,
                          ),
                        ],
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Zaten bir hesabın var mı? ",
                          style: kBodyText,
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: Text(
                            "Giriş Yap",
                            style: kBodyText.copyWith(
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 20),
                    MyTextButton(
                      buttonName: 'Kayıt Ol',
                      onTap: _register,
                      bgColor: Colors.white,
                      textColor: Colors.black87,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class PhoneNumberFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    final buffer = StringBuffer();
    final digits = newValue.text.replaceAll(RegExp(r'\D'), '');
    final length = digits.length;

    if (length > 3) {
      buffer.write('(${digits.substring(0, 3)}) ');
      if (length > 6) {
        buffer
            .write('${digits.substring(3, 6)}-${digits.substring(6, length)}');
      } else {
        buffer.write(digits.substring(3));
      }
    } else {
      buffer.write(digits);
    }

    return newValue.copyWith(
      text: buffer.toString(),
      selection: TextSelection.collapsed(offset: buffer.length),
    );
  }
}
