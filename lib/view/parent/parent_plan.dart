import 'dart:convert';
import 'dart:developer' as dev;
import 'dart:math';
import 'dart:ui';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_svg/svg.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:orange_school/style/main-theme.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:flutter/foundation.dart' as foundation;
import 'package:orange_school/style/month_picker.dart';
import 'package:orange_school/style/register_plan.dart';
import 'package:orange_school/style/schedule_info.dart';
import 'package:orange_school/util/api.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:simple_shadow/simple_shadow.dart';
import 'package:speech_balloon/speech_balloon.dart';

import '../../style/academy-field.dart';
import '../../style/date_picker.dart';
import '../../style/time_picker.dart';
import '../../style/time_table.dart';

String weatherKey = "${dotenv.env['WEATHER_KEY']}";
String urlChildren = "${dotenv.env['BASE_URL']}user/commonMembers";
String urlMonthly = "${dotenv.env['BASE_URL']}user/month/calendars";
String urlDaily = "${dotenv.env['BASE_URL']}user/day/calendars";
String urlWeek = "${dotenv.env['BASE_URL']}user/week/calendars";
String urlWeekSchedule = "${dotenv.env['BASE_URL']}user/week/schedules";
class ParentPlan extends StatefulWidget {
  @override
  State<ParentPlan> createState() => _ParentPlan();
}

class _ParentPlan extends State<ParentPlan> {
  List days = ["일", "월", "화", "수", "목", "금", "토"];
  List dates = [];
  List weeks = List.empty(growable: true);

  //종일 일정
  List onDaySchedules = [
  ];

  //자식 선택
  List children = [
    {"name" : "", "fileUrl" : "", "id" : 0},
  ];

  //선택한 자식
  int selectedChildIndex = 0;

  //일자 선택
  DateTime selectDay = DateTime.now();

  //월간, 주간 인덱스
  int screenIndex = 1;
  int activeIndex = 0;

  bool school = false;
  late DateTime sunday;
  late TextEditingController te_Academy;
  OverlayEntry? _overlayEntry;
  final LayerLink _layerLink = LayerLink();

  bool repeat = false;
  int repeatType = 0;
  Map? weather = null;

  Map monthSchedule = {};
  List daySchedule = [];
  List weekList = [];
  List monthChildren = [{}];
  List weekChildren = [{}];

  @override
  void initState() {
    super.initState();
    initializeDateFormatting();

    if(selectDay.weekday != 7){
      selectDay = selectDay.subtract(Duration(days: selectDay.weekday));
    }

    //오늘날짜
    var now = new DateTime.now();
    //이번달 1일
    var firstDay = DateTime(now.year, now.month, 1);
    //이번달 마지막 날
    var lastDay = DateTime(now.year, now.month+1, 0);


    if(firstDay.weekday != 7){
      //이번달 1일이 일요일이 아니면 저번달 일을 추가함
      var previousLastDay = DateTime(now.year, now.month, 0);
      for(int i = (firstDay.weekday -1); i >= 0; i--){
        dates.add({"today":DateUtils.isSameDay(previousLastDay.subtract(Duration(days: i)), now), "day":previousLastDay.subtract(Duration(days: i)), "previous": 1, "schedule":[]});
      }
    }
    //이번달 1일부터 마지막날까지 추가
    for(int i = 1; i <= lastDay.day; i++){
      dates.add({"today":DateUtils.isSameDay(firstDay.add(Duration(days: i-1)), now), "day":firstDay.add(Duration(days: i-1)), "previous": 0, "schedule":[]});
    }
    if(lastDay.weekday != 6){
      //이번달 마지막 날이 토요일이 아니면 다음달 일을 추가함
      var nextFirstDay = lastDay.add(Duration(days: 1));

      for(int i = 0; i < (lastDay.weekday == 7 ? 6 : (6-lastDay.weekday)) ; i++){
        dates.add({"today":DateUtils.isSameDay(nextFirstDay.add(Duration(days: i)), now),"day":nextFirstDay.add(Duration(days: i)), "previous": -1, "schedule":[]});
      }
    }
    sunday = now.weekday == 7 ? now : now.subtract(Duration(days: now.weekday));
    DateTime start = sunday.subtract(const Duration(days: 7));

    for(int i = 0 ;  i < 3 ; i++){
      List week = List.empty(growable: true);
      for(int j = 0; j <7; j++){
        week.add({"date":start.add(Duration(days: ((i * 7) + j)))});
      }
      weeks.add(week);
    }

    getWeather();
    getChildren();
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(statusBarColor:MainTheme.backgroundGray, statusBarIconBrightness: Brightness.dark));
    double blockWidth = (MediaQuery.of(context).size.width-32) / 7.0; //달력 한칸 가로 길이
    double weekWidth =  MediaQuery.of(context).size.width-32 - 42;
    double dayWidth = (weekWidth)/7.0;
    return Scaffold(
        extendBody: true,
        backgroundColor: MainTheme.backgroundGray,
        resizeToAvoidBottomInset: true,
        body: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Column(

          children: [
            SizedBox(
              height: MediaQuery.of(context).viewPadding.top,
            ),
          const SizedBox(height: 13,),
          Stack(
            children: [
              Container(
                child:
                Row(

                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [

                    GestureDetector(
                      behavior: HitTestBehavior.translucent,
                      onTap:(){
                        if (_overlayEntry == null) {
                          _overlayEntry = selectChild();
                          Overlay.of(context)?.insert(_overlayEntry!);
                        }

                      },
                      child:
                      CompositedTransformTarget(
                        link: _layerLink,
                        child: Container(
                          child: IntrinsicWidth(
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Container(
                                  alignment: Alignment.center,
                                  width: 36,
                                  height: 36,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    shape: BoxShape.circle,
                                  ),
                                  child:
                                  ClipRRect(
                                      borderRadius: BorderRadius.circular(300.0),
                                      child:
                                      Image.network(
                                         children[selectedChildIndex]["fileUrl"] ?? "",
                                          width : 30,
                                          height: 30,
                                          fit: BoxFit.cover,
                                          errorBuilder: (BuildContext context, Object exception, StackTrace? stackTrace) {
                                            return SvgPicture.asset("assets/icons/profile_${children[selectedChildIndex]["id"]%3 + 1}.svg",width: 30, height: 30, );
                                          },
                                      )
                                  )
                                  ,
                                ),
                                Container(width: 8,),
                            ConstrainedBox(
                              constraints: BoxConstraints(
                                maxWidth: 80,
                              ),
                              child: Text(children[selectedChildIndex]["name"], style: MainTheme.caption1(MainTheme.gray7),overflow: TextOverflow.ellipsis,),
                            )



                              ],
                            ),

                          ),
                        ),
                      )


                    ),

                    GestureDetector(
                        behavior: HitTestBehavior.translucent,
                        onTap: (){

                          if(screenIndex == 1){
                            children = monthChildren;
                            selectedChildIndex++;

                            DateTime today = DateTime.now();
                            if(!DateTime(selectDay.year, selectDay.month, selectDay.day).isAfter(DateTime(
                                today.year, today.month, today.day
                            ))){
                              if(DateTime(today.year, today.month, today.day).difference(DateTime(
                                  selectDay.year, selectDay.month, selectDay.day
                              )).inDays <= 6){
                                selectDay = DateTime.now();
                              }

                            }

                            changeMonth();
                            getMonthly();
                            getDaily();
                            setState(() {
                              screenIndex = 0;
                            });
                          }else{
                            children = weekChildren;
                            if(selectedChildIndex == 0 || selectedChildIndex == monthChildren.length-1){
                              selectedChildIndex = 0;
                            }else{
                              selectedChildIndex--;
                            }

                            if(selectDay.weekday != 7){
                              selectDay = selectDay.subtract(Duration(days: selectDay.weekday));
                            }
                            setWeeks();
                            getWeek();
                            getWeekSchedule();
                            setState(() {
                              screenIndex = 1;
                            });
                          }

                        },
                        child:
                        Container(
                          width: 93,
                          height: 36,
                          padding: EdgeInsets.fromLTRB(6, 4, 6, 4),
                          decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(18)
                          ),
                          child:
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                width: 37,
                                height: 28,
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                    color: screenIndex == 0 ? MainTheme.gray2 : Colors.transparent,
                                    borderRadius: BorderRadius.circular(14)
                                ),
                                child: Text("월",style: MainTheme.body8(screenIndex == 0 ? MainTheme.gray6 : MainTheme.gray4),),


                              ),
                              Container(
                                width: 37,
                                height: 28,
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                    color: screenIndex == 1 ? MainTheme.gray2 : Colors.transparent,
                                    borderRadius: BorderRadius.circular(14)
                                ),
                                child: Text("주",style: MainTheme.body8(screenIndex == 1 ? MainTheme.gray6 : MainTheme.gray4),),),




                            ],
                          )
                          ,
                        ))



                  ],
                ),

              ),
              screenIndex == 0 ? SizedBox.shrink() :
              Container(
                alignment: Alignment.center,
                height: 36,
                child:
                    GestureDetector(
                        onTap: () async {
                          var pickedDate = await showModalBottomSheet<DateTime>(
                            context: context,
                            builder: (BuildContext context) {
                              return DatePicker( initTime: selectDay,);
                            },
                          );
                          if(pickedDate != null){
                            setState((){
                              selectDay = pickedDate!;
                              if(selectDay.weekday != 7){
                                selectDay = selectDay.subtract(Duration(days: selectDay.weekday));
                              }
                            });
                            setWeeks();
                            getWeek();
                            getWeekSchedule();
                          }
                        },
                     child: IntrinsicWidth(
                       child: Row(
                         mainAxisAlignment: MainAxisAlignment.center,

                         children: [

                           Text(DateFormat('yyyy.').format(selectDay) + DateFormat('M').format(selectDay), style: MainTheme.body2(MainTheme.gray7),),
                           SizedBox(width : 7),
                           Icon(Icons.keyboard_arrow_down_rounded, color: MainTheme.gray4, size: 16,),

                         ],
                       ),
                     )
                    )




              ),
            ],
          ),


          Container(height: 15,),

            screenIndex == 0 ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12)
                  ),
                  child: Column(
                    children: [


                      Container(height: 74,
                        padding: EdgeInsets.only(left: 20, right: 20),



                        child: Row(
                          mainAxisAlignment:MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [

                            GestureDetector(
                              behavior: HitTestBehavior.translucent,
                              onTap: () async {
                                var pickedDate = await showModalBottomSheet<DateTime>(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return MonthPicker( initTime: selectDay,);
                                  },
                                );
                                if(pickedDate != null) {
                                  if (!DateUtils.isSameMonth(
                                      selectDay, pickedDate)) {
                                    selectDay = pickedDate!;
                                    changeMonth();
                                    getMonthly();
                                  }
                                }
                              },
                              child: Container(
                                child:Row(
                                  children: [
                                    Text(
                                      selectDay.month < 10?
                                      DateFormat('yyyy. M').format(selectDay):
                                      DateFormat('yyyy.MM').format(selectDay)
                                      , style: MainTheme.body2(MainTheme.gray7),),
                                    Container(width: 4,),
                                    Icon(Icons.keyboard_arrow_down_rounded, size: 20,color: MainTheme.gray4),

                                  ],
                                ),

                              ),
                            ),

                            Row(
                              children: [
                                Text(
                                  "오늘", style: MainTheme.caption2(MainTheme.gray7),),
                                weather != null ?
                                Image.network("http://openweathermap.org/img/wn/"
                                    + weather!["weather"][0]["icon"] + ".png", width: 32 , height: 32,) :
                                SizedBox(width: 32 , height: 32,),
                                Container(width: 3,),
                                Container(constraints: const BoxConstraints(
                                  minWidth: 29,
                                ),
                                child: weather != null ? Text(
                                  "${(weather!["main"]["temp"] - 273.15).toInt()}°C", style: MainTheme.caption2(MainTheme.gray7),) : SizedBox.shrink()
                                  )




                              ],
                            ),

                          ],
                        ),

                      ),

                      //요일 그리기
                      Row(
                        children: [
                          ...List.generate(days.length, (index) =>
                              Container(
                                width: blockWidth,
                                height: 21,
                                alignment: Alignment.topCenter,
                                child: Text(
                                  days[index], style: TextStyle(fontSize: 11, fontFamily: "SUIT", fontWeight: FontWeight.w600, color: index ==0? Color(0xffF24147) : MainTheme.gray4),
                                ),
                              )),


                        ],
                      ),

                      GridView.builder(
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          itemCount: dates.length,
                          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                              childAspectRatio: blockWidth / 75,
                              crossAxisCount: 7),
                          itemBuilder: (BuildContext context, int index) {
                            return
                              GestureDetector(
                                behavior: HitTestBehavior.translucent,
                                onTap: (){
                                  if(DateUtils.isSameMonth(dates[index]["day"], selectDay)){
                                    setState(() {
                                      selectDay = dates[index]["day"];
                                      getDaily();
                                    });
                                  }else{
                                    // setState(() {
                                    // selectDay = dates[index]["day"];
                                    // changeMonth();
                                    // getDaily();
                                    // });
                                  }



                                },
                                child: SizedBox(
                                    width: blockWidth, height: 75,
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      children: [

                                        DateUtils.isSameDay(selectDay,dates[index]["day"] )?
                                        //선택된 날짜면 검은바탕에 흰 글자로 표시
                                        Container(
                                          width: 24,
                                          height: 24,
                                          decoration: BoxDecoration(
                                              color: MainTheme.gray7,
                                              shape: BoxShape.circle
                                          ),
                                          alignment: Alignment.center,
                                          child: Text(
                                              dates[index]["day"].day.toString(), style: TextStyle(fontSize: 13, fontFamily: "SUIT", fontWeight: FontWeight.w800, color:Colors.white)
                                          ),
                                        ):

                                        dates[index]["today"]?
                                        //오늘 날짜면 주황바탕으로 표시
                                        Container(
                                          width: 24,
                                          height: 24,
                                          decoration: BoxDecoration(
                                              color: Color(0x1aff881a),
                                              shape: BoxShape.circle
                                          ),
                                          alignment: Alignment.center,
                                          child: Text(
                                              dates[index]["day"].day.toString(), style: TextStyle(fontSize: 13, fontFamily: "SUIT", fontWeight: FontWeight.w800, color:MainTheme.mainColor)
                                          ),
                                        ):
                                        //아니면 검은색 혹은 빨간색으로 표시
                                        Container(
                                          child: Text(
                                            dates[index]["day"].day.toString(), style: TextStyle(fontSize: 13, fontFamily: "SUIT", fontWeight: FontWeight.w800, color: index%7 == 0?
                                          dates[index]["previous"] != 0? Color(0x80F24147): Color(0xffF24147) : dates[index]["previous"] != 0? MainTheme.gray4:MainTheme.gray7),),
                                          alignment: Alignment.center,
                                          width: 24,
                                          height: 24,
                                        ),
                                        //일정 표시
                                        Container(height: 1,),
                                        Column(
                                          mainAxisAlignment: MainAxisAlignment.start,
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            ...List.generate(min(2,   monthSchedule[DateFormat('yyyy-MM-dd').format(dates[index]["day"])] == null ? 0 : monthSchedule[DateFormat('yyyy-MM-dd').format(dates[index]["day"])].length
                                            ), (schIndex) =>

                                                Container(
                                                  margin: EdgeInsets.only(bottom: 3, left: 1.4),
                                                  width: 41,
                                                  height: 14,
                                                  padding: EdgeInsets.symmetric(horizontal: 3),
                                                  decoration: BoxDecoration(
                                                    borderRadius: BorderRadius.circular(4),
                                                    color: MainTheme.planBgColor[int.parse(monthSchedule[DateFormat('yyyy-MM-dd').format(dates[index]["day"])][schIndex]["color"])],
                                                  ),
                                                  child: Text(
                                                      monthSchedule[DateFormat('yyyy-MM-dd').format(dates[index]["day"])][schIndex]["title"], style: TextStyle(overflow:TextOverflow.ellipsis, fontSize: 10, fontFamily: "SUIT", fontWeight: FontWeight.w800, color:MainTheme.planColor[int.parse(monthSchedule[DateFormat('yyyy-MM-dd').format(dates[index]["day"])][schIndex]["color"])],)
                                                  ),
                                                )

                                            ),

                                            (monthSchedule[DateFormat('yyyy-MM-dd').format(dates[index]["day"])] == null ? 0 : monthSchedule[DateFormat('yyyy-MM-dd').format(dates[index]["day"])].length) >=3 ?
                                            Container(
                                                margin: EdgeInsets.only( left: 1.4),
                                                width: 23,
                                                height: 14,
                                                alignment: Alignment.center,
                                                decoration: BoxDecoration(
                                                  borderRadius: BorderRadius.circular(4),
                                                  color: Color(0xffecedf0),
                                                ),
                                                child: Text(
                                                    "+" + ((monthSchedule[DateFormat('yyyy-MM-dd').format(dates[index]["day"])].length) -2).toString(), style: TextStyle(fontSize: 10, fontFamily: "SUIT", fontWeight: FontWeight.w600, color:Color(0xff5a636a)))
                                            ):SizedBox.shrink()
                                          ],
                                        )

                                      ],
                                    )
                                ),

                              );


                          }),



                    ],
                  ),
                ),
                Container(height: 24,),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(width: 13,),
                    Text(DateFormat("E요일", 'ko_KR').format(selectDay), style: MainTheme.body4(MainTheme.gray7)),
                    Container(width: 6,),
                    Text(selectDay.day.toString(), style: MainTheme.body8(MainTheme.gray7))
                  ],
                ),
                Container(height: 12,),

                daySchedule.length == 0 ?

                    Container(
                      height: 100,
                      width: double.infinity,
                      child: MainTheme.ErrorPage(context, "일정이 없어요"),
                    ):

                Container(
                  child: Column(
                    children: [
                      ...List.generate(daySchedule.length, (index) =>

                      GestureDetector(
                        behavior: HitTestBehavior.translucent,
                        onTap: (){showScheduleInfo(daySchedule[index]["scheduleId"], daySchedule[index]["id"]);},
                        child: Container(
                          width: double.infinity,
                          height: 48,
                          margin: EdgeInsets.only(bottom: index == daySchedule.length? 0: 10),
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              color: Colors.white
                          ),
                          padding: EdgeInsets.symmetric(horizontal: 20),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Container(width: 83,
                                  alignment: Alignment.centerLeft,

                                  child:

                                  daySchedule[index]["isAllDay"]?
                                  Text("종일", style: MainTheme.body8(MainTheme.gray7),) :

                                  daySchedule[index]["startTime"] == "00:00:00"|| daySchedule[index]["endTime"] == "00:00:00"?

                                      //시작시간, 종료시간이 자정일 경우 == 한줄만 표시

                                  Row(
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      Text(DateFormat("aa", 'ko_KR').format(DateTime
                                          .parse('${daySchedule[index]["startTime"] == "00:00:00" ? daySchedule[index]["endDate"] :
                                      daySchedule[index]["startDate"]} ${daySchedule[index]["startTime"] == "00:00:00" ? daySchedule[index]["endTime"] : daySchedule[index]["startTime"]}')), style: MainTheme.caption4(MainTheme.gray4),),
                                      Container(width: 2,),
                                      Text(DateFormat("hh:mm").format(DateTime
                                          .parse('${daySchedule[index]["startTime"] == "00:00:00" ? daySchedule[index]["endDate"] :
                                      daySchedule[index]["startDate"]} ${daySchedule[index]["startTime"] == "00:00:00" ? daySchedule[index]["endTime"] : daySchedule[index]["startTime"]}')), style: MainTheme.body4(MainTheme.gray7),)
                                    ],
                                  )

                                      :

                                  Column(
                                    mainAxisAlignment: MainAxisAlignment.center,

                                    children: [
                                      Row(
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        children: [
                                          Text(DateFormat("aa", 'ko_KR').format(DateTime.parse('${daySchedule[index]["startDate"]} ${daySchedule[index]["startTime"]}')), style: MainTheme.caption6(MainTheme.gray4),),
                                          Container(width: 2,),
                                          Text(DateFormat("hh:mm").format(DateTime.parse('${daySchedule[index]["startDate"]} ${daySchedule[index]["startTime"]}')), style: MainTheme.body4(MainTheme.gray7),)

                                        ],
                                      ),
                                      Row(
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        children: [
                                          Text(DateFormat("aa", 'ko_KR').format(DateTime.parse('${daySchedule[index]["endDate"]} ${daySchedule[index]["endTime"]}')), style: MainTheme.caption6(MainTheme.gray4),),
                                          Container(width: 2,),
                                          Text(DateFormat("hh:mm").format(DateTime.parse('${daySchedule[index]["endDate"]} ${daySchedule[index]["endTime"]}')), style: MainTheme.caption4(MainTheme.gray4),)

                                        ],
                                      )

                                    ],
                                  )
                              ),

                              Container(
                                width: 7,
                                height: 7,
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(2),
                                    color: MainTheme.planColor[int.parse( daySchedule[index]["color"])]
                                ),
                              ),
                              Container(
                                width: 6,
                              ),
                              Text("${daySchedule[index]["title"]}", style: MainTheme.body8(MainTheme.gray7), overflow: TextOverflow.ellipsis,)
                            ],
                          ),

                        ),
                      )
                          )

                    ],
                  ),
                ),
              ],
            ) :

            //주간 일정-----------------------------------------

            Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(width: double.infinity,
                    height: 94,
                    decoration: MainTheme.roundBox(Colors.white),
                    child: Row(
                      children: [
                        Container(width: 62,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text("학교 수업", style: MainTheme.caption4(MainTheme.gray6),),
                              SizedBox(height: 6,),
                              CupertinoSwitch(value: school,activeColor: MainTheme.mainColor, trackColor: Color(0xffBEC5CC),onChanged: (bool value){
                                setState(() {
                                  school = value;
                                });
                              }),
                            ],
                          ),
                        ),
                        Expanded(child: CarouselSlider(
                            options: CarouselOptions(
                              autoPlay: false,
                              initialPage: 1,
                              viewportFraction: 1,
                              onPageChanged: (index, reason) => setState(() {

                                int preIndex = index == 0 ? 2 : index -1;
                                int nextIndex = index == 2 ? 0 : index +1;
                                selectDay = weeks[index][0]["date"];
                                for(int i = 0; i < 7; i++){
                                  weeks[preIndex][i]["date"] = selectDay.subtract(Duration(days: 7-i));
                                }
                                for(int i = 0; i < 7; i++){
                                  weeks[nextIndex][i]["date"] = selectDay.add(Duration(days: i+7));
                                }
                                getWeekSchedule();
                                getWeek();
                              }),
                            ),
                            items :[

                              ...List.generate(weeks.length, (index) =>Container(
                                width: MediaQuery.of(context).size.width - 32 - 58,
                                height: 94,
                                child: Row(
                                  children: [
                                    ...List.generate(7, (dayIndex) =>

                                        Expanded(child:

                                        GestureDetector(
                                          behavior: HitTestBehavior.translucent,
                                          onTap: (){
                                            if(selectedChildIndex != 0){
                                              showTimeTable(children[selectedChildIndex], weeks[index][dayIndex]["date"]);
                                            }
                                          },
                                          child:Container(
                                            height: 94,
                                            margin: EdgeInsets.only(right: dayIndex == 6 ? 0 : 2),
                                            child: Column(
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              crossAxisAlignment: CrossAxisAlignment.center,
                                              children: [
                                                Text(days[dayIndex], style: MainTheme.caption3(dayIndex == 0 ? Color(0xfff24147) : MainTheme.gray4),),
                                                SizedBox(height: 11,),
                                                Container(
                                                  width: 24,
                                                  height: 24,
                                                  alignment: Alignment.center,
                                                  decoration: BoxDecoration(
                                                    shape: BoxShape.circle,
                                                    color: DateUtils.isSameDay(DateTime.now(), weeks[index][dayIndex]["date"]) ? MainTheme.mainColor.withOpacity(0.1) : Colors.transparent,
                                                  ),
                                                  child :  Text(DateFormat('d').format(weeks[index][dayIndex]["date"]), style: MainTheme.caption3( DateUtils.isSameDay(DateTime.now(), weeks[index][dayIndex]["date"]) ? MainTheme.mainColor : MainTheme.gray7),),
                                                )

                                              ],
                                            ),

                                          )

                                        )
                                        ))
                                  ],

                                ),

                              ),)
                              ,

                            ]
                        ),)
                      ],
                    ),
                  ),
                  SizedBox(height: 8,),
                  Container(
                    decoration: MainTheme.roundBox(Colors.white),
                    padding: EdgeInsets.symmetric(vertical: 8),
                    width: double.infinity,
                    height: 37,
                    child : Row(
                      children: [
                        Container(
                          width: 42,
                          alignment: Alignment.center,
                          child: Text("종일", style: MainTheme.body8(MainTheme.gray7),),

                        ),
                        Expanded(child: Container(
                          child: Stack(
                            children: [
                              ...List.generate(onDaySchedules.length, (index){

                                int preCount = 0;
                                for(int i = index ; i >= 0 ; i-- ){
                                  if(i == 0){
                                    break;
                                  }
                                  if(DateUtils.isSameDay(onDaySchedules[i-1]["end"], onDaySchedules[i]["start"]) || onDaySchedules[i-1]["end"].isAfter(onDaySchedules[i]["start"])){
                                    preCount ++;
                                  }else{
                                    break;
                                  }
                                }
                                int nextCount = 0;
                                for(int i = index ; i < onDaySchedules.length ; i++ ){
                                  if(i == onDaySchedules.length -1){
                                    break;
                                  }
                                  if(DateUtils.isSameDay(onDaySchedules[i]["end"], onDaySchedules[i + 1]["start"]) || onDaySchedules[i]["end"].isAfter(onDaySchedules[i + 1]["start"])){
                                    nextCount ++;
                                  }else{
                                    break;
                                  }
                                }
                                DateTime start = onDaySchedules[index]["start"];
                                DateTime end = onDaySchedules[index]["end"];

                                double width = ((end.weekday % 7) - (start.weekday % 7) + 1) * dayWidth;
                                double left = (start.weekday % 7) * dayWidth;
                                double height = 21.0/ (nextCount + preCount + 1);
                                double top = height * preCount;
                                return

                                   Positioned(
                                        left: left,
                                        top: top,
                                        child:
                                        GestureDetector(
                                            onTap: (){showScheduleInfo(onDaySchedules[index]["id"], 0);},
                                            behavior: HitTestBehavior.translucent,
                                            child:
                                        Container(
                                          padding : EdgeInsets.all(3),
                                          width: width,
                                          height: height,
                                          decoration: BoxDecoration(
                                              color:MainTheme.planBgColor[int.parse(onDaySchedules[index]["color"])],
                                              borderRadius: BorderRadius.circular(4)
                                          ),
                                          child:

                                          (nextCount + preCount + 1)  > 1 ? SizedBox.shrink() : Text(onDaySchedules[index]["title"], style: TextStyle(letterSpacing: 0,fontSize: 11, height: 14/11, fontWeight: FontWeight.w700, fontFamily: "SUIT", color:MainTheme.planColor[int.parse(onDaySchedules[index]["color"])]),
                                              overflow: TextOverflow.ellipsis, maxLines:1
                                          ),
                                        )),
                                  )
                                  ;


                              })
                            ],
                          ),
                        ))
                      ],
                    ),
                  ),
                  SizedBox(height: 8,),
                  Container(
                    decoration: MainTheme.roundBox(Colors.white),
                    width: double.infinity,
                    height: 1152 + 23,
                    child : Row(
                      children: [
                        Column(
                          children: [
                            SizedBox(height: 23,),
                            ...List.generate(7, (index) => Container(
                              height: 64,
                              width: 42,
                              alignment: Alignment.center,
                              child: Text(
                                "오전\n" + (index + 6).toString() + "시", style: MainTheme.caption3(MainTheme.gray6),textAlign: TextAlign.center,
                              ),
                            )),
                            ...List.generate(11, (index) => Container(
                              height: 64,
                              width: 42,
                              alignment: Alignment.center,
                              child: Text(
                                "오후\n" + (index + 1).toString() + "시", style: MainTheme.caption3(MainTheme.gray6),textAlign: TextAlign.center,
                              ),
                            )),
                          ],
                        ),
                        Expanded(child:
                        Container(
                          margin: EdgeInsets.only(top: 23),
                          height: 1152,
                          child: Stack(
                            children: [
                              ...List.generate(7, (index) => Positioned(
                                  top: 0, left: dayWidth * index,
                                  child: Container(
                                    height: 1152,
                                    width: dayWidth,
                                    child: Column(

                                      children: [

                                        ...List.generate(18, (colIndex) => 
                                            GestureDetector(
                                              onTap: (){
                                                showModalBottomSheet<int>(
                                                  useSafeArea: true,
                                                  context: context,
                                                  isScrollControlled: true,
                                                  builder: (BuildContext context) {
                                                    int hour = 6+colIndex;
                                                    DateTime date = selectDay.add(Duration(days: index));
                                                    return RegisterPlan(initTime:DateTime(date.year,date.month, date.day, hour, 0, 0));
                                                  },
                                                ).then((value){
                                                  if(screenIndex == 0){
                                                    getMonthly();
                                                  }else{
                                                    getWeek();
                                                    getWeekSchedule();
                                                  }

                                                  if(value != null){
                                                    showScheduleInfo(value, 0);
                                                  }

                                                });

                                              },
                                          behavior: HitTestBehavior.translucent,
                                          child: Container(
                                            width: dayWidth,
                                            height: 64,
                                          ),


                                        ))

                                      ],

                                    ),



                                  )


                              )),





                              ...List.generate(weekList.length, (index){



                                int preCount = 0;
                                for(int i = index ; i >= 0 ; i-- ){
                                  if(i == 0){
                                    break;
                                  }
                                  if(weekList[i-1]["end"].isAfter(weekList[i]["start"])){
                                    preCount ++;
                                  }else{
                                    break;
                                  }
                                }
                                int nextCount = 0;
                                for(int i = index ; i < weekList.length ; i++ ){
                                  if(i == weekList.length -1){
                                    break;
                                  }
                                  if(weekList[i]["end"].isAfter(weekList[i + 1]["start"])){
                                    nextCount ++;
                                  }else{
                                    break;
                                  }
                                }
                                DateTime start = weekList[index]["start"];
                                DateTime end = weekList[index]["end"];
                                double width = dayWidth / (preCount + nextCount + 1);
                                double left = width * preCount + (((weekList[index]["start"].weekday) % 7) * dayWidth);
                                double height = 64/60.0 * (end.difference(start).inMinutes);
                                double top = 64/60.0 * (start.difference(DateTime(start.year, start.month, start.day, 6)).inMinutes);
                                int maxLine = (height.toInt() - 6) ~/ 14;
                                return Positioned(
                                    left: left,
                                    top: top,

                                    child : GestureDetector(
                                      onTap: (){showScheduleInfo(weekList[index]["scheduleId"], weekList[index]["id"]);},
                                      behavior: HitTestBehavior.translucent,
                                      child: Container(
                                      width: width,
                                      height: height,
                                      padding: EdgeInsets.only(top: 2,left:1),
                                      child: Container(
                                        width: double.infinity,
                                        height: double.infinity,
                                        decoration: BoxDecoration(
                                            color:MainTheme.planBgColor[int.parse(weekList[index]["color"])],
                                            borderRadius: BorderRadius.circular(4)
                                        ),
                                        padding: EdgeInsets.symmetric(horizontal: 4, vertical: 3),
                                        child:

                                        maxLine == 0 ? SizedBox.shrink() :
                                        Text(weekList[index]["title"], style: TextStyle(letterSpacing: 0,fontSize: 11, height: 14/11, fontWeight: FontWeight.w700, fontFamily: "SUIT", color: MainTheme.planColor[int.parse(weekList[index]["color"])]),
                                          overflow: TextOverflow.ellipsis, maxLines: maxLine,
                                        ),

                                      ),
                                    )));


                              })
                            ],
                          ),
                        )
                        )

                      ],
                    ),
                  ),
                  SizedBox(height: 8,),

                ]
            )

          ],
        ),

          )

        ),
        floatingActionButton:
        screenIndex == 0 ? GestureDetector(
          behavior: HitTestBehavior.translucent,
          onTap: (){
            showModalBottomSheet<int>(
              useSafeArea: true,
              context: context,
              isScrollControlled: true,
              builder: (BuildContext context) {
                return RegisterPlan(initTime:DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day, DateTime.now().hour + 1, 0, 0));
              },
            ).then((value){
              print("helloworld" + value.toString());
              if(screenIndex == 0){
                getMonthly();
              }else{
                getWeek();
                getWeekSchedule();
              }
              if(value != null){
                showScheduleInfo(value, 0);
              }
            });

          },
          child: Container(
            width: 105,
            height: 51,
            decoration: BoxDecoration(
              color: MainTheme.gray7,
              borderRadius: BorderRadius.circular(25.5),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  spreadRadius: 1,
                  blurRadius: 6,
                  offset: Offset(0, 4), // changes position of shadow
                ),
              ],
            ),
            alignment: Alignment.center,
            child:
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SvgPicture.asset("assets/icons/ic_16_edit_white.svg",width: 16, height: 16, ),
                Container(width: 5,),
                Text("일정 추가", style : MainTheme.body4(Colors.white))
              ],
            )
            ,
          ),
        ) : SizedBox.shrink()



    );


  }




  void setWeeks() async {
    weeks = [];
    sunday = selectDay.weekday == 7 ? selectDay : selectDay.subtract(Duration(days: selectDay.weekday));
    DateTime start = sunday.subtract(const Duration(days: 7));

    for(int i = 0 ;  i < 3 ; i++){
      List week = List.empty(growable: true);
      for(int j = 0; j <7; j++){
        week.add({"date":start.add(Duration(days: ((i * 7) + j)))});
      }
      weeks.add(week);
    }
    setState(() {

    });
  }

  void changeMonth() async {
    dates = [];
    var now = selectDay;
    var today = DateTime.now();
    //이번달 1일
    var firstDay = DateTime(now.year, now.month, 1);
    //이번달 마지막 날
    var lastDay = DateTime(now.year, now.month+1, 0);


    if(firstDay.weekday != 7){
      //이번달 1일이 일요일이 아니면 저번달 일을 추가함
      var previousLastDay = DateTime(now.year, now.month, 0);
      for(int i = (firstDay.weekday -1); i >= 0; i--){
        dates.add({"today":DateUtils.isSameDay(previousLastDay.subtract(Duration(days: i)), today), "day":previousLastDay.subtract(Duration(days: i)), "previous": 1, "schedule":[]});
      }
    }
    //이번달 1일부터 마지막날까지 추가
    for(int i = 1; i <= lastDay.day; i++){
      dates.add({"today":DateUtils.isSameDay(firstDay.add(Duration(days: i-1)), today), "day":firstDay.add(Duration(days: i-1)), "previous": 0, "schedule":[]});
    }
    if(lastDay.weekday != 6){
      //이번달 마지막 날이 토요일이 아니면 다음달 일을 추가함
      var nextFirstDay = lastDay.add(Duration(days: 1));

      for(int i = 0; i < (lastDay.weekday == 7 ? 6 : (6-lastDay.weekday)) ; i++){
        dates.add({"today":DateUtils.isSameDay(nextFirstDay.add(Duration(days: i)), today),"day":nextFirstDay.add(Duration(days: i)), "previous": -1, "schedule":[]});
      }
    }


  }




  void showScheduleInfo(int scheduleId, int calendarId){

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return StatefulBuilder(builder:
            (BuildContext context, StateSetter setState){
          return ScheduleInfo(scheduleId: scheduleId, calendarId:  calendarId,);

        }
        );


      },
    ).then((value){
      if(screenIndex == 0){
        getMonthly();
      }else{
        getWeek();
        getWeekSchedule();
      }
    });
  }

  void showTimeTable(Map map, DateTime date){

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return StatefulBuilder(builder:
            (BuildContext context, StateSetter setState){
          return TimeTable(map: map, dateTime: date, isParent: true);

        }
        );


      },
    ).then((value){
      if(screenIndex == 0){
        getMonthly();
      }else{
        getWeek();
        getWeekSchedule();
      }
    });
  }

  Future<void> getWeather() async {

    Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);


    var responseResult = await apiRequestGet("https://api.openweathermap.org/data/2.5/weather",  {"lat" :position.latitude.toString(), "lon": position.longitude.toString(), "appid": weatherKey});
    var response =jsonDecode(utf8.decode(responseResult.bodyBytes));

    if(response["cod"] == 200){
      if (this.mounted) {
        setState(() {weather = response;});
      }
    }


  }


  OverlayEntry selectChild(){
    ScrollController _scrollController= ScrollController();
    return OverlayEntry(
      maintainState: true,
      builder: (context) =>

          SizedBox(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            child: Stack(
              children: [
                ModalBarrier(
                  onDismiss: () {
                    _removeOverlay();
                  },
                ),
                CompositedTransformFollower(
                    link: _layerLink,
                    showWhenUnlinked: false,
                    offset: const Offset(0, 40),
                    child: Container(
                      width: 120,
                      padding: EdgeInsets.fromLTRB(14,10,14,10),
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
                      child:
                      IntrinsicHeight(
                        child: Column(
                          children: [

                            ...List.generate(children.length, (index) =>

                                GestureDetector(
                                  onTap: (){
                                    setState(() {
                                      selectedChildIndex = index;
                                      if(screenIndex == 0){
                                        getMonthly();
                                      }else{
                                        getWeekSchedule();
                                        getWeek();
                                      }
                                    });
                                    _removeOverlay();
                                  },
                                  behavior: HitTestBehavior.translucent,
                                  child: Container(
                                    margin: EdgeInsets.only(bottom: index == children.length - 1 ? 0 : 8),
                                    height: 32,
                                    width: double.infinity,
                                    child: Row(
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      children: [
                                        const SizedBox(width: 6,),
                                        ClipRRect(
                                          borderRadius: BorderRadius.circular(300.0),
                                          child:
                                          Image.network(
                                            children[index]["fileUrl"] ?? "",
                                            width : 24,
                                            height: 24,
                                            fit: BoxFit.cover,
                                            errorBuilder: (BuildContext context, Object exception, StackTrace? stackTrace) {
                                              return SvgPicture.asset("assets/icons/profile_${children[index]["id"]%3 + 1}.svg",width: 24, height: 24, );
                                            },
                                          )

                                        ),
                                        const SizedBox(width: 6,),
                                        Expanded(child:
                                        Material( color: Colors.transparent, child: Text(children[index]["name"], style: MainTheme.body5(MainTheme.gray7),overflow: TextOverflow.ellipsis,))
                                        )

                                      ],
                                    ),
                                  ),
                                )
                                )


                          ],
                        ),
                      )


                    )
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


  Future<void> getChildren() async {
    SharedPreferences pref = await SharedPreferences.getInstance();

    monthChildren[0]["name"] = "전체";
    monthChildren[0]["fileUrl"] = "";
    monthChildren[0]["id"] = 0;


    monthChildren.add({
      "name" : pref.getString("name"),
      "fileUrl" : pref.getString("profile"),
      "id" : pref.getInt("userId")!
    });

    weekChildren[0]["name"] = pref.getString("name");
    weekChildren[0]["fileUrl"] = pref.getString("profile");
    weekChildren[0]["id"] = pref.getInt("userId")!;


    var response = await apiRequestGet(urlChildren,  {});
    var body =jsonDecode(utf8.decode(response.bodyBytes));

    if(response.statusCode == 200){
      for(var child in body["data"]){
        weekChildren.add({
          "name" : child["name"],
          "fileUrl" : child["fileUrl"],
          "id" : child["id"]
        });
        monthChildren.add({
          "name" : child["name"],
          "fileUrl" : child["fileUrl"],
          "id" : child["id"]
        });
      }
    }

    monthChildren.add({
      "name" : "결제일",
      "fileUrl" : "",
      "id" : -1
    });

    children = weekChildren;

    setWeeks();
    getWeek();
    getWeekSchedule();

  }

  Future<void> getMonthly() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    String payOnly = "false";
    List<String> idList = [];
    if(screenIndex == 0){
      if(selectedChildIndex == 0 || selectedChildIndex == monthChildren.length-1){
        for(int i = 1; i < monthChildren.length-1 ; i++){
          idList.add(children[i]["id"].toString());
        }
      }else{
        idList.add(children[selectedChildIndex]["id"].toString());
      }
      if(selectedChildIndex == monthChildren.length-1){
        payOnly = "true";
      }
    }else{
      idList.add(children[selectedChildIndex]["id"].toString());
    }

    var response = await apiRequestGet(urlMonthly,  {"payOnly" : payOnly, "commonMemberIdList" : idList.join(","),  "monthStartDate" : DateFormat('yyyy-MM-dd').format(selectMonth())});
    var body =jsonDecode(utf8.decode(response.bodyBytes));
    if(response.statusCode == 200){
      setState(() {
        monthSchedule = body["data"];
      });
    }
    getDaily();
  }

  Future<void> getDaily() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    String payOnly = "false";
    List<String> idList = [];
    if(screenIndex == 0){
      if(selectedChildIndex == 0 || selectedChildIndex == monthChildren.length-1){
        for(int i = 1; i < monthChildren.length-1 ; i++){
          idList.add(children[i]["id"].toString());
        }
      }else{
        idList.add(children[selectedChildIndex]["id"].toString());
      }
      if(selectedChildIndex == monthChildren.length-1){
        payOnly = "true";
      }
    }else{
      idList.add(children[selectedChildIndex]["id"].toString());
    }
    var response = await apiRequestGet(urlDaily,  {"payOnly" : payOnly, "commonMemberIdList" : idList.join(","), "dayDate" :DateFormat('yyyy-MM-dd').format(selectDay)});
    var body =jsonDecode(utf8.decode(response.bodyBytes));
    if(response.statusCode == 200){
      List allDay = [];
      List notAllDay = [];
      for(Map map in  body["data"]){
        if(map["isAllDay"]){
          allDay.add(map);
        }else{
          notAllDay.add(map);
        }
      }
      allDay.addAll(notAllDay);
      setState(() {
        daySchedule = allDay;
      });
    }

  }


  Future<void> getWeek() async {

    SharedPreferences pref = await SharedPreferences.getInstance();
    var response = await apiRequestGet(urlWeek,  {"commonMemberIdList" : children[selectedChildIndex]["id"].toString(), "commonMemberId" : children[selectedChildIndex]["id"].toString(), "weekStartDate" :DateFormat('yyyy-MM-dd').format(selectDay)});
    var body =jsonDecode(utf8.decode(response.bodyBytes));
    if(response.statusCode == 200){
      List temp = [];
      for(int i = 0; i <body["data"].length; i++){
        if(!body["data"][i]["isAllDay"]){
          if(DateTime.parse('${body["data"][i]["startDate"]} ${body["data"][i]["startTime"]}').isBefore(DateTime.parse('${body["data"][i]["startDate"]} 06:00'))){
            body["data"][i]["startTime"] = "06:00";
          }
          body["data"][i]["start"] = DateTime.parse(body["data"][i]["startDate"] + " " + body["data"][i]["startTime"]);
          body["data"][i]["end"] = DateTime.parse(body["data"][i]["endDate"] + " " + body["data"][i]["endTime"]);
          temp.add(body["data"][i]);
        }

      }
      weekList = temp;
      setState(() {

      });
    }

  }

  Future<void> getWeekSchedule() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    var response = await apiRequestGet(urlWeekSchedule,  {"commonMemberId" : children[selectedChildIndex]["id"].toString(), "weekStartDate" :DateFormat('yyyy-MM-dd').format(selectDay)});
    var body =jsonDecode(utf8.decode(response.bodyBytes));
    if(response.statusCode == 200){
      List temp = [];
      for(int i = 0; i <body["data"].length; i++){
        if(body["data"][i]["isAllDay"] || (body["data"][i]["startDate"] != body["data"][i]["endDate"])){
          if(DateTime.parse('${body["data"][i]["startDate"]}').isBefore(DateTime(selectDay.year, selectDay.month, selectDay.day))){
            body["data"][i]["startDate"] = DateFormat('yyyy-MM-dd').format(selectDay);
          }
          if(DateTime.parse('${body["data"][i]["endDate"]}').isAfter(DateTime(selectDay.year, selectDay.month, selectDay.day).add(Duration(days: 6)))){
            body["data"][i]["endDate"] = DateFormat('yyyy-MM-dd').format(DateTime(selectDay.year, selectDay.month, selectDay.day).add(Duration(days: 6)));
          }

          body["data"][i]["start"] = DateTime.parse(body["data"][i]["startDate"] + " " + body["data"][i]["startTime"]);
          body["data"][i]["end"] = DateTime.parse(body["data"][i]["endDate"] + " " + body["data"][i]["endTime"]);
          temp.add(body["data"][i]);
        }


      }
      temp.sort((a, b) => a["start"].compareTo(b["start"]));
      for(int i = 0; i< temp.length; i++){
      }
      onDaySchedules = temp;
      setState(() {

      });
    }
  }

  DateTime selectMonth(){
    return DateTime(selectDay.year, selectDay.month, 1);
  }

}
