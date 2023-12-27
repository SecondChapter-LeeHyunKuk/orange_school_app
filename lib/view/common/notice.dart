import 'dart:convert';
import 'dart:ui';

import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_svg/svg.dart';
import 'package:http/src/response.dart';
import 'package:intl/intl.dart';
import 'package:orange_school/style/main-theme.dart';
import 'package:flutter/foundation.dart' as foundation;

import '../../util/api.dart';

String urlSearch = "${dotenv.env['BASE_URL']}user/memberNotices";

class Notice extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _Notice();
}

class _Notice extends State<Notice> {

  ScrollController _scrollController = ScrollController(initialScrollOffset: 10.0);
  int index = -1;
  List list = [];
  Future<Response>? getFuture;

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

    getFuture= getFirst();
  }

  @override
  Widget build(BuildContext context) {
    double maxW = MediaQuery.of(context).size.width - 58;
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
          title: Text("공지사항", style:MainTheme.body5(MainTheme.gray7)),
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
                    scrollDirection: Axis.vertical,
                    child: Column(

                      children: [

                        Container(
                          child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [

                                ...List.generate(list.length, (index) =>

                                    GestureDetector(
                                      behavior: HitTestBehavior.translucent,
                                      onTap: (){
                                        setState(() {
                                          list[index]["isRead"] = true;
                                        });
                                        Navigator.of(context).pushNamed("/notice/detail", arguments: list[index]);

                                        },
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: !list[index]["isRead"] ? const Color(0xff5ecece).withOpacity(0.05) : Colors.transparent,
                                          border: Border(
                                        bottom: BorderSide(width: 0.5, color: MainTheme.gray3),

                                      ),
                                        ),
                                        height: 97,

                                        width: double.infinity,
                                        padding: EdgeInsets.symmetric(horizontal: 20),
                                        child:
                                        Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Row(
                                              mainAxisAlignment: MainAxisAlignment.start,
                                              children: [
                                                Container(
                                                  constraints: BoxConstraints(maxWidth: maxW),
                                                  child: Text(list[index]["title"], style: MainTheme.body5(MainTheme.gray7),
                                                    overflow: TextOverflow.ellipsis,
                                                  ),
                                                ),

                                      !list[index]["isRead"] ?
                                                Row(
                                                  mainAxisAlignment: MainAxisAlignment.start,
                                                  children: [
                                                    SizedBox(width: 4,),
                                                    SvgPicture.asset(
                                                      'assets/icons/new.svg',
                                                      width: 14,
                                                      height: 14,
                                                    ),
                                                  ],
                                                ) : SizedBox.shrink()

                                              ],
                                            ),
                                            SizedBox(height: 5,),
                                            Text(DateFormat('yyyy.MM.dd').format(DateTime.parse(list[index]["createdAt"])), style: MainTheme.caption3(MainTheme.gray5),
                                            ),
                                          ],
                                        )
                                        ,


                                      ),
                                    )
                                )


                              ]
                          ),
                        )
                      ],
                    ),
                  );
              }else{
                return MainTheme.ErrorPage(context,"알림이 없어요");
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
    var response = await apiRequestGet(urlSearch,  {"size" : "20","sort" : ["id,DESC"],});
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
    var response = await apiRequestGet(urlSearch,  {"size" : "20", "sort" : ["id,DESC"], "page" : (index + 1).toString()});
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
