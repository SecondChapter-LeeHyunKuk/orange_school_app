import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:orange_school/style/main-theme.dart';
import 'package:flutter/foundation.dart' as foundation;
class SearchEmailResult extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _SearchEmailResult();
}

class _SearchEmailResult extends State<SearchEmailResult> {
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final emailList = ModalRoute.of(context)?.settings.arguments as List;
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
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 40,
                  ),
                  Container(
                    height: 44,
                    child: Text("이메일 찾기", style: MainTheme.heading1(MainTheme.gray7)),
                  ),
                  Container(
                    height: 43,
                    margin: EdgeInsets.only(top: 6),
                    child: Text("조회된 이메일입니다.", style: MainTheme.body8(MainTheme.gray6)),
                  ),
                  Container(
                    height: 18,
                  ),
                  ...List.generate(emailList.length, (index) => Container(
                    margin: EdgeInsets.only(bottom: index == emailList.length-1 ? 0 : 20),
                    child: Text(replaceAtSymbol(emailList[index]), style: MainTheme.body5(MainTheme.gray7)),
                  )),

                  Container(
                    height: 66,
                  ),
                  Container(
                    height: 18,
                  ),
                  Row(

                    children: [
                      Text("비밀번호를 잊으셨나요?", style: MainTheme.body5(MainTheme.gray7)),
                      Container(width: 13),
                      GestureDetector(onTap: (){
                        Navigator.pushNamedAndRemoveUntil(context,'/searchPassword', (route) => false);
                      }, child: Text("비밀번호찾기", style: TextStyle(fontWeight: FontWeight.w600, fontFamily: "SUIT", fontSize: 15, color: MainTheme.mainColor)),)

                    ],
                  )


                ],
              ),
            )
          ],
        ),
      ),
      bottomNavigationBar: Padding(
          padding: EdgeInsets.only(top: 10, left: 20, right: 20, bottom: MediaQuery.of(context).viewPadding.bottom + 10),
          child:
          SizedBox(
            height: 49,
            child:         Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                crossAxisAlignment: CrossAxisAlignment.center,
                children:[
                  Expanded(child:
                  Container(height: 49,
                      child: ElevatedButton(onPressed: (){
                        Navigator.pushNamedAndRemoveUntil(context,'/login', (route) => false);
                      },
                          style: MainTheme.primaryButton(MainTheme.mainColor),
                          child: Text("로그인하러 가기", style: MainTheme.body4(Colors.white),))
                  )
                  ),
                ]

            ),
          )

      ),
    );
  }

  String replaceAtSymbol(String input) {
    int atIndex = input.indexOf('@');

    print(atIndex);
    if (atIndex != -1 && atIndex >= 4) {
      // @ 앞의 3문자를 %로 치환
      String replacedString = input.replaceRange(atIndex - 3, atIndex, '●●●');
      return replacedString;
    } else {
      String replacedString = input.replaceRange(atIndex - 2, atIndex, '●●');
      return replacedString;
    }
  }


/* 자동로그인(사용안함)
  Future<void> _autoLoginTry() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    String? isAutoLogin = pref.getString("autoLogin");
    if (isAutoLogin != null) {
      if (isAutoLogin == "TRUE") {
        autoLoginChecked = true;
        TextEditingControllerId.text = pref.getString("autoLoginId")!;
        TextEditingControllerPw.text = pref.getString("autoLoginPw")!;
        fn_M0_F0();
      }
    }
  }
  */
}
