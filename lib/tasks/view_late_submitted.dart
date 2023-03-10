import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../group/groups_screen.dart';
import '../widgets/widgets.dart';

class viewLateSubmitted extends StatefulWidget {
  String tid;
  String gid;
  viewLateSubmitted({super.key, required this.tid, required this.gid});
  @override
  State<viewLateSubmitted> createState() => _viewLateSubmittedState();
}

class _viewLateSubmittedState extends State<viewLateSubmitted> {
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  List<dynamic> onTime = [];
  List lateSubmission = [];
  List emails = [];
  bool isLoading = true;
  @override
  void initState() {
    super.initState();
    getData();
  }

  void getData() async {
    await firestore.collection('task').doc(widget.tid).get().then((value) {
      setState(() {
        onTime.clear();
        lateSubmission.clear();
        for (var emailMap in value['completedBy']) {
          if (emailMap.isNotEmpty) {
            if (emailMap.values.toList()[0].compareTo(value['dueDate']) <= 0) {
              onTime.add(emailMap.keys.toList());
            } else {
              lateSubmission.add(emailMap.keys.toList());
            }
          }
        }
      });
    });
    onTime = onTime.expand((i) => i).toList();
    lateSubmission = lateSubmission.expand((i) => i).toList();
    isLoading = false;
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
            onPressed: () {
              nextScreenReplace(context, const GroupScreen());
              getData();
            },
            icon: const Icon(Icons.arrow_back)),
        centerTitle: true,
        backgroundColor: const Color(0xFFee7b64),
        title: const Text("Task Submission Information"),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              color: Colors.grey.withOpacity(.1),
              height: 45,
              width: size.width,
              child: Align(
                  alignment: Alignment.centerLeft,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 16.0),
                    child: Text(
                      'Completed On Time',
                      style: Theme.of(context)
                          .textTheme
                          .bodyText1!
                          .copyWith(fontWeight: FontWeight.w600),
                    ),
                  )),
            ),
            ListView.builder(
              shrinkWrap: true,
              physics: ClampingScrollPhysics(),
              itemCount: onTime.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.all(5.0),
                  child: ListTile(
                    tileColor: Color.fromARGB(255, 210, 243, 216),
                    onTap: () {},
                    leading: CircleAvatar(
                      radius: 30,
                      backgroundColor: Colors.transparent,
                      child: ClipOval(child: Image.asset("assets/user.png")),
                    ),
                    title: Text(onTime[index]),
                  ),
                );
              },
            ),
            Container(
              color: Colors.grey.withOpacity(.1),
              height: 45,
              width: size.width,
              child: Align(
                  alignment: Alignment.centerLeft,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 16.0),
                    child: Text(
                      'Late Submission',
                      style: Theme.of(context)
                          .textTheme
                          .bodyText1!
                          .copyWith(fontWeight: FontWeight.w600),
                    ),
                  )),
            ),
            ListView.builder(
              shrinkWrap: true,
              physics: ClampingScrollPhysics(),
              itemCount: lateSubmission.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.all(5.0),
                  child: ListTile(
                    tileColor: Color.fromARGB(255, 243, 210, 210),
                    onTap: () {},
                    leading: CircleAvatar(
                      radius: 30,
                      backgroundColor: Colors.transparent,
                      child: ClipOval(child: Image.asset("assets/user.png")),
                    ),
                    title: Text(lateSubmission[index]),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
