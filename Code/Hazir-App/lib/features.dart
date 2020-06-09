import 'package:Hazir/colors.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class Features{
  static generateShortToast(String message){
    Fluttertoast.showToast(
        msg: message,
        toastLength: Toast.LENGTH_SHORT,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.white,
        textColor: kPrimaryColor,
        fontSize: 14.0);
  }
  static generateLongToast(String message){
    Fluttertoast.showToast(
        msg: message,
        toastLength: Toast.LENGTH_LONG,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.white,
        textColor: kPrimaryColor,
        fontSize: 14.0);
  }
}