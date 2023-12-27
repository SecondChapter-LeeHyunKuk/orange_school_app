import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../util/api.dart';
import 'main-theme.dart';



String url = "https://open.neis.go.kr/hub/schoolInfo";

class Popup extends StatefulWidget {

  final Map map;
  @override  const Popup ({ Key? key, required this.map }): super(key: key);

  @override
  State<StatefulWidget> createState() => _Popup();
}

class _Popup extends State<Popup> {
  bool today = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }



  @override
  Widget build(BuildContext context) {
    return

      Center(
        child: Container(
          height: 380,
          width: 273,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12)
          ),
          child:
              Column(
                children: [
              ClipRRect(
              borderRadius: BorderRadius.only(
              topLeft: Radius.circular(12.0),
          topRight: Radius.circular(12.0),
        ),
      child:

          GestureDetector(
            onTap: () async {await launchUrl(Uri.parse(widget.map["link"]));},
            child: Image.network(
              widget.map["fileUrl"],
              width : 273,
              height: 334.5,
              fit: BoxFit.cover,
              errorBuilder: (BuildContext context, Object exception, StackTrace? stackTrace) {
                return Container(
                  width : 273,
                  height: 334.5,
                  color: MainTheme.gray1,
                );
              },
            )),
          ),

                  Container(width: double.infinity,
                  height: 1,
                    color: Color(0xfff9f9f9),
                  ),
                  ClipRRect(
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(12.0),
                        bottomRight: Radius.circular(12.0),
                      ),
                      child:
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 10),
                        width : 273,
                        height: 44.5,
                        color: Colors.white,
                        child: Row(
                          mainAxisAlignment:MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            GestureDetector(
                              onTap: () async {
                                SharedPreferences pref = await SharedPreferences.getInstance();

                                String key = pref.getInt("userId").toString() + "popup" + widget.map["id"].toString();
                                if(today){
                                  pref.remove(key);
                                }else{
                                  pref.setString(key, DateFormat("yyyy-MM-dd").format(DateTime.now()));
                                }
                                setState(() {
                                  today = !today;
                                });
                              },
                              child: IntrinsicWidth(
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    MainTheme.blackCheckBox(today),
                                    Container(width: 8,),
                                    DefaultTextStyle( style:  TextStyle(fontWeight: FontWeight.w500, fontFamily: "Pretendard", fontSize: 14, height:1, color: MainTheme.gray7, letterSpacing: 0),
                                      child: Text("오늘 하루 보지 않기"),)
                                  ],
                                ),
                              )
                            ),

                            GestureDetector(
                              onTap: (){Navigator.of(context).pop();},
                              child:
                                 DefaultTextStyle( style:  TextStyle(fontWeight: FontWeight.w700, fontFamily: "SUIT", fontSize: 15, height:1, color: MainTheme.mainColor, letterSpacing: 0),
                                    child: Text("닫기"),)




                            )
                          ],
                        ),
                      )),


                ],
              )

          ,
        )
        );
  }

  // void searchSchool() async {
  //   index = 1;
  //   data = [];
  //   var responseResult = await apiRequestGet(url,{"Type" : "json", "pIndex" : 1.toString(), "pSize": 10.toString(), "SCHUL_NM" : textEditingController.text , "key" : "8a3319b07614480db9a06c4906426c52"});
  //   var response =jsonDecode(utf8.decode(responseResult.bodyBytes));
  //   if(response["schoolInfo"][0]["head"][1]["RESULT"]["CODE"] == "INFO-000"){
  //     setState(() {
  //       data.addAll(response["schoolInfo"][1]["row"]);
  //     });
  //
  //   }
  // }
  //
  // void scroll() async {
  //   var responseResult =  await apiRequestGet(url,{"Type" : "json", "pIndex" : (index + 1).toString(), "pSize": 10.toString(), "SCHUL_NM" : textEditingController.text , "key" : "8a3319b07614480db9a06c4906426c52"});
  //   var response =jsonDecode(utf8.decode(responseResult.bodyBytes));
  //   if(response["schoolInfo"][0]["head"][1]["RESULT"]["CODE"] == "INFO-000"){
  //
  //     if(response["schoolInfo"][1]["row"].length > 0){
  //       setState(() {
  //         index++;
  //         data.addAll(response["schoolInfo"][1]["row"]);
  //       });
  //     }
  //   }
  // }
}
