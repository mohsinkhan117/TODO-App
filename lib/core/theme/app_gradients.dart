//lib\core\theme\app_gradients.dart

import 'package:flutter/material.dart';

class AppGradients {
  static final Map<String, Gradient> gradients = {
    "sunsetGlow": const LinearGradient(
      colors: [Color(0xFFfc6076), Color(0xFFff9a44)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    "aquaSplash": const LinearGradient(
      colors: [Color(0xFF13547a), Color(0xFF80d0c7)],
      begin: Alignment.topRight,
      end: Alignment.bottomLeft,
    ),
    "cosmicFusion": const LinearGradient(
      colors: [Color(0xFFff00cc), Color(0xFF333399)],
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
    ),
    "mintyFresh": const LinearGradient(
      colors: [Color(0xFF00c6fb), Color(0xFF005bea)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    // "tropicalBeach": const LinearGradient(
    //   colors: [Color(0xFFfddb92), Color(0xFFd1fdff)],
    //   begin: Alignment.topLeft,
    //   end: Alignment.bottomRight,
    // ),
    "neonDream": const LinearGradient(
      colors: [Color(0xFFff6a00), Color(0xFFee0979)],
      begin: Alignment.bottomLeft,
      end: Alignment.topRight,
    ),
    "cyberSky": const LinearGradient(
      colors: [Color(0xFF00d2ff), Color(0xFF3a7bd5)],
      begin: Alignment.centerLeft,
      end: Alignment.centerRight,
    ),
    "lavenderBliss": const LinearGradient(
      colors: [Color(0xFFfbc2eb), Color(0xFFa6c1ee)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    "emeraldWave": const LinearGradient(
      colors: [Color(0xFF11998e), Color(0xFF38ef7d)],
      begin: Alignment.topRight,
      end: Alignment.bottomLeft,
    ),
    "volcanoBurst": const LinearGradient(
      colors: [Color(0xFFfc6076), Color(0xFFff9a44), Color(0xFFef9d43)],
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
    ),
  };
}
