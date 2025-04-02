import 'package:flutter/material.dart';

class AppColors {
  static const Color imperialRed = Color(0xFFF03A47);
  static const Color redwood = Color(0xFFAF5B5B);
  static const Color whiteSmoke = Color(0xFFF6F4F3);
  static const Color celticBlue = Color(0xFF276FBF);
  static const Color delftBlue = Color(0xFF183059);

  // Gradients
  static const LinearGradient gradientTop = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [imperialRed, redwood, whiteSmoke, celticBlue, delftBlue],
  );

  static const LinearGradient gradientRight = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [imperialRed, redwood, whiteSmoke, celticBlue, delftBlue],
  );

  static const LinearGradient gradientBottom = LinearGradient(
    begin: Alignment.bottomCenter,
    end: Alignment.topCenter,
    colors: [imperialRed, redwood, whiteSmoke, celticBlue, delftBlue],
  );

  static const LinearGradient gradientLeft = LinearGradient(
    begin: Alignment.centerRight,
    end: Alignment.centerLeft,
    colors: [imperialRed, redwood, whiteSmoke, celticBlue, delftBlue],
  );

  static const LinearGradient gradientTopRight = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [imperialRed, redwood, whiteSmoke, celticBlue, delftBlue],
  );

  static const LinearGradient gradientBottomRight = LinearGradient(
    begin: Alignment.bottomLeft,
    end: Alignment.topRight,
    colors: [imperialRed, redwood, whiteSmoke, celticBlue, delftBlue],
  );

  static const LinearGradient gradientTopLeft = LinearGradient(
    begin: Alignment.topRight,
    end: Alignment.bottomLeft,
    colors: [imperialRed, redwood, whiteSmoke, celticBlue, delftBlue],
  );

  static const LinearGradient gradientBottomLeft = LinearGradient(
    begin: Alignment.bottomRight,
    end: Alignment.topLeft,
    colors: [imperialRed, redwood, whiteSmoke, celticBlue, delftBlue],
  );

  static const RadialGradient gradientRadial = RadialGradient(
    colors: [imperialRed, redwood, whiteSmoke, celticBlue, delftBlue],
  );
}
