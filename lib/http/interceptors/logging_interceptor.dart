import 'package:flutter/material.dart';
import 'package:http_interceptor/http/interceptor_contract.dart';
import 'package:http_interceptor/http_interceptor.dart';

class LoggingInterceptor implements InterceptorContract {
  @override
  Future<RequestData> interceptRequest({@required RequestData data}) async {
    // print(data.toString());
    return data;
  }

  @override
  Future<ResponseData> interceptResponse({@required ResponseData data}) async {
    // print(data.toString());
    return data;
  }
}