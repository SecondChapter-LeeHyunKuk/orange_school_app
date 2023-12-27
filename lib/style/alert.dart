import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../util/api.dart';
import 'main-theme.dart';


class Alert extends StatefulWidget {
  final String title;
  const Alert ({ Key? key, required this.title }): super(key: key);
  @override
  State<StatefulWidget> createState() => _Alert();
}

class _Alert extends State<Alert> {

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(

        contentPadding: EdgeInsets.all(0),
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(10))),

        content:
        Container(
          width: 320,
          height: 154,
          padding: EdgeInsets.fromLTRB(20,30,20,20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(child: Container(
                alignment: Alignment.topCenter,
                child: Text(widget.title, style:MainTheme.body2(MainTheme.gray7),),
              ),),

              Container(
                height: 49,
                child: Row(
                  children: [
                    Expanded(child: ElevatedButton(
                      child: Text("취소",style: MainTheme.body4(Colors.white),),
                      onPressed: (){Navigator.of(context).pop(false);},
                    style: MainTheme.primaryButton(Color(0xffbec5cc))),
                    )   ,
                    SizedBox(width: 8,),
                    Expanded(child: ElevatedButton(
                        child: Text("확인",style: MainTheme.body4(Colors.white),),
                        onPressed: (){Navigator.of(context).pop(true);},
                        style: MainTheme.primaryButton(MainTheme.mainColor)),
                    )
                  ],
                )
              ),
            ],
          ),
        )
        );
  }

}
