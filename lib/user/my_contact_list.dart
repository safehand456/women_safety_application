import 'package:flutter/material.dart';
import 'package:flutter_contacts/flutter_contacts.dart';

class MyphoneContactList extends StatefulWidget {
  const MyphoneContactList({super.key});

  @override
  State<MyphoneContactList> createState() => _MyphoneContactListState();
}

class _MyphoneContactListState extends State<MyphoneContactList> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getContact();
  }

  List<Contact>  ? contacts;


  void getContact() async {

    if(await FlutterContacts.requestPermission()){
      contacts = await FlutterContacts.getContacts();
      
    }





  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [

        ],
      ),
    );
  }
}