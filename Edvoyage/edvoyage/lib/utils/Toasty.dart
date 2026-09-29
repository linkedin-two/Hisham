import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class Toasty {
  static showtoast(
    String message, {
    int second = 1,
    Color? backgroundColor,
  }) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.CENTER,
      textColor: Colors.white,
      backgroundColor: backgroundColor ?? Colors.black.withValues(alpha: 0.5),
    );
  }

  static showSuccess(String message, {int second = 1}) {
    return showtoast(
      message,
      second: second,
      backgroundColor: Colors.green,
    );
  }

  static showError(String message, {int second = 1}) {
    return showtoast(
      message,
      second: second,
      backgroundColor: Colors.red,
    );
  }
}
