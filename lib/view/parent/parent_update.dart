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
import 'package:remedi_kopo/remedi_kopo.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/src/response.dart' as http;

import '../../util/number_formatter.dart';
import '../../util/seven_formatter.dart';


String urlMy = "${dotenv.env['BASE_URL']}user/commonMember";
String urlUpdate = "${dotenv.env['BASE_URL']}user/commonMember";
String urlCheckEmail = "${dotenv.env['BASE_URL']}common/check/email";
String urlCheckPhone = "${dotenv.env['BASE_URL']}common/check/phoneNumber";

enum AuthStatus {notAuth, auth, dup, send, missMatch}

class ParentUpdate extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _ParentUpdate();
}

class _ParentUpdate extends State<ParentUpdate> {
  bool? isSocialMember;
  //이미지 삭제 여부
  bool deleteFile = false;

  Future<http.Response>? getFuture;
  Map? myInfo;

  bool changePhoneNumber = false;

  //타이머 클래스
  Timer? _timer = null;
  //남은 시간
  int _seconds = 180;
  //이메일 중복 확인 여부
  bool emailChecked = false;

  bool formComplete = true;

  //sms인증 번호
  String? authNum;

  //sms인증 상태
  AuthStatus authStatus = AuthStatus.notAuth;

  //이미지 목록
  List images = [];

  bool changePassword = false;

  TextEditingController te_name = TextEditingController();
  TextEditingController te_birth = TextEditingController();
  TextEditingController te_sex = TextEditingController();
  TextEditingController te_phone = TextEditingController();
  TextEditingController te_auth = TextEditingController();
  TextEditingController te_email = TextEditingController();
  TextEditingController te_password = TextEditingController();
  TextEditingController te_password_check = TextEditingController();
  TextEditingController te_address = TextEditingController();
  TextEditingController te_address_detail = TextEditingController();

  FocusNode authFocusNode = FocusNode();

  bool apiProcess = false;

  ImagePicker picker = ImagePicker();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
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
            title: Text("계정관리", style:MainTheme.body5(MainTheme.gray7)),
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
                  child: Column(

                    children: [

                      Container(margin: EdgeInsets.symmetric(horizontal: 16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              height: 17,
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
                            Text("생년월일", style: MainTheme.caption1(MainTheme.gray5)),
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
                                          enabled: false,
                                          controller: te_birth,
                                          decoration: MainTheme.inputTextGray("YYMMDD"),
                                          style: MainTheme.body5(MainTheme.gray4),
                                          keyboardType:  TextInputType.number,
                                          inputFormatters: [
                                            FilteringTextInputFormatter.digitsOnly, //숫자만!
                                            LengthLimitingTextInputFormatter(6)
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
                                        enabled: false,
                                        controller: te_sex,
                                        onTap: (){
                                          if(te_sex.text != ""){
                                            te_sex.selection =
                                                TextSelection.fromPosition(TextPosition(offset: 1));
                                          }
                                        },
                                        decoration: MainTheme.inputTextGray(""),
                                        style: MainTheme.body5(MainTheme.gray4),
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
                            Container(
                              height: 17,
                            ),
                            Text("이메일", style: MainTheme.caption1(MainTheme.gray5)),
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
                                  enabled: false,
                                  onChanged: (String value){
                                    setState(() {
                                      emailChecked = false;
                                    });
                                  },
                                  controller: te_email,
                                  decoration: MainTheme.inputTextGray("이메일을 입력하세요"),
                                  keyboardType:  TextInputType.emailAddress,
                                  style: MainTheme.body5(MainTheme.gray4),
                                ),)
                            ),
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

                                        },
                                        decoration: MainTheme.inputTextGray("번호만 입력가능합니다"),
                                        style: MainTheme.body5(MainTheme.gray7),
                                        controller: te_phone,
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
                                        child: Text("변경하기", style: MainTheme.caption1(Colors.white),),
                                      )
                                  )
                                ]
                            ),
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

                                              if(te_auth.text == authNum || te_auth.text == authNum){
                                                _timer!.cancel();
                                                setState(() {
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
                                    Text("인증번호가 일치하지 않습니다.", style: MainTheme.caption2(Color(0xfff24147)),),
                                  ],
                                ): SizedBox.shrink(),

                                Container(
                                  height: 17,
                                ),
                              ],
                            ) :


                            emailChecked ?Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(
                                  height: 4,
                                ),
                                Text("사용 가능한 이메일입니다.", style: MainTheme.caption2(Color(0xff547cf1)),),
                              ],
                            ): SizedBox.shrink(),


                            (isSocialMember??true)?
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
                                    changePassword ?
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Container(height: 51,
                                            child: Focus(
                                              onFocusChange:(value) {
                                                if(!value){
                                                  checkFormComplete();
                                                }
                                              }, child :TextField(
                                              controller: te_password,
                                              decoration: MainTheme.inputTextGray("8-16자리 영문, 숫자, 특수문자 조합"),
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
                                        Text("비밀번호 확인", style: MainTheme.caption1(MainTheme.gray5)),
                                        const SizedBox(
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
                                        const SizedBox(
                                          height: 4,
                                        ),
                                      ],
                                    ) : SizedBox.shrink(),
                                    Container(
                                      height: 45,
                                      child: ElevatedButton(
                                        onPressed: (){
                                          te_password.text = "";
                                          te_password_check.text = "";
                                          changePassword = !changePassword;
                                          checkFormComplete();
                                        },
                                        style: MainTheme.hollowButton(MainTheme.gray4),
                                        child: Text(changePassword ? "변경 취소" : "비밀번호 변경", style: MainTheme.body4(MainTheme.gray4),),
                                      ),
                                    ),
                                  ],
                                ),








                            Container(
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
                                  Expanded(child:
                                  GestureDetector(
                                      onTap: ()async {
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
                                                    deleteFile = true;
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


                            Container(height: 20,)

                          ],
                        ),
                      )
                    ],
                  ),
                );
              }else{
                return MainTheme.ErrorPage(context, jsonDecode(utf8.decode(snapshot.data.bodyBytes))["message"]);
              }
            }
        ),



        bottomNavigationBar:
        Container(
          padding: EdgeInsets.only(top: 10, left: 20, right: 20, bottom: MediaQuery.of(context).viewPadding.bottom + 10),
          child: ElevatedButton(
              onPressed: formComplete ? (){
                register();
              } : null,
              style: MainTheme.primaryButton(MainTheme.mainColor),
              child: Text("저장하기", style: MainTheme.body4(Colors.white),)),
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
    if(myInfo!["phoneNumber"] == te_phone.text.replaceAll("-", "")){
      if(_timer != null){
        if(_timer!.isActive){
          _timer!.cancel();
        }
      }
      setState(() {
        authStatus = AuthStatus.notAuth;
        te_auth.text = "";
        changePhoneNumber = false;
      });
      return;
    }


    changePhoneNumber = true;
    if(te_phone.text == ""){
      ScaffoldMessenger.of(context)
          .showSnackBar(MainTheme.snackBar("전화번호를 입력해 주세요."));
      return;
    }else if(te_phone.text.length < 13){
      ScaffoldMessenger.of(context)
          .showSnackBar(MainTheme.snackBar("올바르지 않은 전화번호입니다."));
      return;
    }
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
        te_birth.text.length < 6 ||
        (authStatus != AuthStatus.auth && changePhoneNumber)||
        (te_password.text.isEmpty && changePassword)  ||
        (te_password.text != te_password_check.text && changePassword)||
        te_address.text.isEmpty
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


  Future<void> register() async {

    if(changePassword){
      if(!( te_password.text.length >= 8 &&
          RegExp(r'^(?=.*[a-zA-Z])(?=.*\d)(?=.*[\W_])', caseSensitive: false).hasMatch(te_password.text))){

        ScaffoldMessenger.of(context)
            .showSnackBar(MainTheme.snackBar("비밀번호는 8-16자리 영문, 숫자, 특수문자를 포함해야 합니다."));

        return;
      }
    }

    if(apiProcess){
      return;
    }else{
      apiProcess = true;
    }

    SharedPreferences pref = await SharedPreferences.getInstance();

    MultipartFile? file;
    if (images.length > 0) {
      if(!images[0]["network"]){
        List<int> fileBytes = await images[0]["file"].readAsBytes();
        file = MultipartFile.fromBytes(fileBytes, filename: images[0]["file"].path
            .split('/')
            .last);
      }
    }

    Map<String, dynamic> formMap = Map<String, dynamic>();
    formMap["gender"] = myInfo!["gender"];
    formMap["name"] = te_name.text;
    formMap["changeEmail"] = false;
    formMap["email"] = te_email.text;
    formMap["address"] = te_address.text;
    formMap["addressDetail"] = te_address_detail.text;
    formMap["birth"] = "${te_birth.text.substring(0,2)}/${te_birth.text.substring(2,4)}/${te_birth.text.substring(4)}";
    formMap["deleteFileFlag"] = deleteFile;
    formMap["changePassword"] = changePassword;
    formMap["password"] = te_password.text.isEmpty ? "1q2w3e4r!" : te_password.text;
    formMap["phoneNumber"] = te_phone.text.replaceAll("-", "");

    print(jsonEncode(formMap));

    formMap["file"] = file;
    var formData = FormData.fromMap(formMap);

    var response = await httpRequestMultipart(urlUpdate, formData, false);

    if(response.statusCode == 200){
      //수정 성공했다면
      //프로필 이미지 다시 받음
      var response = await apiRequestGet(urlMy,  {});
      var body =jsonDecode(utf8.decode(response.bodyBytes));
      if(response.statusCode == 200){
        pref.setString("name", body["data"]["name"]);
        pref.setString("profile", body["data"]["fileUrl"] ?? "");
        pref.setInt("locationCode", body["data"]["locationCode"]);
      }

      //자동로그인 비밀번호 변경
      if(changePassword){
        pref.setString("password", te_password.text);
      }

      Navigator.of(context).pop();


    }else{
      ScaffoldMessenger.of(context)
          .showSnackBar(MainTheme.snackBar(response.data["message"]));
    }
    apiProcess = false;
  }

  Future<http.Response> getFirst() async {
    var response = await apiRequestGet(urlMy,  {});
    var body =jsonDecode(utf8.decode(response.bodyBytes));

    myInfo = body["data"];

    te_name.text = myInfo!["name"];
    te_birth.text = myInfo!["birth"].replaceAll("/", "");
    te_sex.text = myInfo!["gender"] == 5 ? "" : "${myInfo!["gender"]}●●●●●●";
    te_email.text = myInfo!["email"];
    te_address.text = myInfo!["address"];
    te_address_detail.text = myInfo!["addressDetail"] ?? "";
    te_phone.text= myInfo!["phoneNumber"].substring(0,3) + "-" + myInfo!["phoneNumber"].substring(3,7) + "-" +myInfo!["phoneNumber"].substring(7);
    if(myInfo!["fileUrl"] != null){
      if(myInfo!["fileUrl"] != "") {
        images.add({
          "network": true,
          "url": myInfo!["fileUrl"],
          "file": null,
          "id": null
        });
      }
    }

    if(myInfo!["joinType"] == "NORMAL"){
      isSocialMember = false;
    }else{
      isSocialMember = true;
    }
    return response;
  }
}
