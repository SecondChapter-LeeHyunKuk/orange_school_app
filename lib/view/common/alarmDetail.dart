import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:intl/intl.dart';
import 'package:orange_school/style/main-theme.dart';
import 'package:flutter/foundation.dart' as foundation;

import '../../util/api.dart';

String urlSearch = "${dotenv.env['BASE_URL']}user/memberAlarm";

class AlarmDetail extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _AlarmDetail();

}
@override

class _AlarmDetail extends State<AlarmDetail> {
  Map data = {};
  bool changePassword = false;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(statusBarColor:Colors.white, statusBarIconBrightness: Brightness.dark));
  }

  @override
  Widget build(BuildContext context) {
    data = ModalRoute.of(context)?.settings.arguments as Map;
    get();
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
        ),),
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Column(

          children: [

            Container(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  Container(
                    padding: EdgeInsets.fromLTRB(20,20,20,21.5),
                    child:
                        Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              data["title"],
                              style: MainTheme.body4(MainTheme.gray7),
                            ),
                            SizedBox(height: 10,),
                            Text(
                              DateFormat('yyyy.MM.dd').format(DateTime.parse(data["createdAt"])),
                              style: MainTheme.caption3(MainTheme.gray5),
                            ),
                          ],
                        )

                  ),
                  Container(height: 1,width: double.infinity, color:MainTheme.gray2 ,),
                  Container(
                      padding: EdgeInsets.fromLTRB(20,29.5,20,32),
                      child:
                      Text(
                        data["content"], style: MainTheme.body6(MainTheme.gray7),
                      ),

                  ),

                ]
              ),
            )
          ],
        ),
      ),
    );
  }

  Future<void> get() async {
    await apiRequestGet(context, "$urlSearch/" + data["id"].toString(),  {});
  }
}
