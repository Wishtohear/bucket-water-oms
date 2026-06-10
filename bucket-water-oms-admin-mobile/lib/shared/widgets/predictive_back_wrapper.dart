import 'package:flutter/material.dart';

class PredictiveBackWrapper extends StatelessWidget {
  final Widget child;

  const PredictiveBackWrapper({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          debugPrint('Pop was prevented');
        }
      },
      child: child,
    );
  }
}
