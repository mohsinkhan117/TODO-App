import 'package:flutter/material.dart';

Future dialogueBox({
  required BuildContext context,
  required void Function()? onDelete,
  // String? title,
  String? content,
}) {
  return showDialog(
    context: context,
    builder: (context) => AlertDialog(
      icon: Icon(Icons.warning_amber_rounded, color: Colors.amber, size: 50),
      // title: Text(title ?? 'Are you Sure!'),
      content: Text(
        content ?? 'THIS ACTION CANNOT BE UNDONE',
        style: TextStyle(fontWeight: FontWeight.w500, fontSize: 18.0),
        textAlign: TextAlign.center,
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: Text('CANCEL'),
        ),
        TextButton(
          onPressed: onDelete,
          child: Text('DELETE', style: TextStyle(color: Colors.red)),
        ),
      ],
    ),
  );
}
