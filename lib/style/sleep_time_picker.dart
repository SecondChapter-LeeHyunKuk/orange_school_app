import 'dart:convert';
import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_svg/svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';

import '../util/api.dart';
import 'main-theme.dart';
String urlSleep = "${dotenv.env['BASE_URL']}user/timeTable/sleep";

class SleepTimePicker extends StatefulWidget {
  final int commonMemberId;
  final DateTime? wakeup;
  final DateTime? sleep;
  const SleepTimePicker ({ Key? key, required this.commonMemberId ,this.wakeup, this.sleep}): super(key: key);
  @override
  _SleepTimePicker createState() => _SleepTimePicker();
}

class _SleepTimePicker extends State<SleepTimePicker> {
  DateTime pickerSelectDay = DateTime.now();
  DateTime pickerSelectDay2 = DateTime.now().add(Duration(days: 1));
  bool wakeupMode = true;
  String? wakeup;
  String? sleep;
  @override
  void initState() {
    super.initState();
    if(widget.wakeup != null){
      pickerSelectDay = widget.wakeup!;
      wakeup = DateFormat("hh:MM:ss").format(pickerSelectDay);
    }
    if(widget.sleep != null){
      pickerSelectDay2 = widget.sleep!;
      sleep = DateFormat("hh:MM:ss").format(pickerSelectDay2);
    }

  }

  @override
  Widget build(BuildContext context) {

    return Container(
      height: 411,

      decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ) ),

      child:Column(
        children: [
          SizedBox( height : 34),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SizedBox(width: 16,),
              SvgPicture.asset("assets/icons/ic_16_clock.svg",width: 24, height: 24,),
              SizedBox(width: 9,),
              Expanded(child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color : MainTheme.gray2, width: 1.5)
                ),
                height: 80,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    SizedBox(width: 20,),
                    GestureDetector(
                      onTap: (){
                        setState(() {
                          wakeupMode = true;
                        });
                      },
                      child:Container(width: 88,
                    child: 
                    
                    IntrinsicHeight(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text("기상시간", style: MainTheme.body9(wakeupMode ? MainTheme.mainColor : MainTheme.gray7),),
                          Text(wakeup == null ? "오전 -:-" :
                          DateFormat("aa hh:mm", 'ko_KR').format(DateTime.parse("2020-01-01 ${wakeup}"))
                            , style: TextStyle(fontWeight: FontWeight.w800, fontFamily: "SUIT", fontSize: 16, color: wakeupMode ? MainTheme.mainColor : MainTheme.gray7, letterSpacing: 0),)
                        ],
                      ),
                    )
                    ),),
                    SvgPicture.asset(
                      'assets/icons/arrow_right_gray.svg',
                      width: 16,
                      height: 16,
                    ),
                    SizedBox(width: 9,),
                    GestureDetector(
                      onTap: (){
                        setState(() {

                          wakeupMode = false;
                        });
                      },
                      child: Container(width: 88,
                          child:

                          IntrinsicHeight(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text("취침시간", style: MainTheme.body9(!wakeupMode ? MainTheme.mainColor : MainTheme.gray7),),
                                Text(sleep == null ? "오후 -:-" :
                                DateFormat("aa hh:mm", 'ko_KR').format(DateTime.parse("2020-01-01 ${sleep}")), style: TextStyle(fontWeight: FontWeight.w800, fontFamily: "SUIT", fontSize: 16, color: !wakeupMode ? MainTheme.mainColor : MainTheme.gray7, letterSpacing: 0),)
                              ],
                            ),
                          )
                      ),
                    )

                    
                  ],
                ),
              )),
              SizedBox(width: 16,),
            ],
          ),
          wakeupMode ?
          Expanded(child:
          ClipRRect(
              borderRadius: BorderRadius.circular(24.0),
              child:

              CupertinoDatePicker(
                backgroundColor:
                CupertinoColors.white,
                mode: CupertinoDatePickerMode.time,
                initialDateTime: pickerSelectDay,
                use24hFormat: false, // 12시간 형식 사용
                onDateTimeChanged: (newDateTime) {
                  pickerSelectDay = newDateTime;
                  setState(() {
                    wakeup = DateFormat("HH:mm:ss").format(newDateTime);
                  });
                },
              )


          )
          ) : SizedBox.shrink(),
          !wakeupMode ?
          Expanded(child:
          ClipRRect(
              borderRadius: BorderRadius.circular(24.0),
              child:

              CupertinoDatePicker(
                backgroundColor:
                CupertinoColors.white,
                mode: CupertinoDatePickerMode.time,
                initialDateTime: pickerSelectDay2,
                use24hFormat: false, // 12시간 형식 사용
                onDateTimeChanged: (newDateTime) {
                  pickerSelectDay2 = newDateTime;
                  setState(() {
                    sleep = DateFormat("HH:mm:ss").format(newDateTime);
                  });
                },
              )


          )
          ): SizedBox.shrink(),

          Container(
            height: 98,
            padding: EdgeInsets.fromLTRB(16, 10, 16, 39),
            child:
            ElevatedButton(
                onPressed: (){
                  if(wakeup == null ){
                    Fluttertoast.showToast(
                        msg: "기상시간을 설정하세요",
                        toastLength: Toast.LENGTH_SHORT,
                        gravity: ToastGravity.CENTER,
                        timeInSecForIosWeb: 1,
                        backgroundColor: Colors.black,
                        textColor: Colors.white,
                        fontSize: 16.0
                    );
                    return;
                  }
                  if(sleep == null ){
                    Fluttertoast.showToast(
                        msg: "취침시간을 설정하세요",
                        toastLength: Toast.LENGTH_SHORT,
                        gravity: ToastGravity.CENTER,
                        timeInSecForIosWeb: 1,
                        backgroundColor: Colors.black,
                        textColor: Colors.white,
                        fontSize: 16.0
                    );
                    return;
                  }
                  if(wakeup == sleep ){
                    Fluttertoast.showToast(
                        msg: "기상시간과 취침시간이 같습니다.",
                        toastLength: Toast.LENGTH_SHORT,
                        gravity: ToastGravity.CENTER,
                        timeInSecForIosWeb: 1,
                        backgroundColor: Colors.black,
                        textColor: Colors.white,
                        fontSize: 16.0
                    );
                    return;
                  }
                  save();

                },
                style: MainTheme.primaryButton(MainTheme.mainColor),
                child: Text("저장", style: MainTheme.body4(Colors.white),)),

          )
        ],
      )


      ,

    );

  }
  Future<void> save() async {
    var response = await apiRequestPost(urlSleep+ "/" + widget.commonMemberId.toString(), {"wakeTime" : wakeup, "sleepTime" : sleep});
    var body =jsonDecode(utf8.decode(response.bodyBytes));
    if(response.statusCode == 200){
      Navigator.pop(context);
    }else{
      print(body);
      ScaffoldMessenger.of(context)
          .showSnackBar(MainTheme.snackBar(body["message"]));
    }
  }
}

