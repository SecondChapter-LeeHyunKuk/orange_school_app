import 'dart:convert';
import 'dart:ffi';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:orange_school/style/main-theme.dart';
import 'package:flutter/foundation.dart' as foundation;

import '../../util/api.dart';

String urlTerms = "${dotenv.env['BASE_URL']}common/terms/";

class Terms extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _Terms();
}

class _Terms extends State<Terms> {
  String title = "";
  String content = "";

  int? termsId;
  Future<void>? loadingArgs;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getTerms();
  }

  @override
  Widget build(BuildContext context) {
    loadingArgs = fn_loadingArgs();

    return Scaffold(
      appBar: AppBar(
        scrolledUnderElevation: 0.0,
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_rounded, color: MainTheme.gray7),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Column(

          children: [

            Container(margin: EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 40,
                  ),
                  Container(
                    child: Text(title, style: MainTheme.heading1(MainTheme.gray7)),
                  ),
                  Container(
                    height: 19,
                  ),
                  Text(content,style: MainTheme.body6(MainTheme.gray6),
                  )

                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Future<void> fn_loadingArgs() async {
    termsId = ModalRoute.of(context)?.settings.arguments as int;
  }

  Future<void> getTerms()async {

    await loadingArgs;
    var response = await apiRequestGet(context, urlTerms + (termsId!).toString(), {});
    var body = jsonDecode(utf8.decode(response.bodyBytes));
    if(response.statusCode == 200){
        setState(() {
        title = body["data"]["title"];
        content = body["data"]["content"];
        });
    }


  }

}
