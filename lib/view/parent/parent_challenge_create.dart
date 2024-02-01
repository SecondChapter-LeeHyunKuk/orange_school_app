import 'dart:convert';
import 'dart:ffi';

import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_svg/svg.dart';
import 'package:keyboard_actions/keyboard_actions.dart';
import 'package:keyboard_actions/keyboard_actions_config.dart';
import 'package:orange_school/style/main-theme.dart';
import 'package:flutter/foundation.dart' as foundation;
import 'package:orange_school/util/desimal_formatter.dart';

import '../../style/alert.dart';
import '../../util/api.dart';

String urlRegister = "${dotenv.env['BASE_URL']}user/challenge";

class ParentChallengeCreate extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _ParentChallengeCreate();
}

class _ParentChallengeCreate extends State<ParentChallengeCreate> {
  final FocusNode nodeMission = FocusNode();
  final FocusNode nodeReward = FocusNode();
  bool apiProcess = false;
  bool exposure = false;
  bool formComplete = false;
  TextEditingController te_mission = TextEditingController();
  TextEditingController te_requiredOrangeCount = TextEditingController();
  TextEditingController te_reward = TextEditingController();
  int? childId;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(statusBarColor:Colors.white, statusBarIconBrightness: Brightness.dark));

    childId = ModalRoute.of(context)?.settings.arguments as int;

    return Scaffold(
        appBar: AppBar(
          centerTitle: true,
          scrolledUnderElevation: 0.0,
          backgroundColor: Colors.white,
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios_rounded, color: MainTheme.gray7),
            onPressed: () => Navigator.of(context).pop(),
          ),
          title: Text("챌린지 생성", style:MainTheme.body5(MainTheme.gray7)),
        ),
      backgroundColor: Colors.white,
      body: KeyboardActions(
          config: _buildConfig(context),
          child:SingleChildScrollView(
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
                        focusNode: nodeMission,
                        controller: te_mission,
                        enableInteractiveSelection: true,
                        textAlignVertical: TextAlignVertical.top,
                        expands: true,
                        minLines: null,
                        maxLines: null,
                        decoration: MainTheme.inputTextGrayExpand("챌린지 미션을 입력하세요"),
                        style: MainTheme.body5(MainTheme.gray7),
                      ),)
                  ),
                  Container(
                    height: 22,
                  ),
                  Text("오렌지 개수 (챌린지 목표)", style: MainTheme.caption1(MainTheme.gray5)),
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
                      controller: te_requiredOrangeCount,
                      decoration: MainTheme.inputTextGray("갯수를 입력하세요"),
                      style: MainTheme.body5(MainTheme.gray7),
                      keyboardType:  TextInputType.numberWithOptions(signed: true, decimal: true),
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly, //숫자만!
                        DesimalFomatter(),
                        LengthLimitingTextInputFormatter(2)
                      ],
                    ),)
                  ),
                  Container(
                    height: 10,
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(width: 8,),
                      SvgPicture.asset("assets/icons/info_gray.svg", width: 18,height: 18,),
                      SizedBox(width: 6,),
                      Text("오렌지 선택 시 씨앗 개수는 자동으로 셋팅됩니다.\n도장 5개=오렌지1개", style: MainTheme.caption2(MainTheme.gray5),),

                    ],

                  ),
                  Container(
                    height: 24,
                  ),
                  Text("보상", style: MainTheme.caption1(MainTheme.gray5)),
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
                      controller: te_reward,
                      focusNode: nodeReward,
                      enableInteractiveSelection: true,
                      textAlignVertical: TextAlignVertical.top,
                      expands: true,
                      minLines: null,
                      maxLines: null,
                      decoration: MainTheme.inputTextGrayExpand("보상을 입력하세요"),
                      style: MainTheme.body5(MainTheme.gray7),
                    ),)
                  ),
                  Container(
                    height: 24,
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
      )),
      bottomNavigationBar: Padding(
        padding: EdgeInsets.only(top: 10, left: 20, right: 20, bottom: MediaQuery.of(context).viewPadding.bottom + 10),
        child: ElevatedButton(onPressed:

        formComplete ?
            (){

              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return Alert(title: "챌린지를 등록하시겠어요?");
                },
              )
                  .then((val) {
                if (val != null) {
                  if(val){
                    register();
                  }
                }
              });

            } : null,
            style: MainTheme.primaryButton(MainTheme.mainColor),
            child: Text("등록하기", style: MainTheme.body4(Colors.white),)),
      ),
    );
  }

  void checkFormComplete(){
    if(

        te_mission.text.isEmpty ||
        te_requiredOrangeCount.text.isEmpty ||
        te_reward.text.isEmpty
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
    Map request = {};
    request["childId"] = childId;
    request["mission"] = te_mission.text;
    request["requiredOrangeCount"] = int.parse(te_requiredOrangeCount.text);
    request["reward"] = te_reward.text;
    request["isShow"] = exposure;

    var response = await apiRequestPost(context, urlRegister,request);
    var body = jsonDecode(utf8.decode(response.bodyBytes));

    if(response.statusCode == 200){
      ScaffoldMessenger.of(context)
          .showSnackBar(MainTheme.snackBar("챌린지를 등록하였습니다."));
      Navigator.pop(context);
    } else{
      ScaffoldMessenger.of(context)
          .showSnackBar(MainTheme.snackBar(body["message"]));
    }
    apiProcess = false;
  }

  KeyboardActionsConfig _buildConfig(BuildContext context) {
    return KeyboardActionsConfig(
      keyboardActionsPlatform: KeyboardActionsPlatform.IOS,
      keyboardBarColor: Colors.grey[200],
      nextFocus: false,
      actions: [
        KeyboardActionsItem(
            displayArrows: false,
            focusNode: nodeMission, toolbarButtons: [
              (node) {
            return GestureDetector(
              onTap: () => node.unfocus(),
              child: Padding(
                padding: EdgeInsets.all(8.0),
                child: Icon(Icons.close),
              ),
            );
          }
        ]),
        KeyboardActionsItem(
            displayArrows: false,
            focusNode: nodeReward, toolbarButtons: [
              (node) {
            return GestureDetector(
              onTap: () => node.unfocus(),
              child: Padding(
                padding: EdgeInsets.all(8.0),
                child: Icon(Icons.close),
              ),
            );
          }
        ]),
      ],
    );
  }
}
