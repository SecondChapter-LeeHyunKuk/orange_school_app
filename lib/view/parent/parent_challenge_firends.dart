import 'dart:convert';
import 'dart:ffi';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_svg/svg.dart';
import 'package:orange_school/style/challenge_detail.dart';
import 'package:orange_school/style/main-theme.dart';
import 'package:flutter/foundation.dart' as foundation;
import 'package:http/http.dart';
import '../../util/api.dart';
String urlProfile = "${dotenv.env['BASE_URL']}user/my/profile";
String urlTop = "${dotenv.env['BASE_URL']}user/townFriends/top";
String urlFriend = "${dotenv.env['BASE_URL']}user/townFriends";
String urlFollow = "${dotenv.env['BASE_URL']}user/follow";
String urlGetFollow = "${dotenv.env['BASE_URL']}user/townFriend";
class ParentChallengeFriends extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _ParentChallengeFriends();
}

class _ParentChallengeFriends extends State<ParentChallengeFriends> {
  bool exposure = false;
  List cheerMessage = ["힘내", "같이하자", "응원할게", "화이팅", "멋지다", "최고야"];
  int? childId;
  List topList = [];
  List friendList = [];

  ScrollController _scrollController = ScrollController();
  int index = -1;

  Future<Response>? profileFuture;
  Future<Response>? topFuture;
  Future<Response>? friendFuture;
  Map? profile;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent && index > -1) {
        scroll();
      }
    });
  }

  @override
  Widget build(BuildContext context) {

    if(childId == null) {
      childId = ModalRoute.of(context)?.settings.arguments as int;
      profileFuture = getProfile();
      topFuture = getTop();
      friendFuture = getFriend();
    }

    double blockWidth = (MediaQuery.of(context).size.width-32-11) / 2.0;
    double cheerWidth = (MediaQuery.of(context).size.width-32-16) / 3.0;
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(statusBarColor:MainTheme.backgroundGray, statusBarIconBrightness: Brightness.dark));
    return Scaffold(
        appBar: AppBar(
          centerTitle: true,
          scrolledUnderElevation: 0.0,
          backgroundColor: MainTheme.backgroundGray,
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios_rounded, color: MainTheme.gray7),
            onPressed: () => Navigator.of(context).pop(),
          ),
          actions: [
            Container(
              margin: EdgeInsets.zero,
              child: IconButton(
                padding: EdgeInsets.zero,
                constraints: BoxConstraints(),
                icon: Icon(Icons.search, color: MainTheme.gray7),
                onPressed: () => Navigator.of(context).pushNamed("/parent/challenge/search",arguments: childId),
              ),
            )
            ,],
          title: Text("동네 친구들 챌린지", style:MainTheme.body5(MainTheme.gray7)),
        ),
      backgroundColor: MainTheme.backgroundGray,
      body: SingleChildScrollView(
        controller:_scrollController,
        scrollDirection: Axis.vertical,
        child: Column(

          children: [

           Column(

                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 14,
                  ),
                  Padding(padding: EdgeInsets.symmetric(horizontal: 16),child:
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("아이 프로필", style: MainTheme.body2(MainTheme.gray7)),
                        Container(
                          height: 4,
                        ),

                        FutureBuilder(
                            future: profileFuture,
                            builder: (BuildContext context, AsyncSnapshot snapshot){
                              if (snapshot.connectionState != ConnectionState.done){

                                return Container(
                                  height: 124,
                                  child: MainTheme.LoadingPage(context)
                                );
                              }else if(snapshot.data.statusCode == 200){
                                  return GestureDetector(
                                      behavior: HitTestBehavior.translucent,
                                      onTap: (){
                                        showModalBottomSheet<void>(
                                          context: context,
                                          isScrollControlled: true,
                                          builder: (BuildContext context) {
                                            return ChallengeDetail(childId: childId!, commonMemberId: childId!,);
                                          },
                                        );

                                      },
                                      child:
                                      Container(
                                        padding: EdgeInsets.only(left: 14),
                                        width: double.infinity,
                                        height: 124,
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(8),
                                          color: Colors.white,
                                        ),
                                        child: Row(
                                          crossAxisAlignment: CrossAxisAlignment.center,
                                          children: [
                                            ClipRRect(borderRadius: BorderRadius.circular(32),
                                              child:
                                              CachedNetworkImage(imageUrl:
                                                profile!["fileUrl"] ?? "",
                                                width : 64,
                                                height: 64,
                                                fit: BoxFit.cover,
                                                errorWidget: (context, url, error) {
                                                  return SvgPicture.asset("assets/icons/profile_${(profile!["id"]%3) + 1}.svg",width: 57, height: 57, );
                                                },
                                              ),
                                            ),
                                            SizedBox(width: 17,),
                                            Column(
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(profile!["nickName"], style: MainTheme.body4(MainTheme.gray7)),
                                                SizedBox(height: 4,),
                                                Row(
                                                  children: [
                                                    Text(profile!["name"], style: MainTheme.body8(MainTheme.gray6)),
                                                    SizedBox(width: 9,),
                                                    Text(profile!["age"].toString() + "살", style: MainTheme.body8(MainTheme.gray6)),
                                                    SizedBox(width: 8,),
                                                    SvgPicture.asset(
                                                      "assets/icons/challenge_orange.svg",
                                                      width: 18, height: 18,
                                                    ),
                                                    SizedBox(width: 4,),
                                                    Text("${profile!["totalOrange"].toString()}개", style: MainTheme.body8(MainTheme.mainColor)),
                                                  ],
                                                ),
                                                SizedBox(height: 4,),
                                                Row(
                                                  children: [
                                                    Text("팔로워 ${profile!["follower"].toString()}", style: MainTheme.caption2(MainTheme.gray5)),
                                                    SizedBox(width: 16,),
                                                    Text("팔로잉 ${profile!["following"].toString()}", style: MainTheme.caption2(MainTheme.gray5)),
                                                  ],
                                                ),

                                              ],
                                            )
                                          ],
                                        ),

                                      ));

                              }else{
                                return Container(
                                    height: 124,
                                    child: MainTheme.ErrorPage(context, jsonDecode(utf8.decode(snapshot.data.bodyBytes))["message"]));
                              }
                            }
                        ),
                        SizedBox(height: 32,),
                        Text("최다 오렌지 보유 친구", style: MainTheme.body2(MainTheme.gray7)),
                        SizedBox(height: 4,),
                      ],
                    )
                    ,),


                  FutureBuilder(
                      future: topFuture,
                      builder: (BuildContext context, AsyncSnapshot snapshot){
                        if (snapshot.connectionState != ConnectionState.done){
                          return Container(
                              height: 232,
                              child: MainTheme.LoadingPage(context)
                          );
                        }else if(snapshot.data.statusCode == 200){
                          if(topList.isEmpty){
                            return Container(
                                height: 232,
                                child: MainTheme.ErrorPage(context, "콘텐츠가 없어요"));
                          }else{
                            return Container(
                              height: 232, width: double.infinity,
                              child: SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child:
                                Container(
                                  padding: EdgeInsets.symmetric(horizontal: 16),
                                  child: Row(
                                    children: [

                                      ...List.generate(topList.length, (index) =>

                                      GestureDetector(
                                        onTap: (){
                                          showModalBottomSheet<void>(
                                            context: context,
                                            isScrollControlled: true,
                                            builder: (BuildContext context) {
                                              return ChallengeDetail(childId: childId!, commonMemberId: topList[index]["id"],);
                                            },
                                          ).then((value) => {updateFollow("TOP", index)});
                                        },
                                        behavior: HitTestBehavior.translucent,
                                        child:Container(
                                          width: 158,
                                          height: 232,
                                          margin: EdgeInsets.only(right: index == 9 ? 0 : 8),
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(8),
                                            color: Colors.white,
                                          ),
                                          child: Stack(
                                            alignment: Alignment.center,
                                            children: [
                                              Positioned(child: SvgPicture.asset("assets/icons/challenge_medal.svg", width: 21, height: 31,), left: 9, top: 8,),
                                              Column(
                                                crossAxisAlignment: CrossAxisAlignment.center,
                                                children: [
                                                  SizedBox(height: 23.5,),
                                                  ClipRRect(borderRadius: BorderRadius.circular(32),

                                                    child: CachedNetworkImage(imageUrl:
                                                      topList[index]["fileUrl"] ?? "",
                                                      width : 57,
                                                      height: 57,
                                                      fit: BoxFit.cover,
                                                      errorWidget: (context, url, error) {
                                                        return SvgPicture.asset("assets/icons/profile_${(topList[index]["id"]%3) + 1}.svg",width: 57, height: 57, );
                                                      },
                                                    ),
                                                  ),
                                                  SizedBox(height:13,),
                                                  Text(topList[index]["nickName"], style: MainTheme.body4(MainTheme.gray7)),
                                                  SizedBox(height:6,),
                                                  Row(
                                                    mainAxisAlignment: MainAxisAlignment.center,
                                                    children: [
                                                      Text(topList[index]["name"], style: MainTheme.body8(MainTheme.gray6)),
                                                      SizedBox(width:9,),
                                                      Text("${topList[index]["age"]}살", style: MainTheme.body8(MainTheme.gray6)),
                                                    ],
                                                  ),
                                                  SizedBox(height:6,),
                                                  Row(
                                                    mainAxisAlignment: MainAxisAlignment.center,
                                                    crossAxisAlignment: CrossAxisAlignment.center,
                                                    children: [
                                                      SvgPicture.asset("assets/icons/challenge_orange.svg", width: 18, height: 18,),
                                                      SizedBox(width:9,),
                                                      Text("${topList[index]["totalOrange"]}개", style: MainTheme.body8(MainTheme.mainColor)),
                                                    ],

                                                  ),
                                                  SizedBox(height:14,),

                                                  topList[index]["id"] != childId ?
                                                  Container(width: 129, height: 36,
                                                    child: ElevatedButton(
                                                      style: !topList[index]["isFollow"]? MainTheme.primaryButton(Color(0x33ff881a)) : MainTheme.hollowButton(MainTheme.gray2),
                                                      onPressed: (){
                                                        follow("TOP", index);
                                                      },
                                                      child: !topList[index]["isFollow"] ? Text("친구 추가", style: MainTheme.body8(MainTheme.mainColor)) :  Text("친구 취소", style: MainTheme.body8(MainTheme.gray4)),
                                                    ),
                                                  ): SizedBox.shrink()
                                                ],
                                              )
                                            ],
                                          ),

                                        ),
                                      )

                                          )

                                    ],
                                  ),
                                ),
                              ),
                            );
                          }

                        }else{
                          return Container(
                              height: 232,
                              child: MainTheme.ErrorPage(context, jsonDecode(utf8.decode(snapshot.data.bodyBytes))["message"]));
                        }
                      }
                  ),


                  SizedBox(height: 32,),
                  Padding(padding: EdgeInsets.symmetric(horizontal: 16),

                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("내 친구 챌린지 구경하기", style: MainTheme.body2(MainTheme.gray7)),
                      SizedBox(height: 4,),

                      FutureBuilder(
                          future: friendFuture,
                          builder: (BuildContext context, AsyncSnapshot snapshot){
                            if (snapshot.connectionState != ConnectionState.done){
                              return Container(
                                  height: 200,
                                  child: MainTheme.LoadingPage(context)
                              );
                            }else if(snapshot.data.statusCode == 200){

                              if(friendList.length != 0){
                                return GridView.builder(
                                    shrinkWrap: true,
                                    physics: NeverScrollableScrollPhysics(),
                                    itemCount: friendList.length,
                                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                        childAspectRatio: blockWidth / 232,
                                        crossAxisCount: 2,
                                        mainAxisSpacing: 16,
                                        crossAxisSpacing: 11
                                    ),
                                    itemBuilder: (BuildContext context, int index) {

                                      return GestureDetector(
                                          onTap: (){
                                            showModalBottomSheet<void>(
                                              context: context,
                                              isScrollControlled: true,
                                              builder: (BuildContext context) {
                                                return ChallengeDetail(childId: childId!, commonMemberId: friendList[index]["id"],);
                                              },
                                            ).then((value) => {updateFollow("FRIEND", index)});
                                          },
                                          behavior: HitTestBehavior.translucent,
                                          child:Container(
                                        width: blockWidth,
                                        height: 232,
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(8),
                                          color: Colors.white,
                                        ),
                                        child: Stack(
                                          alignment: Alignment.center,
                                          children: [
                                            (friendList[index]["isTop10"]?? false) ? Positioned(child: SvgPicture.asset("assets/icons/challenge_medal.svg", width: 21, height: 31,), left: 9, top: 8,) : SizedBox.shrink(),
                                            Column(
                                              crossAxisAlignment: CrossAxisAlignment.center,
                                              children: [
                                                SizedBox(height: 23.5,),
                                                ClipRRect(borderRadius: BorderRadius.circular(32),

                                                  child: CachedNetworkImage(imageUrl:
                                                    friendList[index]["fileUrl"] ?? "",
                                                    width : 57,
                                                    height: 57,
                                                    fit: BoxFit.cover,
                                                    errorWidget: (context, url, error) {
                                                      return SvgPicture.asset("assets/icons/profile_${(friendList[index]["id"]%3) + 1}.svg",width: 57, height: 57, );
                                                    },
                                                  ),
                                                ),
                                                SizedBox(height:13,),
                                                Text(friendList[index]["nickName"], style: MainTheme.body4(MainTheme.gray7)),
                                                SizedBox(height:6,),
                                                Row(
                                                  mainAxisAlignment: MainAxisAlignment.center,
                                                  children: [
                                                    Text(friendList[index]["name"], style: MainTheme.body8(MainTheme.gray6)),
                                                    SizedBox(width:9,),
                                                    Text("${friendList[index]["age"]}살", style: MainTheme.body8(MainTheme.gray6)),
                                                  ],
                                                ),
                                                SizedBox(height:6,),
                                                Row(
                                                  mainAxisAlignment: MainAxisAlignment.center,
                                                  crossAxisAlignment: CrossAxisAlignment.center,
                                                  children: [
                                                    SvgPicture.asset("assets/icons/challenge_orange.svg", width: 18, height: 18,),
                                                    SizedBox(width:9,),
                                                    Text("${friendList[index]["totalOrange"]}개", style: MainTheme.body8(MainTheme.mainColor)),
                                                  ],

                                                ),
                                                SizedBox(height:14,),
                                                Container(width: 129, height: 36,
                                                  child: ElevatedButton(
                                                    style: !friendList[index]["isFollow"]? MainTheme.primaryButton(Color(0x33ff881a)) : MainTheme.hollowButton(MainTheme.gray2),
                                                    onPressed: (){follow("FRIEND", index);},
                                                    child: !friendList[index]["isFollow"] ? Text("친구 추가", style: MainTheme.body8(MainTheme.mainColor)) :  Text("친구 취소", style: MainTheme.body8(MainTheme.gray4)),
                                                  ),
                                                )
                                              ],
                                            )
                                          ],
                                        ),

                                      ));

                                    }
                                );
                              }else{
                                return Container(
                                    height: 200,
                                    child: MainTheme.ErrorPage(context, "아직 친구가 없습니다."));
                              }

                            }else{
                              return Container(
                                  height: 200,
                                  child: MainTheme.ErrorPage(context, jsonDecode(utf8.decode(snapshot.data.bodyBytes))["message"]));
                            }
                          }
                      ),


                      SizedBox(height: 16,),
                    ],
                  ),
                  )
                ],
              ),

          ],
        ),
      ),
    );
  }
  Future<Response> getProfile() async {
    var response = await apiRequestGet(urlProfile + "/" + childId.toString(),  {});
    var body =jsonDecode(utf8.decode(response.bodyBytes));
    if(response.statusCode == 200){
      setState(() {
        profile = body["data"];
      });
    }
    return response;
  }

  Future<Response> getTop() async {
    var response = await apiRequestGet(urlTop + "/" + childId.toString(),  {});
    var body =jsonDecode(utf8.decode(response.bodyBytes));
    if(response.statusCode == 200){
      setState(() {
        topList = body["data"];
      });
    }
    return response;
  }

  Future<Response> getFriend() async {
    index = -1;
    friendList = [];
    var response = await apiRequestGet(urlFriend + "/" + childId.toString(),  {"size" : "20"});
    var body =jsonDecode(utf8.decode(response.bodyBytes));
    if(response.statusCode == 200){
      setState(() {
        index = 0;
        friendList = body["data"]["content"];
    });
    }
    return response;
  }

  Future<void> scroll() async {
    var response = await apiRequestGet(urlFriend + "/" + childId.toString(),  {"size" : "20","page" : (index + 1).toString()});
    var body =jsonDecode(utf8.decode(response.bodyBytes));

    if(response.statusCode == 200){
      setState(() {
        if(body["data"]["content"].length > 0){
          index++;
          friendList.addAll(body["data"]["content"]);
        }
      });
    }
  }

  Future<Response> updateFollow(String type, int index) async {
    int objectId = type == "TOP" ? topList[index]["id"] : friendList[index]["id"];
    bool nowStatus = type == "TOP" ? topList[index]["isFollow"] : friendList[index]["isFollow"];
    var response = await apiRequestGet(urlGetFollow + "/" + childId.toString() + "/" + objectId.toString(),  {});
    var body =jsonDecode(utf8.decode(response.bodyBytes));
    // if(response.statusCode == 200){
    //     var newStatus = body["data"]["isFollow"];
    //     if(nowStatus != newStatus){
    //       setState(() {
    //         if(type == "TOP"){
    //           topList[index]["isFollow"] = !topList[index]["isFollow"];
    //           for(int i = 0; i < friendList.length; i++){
    //             if(friendList[i]["id"] == objectId){
    //               friendList[i]["isFollow"] = !friendList[i]["isFollow"];
    //               break;
    //             }
    //           }
    //
    //           if(topList[index]["isFollow"]){
    //             friendFuture = getFriend();
    //           }
    //
    //         }else{
    //           friendList[index]["isFollow"] = !friendList[index]["isFollow"];
    //           for(int i = 0; i < friendList.length; i++){
    //             if(topList[i]["id"] == objectId){
    //               topList[i]["isFollow"] = !topList[i]["isFollow"];
    //               break;
    //             }
    //           }
    //         }
    //       });
    //
    //     }
    // }

    if(response.statusCode == 200){
      var newStatus = body["data"]["isFollow"];
      if(nowStatus != newStatus) {
        setState(() {
          if (type == "TOP") {
            topList[index]["isFollow"] = !topList[index]["isFollow"];

            if (topList[index]["isFollow"]) {
              friendFuture = getFriend();
            } else {
              for (int i = 0; i < friendList.length; i++) {
                if (friendList[i]["id"] == objectId) {
                  friendList.removeAt(i);
                }
              }
            }
          } else {
            friendList[index]["isFollow"] = !friendList[index]["isFollow"];
            for (int i = 0; i < topList.length; i++) {
              //print(topList[i]["id"].toString() + " " + objectId.toString());
              if (topList[i]["id"] == objectId) {
                topList[i]["isFollow"] = !topList[i]["isFollow"];
              }
            }
            friendList.removeAt(index);
          }
        });
      }
    }
    return response;
  }


  Future<void> follow(String type, int index) async {

    int objectId = type == "TOP" ? topList[index]["id"] : friendList[index]["id"];

    Map request = {};
    var response = await apiRequestPost(urlFollow + "/" + childId.toString() + "/" + objectId.toString(), request);
    var body =jsonDecode(utf8.decode(response.bodyBytes));

    if(response.statusCode == 200){
      setState(() {
        if(type == "TOP"){
          topList[index]["isFollow"] = !topList[index]["isFollow"];

          if(topList[index]["isFollow"]){
            friendFuture = getFriend();
          }else{
            for(int i = 0; i < friendList.length; i++){
              if(friendList[i]["id"] == objectId){
                friendList.removeAt(i);
              }
            }
          }

        }else{
          friendList[index]["isFollow"] = !friendList[index]["isFollow"];
          for(int i = 0; i < topList.length; i++){
            //print(topList[i]["id"].toString() + " " + objectId.toString());
            if(topList[i]["id"] == objectId){

              topList[i]["isFollow"] = !topList[i]["isFollow"];
            }
          }
          friendList.removeAt(index);
        }
      });
    }else{
      ScaffoldMessenger.of(context)
          .showSnackBar(MainTheme.snackBar(body["message"]));
    }
  }
}
