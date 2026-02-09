import 'package:flutter/material.dart';

// Official Tokyonight color palette
const Color tokyoNightBlack = Color(0xFF1a1b26); // Storm
const Color tokyoNightBlue = Color(0xFF7aa2f7);  // Blue
const Color tokyoNightCyan = Color(0xFF7dcfff);  // Cyan
const Color tokyoNightGreen = Color(0xFF9ece6a); // Green
const Color tokyoNightMagenta = Color(0xFFbb9af7); // Magenta
const Color tokyoNightRed = Color(0xFFf7768e);    // Red
const Color tokyoNightYellow = Color(0xFFe0af68); // Yellow
const Color tokyoNightWhite = Color(0xFFa9b1d6);  // FG
const Color tokyoNightGrey = Color(0xFF414868);  // Gutter Grey

// ThemeData definition
final ThemeData tokyoNightTheme = ThemeData(
  useMaterial3: true,
  brightness: Brightness.dark,
  primaryColor: tokyoNightBlue,
  scaffoldBackgroundColor: tokyoNightBlack,

  // Define the default color scheme
  colorScheme: const ColorScheme.dark(
    primary: tokyoNightBlue,
    secondary: tokyoNightMagenta,
    background: tokyoNightBlack,
    surface: tokyoNightGrey,
    onPrimary: tokyoNightBlack,
    onSecondary: tokyoNightBlack,
    onBackground: tokyoNightWhite,
    onSurface: tokyoNightWhite,
    error: tokyoNightRed,
    onError: tokyoNightBlack,
  ),

  // Define the default TextTheme
  textTheme: const TextTheme(
    bodyLarge: TextStyle(color: tokyoNightWhite),
    bodyMedium: TextStyle(color: tokyoNightWhite),
    titleLarge: TextStyle(color: tokyoNightWhite, fontWeight: FontWeight.bold),
  ),

  // Define the default AppBarTheme
  appBarTheme: const AppBarTheme(
    backgroundColor: tokyoNightGrey,
    foregroundColor: tokyoNightWhite, // For title and icons
  ),

  // Define other widget themes as needed
  floatingActionButtonTheme: const FloatingActionButtonThemeData(
    backgroundColor: tokyoNightBlue,
    foregroundColor: tokyoNightBlack,
  ),

  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: tokyoNightGrey,
    hintStyle: TextStyle(color: tokyoNightWhite.withOpacity(0.6)),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8.0),
      borderSide: BorderSide.none,
    ),
    focusedBorder: const OutlineInputBorder(
      borderSide: BorderSide(color: tokyoNightBlue),
    ),
  ),
);
