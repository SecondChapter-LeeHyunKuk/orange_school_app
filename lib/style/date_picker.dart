import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:loading_indicator/loading_indicator.dart';

import 'main-theme.dart';

class DatePicker extends StatefulWidget {
  final DateTime initTime;
  const DatePicker ({ Key? key, required this.initTime }): super(key: key);
  @override
  _DatePicker createState() => _DatePicker();
}

class _DatePicker extends State<DatePicker> {
  DateTime? pickerSelectDay = null;

  @override
  void initState() {
    super.initState();
    pickerSelectDay = widget.initTime;
  }

  @override
  Widget build(BuildContext context) {

    return Container(
      height: 288,

      decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ) ),

      child:Column(
        children: [
          Expanded(child:
      ClipRRect(
      borderRadius: BorderRadius.circular(24.0),
        child:
          CupertinoDatePicker(
            backgroundColor:
            CupertinoColors.white,
            mode: CupertinoDatePickerMode.date,
            initialDateTime: widget.initTime,
            onDateTimeChanged: (newDateTime) {
              pickerSelectDay = newDateTime;
            },
          ))
          ),

          Container(
            height: 98,
            padding: EdgeInsets.fromLTRB(16, 10, 16, 39),
            child:
            ElevatedButton(
                onPressed: (){
                  Navigator.pop(context, pickerSelectDay);
                },
                style: MainTheme.primaryButton(MainTheme.mainColor),
                child: Text("적용", style: MainTheme.body4(Colors.white),)),

          )
        ],
      )


      ,

    );

  }
}

