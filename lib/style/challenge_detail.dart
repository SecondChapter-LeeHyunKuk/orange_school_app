import 'dart:convert';
import 'dart:math';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:currency_text_input_formatter/currency_text_input_formatter.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_svg/svg.dart';
import 'package:http/http.dart';
import 'package:orange_school/style/cheer_list.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../util/api.dart';
import 'main-theme.dart';





String urlProfile = "${dotenv.env['BASE_URL']}user/townFriend";
String urlCheer = "${dotenv.env['BASE_URL']}user/cheering";
String urlFollow = "${dotenv.env['BASE_URL']}user/follow";
List cheerMessage = ["힘내", "같이하자", "응원할게", "화이팅", "멋지다", "최고야"];

class ChallengeDetail extends StatefulWidget {
  final int childId;
  final int commonMemberId;

  const ChallengeDetail ({ Key? key, required this.childId, required this.commonMemberId}): super(key: key);
  @override
  _ChallengeDetail createState() => _ChallengeDetail();
}

class _ChallengeDetail extends State<ChallengeDetail> {


  Future<Response>? getFuture;
  Map? profile;
  @override
  void initState() {
    super.initState();
    getFuture = getFirst();
  }
  @override
  Widget build(BuildContext context) {
    double cheerWidth = (MediaQuery.of(context).size.width-32-16) / 3.0;
    return Container(
      height: MediaQuery.of(context).size.height * 0.9,
      padding: EdgeInsets.only(left: 16, right: 16),
      decoration: const BoxDecoration(
          color: Color(0xffF6F7F9),
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ) ),

      child:Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 20,),
          Container(
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
          SizedBox(height: 20,),

          FutureBuilder(
              future: getFuture,
              builder: (BuildContext context, AsyncSnapshot snapshot){
                if (snapshot.hasData == false){
                  return Expanded(
                    child: MainTheme.LoadingPage(context),
                  );
                }else if(snapshot.data.statusCode == 200){
                  return  Expanded(child:
                  SingleChildScrollView(
                      scrollDirection: Axis.vertical,
                      padding: EdgeInsets.only(
                          bottom: MediaQuery.of(context).viewInsets.bottom),
                      child:
                      Container(
                        child:Column(
                            crossAxisAlignment: CrossAxisAlignment.start,

                            children: [
                              SizedBox(height: 15,),
                              Container(height: 68,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Container(
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.start,
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        children: [
                                          ClipRRect(borderRadius: BorderRadius.circular(32),



                                              child: CachedNetworkImage(imageUrl:
                                              profile!["fileUrl"] ?? "",
                                                width : 64,
                                                height: 64,
                                                fit: BoxFit.cover,
                                                errorWidget: (context, url, error) {
                                                  return SvgPicture.asset("assets/icons/profile_${(profile!["id"]%3) + 1}.svg",width: 57, height: 57, );
                                                },
                                              )
                                          ),
                                          SizedBox(width: 17,),
                                          Column(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(profile!["nickName"], style: MainTheme.body4(MainTheme.gray7)),
                                              Row(
                                                children: [
                                                  Text(profile!["name"], style: MainTheme.body8(MainTheme.gray6)),
                                                  SizedBox(width: 9,),
                                                  Text("${profile!["age"]}살", style: MainTheme.body8(MainTheme.gray6)),
                                                  SizedBox(width: 8,),
                                                  SvgPicture.asset(
                                                    "assets/icons/challenge_orange.svg",
                                                    width: 18, height: 18,
                                                  ),
                                                  SizedBox(width: 4,),
                                                  Text("${profile!["totalOrange"]}개", style: MainTheme.body8(MainTheme.mainColor)),
                                                ],
                                              ),
                                              Row(
                                                children: [
                                                  Text("팔로워 ${profile!["follower"]}", style: MainTheme.caption2(MainTheme.gray5)),
                                                  SizedBox(width: 16,),
                                                  Text("팔로잉 ${profile!["following"]}", style: MainTheme.caption2(MainTheme.gray5)),
                                                ],
                                              ),

                                            ],
                                          )
                                        ],
                                      ),
                                    ),

                                    widget.childId != widget.commonMemberId ?
                                    Container(width: 83, height: 36,
                                      child: ElevatedButton(
                                        style: !profile!["isFollow"]? MainTheme.primaryButton(Color(0x33ff881a)) : MainTheme.hollowButton(MainTheme.gray2),
                                        onPressed: (){follow();},
                                        child: !profile!["isFollow"] ? Text("친구 추가", style: MainTheme.body8(MainTheme.mainColor)) :  Text("친구 취소", style: MainTheme.body8(MainTheme.gray4)),
                                      ),
                                    ) : SizedBox.shrink()
                                  ],
                                ),
                              ),
                              SizedBox(height: 9,),
                              Text(profile!["intro"],
                                style: MainTheme.body9(MainTheme.gray7),),
                              SizedBox(height: 30,),
                              Container(
                                width: double.infinity,
                                decoration: MainTheme.roundBox(Colors.white),
                                child: Column(
                                  children: [
                                    SizedBox(height: 31,),
                                    SvgPicture.asset("assets/icons/challenge_flag_green.svg", width: 63.93, height: 55.11,),
                                    SizedBox(height: 14.89,),
                                    Text(profile!["mission"] ?? "진행중인 챌린지가 없어요.",
                                      style: MainTheme.body5(MainTheme.gray7), textAlign: TextAlign.center,),
                                    SizedBox(height: 32,),
                                  ],
                                ),

                              ),
                              SizedBox(height: 32,),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Text("응원 메시지", style: MainTheme.body2(MainTheme.gray7)),
                                  GestureDetector(
                                    behavior: HitTestBehavior.translucent,
                                    onTap: (){

                                      showDialog(
                                        context: context,
                                        barrierDismissible: true, //바깥 영역 터치시 닫을지 여부 결정
                                        builder: ((context) {
                                          return CheerList(cheerCount: profile!["totalCheeringCount"], commonMemberId: widget.commonMemberId,);
                                        }),
                                      );


                                    },
                                    child: Container(
                                        child:
                                        IntrinsicWidth(
                                          child:
                                          Row(
                                            children: [
                                              Text("총 ", style: MainTheme.body8(MainTheme.gray7)),
                                              Text("${profile!["totalCheeringCount"]}명", style: MainTheme.body8(MainTheme.subColor)),
                                              Text(" 응원", style: MainTheme.body8(MainTheme.gray7)),
                                              SizedBox(width: 4,),
                                              SvgPicture.asset(
                                                'assets/icons/arrow_right.svg',
                                                width: 16,
                                                height: 16,
                                              ),

                                            ],
                                          ),)
                                    ),

                                  )
                                ],
                              ),
                              SizedBox(height: 7,),
                              GridView.builder(
                                  shrinkWrap: true,
                                  physics: NeverScrollableScrollPhysics(),
                                  itemCount: 6,
                                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                      childAspectRatio: cheerWidth / 84,
                                      crossAxisCount: 3,
                                      mainAxisSpacing: 12,
                                      crossAxisSpacing: 8
                                  ),
                                  itemBuilder: (BuildContext context, int index) {

                                    return

                                      GestureDetector(
                                        onTap: (){
                                          cheer(index + 1);
                                        },
                                        behavior: HitTestBehavior.translucent,
                                        child: Container(
                                          width: cheerWidth,
                                          height: 84,
                                          decoration: BoxDecoration(
                                              borderRadius: BorderRadius.circular(12),
                                              color: Colors.white,
                                              border: Border.all(
                                                  color: profile!["isCheering${index+1}"] ? MainTheme.mainColor : Colors.transparent,
                                                  width: 1
                                              )
                                          ),
                                          child: Column(
                                            mainAxisAlignment: MainAxisAlignment.start,
                                            crossAxisAlignment: CrossAxisAlignment.center,
                                            children: [
                                              SizedBox(height: 19,),
                                              Image.asset("assets/icons/cheer" + (index + 1).toString() + ".png", width: 25, height: 25,),
                                              SizedBox(height: 6,),
                                              Text(cheerMessage[index] + " ${profile!["cheering${index+1}Count"]}",
                                                style: MainTheme.body8(profile!["isCheering${index+1}"] ? MainTheme.mainColor : MainTheme.gray7),),
                                            ],
                                          ),

                                        ),
                                      );


                                  }
                              ),
                              SizedBox(height: 30,)
                            ]
                        ),
                      )



                  )

                  );
                }else{
                  return Expanded(
                      child: MainTheme.ErrorPage(context, jsonDecode(utf8.decode(snapshot.data.bodyBytes))["message"]));
                }
              }
          ),



        ],
      )


      ,

    );
  }

  Future<Response> getFirst() async {
    var response = await apiRequestGet(urlProfile + "/" + widget.childId.toString() + "/" + widget.commonMemberId.toString(),  {});
    var body =jsonDecode(utf8.decode(response.bodyBytes));
    if(response.statusCode == 200){
      setState(() {
        profile = body["data"];
      });
    }
    return response;
  }

  Future<void> cheer(int cheerType) async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    if(pref.getInt("id") != widget.commonMemberId){
      Map request = {};
      request["cheeringMessage"] = "CHEERING${cheerType}";
      var response = await apiRequestPost(urlCheer + "/" + widget.commonMemberId.toString(),  request);
      var body =jsonDecode(utf8.decode(response.bodyBytes));
      if(response.statusCode == 200){

        setState(() {
          profile!["isCheering${cheerType}"] = !profile!["isCheering${cheerType}"];
        });
        getFirst();


      }
    }
  }

  Future<void> follow() async {
    var response = await apiRequestPost(urlFollow + "/" + widget.childId.toString() + "/" + widget.commonMemberId.toString(),{});
    var body =jsonDecode(utf8.decode(response.bodyBytes));

    if(response.statusCode == 200){

      setState(() {
        profile!["isFollow"] = !profile!["isFollow"];
      });
    }else{
      ScaffoldMessenger.of(context)
          .showSnackBar(MainTheme.snackBar(body["message"]));
    }
  }

}









