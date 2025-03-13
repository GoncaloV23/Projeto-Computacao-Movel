import 'package:flutter/material.dart';

void show(BuildContext context, String title, String message, String text1,
    Function opt1, String text2, Function opt2) {
  showDialog<AlertDialog>(
    context: context,
    builder: (_) => AlertDialog(
      title: Text(title),
      content: Text(message),
      actions: [
        TextButton(
          onPressed: () => opt1,
          child: Text(
            text1,
            style: TextStyle(color: Colors.blue),
          ),
        ),
        TextButton(
          onPressed: () => opt2,
          child: Text(
            text2,
            style: TextStyle(color: Colors.blue),
          ),
        ),
      ],
    ),
  );
}
