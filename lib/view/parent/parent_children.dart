import 'dart:convert';
import 'dart:ui';

import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart';
import 'package:orange_school/style/main-theme.dart';
import 'package:flutter/foundation.dart' as foundation;
import 'package:orange_school/view/parent/parent_register_child.dart';

import '../../util/api.dart';


String urlSearch = "${dotenv.env['BASE_URL']}user/commonMembers";

class ParentChildren extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _ParentChildren();
}

class _ParentChildren extends State<ParentChildren> {

  ScrollController _scrollController = ScrollController(initialScrollOffset: 10.0);
  int index = -1;
  List list = [];
  Future<Response>? getFuture;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(statusBarColor:Colors.white, statusBarIconBrightness: Brightness.dark));

    getFuture = getFirst();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(50.0),

        child:  AppBar(
          scrolledUnderElevation: 0.0,
          backgroundColor: Colors.white,
          centerTitle: true,
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios_rounded, color: MainTheme.gray7),
            onPressed: () => Navigator.of(context).pop(),
          ),
          title: Text("자녀 관리", style:MainTheme.body5(MainTheme.gray7)),
        ),),
      backgroundColor: Colors.white,
      body:

      FutureBuilder(
          future: getFuture,
          builder: (BuildContext context, AsyncSnapshot snapshot){
            if (snapshot.hasData == false){
              return MainTheme.LoadingPage(context);
            }else if(snapshot.data.statusCode == 200){
              if(list.length > 0){
                return
                  SingleChildScrollView(
                    controller: _scrollController,
                    scrollDirection: Axis.vertical,
                    child: Column(

                      children: [

                        Container(margin: EdgeInsets.symmetric(horizontal: 16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(

                                height: 19,
                              ),
                              ...List.generate(list.length, (index) => Container(
                                width: double.infinity,
                                height: 79,
                                margin: EdgeInsets.only(bottom: 48),
                                child: Stack(
                                  alignment: Alignment.topLeft,
                                  children: [
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(list[index]["name"], style: MainTheme.body5(MainTheme.gray7),),
                                        Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(list[index]["email"], style: MainTheme.body5(MainTheme.gray5),),
                                            Text("${list[index]["schoolName"]} ${list[index]["grade"]}학년 ${list[index]["schoolClass"]}반 "
                                               + ((list[index]["classNumber"]?? "") == "" ? "" : (list[index]["classNumber"] + "번"))
                                              , style: MainTheme.body5(MainTheme.gray5),),
                                          ],
                                        )

                                      ],
                                    ),
                                    Positioned(
                                        right: 0,
                                        top: 0,

                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.end,
                                          children: [
                                            GestureDetector(
                                              onTap: (){Navigator.of(context).pushNamed("/parent/update/child", arguments: list[index]).then((value){
                                                getFuture = getFirst();
                                              });},
                                              child:  Text("계정관리", style: MainTheme.body5(MainTheme.gray5),),
                                            ),
                                            SizedBox(width: 14,),
                                            GestureDetector(
                                              onTap: (){
                                                Navigator.of(context).pushNamed('/parent/update/school', arguments: list[index])
                                                .then((value){
                                                  getFuture = getFirst();
                                                });

                                                },
                                              child:  Text("학교관리", style: MainTheme.body5(MainTheme.subColor),),
                                            ),
                                          ],

                                        ))

                                  ],
                                ),

                              ))


                            ],
                          ),
                        )
                      ],
                    ),
                  );
              }else{
                return MainTheme.ErrorPage(context,"등록된 아이가 없어요");
              }
            }else{
              return MainTheme.ErrorPage(context, jsonDecode(utf8.decode(snapshot.data.bodyBytes))["message"]);
            }
          }
      ),








      bottomNavigationBar: Padding(
        padding: EdgeInsets.only(top: 10, left: 20, right: 20, bottom: MediaQuery.of(context).viewPadding.bottom + 10),
        child: ElevatedButton(onPressed: (){Navigator.of(context).push(MaterialPageRoute(builder: (_) => ParentRegisterChild())).then((value){
          getFuture = getFirst();
        });},
            style: MainTheme.primaryButton(MainTheme.mainColor),
            child: Text("자녀 추가", style: MainTheme.body4(Colors.white),)),
      ),
    );
  }
  Future<Response> getFirst() async {
    list = [];
    index = -1;
    var response = await apiRequestGet(context, urlSearch,  {"size" : "20","sort" : ["id,DESC"],});
    var body =jsonDecode(utf8.decode(response.bodyBytes));
    if(response.statusCode == 200){
      setState(() {
        index = 0;
        list = body["data"];
      });
    }
    return response;
  }

  Future<void> scroll() async {
    var response = await apiRequestGet(context, urlSearch,  {"size" : "20", "sort" : ["id,DESC"], "page" : (index + 1).toString()});
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
}
