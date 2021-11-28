import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class NameCubit extends Cubit<String> {
  NameCubit(String name) : super(name);

  void change(String name) => emit(name);
}

class NameContainer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return NameView();
  }
}

class NameView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final TextEditingController _nameController = TextEditingController();
    _nameController.text = context.read<NameCubit>().state;
    return Scaffold(
        appBar: AppBar(
          title: const Text('Change name'),
        ),
        body: Column(
          children: [
            TextField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'Desired Name',
                ),
                style: TextStyle(fontSize: 24)),
            Padding(
              padding: EdgeInsets.only(top: 16),
              child: SizedBox(
                width: double.maxFinite,
                child: ElevatedButton(
                  child: Text('Change'),
                  onPressed: () {
                    final name = _nameController.text;
                    context.read<NameCubit>().change(name);
                    Navigator.pop(context);
                  },
                ),
              ),
            )
          ],
        ));
  }
}
