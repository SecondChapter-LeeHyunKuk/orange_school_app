import 'dart:convert';
import 'dart:ffi';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_svg/svg.dart';
import 'package:image_picker/image_picker.dart';
import 'package:orange_school/style/main-theme.dart';
import 'package:flutter/foundation.dart' as foundation;
import 'package:shared_preferences/shared_preferences.dart';

import '../../util/api.dart';
import '../../util/seven_formatter.dart';


String urlCheckEmail = "${dotenv.env['BASE_URL']}common/check/email";

class RegisterChild extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _RegisterChild();
}

class _RegisterChild extends State<RegisterChild> {
  ImagePicker picker = ImagePicker();
  int? id;
  bool emailChecked = false;
  bool apiProcess = false;
  bool formComplete = false;

  //이미지 목록
  List images = [];

  //삭제 이미지 목록
  List deleteIdList = [];

  TextEditingController te_name = TextEditingController();
  TextEditingController te_birth = TextEditingController();
  TextEditingController te_sex = TextEditingController();
  TextEditingController te_email = TextEditingController();
  TextEditingController te_password = TextEditingController();
  TextEditingController te_password_check = TextEditingController();
  TextEditingController te_address = TextEditingController();
  TextEditingController te_address_detail = TextEditingController();
  TextEditingController te_nickname = TextEditingController();
  TextEditingController te_intro = TextEditingController();

  String? nameMessage;
  String? birthMessage;
  String? phoneMessage;
  String? emailMessage;
  String? passwordMessage;
  String? passwordCheckMessage;
  String? addressMessage;
  String? nickNameMessage;
  String? introMessage;

  @override
  void initState(){
    // TODO: implement initState
    super.initState();
    setParentInfo();
  }

  @override
  Widget build(BuildContext context) {
    //final parentInfo = ModalRoute.of(context)?.settings.arguments as Map?;
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
                    height: 34,
                  ),
                  Container(
                    margin: EdgeInsets.only(left: 4, bottom: 5),
                    child: Text("아이등록하기", style: MainTheme.heading1(MainTheme.gray7)),
                  ),
                  Container(
                    margin: EdgeInsets.only(left: 4),
                    child: Text("가입이 완료되었어요!", style: MainTheme.body8(MainTheme.gray6)),
                  ),
                  Container(
                    height: 11,
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
                                decoration: MainTheme.inputTextGray("YYYYMMDD"),
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
                              decoration: MainTheme.inputTextGray("N●●●●●●"),
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
                  Container(height: 51,
                    child: TextField(
                      readOnly: true,
                      controller: te_address,
                      decoration: MainTheme.inputTextGray(""),
                      style: MainTheme.body5(MainTheme.gray7),
                    ),
                  ),
                  Container(height: 4,),
                  Container(height: 51,
                    child: TextField(
                      readOnly: true,
                      controller: te_address_detail,
                      decoration: MainTheme.inputTextGray("상세주소를 입력하세요"),
                      style: MainTheme.body5(MainTheme.gray7),
                    ),
                  ),
                  Container(
                    height: 17,
                  ),
                  Text("프로필 이미지 등록", style: MainTheme.caption1(MainTheme.gray5)),
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
                    height: 17,
                  ),
                  Text("아이 닉네임", style: MainTheme.caption1(MainTheme.gray5)),
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
                        controller: te_nickname,
                        decoration: MainTheme.inputTextGray("닉네임을 입력하세요 (제한 10자)"),
                        style: MainTheme.body5(MainTheme.gray7),
                        inputFormatters: [
                          LengthLimitingTextInputFormatter(10)
                        ],
                      ),)
                  ),
                  nickNameMessage != null ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 5,),
                      Text(nickNameMessage!, style: MainTheme.helper(Color(0xfff24147)),)
                    ],
                  ) :Container(
                    height: 17,
                  ),
                  Text("소개글", style: MainTheme.caption1(MainTheme.gray5)),
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
                        controller: te_intro,
                        decoration: MainTheme.inputTextGray("소개글을 입력하세요 (제한 50자)"),
                        style: MainTheme.body5(MainTheme.gray7),
                        inputFormatters: [
                          LengthLimitingTextInputFormatter(50)
                        ],
                      ),)
                  ),
                  introMessage != null ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 5,),
                      Text(introMessage!, style: MainTheme.helper(Color(0xfff24147)),),
                      SizedBox(height: 30,),
                    ],
                  ) :Container(
                    height: 50,
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
                      child: ElevatedButton(onPressed: (){

                        Navigator.of(context).pushReplacementNamed('/registerComplete');
                      },
                          style: MainTheme.primaryButton(MainTheme.gray4),
                          child: Text("아이 등록 나중에하기", style: MainTheme.body4(Colors.white),))
                  )
                  ),
                  Container(
                    width: 15,
                  ),
                  Expanded(child:
                  Container(height: 49,
                      child: ElevatedButton(
                          onPressed: formComplete ? (){
                            register();
                          } : (){

                            setState(() {
                              if(te_name.text.isEmpty){
                                nameMessage = "이름을 입력해주세요.";
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
                              if(te_nickname.text.isEmpty){
                                nickNameMessage = "닉네임을 입력해주세요";
                              }
                              if(te_intro.text.isEmpty){
                                introMessage = "소개글을 입력해주세요.";
                              }
                            });


                          },
                          style: MainTheme.primaryButton(formComplete ? MainTheme.mainColor : MainTheme.gray4),
                          child: Text("아이 계정 생성하기", style: MainTheme.body4(Colors.white),))
                  )
                  ),
                ]

            ),
          )

      ),
    );
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
        !emailChecked ||
        te_password.text.isEmpty ||
        te_password.text != te_password_check.text ||
        te_nickname.text.isEmpty ||
        te_intro.text.isEmpty ||

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

  Future<void> setParentInfo() async{
    SharedPreferences pref = await SharedPreferences.getInstance();
    id = pref.getInt("userId");
    te_address.text = pref.getString("address")!;
    te_address_detail.text = pref.getString("addressDetail")!;
  }

  Future<void> register() async {

    MultipartFile? file;
    if (images.length > 0) {
      List<int> fileBytes = await images[0]["file"].readAsBytes();
      file = MultipartFile.fromBytes(fileBytes, filename: images[0]["file"].path
          .split('/')
          .last);
    }

    Map<String, dynamic> formMap = Map<String, dynamic>();
    formMap["file"] = file;
    formMap["joinType"] = "NORMAL";
    formMap["socialToken"] = null;
    formMap["memberType"] = "CHILD";
    formMap["email"] = te_email.text;
    formMap["password"] = te_password.text;
    formMap["gender"] = te_sex.text.isEmpty? 5 : te_sex.text.substring(0,1);
    formMap["name"] = te_name.text;
    formMap["address"] = te_address.text;
    formMap["addressDetail"] = te_address_detail.text;
    formMap["birth"] = te_birth.text.isEmpty ? "1800.01.01" : "${te_birth.text.substring(2,4)}/${te_birth.text.substring(4,6)}/${te_birth.text.substring(6)}";
    formMap["pushToken"] = null;
    formMap["nickName"] = te_nickname.text;
    formMap["intro"] = te_intro.text;
    formMap["parentId"] = id;
    formMap["mode"] = "NEW";

    //var formData = FormData.fromMap(formMap);

    Navigator.of(context).pushNamed("/registerSchool", arguments: formMap);
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
}
