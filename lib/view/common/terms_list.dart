import 'dart:convert';
import 'dart:ui';

import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:orange_school/style/main-theme.dart';
import 'package:flutter/foundation.dart' as foundation;

import '../../util/api.dart';

String urlBaseInfo = "${dotenv.env['BASE_URL']}common/baseInfo";
String urlTerms = "${dotenv.env['BASE_URL']}common/terms";

class TermsList extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _TermsList();
}

class _TermsList extends State<TermsList> {
  var businessName = "";
  var representative = "";
  var businessNumber = "";
  var address = "";
  var phoneNumber = "";
  var email = "";
  var list = [];
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getAlarm();
    getTerms();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(50.0),

        child:  AppBar(
          scrolledUnderElevation: 0.0,
          backgroundColor: Colors.white,
          centerTitle: true,
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios_rounded, color: MainTheme.gray7),
            onPressed: () => Navigator.of(context).pop(),
          ),
          title: Text("약관 및 정책", style:MainTheme.body5(MainTheme.gray7)),
        ),),
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Column(

          children: [

            Container(margin: EdgeInsets.symmetric(horizontal: 16, vertical: 23),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children:[
                  ...List.generate(list.length, (index) =>

                      GestureDetector(
                        onTap: (){Navigator.pushNamed(context, "/terms", arguments: list[index]["id"]);},
                       child: Container(
                         margin: EdgeInsets.only(bottom: index == list.length ? 0 : 34),
                         child: Text(list[index]["title"], style: MainTheme.body4(MainTheme.gray7),),
                       ),
                      )
                      )
                ]
              ),
            )
          ],
        ),
      ),
      bottomNavigationBar: Container(
        width: double.infinity,
        color: MainTheme.gray1.withOpacity(0.5),
        padding: EdgeInsets.only(top: 18, left: 20, right: 20, bottom: 54),
        child:
      IntrinsicHeight(
        child:
        Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("사업자 정보", style: MainTheme.body4(MainTheme.gray7),),
            SizedBox(height: 14,),
            Row(
              children: [
                Container(width: 97,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "상호명", style: MainTheme.caption2(MainTheme.gray4),
                  ),),
                Expanded(child:
                Text(
                  businessName, style: MainTheme.caption2(MainTheme.gray4),
                )
                )
              ],
            ),
            SizedBox(height: 7,),
            Row(
              children: [
                Container(width: 97,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "대표자", style: MainTheme.caption2(MainTheme.gray4),
                  ),),
                Expanded(child:
                Text(
                  representative, style: MainTheme.caption2(MainTheme.gray4),
                )
                )
              ],
            ),
            SizedBox(height: 7,),
            Row(
              children: [
                Container(width: 97,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "사업자등록번호", style: MainTheme.caption2(MainTheme.gray4),
                  ),),
                Expanded(child:
                Text(
                  businessNumber, style: MainTheme.caption2(MainTheme.gray4),
                )
                )
              ],
            ),
            SizedBox(height: 7,),
            Row(
              children: [
                Container(width: 97,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "주소", style: MainTheme.caption2(MainTheme.gray4),
                  ),),
                Expanded(child:
                Text(
                  address, style: MainTheme.caption2(MainTheme.gray4),
                )
                )
              ],
            ),
            SizedBox(height: 7,),
            Row(
              children: [
                Container(width: 97,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "전화번호", style: MainTheme.caption2(MainTheme.gray4),
                  ),),
                Expanded(child:
                Text(
                  phoneNumber, style: MainTheme.caption2(MainTheme.gray4),
                )
                )
              ],
            ),
            SizedBox(height: 7,),
            Row(
              children: [
                Container(width: 97,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "이메일", style: MainTheme.caption2(MainTheme.gray4),
                  ),),
                Expanded(child:
                Text(
                  email, style: MainTheme.caption2(MainTheme.gray4),
                )
                )
              ],
            ),
          ],
        )
        ,
      )


      ),
    );
  }
  Future<void> getAlarm() async {
      var response = await apiRequestGet(urlBaseInfo, {});
      var body =jsonDecode(utf8.decode(response.bodyBytes));
      if(response.statusCode == 200){
        setState(() {
           businessName = body["data"]["businessName"];
          representative = body["data"]["representative"];
           businessNumber = body["data"]["businessNumber"];
         address = body["data"]["address"];
           phoneNumber= body["data"]["phoneNumber"];
           email = body["data"]["email"];
        });
      }

  }

  Future<void> getTerms() async {
    var response = await apiRequestGet(urlTerms, {"size" : "100"});
    var body =jsonDecode(utf8.decode(response.bodyBytes));
    if(response.statusCode == 200){
      setState(() {
        list = body["data"]["content"];
      });
    }

  }
}
