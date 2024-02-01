import 'dart:convert';
import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/src/response.dart';
import 'package:orange_school/style/main-theme.dart';
import 'package:flutter/foundation.dart' as foundation;
import 'package:flutter_svg/svg.dart';

import '../../util/api.dart';
String urlSearch = "${dotenv.env['BASE_URL']}user/picks";

class ChildBoard extends StatefulWidget {

  @override
  State<StatefulWidget> createState() => _ChildBoard();
}

class _ChildBoard extends State<ChildBoard> {

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
    double blockWidth = (MediaQuery.of(context).size.width-40-23) / 2.0;
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(statusBarColor:MainTheme.backgroundGray, statusBarIconBrightness: Brightness.dark));
    return Scaffold(
      backgroundColor: MainTheme.backgroundGray,
      body:CustomScrollView(
          controller: _scrollController,
          scrollDirection: Axis.vertical,
          slivers: [
          SliverFillRemaining(
          hasScrollBody: false,
          child: Container(
          padding: EdgeInsets.fromLTRB(20,0,20,20),
          child:
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    height: MediaQuery.of(context).viewPadding.top,
                  ),
                  const SizedBox(height: 13,),
                  SvgPicture.asset(
                    'assets/images/pick.svg',
                    width: 100,
                    height: 44,
                  ),

                  FutureBuilder(
                      future: getFuture,
                      builder: (BuildContext context, AsyncSnapshot snapshot){
                        if (snapshot.hasData == false){
                          return Expanded(child: MainTheme.LoadingPage(context));
                        }else if(snapshot.data.statusCode == 200){
                          if(list.length > 0){
                            return
                              Container(
                                height: 245.0 * ((list.length ~/ 2) + list.length % 2),
                                child:  GridView.builder(
                                    padding: EdgeInsets.only(top: 13),
                                    shrinkWrap: true,
                                    physics: NeverScrollableScrollPhysics(),
                                    itemCount: list.length,
                                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                        childAspectRatio: blockWidth / 215,
                                        crossAxisCount: 2,
                                        mainAxisSpacing: 30,
                                        crossAxisSpacing: 23
                                    ),
                                    itemBuilder: (BuildContext context, int index) {
                                      return
                                        GestureDetector(
                                          behavior: HitTestBehavior.translucent,
                                          child: Container(
                                              width: blockWidth,
                                              height: 215,
                                              child: Column(
                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  ClipRRect(
                                                    borderRadius: BorderRadius.circular(8),
                                                    child:
                                                    CachedNetworkImage(imageUrl:list[index]["fileUrl"]?? "", width: blockWidth,height: 158, fit: BoxFit.cover,
                                                      errorWidget: (context, url, error) {
                                                        return  Container(width: blockWidth, height:  158, color: MainTheme.gray2,);

                                                      },
                                                    )

                                                  ),

                                                  Text(list[index]["title"] + "\n",
                                                    style: MainTheme.body4(MainTheme.gray7),
                                                    maxLines: 2,
                                                  )
                                                ],
                                              )

                                          ),
                                          onTap: (){
                                            Navigator.of(context).pushNamed("/parent/board/detail", arguments: list[index]);

                                          },
                                        );


                                    }
                                ),
                              );

                          }else{
                            return Expanded(child:MainTheme.ErrorPage(context,"게시글이 없어요"));
                          }
                        }else{
                          return Expanded(child:MainTheme.ErrorPage(context, jsonDecode(utf8.decode(snapshot.data.bodyBytes))["message"]));
                        }
                      }
                  )


                ],
              )



        ) )]
      ),
    );
  }

  Future<Response> getFirst() async {
    var response = await apiRequestGet(context, urlSearch,  {"size" : "20","sort" : ["number,DESC"],"pickType" : "CHILD"});
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
    var response = await apiRequestGet(context, urlSearch,  {"size" : "20", "sort" : ["number,DESC"],"pickType" : "CHILD", "page" : (index + 1).toString()});
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
