// ignore_for_file: file_names, avoid_print, prefer_const_constructors

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:project/Screens/HomeScreen.dart';
import '../constants.dart';
import '../screens/screen.dart';
import 'package:flutter_svg_provider/flutter_svg_provider.dart';
import '../widgets/widget.dart';
import 'package:project/apihandler.dart';

class Loginscreen extends StatefulWidget {
  const Loginscreen({super.key});

  @override
  State<Loginscreen> createState() => _CombinedLoginScreenState();
}

class _CombinedLoginScreenState extends State<Loginscreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final ApiHandler _apiHandler = ApiHandler();
  List<Map<String, dynamic>> _clientCards = [];
  bool isPasswordVisible = true;

  @override
  void initState() {
    super.initState();
    _loadClientCards();
  }

  Future<void> _loadClientCards() async {
    final tablesData = await _apiHandler.getTablesWithData();
    final clientCards = tablesData['ClientCard'] ?? [];
    setState(() {
      _clientCards = clientCards;
    });
  }

  Future<void> _login() async {
    final username = _usernameController.text;
    final password = _passwordController.text;
    String clientRef = "";
    _usernameController.text = "";
    _passwordController.text = "";

    if (username.trim().isEmpty || password.trim().isEmpty) {
      print('Fields are empty: Username: $username, Password: $password');
      _showDialog('Giriş Başarısız', 'Kutucuklar boş bırakılamaz.');
      return;
    }

    final isValidUser = _clientCards.any((clientCard) =>
    clientCard['UserName'] == username && clientCard['UserPassword'] == password);

    if (isValidUser) {
      clientRef = _clientCards.firstWhere((clientCard) =>
          clientCard['UserName'] == username &&
          clientCard['UserPassword'] == password)['Ref'];
      _showDialog('Giriş Başarılı', 'Hoşgeldiniz.');
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (context) => MyHomePage(clientRef: clientRef)),
      );
    } else {
      _showDialog('Giriş Başarısız', 'Kullanıcı adı veya şifre hatalı.');
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

  void _notRegistered() {
    Navigator.pushReplacement(
      context,
      CupertinoPageRoute(builder: (context) => Registerscreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: kBackgroundColor,
        elevation: 0,
        leading: IconButton(
  onPressed: () {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => WelcomePage()), // WelcomeScreen yönlendirmesi
    );
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
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Tekrar hoş geldiniz.",
                      style: kHeadline,
                    ),
                    SizedBox(height: 10),
                    Text(
                      "Sizi özledik!",
                      style: kBodyText2,
                    ),
                    SizedBox(height: 60),
                    MyTextField(
                      controller: _usernameController,
                      hintText: 'Telefon, e-posta veya kullanıcı adı',
                      inputType: TextInputType.text,
                    ),
                    SizedBox(height: 10),
                    MyPasswordField(
                      controller: _passwordController,
                      isPasswordVisible: isPasswordVisible,
                      onTap: () {
                        setState(() {
                          isPasswordVisible = !isPasswordVisible;
                        });
                      },
                    ),
                    SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Hesabınız yok mu? ",
                          style: kBodyText,
                        ),
                        GestureDetector(
                          onTap: _notRegistered,
                          child: Text(
                            'Kayıt Ol',
                            style: kBodyText.copyWith(
                              color: Colors.white,
                            ),
                          ),
                        )
                      ],
                    ),
                    SizedBox(height: 20),
                    MyTextButton(
                      buttonName: 'Giriş Yap',
                      onTap: _login,
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
