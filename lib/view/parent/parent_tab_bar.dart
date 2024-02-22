import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:intl/intl.dart';
import 'package:orange_school/style/month_picker.dart';
import 'package:orange_school/view/parent/parent_board.dart';
import 'package:orange_school/view/parent/parent_challenge.dart';
import 'package:orange_school/view/parent/parent_my.dart';
import 'package:orange_school/view/parent/parent_plan.dart';
import 'package:orange_school/view/parent/parent_payment.dart';
import 'package:flutter_svg/svg.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../style/main-theme.dart';
import '../../style/popup.dart';
import '../../util/api.dart';
import 'dart:ui' as ui;

String urlPopup = "${dotenv.env['BASE_URL']}user/popups";
double? statusBarHeight;
double? bottomNavHeight;
double? dayWidth;
class ParentTabBar extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _ParentTabBar();
}

class _ParentTabBar extends State<ParentTabBar>


    with SingleTickerProviderStateMixin {
  TabController? controller;
  int screenIndex = 0;
  Future<void>? buildDone;
  String ? fileUrl;
  int ? userId;

  bool week = false;
  bool month = false;
  bool challenge = false;

  bool? weekViewed;
  bool? monthViewed;
  bool? challengeViewed;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    controller = TabController(length: 5, vsync: this);

    showPopup();

  }

  @override
  Widget build(BuildContext context) {
    statusBarHeight = MediaQuery.of(context).padding.top;
    dayWidth =  (MediaQuery.of(context).size.width-32 - 42)/7.0;
    bottomNavHeight = (MediaQuery.of(context).viewPadding.bottom);
    buildDone = done();
    return
      Stack(children: [
        Scaffold(
        backgroundColor: MainTheme.backgroundGray,
        body:


        TabBarView(
          physics: NeverScrollableScrollPhysics(),
          children: [
            ParentPlan(isParent:  true,
                monthEvent : ()async{
                  print('monthViewed');
                  print(monthViewed);
                  if(monthViewed == null){
                    SharedPreferences pref = await SharedPreferences.getInstance();
                    setState(()  {
                      pref.setBool('monthViewed', true);
                      monthViewed = true;
                      month = true;
                    });
                  }

                }),
            ParentChallenge(challengeEvent : ()async{
              if(challengeViewed == null){
                SharedPreferences pref = await SharedPreferences.getInstance();
                setState(()  {
                  pref.setBool('challengeViewed', true);
                  challengeViewed = true;
                  challenge = true;
                });
              }

            }),
            ParentPayment(),
            ParentBoard(),
            ParentMy(),
          ],
          controller: controller,
        ),

        bottomNavigationBar: Container(

            decoration: BoxDecoration(
              borderRadius: BorderRadius.only(
                  topRight: Radius.circular(16), topLeft: Radius.circular(16)),
              boxShadow: [
                BoxShadow(color: Color(0x12000000), spreadRadius: 0, blurRadius: 10),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(16.0),
                topRight: Radius.circular(16.0),
              ),
              child: BottomNavigationBar(
                backgroundColor: Colors.white,
                onTap: (value){
                  setState(()  {
                    if(value == 0){
                      screenIndex = value;
                      controller!.animateTo(0);
                    }else if(value == 1){
                      screenIndex = value;
                      controller!.animateTo(1);
                    }else if(value == 2){
                      screenIndex = value;
                      controller!.animateTo(2);
                    }else if(value == 3){
                      screenIndex = value;
                      controller!.animateTo(3);
                    }else if(value == 4){
                      screenIndex = value;
                      controller!.animateTo(4);
                    }
                  });
                },
                currentIndex: screenIndex,
                type: BottomNavigationBarType.fixed,
                selectedFontSize: 12,
                unselectedFontSize: 12,
                selectedItemColor: Colors.amber[800],
                unselectedItemColor: Colors.grey[500],
                showUnselectedLabels: true,
                items: <BottomNavigationBarItem>[
                  BottomNavigationBarItem(icon: SvgPicture.asset('assets/icons/nv_home'+(screenIndex == 0 ? "_on" : "")+'.svg', width: 24, height: 24), label: '일정'),
                  BottomNavigationBarItem(icon: SvgPicture.asset('assets/icons/nv_challenge'+(screenIndex == 1 ? "_on" : "")+'.svg', width: 24, height: 24), label: '챌린지'),
                  BottomNavigationBarItem(icon: SvgPicture.asset('assets/icons/nv_money'+(screenIndex == 2 ? "_on" : "")+'.svg', width: 24, height: 24), label: '지출관리'),
                  BottomNavigationBarItem(icon: SvgPicture.asset('assets/icons/nv_post'+(screenIndex == 3 ? "_on" : "")+'.svg', width: 24, height: 24), label: "O’s pick"),
                  BottomNavigationBarItem(icon: ClipRRect(borderRadius : BorderRadius.circular(12), child: CachedNetworkImage(imageUrl:fileUrl ?? "", width: 24, height: 24,fit: BoxFit.cover,
                      errorWidget: (context, url, error) {
                        return SvgPicture.asset("assets/icons/profile_${((userId ?? 1) %3) + 1}.svg",width: 24, height: 24, );
                      }
                  )), label: '마이'),
                ],
                selectedLabelStyle: MainTheme.caption4Pretendard(MainTheme.mainColor),
                unselectedLabelStyle: MainTheme.caption4Pretendard(MainTheme.gray4),
              ),
            )),


      ),
        week ? Stack(
          alignment: AlignmentDirectional.center,
          children: [
            Container(
              width: double.infinity,
              height: double.infinity,
              child: CustomPaint(
                painter: HolePainter(),
                child: Container(),
              ),

            ),



            Positioned(
              left: MediaQuery.of(context).size.width-115,
              top : statusBarHeight! + 7.5,
              child: Container( width:  104, height: 48,
                decoration: BoxDecoration(border: Border.all(color: MainTheme.mainColor, width: 2,), borderRadius: BorderRadius.circular(7)),),
            ),
            Positioned(
              left: MediaQuery.of(context).size.width -114 - 52,
              top : statusBarHeight! + 7.5 + 12,
              child: SvgPicture.asset('assets/lines/line1.svg', width: 52, height: 6),
            ),
            Positioned(left: 77, top : statusBarHeight! + 5,child:
            Material(color: Colors.transparent,child: Text('월간, 주간 달력',style: MainTheme.body2(Colors.white),))),
            Positioned(left: 77, top : statusBarHeight! + 37,child:
            Material(color: Colors.transparent,child: Text('월별, 주별 일정을 확인할 수 있어요',style: MainTheme.caption2(MainTheme.gray4),))),

            Positioned(
              left: 14,
              top : statusBarHeight! + 64,
              child: Container( width:  52, height: 87,
                decoration: BoxDecoration(border: Border.all(color: MainTheme.mainColor, width: 2,), borderRadius: BorderRadius.circular(7)),), ),
            Positioned(
              left: 30,
              top : statusBarHeight! + 64 + 87,
              child: SvgPicture.asset('assets/lines/line2.svg', width: 31, height: 166),
            ),
            Positioned(left: 71, top : statusBarHeight! + 297 - 21,child:
            SvgPicture.asset('assets/lines/line_switch.svg', width: 28 * 1.3, height: 16 * 1.3),),
            Positioned(left: 71, top : statusBarHeight! + 297,child:
            Material(color: Colors.transparent,child: Text('학교 수업',style: MainTheme.body2(Colors.white),))),
            Positioned(left: 71, top : statusBarHeight! + 297 + 37,child:
            Material(color: Colors.transparent,child: Text('학교 정규 수업을\n껐다 켰다 할 수 있어요',style: MainTheme.caption2(MainTheme.gray4),))),

            Positioned(
              left: 31 + dayWidth! + (dayWidth!/2.0),
              top : statusBarHeight! + 71.5,
              child: Container( width:  52, height: 72,
                decoration: BoxDecoration(border: Border.all(color: MainTheme.mainColor, width: 2,), borderRadius: BorderRadius.circular(7)),), ),
            Positioned(
              left: 31 + dayWidth! + (dayWidth!/2.0) + 26,
              top : statusBarHeight! + 71.5 + 72,
              child: SvgPicture.asset('assets/lines/line3.svg', width: 31, height: 94),
            ),
            Positioned(left: 31 + dayWidth! + (dayWidth!/2.0) + 63, top : statusBarHeight! + 218,child:
            Material(color: Colors.transparent,child: Text('일간 시간표',style: MainTheme.body2(Colors.white),))),
            Positioned(left: 31 + dayWidth! + (dayWidth!/2.0) + 63, top : statusBarHeight! + 218 + 37,child:
            Material(color: Colors.transparent,child: Text('일자를 눌러 일간 시간표를\n확인할 수 있어요',style: MainTheme.caption2(MainTheme.gray4),))),

            Positioned(
              left: 52 + (dayWidth!*5),
              top :  statusBarHeight! + 394,
              child: Container( width:  dayWidth! +12, height: 82,
                decoration: BoxDecoration(border: Border.all(color: MainTheme.mainColor, width: 2,), borderRadius: BorderRadius.circular(7)),), ),
            Positioned(
              left: 52 + (dayWidth!*5) + 14,
              top : statusBarHeight! + 394+ 82,
              child: SvgPicture.asset('assets/lines/line4.svg', width: 31, height: 43),
            ),
            Positioned(left: 52 + (dayWidth!*5) -76, top : statusBarHeight! + 498,child:
            Material(color: Colors.transparent,child: Text('일정 추가',style: MainTheme.body2(Colors.white),))),
            Positioned(left: 52 + (dayWidth!*5) -76, top : statusBarHeight! + 498 + 37,child:
            Material(color: Colors.transparent,child: Text('빈 공간을 눌러 바로\n일정을 추가할 수 있어요',style: MainTheme.caption2(MainTheme.gray4),))),

            Positioned(right : 44 , top : statusBarHeight! + 100,child:
            Material(color: Colors.transparent,child: Text('주차별 일정보기',style: MainTheme.body2(Colors.white),))),
            Positioned(
            right: 22,
            top : statusBarHeight! + 140,
            child: SvgPicture.asset('assets/lines/line_slide.svg', width: 145, height: 49),),

            Positioned(
              bottom : MediaQuery.of(context).viewPadding.bottom + 50,
              child:
              GestureDetector(
                onTap: (){setState(() {
                  week = false;
                });},
                behavior: HitTestBehavior.translucent,
                child: Container( width:  44, height: 44,
                  decoration: BoxDecoration(border: Border.all(color: Colors.white, width: 2,), borderRadius: BorderRadius.circular(8)),
                  alignment: Alignment.center,
                  child: SvgPicture.asset('assets/lines/x_white.svg', width: 18, height: 18),),
              ),
              )





          ],
        ) : SizedBox.shrink(),

        month ? Stack(
          alignment: AlignmentDirectional.center,
          children: [
            Container(
              width: double.infinity,
              height: double.infinity,
              child: CustomPaint(
                painter: MonthPainter(),
                child: Container(),
              ),

            ),



            Positioned(
              left: MediaQuery.of(context).size.width - 135,
              top : statusBarHeight! + 77,
              child: Container( width:  111, height: 48,
                decoration: BoxDecoration(border: Border.all(color: MainTheme.mainColor, width: 2,), borderRadius: BorderRadius.circular(7)),),
            ),

            Positioned(
              left: MediaQuery.of(context).size.width - 70,
              top :statusBarHeight! + 77 + 48,
              child: SvgPicture.asset('assets/lines/line6.svg', width: 32, height: 99),
            ),
            Positioned(left: MediaQuery.of(context).size.width - 160 , top : statusBarHeight! + 205,child:
            Material(color: Colors.transparent,child: Text('오늘의 날씨',style: MainTheme.body2(Colors.white),))),
            Positioned(left: MediaQuery.of(context).size.width - 160, top : statusBarHeight! + 205 + 37,child:
            Material(color: Colors.transparent,child: Text('간편히 날씨를 확인하고\n옷차림을 정해요',style: MainTheme.caption2(MainTheme.gray4),))),


            Positioned(
              left: 11,
              top : statusBarHeight! + 7,
              child: Container( width:  119, height: 48,
                decoration: BoxDecoration(border: Border.all(color: MainTheme.mainColor, width: 2,), borderRadius: BorderRadius.circular(7)),),
            ),

            Positioned(
              left: 11+ 8.5,
              top : statusBarHeight! + 7 + 48,
              child: SvgPicture.asset('assets/lines/line5.svg', width: 31, height: 49),
            ),
            Positioned(left: 63 , top : statusBarHeight! + 84,child:
            Material(color: Colors.transparent,child: Text('일정 구분해서 보기',style: MainTheme.body2(Colors.white),))),
            Positioned(left: 63 , top : statusBarHeight! + 84 + 37,child:
            Material(color: Colors.transparent,child: Text('전체/아이/나/결제일로 구분하여\n일정을 볼 수 있어요',style: MainTheme.caption2(MainTheme.gray4),))),


            Positioned(
              left: MediaQuery.of(context).size.width - 126.5,
              top : MediaQuery.of(context).size.height - bottomNavHeight! - 127,
              child: Container( width:  116, height: 59,
                decoration: BoxDecoration(border: Border.all(color: MainTheme.mainColor, width: 2,), borderRadius: BorderRadius.circular(7)),),
            ),

            Positioned(
              left: MediaQuery.of(context).size.width - 126.5 - 63,
              top :MediaQuery.of(context).size.height - bottomNavHeight! - 127,
              child: SvgPicture.asset('assets/lines/line7.svg', width: 65.5, height: 32),
            ),
            Positioned(left: MediaQuery.of(context).size.width - 126.5 - 70, top : MediaQuery.of(context).size.height - bottomNavHeight! - 200 ,child:
            Material(color: Colors.transparent,child: Text('손쉽게 일정을\n추가해 보세요',style: MainTheme.caption2(MainTheme.gray4),))),
            Positioned(left: MediaQuery.of(context).size.width - 126.5 - 70 , top : MediaQuery.of(context).size.height - bottomNavHeight! - 200 + 35,child:
            Material(color: Colors.transparent,child: Text('일정 추가',style: MainTheme.body2(Colors.white),))),

            // Positioned(
            //   left: MediaQuery.of(context).size.width -114 - 52,
            //   top : statusBarHeight! + 7.5 + 12,
            //   child: SvgPicture.asset('assets/lines/line1.svg', width: 52, height: 6),
            // ),
            // Positioned(left: 77, top : statusBarHeight! + 5,child:
            // Material(color: Colors.transparent,child: Text('월간, 주간 달력',style: MainTheme.body2(Colors.white),))),
            // Positioned(left: 77, top : statusBarHeight! + 37,child:
            // Material(color: Colors.transparent,child: Text('월별, 주별 일정을 확인할 수 있어요',style: MainTheme.caption2(MainTheme.gray4),))),


            Positioned(
              bottom : MediaQuery.of(context).viewPadding.bottom + 50,
              child:
              GestureDetector(
                onTap: (){setState(() {
                  month = false;
                });},
                behavior: HitTestBehavior.translucent,
                child: Container( width:  44, height: 44,
                  decoration: BoxDecoration(border: Border.all(color: Colors.white, width: 2,), borderRadius: BorderRadius.circular(8)),
                  alignment: Alignment.center,
                  child: SvgPicture.asset('assets/lines/x_white.svg', width: 18, height: 18),),
              ),
            )





          ],
        ) : SizedBox.shrink(),

        challenge ? Stack(
          alignment: AlignmentDirectional.center,
          children: [
            Container(
              width: double.infinity,
              height: double.infinity,
              child: CustomPaint(
                painter: ChallengePainter(),
                child: Container(),
              ),

            ),

            Positioned(
              left: 11,
              top : statusBarHeight! + 7,
              child: Container( width:  119, height: 48,
                decoration: BoxDecoration(border: Border.all(color: MainTheme.mainColor, width: 2,), borderRadius: BorderRadius.circular(7)),),
            ),

            Positioned(
              left: 11+ 8.5,
              top : statusBarHeight! + 7 + 48,
              child: SvgPicture.asset('assets/lines/line8.svg', width: 31, height: 36),
            ),
            Positioned(left: 61 , top : statusBarHeight! + 67,child:
            Material(color: Colors.transparent,child: Text('아이별 챌린지 보기',style: MainTheme.body2(Colors.white),))),
            Positioned(left: 61 , top : statusBarHeight! + 67 + 37,child:
            Material(color: Colors.transparent,child: Text('아이별로 챌린지를\n관리할 수 있어요',style: MainTheme.caption2(MainTheme.gray4),))),


            Positioned(
              left: MediaQuery.of(context).size.width - 130,
              top : statusBarHeight! + 57,
              child: Container( width:  118, height: 43,
                decoration: BoxDecoration(border: Border.all(color: MainTheme.mainColor, width: 2,), borderRadius: BorderRadius.circular(7)),),
            ),
            Positioned(
              left: MediaQuery.of(context).size.width - 50,
              top : statusBarHeight! + 57 + 43,
              child: SvgPicture.asset('assets/lines/line9.svg', width: 19, height: 223),
            ),
            Positioned(left: MediaQuery.of(context).size.width - 180 , top : statusBarHeight! + 305,child:
            Material(color: Colors.transparent,child: Text('동네 친구들 챌린지',style: MainTheme.body2(Colors.white),))),
            Positioned(left: MediaQuery.of(context).size.width - 180 , top : statusBarHeight! + 305 + 37,child:
            Material(color: Colors.transparent,child: Text('등록된 주소지 기준으로\n동네 친구들이 진행하는\n챌린지를 볼 수 있어요',
              style: MainTheme.caption2(MainTheme.gray4),))),
            Positioned(
              left: 11,
              top : 184,
              child: Container( width:  MediaQuery.of(context).size.width - 22, height:  131,
                decoration: BoxDecoration(border: Border.all(color: MainTheme.mainColor, width: 2,), borderRadius: BorderRadius.circular(7)),),
            ),
            Positioned(
              left: 61,
              top : 184 + 131,
              child: SvgPicture.asset('assets/lines/line10.svg', width: 31, height: 150),
            ),
            Positioned(left: 105 , top : 445,child:
            Material(color: Colors.transparent,child: Text('챌린지 추가하기',style: MainTheme.body2(Colors.white),))),
            Positioned(left: 105 , top : 445
                + 37,child:
            Material(color: Colors.transparent,child: Text('챌린지를 추가하여 칭찬도장 찍으며\n아이의 성공 습관을 만들어 보세요',style: MainTheme.caption2(MainTheme.gray4),))),




            Positioned(
              bottom : MediaQuery.of(context).viewPadding.bottom + 50,
              child:
              GestureDetector(
                onTap: (){setState(() {
                  challenge = false;
                });},
                behavior: HitTestBehavior.translucent,
                child: Container( width:  44, height: 44,
                  decoration: BoxDecoration(border: Border.all(color: Colors.white, width: 2,), borderRadius: BorderRadius.circular(8)),
                  alignment: Alignment.center,
                  child: SvgPicture.asset('assets/lines/x_white.svg', width: 18, height: 18),),
              ),
            )





          ],
        ) : SizedBox.shrink()

      ],);


  }
  @override
  void dispose(){
    controller!.dispose();
    super.dispose();
  }



  Future<void> done()async {


  }

  Future<void> showPopup() async {

    String todayStr = DateFormat("yyyy-MM-dd").format(DateTime.now());

    SharedPreferences pref = await SharedPreferences.getInstance();
    await buildDone;

    setState(() {
      fileUrl = pref.getString("profile");
      userId = pref.getInt("userId");
    });

    weekViewed = pref.getBool("weekViewed");
    monthViewed = pref.getBool("monthViewed");
    challengeViewed = pref.getBool("challengeViewed");

    var response = await apiRequestGet(context, urlPopup, {});
    var body =jsonDecode(utf8.decode(response.bodyBytes));

    List popups = body["data"];

    for(int i = 0; i < popups.length; i++){

      var viewDate = pref.getString(pref.getInt("userId").toString() + "popup" + popups[i]["id"].toString());

      if((viewDate?? "12345") != todayStr){
        await showDialog(
          context: context,
          builder: (BuildContext context) {
            return
              Popup(map : popups[i]);
          },
        );
      }

    }
    if(weekViewed == null){
      setState(() {
        pref.setBool('weekViewed', true);
        weekViewed = true;
        week = true;
      });
    }


  }

  Future<void> showCoach() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    setState(() {
      pref.setBool('challengeViewed', true);
      challengeViewed = true;
      challenge = true;
    });
  }

}
class HolePainter extends CustomPainter {


  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();
    paint.color = Colors.black.withOpacity(0.8);
    canvas.drawPath(
      Path.combine(
        PathOperation.difference,
        Path()..addRect(Rect.fromLTRB(0, 0, size.width, size.height)),
        Path()

          ..addRRect(RRect.fromLTRBR(
              size.width-115,
              statusBarHeight! + 7.5,
              size.width-115 + 104,
              statusBarHeight! + 7.5 + 48,
              Radius.circular(7)))
          ..addRRect(RRect.fromLTRBR(
              14,
              statusBarHeight! + 64,
              14 + 52,
              statusBarHeight! + 64 + 87,
              Radius.circular(7)))
          ..addRRect(RRect.fromLTRBR(
              31 + dayWidth! + (dayWidth!/2.0),
              statusBarHeight! + 71.5,
              31 + dayWidth! + (dayWidth!/2.0) + 52,
              statusBarHeight! + 71.5 + 72,
              Radius.circular(7)))
          ..addRRect(RRect.fromLTRBR(
              52 + (dayWidth!*5),
              statusBarHeight! + 394,
              52 + (dayWidth!*5) + dayWidth! +12,
              statusBarHeight! + 394 + 82,
              Radius.circular(7)))
          ..close(),
      ),
      paint,
    );
  }


  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }

}

class MonthPainter extends CustomPainter {


  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();
    paint.color = Colors.black.withOpacity(0.8);
    canvas.drawPath(
      Path.combine(
        PathOperation.difference,
        Path()..addRect(Rect.fromLTRB(0, 0, size.width, size.height)),
        Path()
          ..addRRect(RRect.fromLTRBR(
              11,
              statusBarHeight! + 7,
              11 + 119,
              statusBarHeight! + 7 + 48,
              Radius.circular(7)))
          ..addRRect(RRect.fromLTRBR(
              size.width - 135,
              statusBarHeight! + 77,
              size.width - 135 + 111,
              statusBarHeight! + 77 + 48,
              Radius.circular(7)))
          ..addRRect(RRect.fromLTRBR(
              size.width - 126.5,
              size.height - bottomNavHeight! - 127,
              size.width - 126.5 + 116,
              size.height - bottomNavHeight! - 127 + 59,
              Radius.circular(7)))
          ..close(),
      ),
      paint,
    );
  }


  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }

}

class ChallengePainter extends CustomPainter {


  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();
    paint.color = Colors.black.withOpacity(0.8);
    canvas.drawPath(
      Path.combine(
        PathOperation.difference,
        Path()..addRect(Rect.fromLTRB(0, 0, size.width, size.height)),
        Path()
          ..addRRect(RRect.fromLTRBR(
              11,
              statusBarHeight! + 7,
              11 + 119,
              statusBarHeight! + 7 + 48,
              Radius.circular(7)))
          ..addRRect(RRect.fromLTRBR(
              size.width - 130,
              statusBarHeight! + 57,
              size.width - 130 + 118,
              statusBarHeight! + 57 + 43,
              Radius.circular(7)))
          ..addRRect(RRect.fromLTRBR(
              11,
              184,
              11 + size.width - 22,
              184 + 131,
              Radius.circular(7)))
          ..close(),
      ),
      paint,
    );
  }


  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }

}