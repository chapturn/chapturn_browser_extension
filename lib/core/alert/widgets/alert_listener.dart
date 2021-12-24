import 'package:chapturn_browser_extension/core/alert/notifiers/alert_notifier.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AlertListener extends StatelessWidget {
  const AlertListener({Key? key, required this.child}) : super(key: key);

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Selector<AlertNotifier, Alert?>(
      builder: (context, value, child) {
        if (value != null) {
          WidgetsBinding.instance?.addPostFrameCallback((_) {
            _handleError(context, value);
          });
        }

        return child!;
      },
      selector: (context, notifier) => notifier.alert,
      child: child,
    );
  }

  void _handleError(BuildContext context, Alert alert) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(alert.message),
          behavior: SnackBarBehavior.floating,
          width: 400,
        ),
      );
  }
}
