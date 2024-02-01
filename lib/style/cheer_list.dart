import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_svg/svg.dart';
import 'package:http/http.dart';
import '../../util/api.dart';
import 'challenge_detail.dart';
import 'main-theme.dart';



String urlCheerList = "${dotenv.env['BASE_URL']}user/cheerings";

class CheerList extends StatefulWidget {
  final int childId;
  final int cheerCount;
  final int commonMemberId;
  const CheerList ({ Key? key, required this.cheerCount , required this.commonMemberId, required this.childId}): super(key: key);
  @override
  State<StatefulWidget> createState() => _CheerList();
}

class _CheerList extends State<CheerList> {
  ScrollController _scrollController = ScrollController();
  int index = -1;
  List list = [];
  Future<Response>? getFuture;
  int? totalCount;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent && index > 0) {
        scroll();
      }
    });
    getFuture = get();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      contentPadding: EdgeInsets.all(0),
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.white,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(6))),
      content:Container(
        width: 313, height: 512,
        padding: EdgeInsets.fromLTRB(14,23,14,23),
        child:Column(
          children: [
            Container(
              height: 24,
              child:


              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  totalCount != null ?
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("총 ", style: MainTheme.body4(MainTheme.gray7)),
                      Text("${totalCount}명", style: MainTheme.body4(MainTheme.subColor)),
                      Text(" 응원", style: MainTheme.body4(MainTheme.gray7)),
                    ],
                  ) : const SizedBox.shrink(),

                  GestureDetector(
                      onTap: (){
                        Navigator.of(context).pop();
                      },
                      child: Icon(Icons.close_rounded, color: Colors.black, size: 24,)
                  ),



                ],
              ),
            ),
            Expanded(child:

            FutureBuilder(
                future: getFuture,
                builder: (BuildContext context, AsyncSnapshot snapshot){
                  if (snapshot.hasData == false){
                    return MainTheme.LoadingPage(context);
                  }else if(snapshot.data.statusCode == 200){
                    if(list.length > 0){
                      return
                        RawScrollbar(
                          radius: Radius.circular(20),
                          thickness: 4,
                          thumbColor: Color(0xffd9d9d9),

                          controller: _scrollController,//여기도 전달
                          child: ListView.builder(
                              controller: _scrollController,//여기도 전달
                              itemCount: list.length,
                              itemBuilder: (context, index) =>
                                  GestureDetector(
                                    behavior: HitTestBehavior.translucent,
                                    onTap: (){
                                      if(list[index]["memberType"] == "CHILD"){
                                        showModalBottomSheet<void>(
                                          context: context,
                                          isScrollControlled: true,
                                          builder: (BuildContext context) {
                                            return ChallengeDetail(childId: widget.childId, commonMemberId: list[index]["commonMemberId"],);
                                          },
                                        );
                                      }
                                    },
                                    child: Container(
                                      height: 32,
                                      margin: EdgeInsets.only(top:16),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.start,
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        children: [
                                          SizedBox(width: 6,),
                                          ClipRRect(
                                              borderRadius: BorderRadius.circular(30),
                                              child: CachedNetworkImage(imageUrl:
                                              list[index]["fileUrl"] ?? "",
                                                width : 24,
                                                height: 24,
                                                fit: BoxFit.cover,
                                                errorWidget: (context, url, error) {
                                                  return SvgPicture.asset("assets/icons/profile_${(list[index]["id"]%3) + 1}.svg",width: 57, height: 57, );
                                                },
                                              )
                                          ),
                                          SizedBox(width: 6,),
                                          Text(list[index]["name"] + "${list[index]["nickName"].isEmpty ? "" : "(${list[index]["nickName"]})"}", style: MainTheme.body5(MainTheme.gray7),)
                                        ],
                                      ),

                                    ),
                                  )


                          ),
                        );
                    }else{
                      return MainTheme.ErrorPage(context,"아직 응원메시지를\n누른 친구가 없어요");
                    }
                  }else{
                    return MainTheme.ErrorPage(context, jsonDecode(utf8.decode(snapshot.data.bodyBytes))["message"]);
                  }
                }
            )


            )
          ],
        ),
      ),
    );
  }

  Future<Response> get() async {
    var response = await apiRequestGet(context, urlCheerList + "/" + widget.commonMemberId.toString(),{"size" : "20"});
    var body =jsonDecode(utf8.decode(response.bodyBytes));
    if(response.statusCode == 200){
      setState(() {
        totalCount =body["data"]["totalElements"];
      });
      index = 0;
      list = body["data"]["content"];
    }
    return response;
  }

  void scroll() async {
    var response = await apiRequestGet(context, urlCheerList + "/" + widget.commonMemberId.toString(),{"size" : "20" , "page" : "${index+1}"});
    var body =jsonDecode(utf8.decode(response.bodyBytes));
    if(response.statusCode == 200){
      if(body["data"]["content"].length > 0){
        setState(() {
          index++;
          list.addAll(body["data"]["content"]);
        });
      }
    }
  }
}
