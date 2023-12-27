import 'dart:convert';
import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:orange_school/style/main-theme.dart';
import 'package:flutter/foundation.dart' as foundation;
import 'package:orange_school/util/api.dart';

import '../../style/alert.dart';

String urlReset = "${dotenv.env['BASE_URL']}common/reset/password";

class ChangePassword extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _ChangePassword();
}

class _ChangePassword extends State<ChangePassword> {
  bool formComplete = false;
  TextEditingController te_password = TextEditingController();
  TextEditingController te_password_check = TextEditingController();
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
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 40,
                  ),
                  Container(
                    height: 93,
                    child: Text("비밀번호 재설정", style: MainTheme.heading1(MainTheme.gray7)),
                  ),
                  Container(
                    height: 17,
                  ),
                  Text("비밀번호", style: MainTheme.caption1(MainTheme.gray5)),
                  Container(
                    height: 4,
                  ),
                  Container(height: 51,
                      child: Focus(
                        onFocusChange:(value) {
                          if(!value){
                            checkFormComplete();
                          }
                        }, child :TextField(
                        controller: te_password,
                        decoration: MainTheme.inputTextGray("비밀번호를 입력하세요"),
                        obscureText : true,
                        style: MainTheme.body5(MainTheme.gray7),
                        inputFormatters: [
                          LengthLimitingTextInputFormatter(16)
                        ],
                      ),)
                  ),

                  Container(
                    height: 17,
                  ),
                  Text("비밀번호 재입력", style: MainTheme.caption1(MainTheme.gray5)),
                  Container(
                    height: 4,
                  ),
                  Container(height: 51,
                      child: Focus(
                        onFocusChange:(value) {
                          if(!value){
                            checkFormComplete();
                          }
                        }, child :TextField(
                        controller: te_password_check,
                        decoration: MainTheme.inputTextGray("비밀번호를 다시 입력하세요"),
                        obscureText : true,
                        inputFormatters: [
                          LengthLimitingTextInputFormatter(16)
                        ],
                        style: MainTheme.body5(MainTheme.gray7),
                      ),)
                  ),

                ],
              ),
            )
          ],
        ),
      ),
      bottomNavigationBar: Padding(
          padding: EdgeInsets.only(top: 10, left: 20, right: 20, bottom: 10),
          child:
          SizedBox(
            height: 49,
            child:         Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                crossAxisAlignment: CrossAxisAlignment.center,
                children:[
                  Expanded(child:
                  Container(height: 49,
                      child: ElevatedButton(onPressed:
                      formComplete?
                          (){

                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return Alert(title: "비밀번호를 새로 만드시겠어요?");
                              },
                            )
                                .then((val) {
                              if (val != null) {
                                if(val){
                                  changePassword();
                                }
                              }
                            });

                      } : null,
                          style: MainTheme.primaryButton(MainTheme.mainColor),
                          child: Text("저장하기", style: MainTheme.body4(Colors.white),))
                  )
                  ),
                ]

            ),
          )

      ),
    );
  }

  void checkFormComplete(){
    if(
        te_password.text.isEmpty ||
        te_password.text != te_password_check.text ||
        !RegExp(r'^(?=.*[a-zA-Z])(?=.*\d)(?=.*[\W_])', caseSensitive: false).hasMatch(te_password.text)
    ){
      setState(() {
        formComplete = false;
      });
    }else{
      setState(() {
        formComplete = true;
      });
    }
  }

  Future<void> changePassword() async {
    final emailList = ModalRoute.of(context)?.settings.arguments as List;
    var response = await apiRequestPost(urlReset,  {"email" : emailList[0], "password" : te_password.text});
    var body =jsonDecode(utf8.decode(response.bodyBytes));
    if(response.statusCode == 200){
      ScaffoldMessenger.of(context)
          .showSnackBar(MainTheme.snackBar("비밀번호를 변경했습니다."));

            Navigator.pushNamedAndRemoveUntil(context,'/login', (route) => false);
    }else{
      ScaffoldMessenger.of(context)
          .showSnackBar(MainTheme.snackBar(body["message"]));
    }
  }
}
