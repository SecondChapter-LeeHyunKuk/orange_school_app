
import 'dart:convert';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';
import 'package:orange_school/style/register_payment.dart';
import 'package:orange_school/style/register_plan.dart';
import 'package:orange_school/style/time_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../util/api.dart';
import 'alert.dart';
import 'date_picker.dart';
import 'main-theme.dart';
String urlGet = "${dotenv.env['BASE_URL']}user/schedule";
String urlChildren = "${dotenv.env['BASE_URL']}user/commonMembers";
String urlDelete = "${dotenv.env['BASE_URL']}user/calendar";
String urlDeleteAll = "${dotenv.env['BASE_URL']}user/schedule";
class ScheduleInfoChild extends StatefulWidget {
  final int scheduleId;
  final int calendarId;
  const ScheduleInfoChild ({ Key? key, required this.scheduleId , required this.calendarId }): super(key: key);
  @override
  _ScheduleInfoChild createState() => _ScheduleInfoChild();
}

class _ScheduleInfoChild extends State<ScheduleInfoChild> {

  bool editMode = false;
  List repeatDays = ["월", "화", "수", "목", "금", "토", "일"];
  List daysTitles = ["월요일", "화요일", "수요일", "목요일", "금요일", "토요일", "일요일"];
  OverlayEntry? _overlayEntry;
  var repeatEndDate;
  var date = DateTime.now();
  var repeat = false;
  var colorIndex = 0;
  int? selectIndex;
  List children = [];
  Map map = {};
  Future<Response>? getFuture;

  @override
  void initState() {
    super.initState();
    getFuture = get();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
        alignment: Alignment.center,
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
                Container(height: 62,
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


                FutureBuilder(
                    future: getFuture,
                    builder: (BuildContext context, AsyncSnapshot snapshot){
                      if (snapshot.hasData == false){
                        return MainTheme.LoadingPage(context);
                      }else if(snapshot.data.statusCode == 200){
                        return SingleChildScrollView(
                            scrollDirection: Axis.vertical,
                            padding: EdgeInsets.only(
                                bottom: MediaQuery.of(context).viewInsets.bottom),
                            child:
                            Container(
                              child:Column(

                                children: [
                                  Container(height: 60,
                                      alignment: Alignment.topCenter,
                                      child: Row(
                                        crossAxisAlignment: CrossAxisAlignment.center,

                                        children: [
                                          Container(
                                              margin: EdgeInsets.only(left: 3),
                                              alignment: Alignment.center,
                                              width: 36, height:36,
                                              decoration: BoxDecoration(

                                                  shape: BoxShape.circle,
                                                  color: Colors.white
                                              ),
                                              child:ClipRRect(
                                                borderRadius: BorderRadius.circular(300.0),
                                                child: CachedNetworkImage(imageUrl:
                                                    map["fileUrl"] ?? "",
                                                    width : 30,
                                                    height: 30,
                                                    fit: BoxFit.cover,
                                                  errorWidget: (context, url, error) {
                                                    return SvgPicture.asset("assets/icons/profile_${(map["commonMemberId"]%3) + 1}.svg",width: 57, height: 57, );
                                                  },
                                                ),)
                                          ),
                                          SizedBox(width: 11,),
                                          GestureDetector(
                                            behavior: HitTestBehavior.translucent,
                                            onTap: (){setState(() {
                                              editMode = true;
                                            });},
                                            child: Container(
                                          child: Text(map["title"], style: MainTheme.heading3(MainTheme.gray7),),
                                            ),
                                          ),
                                        ],
                                      )
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
                                              !map["isAllDay"] ? Container(width: 192,
                                                child: Row(
                                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                  crossAxisAlignment: CrossAxisAlignment.center,
                                                  children: [
                                                    GestureDetector(
                                                      behavior: HitTestBehavior.translucent,
                                                      onTap: () async {
                                                        setState(() {
                                                          editMode = true;
                                                        });
                                                      },

                                                      child:
                                                      Container(
                                                        width: 79,
                                                        child:Column(
                                                          mainAxisAlignment: MainAxisAlignment.center,
                                                          crossAxisAlignment: CrossAxisAlignment.center,
                                                          children: [
                                                            Text(DateFormat("MM월 dd일 E", 'ko_KR').format(DateTime.parse(map["startDate"])), style: MainTheme.body9(MainTheme.gray7),),
                                                            map["startTime"] == null ? SizedBox.shrink() : Text(DateFormat("aa hh:mm", 'ko_KR').format(DateTime.parse(map["startDate"] + " " + map["startTime"])), style:TextStyle(fontWeight: FontWeight.w800, fontFamily: "SUIT", fontSize: 16, color: MainTheme.gray7, letterSpacing: 0))
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
                                                        setState(() {
                                                          editMode = true;
                                                        });
                                                      },

                                                      child:
                                                      Container(
                                                        width: 79,
                                                        child:Column(
                                                          mainAxisAlignment: MainAxisAlignment.center,
                                                          crossAxisAlignment: CrossAxisAlignment.center,
                                                          children: [
                                                            Text(DateFormat("MM월 dd일 E", 'ko_KR').format(DateTime.parse(map["endDate"])), style: MainTheme.body9(MainTheme.gray7),),
                                                            map["endTime"] == null ? SizedBox.shrink() :Text(DateFormat("aa hh:mm", 'ko_KR').format(DateTime.parse(map["endDate"] + " " + map["endTime"])), style:TextStyle(fontWeight: FontWeight.w800, fontFamily: "SUIT", fontSize: 16, color: MainTheme.gray7, letterSpacing: 0))
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
                                                        setState(() {
                                                          editMode = true;
                                                        });
                                                      },

                                                      child:
                                                      Container(
                                                        width: 79,
                                                        child:Column(
                                                          mainAxisAlignment: MainAxisAlignment.center,
                                                          crossAxisAlignment: CrossAxisAlignment.center,
                                                          children: [
                                                            Text(DateFormat("MM월 dd일 E", 'ko_KR').format(DateTime.parse(map["startDate"])), style: MainTheme.body9(MainTheme.gray7),),
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
                                                        setState(() {
                                                          editMode = true;
                                                        });
                                                      },

                                                      child:
                                                      Container(
                                                        width: 79,
                                                        child:Column(
                                                          mainAxisAlignment: MainAxisAlignment.center,
                                                          crossAxisAlignment: CrossAxisAlignment.center,
                                                          children: [
                                                            Text(DateFormat("MM월 dd일 E", 'ko_KR').format(DateTime.parse(map["endDate"])), style: MainTheme.body9(MainTheme.gray7),),
                                                          ],
                                                        ),
                                                      ),),
                                                  ],

                                                ),
                                              ),
                                              map["isAllDay"] ?
                                              Container(
                                                width: 60,
                                                height: 30,
                                                decoration: BoxDecoration(
                                                  color: MainTheme.subColor.withOpacity(0.1),
                                                  borderRadius: BorderRadius.circular(4),
                                                ),
                                                alignment: Alignment.center,
                                                child: Text("하루종일", style: MainTheme.caption2(MainTheme.subColor),),

                                              ) : SizedBox.shrink()

                                            ],
                                          )
                                      )
                                      )

                                    ],
                                  ),
                                  SizedBox(height: 19,),

                                  (map["cycleType"]??"NONE") == "NONE" ?
                                  Row(
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      SvgPicture.asset("assets/icons/ic_24_rotate.svg",width: 24, height: 24,),
                                      Container(width: 9,),
                                      Expanded(child:
                                      GestureDetector(
                                          behavior: HitTestBehavior.translucent,
                                          onTap: (){setState(() {
                                            editMode = true;
                                          });},
                                          child:
                                          Container(
                                              alignment: Alignment.centerLeft,
                                              height: 51,
                                              decoration: BoxDecoration(
                                                  color: Colors.white,
                                                  borderRadius: BorderRadius.circular(12)
                                              ),
                                              padding: EdgeInsets.symmetric(horizontal: 16),
                                              child: Text(
                                                "반복 없음", style: MainTheme.body5(MainTheme.gray7),
                                              )
                                          ))
                                      )

                                    ],
                                  ):
                                  Row(
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      SvgPicture.asset("assets/icons/ic_24_rotate.svg",width: 24, height: 24,),
                                      Container(width: 9,),
                                      Expanded(child:
                                      GestureDetector(
                                          behavior: HitTestBehavior.translucent,
                                          onTap: (){setState(() {
                                            editMode = true;
                                          });},
                                          child:
                                          Container(
                                              height: 73,
                                              decoration: BoxDecoration(
                                                  color: Colors.white,
                                                  borderRadius: BorderRadius.circular(12)
                                              ),
                                              padding: EdgeInsets.symmetric(horizontal: 16),
                                              child: Column(
                                                mainAxisAlignment: MainAxisAlignment.center,
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [

                                                  map["cycleType"] != "PERIOD" ?
                                                  Text("반복 " + getDays(map["cycleDays"]), style: MainTheme.body5(MainTheme.gray7),) :
                                                  Text("반복 " + map["calendarCycleTitle"], style: MainTheme.body5(MainTheme.gray7),)
                                                  ,
                                                  Text(map["cycleEndDate"] == null ? "" : "종료일 ${DateFormat("MM월 dd일", 'ko_KR').format(DateTime.parse(map["cycleEndDate"]))}", style: MainTheme.body5(MainTheme.gray5),),
                                                ],

                                              )
                                          ))
                                      )

                                    ],
                                  ),
                                  SizedBox(height: 19,),

                                  Row(
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      SvgPicture.asset("assets/icons/ic_24_recipe2.svg",width: 24, height: 24,),
                                      Container(width: 9,),
                                      Expanded(child:
                                      GestureDetector(
                                          behavior: HitTestBehavior.translucent,
                                          onTap: (){setState(() {
                                            editMode = true;
                                          });},
                                          child:
                                          Container(
                                              alignment: Alignment.centerLeft,
                                              height: 51,
                                              decoration: BoxDecoration(
                                                  color: Colors.white,
                                                  borderRadius: BorderRadius.circular(12)
                                              ),
                                              padding: EdgeInsets.symmetric(horizontal: 16),
                                              child: Text(map["scheduleTypeTitle"], style: MainTheme.body8(MainTheme.gray7),)
                                          ))
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
                                      GestureDetector(
                                          behavior: HitTestBehavior.translucent,
                                          onTap: (){setState(() {
                                            editMode = true;
                                          });},
                                          child:
                                          Container(
                                              alignment: Alignment.centerLeft,
                                              height: 51,
                                              decoration: BoxDecoration(
                                                  color: Colors.white,
                                                  borderRadius: BorderRadius.circular(12)
                                              ),
                                              padding: EdgeInsets.symmetric(horizontal: 16),
                                              child: Text(
                                                map["commonMemberName"], style: MainTheme.body5(MainTheme.gray7),
                                              )
                                          ))
                                      )

                                    ],
                                  ),
                                  SizedBox(height: 19,),
                                  Row(
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      SvgPicture.asset("assets/icons/ic_24_story.svg",width: 24, height: 24,),
                                      Container(width: 9,),
                                      Expanded(child:
                                      GestureDetector(
                                          behavior: HitTestBehavior.translucent,
                                          onTap: (){setState(() {
                                            editMode = true;
                                          });},
                                          child:
                                          Container(
                                              alignment: Alignment.centerLeft,
                                              height: 51,
                                              decoration: BoxDecoration(
                                                  color: Colors.white,
                                                  borderRadius: BorderRadius.circular(12)
                                              ),
                                              padding: EdgeInsets.symmetric(horizontal: 16),
                                              child: Text(
                                                map["memo"] == "" ?  "메모 없음" : map["memo"], style: MainTheme.body5(MainTheme.gray7),
                                              )
                                          ))
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
                                      GestureDetector(
                                          behavior: HitTestBehavior.translucent,
                                          onTap: (){setState(() {
                                            editMode = true;
                                          });},
                                          child:
                                          Container(
                                              alignment: Alignment.centerLeft,
                                              height: 51,
                                              decoration: BoxDecoration(
                                                  color: Colors.white,
                                                  borderRadius: BorderRadius.circular(12)
                                              ),
                                              padding: EdgeInsets.symmetric(horizontal: 16),
                                              child: Text(
                                                (map["scheduleAlarmTypeTitle"]??"") == "" ? "알림 없음" : map["scheduleAlarmTypeTitle"], style: MainTheme.body5(MainTheme.gray7),
                                              )
                                          ))
                                      )

                                    ],
                                  ),

                                  SizedBox(height: 19,),


                                  map["usePay"] ?
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          SizedBox(height: 21,),
                                          Text("결제일", style : MainTheme.heading7(MainTheme.gray7)),
                                          Container(height: 19,),
                                          Row(
                                            crossAxisAlignment: CrossAxisAlignment.center,
                                            children: [
                                              SvgPicture.asset("assets/icons/ic_16_clock.svg",width: 24, height: 24,),
                                              Container(width: 9,),
                                              Expanded(child:
                                              GestureDetector(
                                                  behavior: HitTestBehavior.translucent,
                                                  onTap: (){setState(() {
                                                    editMode = true;
                                                  });},
                                                  child:
                                                  Container(
                                                      alignment: Alignment.centerLeft,
                                                      height: 51,
                                                      decoration: BoxDecoration(
                                                          color: Colors.white,
                                                          borderRadius: BorderRadius.circular(12)
                                                      ),
                                                      padding: EdgeInsets.symmetric(horizontal: 16),
                                                      child: Text(DateFormat("MM월 dd일 E", 'ko_KR').format(DateTime.parse(map["payDate"])), style: MainTheme.body8(MainTheme.gray7),)
                                                  ))
                                              )

                                            ],
                                          ),
                                          Container(height: 19,),

                                          map["payCycle"] == "NONE" ?
                                          Row(
                                            crossAxisAlignment: CrossAxisAlignment.center,
                                            children: [
                                              SvgPicture.asset("assets/icons/ic_24_rotate.svg",width: 24, height: 24,),
                                              Container(width: 9,),
                                              Expanded(child:
                                              GestureDetector(
                                                  behavior: HitTestBehavior.translucent,
                                                  onTap: (){setState(() {
                                                    editMode = true;
                                                  });},
                                                  child:
                                                  Container(
                                                      alignment: Alignment.centerLeft,
                                                      height: 51,
                                                      decoration: BoxDecoration(
                                                          color: Colors.white,
                                                          borderRadius: BorderRadius.circular(12)
                                                      ),
                                                      padding: EdgeInsets.symmetric(horizontal: 16),
                                                      child: Text(
                                                        "반복 없음", style: MainTheme.body5(MainTheme.gray7),
                                                      )
                                                  ))
                                              )

                                            ],
                                          ):
                                          Row(
                                            crossAxisAlignment: CrossAxisAlignment.center,
                                            children: [
                                              SvgPicture.asset("assets/icons/ic_24_rotate.svg",width: 24, height: 24,),
                                              Container(width: 9,),
                                              Expanded(child:
                                              GestureDetector(
                                                  behavior: HitTestBehavior.translucent,
                                                  onTap: (){setState(() {
                                                    editMode = true;
                                                  });},
                                                  child:
                                                  Container(
                                                      height: 73,
                                                      decoration: BoxDecoration(
                                                          color: Colors.white,
                                                          borderRadius: BorderRadius.circular(12)
                                                      ),
                                                      padding: EdgeInsets.symmetric(horizontal: 16),
                                                      child: Column(
                                                        mainAxisAlignment: MainAxisAlignment.center,
                                                        crossAxisAlignment: CrossAxisAlignment.start,
                                                        children: [
                                                          Text(map["payCycleTitle"] == "1개월" ? "매월" : map["payCycleTitle"], style: MainTheme.body5(MainTheme.gray7),),
                                                          Text(map["payCycleEndDate"] == null ? "" : "종료일 ${DateFormat("MM월 dd일", 'ko_KR').format(DateTime.parse(map["payCycleEndDate"]))}", style: MainTheme.body5(MainTheme.gray5),),
                                                        ],

                                                      )
                                                  ))
                                              )

                                            ],
                                          ),
                                          Container(height: 19,),

                                          Row(
                                            crossAxisAlignment: CrossAxisAlignment.center,
                                            children: [
                                              SvgPicture.asset("assets/icons/ic_24_money.svg",width: 24, height: 24,),
                                              Container(width: 9,),
                                              Expanded(child:
                                              GestureDetector(
                                                  behavior: HitTestBehavior.translucent,
                                                  onTap: (){setState(() {
                                                    editMode = true;
                                                  });},
                                                  child:
                                                  Container(
                                                      alignment: Alignment.centerLeft,
                                                      height: 51,
                                                      decoration: BoxDecoration(
                                                          color: Colors.white,
                                                          borderRadius: BorderRadius.circular(12)
                                                      ),
                                                      padding: EdgeInsets.symmetric(horizontal: 16),
                                                      child: Text(
                                                        map["amount"] == null ? "" : "${NumberFormat('###,###,###,###').format( map["amount"])}원", style: MainTheme.body5(MainTheme.gray7),
                                                      )
                                                  ))
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
                                              GestureDetector(
                                                  behavior: HitTestBehavior.translucent,
                                                  onTap: (){setState(() {
                                                    editMode = true;
                                                  });},
                                                  child:
                                                  Container(
                                                      alignment: Alignment.centerLeft,
                                                      height: 51,
                                                      decoration: BoxDecoration(
                                                          color: Colors.white,
                                                          borderRadius: BorderRadius.circular(12)
                                                      ),
                                                      padding: EdgeInsets.symmetric(horizontal: 16),
                                                      child: Text(
                                                        map["usePaymentAlarm"] ? "당일오전9시" : "알림 없음", style: MainTheme.body5(MainTheme.gray7),
                                                      )
                                                  ))
                                              )

                                            ],
                                          ),

                                          SizedBox(height: 19,),
                                        ],
                                      ) : SizedBox.shrink(),




                                ],
                              ),
                            )



                        );
                      }else{
                        return MainTheme.ErrorPage(context, jsonDecode(utf8.decode(snapshot.data.bodyBytes))["message"]);
                      }
                    }
                )




                )
              ],
            )


            ,

          ),
        ]);
  }

  OverlayEntry deleteOption(){

    return OverlayEntry(
      builder: (context) => SizedBox(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        child: Stack(
          children: [
            ModalBarrier(
              onDismiss: () {
                _removeOverlay();
              },
            ),
            Positioned(
              bottom: 81,
                left: MediaQuery.of(context).size.width/2 -67.5,
              child: Material(color: Colors.transparent,child: Container(
                width: 135,
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
                padding: EdgeInsets.fromLTRB(14,10,14,10),
                child: IntrinsicHeight(
                  child: Column(
                    children: [
                      widget.calendarId != 0?

                      GestureDetector(
                        onTap: (){
                          _removeOverlay();
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return Alert(title: "삭제하시겠어요?");
                            },
                          )
                              .then((val) {
                            if (val != null) {
                              if(val){
                                delete();
                              }
                            }
                          });

                          },
                        child: Container(
                          width: double.infinity,
                          padding: EdgeInsets.symmetric(vertical: 4),
                          alignment: Alignment.center,
                          child: Text(
                            "이 일정만 삭제", style: MainTheme.body5(MainTheme.gray7),
                          ),
                        ),
                      ) : SizedBox.shrink(),
                      widget.calendarId != 0?
                      SizedBox(height: 8,) : SizedBox.shrink(),
                      // Padding(padding: EdgeInsets.fromLTRB(6,4,6,4),
                      // child: Row(
                      //   crossAxisAlignment: CrossAxisAlignment.center,
                      //   children: [
                      //     const SizedBox(height: 6,),
                      //     ClipRRect(
                      //       borderRadius: BorderRadius.circular(300.0),
                      //       child:
                      //       Image(
                      //           image: AssetImage("assets/images/port.jpg", ),
                      //           width : 24,
                      //           height: 24,
                      //           fit: BoxFit.cover
                      //       ),
                      //
                      //     ),
                      //     const SizedBox(width: 6,),
                      //     Expanded(child:
                      //     Material( color: Colors.transparent, child: Text("나", style: MainTheme.body5(MainTheme.gray7),overflow: TextOverflow.ellipsis,))
                      //     )
                      //
                      //   ],
                      // ),
                      // ),


                      SizedBox(height: 6,) ,
                      GestureDetector(
                        onTap: (){
                          _removeOverlay();
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return Alert(title: "이후 일정을 모두 삭제하시겠어요?");
                            },
                          )
                              .then((val) {
                            if (val != null) {
                              if(val){
                                deleteAll();
                              }
                            }
                          });
                          },
                        child: Container(
                          width: double.infinity,
                          padding: EdgeInsets.symmetric(vertical: 4),
                          alignment: Alignment.center,
                          child: Text(
                            "이후 일정 삭제", style: MainTheme.body5(MainTheme.gray7),
                          ),
                        ),
                      ) ,
                      // SizedBox(height: 8,),
                      // Padding(padding: EdgeInsets.fromLTRB(6,4,6,4),
                      //   child: Row(
                      //     crossAxisAlignment: CrossAxisAlignment.center,
                      //     children: [
                      //       const SizedBox(height: 6,),
                      //       ClipRRect(
                      //         borderRadius: BorderRadius.circular(300.0),
                      //         child:
                      //         Image(
                      //             image: AssetImage("assets/images/port.jpg", ),
                      //             width : 24,
                      //             height: 24,
                      //             fit: BoxFit.cover
                      //         ),
                      //
                      //       ),
                      //       const SizedBox(width: 6,),
                      //       Expanded(child:
                      //       Material( color: Colors.transparent, child: Text("나", style: MainTheme.body5(MainTheme.gray7),overflow: TextOverflow.ellipsis,))
                      //       )
                      //
                      //     ],
                      //   ),
                      // ),
                    ],
                  ),
                ),
              ),)
            ),
          ],
        ),
      ),
    );
  }
  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  @override
  void dispose() {
    _overlayEntry?.remove();
    _overlayEntry?.dispose();
    super.dispose();
  }

  Future<Response> get() async {
    var response = await apiRequestGet(urlGet + "/" + widget.scheduleId.toString(),{});
    var body =jsonDecode(utf8.decode(response.bodyBytes));
    if(response.statusCode == 200){
      map = body["data"];
    }
    return response;
  }
  Future<void> getChildren() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    children[0]["name"] = pref.getString("name");
    children[0]["fileUrl"] = pref.getString("profile");
    children[0]["id"] = pref.getInt("userId")!;

    var response = await apiRequestGet(urlChildren,  {});
    var body =jsonDecode(utf8.decode(response.bodyBytes));

    if(response.statusCode == 200){
      for(var child in body["data"]){
        setState(() {
          children.add({
            "name" : child["name"],
            "fileUrl" : child["fileUrl"],
            "id" : child["id"],
            "profile" : null
          });
        });

      }
    }


  }

  
  String getDays(String arg){
    for(int i = 0; i < 7; i++){
      arg = arg.replaceAll((i+1).toString(), repeatDays[i]);
    }
    return arg;
  }
  Future<void> delete() async {
    _removeOverlay();
    var response = await apiRequestDelete(urlDelete + "/" + widget.calendarId.toString(), {});
    if(response.statusCode == 200){
      Fluttertoast.showToast(
          msg: "삭제되었습니다.",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.black,
          textColor: Colors.white,
          fontSize: 16.0
      );
      Navigator.of(context).pop();
    }
  }

  Future<void> deleteAll() async {
    _removeOverlay();
    var response = await apiRequestDelete(urlDeleteAll + "/" + widget.scheduleId.toString(), {});
    if(response.statusCode == 200){
      Fluttertoast.showToast(
          msg: "삭제되었습니다.",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.black,
          textColor: Colors.white,
          fontSize: 16.0
      );
      Navigator.of(context).pop();
    }
  }

}

