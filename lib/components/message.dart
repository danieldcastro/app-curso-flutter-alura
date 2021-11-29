import 'package:alura_crashlytics/components/response_dialog.dart';
import 'package:alura_crashlytics/models/transaction.dart';
import 'package:flutter/material.dart';
import 'package:giffy_dialog/giffy_dialog.dart';


class MessageView {

showFailureMessage(
    BuildContext context, {
    String message = 'Unknown error',
  }) async {
   await showDialog(
      context: context,
      builder: (contextDialog) => NetworkGiffyDialog(
        image: Image.asset(
          'images/error.gif',
        ),
        title: Text(
          'OPS',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
        ),
        description: Text(
          message,
          textAlign: TextAlign.center,
        ),
        entryAnimation: EntryAnimation.TOP,
        onOkButtonPressed: () => Navigator.pop(context),
      ),
    );
  }

    Future showSuccessfulMessage(
      Transaction transaction, BuildContext context) async {
    if (transaction != null) {
      await showDialog(
          context: context,
          builder: (contextDialog) {
            return SuccessDialog('successful transaction');
          });
      Navigator.pop(context);
    }
  }
}

