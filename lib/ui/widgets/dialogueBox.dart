import 'package:flutter/material.dart';

Future<void> dialogueBox({
  required BuildContext context,
  required Future<void> Function()?
  onDelete, // Change to Future<void> Function()
  String? content,
  bool shouldPopAfterDelete = true,
}) {
  bool isLoading = false;

  return showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) => StatefulBuilder(
      builder: (context, setState) {
        return AlertDialog(
          icon: isLoading
              ? CircularProgressIndicator()
              : Icon(
                  Icons.warning_amber_rounded,
                  color: Colors.amber,
                  size: 50,
                ),
          content: isLoading
              ? Text('Deleting...', textAlign: TextAlign.center)
              : Text(
                  content ?? 'THIS ACTION CANNOT BE UNDONE',
                  style: TextStyle(fontWeight: FontWeight.w500, fontSize: 18.0),
                  textAlign: TextAlign.center,
                ),
          actions: isLoading
              ? [] // No buttons while loading
              : [
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: Text('CANCEL'),
                  ),
                  TextButton(
                    onPressed: () async {
                      setState(() => isLoading = true);

                      try {
                        if (onDelete != null) {
                          await onDelete(); // FIX: Add parentheses to call the function
                        }

                        // Close the dialog after successful delete
                        if (shouldPopAfterDelete) {
                          Navigator.pop(context);
                        }

                        // Optional: Show success message
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Deleted successfully'),
                            backgroundColor: Colors.green,
                          ),
                        );
                      } catch (e) {
                        // Show error and keep dialog open
                        setState(() => isLoading = false);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Error deleting: $e'),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    },
                    child: Text('DELETE', style: TextStyle(color: Colors.red)),
                  ),
                ],
        );
      },
    ),
  );
}
