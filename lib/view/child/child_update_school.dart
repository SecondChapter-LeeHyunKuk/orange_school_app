import 'dart:convert';
import 'dart:ffi';


import 'package:dio/dio.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_svg/svg.dart';
import 'package:orange_school/style/main-theme.dart';
import 'package:flutter/foundation.dart' as foundation;
import 'package:orange_school/view/common/search_school.dart';
import 'package:orange_school/view/common/search_school_bottom.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../util/api.dart';

String urlUpdate = "${dotenv.env['BASE_URL']}user/commonMember/school";
String urlMy = "${dotenv.env['BASE_URL']}user/commonMember";

class ChildUpdateSchool extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _ChildUpdateSchool();
}

class _ChildUpdateSchool extends State<ChildUpdateSchool> {
  TextEditingController te_schoolName = TextEditingController();
  TextEditingController te_grade = TextEditingController();
  TextEditingController te_class = TextEditingController();
  TextEditingController te_number = TextEditingController();
  Map? childInfo;

  bool formComplete = false;
  bool apiProcess = false;
  String? schoolCode;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getChildInfo();
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

            Container(margin: EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 34,
                  ),
                  Container(
                    margin: EdgeInsets.only(left: 4),
                    child: Text("학교 등록하기", style: MainTheme.heading1(MainTheme.gray7)),
                  ),
                  Container(
                    height: 49,
                  ),
                  Text("학교 검색", style: MainTheme.caption1(MainTheme.gray5)),
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
                            controller: te_schoolName,
                            enabled: false,
                            decoration: MainTheme.inputTextGray("학교명을 검색하세요"),
                            style: MainTheme.body5(MainTheme.gray7),
                          ),
                        )
                        ),
                        Container(
                          width: 10,
                        ),
                        Container(height: 35,
                            width: 86,
                            child: ElevatedButton(
                              onPressed: () {
                                FocusManager.instance.primaryFocus?.unfocus();
                                // showDialog(
                                //     context: context,
                                //     builder: (BuildContext context) {
                                //       return SearchSchool();
                                //     }).then((val) {
                                //   if (val != null) {
                                //     setState(() {
                                //       schoolName.text = val["schoolNm"];
                                //     });
                                //   }
                                // });
                                showModalBottomSheet<Map>(
                                  context: context,
                                  isScrollControlled: true,
                                  builder: (BuildContext context) {
                                    return SearchSchoolBottom();
                                  },
                                ).then((val) {
                                  if (val != null) {
                                    schoolCode = val["schoolCode"];
                                    setState(() {te_schoolName.text = val["schoolNm"];
                                    });
                                  }
                                });
                              },
                              style: MainTheme.followButton(),
                              child: Text("검색", style: MainTheme.caption1(Colors.white),),
                            )
                        )
                      ]

                  ),
                  Container(
                    height: 17,
                  ),
                  Text("학년", style: MainTheme.caption1(MainTheme.gray5)),
                  Container(
                    height: 4,
                  ),
                  Container(height: 51,
                      child: Focus(
                        onFocusChange:(value) {
                          if(!value){
                            checkFormComplete();
                          }
                        },
                        child: TextFormField(
                          controller: te_grade,
                          decoration: MainTheme.inputTextGray("학년"),
                          style: MainTheme.body5(MainTheme.gray7),
                          keyboardType:  TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly, //숫자만!
                            LengthLimitingTextInputFormatter(1)
                          ],
                        ),
                      )

                  ),

                  const SizedBox(
                    height: 17,
                  ),
                  Text("반", style: MainTheme.caption1(MainTheme.gray5)),
                  const SizedBox(
                    height: 4,
                  ),
                  Container(height: 51,
                      child: Focus(
                        onFocusChange:(value) {
                          if(!value){
                            checkFormComplete();
                          }
                        },
                        child: TextFormField(
                          controller: te_class,
                          decoration: MainTheme.inputTextGray("반"),
                          style: MainTheme.body5(MainTheme.gray7),
                          keyboardType:  TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly, //숫자만!
                            LengthLimitingTextInputFormatter(2)
                          ],
                        ),
                      )

                  ),

                  Container(
                    height: 17,
                  ),
                  Text("번호", style: MainTheme.caption1(MainTheme.gray5)),
                  Container(
                    height: 4,
                  ),
                  Container(height: 51,
                      child: Focus(
                        onFocusChange:(value) {
                          if(!value){
                            checkFormComplete();
                          }
                        },
                        child: TextFormField(
                          controller: te_number,
                          decoration: MainTheme.inputTextGray("번호"),
                          style: MainTheme.body5(MainTheme.gray7),
                          keyboardType:  TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly, //숫자만!
                            LengthLimitingTextInputFormatter(3)
                          ],
                        ),
                      )

                  ),


                ],
              ),
            )
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: EdgeInsets.only(top: 10, left: 20, right: 20, bottom: 10),
        child: ElevatedButton(
            onPressed:formComplete ? (){update(); } : null ,
            style: MainTheme.primaryButton(MainTheme.mainColor),
            child: Text("저장하기", style: MainTheme.body4(Colors.white),)),
      ),
    );
  }

  void checkFormComplete(){
    if(

    te_schoolName.text.isEmpty ||
        te_grade.text.isEmpty ||
        te_class.text.isEmpty ||
        te_number.text.isEmpty
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

    if(apiProcess){
      return;
    }else{
      apiProcess = true;
    }

    Map request = {};
    request["schoolName"] = te_schoolName.text;
    request["grade"] = te_grade.text;
    request["schoolClass"] = te_class.text;
    request["classNumber"] = te_number.text;
    request["schoolCode"] = schoolCode;
    var response = await apiRequestPut("$urlUpdate/" + childInfo!["id"].toString(), request);
    var body =jsonDecode(utf8.decode(response.bodyBytes));
    if(response.statusCode == 200){
      ScaffoldMessenger.of(context)
          .showSnackBar(MainTheme.snackBar("학교를 등록했습니다."));
      Navigator.pop(context);
    }else{
      ScaffoldMessenger.of(context)
          .showSnackBar(MainTheme.snackBar(body["message"]));
    }
    apiProcess = false;
  }

  Future<void> getChildInfo()async {
    var response = await apiRequestGet(urlMy,{});
    var body = jsonDecode(utf8.decode(response.bodyBytes));
    if(response.statusCode == 200){
        childInfo = body["data"];
        te_schoolName.text = childInfo!["schoolName"] ?? "";
        te_grade.text = childInfo!["grade"]?? "";
        te_class.text = childInfo!["schoolClass"]?? "";
        te_number.text = childInfo!["classNumber"]?? "";
        schoolCode = childInfo!["schoolCode"];
        checkFormComplete();
    }
  }
}
