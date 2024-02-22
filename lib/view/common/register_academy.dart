import 'dart:convert';

import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:orange_school/style/main-theme.dart';
import 'package:flutter/foundation.dart' as foundation;
import 'package:remedi_kopo/remedi_kopo.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../util/api.dart';


String urlRegister = "${dotenv.env['BASE_URL']}user/academy";


class RegisterAcademy extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _RegisterAcademy();
}

class _RegisterAcademy extends State<RegisterAcademy> {


  TextEditingController te_address = TextEditingController();
  TextEditingController te_address_detail = TextEditingController();
  TextEditingController te_name = TextEditingController();
  bool formComplete = false;
  bool apiProcess = false;
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
                    height: 34,
                  ),
                  Text("학원 등록하기", style: MainTheme.heading1(MainTheme.gray7)),
                  Container(
                    height: 6,
                  ),
                  Text("정확한 정보를 입력해 주시고, 오탈자에 주의해 주세요!", style: MainTheme.body9(MainTheme.gray6)),
                  Container(
                    height: 49,
                  ),
                  Text("학원명", style: MainTheme.caption1(MainTheme.gray5)),
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
                        decoration: MainTheme.inputTextGray("학원명"),
                        style: MainTheme.body5(MainTheme.gray7),
                        inputFormatters: [
                          LengthLimitingTextInputFormatter(30)
                        ],
                      ),)
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
                        Container(height: 51,
                            child: Focus(
                              onFocusChange:(value) {
                                if(!value){
                                  checkFormComplete();
                                }
                              }, child :TextField(
                              controller: te_address,
                              enabled: false,
                              decoration: MainTheme.inputTextGray("주소를 검색하세요"),
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
                    )
                  ),
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
        child: ElevatedButton(onPressed: formComplete ? (){register();} : null,
            style: MainTheme.primaryButton(MainTheme.mainColor),
            child: Text("등록하기", style: MainTheme.body4(Colors.white),)),
      ),
    );
  }
  void checkFormComplete(){
    if(
        te_name.text.isEmpty ||
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
    if(apiProcess){
      return;
    }else{
      apiProcess= true;
    }


    Map<String, dynamic> request = new Map<String, Object>();
    request["academyName"] = te_name.text;
    request["address"] = te_address.text;
    request["addressDetail"] = te_address_detail.text;


    var response = await apiRequestPost(context, urlRegister,request);
    var body = jsonDecode(utf8.decode(response.bodyBytes));
    if(response.statusCode == 200){
      Navigator.of(context).pop({"academyId" : body["data"], "academyName" : te_name.text});
    } else{
      ScaffoldMessenger.of(context)
          .showSnackBar(MainTheme.snackBar(body["message"]));
    }
    apiProcess = false;
  }
}
