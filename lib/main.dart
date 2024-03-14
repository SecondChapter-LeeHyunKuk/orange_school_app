import 'dart:ffi';

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart';
import 'package:orange_school/style/main-theme.dart';
import 'package:orange_school/view/child/child_my.dart';
import 'package:orange_school/view/child/child_tab_bar.dart';
import 'package:orange_school/view/child/child_update.dart';
import 'package:orange_school/view/child/child_update_school.dart';
import 'package:orange_school/view/common/alarm.dart';
import 'package:orange_school/view/common/alarmDetail.dart';
import 'package:orange_school/view/common/alarmSetting.dart';
import 'package:orange_school/view/common/change_password.dart';
import 'package:orange_school/view/common/chart.dart';
import 'package:orange_school/view/common/login.dart';
import 'package:orange_school/view/common/notice.dart';
import 'package:orange_school/view/common/noticeDetail.dart';
import 'package:orange_school/view/common/register_academy.dart';
import 'package:orange_school/view/common/register_child.dart';
import 'package:orange_school/view/common/register_complete.dart';
import 'package:orange_school/view/common/register_parent.dart';
import 'package:orange_school/view/common/register_school.dart';
import 'package:orange_school/view/common/resign.dart';
import 'package:orange_school/view/common/search_email.dart';
import 'package:orange_school/view/common/search_email_result.dart';
import 'package:orange_school/view/common/search_password.dart';
import 'package:orange_school/view/common/splash.dart';
import 'package:orange_school/view/common/terms.dart';
import 'package:orange_school/view/common/terms_list.dart';
import 'package:orange_school/view/parent/parent_board_detail.dart';
import 'package:orange_school/view/parent/parent_challenge_create.dart';
import 'package:orange_school/view/parent/parent_challenge_firends.dart';
import 'package:orange_school/view/parent/parent_challenge_search.dart';
import 'package:orange_school/view/parent/parent_challenge_update.dart';
import 'package:orange_school/view/parent/parent_child_update.dart';
import 'package:orange_school/view/parent/parent_children.dart';
import 'package:orange_school/view/parent/parent_plan.dart';
import 'package:orange_school/view/parent/parent_my.dart';
import 'package:orange_school/view/parent/parent_tab_bar.dart';
import 'package:orange_school/view/parent/parent_update.dart';
import 'package:orange_school/view/parent/parent_update_school.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'firebase_options.dart';

late FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;
late AndroidNotificationChannel channel;
bool isFlutterLocalNotificationsInitialized = false;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  SharedPreferences pref = await SharedPreferences.getInstance();
  await dotenv.load(fileName: 'assets/config/.env');
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await setupFlutterNotifications();

  String? token = await FirebaseMessaging.instance.getToken();
  if (token != null) {
    pref.setString("pushToken", token!);
  }
  KakaoSdk.init(nativeAppKey: '615c25ed06f51a8b7e8125b8ddb6c2e7');

  runApp(const MyApp());
}

Future<void> setupFlutterNotifications() async {
  if (isFlutterLocalNotificationsInitialized) {
    return;
  }
  channel = const AndroidNotificationChannel(
    'high_importance_channel', // id
    'High Importance Notifications', // title
    description: 'This channel is used for important notifications.', // description
    importance: Importance.high,
  );
  flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
  await flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()?.createNotificationChannel(channel);
  // iOS foreground notification 권한
  await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
    alert: true,
    badge: true,
    sound: true,
  );
  // IOS background 권한 체킹 , 요청
  await FirebaseMessaging.instance.requestPermission(
    alert: true,
    announcement: false,
    badge: true,
    carPlay: false,
    criticalAlert: false,
    provisional: false,
    sound: true,
  );
  // 셋팅flag 설정
  isFlutterLocalNotificationsInitialized = true;
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    // foreground 수신처리
    FirebaseMessaging.onMessage.listen(showFlutterNotification);
    // background 수신처리
    //FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  }
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    final FirebaseAnalytics analytics = FirebaseAnalytics.instance;
    return MaterialApp(
        navigatorObservers: [
          FirebaseAnalyticsObserver(analytics: analytics),
        ],
        builder: (context, child) {
          final MediaQueryData data = MediaQuery.of(context);

          return MediaQuery(
            data: data.copyWith(textScaler: TextScaler.noScaling),
            child: child!,
          );
        },
      debugShowCheckedModeBanner: false,
      title: 'Orange School',
        theme: ThemeData(
          fontFamily: 'SUIT',
          primaryColor: MainTheme.mainColor,
          canvasColor: Colors.white,
          textSelectionTheme: TextSelectionThemeData(
            selectionColor: MainTheme.mainColor,
            selectionHandleColor: MainTheme.mainColor,
            cursorColor: MainTheme.mainColor, //<-- SEE HERE
          ),
        ),
        localizationsDelegates: [
          GlobalMaterialLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: [
          Locale('ko', ''),
          Locale('en', ''),
        ],
      initialRoute: '/',
      routes: {
        /*공통 화면*/
        '/': (context) => Splash(),
        '/login': (context) => Login(),
        '/chart': (context) => Chart(),
        '/registerParent': (context) => RegisterParent(),
        '/registerChild': (context) => RegisterChild(),
        '/registerSchool': (context) => RegisterSchool(),
        '/registerAcademy': (context) => RegisterAcademy(),
        '/registerComplete': (context) => RegisterComplete(),
        '/searchEmail': (context) => SearchEmail(),
        '/searchEmailResult': (context) => SearchEmailResult(),
        '/searchPassword': (context) => SearchPassword(),
        '/changePassword': (context) => ChangePassword(),
        '/terms': (context) => Terms(),
        '/notice': (context) => Notice(),
        '/notice/detail': (context) => NoticeDetail(),
        '/alarm': (context) => Alarm(),
        '/alarm/detail': (context) => AlarmDetail(),
        '/alarm/setting': (context) => AlarmSetting(),
        '/terms/list': (context) => TermsList(),
        '/resign': (context) => Resign(),


        '/parent/challenge/update': (context) => ParentChallengeUpdate(),
        '/parent/challenge/create': (context) => ParentChallengeCreate(),
        '/parent/challenge/friends': (context) => ParentChallengeFriends(),
        '/parent/challenge/search': (context) => ParentChallengeSearch(),
        '/parent/board/detail': (context) => ParentBoardDetail(),
        '/parentTabBar': (context) => ParentTabBar(),
        '/parent/my': (context) => ParentMy(),
        '/parent/update': (context) => ParentUpdate(),
        '/parent/update/child': (context) => ParentChildUpdate(),
        '/parent/update/school': (context) => ParentUpdateSchool(),
        '/parent/my/children': (context) => ParentChildren(),


        /*자식 화면*/
        // '/parent/plan': (context) => ParentPlan(),
        // '/parent/challenge/update': (context) => ParentChallengeUpdate(),
        // '/parent/challenge/create': (context) => ParentChallengeCreate(),
        // '/parent/challenge/friends': (context) => ParentChallengeFriends(),
        // '/parent/challenge/search': (context) => ParentChallengeSearch(),
        // '/parent/board/detail': (context) => ParentBoardDetail(),
        '/childTabBar': (context) => ChildTabBar(),
         '/child/my': (context) => ChildMy(),
         '/child/update': (context) => ChildUpdate(),
        // '/parent/update/child': (context) => ParentChildUpdate(),
        '/child/update/school': (context) => ChildUpdateSchool(),
        // '/parent/my/children': (context) => ParentChildren(),
      }
    );
  }
  /// fcm 전경 처리 - 로컬 알림 보이기
  void showFlutterNotification(RemoteMessage message) {
    RemoteNotification? notification = message.notification;
    AndroidNotification? android = message.notification?.android;
    if (notification != null && android != null) {
      flutterLocalNotificationsPlugin.show(
        notification.hashCode,
        notification.title,
        notification.body,
        NotificationDetails(
          android: AndroidNotificationDetails(
            channel.id,
            channel.name,
            channelDescription: channel.description,
            // TODO add a proper drawable resource to android, for now using
            //      one that already exists in example app.
            icon: 'ic_neo',
          ),
        ),
      );
    }
  }

}


