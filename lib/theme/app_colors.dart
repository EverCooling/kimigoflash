import 'package:flutter/material.dart';

class AppColors {
  static const MaterialColor redGradient = MaterialColor(
    _redPrimaryValue,
    <int, Color>{
      50: Color(0xFFFDECEC),
      100: Color(0xFFFAC8C8),
      200: Color(0xFFF6A4A4),
      300: Color(0xFFF28080),
      400: Color(0xFFEE5C5C),
      500: Color(0xFFE73838),
      600: Color(0xFFD92A2A),
      700: Color(0xFFCB1C1C),
      800: Color(0xFFB71616),
      900: Color(0xFFA31010),
    },
  );
  static const int _redPrimaryValue = 0xFFE73838;

  static const MaterialColor grayGradient = MaterialColor(
    _grayPrimaryValue,
    <int, Color>{
      50: Color(0xFFFAFAFA),
      100: Color(0xFFF5F5F5),
      200: Color(0xFFEEEEEE),
      300: Color(0xFFE0E0E0),
      400: Color(0xFFBDBDBD),
      500: Color(0xFF9E9E9E),
      600: Color(0xFF757575),
      700: Color(0xFF616161),
      800: Color(0xFF424242),
      900: Color(0xFF212121),
    },
  );
  static const int _grayPrimaryValue = 0xFF9E9E9E;

  static const MaterialColor orangeGradient = MaterialColor(
    _orangePrimaryValue,
    <int, Color>{
      50: Color(0xFFFFF3E0),
      100: Color(0xFFFFE0B2),
      200: Color(0xFFFFCC80),
      300: Color(0xFFFFB74D),
      400: Color(0xFFFFA726),
      500: Color(0xFFFB8C00),
      600: Color(0xFFF57C00),
      700: Color(0xFFEF6C00),
      800: Color(0xFFE65100),
      900: Color(0xFFBC3908),
    },
  );
  static const int _orangePrimaryValue = 0xFFFB8C00;

  static const MaterialColor amberGradient = MaterialColor(
    _amberPrimaryValue,
    <int, Color>{
      50: Color(0xFFFFF8E1),
      100: Color(0xFFFFECB3),
      200: Color(0xFFFFE082),
      300: Color(0xFFFFD54F),
      400: Color(0xFFFFCA28),
      500: Color(0xFFFFC107),
      600: Color(0xFFFFB300),
      700: Color(0xFFFFA000),
      800: Color(0xFFFF8F00),
      900: Color(0xFFFF6F00),
    },
  );
  static const int _amberPrimaryValue = 0xFFFFC107;

  //增加黄色
  static const MaterialColor yellowGradient = MaterialColor(
    _yellowPrimaryValue,
    <int, Color>{
      50: Color(0xFFFFFDE0),
      100: Color(0xFFFFF9C4),
      200: Color(0xFFFFF176),
      300: Color(0xFFFFEE58),
      400: Color(0xFFFFEB3B),
      500: Color(0xFFFFEB3B),
      600: Color(0xFFFFEB3B),
      700: Color(0xFFFFEB3B),
      800: Color(0xFFFFEB3B),
      900: Color(0xFFFFEB3B)
    },
  );
  static const int _yellowPrimaryValue = 0xFFFFEB3B;

  //增加绿色
  static const MaterialColor greenGradient = MaterialColor(
    _greenPrimaryValue,
    <int, Color>{
      50: Color(0xFFE8F5E9),
      100: Color(0xFFC8E6C9),
      200: Color(0xFFA5D6A7),
      300: Color(0xFF81C784),
      400: Color(0xFF66BB6A),
      500: Color(0xFF4CAF50),
      600: Color(0xFF43A047),
      700: Color(0xFF388E3C),
      800: Color(0xFF2E7D32),
      900: Color(0xFF1B5E20),
    },
  );
  static const int _greenPrimaryValue = 0xFF4CAF50;
  
}
