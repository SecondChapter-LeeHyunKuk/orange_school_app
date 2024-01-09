import 'dart:ui';
import 'package:flutter_html/flutter_html.dart';
import 'package:url_launcher/url_launcher.dart'; // 패키지
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:orange_school/style/main-theme.dart';
import 'package:flutter/foundation.dart' as foundation;
class ParentBoardDetail extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _ParentBoardDetail();
}

class _ParentBoardDetail extends State<ParentBoardDetail> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final data = ModalRoute.of(context)?.settings.arguments as Map;
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(statusBarColor:Colors.white, statusBarIconBrightness: Brightness.dark));
    return Scaffold(
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(50.0),

          child:  AppBar(
          scrolledUnderElevation: 0.0,
          backgroundColor:Colors.white,

          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios_rounded, color: MainTheme.gray7),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),),
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child:
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 13,),
              Text(data["title"], style: MainTheme.heading8(MainTheme.gray7),),
              SizedBox(height: 5,),
              Text( DateFormat('yyyy-MM-dd').format(DateTime.parse(data["createdAt"])), style: MainTheme.body4(MainTheme.gray5),),
              SizedBox(height: 27,),
              Html(data: data["content"],),
              SizedBox(height: 16,),
            ],
          )


        )
      ),
      bottomNavigationBar:
      (data["link"]??"") == "" ? SizedBox.shrink() :

      Padding(
        padding: EdgeInsets.only(top: 10, left: 20, right: 20, bottom: MediaQuery.of(context).viewPadding.bottom + 10),
        child: ElevatedButton(onPressed: () async {


          await launchUrl(Uri.parse(data["link"]));

          },
            style: MainTheme.primaryButton(MainTheme.mainColor),
            child: Text("관련 링크로 이동", style: MainTheme.body4(Colors.white),)),
      ),
    );
  }

}
