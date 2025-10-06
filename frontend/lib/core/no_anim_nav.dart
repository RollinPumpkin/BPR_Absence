import 'package:flutter/material.dart';

extension NoAnimNav on BuildContext {
  Future<T?> pushNoAnim<T>(Widget page) {
    return Navigator.of(this).push<T>(
      PageRouteBuilder(pageBuilder: (_, __, ___) => page, transitionDuration: Duration.zero, reverseTransitionDuration: Duration.zero),
    );
  }

  Future<T?> replaceNoAnim<T, TO>(Widget page) {
    return Navigator.of(this).pushReplacement<T, TO>(
      PageRouteBuilder(pageBuilder: (_, __, ___) => page, transitionDuration: Duration.zero, reverseTransitionDuration: Duration.zero),
    );
  }
}
