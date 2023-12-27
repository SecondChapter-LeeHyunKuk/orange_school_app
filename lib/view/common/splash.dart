import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:orange_school/style/main-theme.dart';
import 'package:flutter/foundation.dart' as foundation;
import 'package:flutter_svg/flutter_svg.dart';
class Splash extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _Splash();
}

class _Splash extends State<Splash> {

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    new Future.delayed(
        const Duration(seconds: 1),
            () => Navigator.of(context).pushReplacementNamed("/login"));
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(statusBarColor:Colors.white, statusBarIconBrightness: Brightness.dark));
    return Scaffold(
      backgroundColor: Colors.white,
      body:
        Stack(
          alignment: Alignment.center,
          children: [
            Positioned(top : 280, child: SvgPicture.asset("assets/images/splash_front.svg", width:220, height: 126,),),
            Positioned(bottom : 0, left: 0, child: SvgPicture.asset("assets/images/splash_back.svg", fit:BoxFit.fitHeight, width: MediaQuery.of(context).size.width))
          ],
        )
    );
  }


}
