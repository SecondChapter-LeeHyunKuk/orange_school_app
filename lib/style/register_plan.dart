import 'dart:convert';
import 'dart:ffi';
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
String urlRegister = "${dotenv.env['BASE_URL']}user/schedule";
String urlUpdate = "${dotenv.env['BASE_URL']}user/schedule";
  const planType = [
    {"label" : "학원", "value" : "ACADEMY"},
    {"label" : "학교", "value" : "SCHOOL"},
    {"label" : "방과 후 교실", "value" : "CLASS"},
    {"label" : "차량 승하차", "value" : "VEHICLE"},
    {"label" : "기타 일상", "value" : "ETC"},
    {"label" : "일정", "value" : "SCHEDULE"},
  ];

  const planTypeParent = [
    {"label" : "기타 일상", "value" : "ETC"},
    {"label" : "일정", "value" : "SCHEDULE"},
  ];

const repeatCycle = [
  {"label" : "매일", "value" : "EVERY_DAY"},
  {"label" : "매주", "value" : "EVERY_WEEK"},
  {"label" : "2주", "value" : "TWO_WEEK"},
  {"label" : "3주", "value" : "THREE_WEEK"},
  {"label" : "4주", "value" : "FOUR_WEEK"},
  {"label" : "매월", "value" : "EVERY_MONTH"},
  {"label" : "매년", "value" : "EVERY_YEAR"},
];

const payCycle = [
  {"label" : "반복 안함", "value" : "NONE"},
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

const alarmType = [
  {"label" : "없음", "value" : ""},
  {"label" : "이벤트 당시", "value" : "ZERO_MINUTES_AGO"},
  {"label" : "5분전", "value" : "FIVE_MINUTES_AGO"},
  {"label" : "15분전", "value" : "FIFTEEN_MINUTES_AGO"},
  {"label" : "30분전", "value" : "THIRTY_MINUTES_AGO"},
  {"label" : "1시간전", "value" : "ONE_HOURS_AGO"},
  {"label" : "2시간전", "value" : "TWO_HOURS_AGO"},
  {"label" : "1일전", "value" : "ONE_DAY_AGO"},
];
String urlAcademy = "${dotenv.env['BASE_URL']}user/academies";


class RegisterPlan extends StatefulWidget {

  final DateTime initTime;
  final Map? map;
  final int? childId;
  final bool? onday;
  const RegisterPlan ({ Key? key, required this.initTime , this.map , this.childId, this.onday}): super(key: key);
  @override
  _RegisterPlan createState() => _RegisterPlan();
}

class _RegisterPlan extends State<RegisterPlan> {

  List repeatDays = ["월", "화", "수", "목", "금", "토", "일"];

  int index = -1;
  final ScrollController academyScrollController = ScrollController();

  List academy = [{"academyName" : "이름" , "address" : "주소", "id": 6}];

  //스크롤 컨트롤러
  final ScrollController _controller = ScrollController();
  List children = [
    {"name" : "", "fileUrl" : "", "id" : 0, "profile" : 0},
  ];

  //하루종일 여부
  var onday = false;

  //결제내역 추가
  var payment = false;
  bool apiProcess = false;
  
  //학원찾기 컨트롤러
  TextEditingController te_Academy = TextEditingController();
  FocusNode _searchFocusNode = FocusNode();
  OverlayEntry? _overlayEntry;
  LayerLink _layerLink = LayerLink();
  
  String? academyMessage;

  //제목 컨트롤러
  TextEditingController te_title = TextEditingController();
  //제목 포커스
  FocusNode _titleFocusNode = FocusNode();
  //메모 컨트롤러
  TextEditingController te_note = TextEditingController();

  //메모 컨트롤러
  TextEditingController te_amount = TextEditingController();

  FocusNode titleFocus = FocusNode();

  //시작일
  late DateTime startTime;
  //종료일
  late DateTime endTime;
  //반복 여부
  var repeat = false;
  // 0=요일로 1=주기로
  var repeatType = 0;
  List repeatDaysFlag = [false,false,false,false,false,false,false,];
  //반복 종료일자
  DateTime? repeatEndDate = DateTime(DateTime.now().year, DateTime.now().month + 1, DateTime.now().day);

  int? academyId;
  String? repeatCycleValue;
  String? planTypeValue;
  int profileIndex = 0;
  int colorIndex = 0;
  String? alarmIndex;
  DateTime payDate = DateTime.now();
  String? payCycleIndex;
  DateTime? payCycleEndDate;
  DateTime? payAmount;
  bool payAlarmIndex = false;

  bool formComplete = false;

  @override
  void initState() {
    super.initState();

    startTime = widget.initTime;
    endTime = widget.initTime.add(Duration(hours: 1));
    if(widget.onday != null){
      onday = true;
    }
    te_Academy = TextEditingController();
    _searchFocusNode = FocusNode()
      ..addListener(() {
        if (!_searchFocusNode.hasFocus) {
          _removeSearchOverlay();
        }
        checkFormComplete();
      });
    _controller.addListener(() {


    });

    academyScrollController.addListener(() {
      if (academyScrollController.position.pixels ==
          academyScrollController.position.maxScrollExtent && index > 0) {
        scroll();
      }
    });

    if(widget.map != null){

      te_title.text = widget.map!["title"];
      startTime = DateTime.parse(widget.map!["startDate"] + " " + widget.map!["startTime"] );
      endTime = DateTime.parse(widget.map!["endDate"] + " " + widget.map!["endTime"] );
      onday = widget.map!["isAllDay"];
      repeat = widget.map!["cycleType"] != "NONE";
      repeatType = widget.map!["cycleType"] == "NONE" ? 0 : widget.map!["cycleType"] == "PERIOD" ? 1 : 0;

      if(widget.map!["cycleEndDate"] != null){
        repeatEndDate = DateTime.parse(widget.map!["cycleEndDate"]);
      }


      if(widget.map!["cycleDays"] != null) {
        if(widget.map!["cycleDays"].length >= 1) {
          List<String> resultList = widget.map!["cycleDays"].split(',');
          for (String day in resultList) {
            repeatDaysFlag[int.parse(day) - 1] = true;
          }
        }
      }

      if(widget.map!["calendarCycle"] != null) {
        if(widget.map!["calendarCycle"] != "NONE") {
          repeatCycleValue = widget.map!["calendarCycle"];
        }
      }


      if(widget.map!["academy"] != null){
        te_Academy.text = widget.map!["academy"]["academyName"];
        academyId =  widget.map!["academy"]["id"];
      }else{
        te_Academy.text = widget.map!["academyName"];
      }

      colorIndex = int.parse(widget.map!["color"]);
      te_note.text = widget.map!["memo"] ?? "";
      payment = widget.map!["usePay"];

      if(payment){

        payCycleIndex = widget.map!["payCycle"];
        if(widget.map!["payCycleEndDate"] != null ){
          payCycleEndDate = DateTime.parse(widget.map!["payCycleEndDate"]);
        }
        te_amount.text ="${NumberFormat('###,###,###,###').format( widget.map!["amount"])}원";

      }
      payAlarmIndex = widget.map!["usePaymentAlarm"]??false;

      alarmIndex = widget.map!["scheduleAlarmType"] == "NONE" ? null : widget.map!["scheduleAlarmType"];

      formComplete = true;
    }

    _searchFocusNode.addListener(() { if(_searchFocusNode.hasFocus){

      _showsearchOverlayFocus();

    }});
    
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
                      if (scrollNotification is UserScrollNotification) {
                        _removeSearchOverlay();
                      }
                      return true;
                    },
                    child:
                    SingleChildScrollView(
                        controller: _controller,
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
                                  focusNode: titleFocus,
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

                                  Container(
                                      height: 80,
                                      decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.circular(12)
                                      ),
                                      padding: EdgeInsets.only(left: 20, right: 16),
                                      child:Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        children: [
                                          !onday ? Container(width: 192,
                                            child: Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              crossAxisAlignment: CrossAxisAlignment.center,
                                              children: [
                                                GestureDetector(
                                                  behavior: HitTestBehavior.translucent,
                                                  onTap: () async {
                                                    FocusManager.instance.primaryFocus?.unfocus();
                                                    var pickedDate = await showModalBottomSheet<DateTime>(
                                                      context: context,
                                                      builder: (BuildContext context) {
                                                        return TimePicker( initTime: startTime,);
                                                      },
                                                    );
                                                    if(pickedDate != null){
                                                      setState((){
                                                        startTime = pickedDate!;
                                                        endTime = pickedDate!.add(Duration(hours: 1));
                                                      });}
                                                    checkFormComplete();
                                                  },

                                                  child:
                                                  Container(
                                                    width: 79,
                                                    child:Column(
                                                      mainAxisAlignment: MainAxisAlignment.center,
                                                      crossAxisAlignment: CrossAxisAlignment.center,
                                                      children: [
                                                        Text(DateFormat("MM월 dd일 E", 'ko_KR').format(startTime), style: MainTheme.body9(MainTheme.gray7),),
                                                        Text(DateFormat("aa hh:mm", 'ko_KR').format(startTime), style:TextStyle(fontWeight: FontWeight.w800, fontFamily: "SUIT", fontSize: 16, color: MainTheme.gray7,letterSpacing: 0 ))
                                                      ],
                                                    ),
                                                  ),),
                                                SvgPicture.asset(
                                                  'assets/icons/arrow_right.svg',
                                                  width: 16,
                                                  height: 16,
                                                ),
                                                GestureDetector(
                                                  behavior: HitTestBehavior.translucent,
                                                  onTap: () async {
                                                    FocusManager.instance.primaryFocus?.unfocus();
                                                    var pickedDate = await showModalBottomSheet<DateTime>(
                                                      context: context,
                                                      builder: (BuildContext context) {
                                                        return TimePicker( initTime: endTime,);
                                                      },
                                                    );
                                                    if(pickedDate != null){
                                                      setState((){

                                                        endTime = pickedDate!;

                                                      });}
                                                    checkFormComplete();
                                                  },

                                                  child:
                                                  Container(
                                                    width: 79,
                                                    child:Column(
                                                      mainAxisAlignment: MainAxisAlignment.center,
                                                      crossAxisAlignment: CrossAxisAlignment.center,
                                                      children: [
                                                        Text(DateFormat("MM월 dd일 E", 'ko_KR').format(endTime), style: MainTheme.body9(MainTheme.gray7),),
                                                        Text(DateFormat("aa hh:mm", 'ko_KR').format(endTime), style:TextStyle(fontWeight: FontWeight.w800, fontFamily: "SUIT", fontSize: 16, color: MainTheme.gray7,letterSpacing: 0 ))
                                                      ],
                                                    ),
                                                  ),)
                                              ],

                                            ),
                                          ) :


                                            Container(width: 192,
                                              child: Row(
                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                crossAxisAlignment: CrossAxisAlignment.center,
                                                children: [
                                                  GestureDetector(

                                                    behavior: HitTestBehavior.translucent,
                                                    onTap: () async {
                                                      FocusManager.instance.primaryFocus?.unfocus();
                                                      var pickedDate = await showModalBottomSheet<DateTime>(
                                                        context: context,
                                                        builder: (BuildContext context) {
                                                          return DatePicker( initTime: startTime,);
                                                        },
                                                      );
                                                      if(pickedDate != null){
                                                        setState((){
                                                          startTime = pickedDate!;
                                                          endTime = pickedDate!.add(Duration(hours: 1));
                                                        });}
                                                      checkFormComplete();
                                                    },

                                                    child:
                                                  Container(
                                                    width: 79,
                                                    child:Column(
                                                      mainAxisAlignment: MainAxisAlignment.center,
                                                      crossAxisAlignment: CrossAxisAlignment.center,
                                                      children: [
                                                        Text(DateFormat("MM월 dd일 E", 'ko_KR').format(startTime), style: MainTheme.body9(MainTheme.gray7),),
                                                      ],
                                                    ),
                                                  ),),
                                                  SvgPicture.asset(
                                                    'assets/icons/arrow_right.svg',
                                                    width: 16,
                                                    height: 16,
                                                  ),
                                                  GestureDetector(
                                                    behavior: HitTestBehavior.translucent,
                                                    onTap: () async {
                                                      FocusManager.instance.primaryFocus?.unfocus();
                                                      var pickedDate = await showModalBottomSheet<DateTime>(
                                                        context: context,
                                                        builder: (BuildContext context) {
                                                          return DatePicker( initTime: endTime,);
                                                        },
                                                      );
                                                      if(pickedDate != null){
                                                        setState((){

                                                          endTime = pickedDate!;

                                                        });}
                                                      checkFormComplete();
                                                    },

                                                    child:
                                                    Container(
                                                      width: 79,
                                                      child:Column(
                                                        mainAxisAlignment: MainAxisAlignment.center,
                                                        crossAxisAlignment: CrossAxisAlignment.center,
                                                        children: [
                                                          Text(DateFormat("MM월 dd일 E", 'ko_KR').format(endTime), style: MainTheme.body9(MainTheme.gray7),),
                                                        ],
                                                      ),
                                                    ),),
                                                ],

                                              ),
                                            ),
                                          GestureDetector(
                                              behavior: HitTestBehavior.translucent,
                                              onTap: (){
                                                setState((){
                                                  onday = !onday;
                                                });
                                              },
                                              child:Container(
                                                width: 60,
                                                height: 30,
                                                decoration: BoxDecoration(
                                                  color: onday? MainTheme.gray7: Colors.transparent,
                                                  borderRadius: BorderRadius.circular(4),
                                                  border: Border.all(
                                                    width: 1.5,
                                                    color: onday? Colors.transparent : MainTheme.gray2,
                                                  ),


                                                ),
                                                alignment: Alignment.center,
                                                child: Text("하루종일", style: MainTheme.caption2(onday? Colors.white : MainTheme.gray7),),

                                              )
                                          ),

                                        ],
                                      )
                                  )
                                  )

                                ],
                              ),
                              Container(height: 19,),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    margin: EdgeInsets.only(top: 13),
                                    child:  SvgPicture.asset("assets/icons/ic_24_rotate.svg",width: 24, height: 24,),
                                  ),

                                  Container(width: 9,),
                                  repeat ?
                                  Expanded(child:
                                  Container(
                                    child: Column(
                                      children: [
                                        SizedBox(height: 13,),
                                        Row(
                                          crossAxisAlignment: CrossAxisAlignment.center,
                                          mainAxisAlignment: MainAxisAlignment.start,
                                          children: [
                                            GestureDetector(
                                              behavior: HitTestBehavior.translucent,
                                              onTap: (){
                                                setState(() {
                                                  repeatType = 0;
                                                });
                                                checkFormComplete();
                                              },
                                              child: IntrinsicWidth(
                                                child: Row(
                                                  children: [
                                                    CupertinoRadio<int>(
                                                      value: 0,
                                                      activeColor: MainTheme.mainColor,
                                                      groupValue: repeatType,
                                                      onChanged: null
                                                    ),
                                                    SizedBox(width: 8,),
                                                    Text("요일로 설정", style: MainTheme.body4(MainTheme.gray7),),
                                                    
                                                  ]
                                                ),
                                              )
                                            ),
                                            
                                            SizedBox(width: 12),
                                            GestureDetector(
                                                behavior: HitTestBehavior.translucent,
                                                onTap: (){
                                                  setState(() {
                                                    repeatType = 1;
                                                  });
                                                  checkFormComplete();
                                                },
                                                child: IntrinsicWidth(
                                                  child: Row(
                                                      children: [
                                                        CupertinoRadio<int>(
                                                          value: 1,
                                                          activeColor: MainTheme.mainColor,
                                                          groupValue: repeatType,
                                                          onChanged: null
                                                        ),
                                                        SizedBox(width: 8,),
                                                        Text("주기로 설정", style: MainTheme.body4(MainTheme.gray7),),

                                                      ]
                                                  ),
                                                )
                                            ),
                                          ],
                                        ),
                                        Column(
                                          children: [
                                            SizedBox(height: 16,),
                                            repeatType == 0 ? Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: [
                                                ...List.generate(7, (index) => GestureDetector(
                                                  behavior: HitTestBehavior.translucent,
                                                  onTap: (){
                                                  repeatDaysFlag[index] = !repeatDaysFlag[index];
                                                    checkFormComplete();},
                                                  child:
                                                  Container(
                                                    width: 40, height: 40,
                                                    alignment: Alignment.center,
                                                    decoration: BoxDecoration(
                                                        shape: BoxShape.circle,
                                                        color: repeatDaysFlag[index] ? MainTheme.mainColor : Colors.white
                                                    ),
                                                    child: Container(
                                                      width: 36, height: 36,
                                                      alignment: Alignment.center,
                                                      decoration: BoxDecoration(
                                                          shape: BoxShape.circle,
                                                          color: Colors.white
                                                      ),
                                                      child: Text(repeatDays[index], style: MainTheme.body4(repeatDaysFlag[index] ?MainTheme.mainColor : MainTheme.gray7),),
                                                    ),
                                                  )
                                                  ,

                                                ))
                                              ],
                                            ) :
                                            Container(
                                              height: 51,
                                              padding: EdgeInsets.symmetric(horizontal: 16),
                                              decoration: BoxDecoration(
                                                  color: Colors.white,
                                                  borderRadius: BorderRadius.circular(12)
                                              ),
                                              child: DropdownButton<String>(
                                                  borderRadius: BorderRadius.circular(10),
                                                  isExpanded: true,
                                                  dropdownColor: Colors.white,
                                                  icon: Icon(Icons.keyboard_arrow_down_rounded, color: MainTheme.gray5,),
                                                  hint: Text("주기 선택", style: MainTheme.body5(MainTheme.gray4),),
                                                  underline: SizedBox.shrink(),
                                                  alignment: Alignment.centerLeft,
                                                  value: repeatCycleValue,
                                                  onChanged: (String? value) {
                                                    // This is called when the user sel
                                                    repeatCycleValue = value;
                                                      checkFormComplete();
                                                  },
                                                  items: [
                                                    ...List.generate(repeatCycle.length, (index) =>
                                                        DropdownMenuItem<String>(
                                                        child: Text(
                                                          repeatCycle[index]["label"]!,
                                                          style: MainTheme.body5(MainTheme.gray7),
                                                        ),
                                                        value: repeatCycle[index]["value"]),)
                                                  ]),
                                            ),
                                            SizedBox(height: 16,),
                                            GestureDetector(
                                              behavior: HitTestBehavior.translucent,
                                              onTap: () async {
                                                FocusManager.instance.primaryFocus?.unfocus();
                                                var pickedDate = await showModalBottomSheet<DateTime>(
                                                  context: context,
                                                  builder: (BuildContext context) {
                                                    return DatePicker( initTime: repeatEndDate == null ? endTime : repeatEndDate!,);
                                                  },
                                                );
                                                if(pickedDate != null){
                                                  setState((){
                                                    repeatEndDate = pickedDate!;
                                                  });}
                                                checkFormComplete();

                                              },

                                              child:
                                              repeatEndDate == null ? Row(
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
                                                          Text(DateFormat('MM월 dd일 E요일', 'ko_KR').format(repeatEndDate!), style: MainTheme.body8(MainTheme.gray7),),
                                                          Icon(Icons.keyboard_arrow_down_rounded, color: MainTheme.gray5,)
                                                        ],
                                                      )
                                                  )
                                                  )

                                                ],
                                              ),



                                            ),
                                            SizedBox(height: 12,),
                                            Container(alignment: Alignment.centerRight,
                                              child: GestureDetector(
                                                onTap: (){setState((){repeat = false;}); checkFormComplete();},
                                                child: Text("반복 닫기", style: MainTheme.body8(MainTheme.gray6),),
                                              ),
                                            )

                                          ],
                                        )
                                      ],
                                    ),
                                  )


                                  ) :

                                  Expanded(child:
                                  GestureDetector(
                                    behavior: HitTestBehavior.translucent,
                                    onTap: (){repeat= true; checkFormComplete();},
                                    child:Container(
                                      height: 51,
                                      decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.circular(12)
                                      ),
                                      padding: EdgeInsets.only(left: 16, right: 16),
                                      alignment: Alignment.centerLeft,
                                      child: Text("반복 등록", style: MainTheme.body5(MainTheme.gray4),),
                                    ) ,
                                  )

                                  )

                                ],
                              ),
                              Container(height: 19,),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  SvgPicture.asset("assets/icons/ic_24_recipe2.svg",width: 24, height: 24,),
                                  Container(width: 9,),
                                  Expanded(child:
                                  Container(
                                    height: 51,
                                    padding: EdgeInsets.symmetric(horizontal: 16),
                                    decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(12)
                                    ),
                                    child: DropdownButton<String>(
                                        borderRadius: BorderRadius.circular(10),
                                        isExpanded: true,
                                        dropdownColor: Colors.white,
                                        icon: Icon(Icons.keyboard_arrow_down_rounded, color: MainTheme.gray5,),
                                        hint: Text("일정구분", style: MainTheme.body5(MainTheme.gray4),),
                                        underline: SizedBox.shrink(),
                                        alignment: Alignment.centerLeft,
                                        value: planTypeValue,
                                        onChanged: (String? value) {
                                          // This is called when the user selects an item.
                                          setState(() {
                                            planTypeValue = value;
                                            checkFormComplete();
                                          });
                                        },
                                        items: [



                                          ...List.generate((profileIndex == (children.length-1)) ?planTypeParent.length : planType.length, (index) =>
                                              DropdownMenuItem<String>(
                                              child:

                                              Row(
                                              children: [
                                                SvgPicture.asset("assets/icons/${(profileIndex == (children.length-1)) ?planTypeParent[index]["value"] :planType[index]["value"]}.svg",width: 24, height: 24,),
                                                SizedBox(width : 6),
                                                Text(
                                                  (profileIndex == (children.length-1)) ?planTypeParent[index]["label"]! :planType[index]["label"]!,
                                                  style: MainTheme.body5(MainTheme.gray7),
                                                )

                                              ]

                                              )

                                              ,
                                              value: (profileIndex == (children.length-1)) ?planTypeParent[index]["value"] : planType[index]["value"]),)






                                        ]),
                                  )
                                  )

                                ],
                              ),
                              (planTypeValue??"PAY") == "ACADEMY" || (planTypeValue??"PAY") == "VEHICLE"?
                              Padding(
                                padding: EdgeInsets.only(top:8),
                                  child: 
                                  Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children : [
                                    Row(
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      children: [
                                        SizedBox(width:24, height : 24),
                                        Container(width: 9,),
                                        Expanded(child:
                                        _searchTextField()
                                        )

                                      ],
                                    ),
                                    academyMessage != null && _overlayEntry==null?
                                        Padding(padding: EdgeInsets.only(top : 5, left:33),
                                        child:  Text(academyMessage!, style: MainTheme.helper(Color(0xfff24147)),)
                                        ) : SizedBox.shrink()
                                  ]
                                  )

                              )
                              : SizedBox.shrink(),
                              (planTypeValue??"PAY") == "ACADEMY" || (planTypeValue??"PAY") == "SCHOOL"|| (planTypeValue??"PAY") == "CLASS"|| (planTypeValue??"PAY") == "VEHICLE" || (planTypeValue??"PAY") == "ETC"?
                              Padding(
                                  padding: EdgeInsets.only(top:8),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      SvgPicture.asset("assets/icons/info_green.svg", width: 14,height: 14,),
                                      Container(width: 4,),
                                      Text("${getLabel()} 일정은 주간시간표에만 표기돼요", style: MainTheme.caption2(MainTheme.subColor),)
                                    ],
                                  )
                              )
                                  : SizedBox.shrink(),
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
                                          if(planTypeValue != "ETC" && planTypeValue != "SCHEDULE" && value == (children.length-1)){
                                              planTypeValue = "ETC";

                                          }


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
                                    child: DropdownButton<String>(
                                        borderRadius: BorderRadius.circular(10),
                                        isExpanded: true,
                                        dropdownColor: Colors.white,
                                        icon: Icon(Icons.keyboard_arrow_down_rounded, color: MainTheme.gray5,),
                                        hint: Text("알림없음", style: MainTheme.body5(MainTheme.gray4),),
                                        underline: SizedBox.shrink(),
                                        alignment: Alignment.centerLeft,
                                        value: alarmIndex,
                                        onChanged: (String? value) {
                                          // This is called when the user selects an item.
                                          setState(() {
                                            alarmIndex = value == "" ? null :value;
                                          });
                                        },
                                        items: [
                                          ...List.generate(alarmType.length, (index) => DropdownMenuItem<String>(
                                              child: Text(
                                                alarmType[index]["label"]!,
                                                style: MainTheme.body5(MainTheme.gray7),
                                              ),
                                              value: alarmType[index]["value"]),)
                                        ]),
                                  )
                                  )

                                ],
                              ),
                              SizedBox(height: 18.5,),
                              !payment ?
                              GestureDetector(
                                behavior: HitTestBehavior.translucent,
                                onTap:(){
                                  payment = true;
                                  checkFormComplete();
                                },
                                child: Container(
                                  alignment: Alignment.center,
                                  child: Text(
                                    "결제일 추가", style: MainTheme.body4(MainTheme.gray5),
                                  ),
                                  width: 102,
                                  height: 42,
                                  decoration: BoxDecoration(
                                      border: Border.all(color: MainTheme.gray3, width: 1.5),
                                      borderRadius: BorderRadius.circular(24)
                                  ),

                                ),
                              ) : Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children : [
                                    Text("결제일",style: MainTheme.heading7(MainTheme.gray7),),
                                    SizedBox(height: 16,),
                                    Row(
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      children: [
                                        SvgPicture.asset("assets/icons/ic_16_clock.svg",width: 24, height: 24,),
                                        Container(width: 9,),
                                        Expanded(child:

                                        GestureDetector(
                                          behavior: HitTestBehavior.translucent,
                                          onTap: () async {
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
                                                      Text(DateFormat('MM월 dd일 E요일', 'ko_KR').format(payDate), style: MainTheme.body8(MainTheme.gray7),)
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
                                              value: payCycleIndex,
                                              onChanged: (String? value) {
                                                // This is called when the user selects an item.
                                                payCycleIndex = value;

                                                if(payCycleIndex == "NONE"){
                                                  payCycleEndDate = null;
                                                }
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

                                        if((payCycleIndex??"NONE") == "NONE"){

                                        }else{
                                          FocusManager.instance.primaryFocus?.unfocus();
                                          var pickedDate = await showModalBottomSheet<DateTime>(
                                            context: context,
                                            builder: (BuildContext context) {
                                              return DatePicker( initTime: DateTime.now(),);
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
                                              value: payAlarmIndex,
                                              onChanged: (bool? value) {
                                                // This is called when the user selects an item.
                                                setState(() {
                                                  payAlarmIndex = value!;
                                                });
                                              },
                                              items: [
                                                DropdownMenuItem<bool>(
                                                    child: Text(
                                                      "알림없음",
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
                                    SizedBox(height:12),
                                    Container(alignment: Alignment.centerRight,
                                      child: GestureDetector(
                                        onTap: (){
                                          payment = false;
                                          checkFormComplete();
                                        },
                                        child: Text("결제일 등록 취소", style: MainTheme.body8(MainTheme.gray6),),
                                      ),
                                    ),
                                    SizedBox(height: 100,),





                                  ]


                              ),

                              SizedBox(height: _overlayEntry != null ? 300 : 50,),


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


  void _showsearchOverlayFocus() {
    if (_overlayEntry == null) {
      _overlayEntry = _searchListOverlayEntry();
      setState(() {
        
      });
      Overlay.of(context)?.insert(_overlayEntry!);
      searchAcademy();
      checkFormComplete();
      _controller.animateTo(
        280 + (repeat ? repeatType == 0 ? 138 : 144 :0),
        duration: Duration(seconds: 1),
        curve: Curves.fastOutSlowIn,
      );
    }
  }

  Widget _searchTextField() {
    final _border = OutlineInputBorder(
      borderSide: BorderSide(
        color: (_searchFocusNode.hasFocus) ? Colors.black : Colors.grey,
      ),
      borderRadius: BorderRadius.circular(5),
    );

    void _showsearchOverlay() {
      // if (_searchFocusNode.hasFocus) {
      //   if (te_Academy.text.isNotEmpty) {
      //     final _search = te_Academy.text;
      //
      //     if (!_search.contains('@')) {
      //       if (_overlayEntry == null) {
      //         _overlayEntry = _searchListOverlayEntry();
      //         Overlay.of(context)?.insert(_overlayEntry!);
      //         _controller.animateTo(
      //           280 + (repeat ? repeatType == 0 ? 138 : 144 :0),
      //           duration: Duration(seconds: 1),
      //           curve: Curves.fastOutSlowIn,
      //         );
      //       }
      //     }
      //
      //     else {
      //       _removeSearchOverlay();
      //     }
      //   } else {
      //     _removeSearchOverlay();
      //   }
      // }
      searchAcademy();
      academyId = null;
      checkFormComplete();
    }



    return CompositedTransformTarget(
      link: _layerLink,
      child: Container(
        height: 51,
        child: TextField(
          controller: te_Academy,
          focusNode: _searchFocusNode,
          textInputAction: TextInputAction.next,
          textAlignVertical: TextAlignVertical.center,
          style: MainTheme.body5(MainTheme.gray7),
          onChanged: (_) => _showsearchOverlay(),
          decoration : InputDecoration(
            suffixIcon: GestureDetector(
                onTap: (){_showsearchOverlayFocus();},
                child: const Icon(Icons.search, color: MainTheme.gray4, size: 24,)
            ),
            contentPadding: const EdgeInsets.symmetric(
                horizontal: 16, vertical: 0),
            fillColor: Colors.white,
            filled: true,
            focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(12.0)),
                borderSide: BorderSide(color: MainTheme.mainColor)),
            enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(12.0)),
                borderSide: BorderSide(color: Colors.transparent)),
            border: InputBorder.none,
            hintText: "학원 검색",
            hintStyle: MainTheme.body6(MainTheme.gray4),
          ),
        ),
      ),
    );
  }

  // 학원 찾기
  OverlayEntry _searchListOverlayEntry() {
    return OverlayEntry(
      maintainState: true,
      builder: (context) =>
          StatefulBuilder(builder:
              (BuildContext context, StateSetter setState){
      return

          Positioned(
        width: MediaQuery.of(context).size.width - 64,
        height: 259,
        child: CompositedTransformFollower(
            link: _layerLink,
            showWhenUnlinked: false,
            offset: const Offset(0, 59),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(6),
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.15),
                    spreadRadius: 0,
                    blurRadius: 8,
                    offset: Offset(0, 0), // changes position of shadow
                  ),
                ],
              ),
              child: Column(
                children: [
                  Container(
                    width: double.infinity,
                    height: 105,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.only(topLeft: Radius.circular(6), topRight: Radius.circular(6)),
                      color: MainTheme.mainColor.withOpacity(0.1),
                    ),
                    child:
                    Column(
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(width: 20,),
                                Container(
                                  margin:EdgeInsets.only(top: 27),
                                  child: SvgPicture.asset('assets/icons/info.svg', width: 20, height: 20),
                                ),

                                SizedBox(width: 9,),
                                Container(
                                    margin:EdgeInsets.only(top: 22),
                                    child: Material(color: Colors.transparent, child: Text("찾으시는 학원이\n없나요?", style: MainTheme.body4(MainTheme.gray7),))
                                )

                              ],
                            ),
                            Container(
                              margin:const EdgeInsets.only(right: 20, top: 24),
                              width: 88,
                              height: 35,
                              child: ElevatedButton(
                                style: MainTheme.miniButton(MainTheme.mainColor),
                                onPressed: () async {
                                  final Map result = await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => RegisterAcademy(),
                                    ),
                                  );
                                  if(result != null){
                                    if(te_title.text == ""){
                                      te_title.text = result["academyName"];
                                    }
                                    academyId = result["academyId"];
                                    te_Academy.text = result["academyName"];
                                  }
                                  checkFormComplete();
                                },
                                child: Text(
                                  "직접 추가", style: MainTheme.caption1(Colors.white),
                                ),
                              ),
                            ),
                          ],
                        ),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(width: 49,),
                                Container(
                                    child: Material(color: Colors.transparent, child: Text("학원을 등록해 두시면 시간표 완성이 간편해요!", style: MainTheme.caption3(MainTheme.gray6),))
                                )

                              ],
                            ),
                          ],
                        ),
                      ],
                    )

                  ),
                  Expanded(child:
                  Container(
                    margin: EdgeInsets.only(right: 14),
                    child: RawScrollbar(
                      radius: Radius.circular(20),
                      thickness: 4,
                      thumbColor: MainTheme.gray3,

                      controller: academyScrollController,//여기도 전달
                      child: ListView.builder(
                          padding: EdgeInsets.only(top: 8, right: 7),
                          controller: academyScrollController,//여기도 전달
                          itemCount: academy.length,
                          itemBuilder: (context, index) =>

                          GestureDetector(
                            behavior: HitTestBehavior.translucent,
                            onTap: (){
                              if(te_title.text == ""){
                                te_title.text = academy[index]["academyName"];
                              }
                              te_Academy.text = academy[index]["academyName"] ;
                              academyId = academy[index]["id"];
                              _searchFocusNode.unfocus();
                              _removeSearchOverlay();
                              checkFormComplete();
                            },
                            child:Container(
                              margin: EdgeInsets.only(left: 14,right: 12),
                              height: 68,
                              padding: EdgeInsets.fromLTRB(6,11,6,11),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Material(color: Colors.transparent, child: Text(academy[index]["academyName"], style: MainTheme.body4(MainTheme.gray7),overflow: TextOverflow.ellipsis,)),
                                  Material(color: Colors.transparent, child: Text(academy[index]["address"], style: MainTheme.caption2(MainTheme.gray5),overflow: TextOverflow.ellipsis,))
                                ],
                              ),

                            )
                          )

                      ),
                    ),
                  )

                  )
                ],
              ),
            )
        ),
      );})
    );
  }
  // 드롭박스 해제.
  void _removeSearchOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
    setState(() {
      
    });
  }

  @override
  void dispose() {
    te_Academy.dispose();
    _overlayEntry?.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  void checkFormComplete(){

    setState(() {
      // if((planTypeValue == "ACADEMY" || planTypeValue == "VEHICLE") && !te_Academy.text.isEmpty && academyId == null){
      //   academyMessage = "목록에서 학원을 선택해 주세요.";
      // }else{
      //   academyMessage = null;
      // }
    });
  }

  void searchAcademy() async {
    index = 0;
    var response = await apiRequestGet(context, urlAcademy,{"page" : index.toString(), "keyword" : te_Academy.text, "sort" : ["academyName,ASC"]});
    var body =jsonDecode(utf8.decode(response.bodyBytes));
    if(response.statusCode == 200){
        academy = (body["data"]["content"]);
      _overlayEntry!.markNeedsBuild();

    }
  }

  void scroll() async {
    var response = await apiRequestGet(context, urlAcademy,{"page" : index.toString(), "keyword" : te_Academy.text,"sort" : ["academyName,ASC"]});
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
            "id" : child["id"]
          });
      }

      children.add({
        "name" : pref.getString("name"),
        "fileUrl" : pref.getString("profile"),
        "id" :  pref.getInt("userId")!
      });

      if(widget.childId != null){
        if(widget.childId != 0){
          for(int i = 0; i < children.length; i++){
            if(children[i]["id"] == widget.childId){

              profileIndex = i;
              break;
            }
          }
        }
      }

      if(widget.map != null){
        for(int i = 0; i < children.length; i++){
          if(children[i]["id"] == widget.map!["commonMemberId"]){
            profileIndex = i;
            break;
          }
        }
        planTypeValue = widget.map!["scheduleType"];
      } });
    }
  }
  void tryRegister(){

    // if(
    // te_title.text.isEmpty ||
    //     (repeat && repeatEndDate == null) ||
    //     (repeat && repeatType == 0 && !repeatDaysFlag[0] && !repeatDaysFlag[1]&& !repeatDaysFlag[2]&& !repeatDaysFlag[3]&& !repeatDaysFlag[4]&& !repeatDaysFlag[5]&& !repeatDaysFlag[6])||
    //     (repeat && repeatType == 1 && repeatCycleValue == null) ||
    //     planTypeValue == null ||
    //     (planTypeValue == "ACADEMY" && academyId == null) ||
    //     (planTypeValue == "VEHICLE" && academyId == null) ||
    //     (payment && (payDate == null || payCycleIndex == null || te_amount.text.isEmpty) ) ||
    //     (payment && (payCycleIndex??"NONE") != "NONE" && payCycleEndDate == null)
    // ){
    //   formComplete = false;
    // }else{
    //   formComplete = true;
    // }

    if(te_title.text.isEmpty){
      MainTheme.toast("제목을 입력해주세요.");
      return;
    }

    if(repeat && repeatEndDate == null){
      MainTheme.toast("종료일자를 설정해주세요.");
      return;
    }

    if(repeat && repeatType == 0 && !repeatDaysFlag[0] && !repeatDaysFlag[1]&& !repeatDaysFlag[2]&& !repeatDaysFlag[3]&& !repeatDaysFlag[4]&& !repeatDaysFlag[5]&& !repeatDaysFlag[6]){
      MainTheme.toast("반복요일을 설정해주세요.");
      return;
    }

    if(repeat && repeatType == 1 && repeatCycleValue == null){
      MainTheme.toast("반복주기를 설정해주세요.");
      return;
    }

    if(planTypeValue == null){
      MainTheme.toast("일정 구분을 선택해주세요.");
      return;
    }

    if(endTime.isBefore(startTime)){
      MainTheme.toast("종료시간이 시작시간보다 이전입니다.");
      return;
    }

    if(planTypeValue == "ACADEMY" && te_Academy.text.isEmpty){
      MainTheme.toast("학원명을 직접 입력하거나 목록에서 학원을 선택해주세요.");
      return;
    }
    if(planTypeValue == "VEHICLE" && te_Academy.text.isEmpty){
      MainTheme.toast("학원명을 직접 입력하거나  목록에서 학원을 선택해주세요.");
      return;
    }

    if(payment && payCycleIndex == null){
      MainTheme.toast("결제 주기를 설정해주세요.");
      return;
    }
    if(payment && te_amount.text.isEmpty){
      MainTheme.toast("결제 금액을 입력해주세요.");
      return;
    }
    if(payment && (payCycleIndex??"NONE") != "NONE" && payCycleEndDate == null){
      MainTheme.toast("결제 주기 종료일자를 설정해주세요.");
      return;
    }
    // if(DateUtils.isSameDay(startTime, endTime) && startTime.hour == endTime.hour && startTime.minute == endTime.minute){
    //   MainTheme.toast("시작시간과 종료시간이 같습니다.");
    //   return;
    // }
    // if(widget.map == null){
    //   if(profileIndex == (children.length-1) && (planTypeValue == "ACADEMY" || planTypeValue == "SCHOOL" || planTypeValue == "CLASS" || planTypeValue == "VEHICLE" )){
    //     MainTheme.toast("부모는 학교, 학원 관련 일정을 등록할 수 없어요.");
    //     return;
    //   }
    // }

    if(repeat){
      if(endTime.isAfter(repeatEndDate!)){
        MainTheme.toast("반복 종료일을 일정종료일 이후로 설정해주세요.");
        return;
      }
    }

    if(payment){
      if((payCycleIndex??"NONE") != "NONE"){
        if(payDate.isAfter(payCycleEndDate!)){
          MainTheme.toast("결제 주기 종료일을 결제일 이후로 설정해주세요.");
          return;
        }
      }
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
    request["startDate"] = DateFormat('yyyy-MM-dd').format(startTime);
    request["startTime"] =  DateFormat('HH:mm:ss').format(startTime);
    request["endDate"] = DateFormat('yyyy-MM-dd').format(endTime);
    request["endTime"] =  DateFormat('HH:mm:ss').format(endTime);
    request["isAllDay"] = onday;
    request["scheduleType"] = planTypeValue;
    if((planTypeValue == "ACADEMY" || planTypeValue == "VEHICLE") && academyId != null){
      request["academyId"] = academyId;
    }
    request["academyName"] = te_Academy.text;

    request["color"] = colorIndex.toString();
    request["memo"] = te_note.text;
    request["cycleType"] = !repeat ? "NONE" : (repeatType == 0 ? "DAY" : "PERIOD");
    request["cycleDays"] = getDayStr();
    request["calendarCycle"] = !repeat ? "NONE" : repeatCycleValue;
    request["cycleEndDate"] = (repeatEndDate == null ? null :DateFormat('yyyy-MM-dd').format(repeatEndDate!));


    request["usePay"] = payment;
    request["payDate"] = payDate == null ?null :DateFormat('yyyy-MM-dd').format(payDate);
    request["payCycle"] = payCycleIndex ?? "NONE";
    request["payCycleEndDate"] = payCycleEndDate == null ? null : DateFormat('yyyy-MM-dd').format(payCycleEndDate!);
    request["amount"] = te_amount.text.isEmpty ? null : int.parse(te_amount.text.replaceAll(",", "").replaceAll("원", ""));

    request["scheduleAlarmType"] = (alarmIndex??"") == "" ? "NONE" : alarmIndex;
    request["usePaymentAlarm"] = payAlarmIndex;

    var response;
    var body;
    if(widget.map == null){
      response = await apiRequestPost(context, urlRegister,request);
      body =jsonDecode(utf8.decode(response.bodyBytes));
    }else{
      response = await apiRequestPut(context, urlUpdate +  "/" +  widget.map!["id"].toString(), request);
      body =jsonDecode(utf8.decode(response.bodyBytes));
    }

    if(response.statusCode == 200){
      if(response.statusCode == 200){
        if(widget.map == null){
          Navigator.pop(context, {"id" : body["data"], "index" :profileIndex});
        }else{
          Navigator.pop(context);
        }
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

  String getLabel() {
    for(Map map in planType){
      if(map["value"] == planTypeValue){
        return map["label"];
      }
    }
    return "";
  }
}









