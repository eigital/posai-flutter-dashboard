import 'dart:async';

import 'package:flutter/material.dart';

import '../constants/login_assets.dart';

/// Full-height image crossfade used on login and sign-up (matches React 65% rail).
class AuthImageSlider extends StatefulWidget {
  const AuthImageSlider({super.key});

  @override
  State<AuthImageSlider> createState() => _AuthImageSliderState();
}

class _AuthImageSliderState extends State<AuthImageSlider> {
  int _index = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 4), (_) {
      if (!mounted) return;
      setState(() {
        _index = (_index + 1) % loginStackAssets.length;
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        for (var i = 0; i < loginStackAssets.length; i++)
          AnimatedOpacity(
            duration: const Duration(milliseconds: 1000),
            curve: Curves.easeInOut,
            opacity: _index == i ? 1 : 0,
            child: DecoratedBox(
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage(loginStackAssets[i]),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
        ColoredBox(
          color: Colors.black.withValues(alpha: 0.1),
        ),
      ],
    );
  }
}
