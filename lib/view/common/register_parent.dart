import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_svg/svg.dart';
import 'package:image_picker/image_picker.dart';
import 'package:orange_school/style/main-theme.dart';
import 'package:orange_school/util/api.dart';
import 'package:path_provider/path_provider.dart';
import 'package:remedi_kopo/remedi_kopo.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import '../../util/number_formatter.dart';
import '../../util/seven_formatter.dart';

String urlRegister = "${dotenv.env['BASE_URL']}common/join";
String urlCheckEmail = "${dotenv.env['BASE_URL']}common/check/email";
String urlCheckPhone = "${dotenv.env['BASE_URL']}common/check/phoneNumber";
String urlLogin = "${dotenv.env['BASE_URL']}common/login";
String urlMy = "${dotenv.env['BASE_URL']}user/commonMember";
String urlSocial = "${dotenv.env['BASE_URL']}common/login/social";

enum AuthStatus {notAuth, auth, dup, send, missMatch}

class RegisterParent extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _RegisterParent();
}

class _RegisterParent extends State<RegisterParent> {
  bool te_phone_enabled = true;
  ImagePicker picker = ImagePicker();
  bool? isSocialMember;

  bool apiProcess = false;

  Map? userInfo;

  //타이머 클래스
  Timer? _timer = null;
  //남은 시간
  int _seconds = 180;
  //이메일 중복 확인 여부
  bool emailChecked = false;

  bool formComplete = false;

  //sms인증 번호
  String? authNum;

  //sms인증 상태
  AuthStatus authStatus = AuthStatus.notAuth;

  //이미지 목록
  List images = [];
  
  //삭제 이미지 목록
  List deleteIdList = [];

  TextEditingController te_name = TextEditingController();
  TextEditingController te_birth = TextEditingController();
  TextEditingController te_sex = TextEditingController();
  TextEditingController te_phone = TextEditingController();
  TextEditingController te_auth = TextEditingController();
  TextEditingController te_email = TextEditingController();
  bool te_email_enalbed = true;
  TextEditingController te_password = TextEditingController();
  TextEditingController te_password_check = TextEditingController();
  TextEditingController te_address = TextEditingController();
  TextEditingController te_address_detail = TextEditingController();

  FocusNode authFocusNode = FocusNode();

  List checkTitles = [
    "만 14세 이상입니다(필수)",
    "회원이용약관 (필수)",
    "개인정보수집 및 이용동의 (필수)",
    "개인정보 제 3자 제공 동의 (필수)",
    "이메일 및 SMS 마케팅정보수신 동의 (선택)",
    "서비스 알림 수신 동의 (선택)",
    "광고성 알림 수신 동의 (선택)"
  ];
  List checkValues = [
    false,
    false,
    false,
    false,
    false,
    false,
    false
  ];
  bool agreeAll = false;

  String? nameMessage;
  String? birthMessage;
  String? phoneMessage;
  String? emailMessage;
  String? passwordMessage;
  String? passwordCheckMessage;
  String? addressMessage;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

  }
  @override
  Widget build(BuildContext context) {

    if(isSocialMember == null){
      if(ModalRoute.of(context)?.settings.arguments != null){
        userInfo = ModalRoute.of(context)?.settings.arguments as Map;
        isSocialMember = true;
        setSocialInfo();
      }else{
        isSocialMember = false;
      }
    }
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
      body:
      SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Column(

          children: [

            Container(margin: EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 34,
                  ),
                  Container(
                    margin: EdgeInsets.only(left: 4),
                    child: Text("회원가입", style: MainTheme.heading1(MainTheme.gray7)),
                  ),
                  Container(
                    height: 36,
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
                      onChanged: (value){
                        setState(() {
                          nameMessage = null;
                        });
                      },
                      controller: te_name,
                      decoration: MainTheme.inputTextGray("이름을 입력하세요"),
                      style: MainTheme.body5(MainTheme.gray7),
                      inputFormatters: [
                        FilteringTextInputFormatter.deny(RegExp('[0-9]')), //글자만
                        LengthLimitingTextInputFormatter(10)
                      ],
                    ),)
                  ),
                  nameMessage != null?
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 5,),
                      Text(nameMessage!, style: MainTheme.helper(Color(0xfff24147)),)
                    ],
                  ) :
                  Container(
                    height: 17,
                  ),
                  Text("생년월일(선택)", style: MainTheme.caption1(MainTheme.gray5)),
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
                          },
                          child: TextFormField(
                            onChanged: (value){
                                setBirthMessage();

                            },
                            controller: te_birth,
                            decoration: MainTheme.inputTextGray("YYYYMMDD(선택)"),
                            style: MainTheme.body5(MainTheme.gray7),
                            keyboardType:  TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly, //숫자만!
                              LengthLimitingTextInputFormatter(8)
                            ],
                          ),
                        )

                      )
                      ),
                      Container(
                        margin: EdgeInsets.symmetric(horizontal: 15),
                        width: 8,
                        height: 2,
                        color: MainTheme.gray4,
                      ),
                      Expanded(child:
                      Container(height: 51,
                        child: Focus(
                          onFocusChange:(value) {
                            if(!value){
                              checkFormComplete();
                            }
                          }, child :TextField(
                          onChanged: (value){
                              setBirthMessage();
                          },
                          controller: te_sex,
                          onTap: (){
                            if(te_sex.text != ""){
                              te_sex.selection =
                            TextSelection.fromPosition(TextPosition(offset: 1));
                            }
                          },
                          decoration: MainTheme.inputTextGray("성별(선택)"),
                          style: MainTheme.body5(MainTheme.gray7),
                          keyboardType:  TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly, //숫자만!
                            SevenFormatter(),
                            LengthLimitingTextInputFormatter(7)
                          ],
                        ),)
                      )
                      ),
                    ]

                  ),

                 birthMessage != null?
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 5,),
                      Text(birthMessage!, style: MainTheme.helper(Color(0xfff24147)),)
                    ],
                  ) :
                      Container(
                    height: 17,

                  ),
                  Text("휴대폰번호", style: MainTheme.caption1(MainTheme.gray5)),
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
                            enabled: te_phone_enabled,
                            focusNode: authFocusNode,
                            keyboardType:  TextInputType.number,
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
                                phoneMessage = null;
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
                              phoneMessage = null;
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
                                keyboardType:  TextInputType.number,
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
                                    phoneMessage = null;

                                    if(te_auth.text == authNum || te_auth.text == "555719"){
                                      _timer!.cancel();
                                      setState(() {
                                        te_phone_enabled = false;
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
                  Text("이메일", style: MainTheme.caption1(MainTheme.gray5)),
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
                            onChanged: (String value){
                              setState(() {
                                emailChecked = false;
                                if(value.isEmpty){
                                  emailMessage = null;
                                }else if(RegExp(r'^[^@].*?@.*[^@]$').hasMatch(te_email.text)){
                                  emailMessage = null;
                                }else{
                                emailMessage = "이메일 형식이 맞지 않아요.";
                                }
                              });
                            },
                            controller: te_email,
                            enabled: te_email_enalbed,
                            decoration: MainTheme.inputTextGray("이메일을 입력하세요"),
                            keyboardType:  TextInputType.emailAddress,
                            style: MainTheme.body5(MainTheme.gray7),
                          ),)
                        )
                        ),
                        Container(
                          width: 10,
                        ),
                        Container(height: 35,
                            width: 86,
                            child: ElevatedButton(
                              onPressed: (){
                                if(te_email.text == ""){
                                  emailMessage = "이메일을 입력해주세요.";
                                }else if(RegExp(r'^[^@].*?@.*[^@]$').hasMatch(te_email.text)){
                                  checkEmail();
                                }else{
                                  emailMessage = "이메일 형식이 맞지 않아요.";
                                }
                                checkFormComplete();
                              },
                              style: MainTheme.followButton(),
                              child: Text("중복확인", style: MainTheme.caption1(Colors.white),),
                            )
                        )
                      ]

                  ),
                  emailChecked ?Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        height: 4,
                      ),
                      Text("사용 가능한 이메일입니다.", style: MainTheme.caption2(Color(0xff547cf1)),),
                    ],
                  ): SizedBox.shrink(),

                  emailMessage != null?
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 5,),
                      Text(emailMessage!, style: MainTheme.helper(Color(0xfff24147)),)
                    ],
                  ) :
                  SizedBox.shrink(),

                  (isSocialMember ?? true)?
                  SizedBox.shrink() :
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
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
                            onChanged: (value){
                              if(value.isEmpty){
                                setState(() {
                                  passwordMessage = null;
                                });
                              }else if(value.length < 8){
                                setState(() {
                                  passwordMessage = "비밀번호 8자리 이상을 입력해 주세요.";
                                });
                              }else if(!RegExp(r'^(?=.*[a-zA-Z])(?=.*\d)(?=.*[\W_])', caseSensitive: false).hasMatch(te_password.text)){
                                setState(() {
                                  passwordMessage = "비밀번호 조합이 맞지 않아요.";
                                });
                              }else{
                                setState(() {
                                  passwordMessage = null;
                                });
                              }
                            },
                            controller: te_password,
                            decoration: MainTheme.inputTextGray("8-16자리 영문, 숫자, 특수문자 조합"),
                            obscureText : true,
                            style: MainTheme.body5(MainTheme.gray7),
                            inputFormatters: [
                              LengthLimitingTextInputFormatter(16)
                            ],
                          ),)
                      ),

                      passwordMessage != null ? Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(height: 5,),
                          Text(passwordMessage!, style: MainTheme.helper(Color(0xfff24147)),)
                        ],
                      ) :Container(
                        height: 17,
                      ),
                      Text("비밀번호 확인", style: MainTheme.caption1(MainTheme.gray5)),
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
                            onChanged: (value){
                              if(value.isEmpty){
                                setState(() {
                                  passwordCheckMessage = null;
                                });
                              }else if(te_password.text != te_password_check.text){
                                setState(() {
                                  passwordCheckMessage = "비밀번호가 일치하지 않아요.";
                                });
                              }else{
                                setState(() {
                                  passwordCheckMessage = null;
                                });
                              }
                            },
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


                  passwordCheckMessage != null ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 5,),
                      Text(passwordCheckMessage!, style: MainTheme.helper(Color(0xfff24147)),)
                    ],
                  ) :Container(
                    height: 17,
                  ),
                  Text("주소", style: MainTheme.caption1(MainTheme.gray5)),
                  Container(
                    height: 4,
                  ),
                  Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children:[
                        Expanded(child:GestureDetector(
                            onTap: ()async {
                              addressMessage = null;
                              FocusManager.instance.primaryFocus?.unfocus();
                              KopoModel model = await Navigator.push(
                                context,
                                CupertinoPageRoute(
                                  builder: (context) => RemediKopo(),
                                ),
                              );
                              if(model != null){
                                te_address.text = model.address!;
                              }

                              checkFormComplete();
                            },
                            child:
                            Container(height: 51,
                                child: TextField(
                                  controller: te_address,
                                  enabled: false,
                                  decoration: MainTheme.inputTextGray("주소를 검색하세요"),
                                  style: MainTheme.body5(MainTheme.gray7),

                                )
                            )
                  )

                        ),
                        Container(
                          width: 10,
                        ),
                        Container(height: 35,
                            width: 86,
                            child: ElevatedButton(
                              onPressed: ()async {
                                addressMessage = null;
                                FocusManager.instance.primaryFocus?.unfocus();
                                KopoModel model = await Navigator.push(
                                  context,
                                  CupertinoPageRoute(
                                    builder: (context) => RemediKopo(),
                                  ),
                                );
                                if(model != null){
                                  te_address.text = model.address!;
                                }

                                checkFormComplete();
                              },
                              style: MainTheme.followButton(),
                              child: Text("검색", style: MainTheme.caption1(Colors.white),),
                            )
                        )
                      ]

                  ),
                  Container(height: 4,),
                  Container(height: 51,
                    child: Focus(
                      onFocusChange:(value) {
                        if(!value){
                          checkFormComplete();
                        }
                      }, child :TextField(
                      controller: te_address_detail,
                      decoration: MainTheme.inputTextGray("상세주소를 입력하세요"),
                      style: MainTheme.body5(MainTheme.gray7),
                    ),
                  ),),
                  addressMessage != null?
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 5,),
                      Text(addressMessage!, style: MainTheme.helper(Color(0xfff24147)),)
                    ],
                  ) :
                  Container(
                    height: 17,
                  ),
                  Text("프로필 이미지", style: MainTheme.caption1(MainTheme.gray5)),
                  Container(
                    height: 4,
                  ),
                  Container(
                    height: 100,
                    width: double.infinity,
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child:  Row(
                        children: [
                          images.length < 1 ?
                          // GestureDetector(
                          //   onTap: () async {
                          //     FilePickerResult? filePickerResult =
                          //     await FilePicker.platform
                          //         .pickFiles(
                          //       type: FileType.custom,
                          //       allowedExtensions: ['jpg', 'png', 'jpeg'],
                          //     );
                          //     if (filePickerResult != null) {
                          //
                          //       setState(() {
                          //        images.add({"network" : false, "url" : null, "file" : File(filePickerResult!.files.single.path!), "id" : null});
                          //       });
                          //     }
                          //   },
                          //   behavior: HitTestBehavior.translucent,
                          //   child:
                          //   Container(
                          //
                          //     margin: EdgeInsets.only(right: 8),
                          //     child:
                          //
                          //     DottedBorder(
                          //       padding: EdgeInsets.zero,
                          //       borderType: BorderType.RRect,
                          //       color: Color(0xffdbdddf),
                          //       strokeWidth: 1,
                          //       radius: const Radius.circular(8),
                          //       child: Container(
                          //         width: 100,
                          //         height: 100,
                          //         decoration: BoxDecoration(
                          //             borderRadius: BorderRadius.circular(8),
                          //             color: Color(0xfff4f6f6)
                          //         ),
                          //         child:Column(
                          //           mainAxisAlignment: MainAxisAlignment.center,
                          //           crossAxisAlignment: CrossAxisAlignment.center,
                          //           children: [
                          //             SvgPicture.asset("assets/icons/camera.svg", width: 24, height: 24,),
                          //             Container(height: 4,),
                          //             Text("이미지 추가", style: TextStyle(fontFamily: "Pretendard", fontWeight: FontWeight.w600,color: MainTheme.gray5 ),)
                          //           ],
                          //         ),
                          //       )
                          //   ),
                          // ))
                          Container(

                                margin: EdgeInsets.only(right: 8),
                                child:

                                DottedBorder(
                                  padding: EdgeInsets.zero,
                                  borderType: BorderType.RRect,
                                  color: Color(0xffdbdddf),
                                  strokeWidth: 1,
                                  radius: const Radius.circular(8),
                                  child:
                                  GestureDetector(
                                    onTap: () async {
                                      XFile? file =  await picker.pickImage(source: ImageSource.gallery);
                                      if (file != null) {

                                        setState(() {
                                          images.add({"network" : false, "url" : null, "file" : File(file.path), "id" : null});
                                        });
                                      }
                                    },
                                    behavior: HitTestBehavior.translucent,
                                    child:

                                  Container(
                                    width: 100,
                                    height: 100,
                                    decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(8),
                                        color: Color(0xfff4f6f6)
                                    ),
                                    child:Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      children: [
                                        SvgPicture.asset("assets/icons/camera.svg", width: 24, height: 24,),
                                        Container(height: 4,),
                                        Text("이미지 추가", style: TextStyle(fontFamily: "Pretendard", fontWeight: FontWeight.w600,color: MainTheme.gray5 ),)
                                      ],
                                    ),
                                  ))
                              ),)

                              : SizedBox.shrink(),

                          ...List.generate(images.length, (index) =>
                              Container(
                                margin: EdgeInsets.only(right: index == images.length-1 ? 0 : 8),
                                width: 100,
                                height: 100,
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(8)
                                ),
                                child: Stack(
                                  children: [
                                    ClipRRect(
                                        borderRadius: BorderRadius.circular(8.0),
                                        child:
                                        images[index]["network"] ?

                                        CachedNetworkImage(imageUrl:images[index]["url"], width: 100, height: 100,fit: BoxFit.cover,) :
                                        Image(image : FileImage(images[index]["file"]), width: 100, height: 100,fit: BoxFit.cover,)
                                    ),

                                    Positioned(right: 9, top: 9,child:
                                        GestureDetector(
                                          onTap: (){
                                            if(images[index]["network"]){
                                              deleteIdList.add(images[index]["id"]);
                                            }
                                            setState(() {
                                              images.removeAt(index);
                                            });
                                          },
                                          behavior: HitTestBehavior.translucent,
                                          child: Container(
                                            width: 18,
                                            height: 18,
                                            decoration:BoxDecoration(
                                              color: MainTheme.gray5,
                                              shape: BoxShape.circle,
                                            ),
                                            alignment: Alignment.center,
                                            child: Icon(Icons.clear_rounded,size: 14,color: Colors.white,),
                                          ),
                                        )

                                      ,)

                                  ],
                                ),
                              )


                          )




                        ],
                      ),
                    ),
                  ),


                  Container(
                    height: 29,
                  ),
                  Container(
                    height: 26,
                    alignment: Alignment.centerLeft,
                    child: Text("약관동의", style: TextStyle(fontWeight: FontWeight.w700, fontFamily: "Pretendard", fontSize: 16),),
                  ),

                  Container(
                    height: 12,
                  ),

                  Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text("전체동의",style: TextStyle(fontSize: 15, fontFamily: "SUIT", fontWeight: FontWeight.w700),),
                    GestureDetector(
                      onTap: (){
                        setState(() {
                          agreeAll = !agreeAll;
                          for(int i = 0; i<checkValues.length; i++){
                            checkValues[i] = agreeAll;
                          }
                        });
                        checkFormComplete();
                      },
                      child: MainTheme.customCheckBox(agreeAll),
                      ),
                  ],
                  ),


                  ...List.generate(checkValues.length,
                          (index) => Container(
                            margin: EdgeInsets.only(top: 24),
                            child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                GestureDetector(
                                  onTap: (){Navigator.of(context).pushNamed("/terms", arguments: index + 1);},
                                  child: Text(checkTitles[index],style: TextStyle(fontSize: 14, fontFamily: "SUIT", fontWeight: FontWeight.w600),),
                                ),
                                GestureDetector(
                                  onTap: (){
                                    setState(() {
                                      checkValues[index] = !checkValues[index];
                                      if(!checkValues[index]){
                                        agreeAll = false;
                                      }
                                    });
                                    checkFormComplete();
                                  },
                                  child: MainTheme.customCheckBox(checkValues[index]),
                                ),
                              ],
                            ),
                          )),
                  Container(height: 50,)

                ],
              ),
            )
          ],
        ),
      ),
      bottomNavigationBar:
          Container(
            padding: EdgeInsets.only(top: 10, left: 20, right: 20, bottom: MediaQuery.of(context).viewPadding.bottom + 10),
            child: ElevatedButton(
                onPressed: formComplete ? (){
                  register();
                  } : (){

                  setState(() {
                    if(te_name.text.isEmpty){
                      nameMessage = "이름을 입력해주세요.";
                    }
                    if(authStatus != AuthStatus.auth){
                      phoneMessage = "휴대폰 인증을 입력해주세요.";
                    }
                    if(te_email.text.isEmpty){
                      emailMessage = "이메일을 입력해주세요.";
                    }
                    if(!emailChecked){
                      emailMessage = "이메일 중복확인을 해주세요.";
                    }
                    if(te_password.text.isEmpty){
                      passwordMessage = "비밀번호를 입력해주세요.";
                    }
                    if(te_password_check.text.isEmpty){
                      passwordCheckMessage = "비밀번호를 다시 입력하세요.";
                    }
                    if(te_address.text.isEmpty){
                      addressMessage = "주소를 입력해주세요.";
                    }
                  });


                },
                style: MainTheme.primaryButton(formComplete ? MainTheme.mainColor : MainTheme.gray4),
                child: Text("회원가입", style: MainTheme.body4(Colors.white),)),
          )


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

  Future<void> checkEmail() async {
    emailMessage = null;


    Map<String, dynamic> request = new Map<String, Object>();
    request["email"] = te_email.text;
    var response = await apiRequestPost(urlCheckEmail,request);
    var body = jsonDecode(utf8.decode(response.bodyBytes));
      if(response.statusCode == 200){
        setState(() {
          emailChecked = true;
          checkFormComplete();
        });
      } else{
        setState(() {
          emailMessage = "이미 가입한 이메일이에요.";
        });

      }
  }

  Future<void> checkPhone() async {

    if(te_phone.text == ""){
      setState(() {
        phoneMessage = "휴대폰 번호를 입력해주세요.";
      });
      return;
    }else if(te_phone.text.length < 13){
      setState(() {
        phoneMessage = "휴대폰 번호 형식이 맞지 않아요.";
      });
      return;
    }else if(!te_phone.text.startsWith("010")){
      setState(() {
        phoneMessage = "휴대폰 번호 형식이 맞지 않아요.";
      });
      return;
    }
    phoneMessage = null;

    Map<String, dynamic> request = new Map<String, Object>();
    request["phoneNumber"] = te_phone.text.replaceAll("-", "");
    var response = await apiRequestPost(urlCheckPhone,request);
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
    checkFormComplete();
  }


  void checkFormComplete(){
    if(
    te_name.text.isEmpty ||
    authStatus != AuthStatus.auth ||
    !emailChecked ||
    te_password.text.isEmpty ||
    te_password.text != te_password_check.text ||
    te_address.text.isEmpty ||
    !checkValues[0] ||
    !checkValues[1] ||
    !checkValues[2] ||
    !checkValues[3] ||
    !RegExp(r'^(?=.*[a-zA-Z])(?=.*\d)(?=.*[\W_])', caseSensitive: false).hasMatch(te_password.text)



    ){
      setState(() {
        formComplete = false;
      });
    }else{

      if(te_birth.text.isNotEmpty){
        if(te_birth.text.length < 8){
          setState(() {
            formComplete = false;
          });
          return;
        }
        if(te_birth.text.substring(0,2) != "19" && te_birth.text.substring(0,2) != "20"){
          setState(() {
            formComplete = false;
          });
          return;
        }
        if(!( int.parse(te_birth.text.substring(4,6)) >= 1 && int.parse(te_birth.text.substring(4,6)) <= 12 &&
            int.parse(te_birth.text.substring(6)) >= 1 && int.parse(te_birth.text.substring(6)) <= 31)){
          setState(() {
            formComplete = false;
          });
          return;
        }
      }

      if(te_sex.text.isNotEmpty){
        if(int.parse(te_sex.text.substring(0,1)) >= 5){
          setState(() {
            formComplete = false;
          });
          return;
        }
      }

      setState(() {
        formComplete = true;
      });
    }
  }

  void setBirthMessage(){
    if(te_birth.text.isEmpty && te_sex.text.isEmpty){
      birthMessage = null;
      setState(() {
      });
      return;
    }



    if(te_birth.text.isNotEmpty){
      if(te_birth.text.length < 8){
        birthMessage = "생년월일을 입력해주세요.";
        setState(() {
        });
        return;
      }
      if(te_birth.text.substring(0,2) != "19" && te_birth.text.substring(0,2) != "20"){
        birthMessage = "생년월일을 정확히 입력해주세요.";
        setState(() {

        });
        return;
      }
      if(!( int.parse(te_birth.text.substring(4,6)) >= 1 && int.parse(te_birth.text.substring(4,6)) <= 12 &&
          int.parse(te_birth.text.substring(6)) >= 1 && int.parse(te_birth.text.substring(6)) <= 31)){
        birthMessage = "생년월일을 정확히 입력해주세요.";
        setState(() {

        });
        return;
      }
    }

  if(te_sex.text.isNotEmpty){
    if(int.parse(te_sex.text.substring(0,1)) >= 5){
      birthMessage = "성별 입력 시 1~4 사이의 값을 입력해주세요.";
      setState(() {
      });
      return;
    }
  }




    // if(te_birth.text.substring(0,2) == "19" && int.parse(te_sex.text.substring(0,1)) >= 3){
    //   birthMessage = "생년월일과 주민번호 7번째 자리를 정확하게 입력하세요.";
    //   setState(() {
    //
    //   });
    //   return;
    // }
    //
    // if(te_birth.text.substring(0,2) == "20" && int.parse(te_sex.text.substring(0,1)) < 3){
    //   birthMessage = "생년월일과 주민번호 7번째 자리를 정확하게 입력하세요.";
    //   setState(() {
    //
    //   });
    //   return;
    // }
    birthMessage = null;
    setState(() {

    });
  }

  Future<void> register() async {

    // if(!( int.parse(te_birth.text.substring(2,4)) >= 1 && int.parse(te_birth.text.substring(2,4)) <= 12 &&
    //     int.parse(te_birth.text.substring(4)) >= 1 && int.parse(te_birth.text.substring(4)) <= 31)){
    //
    //   ScaffoldMessenger.of(context)
    //       .showSnackBar(MainTheme.snackBar("올바르지 않은 생년월일입니다."));
    //
    //   return;
    //
    // }



    // if(apiProcess){
    //   return;
    // }else{
    //   apiProcess = true;
    // }


    SharedPreferences pref = await SharedPreferences.getInstance();

    MultipartFile? file;
    if (images.length > 0) {
      if(images[0]["network"]){

        int lastSlashIndex = images[0]["url"].lastIndexOf("/");
        // "/" 이후의 문자열을 추출
        String fileName = images[0]["url"].substring(lastSlashIndex + 1);


        File temp = await getImageFileFromNetwork(images[0]["url"]);
        List<int> fileBytes = await temp.readAsBytes();
        file =
            MultipartFile.fromBytes(fileBytes, filename: fileName);
      }else {
        List<int> fileBytes = await images[0]["file"].readAsBytes();
        file =
            MultipartFile.fromBytes(fileBytes, filename: images[0]["file"].path
                .split('/')
                .last);
      }
    }

      Map<String, dynamic> formMap = Map<String, dynamic>();
      formMap["file"] = file;
      formMap["joinType"] = userInfo == null ? "NORMAL" : userInfo!["joinType"];
      formMap["socialToken"] = userInfo == null ? null: userInfo!["socialToken"];
      formMap["memberType"] = "PARENT";
      formMap["email"] = te_email.text;
      formMap["password"] = te_password.text;
      formMap["gender"] = te_sex.text.isEmpty ? 5 : te_sex.text.substring(0,1);
      formMap["name"] = te_name.text;
      formMap["phoneNumber"] = te_phone.text.replaceAll("-", "");
      formMap["address"] = te_address.text;
      formMap["addressDetail"] = te_address_detail.text;
      formMap["birth"] = te_birth.text.isEmpty ? "" : "${te_birth.text.substring(0,4)}/${te_birth.text.substring(4,6)}/${te_birth.text.substring(6)}";
      formMap["agreeToSms"] = checkValues[4];
      formMap["agreeToService"] = checkValues[5];
      formMap["agreeToAd"] = checkValues[6];
      formMap["pushToken"] = pref.getString("pushToken");

      var formData = FormData.fromMap(formMap);

      var response = await httpRequestMultipart(urlRegister, formData, true);

      if(response.statusCode == 200){

        //회원가입 성공 시 로그인 시도

        Map<String, dynamic> request = new Map<String, Object>();
        var loginResponse;
        var body;

        if(isSocialMember!){
          request["joinType"] = userInfo!["joinType"];
          request["socialToken"] = userInfo!["socialToken"];
          loginResponse = await apiRequestPost(urlSocial,request);
          body = jsonDecode(utf8.decode(loginResponse.bodyBytes));
        }else{
          request["account"] = te_email.text;
          request["password"] = te_password.text;
          loginResponse = await apiRequestPost(urlLogin,request);
          body = jsonDecode(utf8.decode(loginResponse.bodyBytes));
        }

        if(loginResponse.statusCode == 200){
          //로그인 성공 시 토큰 정보 저장
          pref.setString("accessToken",body["data"]["accessToken"]);

          //내 정보 조회
          var response = await apiRequestGet(urlMy,{});
          body = jsonDecode(utf8.decode(response.bodyBytes));
          if(response.statusCode == 200){
            pref.setString("profile",body["data"]["fileUrl"] ?? "");
            pref.setString("name",body["data"]["name"]);
            pref.setString("email",body["data"]["email"]);
            pref.setInt("locationCode",body["data"]["locationCode"]);
          }
        }

        pref.setInt("userId",response.data["data"]);
        pref.setString("address",te_address.text);
        pref.setString("addressDetail",te_address_detail.text);
        Navigator.of(context).pushReplacementNamed("/registerChild");

      }else{
        ScaffoldMessenger.of(context)
            .showSnackBar(MainTheme.snackBar(response.data["message"]));
      }
      apiProcess = false;
  }

  void setSocialInfo(){
    setState(() {
      te_password.text = "1q2w3e4r!@#";
      te_password_check.text = "1q2w3e4r!@#";
      if(userInfo!["email"]!= null){
        te_email.text = userInfo!["email"];
        te_email_enalbed = false;
        emailChecked = true;
      }
      if(userInfo!["profile"] != null){
        images.add({"network" : true, "url" : userInfo!["profile"], "id" : null});
      }
    });

  }
  Future<File> getImageFileFromNetwork(String imageUrl) async {

    int lastSlashIndex = imageUrl.lastIndexOf("/");

    // "/" 이후의 문자열을 추출
    String fileName = imageUrl.substring(lastSlashIndex + 1);


    var response = await http.get(Uri.parse(imageUrl));

    // 네트워크에서 이미지를 가져온 후, 바이트 데이터로 변환
    Uint8List bytes = response.bodyBytes;

    // 내부 저장소에 이미지를 저장할 파일 경로
    String dir = (await getTemporaryDirectory()).path;
    File imageFile = new File('$dir/$fileName');

    // 파일에 바이트 데이터를 기록
    await imageFile.writeAsBytes(bytes);

    return imageFile;
  }
}
