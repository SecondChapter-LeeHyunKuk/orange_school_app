import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:orange_school/style/main-theme.dart';
import 'package:flutter/foundation.dart' as foundation;
import 'package:super_tooltip/super_tooltip.dart';
class Chart extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _Chart();
}

class _Chart extends State<Chart> {
  final _controller = SuperTooltipController();
  void _willPopCallback(bool boll) async {
    // If the tooltip is open we don't pop the page on a backbutton press
    // but close the ToolTip
    if (_controller.isVisible) {
      await _controller.hideTooltip();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body :
        Column(
          children: [
            SizedBox(height: 300,),
            PopScope(
              onPopInvoked: _willPopCallback,
              child: GestureDetector(
                onTap: () async {
                  await _controller.showTooltip();
                },
                child: SuperTooltip(
                  showBarrier: true,
                  controller: _controller,
                  backgroundColor: Colors.white,
                  left: 120,
                  arrowTipDistance: 15.0,
                  arrowBaseWidth: 13.0,
                  arrowLength: 13.0,
                  borderWidth: 1.5,
                  borderColor: MainTheme.mainColor,
                  borderRadius: 2,
                  shadowColor: Colors.black.withOpacity(0.1),
                  shadowSpreadRadius: 0,
                  shadowBlurRadius: 8,
                  popupDirection: TooltipDirection.right,
                  constraints: const BoxConstraints(
                    minHeight: 73,
                    minWidth: 140,
                  ),
                  showCloseButton: ShowCloseButton.none,
                  touchThroughAreaShape: ClipAreaShape.rectangle,
                  touchThroughAreaCornerRadius: 30,
                  barrierColor: Colors.transparent,
                  content: Container(
                    width: 300,
                    height: 200,
                    color: Colors.red,
                  ),
                  child: Container(
                    width: 100,
                    height: 200
                    ,
                    decoration: const BoxDecoration(
                      color: Colors.blue,
                    ),
                    child: Icon(
                      Icons.add,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            )
          ],
        )

    );
  }

  void makeTooltip() {
    _controller.showTooltip();
  }
}
