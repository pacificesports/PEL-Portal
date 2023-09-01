// ignore_for_file: non_constant_identifier_names

import 'package:flutter/material.dart';

Color PEL_MAIN = PEL_PURPLE;

Color PEL_BLUE = const Color(0xFF087CFF);
Color PEL_PURPLE = const Color(0xFF6F4ACB);
Color PEL_GREY = const Color(0xFF121212);

// LIGHT THEME
const lightBackgroundColor = Color(0xFFf9f9f9);
const lightCardColor = Colors.white;
const lightDividerColor = Color(0xFFA8A8A8);

// Dark theme
const darkBackgroundColor = Color(0xFF100F1D);
const darkCanvasColor = Color(0xFF090910);
const darkCardColor = Color(0xFF090910);
const darkDividerColor = Color(0xFF545454);

/// Light style
final ThemeData lightTheme = ThemeData(
  brightness: Brightness.light,
  colorScheme: const ColorScheme.light().copyWith(
    primary: PEL_MAIN,
    secondary: PEL_MAIN,
    onSecondary: Colors.white,
    background: lightBackgroundColor,
  ),
  fontFamily: "Helvetica",
  primaryColor: PEL_MAIN,
  scaffoldBackgroundColor: lightBackgroundColor,
  cardColor: lightCardColor,
  cardTheme: CardTheme(
    color: lightCardColor,
    elevation: 0,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
  ),
  listTileTheme: ListTileThemeData(
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
  ),
  buttonTheme: ButtonThemeData(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))
  ),
  dividerColor: lightDividerColor,
  dialogBackgroundColor: lightCardColor,
  // textTheme: GoogleFonts.openSansTextTheme(ThemeData.light().textTheme),
  popupMenuTheme: PopupMenuThemeData(
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(8),
    ),
  ),
);

/// Dark style
final ThemeData darkTheme = ThemeData(
  useMaterial3: true,
  brightness: Brightness.dark,
  colorScheme: const ColorScheme.dark().copyWith(
    primary: PEL_MAIN,
    secondary: PEL_MAIN,
    background: darkBackgroundColor,
  ),
  fontFamily: "Helvetica",
  primaryColor: PEL_MAIN,
  canvasColor: darkCanvasColor,
  scaffoldBackgroundColor: darkBackgroundColor,
  cardColor: darkCardColor,
  cardTheme: CardTheme(
    color: darkCardColor,
    elevation: 0,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
  ),
  listTileTheme: ListTileThemeData(
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
  ),
  buttonTheme: ButtonThemeData(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))
  ),
  dividerColor: darkDividerColor,
  dialogBackgroundColor: darkCardColor,
  // textTheme: GoogleFonts.openSansTextTheme(ThemeData.dark().textTheme),
  popupMenuTheme: PopupMenuThemeData(
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(6),
    ),
  ),
);