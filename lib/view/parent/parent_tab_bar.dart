import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:intl/intl.dart';
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


String urlPopup = "${dotenv.env['BASE_URL']}user/popups";
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
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    controller = TabController(length: 5, vsync: this);

    showPopup();

  }

  @override
  Widget build(BuildContext context) {
    buildDone = done();
    return Scaffold(
      backgroundColor: MainTheme.backgroundGray,
        body:


            TabBarView(
              physics: NeverScrollableScrollPhysics(),
              children: [
                ParentPlan(isParent:  true,),
                ParentChallenge(),
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
        onTap: (value) {
          setState(() {
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


    );
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


  }

}
