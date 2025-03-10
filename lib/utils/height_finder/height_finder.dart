import 'package:flutter/material.dart';

class HeightFinder {
  BuildContext cntxt;
  late double scrHt;
  late double kbrdHt;
  HeightFinder(this.cntxt) {
    scrHt = MediaQuery.of(cntxt).size.height;
    kbrdHt = MediaQuery.of(cntxt).viewInsets.bottom;
  }
}


    // orginal core code //
    // final double screenHeight = MediaQuery.of(context).size.height;
    // final double keyboardHeight = MediaQuery.of(context).viewInsets.bottom;

    // set in scaffold to avoid bottom padding //
    // resizeToAvoidBottomInset: false,

    // paste below of stateless or statefull widget //
    // final double screenHeight = HeightFinder(context).scrHt;
    // final double keyboardHeight = HeightFinder(context).kbrdHt;
    
    // use this in root widgets //
    // SizedBox(height: screenHeight - keyboardHeight, child: _buildBodyContentWidget(),),