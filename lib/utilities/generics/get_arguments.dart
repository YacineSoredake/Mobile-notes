import 'package:flutter/material.dart' show BuildContext,ModalRoute;

extension GetArguments on BuildContext {

  T? getArguments<T>() {
    final args = ModalRoute.of(this)?.settings.arguments;
    if (args !=null && args is T) {
      return args as T;
    }
    return null;
  }
}