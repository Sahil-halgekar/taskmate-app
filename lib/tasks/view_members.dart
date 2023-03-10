import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../group/groups_screen.dart';
import '../widgets/widgets.dart';

class view_members extends StatefulWidget {
  String gid;
  String tid;
  view_members({super.key, required this.gid, required this.tid});

  @override
  State<view_members> createState() => _view_membersState();
}

class _view_membersState extends State<view_members> {
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  FirebaseAuth auth = FirebaseAuth.instance;
  List taskID = [];
  List tasks = [];
  List completed = [];
  List assignedTo = [];
  List emails = [];
  List<dynamic> result = [];
  Function eq = const ListEquality().equals;
  bool isLoading = true;
  @override
  void initState() {
    super.initState();
    getData();
  }

  void getData() async {
    await firestore.collection('task').doc(widget.tid).get().then((value) {
      setState(() {
        List map = (value['completedBy']);
        assignedTo = value['assignedTo'];
        for (var emailMap in map) {
          if (emailMap.isNotEmpty) {
            emails.add(emailMap.keys.toList());
          }
        }
        completed = emails.expand((i) => i).toList();
        result = assignedTo.where((item) => !completed.contains(item)).toList();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
            onPressed: () {
              nextScreenReplace(context, const GroupScreen());
            },
            icon: const Icon(Icons.arrow_back)),
        centerTitle: true,
        backgroundColor: const Color(0xFFee7b64),
        title: const Text("Assigned Members"),
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
                      'Completed By',
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
              itemCount: completed.length,
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
                    title: Text(completed[index]),
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
                      'Still To complete',
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
              itemCount: result.length,
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
                    title: Text(result[index]),
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
