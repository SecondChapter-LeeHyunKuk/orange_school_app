import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';

class SevenFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    var text = newValue.text;

    if(text == ""){
      return newValue.copyWith(
          text: text,
          selection: TextSelection.collapsed(offset: 0));
    }

    return newValue.copyWith(
        text: text + '●●●●●●●',
        selection: TextSelection.collapsed(offset: 1));
  }
}