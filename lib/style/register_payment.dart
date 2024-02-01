import 'dart:convert';
import 'dart:math';

import 'package:currency_text_input_formatter/currency_text_input_formatter.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_svg/svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:orange_school/style/time_picker.dart';
import 'package:orange_school/view/common/register_academy.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:simple_shadow/simple_shadow.dart';

import '../util/api.dart';
import '../util/comma_formatter.dart';
import 'alert.dart';
import 'date_picker.dart';
import 'main-theme.dart';
String urlChildren = "${dotenv.env['BASE_URL']}user/commonMembers";
String urlRegister = "${dotenv.env['BASE_URL']}user/payment";
String urlUpdate = "${dotenv.env['BASE_URL']}user/schedule/payment";
const payCycle = [
  {"label" : "반복 없음", "value" : "NONE"},
  {"label" : "1개월", "value" : "ONE_MONTH"},
  {"label" : "2개월", "value" : "TWO_MONTH"},
  {"label" : "3개월", "value" : "THREE_MONTH"},
  {"label" : "4개월", "value" : "FOUR_MONTH"},
  {"label" : "5개월", "value" : "FIVE_MONTH"},
  {"label" : "6개월", "value" : "SIX_MONTH"},
  {"label" : "7개월", "value" : "SEVEN_MONTH"},
  {"label" : "8개월", "value" : "EIGHT_MONTH"},
  {"label" : "9개월", "value" : "NINE_MONTH"},
  {"label" : "10개월", "value" : "TEN_MONTH"},
  {"label" : "11개월", "value" : "ELEVEN_MONTH"},
  {"label" : "매년", "value" : "EVERY_YEAR"},
];

String urlAcademy = "${dotenv.env['BASE_URL']}user/academies";


class RegisterPayment extends StatefulWidget {
  final DateTime initTime;
  final Map? map;
  const RegisterPayment ({ Key? key, required this.initTime , this.map}): super(key: key);
  @override
  _RegisterPayment createState() => _RegisterPayment();
}

class _RegisterPayment extends State<RegisterPayment> {

  List repeatDays = ["월", "화", "수", "목", "금", "토", "일"];

  int index = -1;

  List academy = [{"academyName" : "이름" , "address" : "주소", "id": 6}];

  List children = [
    {"name" : "", "fileUrl" : "", "id" : 0, "profile" : 0},
  ];

  //하루종일 여부
  var onday = false;


  
  //학원찾기 컨트롤러
  TextEditingController te_Academy = TextEditingController();
  OverlayEntry? _overlayEntry;

  //제목 컨트롤러
  TextEditingController te_title = TextEditingController();
  //메모 컨트롤러
  TextEditingController te_note = TextEditingController();

  //메모 컨트롤러
  TextEditingController te_amount = TextEditingController();


  //시작일
  var startTime;
  //종료일
  var endTime;
  //반복 여부
  var repeat = false;
  // 0=요일로 1=주기로
  var repeatType = 0;
  List repeatDaysFlag = [false,false,false,false,false,false,false,];
  //반복 종료일자
  var repeatEndDate;

  int? academyId;
  int? repeatCycleIndex;
  int? planTypeIndex;
  int profileIndex = 0;
  int colorIndex = 0;
  int? selectIndex;
  bool alarmIndex = false;
  DateTime? payDate;
  String? payCycleValue;
  DateTime? payCycleEndDate;
  DateTime? payAmount;
  bool apiProcess = false;
  bool formComplete = false;

  @override
  void initState() {
    super.initState();
    payDate = widget.initTime;
    startTime = widget.initTime;
    endTime = widget.initTime;

    te_Academy = TextEditingController();


    if(widget.map != null){
      te_title.text = widget.map!["title"];
      formComplete = true;
      payCycleValue = widget.map!["payCycle"];
      payCycleEndDate = widget.map!["payCycleEndDate"] == null ? null : DateTime.parse(widget.map!["payCycleEndDate"]);
      te_amount.text ="${NumberFormat('###,###,###,###').format( widget.map!["amount"])}원";
      colorIndex = int.parse(widget.map!["color"]);
      te_note.text = widget.map!["memo"];
      alarmIndex = widget.map!["usePaymentAlarm"]??false;
    }


    getChildren();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(

        children: [
          Container(
            height:MediaQuery.of(context).size.height * 0.9,
            padding: EdgeInsets.only(top: 19, left: 16, right: 16),
            decoration: const BoxDecoration(
                color: Color(0xffF6F7F9),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(24),
                  topRight: Radius.circular(24),
                ) ),

            child:Column(
              children: [
                Container(height: 50,
                  width: double.infinity,
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [


                        GestureDetector(
                          onTap: (){Navigator.pop(context);},
                          behavior: HitTestBehavior.translucent,
                          child:
                          SvgPicture.asset("assets/icons/close.svg",width: 30, height: 30,),
                        )

                      ]
                  ),

                ),
                Expanded(child:

                NotificationListener<ScrollNotification>(
                    onNotification: (scrollNotification) {
                      return true;
                    },
                    child:
                    SingleChildScrollView(
                        scrollDirection: Axis.vertical,
                        child:
                        Container(
                          child:Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(height: 60,
                                alignment: Alignment.topCenter,
                                child:
                                Focus(
                                  onFocusChange:(value) {
                                  if(!value){
                                  checkFormComplete();
                                  }},
                                  child:
                                TextField(
                                  controller: te_title,
                                  autofocus: true,
                                  decoration: InputDecoration(
                                    contentPadding: const EdgeInsets.only(left: 4),
                                    fillColor: MainTheme.backgroundGray,
                                    filled: true,
                                    focusedBorder: InputBorder.none,
                                    enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.all(Radius.circular(12.0)),
                                        borderSide: BorderSide.none),
                                    border: InputBorder.none,
                                    hintText: "제목을 입력하세요",
                                    hintStyle: MainTheme.heading3(MainTheme.gray4),
                                  ),
                                  style: MainTheme.heading3(MainTheme.gray7),
                                ),)
                              ),

                              Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  SvgPicture.asset("assets/icons/ic_16_clock.svg",width: 24, height: 24,),
                                  Container(width: 9,),
                                  Expanded(child:

                                  GestureDetector(
                                    behavior: HitTestBehavior.translucent,
                                    onTap: () async {
                                      FocusManager.instance.primaryFocus?.unfocus();
                                      var pickedDate = await showModalBottomSheet<DateTime>(
                                        context: context,
                                        builder: (BuildContext context) {
                                          return DatePicker( initTime: DateTime.now(),);
                                        },
                                      );
                                      if(pickedDate != null){
                                        setState((){
                                          payDate = pickedDate!;
                                        });
                                      }
                                      checkFormComplete();
                                    },

                                    child:
                                    payDate == null ? Row(
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      children: [
                                        Expanded(child:
                                        Container(
                                            height: 51,
                                            decoration: BoxDecoration(
                                                color: Colors.white,
                                                borderRadius: BorderRadius.circular(12)
                                            ),
                                            padding: EdgeInsets.symmetric(horizontal: 16),
                                            child: Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              crossAxisAlignment: CrossAxisAlignment.center,
                                              children: [
                                                Text("결제일 선택", style: MainTheme.body5(MainTheme.gray4)),
                                                Icon(Icons.keyboard_arrow_down_rounded, color: MainTheme.gray5,),
                                              ],
                                            )
                                        )
                                        )

                                      ],
                                    ) :
                                    Row(
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      children: [
                                        Expanded(child:
                                        Container(
                                            height: 51,
                                            decoration: BoxDecoration(
                                                color: Colors.white,
                                                borderRadius: BorderRadius.circular(12)
                                            ),
                                            padding: EdgeInsets.symmetric(horizontal: 16),
                                            child: Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              crossAxisAlignment: CrossAxisAlignment.center,
                                              children: [
                                                Text(DateFormat('MM월 dd일 E요일', 'ko_KR').format(payDate!), style: MainTheme.body8(MainTheme.gray7),)
                                              ],
                                            )
                                        )
                                        )

                                      ],
                                    ),



                                  ),
                                  )

                                ],
                              ),
                              SizedBox(height: 19,),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  SvgPicture.asset("assets/icons/ic_24_rotate.svg",width: 24, height: 24,),
                                  Container(width: 9,),
                                  Expanded(child:
                                  Container(
                                    height: 51,
                                    decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(12)
                                    ),
                                    padding: EdgeInsets.symmetric(horizontal: 16),
                                    child: DropdownButton<String>(
                                        borderRadius: BorderRadius.circular(10),
                                        isExpanded: true,
                                        dropdownColor: Colors.white,
                                        icon: Icon(Icons.keyboard_arrow_down_rounded, color: MainTheme.gray5,),
                                        hint: Text("결제주기 선택", style: MainTheme.body5(MainTheme.gray4),),
                                        underline: SizedBox.shrink(),
                                        alignment: Alignment.centerLeft,
                                        value: payCycleValue,
                                        onChanged: (String? value) {
                                          payCycleValue = value;
                                          payCycleEndDate = null;
                                          checkFormComplete();
                                        },
                                        items: [
                                          ...List.generate(payCycle.length, (index) =>
                                              DropdownMenuItem<String>(
                                                  child: Text(
                                                    payCycle[index]["label"]!,
                                                    style: MainTheme.body5(MainTheme.gray7),
                                                  ),
                                                  value: payCycle[index]["value"]),)
                                        ]),
                                  )
                                  )

                                ],
                              ),
                              Container(height: 8,),
                              GestureDetector(
                                behavior: HitTestBehavior.translucent,
                                onTap: () async {

                                  if(payCycleValue != "NONE"){
                                    FocusManager.instance.primaryFocus?.unfocus();
                                    var pickedDate = await showModalBottomSheet<DateTime>(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return DatePicker( initTime: payCycleEndDate ?? widget.initTime,);
                                      },
                                    );
                                    if(pickedDate != null){
                                      setState((){
                                        payCycleEndDate = pickedDate!;
                                      });
                                    }
                                    checkFormComplete();
                                  }
                                } ,

                                child:
                                payCycleEndDate == null ? Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    SizedBox(width: 24, height: 24,),
                                    Container(width: 9,),
                                    Expanded(child:
                                    Container(
                                        height: 51,
                                        decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius: BorderRadius.circular(12)
                                        ),
                                        padding: EdgeInsets.symmetric(horizontal: 16),
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          crossAxisAlignment: CrossAxisAlignment.center,
                                          children: [
                                            Text("종료일자 선택", style: MainTheme.body5(MainTheme.gray4)),
                                            Icon(Icons.keyboard_arrow_down_rounded, color: MainTheme.gray5,),
                                          ],
                                        )
                                    )
                                    )

                                  ],
                                ) :
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    SizedBox(width: 24, height: 24,),
                                    Container(width: 9,),
                                    Expanded(child:
                                    Container(
                                        height: 51,
                                        decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius: BorderRadius.circular(12)
                                        ),
                                        padding: EdgeInsets.symmetric(horizontal: 16),
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          crossAxisAlignment: CrossAxisAlignment.center,
                                          children: [
                                            Text(DateFormat('MM월 dd일 E요일', 'ko_KR').format(payCycleEndDate!), style: MainTheme.body8(MainTheme.gray7),)
                                          ],
                                        )
                                    )
                                    )

                                  ],
                                )


                                ,),
                              SizedBox(height: 19,),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  SvgPicture.asset("assets/icons/ic_24_money.svg",width: 24, height: 24,),
                                  Container(width: 9,),
                                  Expanded(child:

                                  Container(
                                      height: 51,
                                      child:
                                      Focus(
                                        onFocusChange:(value) {
                                          if(!value){
                                            checkFormComplete();
                                          }},
                                        child:

                                        TextField(
                                          controller : te_amount,
                                          decoration: MainTheme.inputTextWhite("00,000원"),
                                          style: MainTheme.body5(MainTheme.gray7),
                                          keyboardType:  TextInputType.numberWithOptions(signed: true, decimal: true),
                                          inputFormatters: [
                                            FilteringTextInputFormatter.digitsOnly, //숫자만!
                                            CommaFormatter()
                                          ],
                                          onChanged: (String? value){
                                            if(te_amount.text.length > 0 && te_amount.selection.baseOffset == te_amount.text.length){
                                              te_amount.selection = TextSelection.fromPosition(
                                                TextPosition(offset: te_amount.text.length - 1),
                                              );
                                            }

                                          },
                                          onTap: (){
                                            if(te_amount.text.length > 0 && te_amount.selection.baseOffset == te_amount.text.length){
                                              te_amount.selection = TextSelection.fromPosition(
                                                TextPosition(offset: te_amount.text.length - 1),
                                              );
                                            }

                                          },

                                        ),)
                                  )
                                  )

                                ],
                              ),
                              Container(height: 19,),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  SvgPicture.asset("assets/icons/ic_24_profile.svg",width: 24, height: 24,),
                                  Container(width: 9,),
                                  Expanded(child:
                                  Container(
                                    height: 51,
                                    padding: EdgeInsets.symmetric(horizontal: 16),
                                    decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(12)
                                    ),
                                    child: DropdownButton<int>(
                                        borderRadius: BorderRadius.circular(10),
                                        isExpanded: true,
                                        dropdownColor: Colors.white,
                                        icon: Icon(Icons.keyboard_arrow_down_rounded, color: MainTheme.gray5,),
                                        hint: Text("일정구분", style: MainTheme.body5(MainTheme.gray4),),
                                        underline: SizedBox.shrink(),
                                        alignment: Alignment.centerLeft,
                                        value: profileIndex,
                                        onChanged: (int? value) {
                                          // This is called when the user selects an item.
                                          setState(() {
                                            profileIndex = value!;
                                          });
                                        },
                                        items: [
                                          ...List.generate(children.length, (index) => DropdownMenuItem<int>(
                                              child: Text(
                                                children[index]["name"],
                                                style: MainTheme.body5(MainTheme.gray7),
                                              ),
                                              value: index),)

                                        ]),
                                  )
                                  )

                                ],
                              ),
                              Container(height: 19,),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  SvgPicture.asset("assets/icons/ic_24_color.svg",width: 24, height: 24,),
                                  Container(width: 9,),
                                  Container(width: 15,),
                                  Expanded(child:
                                  Container(
                                    height: 32,
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [

                                        ...List.generate(MainTheme.planColor.length, (index) =>

                                            GestureDetector(
                                                behavior: HitTestBehavior.translucent,
                                                onTap: (){

                                                  setState(() {
                                                    colorIndex = index;
                                                  });

                                                },
                                                child:
                                                Container(
                                                  alignment: Alignment.center,
                                                  width: 32, height: 32,
                                                  decoration: BoxDecoration(
                                                      color: Colors.white,
                                                      shape: BoxShape.circle
                                                  ),
                                                  child: Container(
                                                      width: 24, height: 24,
                                                      decoration: BoxDecoration(
                                                          color: MainTheme.planColor[index],
                                                          shape: BoxShape.circle
                                                      ),
                                                      alignment: Alignment.center,
                                                      child: index == colorIndex ? SvgPicture.asset("assets/icons/check.svg",width: 16, height: 16,): SizedBox.shrink()
                                                  ),


                                                )))
                                      ],


                                    ),
                                  )
                                  )

                                ],
                              ),
                              Container(height: 19,),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  SvgPicture.asset("assets/icons/ic_24_story.svg",width: 24, height: 24,),
                                  Container(width: 9,),
                                  Expanded(child:

                                  Container(
                                    height: 51,
                                    child: TextField(
                                      decoration: MainTheme.inputTextWhite("메모 입력"),
                                      style: MainTheme.body5(MainTheme.gray7),
                                      controller: te_note
                                    ),
                                  )
                                  )

                                ],
                              ),
                              Container(height: 19,),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  SvgPicture.asset("assets/icons/ic_24_bell.svg",width: 24, height: 24,),
                                  Container(width: 9,),
                                  Expanded(child:
                                  Container(
                                    height: 51,
                                    padding: EdgeInsets.symmetric(horizontal: 16),
                                    decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(12)
                                    ),
                                    child: DropdownButton<bool>(
                                        borderRadius: BorderRadius.circular(10),
                                        isExpanded: true,
                                        dropdownColor: Colors.white,
                                        icon: Icon(Icons.keyboard_arrow_down_rounded, color: MainTheme.gray5,),
                                        hint: Text("알림없음", style: MainTheme.body5(MainTheme.gray4),),
                                        underline: SizedBox.shrink(),
                                        alignment: Alignment.centerLeft,
                                        value: alarmIndex,
                                        onChanged: (bool? value) {
                                          // This is called when the user selects an item.
                                          setState(() {
                                            alarmIndex = value!;
                                          });
                                        },
                                        items: [
                                          DropdownMenuItem<bool>(
                                              child: Text(
                                               "알림 없음",
                                                style: MainTheme.body5(MainTheme.gray7),
                                              ),
                                              value: false),
                                          DropdownMenuItem<bool>(
                                              child: Text(
                                                "당일오전9시",
                                                style: MainTheme.body5(MainTheme.gray7),
                                              ),
                                              value: true),
                                        ]),
                                  )
                                  )

                                ],
                              ),

                              SizedBox(height: 50,),


                            ],
                          ),
                        )



                    ))

                ),
                SizedBox(
                  height: MediaQuery.of(context).viewInsets.bottom,
                )
              ],
            )


            ,

          ),
          Positioned(
              right: 16,
              bottom: 20,
              child : GestureDetector(
                behavior: HitTestBehavior.translucent,
                onTap: (){
                    tryRegister();
                },
                child: Container(
                  width: 105, height: 51,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(25.5),
                      color: MainTheme.mainColor
                  ),
                  alignment: Alignment.center,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SvgPicture.asset("assets/icons/check.svg",  width: 16, height: 16,),
                      SizedBox(width: 5,),
                      Text("저장",style: MainTheme.body4(Colors.white),)
                    ],
                  ),
                ),
              )



          ) ]




    );
  }


  @override
  void dispose() {
    super.dispose();
  }

  void checkFormComplete(){

    setState(() {

      // if(
      // te_title.text.isEmpty ||
      // payDate == null ||
      //     payCycleValue == null ||
      //     (((payCycleValue??"NONE") != "NONE") && payCycleEndDate == null) ||
      //     te_amount.text.isEmpty ||
      //   te_title.text.isEmpty ||
      // profileIndex == null
      //
      // ){
      //     formComplete = false;
      // }else{
      //   formComplete = true;
      // }

    });
  }

  void searchAcademy() async {
    index = 0;
    var response = await apiRequestGet(context, urlAcademy,{"page" : index.toString(), "keyword" : te_Academy.text});
    var body =jsonDecode(utf8.decode(response.bodyBytes));
    if(response.statusCode == 200){
        academy = (body["data"]["content"]);
      _overlayEntry!.markNeedsBuild();
    }
  }

  void scroll() async {
    var response = await apiRequestGet(context, urlAcademy,{"page" : index.toString(), "keyword" : te_Academy.text});
    var body =jsonDecode(utf8.decode(response.bodyBytes));
    if(response.statusCode == 200){
      setState(() {
        index ++;
        academy.addAll(body["data"]["content"]);
      });

    }
  }


  Future<void> getChildren() async {
    children = [];
    SharedPreferences pref = await SharedPreferences.getInstance();


    var response = await apiRequestGet(context, urlChildren,  {});
    var body =jsonDecode(utf8.decode(response.bodyBytes));

    if(response.statusCode == 200){
      setState(() {
        for(var child in body["data"]){
          children.add({
            "name" : child["name"],
            "fileUrl" : child["fileUrl"],
            "id" : child["id"],
          });
        }

        children.add({
          "name" : pref.getString("name"),
          "fileUrl" : pref.getString("profile"),
          "id" : pref.getInt("userId"),
        });

        if(widget.map != null){
          for(int i = 0; i < children.length; i++){
            if(children[i]["id"] == widget.map!["commonMemberId"]){
              var child  = children[i];
              children = [];
              children.add(child);
              profileIndex = 0;
              break;
            }
          }
        }
      });

    }


  }
  void tryRegister(){
    // if(
    // te_title.text.isEmpty ||
    // payDate == null ||
    //     payCycleValue == null ||
    //     (((payCycleValue??"NONE") != "NONE") && payCycleEndDate == null) ||
    //     te_amount.text.isEmpty ||
    //   te_title.text.isEmpty ||
    // profileIndex == null
    //
    // ){
    //     formComplete = false;
    // }else{
    //   formComplete = true;
    // }


    if(te_title.text.isEmpty){
      MainTheme.toast("제목을 입력해주세요.");
      return;
    }

    if(payDate == null){
      MainTheme.toast("결제일을 입력해주세요.");
      return;
    }
    if(payCycleValue == null){
      MainTheme.toast("결제주기를 설정해주세요.");
      return;
    }
    if(((payCycleValue??"NONE") != "NONE") && payCycleEndDate == null){
      MainTheme.toast("종료일자를 설정해주세요.");
      return;
    }
    if((payCycleValue??"NONE") != "NONE"){
      if(payDate!.isAfter(payCycleEndDate!)){
        MainTheme.toast("결제 주기 종료일을 결제일 이후로 설정해주세요.");
        return;
      }
    }

    if(te_amount.text.isEmpty){
      MainTheme.toast("결제금액을 입력해주세요.");
      return;
    }



    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Alert(title: "저장하시겠어요?");
      },
    )
        .then((val) {
      if (val != null) {
        if(val){
          register();
        }
      }
    });

  }

  Future<void> register() async {




    if(apiProcess){
      return;
    }else{
      apiProcess = true;
    }

    Map request = {};

    request["commonMemberId"] = children[profileIndex]["id"];
    request["title"] = te_title.text;
    request["startDate"] = DateFormat('yyyy-MM-dd').format(payDate!);
    request["endDate"] = DateFormat('yyyy-MM-dd').format(payDate!);
    request["isAllDay"] = false;
    request["scheduleType"] = "PAY";
    request["color"] = colorIndex.toString();
    request["memo"] = te_note.text;
    request["payDate"] = DateFormat('yyyy-MM-dd').format(payDate!);
    request["payCycle"] = payCycleValue;
    request["payCycleEndDate"] = payCycleEndDate == null ? null : DateFormat('yyyy-MM-dd').format(payCycleEndDate!);
    request["amount"] = te_amount.text.isEmpty ? null : int.parse(te_amount.text.replaceAll(",", "").replaceAll("원", ""));
    request["usePaymentAlarm"] = alarmIndex;
    var response ;
    var body;
    if(widget.map == null){
      response = await apiRequestPost(context, urlRegister,request);
      body =jsonDecode(utf8.decode(response.bodyBytes));
    }else{
      response = await apiRequestPut(context, urlUpdate +  "/" +  widget.map!["id"].toString(), request);
      body =jsonDecode(utf8.decode(response.bodyBytes));
    }



    if(response.statusCode == 200){
      if(widget.map == null){
        Navigator.pop(context, body["data"]);
      }else{
        Navigator.pop(context);
      }
    } else{
      var body = jsonDecode(utf8.decode(response.bodyBytes));
      ScaffoldMessenger.of(context)
          .showSnackBar(MainTheme.snackBar(body["message"]));
    }

    apiProcess = false;
  }

  String colorToHex(Color color) {
    // Color의 red, green, blue 값을 추출합니다.
    int red = color.red;
    int green = color.green;
    int blue = color.blue;

    // RGB 값을 합쳐서 16진수로 변환합니다.
    String hex = '#${_componentToHex(red)}${_componentToHex(green)}${_componentToHex(blue)}';

    return hex.toUpperCase(); // 대문자로 변환하여 반환
  }

  String _componentToHex(int component) {
    // 16진수로 변환된 컴포넌트를 반환합니다.
    String hex = component.toRadixString(16);
    return hex.length == 1 ? '0$hex' : hex; // 한 자릿수인 경우 앞에 0을 추가합니다.
  }

  String getDayStr() {
    List<String> days = [];
    for(int i=0; i<7; i++){
      if(repeatDaysFlag[i]){
        days.add((i+1).toString());
      }
    }
    return days.join(',');
  }


}









