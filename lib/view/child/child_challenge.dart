import 'dart:convert';
import 'dart:ui';
import 'dart:math';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:get/get_connect/http/src/response/response.dart';
import 'package:get/get_connect/http/src/response/response.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:orange_school/style/alert.dart';
import 'package:orange_school/style/main-theme.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:simple_shadow/simple_shadow.dart';

import '../../util/api.dart';


String urlChildren = "${dotenv.env['BASE_URL']}user/commonMembers";
String urlChallenges = "${dotenv.env['BASE_URL']}user/challenges";
String urlAddStamp = "${dotenv.env['BASE_URL']}user/challenge/stamp/add";
String urlRemoveStamp = "${dotenv.env['BASE_URL']}user/challenge/stamp/remove";
String urlRequest = "${dotenv.env['BASE_URL']}user/challenge/stamp";


class ChildChallenge extends StatefulWidget {
  @override
  State<ChildChallenge> createState() => _ChildChallenge();
}

class _ChildChallenge extends State<ChildChallenge> {
  ScrollController _scrollController = ScrollController(initialScrollOffset: 10.0);
  int index = -1;
  bool ongoing = true;
  bool show = true;
  var stamp = 2;
  List dates = [];
  List children = [];
  int selectedChildIndex = 0;
  Map? ongoingChallenge;
  List completeList = [];
  Future<http.Response>? getOngoingChallenge;
  DateTime selectDay = DateTime.now();


  DateTime selectMonth = DateTime.now();

  OverlayEntry? _overlayEntry;
  final LayerLink _layerLink = LayerLink();

  @override
  void initState() {

    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent && index > -1 && !ongoing) {
        scroll();
      }
    });
    getChildren();
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(statusBarColor:MainTheme.backgroundGray, statusBarIconBrightness: Brightness.dark));
    double orangeGap = (MediaQuery.of(context).size.width-(16*4) - (56*5)) / 4.0; //오렌지 사이 갭
    //int orangeRowCount = orangeObject==null?  0 : (orangeObject ~/ 5) +1;
    return Scaffold(
        extendBody: true,
        backgroundColor: MainTheme.backgroundGray,
        resizeToAvoidBottomInset: true,
        body:

        CustomScrollView(
        controller: _scrollController,
        scrollDirection: Axis.vertical,
        slivers: [
          SliverFillRemaining(
              hasScrollBody: false,
              child:
              Container(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      height: MediaQuery.of(context).viewPadding.top,
                    ),
                    const SizedBox(height: 13,),

                    Row(
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
                            children.isNotEmpty ?
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
                                            CachedNetworkImage(imageUrl:
                                              children[selectedChildIndex]["fileUrl"] ?? "",
                                              width : 30,
                                              height: 30,
                                              fit: BoxFit.cover,
                                              errorWidget: (context, url, error) {
                                                return SvgPicture.asset("assets/icons/profile_${(children[selectedChildIndex]["id"]%3) + 1}.svg",width: 30, height: 30, );
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
                            ): SizedBox(height : 36)


                        ) ,
                        Expanded(child: Container())
                      ],
                    ),


                    Container(height: 14,),
                    //습관만들기 챌린지, 동네 친구들 보기 버튼
                    Container(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text("습관 만들기 챌린지",style: MainTheme.heading7(MainTheme.gray7),),
                          GestureDetector(
                            behavior: HitTestBehavior.translucent,
                            onTap: (){
                              Navigator.of(context).pushNamed("/parent/challenge/friends", arguments: children[selectedChildIndex]["id"]);
                            },
                            child: Container( height: 32,
                              padding: EdgeInsets.fromLTRB(9,6,9,6),
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text("동네 친구들 보기",style: MainTheme.body8(MainTheme.gray6)),
                            ),
                          )
                        ],
                      ),

                    ),
                    Container(height: 20,),
                    //진행중, 완료 탭
                    Row(children: [
                      GestureDetector(
                        onTap: (){
                          setState(() {
                            ongoing = true;
                          });
                        },
                        behavior: HitTestBehavior.translucent,
                        child:
                        Container(
                          decoration: BoxDecoration(
                              color: ongoing? MainTheme.gray7 : MainTheme.gray3,
                              borderRadius: BorderRadius.circular(8)
                          ),
                          padding: EdgeInsets.fromLTRB(9,6,9,6),
                          child: Text("진행중", style: MainTheme.body8(ongoing? Colors.white : MainTheme.gray5),),
                        ),),
                      SizedBox(width: 10,),
                      GestureDetector(
                        onTap: (){setState(() {
                          ongoing = false;
                        });},
                        behavior: HitTestBehavior.translucent,
                        child:
                        Container(
                          decoration: BoxDecoration(
                              color: !ongoing? MainTheme.gray7 : MainTheme.gray3,
                              borderRadius: BorderRadius.circular(8)
                          ),
                          padding: EdgeInsets.fromLTRB(9,6,9,6),
                          child: Text("완료", style: MainTheme.body8(!ongoing? Colors.white : MainTheme.gray5),),
                        ),),

                    ],),
                    SizedBox(height: 16,),
                    ongoing?


                    FutureBuilder(
                        future: getOngoingChallenge,
                        builder: (BuildContext context, AsyncSnapshot snapshot){
                          if (snapshot.connectionState != ConnectionState.done){
                            return Expanded(child : MainTheme.LoadingPage(context));
                          }else if(snapshot.data.statusCode == 200){
                            if(ongoingChallenge != null){
                              return  Column(
                                children: [
                                  ClipRRect(borderRadius: BorderRadius.only(topRight: Radius.circular(12), topLeft:  Radius.circular(12)),
                                    child: Container(
                                      padding: EdgeInsets.only(bottom: 19),
                                      width: double.infinity,
                                      color: Colors.white,
                                      child: Stack(
                                        alignment: Alignment.center,
                                        children: [
                                          Column(
                                            mainAxisAlignment: MainAxisAlignment.start,
                                            crossAxisAlignment: CrossAxisAlignment.center,
                                            children: [
                                              SizedBox(height: 40.24,),
                                              SimpleShadow(
                                                child:SvgPicture.asset("assets/icons/challenge_flag_red.svg", width: 63.93, height: 55.11,),
                                                opacity: 0.1,         // Default: 0.5
                                                color: Colors.black,   // Default: Black
                                                offset: Offset(0, 0), // Default: Offset(2, 2)
                                                sigma: 2,             // Deffault: 2
                                              ),

                                              SizedBox(height: 12.65,),

                                              show?
                                              Container(
                                                  padding: EdgeInsets.fromLTRB(7,3,7,3),
                                                  decoration: BoxDecoration(
                                                    color: ongoingChallenge!["isShow"] ?  Color(0xff8cca55).withOpacity(0.1) : MainTheme.gray2,
                                                    borderRadius: BorderRadius.circular(32),
                                                  ),
                                                  child:
                                                  ongoingChallenge!["isShow"] ?
                                                  IntrinsicWidth(
                                                    child: Row(
                                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                      children: [
                                                        Container(
                                                          width: 8,height: 8,
                                                          decoration: BoxDecoration(
                                                            color: Color(0xff8cca55),
                                                            borderRadius: BorderRadius.circular(4),
                                                          ),
                                                        ),
                                                        Container(width: 5,),
                                                        Text("공개중", style: MainTheme.caption2(Color(0xff8cca55)),)
                                                      ],

                                                    ),
                                                  ) : Text("비공개", style: MainTheme.caption2(MainTheme.gray4))


                                              ) : Container(
                                                  padding: EdgeInsets.fromLTRB(7,3,7,3),
                                                  decoration: BoxDecoration(
                                                    color: MainTheme.gray2,
                                                    borderRadius: BorderRadius.circular(32),
                                                  ),
                                                  child:
                                                  IntrinsicWidth(
                                                    child: Row(
                                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                      children: [
                                                        Text("비공개", style: MainTheme.caption2(MainTheme.gray4),)
                                                      ],

                                                    ),
                                                  )


                                              ),
                                              SizedBox(height: 6,),
                                              Text(ongoingChallenge!["mission"], style: MainTheme.body5(MainTheme.gray7),textAlign: TextAlign.center,)

                                            ],
                                          ),

                                        ],
                                      ),

                                    ),
                                  ),
                                  ClipRRect(borderRadius: BorderRadius.only(bottomRight: Radius.circular(12), bottomLeft:  Radius.circular(12)),
                                    child: Container(
                                      padding: EdgeInsets.only(bottom: 22, top: 15),
                                      width: double.infinity,
                                      color: Color(0xff8cca55),
                                      child: Column(
                                        children: [
                                          Container(
                                            width: 37,
                                            height: 25,
                                            alignment: Alignment.center,
                                            decoration: BoxDecoration(
                                                color: Colors.white,
                                                borderRadius: BorderRadius.circular(12.5)
                                            ),
                                            child: Text("보상", style : MainTheme.caption2(Color(0xff8cca55))),
                                          ),
                                          SizedBox(height: 10,),
                                          Text(ongoingChallenge!["reward"], style: MainTheme.body5(Colors.white),textAlign: TextAlign.center,)

                                        ],
                                      ),

                                    ),
                                  ),
                                  SizedBox(height: 32,),
                                  Container(

                                    //도장모으기
                                    width: double.infinity,
                                    padding: EdgeInsets.only(left: 16, bottom: 16),
                                    decoration: MainTheme.roundBox(Colors.white),
                                    child:
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        SizedBox(height: 32,),
                                        Text("도장", style: MainTheme.body4(MainTheme.gray7),),
                                        SizedBox(height: 13,),
                                        Container(
                                          margin: EdgeInsets.only(right: 16),
                                          child: Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              ...List.generate(5, (index) =>

                                                  GestureDetector(
                                                    child: SvgPicture.asset("assets/images/stamp" + (index+1 <= ongoingChallenge!["currentStampCount"]?"_on.svg":"_off.svg"), width: 56,height: 56,),
                                                  )

                                              )
                                            ],
                                          ),
                                        ),

                                        SizedBox(height: 15,),
                                        Row(
                                          crossAxisAlignment: CrossAxisAlignment.center,
                                          children: [
                                            SizedBox(width: 8,),
                                            SvgPicture.asset("assets/icons/info_gray.svg", width: 18,height: 18,),
                                            SizedBox(width: 6,),
                                            Text("도장 5개를 모으면 오렌지 1개를 획득할 수 있어요!", style: MainTheme.caption2(MainTheme.gray5),),

                                          ],

                                        ),
                                        SizedBox(height: 22,),
                                        Text("목표 오렌지", style: MainTheme.body4(MainTheme.gray7),),
                                        SizedBox(height: 9,),
                                        Container(
                                          width: double.infinity,
                                          child: Column(
                                            children: [

                                              ...List.generate((ongoingChallenge!["requiredOrangeCount"] ~/ 5) +(ongoingChallenge!["requiredOrangeCount"] % 5 == 0 ? 0 : 1), (rowIndex) =>

                                                  Container(
                                                    width: double.infinity,
                                                    height: 60,
                                                    margin: EdgeInsets.only(bottom: 12),
                                                    child: Stack(

                                                      children: [
                                                        ...List.generate(ongoingChallenge!["requiredOrangeCount"] >= 5*(rowIndex+1)? 5 : ongoingChallenge!["requiredOrangeCount"] % 5, (colIndex) =>

                                                            Positioned(
                                                                bottom: 0,
                                                                left: ((ongoingChallenge!["requiredOrangeCount"] >= 5*(rowIndex+1)? 5 : ongoingChallenge!["requiredOrangeCount"] % 5) -1 -colIndex) * (orangeGap + 56),
                                                                child: 5*rowIndex + ((ongoingChallenge!["requiredOrangeCount"] >= 5*(rowIndex+1)? 5 : ongoingChallenge!["requiredOrangeCount"] % 5) -1 -colIndex) +1 <= ongoingChallenge!["currentOrangeCount"] ?

                                                                SvgPicture.asset('assets/images/orange_on.svg',width: 65, height: 60,):
                                                                SvgPicture.asset("assets/images/orange_off.svg",width: 56,height: 56,)
                                                            )

                                                        )
                                                      ],

                                                    ),
                                                  ),


                                              )
                                            ],

                                          ),
                                        ),
                                        ongoingChallenge!["requiredOrangeCount"] != ongoingChallenge!["currentOrangeCount"] ?
                                        Container(width: double.infinity,height: 49,
                                          margin: EdgeInsets.only(right: 16,top: 4),
                                          child: ElevatedButton(
                                            style: MainTheme.primaryButton(Color(0x33ff881a)),
                                            onPressed: () {
                                              showDialog(
                                                context: context,
                                                builder: (BuildContext context) {
                                                  return Alert(title: "도장을 요청하시겠어요?");
                                                },
                                              )
                                                  .then((val) {
                                                if (val != null) {
                                                  if(val){
                                                    reqStamp();
                                                  }
                                                }
                                              });

                                            },
                                            child: Text("도장 요청하기", style: MainTheme.body4(MainTheme.mainColor),),
                                          ),
                                        ) : SizedBox.shrink()
                                      ],
                                    ),

                                  ),
                                  SizedBox(height: 36,)

                                ],

                              );
                            }else{
                              return
                                Expanded(child:

                              MainTheme.ErrorPage(context, "진행중인 챌린지가 없어요.")
                              );
                            }
                          }else{
                            return Expanded(
                                child:  MainTheme.ErrorPage(context, jsonDecode(utf8.decode(snapshot.data.bodyBytes))["message"])
                            );

                          }
                        }
                    )





                        :

                    completeList.length > 0?




                    Column(
                      children: [
                        ...List.generate(completeList.length, (index) =>

                            Container(
                              decoration: MainTheme.roundBox(Colors.white),
                              margin: EdgeInsets.only(bottom: 16),
                              child: Stack(
                                children: [
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      SizedBox(height: 32,),
                                      Container(margin: EdgeInsets.only(left: 34),
                                          width: double.infinity,
                                          child:  Text( DateFormat('yyyy-MM-dd').format(DateTime.parse(completeList[index]["updatedAt"])), style: MainTheme.body2(MainTheme.gray7),)
                                      ),
                                      SizedBox(height: 11,),
                                      Stack(
                                        children: [
                                          Positioned.fill(
                                            child: Container(
                                              alignment: Alignment.centerLeft,
                                              // This child will fill full height, replace it with your leading widget
                                              child: Container(
                                                decoration: BoxDecoration(
                                                  borderRadius: BorderRadius.circular(30),
                                                  color: MainTheme.gray2,
                                                ),
                                                margin: EdgeInsets.only(left: 31),

                                                width: 4,
                                              ),
                                            ),
                                          ),

                                          Row(
                                            children: [
                                              SizedBox(width: 49,),
                                              Text(completeList[index]["mission"], style: MainTheme.body6(MainTheme.gray7),)
                                            ],
                                          )

                                        ],
                                      ),
                                      SizedBox(height: 10,),
                                      GestureDetector(
                                        onTap: (){
                                          Clipboard.setData(ClipboardData(text: completeList[index]["mission"]));
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(MainTheme.snackBar("복사되었습니다."));
                                          },
                                        behavior: HitTestBehavior.translucent,
                                        child:  IntrinsicWidth(
                                          child: Row(
                                            crossAxisAlignment: CrossAxisAlignment.center,
                                            children: [
                                              const SizedBox(width: 31,),
                                              SvgPicture.asset("assets/icons/copy.svg", width: 15, height: 16.67,),
                                              const SizedBox(width: 5,),
                                              Text("이 미션 복사하기", style: MainTheme.caption2(MainTheme.gray5),)
                                            ],
                                          ),
                                        ),
                                      ),

                                      SizedBox(height: 20,),
                                      Container(margin: EdgeInsets.only(left: 31),child:
                                      Text("목표 오렌지", style: MainTheme.body8(MainTheme.gray6),)),
                                      SizedBox(height: 8,),
                                      Container(
                                        padding: EdgeInsets.only(left: 16),
                                        width: double.infinity,
                                        child: Column(
                                          children: [

                                            ...List.generate((completeList[index]["requiredOrangeCount"] ~/ 5) +(completeList[index]["requiredOrangeCount"] % 5 == 0 ? 0 : 1), (rowIndex) =>

                                                Container(
                                                  width: double.infinity,
                                                  height: 60,
                                                  margin: EdgeInsets.only(bottom: 12),
                                                  child: Stack(

                                                    children: [
                                                      ...List.generate(completeList[index]["requiredOrangeCount"] >= 5*(rowIndex+1)? 5 : completeList[index]["requiredOrangeCount"] % 5, (colIndex) =>

                                                          Positioned(
                                                              bottom: 0,
                                                              left: ((completeList[index]["requiredOrangeCount"] >= 5*(rowIndex+1)? 5 : completeList[index]["requiredOrangeCount"] % 5) -1 -colIndex) * (orangeGap + 56),
                                                              child: 5*rowIndex + ((completeList[index]["requiredOrangeCount"] >= 5*(rowIndex+1)? 5 : completeList[index]["requiredOrangeCount"] % 5) -1 -colIndex) +1 <= completeList[index]["requiredOrangeCount"] ?

                                                              SvgPicture.asset('assets/images/orange.svg', width: 56, height: 56):
                                                              SizedBox.shrink()
                                                          )

                                                      )
                                                    ],

                                                  ),
                                                ),


                                            )
                                          ],

                                        ),
                                      ),
                                      SizedBox(height: 4,),
                                      Container(
                                        margin: EdgeInsets.fromLTRB(16, 0, 16, 16),
                                        width: double.infinity,
                                        decoration: MainTheme.roundBox(Color(0xfff6f7f9)),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.center,
                                          children: [
                                            SizedBox(height: 14,),
                                            Container(
                                              padding: EdgeInsets.fromLTRB(7,3,7,3),
                                              child: Text("보상", style: MainTheme.caption1(MainTheme.mainColor),),
                                              decoration: BoxDecoration(
                                                  borderRadius: BorderRadius.circular(32),
                                                  color: Colors.white
                                              ),


                                            ),
                                            SizedBox(height: 9,),
                                            Text(completeList[index]["reward"], style: MainTheme.body6(MainTheme.gray7),textAlign: TextAlign.center,),
                                            SizedBox(height: 25,),

                                          ],
                                        ),

                                      )
                                    ],

                                  ),
                                  Positioned(child: Image.asset("assets/images/complete.png", width: 74.75, height: 76.58,),
                                    right: 18, top: 18,
                                  )


                                ],
                              ),

                            )


                        )

                      ],
                    )
                        :                           Expanded(
                        child:  MainTheme.ErrorPage(context, "완료된 챌린지가 아직 없어요")
                    )


                  ],
                ),
              ))]

    )





    );


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
                                        getOngoingChallenge = getOngoing();
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
                                              CachedNetworkImage(imageUrl:
                                                children[index]["fileUrl"] ?? "",
                                                width : 24,
                                                height: 24,
                                                fit: BoxFit.cover,
                                                errorWidget: (context, url, error) {
                                                  return SvgPicture.asset("assets/icons/profile_${(children[index]["id"]%3) + 1}.svg",width: 30, height: 30, );
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

    setState(() {
      children.add({"name" : pref.getString("name"), "fileUrl" :pref.getString("profile"), "id" :  pref.getInt("userId") });
      getOngoingChallenge = getOngoing();
    });


  }

  Future<http.Response> getOngoing() async {
    ongoingChallenge = null;
    var response = await apiRequestGet(context, urlChallenges + "/" + children[selectedChildIndex]["id"].toString(),  {"challengeStatus": "PROGRESS"});
    var body =jsonDecode(utf8.decode(response.bodyBytes));

    if(response.statusCode == 200){
      if(body["data"]["content"].length > 0){
        ongoingChallenge = body["data"]["content"][0];
      }
    }
    getComplete();
    return response;
  }

  Future<void> getComplete() async {
    completeList = [];
    var response = await apiRequestGet(context, urlChallenges + "/" + children[selectedChildIndex]["id"].toString(),  {"challengeStatus": "END", "sort" : ["id,DESC"],});
    var body =jsonDecode(utf8.decode(response.bodyBytes));

    if(response.statusCode == 200){
      setState(() {
        index = 0;
        completeList = body["data"]["content"];
      });
    }
  }

  Future<void> scroll() async {
    var response = await apiRequestGet(context, urlChallenges + "/" + children[selectedChildIndex]["id"].toString(),  {"challengeStatus": "END", "sort" : ["id,DESC"], "page" : (index + 1).toString()});
    var body =jsonDecode(utf8.decode(response.bodyBytes));

    if(response.statusCode == 200){
      setState(() {
        if(body["data"]["content"].length > 0){
          index++;
          completeList.addAll(body["data"]["content"]);
        }
      });
    }
  }

  Future<void> addStamp() async {
    if(ongoingChallenge!["requiredOrangeCount"] > ongoingChallenge!["currentOrangeCount"]){
      var response = await apiRequestPost(context, "$urlAddStamp/${ongoingChallenge!["id"]}", {});
      var body =jsonDecode(utf8.decode(response.bodyBytes));
      if(response.statusCode == 200){

        setState(() {
          if(ongoingChallenge!["currentStampCount"] == 4){
            ongoingChallenge!["currentStampCount"] = 0;
            ongoingChallenge!["currentOrangeCount"]++;
          }else{
            ongoingChallenge!["currentStampCount"]++;
          }
        });

      }else{
        ScaffoldMessenger.of(context)
            .showSnackBar(MainTheme.snackBar(body["message"]));
      }
    }
  }

  Future<void> removeStamp() async {
    if(ongoingChallenge!["requiredOrangeCount"] > ongoingChallenge!["currentOrangeCount"]){
      var response = await apiRequestPost(context, "$urlRemoveStamp/${ongoingChallenge!["id"]}", {});
      var body =jsonDecode(utf8.decode(response.bodyBytes));
      if(response.statusCode == 200){

        setState(() {
            ongoingChallenge!["currentStampCount"]--;
        });

      }else{
        ScaffoldMessenger.of(context)
            .showSnackBar(MainTheme.snackBar(body["message"]));
      }
    }
  }

  Future<void> reqStamp() async {
    var response = await apiRequestPost(context, "$urlRequest/${ongoingChallenge!["id"]}", {});
  }
}
