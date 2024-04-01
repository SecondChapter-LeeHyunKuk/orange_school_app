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

String urlRegister = "${dotenv.env['BASE_URL']}common/join";


class RegisterSchool extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _RegisterSchool();
}

class _RegisterSchool extends State<RegisterSchool> {

  bool apiProcess = false;

  TextEditingController te_schoolName = TextEditingController();
  TextEditingController te_grade = TextEditingController();
  TextEditingController te_class = TextEditingController();
  TextEditingController te_number = TextEditingController();
  Map<String, dynamic>? formMap = null;

  bool formComplete = false;

  String? schoolCode;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

  }

  @override
  Widget build(BuildContext context) {
    formMap = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>;
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
                  Padding(padding: EdgeInsets.only(left: 4),
                    child: Text("학교 수업 정보 확인을 위해 등록합니다.", style: MainTheme.body8(MainTheme.gray6)),
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
                            child:
                            GestureDetector(
                              onTap: (){
                                showModalBottomSheet<Map>(
                                  context: context,
                                  isScrollControlled: true,
                                  builder: (BuildContext context) {
                                    return SearchSchoolBottom();
                                  },
                                ).then((val) {
                                  if (val != null) {
                                    schoolCode = te_schoolName.text = val["schoolCode"];
                                    setState(() {te_schoolName.text = val["schoolNm"];
                                    });
                                  }
                                });

                              },
                              child: TextField(
                                controller: te_schoolName,
                                enabled: false,
                                decoration: MainTheme.inputTextGray("학교명을 검색하세요"),
                                style: MainTheme.body5(MainTheme.gray7),
                              ),
                            )


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
                          keyboardType:  TextInputType.numberWithOptions(signed: true, decimal: true),
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
                          inputFormatters: [
                            LengthLimitingTextInputFormatter(10)
                          ],
                        ),
                      )

                  ),

                  Container(
                    height: 17,
                  ),
                  Text("번호(선택)", style: MainTheme.caption1(MainTheme.gray5)),
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
                          keyboardType:  TextInputType.numberWithOptions(signed: true, decimal: true),
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
        padding: EdgeInsets.only(top: 10, left: 20, right: 20, bottom: MediaQuery.of(context).viewPadding.bottom + 10),
        child: ElevatedButton(
            onPressed:formComplete ? (){register(); } : null ,
            style: MainTheme.primaryButton(MainTheme.mainColor),
            child: Text("저장하기", style: MainTheme.body4(Colors.white),)),
      ),
    );
  }

  void checkFormComplete(){
    if(

    te_schoolName.text.isEmpty ||
        te_grade.text.isEmpty ||
        te_class.text.isEmpty
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
    if(apiProcess){
      return;
    }else{
      apiProcess = true;
    }


    formMap!["schoolName"] = te_schoolName.text;
    formMap!["grade"] = te_grade.text;
    formMap!["schoolClass"] = te_class.text;
    formMap!["classNumber"] = te_number.text;
    formMap!["schoolCode"] = schoolCode;

    var formData = FormData.fromMap(formMap!);

    var response = await httpRequestMultipart(context, urlRegister, formData!, true);

    if(response.statusCode == 200){
      if(formMap!["mode"] == "NEW"){
        Navigator.of(context).popUntil(ModalRoute.withName('/login'));
        Navigator.of(context).pushNamed('/registerComplete');
      }else{
        ScaffoldMessenger.of(context)
            .showSnackBar(MainTheme.snackBar(response.data["message"]));
        Navigator.of(context).popUntil(ModalRoute.withName('/parent/my/children'));
      }


    }else{
      ScaffoldMessenger.of(context)
          .showSnackBar(MainTheme.snackBar(response.data["message"]));
    }
    apiProcess = false;
  }
}
