import 'package:flutter/material.dart';

// Colors
const kBackgroundColor = Color(0xff191720);
const kTextFieldFill = Color(0xff1E1C24);
const kBackGroundColor = Color.fromARGB(255, 255, 255, 255);
// Kategori Renkleri
const kCategoryColor1 = Color(0xffc2f6bf);
const kCategoryColor2 = Color(0xffc8a0f1); 
const kCategoryColor3 = Color(0xfff5c385); 
const kCategoryColor4 = Color(0xfff19baa);
// TextStyles
const kHeadline = TextStyle(
  color: Colors.white,
  fontSize: 34,
  fontWeight: FontWeight.bold,
);

const kBodyText = TextStyle(
  color: Colors.grey,
  fontSize: 15,
);

const kButtonText = TextStyle(
  color: Colors.black87,
  fontSize: 16,
  fontWeight: FontWeight.bold,
);

const kBodyText2 =
    TextStyle(fontSize: 28, fontWeight: FontWeight.w500, color: Colors.white);

const kPrimaryColor = Color(0xFFFF7643);
const kPrimaryLightColor = Color(0xFFFFECDF);
const kPrimaryGradientColor = LinearGradient(
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
  colors: [Color(0xFFFFA53E), Color(0xFFFF7643)],
);
const kSecondaryColor = Color(0xFF979797);
const kTextColor = Colors.black;

const kAnimationDuration = Duration(milliseconds: 200);

const headingStyle = TextStyle(
  fontSize: 24,
  fontWeight: FontWeight.bold,
  color: Colors.black,
  height: 1.5,
);

const defaultDuration = Duration(milliseconds: 250);

// Form Error
final RegExp emailValidatorRegExp =
    RegExp(r"^[a-zA-Z0-9.]+@[a-zA-Z0-9]+\.[a-zA-Z]+");
const String kEmailNullError = "Please Enter your email";
const String kInvalidEmailError = "Please Enter Valid Email";
const String kPassNullError = "Please Enter your password";
const String kShortPassError = "Password is too short";
const String kMatchPassError = "Passwords don't match";
const String kNamelNullError = "Please Enter your name";
const String kPhoneNumberNullError = "Please Enter your phone number";
const String kAddressNullError = "Please Enter your address";

final otpInputDecoration = InputDecoration(
  contentPadding: const EdgeInsets.symmetric(vertical: 16),
  border: outlineInputBorder(),
  focusedBorder: outlineInputBorder(),
  enabledBorder: outlineInputBorder(),
);

OutlineInputBorder outlineInputBorder() {
  return OutlineInputBorder(
    borderRadius: BorderRadius.circular(16),
    borderSide: const BorderSide(color: kTextColor),
  );
}

class Category {
  final String image;
  final Color color;

  Category({required this.image, required this.color});
}

List<Category> categories = [
  Category(
    
    image: "assets/screwdriver.png",
    color: const Color(0xffc2f6bf),
  ),
  Category(
   
    image: "assets/fridge.png",
    color: const Color(0xffc8a0f1),
  ),
  Category(
    
    image: "assets/fitness.png",
    color: const Color(0xfff5c385),
  ),
  Category(
   
    image: "assets/screwdriver.png",
    color: const Color(0xfff19baa),
  ),
  Category(
    
    image: "assets/screwdriver.png",
    color: Colors.orange,
  ),
];