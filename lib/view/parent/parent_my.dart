
import 'dart:convert';
import 'dart:ui';

import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:orange_school/style/main-theme.dart';
import 'package:flutter/foundation.dart' as foundation;
import 'package:flutter_svg/svg.dart';
import 'package:orange_school/util/api.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../style/alert.dart';

class ParentMy extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _ParentMy();
}
String urlAlarm = "${dotenv.env['BASE_URL']}user/memberAlarm/new/exist";
class _ParentMy extends State<ParentMy> {

  String name = "   ";
  String email = "";
  bool? alarm;

  @override
  void initState() {
    // TODO: implement initState
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(statusBarColor:Colors.white, statusBarIconBrightness: Brightness.dark));
    super.initState();
    getAlarm();
    getMy();
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: Colors.white,
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(0),

          child:  AppBar(
            backgroundColor: Colors.white,

          ),),
      body:
        Container(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child:
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: MediaQuery.of(context).viewPadding.top),
              Container(height: 50,
              alignment: Alignment.centerRight,
                child:
                    GestureDetector(
                      onTap: (){Navigator.of(context).pushNamed("/alarm");},
                      child: alarm == null ? SizedBox.shrink() : SvgPicture.asset(
                        'assets/icons/alarm${alarm! ? "_on" : ""}.svg',
                        width: 24,
                        height: 24,
                      ),
                    )

              ),

              SizedBox(height: 9,),
              GestureDetector(
              behavior: HitTestBehavior.translucent,
              onTap: (){Navigator.of(context).pushNamed('/parent/update').then((value) => getMy());},
                child:
              IntrinsicWidth(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text("${name}님", style: MainTheme.heading7(MainTheme.gray7),),
                    SizedBox(width: 13,),
                    SvgPicture.asset(
                      'assets/icons/arrow_right.svg',
                      width: 16,
                      height: 16,
                    ),
                  ],
                ),
              ),
              ),

              Text(email, style: MainTheme.body6(MainTheme.gray5),),
              SizedBox(height: 23,),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children:[
                  Text("친구를 초대해보아요!", style: MainTheme.body2(MainTheme.gray7),),
                  Container(
                    width: 71, height: 33,
                  child: ElevatedButton(
                    style: MainTheme.primaryButton(MainTheme.subColor.withOpacity(0.1)),
                    onPressed: (){
                      Clipboard.setData(ClipboardData(text: "https://orangeschool.imweb.me/home"));
                      ScaffoldMessenger.of(context)
                          .showSnackBar(MainTheme.snackBar("링크가 복사되었습니다."));
                    }, child: Text("친구초대", style: MainTheme.body4(MainTheme.subColor),),)
                  )

                ]
              ),
              SizedBox(height: 16,),
              GestureDetector(
                behavior: HitTestBehavior.translucent,
                onTap: (){Navigator.of(context).pushNamed('/parent/my/children');},
                child:
              Text("자녀 관리", style: MainTheme.body4(MainTheme.gray7)),),
              SizedBox(height: 34,),
              GestureDetector(
                behavior: HitTestBehavior.translucent,
                onTap: (){Navigator.of(context).pushNamed('/alarm/setting');},
                child:
                Text("알림 설정", style: MainTheme.body4(MainTheme.gray7)),),
              SizedBox(height: 34,),
              GestureDetector(
                behavior: HitTestBehavior.translucent,
                onTap: (){Navigator.of(context).pushNamed('/notice');},
                child:
                Text("공지사항", style: MainTheme.body4(MainTheme.gray7)),),
              SizedBox(height: 34,),
              GestureDetector(
                behavior: HitTestBehavior.translucent,
                onTap: (){Navigator.of(context).pushNamed('/terms/list');},
                child:
                Text("약관 및 정책", style: MainTheme.body4(MainTheme.gray7)),),
              SizedBox(height: 70,),
              GestureDetector(
                  behavior: HitTestBehavior.translucent,
                  onTap: (){Navigator.of(context).pushNamed('/resign');},
                  child:
              Text("탈퇴하기", style: MainTheme.body5(MainTheme.gray4))),
              SizedBox(height: 17,),
              GestureDetector(
                onTap: () async {

                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return Alert(title: "로그아웃 하시겠어요?");
                    },
                  )
                      .then((val) async {
                    if (val != null) {
                      if(val){
                        SharedPreferences pref = await SharedPreferences.getInstance();
                        pref.setBool("autoLogin", false);
                        Navigator.pushNamedAndRemoveUntil(context,'/login', (route) => false);
                      }
                    }
                  });


                },
                child: Text("로그아웃", style: MainTheme.body5(MainTheme.gray4)),
              )

            ],
          )


        )

    );
  }
  Future<void> getAlarm() async {
    var response = await apiRequestGet(urlAlarm,  {});
    var body =jsonDecode(utf8.decode(response.bodyBytes));
    setState(() {
      alarm = body["data"];
    });
  }

  Future<void> getMy() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    setState(() {
      name = pref.getString("name")!;
      email = pref.getString("email")!;
    });

  }

}
