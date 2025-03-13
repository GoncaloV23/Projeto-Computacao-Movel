import 'package:flutter/material.dart';

void showSnackbar(
    {required BuildContext context,
    required String message,
    required Color backgroundColor}) {
  hideSnackbar(context);

  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(message),
      backgroundColor: backgroundColor,
    ),
  );
}

void hideSnackbar(BuildContext context) {
  ScaffoldMessenger.of(context).hideCurrentSnackBar();
}
