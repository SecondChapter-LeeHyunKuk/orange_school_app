import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_naver_login/flutter_naver_login.dart';
import 'package:flutter_svg/svg.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart';
import 'package:orange_school/style/main-theme.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:the_apple_sign_in/the_apple_sign_in.dart';
import 'package:the_apple_sign_in/scope.dart' as apple;
import 'package:url_launcher/url_launcher.dart';
import '../../util/api.dart';

String urlLogin = "${dotenv.env['BASE_URL']}common/login";
String urlSocial = "${dotenv.env['BASE_URL']}common/login/social";
String urlMy = "${dotenv.env['BASE_URL']}user/commonMember";
String urlVisitor = "${dotenv.env['BASE_URL']}visitor";
String urlEmailCheck = "${dotenv.env['BASE_URL']}common/check/email";
String urlBaseInfo = "${dotenv.env['BASE_URL']}common/baseInfo";

class Login extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _Login();
}

class _Login extends State<Login> {
  bool autoLogin = true;
  TextEditingController te_email = TextEditingController();
  TextEditingController te_password = TextEditingController();
  String? emailMessage;
  String? passwordMessage;
  @override
  void initState() {
    // TODO: implement initState

    getVersion();
    super.initState();

    permission();
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
        statusBarColor: Colors.white,
        statusBarIconBrightness: Brightness.dark));
    return Scaffold(
        backgroundColor: Colors.white,
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(0),
          child: AppBar(
            backgroundColor: Colors.white,
          ),
        ),
        body: SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: Stack(
              children: [
                Container(
                  margin: EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        height: 98,
                      ),
                      Text("로그인", style: MainTheme.heading1(MainTheme.gray7)),
                      Text("우리 아이와 함께하는 일상",
                          style: MainTheme.body8(MainTheme.gray6)),
                      SizedBox(
                        height: 34,
                      ),
                      Text("이메일/ID",
                          style: MainTheme.caption1(MainTheme.gray5)),
                      Container(
                        height: 4,
                      ),
                      Container(
                        height: 51,
                        child: TextField(
                          onChanged: (String value) {
                            if (value.isEmpty) {
                              setState(() {
                                emailMessage = null;
                              });
                            } else if (!RegExp(r'^[^@].*?@.*[^@]$')
                                    .hasMatch(te_email.text) &&
                                !RegExp(r'^(?=.*[a-zA-Z])(?=.*\d)[a-zA-Z\d]+$')
                                    .hasMatch(te_email.text)) {
                              setState(() {
                                emailMessage = "이메일/ID 형식이 맞지 않아요.";
                              });
                            } else {
                              setState(() {
                                emailMessage = null;
                              });
                            }
                          },
                          decoration: MainTheme.inputTextGray("이메일/ID를 입력해주세요"),
                          controller: te_email,
                          keyboardType: TextInputType.emailAddress,
                          style: MainTheme.body5(MainTheme.gray7),
                        ),
                      ),
                      emailMessage != null
                          ? Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(
                                  height: 5,
                                ),
                                Text(
                                  emailMessage!,
                                  style: MainTheme.helper(Color(0xfff24147)),
                                )
                              ],
                            )
                          : Container(
                              height: 17,
                            ),
                      Text("비밀번호", style: MainTheme.caption1(MainTheme.gray5)),
                      Container(
                        height: 4,
                      ),
                      Container(
                        height: 51,
                        child: TextField(
                          onChanged: (String value) {
                            setState(() {
                              passwordMessage = null;
                            });
                          },
                          decoration: MainTheme.inputTextGray("비밀번호를 입력해주세요"),
                          obscureText: true,
                          controller: te_password,
                          style: MainTheme.body5(MainTheme.gray7),
                        ),
                      ),
                      passwordMessage != null
                          ? Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(
                                  height: 5,
                                ),
                                Text(
                                  passwordMessage!,
                                  style: MainTheme.helper(Color(0xfff24147)),
                                )
                              ],
                            )
                          : Container(
                              height: 13,
                            ),
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            autoLogin = !autoLogin;
                          });
                        },
                        child: Container(
                          height: 22,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              MainTheme.blackCheckBox(autoLogin),
                              Container(
                                width: 8,
                              ),
                              Text(
                                "자동로그인",
                                style: TextStyle(
                                    color: Color(0xff262c31),
                                    fontFamily: "Pretendard",
                                    fontWeight: FontWeight.w500,
                                    fontSize: 14),
                              )
                            ],
                          ),
                        ),
                      ),
                      Container(
                        height: 34,
                      ),
                      ElevatedButton(
                          onPressed: () {
                            login();
                          },
                          style: MainTheme.primaryButton(MainTheme.mainColor),
                          child: Text(
                            "로그인",
                            style: MainTheme.body4(Colors.white),
                          )),
                      Container(
                        height: 14,
                      ),
                      Container(
                        alignment: Alignment.center,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            GestureDetector(
                              onTap: () {
                                Navigator.of(context).pushNamed('/searchEmail');
                              },
                              child: Text(
                                "이메일 찾기",
                                style: MainTheme.body8(MainTheme.gray6),
                              ),
                            ),
                            Container(
                              width: 13,
                            ),
                            GestureDetector(
                              onTap: () {
                                Navigator.of(context)
                                    .pushNamed('/searchPassword');
                              },
                              child: Text(
                                "비밀번호 찾기",
                                style: MainTheme.body8(MainTheme.gray6),
                              ),
                            ),
                            Container(
                              width: 13,
                            ),
                            GestureDetector(
                              onTap: () {
                                Navigator.of(context)
                                    .pushNamed('/registerParent');
                              },
                              child: Text(
                                "회원가입",
                                style: MainTheme.body8(MainTheme.gray6),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        height: 60,
                      ),
                      Container(
                        alignment: Alignment.center,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            GestureDetector(
                              onTap: () async {
                                naverLogin();
                              },
                              child: SvgPicture.asset(
                                "assets/icons/naver.svg",
                                width: 64,
                                height: 64,
                              ),
                            ),
                            Container(
                              width: 11,
                            ),
                            GestureDetector(
                              onTap: () async {
                                kakaoLogin();
                              },
                              child: SvgPicture.asset(
                                "assets/icons/kakao.svg",
                                width: 64,
                                height: 64,
                              ),
                            ),
                            Platform.isIOS
                                ? Row(
                                    children: [
                                      Container(
                                        width: 11,
                                      ),
                                      GestureDetector(
                                        onTap: () async {
                                          appleLogin();
                                        },
                                        child: SvgPicture.asset(
                                          "assets/icons/apple.svg",
                                          width: 64,
                                          height: 64,
                                        ),
                                      ),
                                    ],
                                  )
                                : SizedBox.shrink()
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Positioned(
                  right: 16,
                  top: 43,
                  child: SvgPicture.asset(
                    "assets/icons/app_ic.svg",
                    height: 112,
                  ),
                )
              ],
            )));
  }

  Future<void> login() async {
    SharedPreferences pref = await SharedPreferences.getInstance();

    if (te_email.text == "") {
      setState(() {
        emailMessage = "이메일을 입력해 주세요.";
      });
      return;
    }

    if (te_password.text == "") {
      setState(() {
        passwordMessage = "비밀번호를 입력해 주세요.";
      });
      return;
    }

    if (!RegExp(r'^[^@].*?@.*[^@]$').hasMatch(te_email.text) &&
        !RegExp(r'^(?=.*[a-zA-Z])(?=.*\d)[a-zA-Z\d]+$')
            .hasMatch(te_email.text)) {
      setState(() {
        emailMessage = "이메일 형식이 맞지 않아요.";
      });
      return;
    }
    setState(() {
      passwordMessage = null;
      emailMessage = null;
    });

    Map<String, dynamic> request = new Map<String, Object>();
    request["account"] = te_email.text;
    request["password"] = te_password.text;
    request["pushToken"] = pref.getString("pushToken");
    print(request["pushToken"]);
    var response = await apiRequestPost(context, urlLogin, request);
    var body = jsonDecode(utf8.decode(response.bodyBytes));
    if (response.statusCode == 200) {
      pref.setBool("autoLogin", autoLogin);

      if (autoLogin) {
        pref.setString("email", te_email.text);
        pref.setString("password", te_password.text);
      }

      //로그인 성공 시 로그인 정보 저장
      String accessToken = body["data"]["accessToken"];
      pref.setString("accessToken", accessToken);
      int userId = body["data"]["id"];
      pref.setInt("userId", userId);

      //내 정보 조회
      var response = await apiRequestGet(context, urlMy, {});
      body = jsonDecode(utf8.decode(response.bodyBytes));
      if (response.statusCode == 200) {
        pref.setString("profile", body["data"]["fileUrl"] ?? "");
        pref.setString("name", body["data"]["name"]);
        pref.setString("myEmail", body["data"]["email"]);
        pref.setInt("locationCode", body["data"]["locationCode"]);
        pref.remove("selectedChildId");
        if (body["data"]["memberType"] == "PARENT") {
          apiRequestPost(context, urlVisitor, {"memberType": "PARENT"});
          Navigator.pushNamedAndRemoveUntil(
              context, '/parentTabBar', (route) => false);
        } else {
          apiRequestPost(context, urlVisitor, {"memberType": "CHILD"});
          Navigator.pushNamedAndRemoveUntil(
              context, '/childTabBar', (route) => false);
        }
      }
    } else if (response.statusCode == 404) {
      setState(() {
        emailMessage = "등록되지 않은 이메일이에요.";
      });
    } else if (response.statusCode == 401) {
      if (body["message"].contains("비활성화")) {
        setState(() {
          emailMessage = "활동하지 않는 계정이에요. 오렌지스쿨에 문의하세요.";
        });
      } else {
        setState(() {
          passwordMessage = "비밀번호가 맞지 않아요.";
        });
      }
    }
  }

  Future<void> socialLogin(Map userInfo) async {
    SharedPreferences pref = await SharedPreferences.getInstance();

    Map<String, dynamic> request = new Map<String, Object>();
    request["joinType"] = userInfo["joinType"];
    request["socialToken"] = userInfo["socialToken"];
    request["pushToken"] = pref.getString("pushToken");

    var response = await apiRequestPost(context, urlSocial, request);
    var body = jsonDecode(utf8.decode(response.bodyBytes));
    if (response.statusCode == 200) {
      pref.setBool("autoLogin", autoLogin);

      if (autoLogin) {
        pref.setString("email", userInfo["joinType"]);
        pref.setString("password", "");
      }

      //로그인 성공 시 로그인 정보 저장
      String accessToken = body["data"]["accessToken"];
      pref.setString("accessToken", accessToken);
      int userId = body["data"]["id"];
      pref.setInt("userId", userId);

      //내 정보 조회
      var response = await apiRequestGet(context, urlMy, {});
      body = jsonDecode(utf8.decode(response.bodyBytes));
      if (response.statusCode == 200) {
        pref.setString("profile", body["data"]["fileUrl"] ?? "");
        pref.setString("name", body["data"]["name"]);
        pref.setString("myEmail", body["data"]["email"]);
        pref.setInt("locationCode", body["data"]["locationCode"]);
        pref.remove("selectedChildId");
        if (body["data"]["memberType"] == "PARENT") {
          apiRequestPost(context, urlVisitor, {"memberType": "PARENT"});
          Navigator.pushNamedAndRemoveUntil(
              context, '/parentTabBar', (route) => false);
        } else {
          apiRequestPost(context, urlVisitor, {"memberType": "CHILD"});
          Navigator.pushNamedAndRemoveUntil(
              context, '/childTabBar', (route) => false);
        }
      }
    } else if (response.statusCode == 404) {
      Navigator.of(context).pushNamed('/registerParent', arguments: userInfo);
      // bool usable =  await checkEmail(userInfo["email"]);
      // if(usable){
      //   Navigator.of(context).pushNamed('/registerParent',arguments: userInfo);
      // }else{
      //   ScaffoldMessenger.of(context)
      //       .showSnackBar(MainTheme.snackBar("해당 이메일은 이미 가입되어있습니다."));
      // }
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(MainTheme.snackBar(body["message"]));
    }
  }

  Future<void> tryAutoLogin() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    if (pref.getBool("autoLogin") != null) {
      setState(() {
        autoLogin = pref.getBool("autoLogin")!;
      });
    }
    String? email = pref.getString("email");
    if (autoLogin) {
      switch (email) {
        case 'NAVER':
          naverLogin();
          break;
        case 'KAKAO':
          kakaoLogin();
          break;
        case 'APPLE':
          appleLogin();
          break;
        default:
          te_email.text = pref.getString("email")!;
          te_password.text = pref.getString("password")!;
          login();
      }
    }
  }

  Future<bool> permission() async {
    LocationPermission permission;
    permission = await Geolocator.requestPermission();
    return true;
  }

  Future<bool> checkEmail(String? email) async {
    if (email == null) {
      return true;
    }
    Map<String, dynamic> request = new Map<String, Object>();
    request["email"] = email;
    var response = await apiRequestPost(context, urlEmailCheck, request);
    var body = jsonDecode(utf8.decode(response.bodyBytes));
    if (response.statusCode == 200) {
      return true;
    } else {
      return false;
    }
  }

  Future<void> naverLogin() async {
    NaverLoginResult _result = await FlutterNaverLogin.logIn();
    socialLogin({
      "joinType": "NAVER",
      "name": _result.account.name,
      "birth": _result.account.birthyear.isNotEmpty &&
              _result.account.birthday.isNotEmpty
          ? DateTime.parse(
              '${_result.account.birthyear}-${_result.account.birthday}')
          : null,
      "phoneNumber": _result.account.mobile,
      "email": _result.account.email,
      "socialToken": _result.account.id,
      "gender": _result.account.gender == "F"
          ? false
          : _result.account.gender == "M"
              ? true
              : null
    });
  }

  Future<void> kakaoLogin() async {
    if (await isKakaoTalkInstalled()) {
      try {
        await UserApi.instance.loginWithKakaoTalk();
        try {
          User user = await UserApi.instance.me();
          socialLogin({
            "joinType": "KAKAO",
            "name": user.kakaoAccount?.name,
            "birth": user.kakaoAccount?.birthyear != null &&
                    user.kakaoAccount?.birthday != null
                ? DateTime.parse(
                    '${user.kakaoAccount?.birthyear}-${user.kakaoAccount!.birthday!.substring(0, 2)}-${user.kakaoAccount!.birthday!.substring(2)}')
                : null,
            "phoneNumber": user.kakaoAccount?.phoneNumber,
            "email": user.kakaoAccount?.email,
            "socialToken": user.id.toString(),
            "gender": user.kakaoAccount?.gender == Gender.male
                ? true
                : user.kakaoAccount?.gender == Gender.female
                    ? false
                    : null,
          });
        } catch (error) {}
      } catch (error) {}
    } else {
      try {
        await UserApi.instance.loginWithKakaoAccount();
        try {
          User user = await UserApi.instance.me();
          socialLogin({
            "joinType": "KAKAO",
            "socialToken": user.id.toString(),
            "profile": user.kakaoAccount?.profile?.profileImageUrl
          });
        } catch (error) {
          print('사용자 정보 요청 실패 $error');
        }
      } catch (error) {
        print('카카오계정으로 로그인 실패 $error');
      }
    }
  }

  Future<void> appleLogin() async {
    if (await TheAppleSignIn.isAvailable()) {
      // 2. 로그인 수행(FaceId 또는 Password 입력)
      final AuthorizationResult result = await TheAppleSignIn.performRequests([
        const AppleIdRequest(
            requestedScopes: [apple.Scope.email, apple.Scope.fullName])
      ]);

      // 3. 로그인 권한 여부 체크
      switch (result.status) {
        // 3-1. 로그인 권한을 부여받은 경우
        case AuthorizationStatus.authorized:
          (result.credential!.fullName == null);
          socialLogin({
            "joinType": "APPLE",
            "name": result.credential!.fullName?.familyName == null
                ? null
                : "${result.credential!.fullName!.familyName}${result.credential!.fullName!.givenName}",
            "birth": null,
            "phoneNumber": null,
            "email": result.credential!.email,
            "socialToken": result.credential!.user,
            "gender": null
          });

          break;
        // 3-2. 오류가 발생한 경우
        case AuthorizationStatus.error:
          break;
        // 3-3. 유저가 직접 취소한 경우
        case AuthorizationStatus.cancelled:
          break;
      }
    } else {}
  }

  Future<void> getVersion() async {
    String todayStr = DateFormat("yyyy-MM-dd").format(DateTime.now());

    SharedPreferences pref = await SharedPreferences.getInstance();



    var response = await apiRequestGet(context, urlBaseInfo, {});
    var body = jsonDecode(utf8.decode(response.bodyBytes));

    if (response.statusCode == 200) {

      PackageInfo packageInfo = await PackageInfo.fromPlatform();
      bool? showDialog = false;


      //현재 버전정보 추출
      if (Platform.isIOS) {
        if ((body["data"]["iosVersion"] ?? "") != "") {
          if (packageInfo.version != body["data"]["iosVersion"]) {
            showDialog = true;
          }
        }
      } else {
        if ((body["data"]["androidVersion"] ?? "") != "") {
          if (packageInfo.version != body["data"]["androidVersion"]) {
            showDialog = true;
          }
        }
      }
      if (showDialog) {
        //마지막 팝업조회일자를 조회
        var updateViewDate = pref.getString("updateViewDate");

        if ((updateViewDate ?? "12345") != todayStr) {
          pref.setString("updateViewDate", todayStr);
          bool? move = await updateDialog();
          if (move != null) {
            if (move) {
              if (Platform.isIOS) {
                launchUrl(
                  Uri.parse("https://apps.apple.com/kr/app/id6475079694"),
                );
              } else {
                launchUrl(
                  Uri.parse(
                      "https://play.google.com/store/apps/details?id=com.orangeschool.orange_school"),
                );
              }
            }
          }
        }
      }
    }

    tryAutoLogin();
  }

  Future<bool?> updateDialog() async {
    return await showDialog(
      context: context,
      barrierDismissible: true, //바깥 영역 터치시 닫을지 여부 결정
      builder: ((context) {
        return AlertDialog(
          contentPadding: EdgeInsets.all(0),
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.white,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(10))),
          content: Container(
            width: 320,
            height: 204,
            padding: EdgeInsets.all(20),
            child: Column(
              children: [
                Expanded(
                    child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      "업데이트 안내",
                      style: MainTheme.body2(MainTheme.gray7),
                    ),
                    Text(
                      "새로운 버전이 출시되었습니다. 확인 버튼을 눌러 스토어로 이동합니다.",
                      style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontFamily: "SUIT",
                          fontSize: 15,
                          height: 1.486,
                          color: MainTheme.gray5,
                          letterSpacing: 0),
                      textAlign: TextAlign.center,
                    ),
                  ],
                )),
                Container(
                  width: double.infinity,
                  height: 49,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop(true);
                    },
                    child: Text(
                      "확인",
                      style: MainTheme.body4(Colors.white),
                    ),
                    style: MainTheme.primaryButton(MainTheme.mainColor),
                  ),
                )
              ],
            ),
          ),
        );
      }),
    );
  }
}
