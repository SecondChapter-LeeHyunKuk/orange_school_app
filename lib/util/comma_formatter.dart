import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

class CommaFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    var text = newValue.text;

    if(text == ""){
      return newValue.copyWith(
        text: "",);
    }

    if(text.startsWith("0")){
      return oldValue;
    }


    // var buffer = StringBuffer();
    // for (int i = 0; i < text.length; i++) {
    //   buffer.write(text[i]);
    //   var nonZeroIndex = i + 1;
    //   if (nonZeroIndex <= 3) {
    //     if (nonZeroIndex % 3 == 0 && nonZeroIndex != text.length) {
    //       buffer.write('-'); // Add double spaces.
    //     }
    //   } else {
    //     if (nonZeroIndex % 7 == 0 &&
    //         nonZeroIndex != text.length &&
    //         nonZeroIndex > 4) {
    //       buffer.write('-');
    //     }
    //   }
    // }
    var buffer = StringBuffer();
    for (int i = 0; i < text.length; i++) {

      buffer.write(text[i]);
    }



    var string = NumberFormat('###,###,###,###').format(int.parse(buffer.toString())) + "원";
    return newValue.copyWith(
        text: string,);
  }
}