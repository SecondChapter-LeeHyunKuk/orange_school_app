import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:loading_indicator/loading_indicator.dart';

import 'main-theme.dart';

class AcademyField extends StatefulWidget {
  @override
  _AcademyField createState() => _AcademyField();
}

class _AcademyField extends State<AcademyField> {
  late TextEditingController te_Academy;
  late FocusNode _searchFocusNode;
  OverlayEntry? _overlayEntry;
  final LayerLink _layerLink = LayerLink();


  // 드롭박스 해제.
  void _removeSearchOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    te_Academy = TextEditingController();
    _searchFocusNode = FocusNode()
      ..addListener(() {
        if (!_searchFocusNode.hasFocus) {
          _removeSearchOverlay();
        }
      });
  }

  @override
  void dispose() {
    te_Academy.dispose();
    _overlayEntry?.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    return _searchTextField();
  }

  // 이메일 입력창.
  Widget _searchTextField() {
    // 테두리 스타일.
    final _border = OutlineInputBorder(
      borderSide: BorderSide(
        color: (_searchFocusNode.hasFocus) ? Colors.black : Colors.grey,
      ),
      borderRadius: BorderRadius.circular(5),
    );

    // 이메일 자동 입력 드롭박스 출력.
    void _showsearchOverlay() {
      // 이메일 자동 입력 드롭박스.
      if (_searchFocusNode.hasFocus) {
        if (te_Academy.text.isNotEmpty) {
          final _search = te_Academy.text;

          // 이메일 자동 입력 드롭박스 출력.
          if (!_search.contains('@')) {
            if (_overlayEntry == null) {
              _overlayEntry = _searchListOverlayEntry();
              Overlay.of(context)?.insert(_overlayEntry!);
            }
          }

          // 이메일 자동 입력 드롭박스 해제.
          else {
            _removeSearchOverlay();
          }
        } else {
          _removeSearchOverlay();
        }
      }
    }

    return CompositedTransformTarget(
      link: _layerLink,
      child: Container(
        height: 51,
        child: TextField(
          controller: te_Academy,
          focusNode: _searchFocusNode,
          textInputAction: TextInputAction.next,
          textAlignVertical: TextAlignVertical.center,
          style: MainTheme.body5(MainTheme.gray7),
          onChanged: (_) => _showsearchOverlay(),
          decoration : InputDecoration(
            suffixIcon: GestureDetector(
                onTap: (){},
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
            hintText: "학원 검색",
            hintStyle: MainTheme.body6(MainTheme.gray4),
          ),
        ),
      ),
    );
  }

  // 학원 찾기
  OverlayEntry _searchListOverlayEntry() {
    ScrollController _scrollController= ScrollController();
    return OverlayEntry(
      maintainState: true,
      builder: (context) => Positioned(
        width: MediaQuery.of(context).size.width - 64,
        height: 259,
        child: CompositedTransformFollower(
            link: _layerLink,
            showWhenUnlinked: false,
            offset: const Offset(0, 59),
            child: Container(
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(6),
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.15),
                    spreadRadius: 0,
                    blurRadius: 8,
                    offset: Offset(0, 0), // changes position of shadow
                  ),
                ],
              ),
              child: Column(
                children: [
                  Container(
                    width: double.infinity,
                    height: 84,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.only(topLeft: Radius.circular(6), topRight: Radius.circular(6)),
                      color: MainTheme.mainColor.withOpacity(0.1),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(width: 20,),
                            Container(
                              margin:EdgeInsets.only(top: 27),
                              child: SvgPicture.asset('assets/icons/info.svg', width: 20, height: 20),
                            ),

                            SizedBox(width: 9,),
                            Container(
                              margin:EdgeInsets.only(top: 22),
                              child: Material(color: Colors.transparent, child: Text("찾으시는 학원이\n없으신가요?", style: MainTheme.body4(MainTheme.gray7),))
                            )

                          ],
                        ),
                        Container(
                          margin:const EdgeInsets.only(right: 20, top: 24),
                          width: 88,
                          height: 35,
                          child: ElevatedButton(
                            style: MainTheme.miniButton(MainTheme.mainColor),
                            onPressed: (){},
                            child: Text(
                              "직접 추가", style: MainTheme.caption1(Colors.white),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(child:
                      Container(
                        margin: EdgeInsets.only(right: 14),
                        child: RawScrollbar(
                          radius: Radius.circular(20),
                          thickness: 4,
                          thumbColor: MainTheme.gray3,

                          controller: _scrollController,//여기도 전달
                          child: ListView.builder(
                              padding: EdgeInsets.only(top: 8, right: 7),
                              controller: _scrollController,//여기도 전달
                              itemCount: 10,
                              itemBuilder: (context, index) => Container(
                                margin: EdgeInsets.only(left: 14,right: 12),
                                height: 68,
                                padding: EdgeInsets.fromLTRB(6,11,6,11),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Material(color: Colors.transparent, child: Text("학원명", style: MainTheme.body4(MainTheme.gray7),overflow: TextOverflow.ellipsis,)),
                                    Material(color: Colors.transparent, child: Text("주소주소주소주소주소주소주소주소주소주소주소주소주소주소주소주소주소주소", style: MainTheme.caption2(MainTheme.gray5),overflow: TextOverflow.ellipsis,))
                                  ],
                                ),

                              )
                          ),
                        ),
                      )

                  )
                ],
              ),
            )
        ),
      ),
    );
  }


}

