import 'package:flutter/material.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:loading_indicator/loading_indicator.dart';

class MainTheme {

  static const mainColor = Color(0xffff881A);
  static const subColor = Color(0xff66ccba);
  static const green = Color(0xffa5cc2b);

  static const backgroundWhite = Color(0xffffffff);
  static const backgroundGray = Color(0xfff6f7f9);

  static const gray1 = Color(0xfff4f6f6);
  static const gray2 = Color(0xffe6e8eb);
  static const gray3 = Color(0xffccd1d7);
  static const gray4 = Color(0xffadb4ba);
  static const gray5 = Color(0xff778088);
  static const gray6 = Color(0xff5a636a);
  static const gray7 = Color(0xff262C31);

  static const planColor = [
    Color(0xffFA8431),
    Color(0xff87B800),
    Color(0xff24CCAF),
    Color(0xff6A70EB),
    Color(0xffBE51FF),
    Color(0xffE745BA),
    Color(0xff8E8E8E),];

  static const planBgColor = [
    Color(0xffFFEEE3),
    Color(0xffEBF5D0),
    Color(0xffE1F7F3),
    Color(0xffE0E2FD),
    Color(0xffF3E0FF),
    Color(0xffFFE3F7),
    Color(0xffEEEEEE),];

  static const chartColor = [
    Color(0xffFF881A),
    Color(0xffF56397),
    Color(0xff8500F4),
    Color(0xffF4B000),
    Color(0xffF56363),
    Color(0xffD2F400),
    Color(0xff0EC4DD),
    Color(0xff3B7FCF),
    Color(0xffA93BCF),
    Color(0xffCF3B8B),
    Color(0xff84684E),
  ];

  static const inputGray = Color(0xfff4f6f6);

  //로딩 화면
  static Widget LoadingPage(BuildContext context) {
    double size = MediaQuery.of(context).size.width / 4.0;
    return Center(
      child: SizedBox(
        width: size,
        height: size,
        child: const LoadingIndicator(
          indicatorType: Indicator.circleStrokeSpin,
          colors: [mainColor],
          strokeWidth: 2,
        ),
      ),
    );
  }

  //에러 화면
  static Widget ErrorPage(BuildContext context, String message) {
    return Center(
        child:
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SvgPicture.asset(
              'assets/icons/info_gray.svg', width: 32, height: 32,
            ),
            SizedBox(height: 10,),
            Text(message, style: body8(Color(0xffB0BAC1)),)
          ],
        )
    );
  }


  static ButtonStyle primaryButton(Color color) {
    return ElevatedButton.styleFrom(
      elevation: 0.0,
      backgroundColor: color,
      disabledBackgroundColor: MainTheme.gray4 ,
      minimumSize: Size(double.infinity, 49),
      shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12)
      ),
      padding: EdgeInsets.zero
    );
  }


  static ButtonStyle hollowButton(Color color) {
    return ElevatedButton.styleFrom(
        elevation: 0.0,
        minimumSize: Size(double.infinity,0),
        backgroundColor: Colors.transparent,
        side: BorderSide(color: color),
        padding: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12)
        ),
    );
  }

  static ButtonStyle hollowFollowButton(Color color) {
    return ElevatedButton.styleFrom(
      elevation: 0.0,
      minimumSize: Size(double.infinity,0),
      backgroundColor: Colors.transparent,
      side: BorderSide(color: color),
      padding: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8)
      ),
    );
  }


  static ButtonStyle followButton() {
    return ElevatedButton.styleFrom(
        elevation: 0.0,
        padding: EdgeInsets.zero,
        backgroundColor: MainTheme.gray7,
        disabledBackgroundColor: MainTheme.gray4 ,
        minimumSize: Size(86, 35),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8)
        )
    );
  }

  static ButtonStyle miniButton(Color color) {
    return ElevatedButton.styleFrom(
        elevation: 0.0,
        padding: EdgeInsets.zero,
        backgroundColor: color,
        disabledBackgroundColor: MainTheme.gray4 ,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8)
        )
    );
  }

  static InputDecoration inputTextGray(String hint){
    return InputDecoration(
      contentPadding: const EdgeInsets.symmetric(
          horizontal: 16, vertical: 0),
      fillColor: MainTheme.backgroundGray,
      filled: true,
      focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(12.0)),
          borderSide: BorderSide(color: MainTheme.mainColor)),
      enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(12.0)),
          borderSide: BorderSide.none),
      disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(12.0)),
          borderSide: BorderSide.none),
      border: InputBorder.none,
      hintText: hint,
      hintStyle: TextStyle(fontWeight: FontWeight.w600, fontFamily: "SUIT", fontSize: 15, color: MainTheme.gray4),
    );
  }

  static InputDecoration inputTextAuthNum(String hint, int seconds){
    return InputDecoration(

        suffixIcon :


            Padding(
              padding: EdgeInsets.only(right: 16),

              child:
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(NumberFormat('00').format(seconds ~/ 60) + ":" + NumberFormat('00').format(seconds % 60) , style : MainTheme.body6(MainTheme.subColor),
                    textAlign: TextAlign.center,),
                ],
              )


            ),


      contentPadding: const EdgeInsets.symmetric(
          horizontal: 16, vertical: 0),
      fillColor: MainTheme.backgroundGray,
      filled: true,
      focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(12.0)),
          borderSide: BorderSide(color: MainTheme.mainColor)),
      enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(12.0)),
          borderSide: BorderSide.none),
      disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(12.0)),
          borderSide: BorderSide.none),
      border: InputBorder.none,
      hintText: hint,
      hintStyle: TextStyle(fontWeight: FontWeight.w600, fontFamily: "SUIT", fontSize: 15, color: MainTheme.gray4),
    );
  }
  static InputDecoration inputTextGrayExpand(String hint){
    return InputDecoration(
      alignLabelWithHint: true,
      contentPadding: const EdgeInsets.symmetric(
          horizontal: 16, vertical: 14),
      fillColor: MainTheme.backgroundGray,
      filled: true,
      focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(12.0)),
          borderSide: BorderSide(color: MainTheme.mainColor)),
      enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(12.0)),
          borderSide: BorderSide.none),
      border: InputBorder.none,
      hintText: hint,
      hintStyle: TextStyle(fontWeight: FontWeight.w600, fontFamily: "SUIT", fontSize: 15, color: MainTheme.gray4),
    );
  }
  static InputDecoration inputTextWhite(String hint){
    return InputDecoration(
      contentPadding: const EdgeInsets.symmetric(
          horizontal: 16, vertical: 0),
      fillColor: Colors.white,
      filled: true,
      focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(12.0)),
          borderSide: BorderSide(color: MainTheme.mainColor)),
      enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(12.0)),
          borderSide: BorderSide.none),
      border: InputBorder.none,
      hintText: hint,
      hintStyle: body5(gray4),
    );
  }

  static InputDecoration searchText(String hint){
    return InputDecoration(
      suffixIcon: GestureDetector(
        onTap: (){},
        child: const Icon(Icons.search, color: MainTheme.gray3, size: 24,)
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
          borderSide: BorderSide(color: MainTheme.gray2)),
      border: InputBorder.none,
      hintText: hint,
      hintStyle: body6(gray4),
    );
  }

  static TextStyle heading1(Color color){
    return TextStyle(fontWeight: FontWeight.w800, fontFamily: "SUIT", fontSize: 32, height:1.38, color: color, letterSpacing: 0);
  }
  static TextStyle heading2(Color color){
    return TextStyle(fontWeight: FontWeight.w300, fontFamily: "SUIT", fontSize: 32, height:1.38, color: color, letterSpacing: 0);
  }
  static TextStyle heading3(Color color){
    return TextStyle(fontWeight: FontWeight.w700, fontFamily: "SUIT", fontSize: 28, height: 1.4, color: color, letterSpacing: 0);
  }
  static TextStyle heading4(Color color){
    return TextStyle(fontWeight: FontWeight.w600, fontFamily: "SUIT", fontSize: 28, height:1.4, color: color, letterSpacing: 0);
  }
  static TextStyle heading5(Color color){
    return TextStyle(fontWeight: FontWeight.w600, fontFamily: "SUIT", fontSize: 25, height:1.4, color: color, letterSpacing: 0);
  }
  static TextStyle heading6(Color color){
    return TextStyle(fontWeight: FontWeight.w400, fontFamily: "SUIT", fontSize: 24, height: 1.4, color: color, letterSpacing: 0);
  }
  static TextStyle heading7(Color color){
    return TextStyle(fontWeight: FontWeight.w800, fontFamily: "SUIT", fontSize: 20, height:1.4, color: color, letterSpacing: 0);
  }
  static TextStyle heading8(Color color){
    return TextStyle(fontWeight: FontWeight.w600, fontFamily: "SUIT", fontSize: 18, height:1.4, color: color, letterSpacing: 0);
  }

  static TextStyle body1(Color color){
    return TextStyle(fontWeight: FontWeight.w400, fontFamily: "SUIT", fontSize: 20, height:1.4, color: color, letterSpacing: 0);
  }
  static TextStyle body2(Color color){
    return TextStyle(fontWeight: FontWeight.w800, fontFamily: "SUIT", fontSize: 16, height:2.33,color: color, letterSpacing: 0);
  }
  static TextStyle body3(Color color){
    return TextStyle(fontWeight: FontWeight.w400, fontFamily: "SUIT", fontSize: 16, height:2.33,color: color, letterSpacing: 0);
  }
  static TextStyle body4(Color color){
    return TextStyle(fontWeight: FontWeight.w700, fontFamily: "SUIT", fontSize: 15, height:1.486, color: color, letterSpacing: 0);
  }
  static TextStyle body5(Color color){
    return TextStyle(fontWeight: FontWeight.w600, fontFamily: "SUIT", fontSize: 15, height:1.486, color: color, letterSpacing: 0);
  }
  static TextStyle body6(Color color){
    return TextStyle(fontWeight: FontWeight.w500, fontFamily: "SUIT", fontSize: 15, height:1.486, color: color, letterSpacing: 0);
  }
  static TextStyle body8(Color color){
    return TextStyle(fontWeight: FontWeight.w600, fontFamily: "SUIT", fontSize: 14, height:1.486, color: color, letterSpacing: 0);
  }
  static TextStyle body9(Color color){
    return TextStyle(fontWeight: FontWeight.w500, fontFamily: "SUIT", fontSize: 14, height:1.535, color: color, letterSpacing: 0);
  }

  static TextStyle caption1(Color color){
    return TextStyle(fontWeight: FontWeight.w800, fontFamily: "SUIT", fontSize: 13, height:1.446, color: color, letterSpacing: 0);
  }

  static TextStyle caption2(Color color){
    return TextStyle(fontWeight: FontWeight.w600, fontFamily: "SUIT", fontSize: 13, height:1.446, color: color, letterSpacing: 0);
  }
  static TextStyle caption3(Color color){
    return TextStyle(fontWeight: FontWeight.w400, fontFamily: "SUIT", fontSize: 13, height:1.446, color: color, letterSpacing: 0);
  }

  static TextStyle caption4(Color color){
    return TextStyle(fontWeight: FontWeight.w500, fontFamily: "SUIT", fontSize: 12, height:1.375, color: color, letterSpacing: 0);
  }

  static TextStyle caption4Pretendard(Color color){
    return TextStyle(fontWeight: FontWeight.w500, fontFamily: "Pretendard", fontSize: 12, height:1.375, color: color, letterSpacing: 0);
  }

  static TextStyle caption5(Color color){
    return TextStyle(fontWeight: FontWeight.w600, fontFamily: "SUIT", fontSize: 11, height:1.272, color: color, letterSpacing: 0);
  }
  static TextStyle caption6(Color color){
    return TextStyle(fontWeight: FontWeight.w600, fontFamily: "SUIT", fontSize: 10, height:1.4, color: color, letterSpacing: 0);
  }

  static TextStyle helper(Color color){
    return TextStyle(fontWeight: FontWeight.w500, fontFamily: "Pretendard", fontSize: 13, height:1.384, color: color, letterSpacing: 0);
  }


  static BoxDecoration roundBox(Color color){
    return BoxDecoration(
      borderRadius: BorderRadius.circular(12),
      color: color
    );
  }


  static Widget customCheckBox(bool isChecked){
    return SvgPicture.asset(isChecked? "assets/icons/btn_check_on.svg" : "assets/icons/btn_check_off.svg",
      width: 20,
      height: 20,
    );
  }

  static Widget blackCheckBox(bool isChecked){
    return SvgPicture.asset(isChecked? "assets/icons/btn_check_black.svg" : "assets/icons/btn_check_off.svg",
      width: 20,
      height: 20,
    );
  }

  static snackBar (String content){
    return   SnackBar(
      content: Text(content,textAlign: TextAlign.center, style: MainTheme.body8(Colors.white),),
      backgroundColor: Colors.black.withOpacity(0.85), // 스낵바 배경색
      duration: Duration(milliseconds: 3000), // 스낵바 표시되는 시간
      behavior: SnackBarBehavior.floating, // 하단에서 살짝 띄어짐, 기본값: fixed
      shape: RoundedRectangleBorder( // 스낵바 모양
        borderRadius: BorderRadius.circular(9),
      ),
    );
  }

  static toast(String message){
    Fluttertoast.showToast(
        msg: message,
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.black,
        textColor: Colors.white,
        fontSize: 16.0
    );
  }

}


class DashedLineVerticalPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    double dashHeight = 3, dashSpace = 3, startY = 0;
    final paint = Paint()
      ..color = Color(0xffDBE2E8)
      ..strokeWidth = 0.5;
    while (startY < size.height) {
      if((startY + dashHeight) > size.height){
        canvas.drawLine(Offset(0, startY), Offset(0, size.height), paint);
        break;
      }else{
        canvas.drawLine(Offset(0, startY), Offset(0, startY + dashHeight), paint);
        startY += dashHeight + dashSpace;
      }
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

class DashedLineHorizontalPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    double dashHeight = 3, dashSpace = 3, startY = 0;
    final paint = Paint()
      ..color = Color(0xffDBE2E8)
      ..strokeWidth = 0.5;
    while (startY < size.width) {
      if((startY + dashHeight) > size.width){
        canvas.drawLine(Offset(startY, 0), Offset(startY + dashHeight, 0), paint);
        break;
      }else{
        canvas.drawLine(Offset(startY, 0), Offset(startY + dashHeight, 0), paint);
        startY += dashHeight + dashSpace;
      }
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
