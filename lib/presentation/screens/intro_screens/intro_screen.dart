import 'package:flutter/material.dart';
import 'package:tasko/data/classes/language_constant.dart';
import 'package:tasko/presentation/routes/pages_name.dart';
import 'package:tasko/presentation/screens/screens.dart';
import 'package:tasko/presentation/widgets/widgets.dart';
import 'package:tasko/utils/utils.dart';

class IntroScreen extends StatefulWidget {
  const IntroScreen({super.key});

  @override
  State<IntroScreen> createState() => _IntroScreenState();
}

class _IntroScreenState extends State<IntroScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onNextPressed() {
    if (_currentPage < 2) {
      _pageController.nextPage(
          duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
    } else {
      Navigator.pushNamed(context, PageName.loginEntryScreen);
    }
  }

  Widget _buildDot(int index) {
  return Container(
    margin: const EdgeInsets.symmetric(horizontal: 9.0),
    width: _currentPage == index ? 8.0 : 6.0,
    height: _currentPage == index ? 8.0 : 6.0,
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      color: _currentPage == index ? primaryColor : progressGrey,
    ),
  );
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: bgColor,
        body: Stack(children: [
          Padding(padding: const EdgeInsets.only(top: 60.0), child: bgLogin()),
          PageView(
            controller: _pageController,
            onPageChanged: (index) {
              setState(() {
                _currentPage = index;
              });
            },
            children: const [
              FirstIntroScreen(),
              SecondIntroScreen(),
              ThirdIntroScreen(),
            ],
          ),
          Positioned(
              bottom: 105,
              left: 0,
              right: 0,
              child: Center(
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children:
                          List.generate(3, (index) => _buildDot(index))))),
          Positioned(
              bottom: 40,
              left: 30,
              child: TextButton(
                  onPressed: () {
                    Navigator.pushNamed(context, PageName.loginEntryScreen);
                  },
                  child: Text(translation(context).skip,
                      style: const TextStyle(color: lightTextColor, fontSize: 16)))),
          Positioned(
              bottom: 40,
              right: 30,
              child: CircleAvatar(
                  backgroundColor: primaryColor,
                  radius: 23,
                  child: IconButton(
                      icon: const Icon(Icons.arrow_forward_ios, color: white),
                      onPressed: _onNextPressed)))
        ]));
  }
}