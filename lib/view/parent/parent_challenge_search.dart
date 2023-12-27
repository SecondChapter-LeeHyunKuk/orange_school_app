import 'dart:convert';
import 'dart:ui';

import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_svg/svg.dart';
import 'package:orange_school/style/main-theme.dart';
import 'package:http/src/response.dart';
import 'package:flutter/foundation.dart' as foundation;

import '../../util/api.dart';

String urlSearch = "${dotenv.env['BASE_URL']}user/search/townFriends";
String urlFollow = "${dotenv.env['BASE_URL']}user/follow";

class ParentChallengeSearch extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _ParentChallengeSearch();
}

class _ParentChallengeSearch extends State<ParentChallengeSearch> {
  String? currentText;
  int? childId;
  List list = [];
  ScrollController _scrollController = ScrollController();
  int index = -1;
  Future<Response>? getFuture;
  TextEditingController te_search = TextEditingController();
  final FocusNode _focusNode = FocusNode();
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
    childId ??= ModalRoute.of(context)?.settings.arguments as int;

    double blockWidth = (MediaQuery.of(context).size.width-32-11) / 2.0;
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(statusBarColor:MainTheme.backgroundGray, statusBarIconBrightness: Brightness.dark));
    return Scaffold(
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(50.0),

          child:  AppBar(
          scrolledUnderElevation: 0.0,
          backgroundColor: MainTheme.backgroundGray,

          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios_rounded, color: MainTheme.gray7),
            onPressed: () => Navigator.of(context).pop(),
          ),
          actions: [
            Container(
              width: MediaQuery.of(context).size.width-16-52,
              height: 48,
              margin: EdgeInsets.only(right: 16),
              child: TextField(
                focusNode: _focusNode,
                controller: te_search,
                onEditingComplete: (){
                  _focusNode.unfocus();
                  getFuture = getFirst();
                },
                decoration : InputDecoration(
                  suffixIcon: GestureDetector(
                      onTap: (){
                        getFuture = getFirst();
                      },
                      child: const Icon(Icons.search, color: MainTheme.gray3, size: 24,)
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 0),
                  fillColor: Colors.white,
                  filled: true,
                  focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(12.0)),
                      borderSide: BorderSide(color: MainTheme.mainColor)),
                  enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(12.0)),
                      borderSide: BorderSide(color: MainTheme.gray2)),
                  border: InputBorder.none,
                  hintText: "이름 또는 닉네임을 검색하세요",
                  hintStyle: MainTheme.body6(MainTheme.gray4),
                ),
                style: MainTheme.body5(MainTheme.gray7),
              ),
            )
            ,],
        ),),
      backgroundColor: MainTheme.backgroundGray,
      body:
      FutureBuilder(
          future: getFuture,
          builder: (BuildContext context, AsyncSnapshot snapshot){
            if(getFuture == null){
              return SizedBox.shrink();
            }
            else if (snapshot.hasData == false){
              return MainTheme.LoadingPage(context);
            }else if(snapshot.data.statusCode == 200){
              if(list.length > 0){
                return
                  SingleChildScrollView(
                      controller: _scrollController,
                      scrollDirection: Axis.vertical,
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 16,vertical: 15),
                      child:
                      GridView.builder(
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          itemCount: list.length,
                          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                              childAspectRatio: blockWidth / 232,
                              crossAxisCount: 2,
                              mainAxisSpacing: 16,
                              crossAxisSpacing: 11
                          ),
                          itemBuilder: (BuildContext context, int index) {

                            return Container(
                              width: blockWidth,
                              height: 232,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                color: Colors.white,
                              ),
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  list[index]["isTop10"] ? Positioned(child: SvgPicture.asset("assets/icons/challenge_medal.svg", width: 21, height: 31,), left: 9, top: 8,) : SizedBox.shrink(),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      SizedBox(height: 23.5,),
                                      ClipRRect(borderRadius: BorderRadius.circular(32),

                                        child:
                                        Image.network(
                                        list[index]["fileUrl"] ?? "",
                                          width : 57,
                                          height: 57,
                                          fit: BoxFit.cover,
                                          errorBuilder: (BuildContext context, Object exception, StackTrace? stackTrace) {
                                          return SvgPicture.asset("assets/icons/profile_${(list[index]["id"]%3) + 1}.svg",width: 57, height: 57, );
                                          },
                                          )
                                      ),
                                      SizedBox(height:13,),
                                      Text(list[index]["nickName"], style: MainTheme.body4(MainTheme.gray7)),
                                      SizedBox(height:6,),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Text(list[index]["name"], style: MainTheme.body8(MainTheme.gray6)),
                                          SizedBox(width:9,),
                                          Text("${list[index]["age"]}살", style: MainTheme.body8(MainTheme.gray6)),
                                        ],
                                      ),
                                      SizedBox(height:6,),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        children: [
                                          SvgPicture.asset("assets/icons/challenge_orange.svg", width: 18, height: 18,),
                                          SizedBox(width:9,),
                                          Text("${list[index]["totalOrange"]}개", style: MainTheme.body8(MainTheme.mainColor)),
                                        ],

                                      ),
                                      SizedBox(height:14,),
                                      Container(width: 129, height: 36,
                                        child: ElevatedButton(
                                          style: !list[index]["isFollow"]? MainTheme.primaryButton(Color(0x33ff881a)) : MainTheme.hollowButton(MainTheme.gray2),
                                          onPressed: (){
                                            follow(index);
                                          },
                                          child: !list[index]["isFollow"] ? Text("친구 추가", style: MainTheme.body8(MainTheme.mainColor)) :  Text("친구 취소", style: MainTheme.body8(MainTheme.gray4)),
                                        ),
                                      )
                                    ],
                                  )
                                ],
                              ),

                            );

                          }
                      ),


                    ),
                  ) ;
              }else{
                return MainTheme.ErrorPage(context,"검색된 친구가 없어요");
              }
            }else{
              return MainTheme.ErrorPage(context, jsonDecode(utf8.decode(snapshot.data.bodyBytes))["message"]);
            }
          }
      )



      ,
    );
  }
  Future<Response> getFirst() async {
    index = -1;
    list = [];
    currentText = te_search.text;
    var response = await apiRequestGet(urlSearch + "/" + childId.toString(),  {"keyword": te_search.text,"size" : "20","sort" : ["id,DESC"],});
    var body =jsonDecode(utf8.decode(response.bodyBytes));
    if(response.statusCode == 200){
      setState(() {
        index = 0;
        list = body["data"]["content"];
      });
    }
    return response;
  }

  Future<void> scroll() async {
    var response = await apiRequestGet(urlSearch + "/" + childId.toString(),  {"keyword": currentText, "size" : "20", "sort" : ["id,DESC"], "page" : (index + 1).toString()});
    var body =jsonDecode(utf8.decode(response.bodyBytes));

    if(response.statusCode == 200){
      setState(() {
        if(body["data"]["content"].length > 0){
          index++;
          list.addAll(body["data"]["content"]);
        }
      });
    }
  }

  Future<void> follow(int index) async {
    Map request = {};
    var response = await apiRequestPost(urlFollow + "/" + childId.toString() + "/" + list[index]["id"].toString(),request);
    var body =jsonDecode(utf8.decode(response.bodyBytes));

    if(response.statusCode == 200){
      setState(() {
        list[index]["isFollow"] = !list[index]["isFollow"];
      });
    }else{
      ScaffoldMessenger.of(context)
          .showSnackBar(MainTheme.snackBar(body["message"]));
    }
  }
}
