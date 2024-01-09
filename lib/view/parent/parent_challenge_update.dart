import 'dart:convert';
import 'dart:ffi';

import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_svg/svg.dart';
import 'package:orange_school/style/main-theme.dart';
import 'package:flutter/foundation.dart' as foundation;
import 'package:orange_school/util/desimal_formatter.dart';

import '../../style/alert.dart';
import '../../util/api.dart';

String urlUpdate = "${dotenv.env['BASE_URL']}user/challenge";

class ParentChallengeUpdate extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _ParentChallengeUpdate();
}

class _ParentChallengeUpdate extends State<ParentChallengeUpdate> {


  bool exposure = false;
  bool formComplete = true;
  TextEditingController te_mission = TextEditingController();
  Map? challenge;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(statusBarColor:Colors.white, statusBarIconBrightness: Brightness.dark));

    if(challenge == null){
      challenge = ModalRoute.of(context)?.settings.arguments as Map;
      te_mission.text = challenge!["mission"];
      exposure = challenge!["isShow"];
    }


    return Scaffold(
        appBar: AppBar(
          centerTitle: true,
          scrolledUnderElevation: 0.0,
          backgroundColor: Colors.white,
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios_rounded, color: MainTheme.gray7),
            onPressed: () => Navigator.of(context).pop(),
          ),
          title: Text("챌린지 수정", style:MainTheme.body5(MainTheme.gray7)),
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
                    height: 22,
                  ),
                  Container(
                    height: 17,
                  ),
                  Text("챌린지 미션", style: MainTheme.caption1(MainTheme.gray5)),
                  Container(
                    height: 4,
                  ),
                  Container(height: 162,
                    child: Focus(
                      onFocusChange:(value) {
                        if(!value){
                          checkFormComplete();
                        }
                      }, child :TextField(
                      controller: te_mission,
                      enableInteractiveSelection: true,
                      textAlignVertical: TextAlignVertical.top,
                      expands: true,
                      minLines: null,
                      maxLines: null,
                      decoration: MainTheme.inputTextGrayExpand("챌린지 미션을 입력하세요"),
                      style: MainTheme.body5(MainTheme.gray7),
                    ),),
                  ),
                  Container(
                    height: 22,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text("동네 챌린지 공개 여부", style: MainTheme.caption1(MainTheme.gray5),),
                      CupertinoSwitch(value: exposure,activeColor: MainTheme.mainColor, trackColor: Color(0xffBEC5CC),onChanged: (bool value){
                        setState(() {
                          exposure = value;
                        });
                       })
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
        child: ElevatedButton(onPressed:

        formComplete ?
            (){showDialog(
              context: context,
              builder: (BuildContext context) {
                return Alert(title: "챌린지를 수정하시겠습니까?");
              },
            )
                .then((val) {
              if (val != null) {
                if(val){
                  update();
                }
              }
            });} : null,
            style: MainTheme.primaryButton(MainTheme.mainColor),
            child: Text("수정하기", style: MainTheme.body4(Colors.white),)),
      ),
    );
  }



  void checkFormComplete(){
    if(
        te_mission.text.isEmpty
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
    Map request = {};
    request["mission"] = te_mission.text;
    request["isShow"] = exposure;

    var response = await apiRequestPut(urlUpdate + "/" + challenge!["id"].toString() ,request);
    var body = jsonDecode(utf8.decode(response.bodyBytes));

    if(response.statusCode == 200){
      ScaffoldMessenger.of(context)
          .showSnackBar(MainTheme.snackBar("챌린지를 수정했습니다."));
      Navigator.pop(context);
    } else{
      ScaffoldMessenger.of(context)
          .showSnackBar(MainTheme.snackBar(body["message"]));
    }
  }
}
