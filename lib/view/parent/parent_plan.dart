import 'dart:convert';
import 'dart:math';
import 'dart:ui';
import 'package:cached_network_image/cached_network_image.dart';
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
import 'package:orange_school/style/month_picker.dart';
import 'package:orange_school/style/register_plan.dart';
import 'package:orange_school/style/schedule_info.dart';
import 'package:orange_school/util/api.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:xml/xml.dart';
import '../../style/date_picker.dart';
import '../../style/schedule_info_child.dart';
import '../../style/time_picker.dart';
import '../../style/time_table.dart';


const Map eleTimes ={
  "1-1" : "09:00",
  "1-2" : "09:50",
  "1-3" : "10:40",
  "1-4" : "12:00",
  "1-5" : "12:50",
  "1-6" : "13:40",
  "1-7" : "14:30",
  "2-1" : "09:00",
  "2-2" : "09:50",
  "2-3" : "10:40",
  "2-4" : "12:00",
  "2-5" : "12:50",
  "2-6" : "13:40",
  "2-7" : "14:30",
  "3-1" : "09:00",
  "3-2" : "09:50",
  "3-3" : "10:40",
  "3-4" : "11:30",
  "3-5" : "12:50",
  "3-6" : "13:40",
  "3-7" : "14:30",
  "4-1" : "09:00",
  "4-2" : "09:50",
  "4-3" : "10:40",
  "4-4" : "11:30",
  "4-5" : "12:50",
  "4-6" : "13:40",
  "4-7" : "14:30",
  "5-1" : "09:00",
  "5-2" : "09:50",
  "5-3" : "10:40",
  "5-4" : "11:30",
  "5-5" : "12:20",
  "5-6" : "13:40",
  "5-7" : "14:30",
  "6-1" : "09:00",
  "6-2" : "09:50",
  "6-3" : "10:40",
  "6-4" : "11:30",
  "6-5" : "12:20",
  "6-6" : "13:40",
  "6-7" : "14:30",
};



String weatherKey = "${dotenv.env['WEATHER_KEY']}";
String urlChildren = "${dotenv.env['BASE_URL']}user/commonMembers";
String urlMonthly = "${dotenv.env['BASE_URL']}user/month/calendars";
String urlDaily = "${dotenv.env['BASE_URL']}user/day/calendars";
String urlWeek = "${dotenv.env['BASE_URL']}user/week/calendars";
String urlWeekSchedule = "${dotenv.env['BASE_URL']}user/week/calendars/allDay";
String holidayKey = "${dotenv.env['HOLIDAY_KEY']}";
String urlHoliday = "http://apis.data.go.kr/B090041/openapi/service/SpcdeInfoService/getRestDeInfo";
String urlJulgi = "http://apis.data.go.kr/B090041/openapi/service/SpcdeInfoService/get24DivisionsInfo";
String urlSchoolTime = "https://open.neis.go.kr/hub/elsTimetable";
String schoolKey = "${dotenv.env['SCHOOL_KEY']}";
String urlMy = "${dotenv.env['BASE_URL']}user/commonMember";
class ParentPlan extends StatefulWidget {
  final bool isParent;
  const ParentPlan ({ Key? key, required this.isParent }): super(key: key);
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
  CarouselController carouselController = CarouselController();
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
  Map holidays = {};
  ScrollController scrollController = ScrollController();

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
    double dashWidth =  MediaQuery.of(context).size.width-32;
    return Scaffold(
        extendBody: true,
        backgroundColor: MainTheme.backgroundGray,
        resizeToAvoidBottomInset: true,
        body: Padding(
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
                                            children[selectedChildIndex]["id"] == 0 ?
                                            SvgPicture.asset("assets/icons/ic_all.svg",width: 30, height: 30, ) :
                                            children[selectedChildIndex]["id"] == -1 ?
                                            SvgPicture.asset("assets/icons/ic_reci.svg",width: 30, height: 30, ) :
                                            CachedNetworkImage(
                                              imageUrl:
                                              children[selectedChildIndex]["fileUrl"] ?? "",
                                              width : 30,
                                              height: 30,
                                              fit: BoxFit.cover,
                                              errorWidget: (context, url, error) {
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
                              if(widget.isParent){
                                if(screenIndex == 1){
                                  scrollController.jumpTo(0);
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
                                  scrollController.jumpTo(535);
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
                              }else{
                                if(screenIndex == 1){
                                  scrollController.jumpTo(0);
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
                                  scrollController.jumpTo(535);
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

                                Text(DateFormat('yyyy.').format(exMonth()) + DateFormat('M').format(exMonth()), style: MainTheme.body2(MainTheme.gray7),),
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
              screenIndex == 1 ?

              Column(children: [

                Container(width: double.infinity,
                  height: 94,
                  decoration: MainTheme.roundBox(Colors.white),
                  child: Row(
                    children: [
                      Container(width: 42,
                          alignment: Alignment.centerRight,
                          padding: EdgeInsets.only(right: 4),

                          child:
                          widget.isParent && (selectedChildIndex == (children.length-1)) ? SizedBox.shrink():

                          GestureDetector(
                            behavior: HitTestBehavior.translucent,
                            onTap: (){
                              setState(() {
                                school = !school;
                                getWeek();
                              });
                            },
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text("학교\n수업", style: MainTheme.caption4(MainTheme.gray6),),
                                SizedBox(height: 6,),

                                Container(
                                  width: 28,
                                  child: FittedBox(
                                    fit: BoxFit.contain,
                                    child: CupertinoSwitch(value: school,activeColor: MainTheme.mainColor, trackColor: Color(0xffBEC5CC),onChanged: (bool value){
                                      setState(() {
                                        school = !school;
                                        getWeek();
                                      });
                                    }),
                                  ),
                                ),
                              ],
                            ),
                          )


                      ),
                      Expanded(child: CarouselSlider(
                          carouselController: carouselController,
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
                              width: MediaQuery.of(context).size.width - 32 - 42,
                              height: 94,
                              child: Row(
                                children: [
                                  ...List.generate(7, (dayIndex) =>

                                      Expanded(child:

                                      GestureDetector(
                                          behavior: HitTestBehavior.translucent,
                                          onTap: (){
                                            if(widget.isParent){
                                              showTimeTable(children[selectedChildIndex], weeks[index][dayIndex]["date"], selectedChildIndex == (children.length-1));
                                            }else{
                                              showTimeTable(children[selectedChildIndex], weeks[index][dayIndex]["date"], false);
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
                                                  child :  Text(DateFormat('d').format(weeks[index][dayIndex]["date"]), style: MainTheme.body4( DateUtils.isSameDay(DateTime.now(), weeks[index][dayIndex]["date"]) ? MainTheme.mainColor : MainTheme.gray7),),
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
                  padding: EdgeInsets.symmetric(vertical: 0),
                  width: dashWidth,
                  child : Row(
                    children: [
                      Container(
                        width: 41.75,
                        alignment: Alignment.center,
                        child: Text("종일", style: MainTheme.body8(MainTheme.gray7),),
                      ),
                      Container(
                        width: dashWidth - 41.75,
                        child: Stack(
                          children: [

                            Positioned.fill(
                                child: Row(
                                  children: [
                                    ...List.generate(7, (index) =>
                                        GestureDetector(
                                            onTap: (){
                                              if(widget.isParent){
                                                showRegister(index);
                                              }
                                            },
                                            behavior: HitTestBehavior.translucent,
                                            child:
                                            Container(
                                              child: Row(
                                                children: [
                                                  CustomPaint(
                                                      painter: DashedLineVerticalPainter(),
                                                      size: Size(0.5, double.infinity)),
                                                  Container(width: index == 7 ? dayWidth-0.25 : dayWidth-0.5,)
                                                ],
                                              ),
                                            ))

                                    )

                                  ],

                                )
                            ),
                            //기본 길이
                            Container(height: 37,),
                            //최대길이

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
                              return
                                Container(
                                  height: ((preCount + nextCount + 1)* 21) + ((preCount + nextCount)*2) + 16,
                                )
                              ;


                            }),

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

                              double width = ((end.weekday % 7) - (start.weekday % 7) + 1) * dayWidth - 4;
                              double left = (start.weekday % 7) * dayWidth + 2;
                              double height = 21;
                              double top = ((height + 2)  * preCount) + 8;
                              return

                                Positioned(
                                  left: left,
                                  top: top,
                                  width: width,
                                  height: height,
                                  child:
                                  GestureDetector(
                                      onTap: (){showScheduleInfo(onDaySchedules[index]["scheduleId"], 0);},
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

                                        Text(onDaySchedules[index]["title"], style: TextStyle(letterSpacing: 0,fontSize: 11, height: 14/11, fontWeight: FontWeight.w700, fontFamily: "SUIT", color:MainTheme.planColor[int.parse(onDaySchedules[index]["color"])]),
                                            overflow: TextOverflow.ellipsis, maxLines:1
                                        ),
                                      )),
                                )
                              ;


                            }),

                          ],
                        ),

                      )
                    ],
                  ),
                ),
                SizedBox(height: 8,),

              ],)



                  : SizedBox.shrink(),


              Expanded(child:

              ClipRRect(
                borderRadius: screenIndex == 1 ? BorderRadius.circular(12) : BorderRadius.zero,
                child:  Container(
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(screenIndex == 1 ? 12 : 0)
                    ),
                    child : SingleChildScrollView(
                      controller: scrollController,
                        scrollDirection: Axis.vertical,
                        child :  screenIndex == 0 ?
                        Column(
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
                                            CachedNetworkImage(imageUrl:"http://openweathermap.org/img/wn/"
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
                                                        dates[index]["day"].day.toString(), style: TextStyle(fontSize: 13, fontFamily: "SUIT", fontWeight: FontWeight.w800, color: index%7 == 0


                                                          || (holidays[DateFormat("yyyyMMdd").format(dates[index]["day"])]??{"isHoliday":false})["isHoliday"]


                                                          ?
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
                            Container(
                              child: Column(
                                children: [

                                  ...List.generate((holidays[DateFormat("yyyyMMdd").format(selectDay)]??{"list":[]})["list"].length, (holiIndex) => Container(
                                    width: double.infinity,
                                    height: 48,
                                    margin: EdgeInsets.only(bottom: 10),
                                    decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(8),
                                        color: Colors.white
                                    ),
                                    padding: EdgeInsets.symmetric(horizontal: 20),
                                    child: Row(
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      children: [

                                        Container(
                                          width: 7,
                                          height: 7,
                                          decoration: BoxDecoration(
                                              borderRadius: BorderRadius.circular(2),
                                              color: MainTheme.planColor[0]
                                          ),
                                        ),
                                        Container(
                                          width: 6,
                                        ),
                                        Text("${holidays[DateFormat("yyyyMMdd").format(selectDay)]["list"][holiIndex]}", style: MainTheme.body8(MainTheme.gray7), overflow: TextOverflow.ellipsis,)
                                      ],
                                    ),

                                  ),),



                                ],
                              ),
                            ),
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
                                        onTap: (){
                                          if(widget.isParent){
                                            showScheduleInfo(daySchedule[index]["scheduleId"], daySchedule[index]["id"]);
                                          }else{
                                            showTimeTable(children[selectedChildIndex], selectDay, false);
                                          }

                                          },
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
                                                  daySchedule[index]["scheduleType"] == "PAY"?
                                                  Text("결제일", style: MainTheme.body8(MainTheme.gray7),) :
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
                                              SvgPicture.asset("assets/icons/${daySchedule[index]["scheduleType"]}_GRAY.svg",width: 24, height: 24,),
                                              SizedBox(width: 8,),
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
                        ):
                        Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                  decoration: MainTheme.roundBox(Colors.white),
                                  width: double.infinity,
                                  height: 1536 + 23,
                                  child :

                                  Stack(
                                    children: [
                                      Column(
                                        children: [
                                          SizedBox(height : 63.75 + 23),
                                          CustomPaint(
                                              painter: DashedLineHorizontalPainter(),
                                              size: Size(dashWidth, 0.5)),
                                          SizedBox(height : 63.5),
                                          CustomPaint(
                                              painter: DashedLineHorizontalPainter(),
                                              size: Size(dashWidth, 0.5)),
                                          SizedBox(height : 63.5),
                                          CustomPaint(
                                              painter: DashedLineHorizontalPainter(),
                                              size: Size(dashWidth, 0.5)),
                                          SizedBox(height : 63.5),
                                          CustomPaint(
                                              painter: DashedLineHorizontalPainter(),
                                              size: Size(dashWidth, 0.5)),
                                          SizedBox(height : 63.5),
                                          CustomPaint(
                                              painter: DashedLineHorizontalPainter(),
                                              size: Size(dashWidth, 0.5)),
                                          SizedBox(height : 63.5),
                                          CustomPaint(
                                              painter: DashedLineHorizontalPainter(),
                                              size: Size(dashWidth, 0.5)),
                                          SizedBox(height : 63.5),
                                          CustomPaint(
                                              painter: DashedLineHorizontalPainter(),
                                              size: Size(dashWidth, 0.5)),
                                          SizedBox(height : 63.5),
                                          CustomPaint(
                                              painter: DashedLineHorizontalPainter(),
                                              size: Size(dashWidth, 0.5)),
                                          SizedBox(height : 63.5),
                                          CustomPaint(
                                              painter: DashedLineHorizontalPainter(),
                                              size: Size(dashWidth, 0.5)),
                                          SizedBox(height : 63.5),
                                          CustomPaint(
                                              painter: DashedLineHorizontalPainter(),
                                              size: Size(dashWidth, 0.5)),
                                          SizedBox(height : 63.5),
                                          CustomPaint(
                                              painter: DashedLineHorizontalPainter(),
                                              size: Size(dashWidth, 0.5)),
                                          SizedBox(height : 63.5),
                                          CustomPaint(
                                              painter: DashedLineHorizontalPainter(),
                                              size: Size(dashWidth, 0.5)),
                                          SizedBox(height : 63.5),
                                          CustomPaint(
                                              painter: DashedLineHorizontalPainter(),
                                              size: Size(dashWidth, 0.5)),
                                          SizedBox(height : 63.5),
                                          CustomPaint(
                                              painter: DashedLineHorizontalPainter(),
                                              size: Size(dashWidth, 0.5)),
                                          SizedBox(height : 63.5),
                                          CustomPaint(
                                              painter: DashedLineHorizontalPainter(),
                                              size: Size(dashWidth, 0.5)),
                                          SizedBox(height : 63.5),
                                          CustomPaint(
                                              painter: DashedLineHorizontalPainter(),
                                              size: Size(dashWidth, 0.5)),
                                          SizedBox(height : 63.5),
                                          CustomPaint(
                                              painter: DashedLineHorizontalPainter(),
                                              size: Size(dashWidth, 0.5)),

                                          SizedBox(height : 63.5),
                                          CustomPaint(
                                              painter: DashedLineHorizontalPainter(),
                                              size: Size(dashWidth, 0.5)),
                                          SizedBox(height : 63.5),
                                          CustomPaint(
                                              painter: DashedLineHorizontalPainter(),
                                              size: Size(dashWidth, 0.5)),
                                          SizedBox(height : 63.5),
                                          CustomPaint(
                                              painter: DashedLineHorizontalPainter(),
                                              size: Size(dashWidth, 0.5)),
                                          SizedBox(height : 63.5),
                                          CustomPaint(
                                              painter: DashedLineHorizontalPainter(),
                                              size: Size(dashWidth, 0.5)),
                                          SizedBox(height : 63.5),
                                          CustomPaint(
                                              painter: DashedLineHorizontalPainter(),
                                              size: Size(dashWidth, 0.5)),
                                          SizedBox(height : 63.5),
                                          CustomPaint(
                                              painter: DashedLineHorizontalPainter(),
                                              size: Size(dashWidth, 0.5)),

                                        ],
                                      ),
                                      Row(
                                        children: [
                                          Column(
                                            children: [
                                              SizedBox(height: 23,),
                                              ...List.generate(13, (index) => Container(
                                                height: 64,
                                                width: 42,
                                                alignment: Alignment.center,
                                                child: Text(
                                                  index == 0 ? "" : "오전\n" + (index).toString() + "시", style: MainTheme.caption3(MainTheme.gray6),textAlign: TextAlign.center,
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
                                            height: 1536 + 23,
                                            child: Stack(
                                              children: [
                                                Row(
                                                  children: [
                                                    CustomPaint(
                                                        painter: DashedLineVerticalPainter(),
                                                        size: Size(0.5, 1536 + 23)),
                                                    SizedBox(width: dayWidth-0.5,),
                                                    CustomPaint(
                                                        painter: DashedLineVerticalPainter(),
                                                        size: Size(0.5, 1536 + 23)),
                                                    SizedBox(width: dayWidth-0.5,),
                                                    CustomPaint(
                                                        painter: DashedLineVerticalPainter(),
                                                        size: Size(0.5, 1536 + 23)),
                                                    SizedBox(width: dayWidth-0.5,),
                                                    CustomPaint(
                                                        painter: DashedLineVerticalPainter(),
                                                        size: Size(0.5, 1536 + 23)),
                                                    SizedBox(width: dayWidth-0.5,),
                                                    CustomPaint(
                                                        painter: DashedLineVerticalPainter(),
                                                        size: Size(0.5, 1536 + 23)),
                                                    SizedBox(width: dayWidth-0.5,),
                                                    CustomPaint(
                                                        painter: DashedLineVerticalPainter(),
                                                        size: Size(0.5, 1536 + 23)),
                                                    SizedBox(width: dayWidth-0.5,),
                                                    CustomPaint(
                                                        painter: DashedLineVerticalPainter(),
                                                        size: Size(0.5, 1536 + 23)),
                                                  ],
                                                ),


                                                ...List.generate(7, (index) => Positioned(
                                                    top: 0, left: dayWidth * index,
                                                    child: Container(
                                                      height: 1536,
                                                      width: dayWidth,
                                                      child: Column(

                                                        children: [

                                                          ...List.generate(24, (colIndex) =>
                                                              GestureDetector(
                                                                onTap: (){

                                                                  if(widget.isParent){
                                                                    showModalBottomSheet<Map>(
                                                                      useSafeArea: true,
                                                                      context: context,
                                                                      isScrollControlled: true,
                                                                      builder: (BuildContext context) {
                                                                        int hour = colIndex;
                                                                        DateTime date = selectDay.add(Duration(days: index));
                                                                        return RegisterPlan(initTime:DateTime(date.year,date.month, date.day, hour, 0, 0),childId: children[selectedChildIndex]["id"],);
                                                                      },
                                                                    ).then((value) async {
                                                                      if(value != null){
                                                                        if(screenIndex == 0){
                                                                          selectedChildIndex = value["index"] + 1;
                                                                        }else{
                                                                          selectedChildIndex = value["index"];
                                                                        }
                                                                        SharedPreferences pref = await SharedPreferences.getInstance();
                                                                        pref.setInt("selectedChildId", children[selectedChildIndex]["id"]);
                                                                      }

                                                                      if(screenIndex == 0){
                                                                        getMonthly();
                                                                      }else{
                                                                        getWeek();
                                                                        getWeekSchedule();
                                                                      }

                                                                      if(value != null){
                                                                        showScheduleInfo(value["id"], 0);
                                                                      }

                                                                    });
                                                                  }



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
                                                  double top = 64/60.0 * (start.difference(DateTime(start.year, start.month, start.day)).inMinutes);
                                                  top = top + 23;
                                                  int maxLine = (height.toInt() - 6) ~/ 14;
                                                  return Positioned(
                                                      left: left,
                                                      top: top,

                                                      child : GestureDetector(
                                                          onTap: () {
                                                            if (weekList[index]["scheduleId"] !=
                                                                0) {
                                                              showScheduleInfo(
                                                                  weekList[index]["scheduleId"],
                                                                  weekList[index]["id"]);
                                                            }
                                                          },

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
                                    ],
                                  )

                              ),

                            ]
                        )

                      //주간 일정-----------------------------------------


                    )
                ),
              ),





              ),

          screenIndex == 1 ? SizedBox(height: 8,) : SizedBox.shrink()

            ],
          ),

        ),
        floatingActionButton:
        (screenIndex == 0 && widget.isParent) ? GestureDetector(
          behavior: HitTestBehavior.translucent,
          onTap: (){
            showModalBottomSheet<Map>(
              useSafeArea: true,
              context: context,
              isScrollControlled: true,
              builder: (BuildContext context) {
                return RegisterPlan(initTime:DateTime(selectDay.year, selectDay.month, selectDay.day, selectDay.hour + 1, 0, 0),
                  childId: children[selectedChildIndex]["id"],
                );
              },
            ).then((value) async {
              if(value != null){
                if(screenIndex == 0){
                  selectedChildIndex = value["index"] + 1;
                }else{
                  selectedChildIndex = value["index"];
                }
                SharedPreferences pref = await SharedPreferences.getInstance();
                pref.setInt("selectedChildId", children[selectedChildIndex]["id"]);

              }

              if(screenIndex == 0){
                getMonthly();
              }else{
                getWeek();
                getWeekSchedule();
              }

              if(value != null){
                showScheduleInfo(value["id"], 0);
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
    setState(() {
      carouselController.jumpToPage(1);
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
    if(widget.isParent){
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
          getDaily();
        }else{
          getWeek();
          getWeekSchedule();
        }
      });
    }else{
      showModalBottomSheet<void>(
        context: context,
        isScrollControlled: true,
        builder: (BuildContext context) {
          return StatefulBuilder(builder:
              (BuildContext context, StateSetter setState){
            return ScheduleInfoChild(scheduleId: scheduleId, calendarId:  calendarId,);

          }
          );


        },
      );
    }


  }

  void showTimeTable(Map map, DateTime date, bool parentSelf){

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return StatefulBuilder(builder:
            (BuildContext context, StateSetter setState){
          return TimeTable(map: map, dateTime: date, isParent: widget.isParent, parentSelf:  parentSelf,);

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

    var responseResult = await apiRequestGet(context, "https://api.openweathermap.org/data/2.5/weather",  {"lat" :position.latitude.toString(), "lon": position.longitude.toString(), "appid": weatherKey});
    var response =jsonDecode(utf8.decode(responseResult.bodyBytes));

    if(response["cod"] == 200){
      if (this.mounted) {
        setState(() {weather = response;});
      }
    }


  }


  OverlayEntry selectChild() {
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
                                    onTap: ()async{
                                      SharedPreferences pref = await SharedPreferences.getInstance();
                                      setState(()  {
                                        selectedChildIndex = index;
                                        if(screenIndex == 0){
                                          pref.setInt("selectedChildId", children[index]["id"]);
                                          getMonthly();

                                          getDaily();
                                        }else{
                                          pref.setInt("selectedChildId", children[index]["id"]);
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
                                              children[index]["id"] == 0 ?
                                              SvgPicture.asset("assets/icons/ic_all.svg",width: 24, height: 24, ) :
                                              children[index]["id"] == -1 ?
                                              SvgPicture.asset("assets/icons/ic_reci.svg",width: 24, height: 24, ) :
                                              CachedNetworkImage(imageUrl:
                                              children[index]["fileUrl"] ?? "",
                                                width : 24,
                                                height: 24,
                                                fit: BoxFit.cover,
                                                errorWidget: (context, url, error) {
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
    if(widget.isParent){

      weekChildren = [];
      monthChildren = [];
      SharedPreferences pref = await SharedPreferences.getInstance();

      int? selectedChildId = pref.getInt("selectedChildId");

      //월별일정 자식 목록 채우기
      monthChildren.add({"name" :"전체", "fileUrl" :  "", "id" : 0});


      var response = await apiRequestGet(context, urlChildren,  {});
      var body =jsonDecode(utf8.decode(response.bodyBytes));

      if(response.statusCode == 200){
        for(var child in body["data"]){
          weekChildren.add({
            "name" : child["name"],
            "fileUrl" : child["fileUrl"],
            "id" : child["id"],
            "schoolCode" : child["schoolCode"],
            "grade": child["grade"],
            "schoolClass": child["schoolClass"],
          });
          monthChildren.add({
            "name" : child["name"],
            "fileUrl" : child["fileUrl"],
            "id" : child["id"],
            "schoolCode" : child["schoolCode"],
            "grade": child["grade"],
            "schoolClass": child["schoolClass"],
          });
        }
      }
      monthChildren.add({"name" :pref.getString("name"), "fileUrl" :  pref.getString("profile"), "id" : pref.getInt("userId")});
      weekChildren.add({"name" :pref.getString("name"), "fileUrl" :  pref.getString("profile"), "id" : pref.getInt("userId")});
      monthChildren.add({
        "name" : "결제일",
        "fileUrl" : "",
        "id" : -1
      });

      children = weekChildren;


      //다른페이지에 갔다왔을 때 저장
      if(selectedChildId != null){
        for(int i = 0 ; i < children.length; i++){
          if(children[i]["id"] == selectedChildId){
            setState(() {
              selectedChildIndex = i;
            });
          }
        }
      }


      setWeeks();
      getWeek();
      getWeekSchedule();



      scrollController.jumpTo(535);
    }else{
      SharedPreferences pref = await SharedPreferences.getInstance();
      children[0]["name"] = pref.getString("name");
      children[0]["fileUrl"] = pref.getString("profile");
      children[0]["id"] = pref.getInt("userId")!;

      //내 정보 조회
      var response = await apiRequestGet(context, urlMy,{});
      var body = jsonDecode(utf8.decode(response.bodyBytes));
      if(response.statusCode == 200){
        children[0]["schoolCode"] = body["data"]["schoolCode"];
        children[0]["grade"] = body["data"]["grade"];
        children[0]["schoolClass"] = body["data"]["schoolClass"];
      }

      setWeeks();
      getWeek();
      getWeekSchedule();
      scrollController.jumpTo(535);
    }


  }

  Future<void> getMonthly() async {
    holidays = {};
    String payOnly = "false";
    List<String> idList = [];
    if(widget.isParent && screenIndex == 0){
      if(selectedChildIndex == 0 || selectedChildIndex == monthChildren.length-1){
        for(int i = 1; i < monthChildren.length-1 ; i++){
          idList.add(children[i]["id"].toString());
        }
      }else {
        idList.add(children[selectedChildIndex]["id"].toString());
      }
      if(selectedChildIndex == monthChildren.length-1){
        payOnly = "true";
      }
    }else{
      idList.add(children[selectedChildIndex]["id"].toString());
    }

    var response = await apiRequestGet(context, urlMonthly,  {"payOnly" : payOnly, "commonMemberIdList" : idList.join(","),  "monthStartDate" : DateFormat('yyyy-MM-dd').format(selectMonth())});
    var body =jsonDecode(utf8.decode(response.bodyBytes));
    if(response.statusCode == 200){
      monthSchedule = body["data"];
    }

    //휴일정보 받아옴
    var holidayResponse = await openApiXmlRequestGet(urlHoliday,  {"ServiceKey" : holidayKey, "solYear" : selectDay.year.toString(),  "solMonth" : (selectDay.month < 10 ? "0" : "") + selectDay.month.toString()});
    if(holidayResponse.statusCode == 200){
      var holidayBody = XmlDocument.parse(utf8.decode(holidayResponse.bodyBytes));
      var itemList = holidayBody.lastChild?.lastChild?.firstChild?.childElements;
      if(itemList != null){
        for(int i = 0; i< itemList!.length; i++){
          if(holidays[itemList?.elementAt(i).findElements("locdate").single.innerText] == null){
            holidays[itemList?.elementAt(i).findElements("locdate").single.innerText] = {"isHoliday" : false, "list" : []};
          }
          holidays[itemList?.elementAt(i).findElements("locdate").single.innerText]["isHoliday"] = itemList?.elementAt(i).findElements("isHoliday").single.innerText == "Y";
          holidays[itemList?.elementAt(i).findElements("locdate").single.innerText]["list"].add(itemList?.elementAt(i).findElements("dateName").single.innerText);
        }
      }

    }

    //절기정보 받아옴
    holidayResponse = await openapiRequestGet(context, urlJulgi,  {"ServiceKey" : holidayKey, "solYear" : selectDay.year.toString(),  "solMonth" : (selectDay.month < 10 ? "0" : "") + selectDay.month.toString()});
    if(holidayResponse.statusCode == 200){
      var holidayBody = XmlDocument.parse(utf8.decode(holidayResponse.bodyBytes));

      var itemList = holidayBody.lastChild?.lastChild?.firstChild?.childElements;
      if(itemList != null){
        for(int i = 0; i< itemList!.length; i++){

          if(holidays[itemList?.elementAt(i).findElements("locdate").single.innerText] == null){
            holidays[itemList?.elementAt(i).findElements("locdate").single.innerText] = {"isHoliday" : false, "list" : []};
          }
          holidays[itemList?.elementAt(i).findElements("locdate").single.innerText]["list"].add(itemList?.elementAt(i).findElements("dateName").single.innerText);
        }
      }

    }
    setState(() {

    });
  }

  Future<void> getDaily() async {
    String payOnly = "false";
    List<String> idList = [];
    if(widget.isParent && screenIndex == 0){
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
    var response = await apiRequestGet(context, urlDaily,  {"payOnly" : payOnly, "commonMemberIdList" : idList.join(","), "dayDate" :DateFormat('yyyy-MM-dd').format(selectDay)});
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
    var response = await apiRequestGet(context, urlWeek,  {"commonMemberIdList" : children[selectedChildIndex]["id"].toString(), "commonMemberId" : children[selectedChildIndex]["id"].toString(), "weekStartDate" :DateFormat('yyyy-MM-dd').format(selectDay)});
    var body =jsonDecode(utf8.decode(response.bodyBytes));
    if(response.statusCode == 200){
      List temp = [];

      for(int i = 0; i <body["data"].length; i++){
        if(!body["data"][i]["isAllDay"]){
          // if(DateTime.parse('${body["data"][i]["startDate"]} ${body["data"][i]["startTime"]}').isBefore(DateTime.parse('${body["data"][i]["startDate"]} 06:00'))){
          //   body["data"][i]["startTime"] = "06:00";
          // }
          var start = DateTime.parse(body["data"][i]["startDate"] + " " + body["data"][i]["startTime"]);
          var end = DateTime.parse(body["data"][i]["endDate"] + " " + body["data"][i]["endTime"]);
          if(end.difference(start).inSeconds < 1800){
            var endOfDay = DateTime(start.year, start.month, start.day, 23, 59, 59);
            end = start.add(Duration(seconds: 1800));
            if(end.isAfter(endOfDay)){
              end = endOfDay;
            }
          }
          body["data"][i]["start"] = start;
          body["data"][i]["end"] = end;
          temp.add(body["data"][i]);
        }

      }
      weekList = temp;

      if(school){

        if(children[selectedChildIndex]["schoolCode"] != null){
          String schoolCode = children[selectedChildIndex]["schoolCode"];
          if(children[selectedChildIndex]["schoolCode"].contains(":")){
            var schoolTimeResponse = await apiRequestGet(context, urlSchoolTime,{
              "ATPT_OFCDC_SC_CODE" : schoolCode.split(":")[0],
              "SD_SCHUL_CODE" :schoolCode.split(":")[1],
              "KEY": schoolKey,
              "GRADE" : children[selectedChildIndex]["grade"],
              "CLASS_NM" : children[selectedChildIndex]["schoolClass"],
              "TI_FROM_YMD" : DateFormat('yyyyMMdd').format(selectDay),
              "TI_TO_YMD" : DateFormat('yyyyMMdd').format(selectDay.add(Duration(days: 6)))}
            );
            var schoolTimeBody =jsonDecode(utf8.decode(schoolTimeResponse.bodyBytes));
            if(schoolTimeResponse.statusCode == 200){
              if(schoolTimeBody["elsTimetable"] != null){
                var timeList = schoolTimeBody["elsTimetable"][1]["row"];
                for(int i = 0; i<timeList.length; i++){
                  if(timeList[i]["ITRT_CNTNT"] != null){
                    timeList[i]["start"] = parseDateTime(timeList[i]["ALL_TI_YMD"] + " " + eleTimes[children[selectedChildIndex]["grade"] + "-" + timeList[i]["PERIO"]]);
                    timeList[i]["end"] = timeList[i]["start"].add(const Duration(minutes: 40));
                    timeList[i]["id"] = 0;
                    timeList[i]["scheduleId"] = 0;
                    timeList[i]["title"] = timeList[i]["ITRT_CNTNT"]??"미정";
                    timeList[i]["color"] = "1";
                    weekList.add(timeList[i]);
                  }
                }
              }
            }
          }
        }


      }
      weekList.sort((a, b) => a["start"].compareTo(b["start"]));
      setState(() {

      });
    }

  }
  DateTime parseDateTime(String dateTimeString) {
    String year = dateTimeString.substring(0, 4);
    String month = dateTimeString.substring(4, 6);
    String day = dateTimeString.substring(6, 8);
    String hour = dateTimeString.substring(9, 11);
    String minute = dateTimeString.substring(12, 14);

    return DateTime(int.parse(year), int.parse(month), int.parse(day),
        int.parse(hour), int.parse(minute));
  }
  Future<void> getWeekSchedule() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    var response = await apiRequestGet(context, urlWeekSchedule,  {"commonMemberId" : children[selectedChildIndex]["id"].toString(), "weekStartDate" :DateFormat('yyyy-MM-dd').format(selectDay)});
    var body =jsonDecode(utf8.decode(response.bodyBytes));
    if(response.statusCode == 200){
      List temp = [];
      for(int i = 0; i <body["data"].length; i++){
        if(body["data"][i]["isAllDay"] || (body["data"][i]["startDate"] != body["data"][i]["endDate"] || body["data"][i]["isBetween"])){
          if(DateTime.parse('${body["data"][i]["startDate"]}').isBefore(DateTime(selectDay.year, selectDay.month, selectDay.day))){
            body["data"][i]["startDate"] = DateFormat('yyyy-MM-dd').format(selectDay);
          }
          if(DateTime.parse('${body["data"][i]["endDate"]}').isAfter(DateTime(selectDay.year, selectDay.month, selectDay.day).add(Duration(days: 6)))){
            body["data"][i]["endDate"] = DateFormat('yyyy-MM-dd').format(DateTime(selectDay.year, selectDay.month, selectDay.day).add(Duration(days: 6)));
          }

          body["data"][i]["start"] = DateTime.parse(body["data"][i]["startDate"] + " " + (body["data"][i]["startTime"]?? "00:00"));
          body["data"][i]["end"] = DateTime.parse(body["data"][i]["endDate"] + " " + (body["data"][i]["endTime"]?? "00:00"));
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

  DateTime exMonth(){
    DateTime now = DateTime.now();
    int dif =DateTime(now.year, now.month, now.day).difference(DateTime(selectDay.year, selectDay.month, selectDay.day)).inDays;
    if(dif <= 6 && dif >=0){
      return DateTime.now();
    }else{
      return selectDay;
    }
  }

  void showRegister(int index){
    showModalBottomSheet<Map>(
      useSafeArea: true,
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return RegisterPlan(initTime:selectDay.add(Duration(days: index)),childId: children[selectedChildIndex]["id"],onday: true,);
      },
    ).then((value) async {
      if(value != null){
        if(screenIndex == 0){
          selectedChildIndex = value["index"] + 1;
        }else{
          selectedChildIndex = value["index"];
        }
        SharedPreferences pref = await SharedPreferences.getInstance();
        pref.setInt("selectedChildId", children[selectedChildIndex]["id"]);

      }

      if(screenIndex == 0){
        getMonthly();
      }else{
        getWeek();
        getWeekSchedule();
      }

      if(value != null){
        showScheduleInfo(value["id"], 0);
      }

    });
  }

}
