import 'dart:ffi';

import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:orange_school/style/main-theme.dart';
import 'package:flutter/foundation.dart' as foundation;
class RegisterComplete extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _RegisterComplete();
}

class _RegisterComplete extends State<RegisterComplete> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        scrolledUnderElevation: 0.0,
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_rounded, color: MainTheme.gray7),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Column(

          children: [
            Container(margin: EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(height: 158,),
                  Container(height: 120,
                  margin: EdgeInsets.only(bottom: 4),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      SvgPicture.asset("assets/images/check.svg", width: 45.67, height: 67,),

                      Text("환영합니다!", style: MainTheme.heading1(MainTheme.gray7),)
                    ],
                  ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text("오렌지스쿨의 ", style: TextStyle(color: MainTheme.gray7, fontWeight: FontWeight.w700, fontFamily: "SUIT",fontSize: 15),),
                      Text("가족 공유 학습 캘린더", style: TextStyle(color: MainTheme.mainColor, fontWeight: FontWeight.w700, fontFamily: "SUIT",fontSize: 15),),
                      Text("를시작하세요", style: TextStyle(color: MainTheme.gray7, fontWeight: FontWeight.w700, fontFamily: "SUIT",fontSize: 15),),
                    ],
                  ),
                  Container(height: 26,),
                  Container(width: 212,
                  height: 45,
                  child: ElevatedButton(
                    style: MainTheme.hollowButton(MainTheme.gray4),
                    onPressed: (){

                      Navigator.of(context).pushReplacementNamed("/registerChild");
                    },
                    child: Text("아이 추가 등록하기", style: TextStyle(color: MainTheme.gray4, fontWeight: FontWeight.w700, fontFamily: "Pretendard",fontSize: 15),),
                  ),
                  )

                ]
              ),
            )
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: EdgeInsets.only(top: 10, left: 20, right: 20, bottom:MediaQuery.of(context).viewPadding.bottom + 10),
        child: ElevatedButton(onPressed: (){
          Navigator.pushNamedAndRemoveUntil(context,'/parentTabBar', (route) => false);
          },
            style: MainTheme.primaryButton(MainTheme.mainColor),
            child: Text("시간표 만들러 가기", style: MainTheme.body4(Colors.white),)),
      ),
    );
  }

}
