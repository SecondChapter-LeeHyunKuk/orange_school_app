import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../util/api.dart';



String url = "https://open.neis.go.kr/hub/schoolInfo";

class SearchSchool extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _SearchSchool();
}

class _SearchSchool extends State<SearchSchool> {
  List data = [];
  int index = 0;
  TextEditingController textEditingController = TextEditingController();
  ScrollController _scrollController = ScrollController();
  FocusNode focusNode = FocusNode();

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
    return AlertDialog(

        contentPadding: EdgeInsets.all(0),
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(6))),

        content:
        Container(
          width: 313,
          height: 502,
          child: Column(
            children: [
              Container(
                alignment: Alignment.centerRight,
                margin: EdgeInsets.only(bottom: 20),
                child: GestureDetector(
                  child: Icon(Icons.close),
                  onTap: () {
                    Navigator.of(context).pop();
                  },
                ),
              ),
              Container(
                margin: EdgeInsets.only(bottom: 20),
                child: Text("학교 검색", style: TextStyle(fontSize: 25)),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    child: TextField(
                        controller: textEditingController,
                        focusNode: focusNode,
                        maxLines: 1,
                        decoration: InputDecoration(
                          border: UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.black),
                          ),
                        )),
                  ),
                  GestureDetector(
                    onTap: () {
                      focusNode.unfocus();
                      setState(() {
                        searchSchool();
                      });
                    },
                    child: Icon(Icons.search),
                  )
                ],
              ),
              Container(
                height: 10,
              ),
              Expanded(child:
              RawScrollbar(
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
                            {"schoolNm": data[index]["SCHUL_NM"]}
                        );
                      },
                      child: Container(
                        child: Column(
                          children: [
                            Container(
                              alignment: Alignment.center,
                              height: 40,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Text(data[index]["SCHUL_NM"]),
                                ],
                              ),
                            ),
                            Divider(
                                thickness: 1, height: 1, color: Colors.black12),
                          ],
                        ),
                      ),
                    )
                ),
              )
              )
            ],
          ),
        )
        );
  }

  void searchSchool() async {
    index = 1;
    data = [];
    var responseResult = await apiRequestGet(context, url,{"Type" : "json", "pIndex" : 1.toString(), "pSize": 10.toString(), "SCHUL_NM" : textEditingController.text , "key" : "8a3319b07614480db9a06c4906426c52"});
    var response =jsonDecode(utf8.decode(responseResult.bodyBytes));
    if(response["schoolInfo"][0]["head"][1]["RESULT"]["CODE"] == "INFO-000"){
      setState(() {
        data.addAll(response["schoolInfo"][1]["row"]);
      });

    }
  }

  void scroll() async {
    var responseResult =  await apiRequestGet(context, url,{"Type" : "json", "pIndex" : (index + 1).toString(), "pSize": 10.toString(), "SCHUL_NM" : textEditingController.text , "key" : "8a3319b07614480db9a06c4906426c52"});
    var response =jsonDecode(utf8.decode(responseResult.bodyBytes));
    if(response["schoolInfo"][0]["head"][1]["RESULT"]["CODE"] == "INFO-000"){

      if(response["schoolInfo"][1]["row"].length > 0){
        setState(() {
          index++;
          data.addAll(response["schoolInfo"][1]["row"]);
        });
      }
    }
  }
}
