import 'package:flutter/material.dart';

final bytebankTheme = ThemeData(
  primaryColor: Colors.green[900],
  buttonTheme: ButtonThemeData(
    buttonColor: Color.fromRGBO(71, 161, 56, 1),
    textTheme: ButtonTextTheme.primary,
  ),
  colorScheme: ColorScheme.fromSwatch()
      .copyWith(secondary: Color.fromRGBO(71, 161, 56, 1)),
);
