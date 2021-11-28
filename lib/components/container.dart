import 'package:flutter/material.dart';

abstract class BlocContainer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      
    );
  }
}

void push(BuildContext blocContext, BlocContainer container) {
   Navigator.of(blocContext).push(
      MaterialPageRoute(
        builder: (context) => container,
      ),
    );
}