import 'dart:convert';
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


String urlUpdate = "${dotenv.env['BASE_URL']}user/commonMember";
String urlMy = "${dotenv.env['BASE_URL']}user/commonMember";

class ChildUpdate extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _ChildUpdate();
}

class _ChildUpdate extends State<ChildUpdate> {

  ImagePicker picker = ImagePicker();

  //이미지 삭제 여부
  bool deleteFile = false;


  bool changePassword = false;

  bool emailChecked = false;

  bool formComplete = true;

  bool apiProcess = false;

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

  Map? childInfo;

  @override
  void initState(){
    // TODO: implement initState
    super.initState();
    getChildInfo();
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
          title: Text("자녀 계정 관리", style:MainTheme.body5(MainTheme.gray7)),
        ),),
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
                                decoration: MainTheme.inputTextGray(""),
                                style: MainTheme.body5(MainTheme.gray4),
                                keyboardType:  TextInputType.numberWithOptions(signed: true, decimal: true),
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
                              keyboardType:  TextInputType.numberWithOptions(signed: true, decimal: true),
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
                  emailChecked ?Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        height: 4,
                      ),
                      Text("사용 가능한 이메일입니다.", style: MainTheme.caption2(Color(0xff547cf1)),),
                    ],
                  ): SizedBox.shrink(),
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
                            decoration: MainTheme.inputTextGray("새 비밀번호를 입력하세요"),
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

                  Container(
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
                      style: MainTheme.body5(MainTheme.gray4),
                    ),
                  ),
                  Container(height: 4,),
                  Container(height: 51,
                    child: TextField(
                      readOnly: true,
                      controller: te_address_detail,
                      decoration: MainTheme.inputTextGray("상세주소를 입력하세요"),
                      style: MainTheme.body5(MainTheme.gray4),
                    ),
                  ),
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
                  Container(
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
                  Container(height: 20,)

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
            child:  Container(height: 49,
                child: ElevatedButton(
                    onPressed: formComplete ? (){
                      update();
                    } : null,
                    style: MainTheme.primaryButton(MainTheme.mainColor),
                    child: Text("저장하기", style: MainTheme.body4(Colors.white),))
            )
          )

      ),
    );
  }






  void checkFormComplete(){
    if(

    te_name.text.isEmpty ||
        (te_password.text.isEmpty && changePassword)  ||
        (te_password.text != te_password_check.text && changePassword)||
        te_nickname.text.isEmpty ||
        te_intro.text.isEmpty
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

  Future<void> update() async {

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

    SharedPreferences pref = await SharedPreferences.getInstance(); //jwt 조회용
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
    formMap["gender"] = childInfo!["gender"];
    formMap["name"] = te_name.text;
    formMap["changeEmail"] = false;
    formMap["email"] = te_email.text;
    formMap["address"] = te_address.text;
    formMap["addressDetail"] = te_address_detail.text;
    formMap["birth"] = te_birth.text.isEmpty ? "" : "${te_birth.text.substring(0,4)}/${te_birth.text.substring(4,6)}/${te_birth.text.substring(6)}";
    formMap["deleteFileFlag"] = deleteFile;
    formMap["nickName"] = te_nickname.text;
    formMap["intro"] = te_intro.text;
    formMap["changePassword"] = changePassword;
    formMap["password"] = te_password.text.isEmpty ? "1q2w3e4r!" : te_password.text;

    formMap["file"] = file;
    var formData = FormData.fromMap(formMap);

    var response = await httpRequestMultipart(urlUpdate + "/" + childInfo!["id"].toString(), formData, false);
    if(response.statusCode == 200){

      //수정 성공했다면
      //프로필 이미지 다시 받음
      var response = await apiRequestGet(urlMy,  {});
      var body =jsonDecode(utf8.decode(response.bodyBytes));
      if(response.statusCode == 200){
        pref.setString("profile", body["data"]["fileUrl"] ?? "");
        pref.setString("name", body["data"]["name"] ?? "");
      }
      //자동로그인 비밀번호 변경
      if(changePassword){
        pref.setString("password", te_password.text);
      }

      ScaffoldMessenger.of(context)
          .showSnackBar(MainTheme.snackBar("계정정보를 수정했습니다."));
      Navigator.of(context).pop();
    }else{
      ScaffoldMessenger.of(context)
          .showSnackBar(MainTheme.snackBar(response.data["message"]));
    }

    apiProcess = false;

  }
  Future<void> getChildInfo()async {
    var response = await apiRequestGet(urlMy,{});
    var body = jsonDecode(utf8.decode(response.bodyBytes));
    if(response.statusCode == 200){
      childInfo = body["data"];
      te_name.text = childInfo!["name"];
      te_birth.text = childInfo!["birth"].replaceAll("/", "");
      te_sex.text = childInfo!["gender"] == 5 ? "" : "${childInfo!["gender"]}●●●●●●";
      te_email.text = childInfo!["email"];
      te_address.text = childInfo!["address"];
      te_address_detail.text = childInfo!["addressDetail"] ?? "";
      te_intro.text = childInfo!["intro"] ?? "";
      te_nickname.text = childInfo!["nickName"] ?? "";
      if(childInfo!["fileUrl"] != null){
        if(childInfo!["fileUrl"] != "") {
          images.add({
            "network": true,
            "url": childInfo!["fileUrl"],
            "file": null,
            "id": null
          });
        }
      }
      checkFormComplete();
    }
  }
}
