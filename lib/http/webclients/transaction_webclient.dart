import 'dart:convert';

import 'package:bytebank/models/transaction.dart';
import 'package:http/http.dart';

import '../webclient.dart';

class TransactionWebclient {
  Future<List<Transaction>> findAll() async {
    final Response response =
        await client.get(url).timeout(Duration(seconds: 5));
    final List decodedJson = jsonDecode(response.body);
    return decodedJson
        .map((dynamic json) => Transaction.fromJson(json))
        .toList();
  }

  Future<Transaction> save(Transaction transaction, String password) async {
    final String transactionJson = jsonEncode(transaction.toJson());
    final Response response = await client.post(
      url,
      headers: {
        'Content-type': 'application/json',
        'password': password,
      },
      body: transactionJson,
    );

    if (response.statusCode == 200) {
      return Transaction.fromJson(jsonDecode(response.body));
    }
    _throwHttpError(response.statusCode);
  }

  void _throwHttpError(int statusCode) => throw Exception(
        _statusCodeResponses[statusCode],
      );

  static final Map<int, String> _statusCodeResponses = {
    400: 'there was an error submiting a transaction',
    401: 'authentication failed'
  };
}
