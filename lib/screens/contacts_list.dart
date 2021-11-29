import 'package:flutter_bloc/flutter_bloc.dart';

import '../components/container.dart';
import '../components/progress.dart';
import '../database/dao/contact_dao.dart';
import '../models/contact.dart';
import 'contact_form.dart';
import 'transaction_form.dart';
import 'package:flutter/material.dart';

@immutable
abstract class ContactsListState {
  const ContactsListState();
}

@immutable
class InitContactsListState extends ContactsListState {
  const InitContactsListState();
}

@immutable
class LoadingContactsListState extends ContactsListState {
  const LoadingContactsListState();
}

class LoadedContactsListState extends ContactsListState {
  final List<Contact> _contacts;
  const LoadedContactsListState(this._contacts);
}

@immutable
class FatalErrorContactsListState extends ContactsListState {
  const FatalErrorContactsListState();
}

class ContactsListCubit extends Cubit<ContactsListState> {
  ContactsListCubit() : super(InitContactsListState());

  void reload(ContactDao dao) async {
    emit(LoadingContactsListState());
    dao.findAll().then(
          (contacts) => emit(
            LoadedContactsListState(contacts),
          ),
        );
  }
}

class ContactsListContainer extends BlocContainer {
  @override
  Widget build(BuildContext context) {
    final ContactDao dao = ContactDao();
    return BlocProvider<ContactsListCubit>(
      create: (BuildContext context) {
        final cubit = ContactsListCubit();
        cubit.reload(dao);
        return cubit;
      },
      child: ContactsListView(dao),
    );
  }
}

class ContactsListView extends StatelessWidget {
  final ContactDao _dao;
  ContactsListView(this._dao);

 
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Transfer'),
        ),
        body: BlocBuilder<ContactsListCubit, ContactsListState>(
          builder: (context, state) {
            if (state is InitContactsListState ||
                state is LoadingContactsListState) {
              return ProgressView();
            }
            if (state is LoadedContactsListState) {
              final contacts = state._contacts;
              return ListView.builder(
                itemBuilder: (context, index) {
                  final contact = contacts[index];
                  return _ContactItem(
                    contact,
                    onClick: () {
                      push(context, TransactionFormContainer(contact));
                    },
                  );
                },
                itemCount: contacts.length,
              );
            }
            return const Text('Unknown error');
          },
        ),
        floatingActionButton: buildAddContactButton(context));
  }

  FloatingActionButton buildAddContactButton(BuildContext context) {
    return FloatingActionButton(
      onPressed: () async {
        await Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => ContactForm(),
          ),
        );
        update(context);
      },
      child: Icon(
        Icons.add,
      ),
    );
  }

  void update(BuildContext context) {
    context.read<ContactsListCubit>().reload(_dao);
  }
}

class _ContactItem extends StatelessWidget {
  final Contact contact;
  final Function onClick;

  _ContactItem(
    this.contact, {
    @required this.onClick,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        onTap: () => onClick(),
        title: Text(
          contact.name,
          style: TextStyle(
            fontSize: 24.0,
          ),
        ),
        subtitle: Text(
          contact.accountNumber.toString(),
          style: TextStyle(
            fontSize: 16.0,
          ),
        ),
      ),
    );
  }
}
