import 'package:flutter/material.dart';
import 'package:flutter_app/utilities/dialogs/generic_dialog.dart';

Future<bool> showDeletetDialog(BuildContext context) {
  return showGenericDialog<bool>(
    context: context,
    title: 'delete',
    content: 'Are you sure you want to delete?',
    optionsBuilder: () => {'Cancel': false, 'Yes': true},
  ).then((value) => value ?? false);
}
