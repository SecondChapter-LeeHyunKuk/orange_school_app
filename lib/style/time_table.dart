import 'dart:async';
import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_svg/svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:simple_shadow/simple_shadow.dart';

import '../util/api.dart';
import 'main-theme.dart';
String urlChart = "${dotenv.env['BASE_URL']}user/timeTable";
String urlMemo = "${dotenv.env['BASE_URL']}user/timeTable/message";




class TimeTable extends StatefulWidget {

  final Map map;
  final DateTime dateTime;
  final bool isParent;
  const TimeTable ({ Key? key, required this.map, required this.dateTime , required this.isParent}): super(key: key);

  @override
  _TimeTable createState() => _TimeTable();
}

class _TimeTable extends State<TimeTable> {
  Timer? _timer = null;
  LayerLink _layerLink = LayerLink();
  OverlayEntry? _overlayEntry;
  List daySchedule = [];
  Future<http.Response>? getFuture;
  List chartList = [];
  TextEditingController te_parentMemo = TextEditingController();
  TextEditingController te_ChildMemo = TextEditingController();
  bool parentReadOnly = true;
  bool childReadOnly = true;

  @override
  void initState() {
    super.initState();
    getFuture = getChart();
    getMemo();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height:MediaQuery.of(context).size.height * 0.9,
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
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [


                  GestureDetector(
                    onTap: (){Navigator.pop(context);},
                    behavior: HitTestBehavior.translucent,
                    child:
                    SvgPicture.asset("assets/icons/close.svg",width: 30, height: 30,),
                  ),
                  SizedBox(width: 16,)

                ]
            ),

          ),
          Expanded(child: SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child:
              Container(
                width: double.infinity,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Positioned(child:
                    SimpleShadow(
                      child:SvgPicture.asset('assets/images/chart_bg.svg',
                          width: 329,
                          height: 363),
                      opacity: 0.05,         // Default: 0.5
                      color: Colors.black,   // Default: Black
                      offset: Offset(0, 0), // Default: Offset(2, 2)
                      sigma: 20,             // Deffault: 2
                    )
                      ,top: 53,),


                    Positioned(
                      top: 118,
                      width: 266,
                      height: 266,
                      child:
                      CompositedTransformTarget(
                        link: _layerLink,
                      child:
                      PieChart(
                        PieChartData(
                            pieTouchData: PieTouchData(
                              touchCallback: (FlTouchEvent event, PieTouchResponse? touchResponse) {
                                if(touchResponse != null){
                                  if(touchResponse.touchedSection!.touchedSectionIndex >= 0 && chartList[touchResponse.touchedSection!.touchedSectionIndex]["color"] != null){
                                    if (_overlayEntry != null) {
                                      _removeOverlay();
                                      if(_timer != null){
                                        _timer!.cancel();
                                      }
                                    }
                                    if (_overlayEntry == null) {
                                      _overlayEntry = _titleInfo(event.localPosition!.dx, event.localPosition!.dy, touchResponse.touchedSection!.touchedSectionIndex);
                                      Overlay.of(context)?.insert(_overlayEntry!);
                                      _startTimer();
                                    }
                                  }
                                }


                              },
                            ),
                            startDegreeOffset: 270,
                            sectionsSpace: 6,
                            centerSpaceRadius: 0,
                            sections: [
                              ...List.generate(chartList.length, (index) =>

                                  PieChartSectionData(
                                      color: chartList[index]["color"] == null ? Color(0xffffffff) : MainTheme.planBgColor[int.parse(chartList[index]["color"])],
                                      value: chartList[index]["min"] * 1.0,
                                      title:
                                          //빈시간은 표시 안함
                                      chartList[index]["color"] == null ? "" :
                                          //1시간 이하 표시 안함
                                      chartList[index]["min"] * 1.0 < 60 ? "" :
                                          //2시간 미만 2글자 이상이면 .. 처리
                                      //chartList[index]["min"] * 1.0 <= 120 ? chartList[index]["title"].length > 2 ? chartList[index]["title"].substring(0,2) + ".." : chartList[index]["title"] :
                                      chartList[index]["min"] * 1.0 <= 180 ? chartList[index]["title"].length > 4 ? chartList[index]["title"].substring(0,4) + ".." : chartList[index]["title"] :
                                      chartList[index]["title"].length > 9 ? chartList[index]["title"].substring(0,5) + "\n" + chartList[index]["title"].substring(5, 9) + "..." :
                                      chartList[index]["title"].length == 9 ? chartList[index]["title"].substring(0,5) + "\n" + chartList[index]["title"].substring(5, 9) :
                                      chartList[index]["title"],
                                      radius: 133,
                                      titlePositionPercentageOffset : 0.7,
                                      titleStyle: MainTheme.caption1(chartList[index]["color"] == null ? Color(0xffed6a6a) : MainTheme.planColor[int.parse(chartList[index]["color"])])
                                  )

                              )
                              ,
                              // PieChartSectionData(
                              //     color: MainTheme.planBgColor[1],
                              //     value: 17,
                              //     title: '학교',
                              //     radius: 133,
                              //     titlePositionPercentageOffset : 0.7,
                              //     titleStyle: MainTheme.caption1(MainTheme.planColor[1])
                              // ),
                              // PieChartSectionData(
                              //     color: MainTheme.planBgColor[2],
                              //     value: 16,
                              //     title: '방과 후 교실',
                              //     radius: 133,
                              //     titlePositionPercentageOffset : 0.7,
                              //     titleStyle: MainTheme.caption1(MainTheme.planColor[2])
                              // ),
                              // PieChartSectionData(
                              //     color: MainTheme.planBgColor[3],
                              //     value: 23,
                              //     title: '차량 승하차',
                              //     radius: 133,
                              //     titlePositionPercentageOffset : 0.7,
                              //     titleStyle: MainTheme.caption1(MainTheme.planColor[3])
                              // ),
                              // PieChartSectionData(
                              //     color: MainTheme.planBgColor[4],
                              //     value: 22,
                              //     title: '일정',
                              //     radius: 133,
                              //     titlePositionPercentageOffset : 0.7,
                              //     titleStyle: MainTheme.caption1(MainTheme.planColor[4])
                              // ),
                              // PieChartSectionData(
                              //     color: MainTheme.planBgColor[5],
                              //     value: 24,
                              //     title: '결제일',
                              //     radius: 133,
                              //     titlePositionPercentageOffset : 0.7,
                              //     titleStyle: MainTheme.caption1(MainTheme.planColor[5])
                              // ),

                            ]
                        ),
                      ),)
                    ),
                    Column(
                      children: [
                        Container(
                          height: 434,
                        ),



                        Padding(padding: EdgeInsets.symmetric(horizontal: 16),
                            child:Column(
                              children: [
                                Container(
                                  height: 79,
                                  width: double.infinity,
                                  decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(16),
                                      border: Border.all(width: 1, color: MainTheme.gray3)
                                  ),
                                  child:

                                  Stack(
                                    children: [
                                      Positioned(
                                        top:15,
                                        left: 18,
                                        child: Text("부모님 메모", style : MainTheme.body8(MainTheme.gray6)),),
                                      Row(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          SizedBox(width: 18,),
                                          Expanded(child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              SizedBox(height: 25,),
                                              SizedBox(height: 4,),
                                              Container(
                                                height: 40,
                                                child: TextField(

                                                  readOnly: parentReadOnly,
                                                  controller: te_parentMemo,
                                                  decoration: InputDecoration(
                                                    isDense: true,
                                                    focusedBorder: InputBorder.none,
                                                    enabledBorder: InputBorder.none,
                                                    border: InputBorder.none,
                                                    hintText: "메모가 없어요",
                                                    hintStyle: MainTheme.body5(MainTheme.gray4),
                                                  ),
                                                  style: MainTheme.body5(MainTheme.gray7),
                                                ),

                                              )
                                            ],
                                          )),
                                          widget.isParent ? GestureDetector(
                                            behavior: HitTestBehavior.translucent,
                                            onTap: (){
                                              if(!parentReadOnly){
                                                saveMemo();
                                              }
                                              setState(() {
                                                parentReadOnly = !parentReadOnly;
                                              });
                                            },
                                            child: Container(
                                              width: 36,
                                              height: 36,
                                              margin: EdgeInsets.only(top: 13, right: 13),
                                              decoration: BoxDecoration(
                                                  color: MainTheme.gray1,
                                                  shape: BoxShape.circle
                                              ),
                                              alignment: Alignment.center,
                                              child : parentReadOnly ? SvgPicture.asset('assets/icons/ic_16_edit.svg', width: 16, height: 16) : Icon(Icons.check, size: 16, color:MainTheme.gray7),
                                            ),
                                          ) : SizedBox.shrink()

                                        ],
                                      ),
                                    ],

                                  )

                                ),
                                SizedBox(height: 12,),
                                Container(
                                  height: 79,
                                  width: double.infinity,
                                  decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(16),
                                      border: Border.all(width: 1, color: MainTheme.gray3)
                                  ),
                                  child:

                                  Stack(
                                    children: [
                                      Positioned(
                                        top:15,
                                        left: 18,
                                        child: Text("아이 메모", style : MainTheme.body8(MainTheme.gray6)),),
                                      Row(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          SizedBox(width: 18,),
                                          Expanded(child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              SizedBox(height: 25,),
                                              SizedBox(height: 4,),
                                              Container(
                                                height: 40,
                                                child:TextField(
                                                  controller: te_ChildMemo,
                                                  readOnly: childReadOnly,
                                                  decoration: InputDecoration(
                                                    isDense: true,
                                                    focusedBorder: InputBorder.none,
                                                    enabledBorder: InputBorder.none,
                                                    border: InputBorder.none,
                                                    hintText: "메모가 없어요",
                                                    hintStyle: MainTheme.body5(MainTheme.gray4),
                                                  ),
                                                  style: MainTheme.body5(MainTheme.gray7),
                                                ),

                                              )
                                            ],
                                          )),
                                          !widget.isParent ?
                                          GestureDetector(
                                            behavior: HitTestBehavior.translucent,
                                            onTap: (){
                                              if(!childReadOnly){
                                                saveMemo();
                                              }
                                              setState(() {
                                                childReadOnly = !childReadOnly;
                                              });
                                            },
                                            child: Container(
                                              width: 36,
                                              height: 36,
                                              margin: EdgeInsets.only(top: 13, right: 13),
                                              decoration: BoxDecoration(
                                                  color: MainTheme.gray1,
                                                  shape: BoxShape.circle
                                              ),
                                              alignment: Alignment.center,
                                              child : childReadOnly ? SvgPicture.asset('assets/icons/ic_16_edit.svg', width: 16, height: 16) : Icon(Icons.check, size: 16, color:MainTheme.gray7),
                                            ),
                                          ) : SizedBox.shrink()

                                        ],
                                      ),
                                    ],

                                  )

                                ),
                                Container(height: 8,),
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

                                          Container(
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

                                    ],
                                  ),
                                ),

                              ],
                            )
                        ),
                        SizedBox(height: 18,),


                      ],
                    ),



                    Positioned(
                      top: 1,
                      child: Container(
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Container(
                              width: 36,
                              height: 36,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(300.0),
                                child:
                                CachedNetworkImage(imageUrl:
                                  widget.map["fileUrl"] ?? "",
                                  width : 30,
                                  height: 30,
                                  fit: BoxFit.cover,
                                  errorWidget: (context, url, error) {
                                    return SvgPicture.asset("assets/icons/profile_${(widget.map["id"]%3) + 1}.svg",width: 30, height: 30, );
                                  },
                                ),

                              ),
                            ),

                            Container(width: 11,),
                            Text(widget.map["name"],style: MainTheme.body5(MainTheme.gray7),)
                          ],
                        ),

                      ),
                    ),
                    Positioned(
                      top: 45,
                      child: Container(
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(4),
                            color: MainTheme.mainColor.withOpacity(0.1)
                        ),
                        padding: EdgeInsets.fromLTRB(7,3,7,3),


                        child:Text(DateFormat('yyyy.MM.dd.E', 'ko').format(widget.dateTime),style: MainTheme.caption1(MainTheme.mainColor),),

                      ),
                    ),


                  ],
                ),

              )



          ),),


          SizedBox(
            height: MediaQuery.of(context).viewInsets.bottom,
          )
        ],
      )


      ,

    );

  }


  Future<http.Response> getChart() async {
    var response = await apiRequestGet(urlChart,{"commonMemberId" : widget.map["id"].toString(), "dayDate" : DateFormat("yyyy-MM-dd").format(widget.dateTime)});
    var body =jsonDecode(utf8.decode(response.bodyBytes));
    if(response.statusCode == 200){
      chartList = body["data"];
      //하루종일 아닌것만 필터링
      chartList = chartList.where((element) => !element['isAllDay']).toList();
      if(chartList.isEmpty){
        chartList.add({"min" : 1440, "title": getTimes(1440), "color": null});
      }else{
        //한개라도 표시할게 있는 경우
        //시간 세팅
        for(int i = 0; i < chartList.length; i++){
          chartList[i]["start"] = DateTime.parse( chartList[i]["startDate"] + " " + chartList[i]["startTime"]);
          chartList[i]["end"] = DateTime.parse( chartList[i]["endDate"] + " " +  chartList[i]["endTime"]);
          if(chartList[i]["endTime"] == "00:00:00"){
                chartList[i]["end"]  = chartList[i]["end"].add(Duration(days: 1));
          }
        }

        //id 순으로 소팅
        chartList.sort((a, b) => a['id'].compareTo(b['id']));
        List deletedIndex = [];

        //겹치는 시간 제거
        for(int i = 0; i < chartList.length; i++){
          for(int j = i+1; j < chartList.length; j++){
            if(!deletedIndex.contains(i)){
              if(chartList[i]["start"].isBefore(chartList[j]["end"]) || chartList[i]["end"].isAfter(chartList[j]["start"])){

                deletedIndex.add(j);
              }
            }
          }
        }

        List varList = [];

        //시작 시간 순으로 소팅
        chartList.sort((a, b) => a['start'].isBefore(b['start']) ? -1 : 1);

        //맨 처음 시간이 0시 이후일 경우 0시부터 빈 시간 세팅
        if(chartList[0]["start"].isAfter(DateTime.parse(chartList[0]["startDate"]))){

          int interval = chartList[0]["start"].difference(DateTime.parse(chartList[0]["startDate"])).inMinutes;
          varList.add({"min" : interval, "title": getTimes(interval), "color": null});
        }

          for(int i = 0; i < chartList.length; i++){
            chartList[i]["min"] = chartList[i]["end"].difference(chartList[i]["start"]).inMinutes;

            varList.add(chartList[i]);
            if(i < chartList.length-1){
              if(chartList[i]["end"].isBefore(chartList[i + 1]["start"])){
                int interval = chartList[i+1]["start"].difference(chartList[i]["end"]).inMinutes;
                varList.add({"min" : interval, "title": getTimes(interval), "color": null});
              }
            }
          }


        //맨 마지막시간이 다음날 0시 이전이면 인터벌 세팅
        if(chartList[chartList.length-1]["end"].isBefore(DateTime.parse(chartList[chartList.length-1]["endDate"]).add(Duration(days: 1)))){
          int interval = DateTime.parse(chartList[chartList.length-1]["endDate"]).add(Duration(days: 1)).difference(chartList[chartList.length-1]["end"]).inMinutes;
          varList.add({"min" : interval, "title": getTimes(interval), "color": null});
        }
        chartList = varList;
      }

      if(chartList.length == 0){
        chartList.add({"min" : 1440, "title": getTimes(1440), "color": null});
      }



      setState(() {
        daySchedule = body["data"];
      });
    }
    return response;
  }

  String getTimes(int min){
    return "${min ~/ 60}시간 ${min % 60}분";
  }

  Future<void> getMemo() async {

    var response = await apiRequestGet(urlMemo + "/" + widget.map["id"].toString(),{"dayDate" : DateFormat('yyyy-MM-dd').format(widget.dateTime)});
    var body =jsonDecode(utf8.decode(response.bodyBytes));
    if(response.statusCode == 200){
      setState(() {
        if(body["data"]["parentMessage"] != null){
          te_parentMemo.text = body["data"]["parentMessage"];
        }
        if(body["data"]["childMessage"] != null){
          te_ChildMemo.text = body["data"]["childMessage"];
        }
      });
    }
  }

  Future<void> saveMemo() async {
    var request = {};
    request["dayDate"] = DateFormat("yyyy-MM-dd").format(widget.dateTime);
    request["memberType"] = widget.isParent ? "PARENT" : "CHILD";
    request["parentMessage"] = te_parentMemo.text == "" ? null : te_parentMemo.text;
    request["childMessage"] =  te_ChildMemo.text == "" ? null : te_ChildMemo.text;
    var response = await apiRequestPost(urlMemo + "/" + widget.map["id"].toString(),request);
    var body =jsonDecode(utf8.decode(response.bodyBytes));
    if(response.statusCode == 200){
      Fluttertoast.showToast(
          msg: "메시지가 등록되었습니다.",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.black,
          textColor: Colors.white,
          fontSize: 16.0
      );
    }
  }
  OverlayEntry _titleInfo(double x, double y, int index){
    bool left  = x < MediaQuery.of(context).size.width/2;

    return OverlayEntry(
      builder: (context) => SizedBox(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        child: Stack(
          children: [
            ModalBarrier(
              onDismiss: () {
                if(_timer != null){
                  _timer!.cancel();
                }
                _removeOverlay();
              },
            ),
      CompositedTransformFollower(
        link: _layerLink,
        showWhenUnlinked: false,
        offset: Offset(x-45, y),
        child:
            Material(
              color: Colors.transparent,
              child: Container(
                padding: EdgeInsets.all(10),
                width: 90,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(5)),
                    color: Colors.black.withOpacity(0.5)
                ),
                child:
                chartList[index]["title"].length <= 4 ?
                Text(chartList[index]["title"], style: MainTheme.body6(Colors.white),textAlign: TextAlign.center,) :

                  chartList[index]["title"].length <= 8 ?
                  Text(chartList[index]["title"].substring(0,4) + "\n" + chartList[index]["title"].substring(4), style: MainTheme.body6(Colors.white),) :
                  Text(chartList[index]["title"].substring(0,4) + "\n" + chartList[index]["title"].substring(4, 8) + "...", style: MainTheme.body6(Colors.white),)
              ),
            )


            // Positioned(
            //   left: left ? x + 40 : null,
            //   right : left ? null : MediaQuery.of(context).size.width - x+ 40,
            //   top: 0,
            //   child: Container(
            //     width: 100,
            //     height: 100,
            //     color: Colors.white,
            //   )
            // ),

      )
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
    if(_timer != null){
      _timer!.cancel();
    }
    _overlayEntry?.remove();
    _overlayEntry?.dispose();
    super.dispose();
  }

  void _startTimer() {
    if(_timer != null){
      if(_timer!.isActive){
        _timer!.cancel();
      }
    }
    _timer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if(_timer != null){
        if(_timer!.isActive){
          _timer!.cancel();
          _removeOverlay();
        }
      }
    });
  }
}

