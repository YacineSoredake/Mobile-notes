import 'package:flutter/material.dart';
import 'package:flutter_app/utilities/dialogs/generic_dialog.dart';

Future<void> cannotShareEmptyNoteDialog(BuildContext context) {
  return showGenericDialog<void>(
    context: context,
    title: "Warning",
    content: "You can't share empty note",
    optionsBuilder: () => {"ok": null},
  );
}
