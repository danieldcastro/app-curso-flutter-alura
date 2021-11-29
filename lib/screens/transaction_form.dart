import 'dart:async';

import 'package:alura_crashlytics/components/container.dart';
import 'package:alura_crashlytics/components/error.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../components/progress.dart';
import '../components/transaction_auth_dialog.dart';
import '../http/webclients/transaction_webclient.dart';
import '../models/contact.dart';
import '../models/transaction.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

@immutable
abstract class TransactionFormState {
  const TransactionFormState();
}

@immutable
class ShowTransactionFormState extends TransactionFormState {
  const ShowTransactionFormState();
}

@immutable
class SendingTransactionFormState extends TransactionFormState {
  const SendingTransactionFormState();
}

class SentTransactionFormState extends TransactionFormState {
  const SentTransactionFormState();
}

@immutable
class FatalErrorTransactionFormState extends TransactionFormState {
  final String message;
  const FatalErrorTransactionFormState(this.message);
}

class TransactionFormCubit extends Cubit<TransactionFormState> {
  TransactionFormCubit() : super(ShowTransactionFormState());

  void save(Transaction transactionCreated, String password,
      BuildContext context) async {
    emit(SendingTransactionFormState());
    await _send(
      transactionCreated,
      password,
      context,
    );
  }

  _send(Transaction transactionCreated, String password,
      BuildContext context) async {
    await TransactionWebClient()
        .save(transactionCreated, password)
        .then((transaction) => emit(SentTransactionFormState()))
        .catchError((e) {
      emit(FatalErrorTransactionFormState(e.message));

      if (FirebaseCrashlytics.instance.isCrashlyticsCollectionEnabled) {
        FirebaseCrashlytics.instance.setCustomKey('exception', e.toString());
        FirebaseCrashlytics.instance
            .setCustomKey('http_body', transactionCreated.toString());
        FirebaseCrashlytics.instance.recordError(e.message, null);
      }
    }, test: (e) => e is HttpException).catchError((e) {
      emit(
          FatalErrorTransactionFormState('timeout submitting the transaction'));

      if (FirebaseCrashlytics.instance.isCrashlyticsCollectionEnabled) {
        FirebaseCrashlytics.instance.setCustomKey('exception', e.toString());
        FirebaseCrashlytics.instance
            .setCustomKey('http_body', transactionCreated.toString());
        FirebaseCrashlytics.instance.recordError(e.message, null);
      }
      // _showFailureMessage(context,
    }, test: (e) => e is TimeoutException).catchError((e) {
      emit(FatalErrorTransactionFormState(e.message));

      if (FirebaseCrashlytics.instance.isCrashlyticsCollectionEnabled) {
        FirebaseCrashlytics.instance.setCustomKey('exception', e.toString());
        FirebaseCrashlytics.instance
            .setCustomKey('http_body', transactionCreated.toString());
        FirebaseCrashlytics.instance.recordError(e.message, null);
      }
      // _showFailureMessage(context);
    });
  }
}

class TransactionFormContainer extends BlocContainer {
  final Contact _contact;
  TransactionFormContainer(this._contact);

  @override
  Widget build(BuildContext context) {
    return BlocProvider<TransactionFormCubit>(
      create: (context) => TransactionFormCubit(),
      child: BlocListener<TransactionFormCubit, TransactionFormState>(
        listener: (context, state) {
          if (state is SentTransactionFormState) {
            Navigator.pop(context);
          }
        },
        child: TransactionFormView(_contact),
      ),
    );
  }
}

class TransactionFormView extends StatelessWidget {
  final Contact _contact;
  TransactionFormView(this._contact);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TransactionFormCubit, TransactionFormState>(
      builder: (context, state) {
        if (state is ShowTransactionFormState) {
          return _BasicForm(_contact);
        }
        if (state is SendingTransactionFormState ||
            state is SentTransactionFormState) {
          return ProgressView();
        }
        if (state is FatalErrorTransactionFormState) {
          return ErrorView(
            message: state.message,
          );
        }
        return ErrorView();
      },
    );
  }
}

class _BasicForm extends StatelessWidget {
  final Contact _contact;
  _BasicForm(this._contact);
  final String transactionId = Uuid().v4();
  final TextEditingController _valueController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('New transaction'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                _contact.name,
                style: TextStyle(
                  fontSize: 24.0,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 16.0),
                child: Text(
                  _contact.accountNumber.toString(),
                  style: TextStyle(
                    fontSize: 32.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 16.0),
                child: TextField(
                  controller: _valueController,
                  style: TextStyle(fontSize: 24.0),
                  decoration: InputDecoration(labelText: 'Value'),
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 16.0),
                child: SizedBox(
                  width: double.maxFinite,
                  child: ElevatedButton(
                    child: Text('Transfer'),
                    onPressed: () {
                      final double value =
                          double.tryParse(_valueController.text);
                      final transactionCreated = Transaction(
                        transactionId,
                        value,
                        _contact,
                      );
                      showDialog(
                          context: context,
                          builder: (contextDialog) {
                            return TransactionAuthDialog(
                              onConfirm: (String password) {
                                BlocProvider.of<TransactionFormCubit>(context)
                                    .save(
                                        transactionCreated, password, context);
                              },
                            );
                          });
                    },
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
