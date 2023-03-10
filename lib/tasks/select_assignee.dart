// ignore_for_file: avoid_single_cascade_in_expression_statements

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:taskmate/tasks/create_task.dart';
import 'package:taskmate/widgets/widgets.dart';

class selectAssignee extends StatefulWidget {
  List users;
  String reminderDate;
  String id;
  String description;
  String date;
  bool reminder;
  String gname;
  selectAssignee(
      {super.key,
      required this.users,
      required this.id,
      required this.description,
      required this.date,
      required this.reminder,
      required this.reminderDate,
      required this.gname});

  @override
  State<selectAssignee> createState() => _selectAssigneeState();
}

class _selectAssigneeState extends State<selectAssignee> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  Map<String, dynamic>? userMap;
  List selectedUsers = [];
  void initState() {
    super.initState();
    getdata();
  }

  void getdata() async {
    for (int i = 0; i < widget.users.length; i++) {
      await firestore.collection('users')
        ..where("email", isEqualTo: widget.users[i]['email'])
            .get()
            .then((value) {
          setState(() {
            widget.users[i]['profileImg'] = value.docs[0].data()['profileImg'];
          });
        });
    }
  }

  List<bool> isChecked = List.generate(100, (index) => false);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: const Color(0xFFee7b64),
        title: const Text("Select members"),
      ),
      body: Column(
        children: [
          SingleChildScrollView(
            physics: ScrollPhysics(),
            child: ListView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: widget.users.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.all(5.0),
                  child: ListTile(
                    onTap: () {},
                    trailing: Checkbox(
                      activeColor: Colors.white,
                      checkColor: Colors.green,
                      onChanged: (checked) {
                        setState(
                          () {
                            isChecked[index] = checked!;
                            if (isChecked[index]) {
                              selectedUsers.add(widget.users[index]['email']);
                            } else {
                              selectedUsers
                                  .remove(widget.users[index]['email']);
                            }
                          },
                        );
                      },
                      value: isChecked[index],
                    ),
                    leading: CircleAvatar(
                      radius: 30,
                      backgroundColor: Colors.transparent,
                      child: ClipOval(
                        child: widget.users[index]['profileImg'] == ''
                            ? Image.asset("assets/user.png")
                            : Image.network(widget.users[index]['profileImg'],
                                width: 150, fit: BoxFit.fill),
                      ),
                    ),
                    title: Text(widget.users[index]['name']),
                  ),
                );
              },
            ),
          ),
          ElevatedButton(
              style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  backgroundColor: Colors.black),
              onPressed: () {
                nextScreenReplace(
                    context,
                    createTask(
                        id: widget.id,
                        selected: selectedUsers,
                        description: widget.description,
                        date: widget.date,
                        gname: widget.gname,
                        reminderDate: widget.reminderDate,
                        reminder: widget.reminder));
              },
              child: const Padding(
                padding: EdgeInsets.all(12.0),
                child: Text("Add Members"),
              )),
        ],
      ),
    );
  }
}
