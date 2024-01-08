import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_svg/svg.dart';
import 'package:http/http.dart';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:orange_school/main.dart';
import 'package:orange_school/style/main-theme.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:flutter/foundation.dart' as foundation;
import 'package:orange_school/style/payment_info.dart';
import 'package:orange_school/style/register_payment.dart';
import 'package:orange_school/view/common/register_parent.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:speech_balloon/speech_balloon.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../style/month_picker.dart';
import '../../util/api.dart';





String urlPayment = "${dotenv.env['BASE_URL']}user/payment";
String urlChart = "${dotenv.env['BASE_URL']}user/payment/graph";
String urlChildren = "${dotenv.env['BASE_URL']}user/commonMembers";
String urlBanner = "${dotenv.env['BASE_URL']}user/banners";

class ParentPayment extends StatefulWidget {
  @override
  State<ParentPayment> createState() => _ParentPayment();
}

class _ParentPayment extends State<ParentPayment> {

  final GlobalKey _widgetKey = GlobalKey();
  DateTime selectMonth = DateTime(DateTime.now().year, DateTime.now().month, 1);
  int paySum = 0;
  int previousMonth = 0;

  List images  = [];
  ScrollController mainScrollController = ScrollController();
  ScrollController chartScrollController = ScrollController();
  //아이 색상 매핑
  Map color = {};

  //차트 데이터
  List money = [
  ];

  //자식들
  List children = [
  ];

  //그달 결제기록
  List payments = [];

  Map<String, int> mappping = new Map();

  //차트 최고 지출
  int maxAmount = 0;


  var activeIndex = 0;

  // var lineWidth = 0.0;


  Future<Response>? paymentFuture;
  Future<Response>? bannerFuture;

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

  @override
  void initState() {
    super.initState();
    paymentFuture = getPayment();
    bannerFuture = getBanner();
    getChart();
    getChildren();
    mainScrollController.addListener(() {
    _removeOverlay();
    });
    chartScrollController.addListener(() {
      _removeOverlay();
    });
  }
  OverlayEntry? _overlayEntry;


  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(statusBarColor:MainTheme.backgroundGray, statusBarIconBrightness: Brightness.dark));
    return Scaffold(
        extendBody: true,
        backgroundColor: MainTheme.backgroundGray,
        resizeToAvoidBottomInset: true,
        body:
        SingleChildScrollView(
          controller: mainScrollController,
          child: Container(
            padding: EdgeInsets.fromLTRB(16, 0, 16, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  height: MediaQuery.of(context).viewPadding.top,
                ),
                const SizedBox(height: 13,),
                //선택된 월
                GestureDetector(
                  behavior: HitTestBehavior.translucent,
                  onTap: () async {
                    _removeOverlay();
                      var pickedDate = await showModalBottomSheet<DateTime>(
                      context: context,
                      builder: (BuildContext context) {
                        return MonthPicker( initTime: selectMonth,);
                        },
                      );
                      if(pickedDate!=null){
                        setState(() {
                          selectMonth = pickedDate;
                          paymentFuture = getPayment();
                          getChart();
                        });
                      }

                },
                  child: Container(
                    child:Row(
                      children: [
                        Text(
                          selectMonth.month < 10?
                          DateFormat('yyyy. M').format(selectMonth):
                          DateFormat('yyyy.MM').format(selectMonth)
                          , style: MainTheme.heading7(MainTheme.gray7),),
                        Container(width: 4,),
                        Icon(Icons.keyboard_arrow_down_rounded, size: 20,color: MainTheme.gray4),

                      ],
                    ),

                  ),
                ),
                SizedBox(height: 19,),

                FutureBuilder(
                    future: paymentFuture,
                    builder: (BuildContext context, AsyncSnapshot snapshot){
                      if (snapshot.connectionState != ConnectionState.done){

                        return Container(
                            height: 99,
                            child: MainTheme.LoadingPage(context)
                        );
                      }else if(snapshot.data.statusCode == 200){
                        if(images.length > 0){
                          return Stack(alignment: Alignment.bottomCenter, children: <Widget>[

                            ClipRRect(
                              borderRadius: BorderRadius.all(
                                Radius.circular(12.0),
                              ),
                              child: Container(
                                width: double.infinity,
                                height: 99,
                                child: CarouselSlider.builder(
                                  options: CarouselOptions(
                                    autoPlay: true,
                                    initialPage: 0,
                                    viewportFraction: 1,
                                    enlargeCenterPage: true,
                                    onPageChanged: (index, reason) => setState(() {
                                      activeIndex = index;
                                    }),
                                  ),
                                  itemCount: images.length,
                                  itemBuilder: (context, index, realIndex) {
                                    final path = images[index];
                                    return imageSlider(index);
                                  },
                                ),
                              )
                              ,
                            ),


                            Align(alignment: Alignment.bottomCenter, child: indicator())
                          ]);
                        }else{
                          return ClipRRect(
                              borderRadius: BorderRadius.all(
                              Radius.circular(12.0),
                      ),
                      child: Container(
                              height: 99,
                              width: double.infinity,
                              color: Colors.grey,
                              ));
                        }


                      }else{
                        return ClipRRect(
                            borderRadius: BorderRadius.all(
                              Radius.circular(12.0),
                            ),
                            child: Container(
                              height: 99,
                              width: double.infinity,
                              color: Colors.grey,
                            ));
                      }
                    }
                ),

                //광고 슬라이더


                SizedBox(height: 10,),
                //이번달 지출금액
                Container(
                  width: double.infinity,
                  decoration: MainTheme.roundBox(Colors.white),
                  padding: EdgeInsets.fromLTRB(16, 20, 16, 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(selectMonth.month.toString() + "월 지출 금액" , style: MainTheme.body4(MainTheme.gray7),),
                      SizedBox(height: 11,),
                      Text( NumberFormat('###,###,###,###').format(paySum)+ "원" , style: MainTheme.heading7(MainTheme.gray7),),
                      SizedBox(height: 9,),
                      Container(
                        width: double.infinity,
                        height: 41,
                        decoration: MainTheme.roundBox(Color(0x1a66ccba)),
                        padding: EdgeInsets.symmetric(horizontal: 16),
                        child:
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text("전월 대비", style: TextStyle(fontWeight: FontWeight.w700, fontFamily: "Pretendard", color: MainTheme.gray5, fontSize: 13),),
                            SizedBox(width: 11,),
                            Text(NumberFormat('###,###,###,###').format((paySum - previousMonth).abs()), style: TextStyle(fontWeight: FontWeight.w700, fontFamily: "Pretendard", color: MainTheme.subColor, fontSize: 13),),
                            SizedBox(width: 7,),
                            Transform.rotate(
                                angle: ((paySum - previousMonth) >= 0 ? 0 : 1) * pi, child: SvgPicture.asset("assets/icons/vector.svg", width: 7, height: 5,))
                          ],),
                      )
                    ],
                  ),

                ),
                //막대그래프
                SizedBox(height: 10,),
                Container(
                  width: double.infinity,
                  height: 224,
                  decoration: MainTheme.roundBox(Colors.white),
                  child: Column(
                    children: [
                      SizedBox(height: 48,),
                      Container(height: 109,
                        width: double.infinity,
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Container(
                            padding: EdgeInsets.symmetric(horizontal: 16),
                            //constraints: BoxConstraints( minWidth: MediaQuery.of(context).size.width - (16*2)),
                            child:
                            Stack(
                              children: [
                                Positioned.fill(
                                  child: Container(
                                    margin: EdgeInsets.only(top: 83.25),
                                    alignment: Alignment.topCenter,
                                    // This child will fill full height, replace it with your leading widget
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: MainTheme.gray2,
                                        borderRadius: BorderRadius.circular(10)
                                    ),
                                      height: 1.5,
                                    ),
                                  ),
                                ),

                                Container(
                                  child: Row(
                                    children: [
                                      Container(width: 28),
                                      ...List.generate(money.length, (index) =>

                                          Row(children: [

                                            GestureDetector(
                                              behavior: HitTestBehavior.translucent,

                                              onTapDown:(TapDownDetails details){

                                                if (_overlayEntry != null) {
                                                  _removeOverlay();
                                                }
                                                if (_overlayEntry == null) {
                                                  _overlayEntry = _payInfo(details, index);
                                                  Overlay.of(context)?.insert(_overlayEntry!);
                                                }

                                              }

                                              ,
                                              child: Container(
                                                key: DateFormat("yyyy.M").format(selectMonth) == money[index]["date"] ? _widgetKey : null,

                                                height: 109,
                                                child: Column(
                                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                  crossAxisAlignment: CrossAxisAlignment.center,
                                                  children: [
                                                    Container(height: 84,
                                                      child: Row(
                                                        crossAxisAlignment: CrossAxisAlignment.end,

                                                        children: [

                                                          ...List.generate(money[index]["list"].length, (listIndex) =>

                                                              Row(
                                                                children: [
                                                                  ClipRRect(
                                                                      borderRadius: BorderRadius.only(topLeft: Radius.circular(7), topRight: Radius.circular(7)),
                                                                      child: Container(
                                                                        height: money[index]["list"][listIndex]["amount"] == 0  ? 0 :(74.0 / maxAmount) * money[index]["list"][listIndex]["amount"]
                                                                        ,
                                                                        width: 14,
                                                                        color: MainTheme.chartColor[color[money[index]["list"][listIndex]["name"]]],
                                                                      )
                                                                  ),
                                                                  listIndex == (money[index]["list"].length-1) ? SizedBox.shrink() :
                                                                  SizedBox(width: 5,)
                                                                ],
                                                              )



                                                          )

                                                        ],
                                                      ),
                                                    ),
                                                    Container(width: 50,
                                                      alignment: Alignment.bottomCenter,
                                                      child:
                                                      Text(money[index]["date"], style : MainTheme.caption4(MainTheme.gray6),)
                                                      ,)
                                                  ],
                                                ),



                                              ) ,
                                            ),

                                            index != (money.length-1)? SizedBox(
                                              width: 30,
                                            ):SizedBox.shrink()

                                          ],)
                                      ),



                                    ],
                                  ),
                                )

                              ],
                            )

                            ,
                          ),
                        ),
                      ),

                      SizedBox(height: 30,),
                      Container(width: double.infinity,
                        height: 17,
                        margin: EdgeInsets.only(left: 16),
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child:
                          Row(
                            children: [

                              ...List.generate(children.length, (index) => Container(
                                height: 17,
                                margin: EdgeInsets.only(right: 12),
                                child: Row(
                                    children:[

                                      Text(children[index]["name"], style: MainTheme.caption4(MainTheme.gray7)),
                                      SizedBox(width: 4,),
                                      Container(
                                        width: 12,height: 12,
                                        decoration: BoxDecoration(
                                            color: MainTheme.chartColor[color[children[index]["name"]]],
                                            shape: BoxShape.circle
                                        ),
                                      )
                                    ]
                                ),

                              ))

                            ],
                          )
                          ,
                        ),
                      )





                    ],
                  ),
                ),
                SizedBox(height: 19,),
                Text("지출리스트", style: MainTheme.body4(MainTheme.gray7),),

                FutureBuilder(
                    future: paymentFuture,
                    builder: (BuildContext context, AsyncSnapshot snapshot){
                      if (snapshot.connectionState != ConnectionState.done){

                        return Container(
                            height: 124,
                            child: MainTheme.LoadingPage(context)
                        );
                      }else if(snapshot.data.statusCode == 200){
                        if(payments.length > 0){
                          return Column(
                            children: [
                              ...List.generate(payments.length, (index) => Column(

                                children: [

                                  index == 0 ?

                                  Container(
                                    alignment: Alignment.center,
                                    padding: EdgeInsets.only(top: 20),
                                    child: Text(DateFormat('yyyy년 MM월 dd일').format(DateTime.parse(payments[index]["startDate"])), style: MainTheme.body8(MainTheme.gray5),),


                                  )

                                      : DateUtils.isSameDay(DateTime.parse(payments[index]["startDate"]), DateTime.parse(payments[index-1]["startDate"])) ? SizedBox.shrink() :
                                  Container(
                                    alignment: Alignment.center,
                                    padding: EdgeInsets.only(top: 20),
                                    child: Text(DateFormat('yyyy년 MM월 dd일').format(DateTime.parse(payments[index]["startDate"])), style: MainTheme.body8(MainTheme.gray5),),


                                  ),

                                  GestureDetector(
                                      behavior: HitTestBehavior.translucent,
                                      onTap: (){

                                        _removeOverlay();
                                        showModalBottomSheet<int>(
                                          context: context,
                                          isScrollControlled: true,
                                          builder: (BuildContext context) {
                                            return PaymentInfo(scheduleId: payments[index]["scheduleId"], calendarId : payments[index]["id"]);
                                          },
                                        ).then((value){
                                          if(value != null){
                                            paymentFuture = getPayment();
                                            getChart();
                                          }


                                        });

                                      },
                                      child:
                                      Container(
                                        padding: EdgeInsets.symmetric(horizontal: 16),
                                        width: double.infinity,
                                        height: 85,
                                        margin: EdgeInsets.only(top: 8),
                                        decoration: MainTheme.roundBox(Colors.white),
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                SizedBox(height: 18,),
                                                Container(width: 209,child:
                                                Text(payments[index]["title"], style: MainTheme.body4(MainTheme.gray7),overflow: TextOverflow.ellipsis,)
                                                  ,),
                                                SizedBox(height: 6,),
                                                Text(payments[index]["name"], style: MainTheme.body9(MainTheme.gray5),overflow: TextOverflow.ellipsis,)

                                              ],
                                            ),
                                            Column(
                                              crossAxisAlignment: CrossAxisAlignment.end,
                                              children: [

                                                SizedBox(height: 10,),
                                                Container(height: 37,alignment :Alignment.centerRight, child:
                                                Text(NumberFormat('###,###,###,###').format(payments[index]["amount"])+ "원", style: MainTheme.body4(MainTheme.gray7),overflow: TextOverflow.ellipsis,),
                                                ),
                                                SizedBox(height: 2,),

                                                Text(payments[index]["payCycleTitle"] == "1개월" ? "매월" : payments[index]["payCycleTitle"], style: MainTheme.body8(MainTheme.gray5),overflow: TextOverflow.ellipsis,)

                                              ],
                                            ),

                                          ],
                                        ),
                                      ))


                                ],


                              )),
                              SizedBox(height: 100,)
                            ],
                          );
                        }else{
                              return Container(
                              height: 124,
                              child: MainTheme.ErrorPage(context, "지출리스트가 없어요"));
                              }


                      }else{
                        return Container(
                            height: 124,
                            child: MainTheme.ErrorPage(context, jsonDecode(utf8.decode(snapshot.data.bodyBytes))["message"]));
                      }
                    }
                ),

              ],
            ),


          ),
        ),

        floatingActionButton:
        GestureDetector(
          behavior: HitTestBehavior.translucent,
          onTap: (){
            showModalBottomSheet<int>(
              useSafeArea: true,
              context: context,
              isScrollControlled: true,
              builder: (BuildContext context) {
                return RegisterPayment(initTime: DateTime.now());
              },
            ).then((value){
              paymentFuture = getPayment();
              getChart();

              if(value != null){
                showModalBottomSheet<void>(
                  context: context,
                  isScrollControlled: true,
                  builder: (BuildContext context) {
                    return PaymentInfo(scheduleId: value, calendarId : 0);
                  },
                ).then((value){
                });
                paymentFuture = getPayment();
                getChart();
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
                Text("지출 추가", style : MainTheme.body4(Colors.white))
              ],
            )
            ,
          ),
        )



    );


  }




  Widget imageSlider(index) =>

      ClipRRect(
          borderRadius: BorderRadius.all(
            Radius.circular(12.0),
          ),
      child:
          GestureDetector(
            onTap: () async {
              await launchUrl(Uri.parse(images[index]["link"]));
            },
            child:Container(
              width: double.infinity,
              height: 99,
              color: Colors.grey,
              child: CachedNetworkImage(imageUrl:images[index]["fileUrl"], fit: BoxFit.cover,
                errorWidget: (context, url, error) {
                  return Container(height: 99,);
                },
              ),
            ) ,
          )
      );

  Widget indicator() =>
      Container(
      margin: const EdgeInsets.only(bottom: 9.0),
      alignment: Alignment.bottomCenter,
      child: AnimatedSmoothIndicator(
        activeIndex: activeIndex,
        count: images.length,
        effect: ExpandingDotsEffect(
          expansionFactor: 2,
            dotHeight: 6,
            dotWidth: 6,
            activeDotColor: Colors.white,
            dotColor: Colors.white.withOpacity(0.6)),
      ));

  OverlayEntry _payInfo(TapDownDetails details, int index){
    double height = 26.0 + (money[index]["list"].length * 19) + ((money[index]["list"].length-1) * 9) + 1.5;
    bool left  = details.globalPosition.dx < MediaQuery.of(context).size.width/2;

    return OverlayEntry(
      builder: (context) =>
      //     SizedBox(
      //   width: MediaQuery.of(context).size.width,
      //   height: MediaQuery.of(context).size.height,
      //   // child: Stack(
      //   //   children: [
      //   //     // ModalBarrier(
      //   //     //   onDismiss: () {
      //   //     //     _removeOverlay();
      //   //     //   },
      //   //     // ),
      //   //
      //   //   ],
      //   // ),
      // ),
      Positioned(
        left: left ? details.globalPosition.dx + 40 : null,
        right : left ? null : MediaQuery.of(context).size.width - details.globalPosition.dx+ 40,
        top: details.globalPosition.dy -height/2,
        child: SpeechBalloon(
          nipHeight: 8,
          nipLocation: left ?NipLocation.left : NipLocation.right,
          borderColor: MainTheme.mainColor,
          borderWidth: 1.5,
          borderRadius: 3,
          width: 140,
          height: height,
          child: Container(
            height: height,
            width: 140,
            padding: EdgeInsets.symmetric(horizontal: 14, vertical: 13),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                ...List.generate(money[index]["list"].length, (childIndex) => Container(
                  width: 112,
                  height: 19,
                  margin: EdgeInsets.only(bottom: childIndex == money[index]["list"].length -1 ? 0 : 9),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(child:
                      Text(money[index]["list"][childIndex]["name"], style: MainTheme.caption4(MainTheme.gray5), overflow: TextOverflow.ellipsis,)),
                      Text("${NumberFormat('###,###,###,###').format(money[index]["list"][childIndex]["amount"])}원", style: MainTheme.caption1(Colors.black),
                      )
                    ],
                  ),
                ))

              ],
            ),

          ),
        ),
      ),
    );
  }
  Future<Response> getPayment() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    var response = await apiRequestGet(urlPayment,  {"commonMemberId" : pref.getInt("userId")!.toString(), "monthStartDate" :DateFormat('yyyy-MM-dd').format(selectMonth)});
    var body = jsonDecode(utf8.decode(response.bodyBytes));
    if(response.statusCode == 200){
      setState(() {
        paySum = body["data"]["paySum"];
        previousMonth = body["data"]["previousMonth"];
        payments = body["data"]["paySchedule"];
      });
    }
    return response;
  }

  Future<void> getChildren() async {

    var response = await apiRequestGet(urlChildren,  {});
    var body =jsonDecode(utf8.decode(response.bodyBytes));

    if(response.statusCode == 200){
      setState(() {
        for(int i = 0 ;i <  body["data"].length; i++){
          children.add({
            "name" : body["data"][i]["name"],
            "fileUrl" : body["data"][i]["fileUrl"],
            "id" : body["data"][i]["id"],
          });
          color[body["data"][i]["name"]] = i;
        }
      });
    }
  }

  Future<void> getChart() async {
    money = [];
    int max = 0;
    var response = await apiRequestGet(urlChart,  {"dayDate" : DateFormat("yyyy-MM-dd").format(selectMonth)});
    var body = jsonDecode(utf8.decode(response.bodyBytes));
    if(response.statusCode == 200){

      setState(() {
        body["data"].forEach((key, value) {
          for(int i = 0; i < value.length; i++){
            if(max < value[i]["amount"]){
              max = value[i]["amount"];
            }
          }
          money.add({"date" : key, "list" : value});
        });
        maxAmount = max;
      });
    }
    move();
  }

  Future<void> move() async {
    await Future.delayed(Duration(milliseconds: 500));
    Scrollable.ensureVisible(
      _widgetKey.currentContext!, // 초록색 컨테이너의 BuildContext
    );
    mainScrollController.jumpTo(
      0,
    );
  }

  Future<Response> getBanner() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    var response = await apiRequestGet(urlBanner + "/" + pref.getInt("locationCode").toString(),  {});
    var body = jsonDecode(utf8.decode(response.bodyBytes));
    if(response.statusCode == 200){
      images = body["data"];
    }
    return response;
  }

}
