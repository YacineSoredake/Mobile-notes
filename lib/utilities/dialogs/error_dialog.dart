import 'package:flutter/material.dart';
import 'package:flutter_app/utilities/dialogs/generic_dialog.dart';

Future<void> showErrorDialog(
  BuildContext context, 
   String text,
) {
  return showGenericDialog<void>(
    context: context,
    title: 'An error occurred',
    content: text,
    optionsBuilder: () => {
      'OK': null,
    },
  );
}