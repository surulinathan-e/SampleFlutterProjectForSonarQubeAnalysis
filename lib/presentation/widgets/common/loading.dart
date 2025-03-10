import 'package:flutter/material.dart';
import 'package:tasko/utils/assets.dart';

class Loading extends StatefulWidget {
  const Loading({super.key});

  @override
  State<Loading> createState() => _LoadingState();
}

class _LoadingState extends State<Loading> with TickerProviderStateMixin {
  AnimationController? animationController;

  @override
  void initState() {
    super.initState();
    animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    animationController!.repeat();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        alignment: Alignment.center,
        child: RotationTransition(
          turns: animationController!,
          child: Opacity(
            opacity: 0.5,
            child: Image.asset(
              Assets.loader,
              width: 80,
              height: 80,
            ),
          ),
        ));
  }

  @override
  void dispose() {
    animationController!.dispose();
    super.dispose();
  }
}
