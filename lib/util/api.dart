import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

import '../style/main-theme.dart';



Future<http.Response> openapiRequestGet(context, String url, Map<String, dynamic> param) async {

  try {
    http.Response response = await http.get(
        Uri.parse(url + "?" + Uri(queryParameters: param).query),
        headers: {
        }).timeout(const Duration(seconds: 10));
    log(Uri.parse(url + "?" + Uri(queryParameters: param).query).toString() + " response =" + response.statusCode.toString());
    return response;
  }on TimeoutException {
    return http.Response('{"message" : "server is not responding."}' , 408); //timeout 체크
  }
}

Future<http.Response> openApiXmlRequestGet(String url, Map<String, dynamic> param) async {

  try {
    http.Response response = await http.get(
        Uri.parse(url + "?" + Uri(queryParameters: param).query),
        headers: {
          'Content-Type': 'text/xml',
        }).timeout(const Duration(seconds: 10));
    log(Uri.parse(url + "?" + Uri(queryParameters: param).query).toString() + " response =" + response.statusCode.toString());
    return response;
  }on TimeoutException {
    return http.Response('{"message" : "server is not responding."}' , 408); //timeout 체크
  }
}
Future<http.Response> apiRequestGet(BuildContext context, String url, Map<String, dynamic> param) async {
  try {
    SharedPreferences pref = await SharedPreferences.getInstance(); //jwt 조회용
    http.Response response = await http.get(
        Uri.parse(url + "?" + Uri(queryParameters: param).query),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': pref.getString("accessToken") == null ? "" : pref
              .getString("accessToken")!
        }).timeout(const Duration(seconds: 10));
    log(Uri.parse(url + "?" + Uri(queryParameters: param).query).toString() + " response =" + response.statusCode.toString());
    log(jsonEncode(jsonDecode(utf8.decode(response.bodyBytes))));
    if(response.statusCode == 403){
      ScaffoldMessenger.of(context)
          .showSnackBar(MainTheme.snackBar('로그인이 만료되었습니다.'));
      if (context.mounted)  Navigator.pushNamedAndRemoveUntil(context,'/login', (route) => false);
    }
    return response;
  }on TimeoutException {
    return http.Response('{"message" : "server is not responding."}' , 408); //timeout 체크
  }
}

Future<http.Response> apiRequestDelete(BuildContext context,String url, Map<String, dynamic> param) async {
  try{
    SharedPreferences pref = await SharedPreferences.getInstance(); //jwt 조회용
    http.Response response = await http.delete(Uri.parse(url + "?" + Uri(queryParameters: param).query),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': pref.getString("accessToken") == null ? "" :  pref.getString("accessToken")!
        }).timeout(const Duration(seconds: 10));
    //log(url + " response =" + response.statusCode.toString());
    if(response.statusCode == 403){
      ScaffoldMessenger.of(context)
          .showSnackBar(MainTheme.snackBar('로그인이 만료되었습니다.'));
      if (context.mounted)  Navigator.pushNamedAndRemoveUntil(context,'/login', (route) => false);
    }
    return response;
  }on TimeoutException {
  return http.Response('{"message" : "server is not responding."}' , 408); //timeout 체크
  }
}

Future<http.Response> apiRequestPost(BuildContext context,String url, Map param) async {
  try{
    SharedPreferences pref = await SharedPreferences.getInstance(); //jwt 조회용
    http.Response response = await http.post(Uri.parse(url),
        body: json.encode(param),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': pref.getString("accessToken") == null ? "" :  pref.getString("accessToken")!
        }).timeout(const Duration(seconds: 10));
    log(url + " response =" + response.statusCode.toString());

    if(response.statusCode == 403){
      ScaffoldMessenger.of(context)
          .showSnackBar(MainTheme.snackBar('로그인이 만료되었습니다.'));
      if (context.mounted)  Navigator.pushNamedAndRemoveUntil(context,'/login', (route) => false);
    }
    return response;
  }on TimeoutException {
  return http.Response('{"message" : "server is not responding."}', 408); //timeout 체크
  }
}

Future<http.Response> apiRequestPut(BuildContext context,String url, Map param) async {
  try{
    SharedPreferences pref = await SharedPreferences.getInstance(); //jwt 조회용
    http.Response response = await http.put(Uri.parse(url),
        body: json.encode(param),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': pref.getString("accessToken") == null ? "" :  pref.getString("accessToken")!
        }).timeout(const Duration(seconds: 10));
    log(url + " response =" + response.statusCode.toString());
    if(response.statusCode == 403){
      ScaffoldMessenger.of(context)
          .showSnackBar(MainTheme.snackBar('로그인이 만료되었습니다.'));
      if (context.mounted)  Navigator.pushNamedAndRemoveUntil(context,'/login', (route) => false);
    }
    return response;
  }on TimeoutException {
  return http.Response('{"message" : "server is not responding."}' , 408); //timeout 체크
  }
}

Future<Response> httpRequestMultipart(BuildContext context,String url, FormData formData, bool post) async {
  try{
    SharedPreferences pref = await SharedPreferences.getInstance(); //jwt 조회용
    var dio = Dio();
    dio.options.headers["Content-Type"] = "application/json";

    if(pref.getString("accessToken") != null){
      dio.options.headers["Authorization"] = pref.getString("accessToken");
    }

    var response = post ?  await dio.post(url, data: formData).timeout(Duration(seconds: 10)) : await dio.put(url, data: formData).timeout(Duration(seconds: 10));
    if(response.statusCode == 403){
      ScaffoldMessenger.of(context)
          .showSnackBar(MainTheme.snackBar('로그인이 만료되었습니다.'));
      if (context.mounted)  Navigator.pushNamedAndRemoveUntil(context,'/login', (route) => false);
    }
    return response;
    
  }on TimeoutException {
    return Response(data: {"message" : "server is not responding."}, statusCode: 408, requestOptions: RequestOptions()); //timeout 체크
  }
}

