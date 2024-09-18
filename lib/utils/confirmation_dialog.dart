import 'package:flutter/material.dart';

class ConfirmationDialog {
  static Future<bool> show({
    required BuildContext context,
    required String title,
    required String content,
    String confirmText = 'Ja',
    String cancelText = 'Nein',
    Color confirmTextColor = Colors.white,
    Color cancelTextColor = Colors.white,
  }) {
    return showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(content),
          actions: <Widget>[
            TextButton(
              child: Text(cancelText, style: TextStyle(color: cancelTextColor)),
              onPressed: () => Navigator.of(context).pop(false),
            ),
            TextButton(
              child:
                  Text(confirmText, style: TextStyle(color: confirmTextColor)),
              onPressed: () => Navigator.of(context).pop(true),
            ),
          ],
        );
      },
    ).then((value) => value ?? false);
  }
}
