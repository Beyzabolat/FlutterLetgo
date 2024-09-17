// ignore_for_file: use_super_parameters, prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../constants.dart';

class MyTextField extends StatelessWidget {
  const MyTextField({
    Key? key,
    required this.hintText,
    required this.inputType,
    required this.controller,
    this.prefixIcon, 
    this.suffixIcon,
    this.inputFormatters,
    this.obscureText = false, 
  }) : super(key: key);

  final String hintText;
  final TextInputType inputType;
  final TextEditingController controller;
  final IconData? prefixIcon; 
  final IconData? suffixIcon; 
  final List<TextInputFormatter>? inputFormatters;
  final bool obscureText;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: TextField(
        controller: controller,
        style: kBodyText.copyWith(color: Colors.white),
        keyboardType: inputType,
        obscureText: obscureText,
        textInputAction: TextInputAction.next,
        inputFormatters: inputFormatters,
        decoration: InputDecoration(
          contentPadding: EdgeInsets.all(20),
          hintText: hintText,
          hintStyle: kBodyText,

          prefixIcon: prefixIcon != null
              ? Icon(prefixIcon, color: Colors.white)
              : null,
          suffixIcon: suffixIcon != null
              ? Icon(suffixIcon, color: Colors.white)
              : null, 
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(
              color: Colors.grey,
              width: 1,
            ),
            borderRadius: BorderRadius.circular(18),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(
              color: Colors.white,
              width: 1,
            ),
            borderRadius: BorderRadius.circular(18),
          ),
        ),
      ),
    );
  }
}
