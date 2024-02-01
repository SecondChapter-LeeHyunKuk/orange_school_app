import 'dart:async';
import 'dart:convert';
import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:orange_school/style/main-theme.dart';
import 'package:flutter/foundation.dart' as foundation;
import 'package:orange_school/view/common/register_parent.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../util/api.dart';
import '../../util/number_formatter.dart';

String urlSearch = "${dotenv.env['BASE_URL']}common/find/email";
String urlCheckPhone = "${dotenv.env['BASE_URL']}common/find/email/check/phoneNumber";

enum AuthStatus {notAuth, auth, dup, send, missMatch}

class SearchPassword extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _SearchPassword();
}

class _SearchPassword extends State<SearchPassword> {
  bool te_phone_enable = true;
  String? phoneMessage = null;
  //타이머 클래스
  Timer? _timer = null;
  //남은 시간
  int _seconds = 180;
  //이메일 중복 확인 여부

  bool formComplete = false;

  //sms인증 번호
  String? authNum;

  //sms인증 상태
  AuthStatus authStatus = AuthStatus.notAuth;

  TextEditingController te_phone = TextEditingController();
  TextEditingController te_auth = TextEditingController();
  TextEditingController te_name = TextEditingController();
  FocusNode authFocusNode = FocusNode();

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
                    height: 44,
                    child: Text("비밀번호 재설정", style: MainTheme.heading1(MainTheme.gray7)),
                  ),
                  Container(
                    height: 43,
                    margin: EdgeInsets.only(top: 6),
                    child: Text("이메일과 휴대폰번호를 입력하세요", style: MainTheme.body8(MainTheme.gray6)),
                  ),
                  Container(
                    height: 37,
                  ),
                  Text("이름", style: MainTheme.caption1(MainTheme.gray5)),
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
                        controller: te_name,
                        decoration: MainTheme.inputTextGray("이름을 입력하세요"),
                        style: MainTheme.body5(MainTheme.gray7),
                        inputFormatters: [
                          FilteringTextInputFormatter.deny(RegExp('[0-9]')), //글자만
                          LengthLimitingTextInputFormatter(10)
                        ],
                      ),)
                  ),
                  Container(
                    height: 17,
                  ),
                  Text("휴대폰 번호", style: MainTheme.caption1(MainTheme.gray5)),
                  Container(
                    height: 4,
                  ),
                  Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children:[
                        Expanded(child:
                        Container(height: 51,
                            child: Focus(
                              onFocusChange:(value) {
                                if(!value){
                                  checkFormComplete();
                                }
                              }, child :TextField(
                              enabled: te_phone_enable,
                              onChanged: (String value){
                                if(authStatus == AuthStatus.send || authStatus == AuthStatus.missMatch){
                                  _timer!.cancel();
                                  setState(() {
                                    authStatus = AuthStatus.notAuth;
                                    checkFormComplete();
                                  });
                                }else if(authStatus == AuthStatus.auth){
                                  setState(() {
                                    authStatus = AuthStatus.notAuth;
                                    checkFormComplete();
                                  });
                                }
                                setState(() {
                                  phoneMessage = null;
                                });
                              },
                              decoration: MainTheme.inputTextGray("번호만 입력가능합니다"),
                              style: MainTheme.body5(MainTheme.gray7),
                              controller: te_phone,
                              focusNode: authFocusNode,
                              keyboardType:  TextInputType.numberWithOptions(signed: true, decimal: true),
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly, //숫자만!
                                NumberFormatter(),
                                LengthLimitingTextInputFormatter(13) //13자리만 입력받도록 하이픈 2개+숫자 11개
                              ],
                            ),)
                        )
                        ),
                        Container(
                          width: 10,
                        ),
                        authStatus == AuthStatus.missMatch || authStatus == AuthStatus.send ?
                        Container(height: 35,
                            width: 75,
                            margin: EdgeInsets.only(right: 11),
                            child: ElevatedButton(
                              onPressed: (){
                                checkPhone();
                              },
                              style: MainTheme.hollowFollowButton(MainTheme.gray7),
                              child: Text("재전송", style: MainTheme.caption1(MainTheme.gray7),),
                            )
                        ) :

                        Container(height: 35,
                            width: 86,
                            child: ElevatedButton(

                              onPressed: (){
                                checkPhone();
                              },
                              style: MainTheme.followButton(),
                              child: Text("인증하기", style: MainTheme.caption1(Colors.white),),
                            )
                        )
                      ]
                  ),
                  phoneMessage != null ?Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        height: 4,
                      ),
                      Text(phoneMessage!, style: MainTheme.caption2(Color(0xfff24147)),),
                    ],
                  ): SizedBox(height: 0,),
                  authStatus == AuthStatus.auth ?Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        height: 4,
                      ),
                      Text("인증되었습니다.", style: MainTheme.caption2(Color(0xff547cf1)),),
                    ],
                  ): SizedBox.shrink(),
                  authStatus == AuthStatus.dup ?Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        height: 4,
                      ),
                      Text("이미 등록된 휴대폰번호입니다.", style: MainTheme.caption2(Color(0xfff24147)),),
                    ],
                  ): SizedBox.shrink(),
                  authStatus == AuthStatus.missMatch || authStatus == AuthStatus.send ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        height: 17,
                      ),
                      Text("인증번호 입력", style: MainTheme.caption1(MainTheme.gray5)),
                      Container(
                        height: 4,
                      ),
                      Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children:[
                            Expanded(child:
                            Container(height: 51,
                              child: TextField(
                                controller: te_auth,
                                decoration: MainTheme.inputTextAuthNum("번호만 입력가능합니다", _seconds),
                                style: MainTheme.body5(MainTheme.gray7),
                                keyboardType:  TextInputType.numberWithOptions(signed: true, decimal: true),
                                obscureText : true,
                                inputFormatters: [
                                  FilteringTextInputFormatter.digitsOnly, //숫자만!
                                  LengthLimitingTextInputFormatter(6) //13자리만 입력받도록 하이픈 2개+숫자 11개
                                ],
                              ),
                            )
                            ),
                            Container(
                              width: 10,
                            ),
                            Container(height: 35,
                                width: 86,
                                child: ElevatedButton(
                                  onPressed: (){

                                    if(te_auth.text == authNum){
                                      _timer!.cancel();
                                      setState(() {
                                        te_phone_enable;
                                        authStatus = AuthStatus.auth;
                                        te_auth.text = "";
                                      });
                                    }else{
                                      setState(() {
                                        authStatus = AuthStatus.missMatch;
                                        te_auth.text = "";
                                      });
                                    }

                                    checkFormComplete();
                                  },
                                  style: MainTheme.followButton(),
                                  child: Text("인증하기", style: MainTheme.caption1(Colors.white),),
                                )
                            )
                          ]

                      ),
                      authStatus == AuthStatus.missMatch ?Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            height: 4,
                          ),
                          Text("인증번호를 다시 확인해주세요..", style: MainTheme.caption2(Color(0xfff24147)),),
                        ],
                      ): SizedBox.shrink(),

                      Container(
                        height: 17,
                      ),
                    ],
                  ) :
                  Container(
                    height: 17,
                  ),

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
                      child: ElevatedButton(onPressed: formComplete?

                          (){
                        search();
                      } : null,
                          style: MainTheme.primaryButton(MainTheme.mainColor),
                          child: Text("비밀번호 새로 만들기", style: MainTheme.body4(Colors.white),))
                  )
                  ),
                ]

            ),
          )

      ),
    );
  }




  void _startTimer() {
    if(_timer != null){
      if(_timer!.isActive){
        _timer!.cancel();
      }
    }
    authStatus = AuthStatus.send;
    _seconds = 180;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {

      if(_seconds <= 0){
        setState(() {
          authStatus = AuthStatus.notAuth;
          phoneMessage = "인증 시간이 지났어요. 인증을 다시 시도하세요.";
          _timer!.cancel();
        });

      }else{
        setState(() {
          _seconds--;
        });
      }

    });
  }

  @override
  void dispose() {
    if(_timer != null){
      _timer!.cancel();
    }
    super.dispose();
  }


  Future<void> checkPhone() async {

    if(te_phone.text == ""){
      setState(() {
        phoneMessage = "휴대폰 번호를 입력해주세요.";
      });
      return;
    }else if(te_phone.text.length < 13 || !te_phone.text.startsWith("010")){
      setState(() {
        phoneMessage = "휴대폰 번호 형식이 맞지 않아요.";
      });
      return;
    }
    phoneMessage = null;

    Map<String, dynamic> request = new Map<String, Object>();
    request["phoneNumber"] = te_phone.text.replaceAll("-", "");
    var response = await apiRequestPost(context, urlCheckPhone,request);
    var body = jsonDecode(utf8.decode(response.bodyBytes));
    if(response.statusCode == 200){
      // ScaffoldMessenger.of(context)
      //     .showSnackBar(MainTheme.snackBar(body["data"]["randomNumber"]));
      te_auth.clear();
      authNum = body["data"]["randomNumber"];
      authFocusNode.unfocus();
      _startTimer();
    } else if(response.statusCode == 409){
      setState(() {
        authStatus = AuthStatus.dup;
      });
    } else{
      ScaffoldMessenger.of(context)
          .showSnackBar(MainTheme.snackBar(body["message"]));
    }
  }


  void checkFormComplete(){
    if(

    te_name.text.isEmpty ||
        authStatus != AuthStatus.auth
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


  Future<void> search() async {
    var response = await apiRequestGet(context, urlSearch,  {"name" :te_name.text, "phoneNumber" : te_phone.text.replaceAll("-", "")});
    var body =jsonDecode(utf8.decode(response.bodyBytes));

    if(body["data"]["emailList"].length >0){
      Navigator.of(context).pushReplacementNamed("/changePassword", arguments : body["data"]["emailList"]);
    }else{
      ScaffoldMessenger.of(context)
          .showSnackBar(MainTheme.snackBar("등록된 회원정보가 없습니다."));
    }

  }
}
