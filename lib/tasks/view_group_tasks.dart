import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:taskmate/tasks/view_completed_tasks.dart';
import 'package:intl/intl.dart';
import 'package:taskmate/tasks/view_members.dart';
import '../group/groups_screen.dart';
import '../widgets/widgets.dart';

class viewGroupTasks extends StatefulWidget {
  String groupID;
  viewGroupTasks({super.key, required this.groupID});

  @override
  State<viewGroupTasks> createState() => _viewGroupTasksState();
}

class _viewGroupTasksState extends State<viewGroupTasks> {
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  FirebaseAuth auth = FirebaseAuth.instance;
  List taskID = [];
  List tasks = [];
  List remainingTasks = [];
  DateTime today = DateTime.now();
  String? dateStr;
  String? currentTime;
  String? dateTime;
  Function eq = const ListEquality().equals;
  bool isLoading = true;
  @override
  void initState() {
    super.initState();
    dateStr = today.toString().substring(0, 10);
    currentTime = DateFormat.Hm().format(today);
    dateTime = dateStr! + " " + currentTime!;
    getTaskData();
  }

  void getTaskData() async {
    await firestore
        .collection('groups')
        .doc(widget.groupID)
        .collection('task')
        .get()
        .then((value) {
      setState(() {
        for (int i = 0; i < value.size; i++) {
          taskID.add(value.docs[i]['id']);
        }
      });
    });
    List completedTaskEmails = [];
    for (int i = 0; i < taskID.length; i++) {
      await firestore.collection('task').doc(taskID[i]).get().then((value) {
        setState(() {
          tasks.add(value.data());
          completedTaskEmails.add(value['completedBy']);
        });
      });
    }
    for (int i = 0; i < completedTaskEmails.length; i++) {
      List map = completedTaskEmails[i];
      if (completedTaskEmails.isNotEmpty) {
        List emails = [];
        for (var emailMap in map) {
          if (emailMap.isNotEmpty) {
            emails.add(emailMap.keys.toList());
          }
        }
        var flat = emails.expand((i) => i).toList();
        flat.sort();
        List email = tasks[i]['assignedTo'];
        email.sort();

        if (!eq(flat, email)) {
          remainingTasks.add(tasks[i]);
        }
      } else {
        remainingTasks.add(tasks[i]);
      }
    }
    isLoading = false;
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    return Scaffold(
        appBar: AppBar(
          leading: IconButton(
              onPressed: () {
                nextScreenReplace(context, const GroupScreen());
              },
              icon: const Icon(Icons.arrow_back)),
          centerTitle: true,
          backgroundColor: const Color(0xFFee7b64),
          title: const Text("Pending Group Tasks"),
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: !isLoading
                ? remainingTasks.isEmpty
                    ? const EmptyWidget(
                        message: 'Group Tasks appears here',
                        imageAsset: 'no_task.png')
                    : ListView.builder(
                        shrinkWrap: true,
                        physics: ClampingScrollPhysics(),
                        itemCount: remainingTasks.length,
                        itemBuilder: (BuildContext context, int index) {
                          return GestureDetector(
                            onTap: () {
                              nextScreen(
                                  context,
                                  view_members(
                                      gid: widget.groupID,
                                      tid: remainingTasks[index]['id']));
                            },
                            child: Card(
                              color: (dateTime!.compareTo(
                                          remainingTasks[index]['dueDate']) <
                                      0)
                                  ? Color.fromARGB(255, 210, 243, 216)
                                  : Color.fromARGB(255, 243, 210, 210),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: <Widget>[
                                  ListTile(
                                    leading: Container(
                                      width: 10,
                                      decoration: BoxDecoration(
                                          color: (dateTime!.compareTo(
                                                      remainingTasks[index]
                                                          ['dueDate']) <
                                                  0)
                                              ? Colors.green
                                              : Colors.red,
                                          borderRadius:
                                              BorderRadius.circular(45)),
                                    ),
                                    title: Text(remainingTasks[index]
                                        ['taskDescription']),
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: <Widget>[
                                      const SizedBox(width: 8),
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Text(
                                          ("Due date:" +
                                              remainingTasks[index]['dueDate']
                                                  .split(' ')[0]),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      )
                : Container(
                    height: size.height,
                    width: size.width,
                    alignment: Alignment.center,
                    child: CircularProgressIndicator()),
          ),
        ));
  }
}
