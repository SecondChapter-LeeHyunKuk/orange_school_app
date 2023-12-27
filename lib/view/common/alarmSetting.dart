import 'dart:convert';
import 'dart:ui';

import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_svg/svg.dart';
import 'package:http/src/response.dart';
import 'package:orange_school/style/main-theme.dart';
import 'package:flutter/foundation.dart' as foundation;

import '../../util/api.dart';

String urlMy = "${dotenv.env['BASE_URL']}user/commonMember";
String urlUpdate = "${dotenv.env['BASE_URL']}user/commonMember/setting/alarm";


class AlarmSetting extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _AlarmSetting();
}

class _AlarmSetting extends State<AlarmSetting> {

  Future<Response>? getFuture;

  bool plan = false;
  bool service = false;
  bool ad = false;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(statusBarColor:Colors.white, statusBarIconBrightness: Brightness.dark));
    getFuture = getFirst();
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
          title: Text("알림 설정", style: MainTheme.body5(MainTheme.gray7),),
        ),),
      backgroundColor: Colors.white,
      body:
      FutureBuilder(
          future: getFuture,
          builder: (BuildContext context, AsyncSnapshot snapshot){
            if (snapshot.hasData == false){
              return MainTheme.LoadingPage(context);
            }else if(snapshot.data.statusCode == 200){
              return SingleChildScrollView(
                scrollDirection: Axis.vertical,
                padding: (
                    EdgeInsets.fromLTRB(20, 25, 20, 0)
                ),
                child: Column(

                  children: [

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text("일정 알림", style: MainTheme.body5(MainTheme.gray7),),
                        CupertinoSwitch(value: plan,activeColor: MainTheme.mainColor, trackColor: Color(0xffBEC5CC),onChanged: (bool value){
                            update(0, value);
                        }),

                      ],
                    ),
                    SizedBox(height: 24,),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text("서비스 알림", style: MainTheme.body5(MainTheme.gray7),),
                        CupertinoSwitch(value: service,activeColor: MainTheme.mainColor, trackColor: Color(0xffBEC5CC),onChanged: (bool value){
                          update(1, value);
                        }),

                      ],
                    ),
                    SizedBox(height: 24,),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text("광고성 알림", style: MainTheme.body5(MainTheme.gray7),),
                        CupertinoSwitch(value: ad,activeColor: MainTheme.mainColor, trackColor: Color(0xffBEC5CC),onChanged: (bool value){
                          update(2, value);
                        }),

                      ],
                    ),
                  ],
                ),
              );
            }else{
              return MainTheme.ErrorPage(context, jsonDecode(utf8.decode(snapshot.data.bodyBytes))["message"]);
            }
          }
      )


    );
  }

  Future<Response> getFirst() async {
    var response = await apiRequestGet(urlMy,  {});
    var body =jsonDecode(utf8.decode(response.bodyBytes));
    if(response.statusCode == 200){
      setState(() {
        plan = body["data"]["agreeToSchedule"];
        service = body["data"]["agreeToService"];
        ad = body["data"]["agreeToAd"];
      });
    }
    return response;
  }

  Future<Response> update(int type, bool to) async {

    var response = await apiRequestPut(urlUpdate,  { "agreeToSchedule" : type == 0 ? to : plan, "agreeToService" : type == 1 ? to : service, "agreeToAd" : type == 2 ? to : ad  });
    var body =jsonDecode(utf8.decode(response.bodyBytes));
    if(response.statusCode == 200){
      setState(() {
        plan = type == 0 ? to : plan;
        service = type == 1 ? to : service;
        ad = type == 2 ? to : ad;
      });
    }
    return response;
  }
}
