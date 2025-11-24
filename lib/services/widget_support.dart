import 'package:flutter/material.dart';

class AppWidget{
  // ignore: non_constant_identifier_names
  static TextStyle HeadLineTextfeildStyle(double textsize){
    return TextStyle(
      color: Colors.black,
      fontSize: textsize,
      fontWeight: FontWeight.bold,
    );
  }

  static TextStyle SimpleTextfeildStyle(){
    return TextStyle(
      color: Colors.black38,
      fontSize: 18.0,
      fontWeight: FontWeight.w500,
    );
  }

  static TextStyle slowSimpleTextfeildStyle(){
    return TextStyle(
      color: Colors.black38,
      fontSize: 15.0,
      fontWeight: FontWeight.w500,
    );
  }

  static TextStyle WhiteTextfeildStyle(){
    return TextStyle(
      color: Colors.white,
      fontSize: 24.0,
      fontWeight: FontWeight.bold,
    );
  }

  static TextStyle differentshadetWhiteTextfeildStyle(){
    return TextStyle(
      color: Colors.white54,
      fontSize: 17.0,
      fontWeight: FontWeight.w500,
    );
  }

}