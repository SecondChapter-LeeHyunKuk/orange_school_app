import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_svg/svg.dart';

import '../../style/main-theme.dart';
import '../../util/api.dart';
import 'package:http/http.dart';


String url = "https://open.neis.go.kr/hub/schoolInfo";
String schoolKey = "${dotenv.env["SCHOOL_KEY"]}";
class SearchSchoolBottom extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _SearchSchoolBottom();
}

class _SearchSchoolBottom extends State<SearchSchoolBottom> {

  List data = [];
  int index = 0;
  String nowKeyword = "";
  TextEditingController textEditingController = TextEditingController();
  ScrollController _scrollController = ScrollController(initialScrollOffset: 10.0);
  FocusNode focusNode = FocusNode();
  Future<Response>? getFuture;


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
  }

  @override
  Widget build(BuildContext context) {
    return  Container(
      height:MediaQuery.of(context).size.height * 0.9,
      padding: EdgeInsets.only(left: 16, right: 16),
      decoration: const BoxDecoration(
          color: Color(0xffF6F7F9),
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ) ),

      child:

      Column(
        children: [
          SizedBox(height: 19,),
          Container(height: 71,
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

          Container(
            height: 45,
            child: TextField(
              onEditingComplete: (){
                focusNode.unfocus();
                setState(() {
                  getFuture = searchSchool();
                });
              },
              controller: textEditingController,
              textInputAction: TextInputAction.done,
              focusNode: focusNode,
              textAlignVertical: TextAlignVertical.center,
              style: MainTheme.body5(MainTheme.gray7),
              decoration : InputDecoration(
                suffixIcon: GestureDetector(
                    onTap: (){
                      focusNode.unfocus();
                      setState(() {
                        getFuture = searchSchool();
                      });
                    },
                    child: const Icon(Icons.search, color: MainTheme.gray4, size: 24,)
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
                    borderSide: BorderSide(color: Colors.transparent)),
                border: InputBorder.none,
                hintText: "키워드를 입력해 주세요",
                hintStyle: MainTheme.body6(MainTheme.gray4),
              ),
            ),
          ),
          Container(
            height: 32,
          ),
          Expanded(child:

          FutureBuilder(
              future: getFuture,
              builder: (BuildContext context, AsyncSnapshot snapshot){
                if(getFuture == null){
                  return SizedBox.shrink();
                }else if (snapshot.connectionState != ConnectionState.done){
                  return MainTheme.LoadingPage(context);
                }else if(snapshot.data.statusCode == 200){
                  
                  if(data.length > 0){
                    return  RawScrollbar(
                      radius: Radius.circular(20),
                      thickness: 4,
                      thumbColor: Color(0xffd9d9d9),

                      controller: _scrollController,//여기도 전달
                      child: ListView.builder(
                          controller: _scrollController,//여기도 전달
                          itemCount: data.length,
                          itemBuilder: (context, index) => GestureDetector(
                            onTap: () {
                              Navigator.pop(context,
                                  {"schoolNm": data[index]["SCHUL_NM"], "schoolCode": data[index]["SCHUL_KND_SC_NM"] == "초등학교"? data[index]["ATPT_OFCDC_SC_CODE"] + ":" + data[index]["SD_SCHUL_CODE"] : null}
                              );
                            },
                            child: Container(
                              child: Text(data[index]["SCHUL_NM"],style: MainTheme.body5(MainTheme.gray7),),
                              padding: EdgeInsets.only(bottom: 28),
                            ),
                          )
                      ),
                    );
                  }else{
                    return MainTheme.ErrorPage(context, "검색 결과가 없습니다.");
                  }
                  
                }else{
                  return MainTheme.ErrorPage(context, "에러가 발생했습니다.");
                }
              }
          ),


          ),
          SizedBox(
            height:27
          )
        ],
      ),






    );
  }

  Future<Response> searchSchool() async {
    index = 1;
    data = [];
    nowKeyword =  textEditingController.text;
    var responseResult = await apiRequestGet(context, url,{"Type" : "json", "pIndex" : 1.toString(), "pSize": 20.toString(), "SCHUL_NM" : nowKeyword, "key" : schoolKey, "SCHUL_KND_SC_NM" : "초등학교"});
    var response =jsonDecode(utf8.decode(responseResult.bodyBytes));
    if(responseResult.statusCode == 200){
      if(response["schoolInfo"] != null){
        setState(() {
          data.addAll(response["schoolInfo"][1]["row"]);
        });
      }
    }
    return responseResult;
  }

  void scroll() async {
    var responseResult =  await apiRequestGet(context, url,{"Type" : "json", "pIndex" : (index + 1).toString(), "pSize": 20.toString(), "SCHUL_NM" : nowKeyword , "key" : schoolKey, "SCHUL_KND_SC_NM" : "초등학교"});
    var response =jsonDecode(utf8.decode(responseResult.bodyBytes));
    if(response["schoolInfo"][0]["head"][1]["RESULT"]["CODE"] == "INFO-000"){

      if(response["schoolInfo"] != null){
        setState(() {
          index++;
          data.addAll(response["schoolInfo"][1]["row"]);
        });
      }
    }
  }
}
