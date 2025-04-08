import 'package:flutter/material.dart';

/// A utility class for building consistent UI components and theme across the app.
class AppUI {
  /// Builds a customizable [AppBar] with optional [actions] and [bottom] widget.
  ///
  /// - [title]: The title text shown in the AppBar.
  /// - [actions]: Optional list of widgets displayed at the end of the AppBar.
  /// - [bottom]: Optional widget displayed at the bottom of the AppBar (e.g., TabBar).
  static AppBar buildAppBar({
    required String title,
    List<Widget>? actions,
    PreferredSizeWidget? bottom,
  }) {
    return AppBar(
      title: Text(title),
      centerTitle: false,
      actions: actions,
      bottom: bottom,
    );
  }

  /// Builds a styled [ElevatedButton] with default padding and size.
  ///
  /// - [label]: The text displayed inside the button.
  /// - [onPressed]: The callback triggered when the button is pressed.
  static Widget buildButton({
    required String label,
    required VoidCallback onPressed,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          minimumSize: const Size(200, 48),
        ),
        child: Text(label),
      ),
    );
  }

  /// Builds a styled [OutlinedButton] with default padding and size.
  ///
  /// - [label]: The text displayed inside the button.
  /// - [onPressed]: The callback triggered when the button is pressed.
  static Widget buildOutlinedButton({
    required String label,
    required VoidCallback onPressed,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(200, 48),
        ),
        child: Text(label),
      ),
    );
  }

  /// Returns a [ThemeData] object that defines the app's overall appearance.
  ///
  /// This includes default colors, button styles, text styles, etc.
  static ThemeData theme() {
    return ThemeData(
      primarySwatch: Colors.blue,
      scaffoldBackgroundColor: const Color(0xFFFCF7FD),
      textTheme: const TextTheme(
        bodyMedium: TextStyle(color: Colors.black87, fontSize: 16),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        elevation: 2,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blue,
          foregroundColor: Colors.white,
          textStyle: const TextStyle(fontSize: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(24)),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: Colors.blue,
          textStyle: const TextStyle(fontSize: 16),
          side: const BorderSide(color: Colors.blue),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(24)),
          ),
        ),
      ),
    );
  }
}



