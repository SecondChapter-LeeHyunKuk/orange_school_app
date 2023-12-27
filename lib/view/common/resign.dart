import 'dart:convert';
import 'dart:ui';

import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:orange_school/style/main-theme.dart';
import 'package:flutter/foundation.dart' as foundation;
import 'package:shared_preferences/shared_preferences.dart';

import '../../util/api.dart';

String urlResign = "${dotenv.env['BASE_URL']}user/leaveMember";

List reasons = [
  "원하는 서비스가 없어요",
  "오렌지스쿨을 사용하기가 어려워요.",
  "오렌지스쿨에서 불쾌한 경험을 했어요.",
  "새로운 계정을 만들고 싶어요.",
  "기타"
];

List values = [
    "NO_WANTED",
    "USE_DIFFICULT",
    "BAD_EX",
    "NEW_ACCOUNT",
    "ETC"
];

class Resign extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _Resign();
}

class _Resign extends State<Resign> {
  int reasonIndex = 0;
  TextEditingController te_resonDetail = TextEditingController();
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(statusBarColor:Colors.white, statusBarIconBrightness: Brightness.dark));
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
          title: Text("계정관리", style:MainTheme.body5(MainTheme.gray7)),
        ),),
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Column(

          children: [

            Container(margin: EdgeInsets.symmetric(horizontal: 20, vertical: 41),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("오렌지스쿨 떠나기", style: MainTheme.heading1(MainTheme.gray7)),
                  Container(
                    height: 6,
                  ),
                  Text("회원탈퇴 사유를 알려주시면\n더 나은 서비스로 발전하겠습니다.", style: MainTheme.body9(MainTheme.gray6)),
                  Container(
                    height: 50,
                  ),


                      ...List.generate(reasons.length, (index) =>
                        Container(
                          margin: EdgeInsets.only(bottom: 24),
                          child:  Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              CupertinoRadio<int>(
                                value: index,
                                activeColor: MainTheme.mainColor,
                                groupValue: reasonIndex,
                                onChanged: (int? value) {
                                  setState(() {
                                    reasonIndex = value!;
                                  });
                                },
                              ),
                              SizedBox(width: 8,),
                              Text(reasons[index], style: MainTheme.body4(MainTheme.gray7),)
                            ],
                          ),

                        )


                      ),
                  reasonIndex == 4 ? Container(height: 51,
                      child: Focus(
                        child :TextField(
                            controller: te_resonDetail,
                            decoration: MainTheme.inputTextGray("상세 사유를 입력해 주세요."),
                            style: MainTheme.body5(MainTheme.gray7)
                        ),)
                  ) : SizedBox.shrink(),



        ]
              ),
            ),




          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: EdgeInsets.only(top: 10, left: 20, right: 20, bottom: 10),
        child: ElevatedButton(onPressed: (){
          showDialog(
            context: context,
            barrierDismissible: true, //바깥 영역 터치시 닫을지 여부 결정
            builder: ((context) {
              ScrollController _scrollController= ScrollController();

              return AlertDialog(
                contentPadding: EdgeInsets.all(0),
                backgroundColor: Colors.white,
                surfaceTintColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(10))),
                content:Container(
                  width: 320, height: 204,
                  padding: EdgeInsets.all(20),
                  child:Column(
                    children: [
                      Expanded(child: 
                      Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text("정말 탈퇴하시겠어요?", style: MainTheme.body2(MainTheme.gray7),),
                          Text("탈퇴 시 계정복구가 불가하며 데이터가 모두\n삭제됩니다. 그래도 탈퇴하시겠습니까?", style: TextStyle(fontWeight: FontWeight.w600, fontFamily: "SUIT", fontSize: 15, height:1.486, color: MainTheme.gray5, letterSpacing: 0),
                          textAlign: TextAlign.center,

                          ),
                        ],
                      )
                      ),
                      Container(
                        width: double.infinity,
                        height: 49,
                        child: ElevatedButton(
                          onPressed: (){
                            resign();
                          },
                          child: Text("확인", style: MainTheme.body4(Colors.white),),
                          style: MainTheme.primaryButton(MainTheme.mainColor),
                        ),
                      )
                    ],
                  ),
                ),
              );
            }),
          );


        },
            style: MainTheme.primaryButton(MainTheme.mainColor),
            child: Text("탈퇴하기", style: MainTheme.body4(Colors.white),)),
      ),
    );
  }
  Future<void> resign() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    var response = await apiRequestPost(urlResign, {"leaveType" : values[reasonIndex], "reasonDetail" : te_resonDetail.text});
    var body =jsonDecode(utf8.decode(response.bodyBytes));
    if(response.statusCode == 200){
      pref.setBool("autoLogin", false);
      pref.remove("email");
      pref.remove("password");
      Navigator.pushNamedAndRemoveUntil(context,'/login', (route) => false);
    }else{
      ScaffoldMessenger.of(context)
          .showSnackBar(MainTheme.snackBar(body["message"]));
    }
  }
}
