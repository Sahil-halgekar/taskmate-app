import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../group/groups_screen.dart';
import '../widgets/widgets.dart';

class viewCompletedTasks extends StatefulWidget {
  String groupID;
  viewCompletedTasks({super.key, required this.groupID});

  @override
  State<viewCompletedTasks> createState() => _viewCompletedTasksState();
}

class _viewCompletedTasksState extends State<viewCompletedTasks> {
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  FirebaseAuth auth = FirebaseAuth.instance;
  List taskID = [];
  List onTime = [];
  List latesubmitted = [];
  List tasks = [];
  List completedTask = [];
  DateTime today = DateTime.now();
  String? dateStr;
  String? currentTime;
  String? dateTime;
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
        .collection("users")
        .doc(auth.currentUser!.uid)
        .collection("task")
        .get()
        .then((value) {
      setState(() {
        for (int i = 0; i < value.size; i++) {
          if (widget.groupID == value.docs[i]['groupId']) {
            taskID.add(value.docs[i]['id']);
          }
        }
      });
    });
    for (int i = 0; i < taskID.length; i++) {
      await firestore.collection('task').doc(taskID[i]).get().then((value) {
        setState(() {
          tasks.add(value.data());
        });
      });
    }
    List completedTaskEmails = [];
    for (int i = 0; i < tasks.length; i++) {
      setState(() {
        completedTaskEmails.add(tasks[i]['completedBy']);
      });
    }

    for (int i = 0; i < completedTaskEmails.length; i++) {
      setState(() {
        List map = ((completedTaskEmails[i]));
        if (map.isNotEmpty) {
          for (var emailMap in map) {
            if (emailMap.containsKey(auth.currentUser!.email)) {
              completedTask.add(tasks[i]);
            }
          }
        }
      });
    }
    onTime.clear();
    latesubmitted.clear();
    for (int i = 0; i < completedTask.length; i++) {
      for (var emailMap in completedTask[i]['completedBy']) {
        if (emailMap.isNotEmpty) {
          if (emailMap.values
                  .toList()[0]
                  .compareTo(completedTask[i]['dueDate']) <=
              0) {
            onTime.add(completedTask[i]);
          } else {
            latesubmitted.add(completedTask[i]);
          }
        }
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
          title: const Text("Completed Tasks"),
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: !isLoading
                ? completedTask.isEmpty
                    ? const EmptyWidget(
                        message: 'Tasks completed by you appear here',
                        imageAsset: 'no_task.png')
                    : Column(
                        children: [
                          ListView.builder(
                            shrinkWrap: true,
                            physics: ClampingScrollPhysics(),
                            itemCount: onTime.length,
                            itemBuilder: (BuildContext context, int index) {
                              return Card(
                                color: Color.fromARGB(255, 210, 243, 216),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: <Widget>[
                                    Padding(
                                      padding: const EdgeInsets.fromLTRB(
                                          5, 10, 0, 10),
                                      child: ListTile(
                                        leading: Container(
                                          width: 15,
                                          decoration: BoxDecoration(
                                              color: Colors.green,
                                              borderRadius:
                                                  BorderRadius.circular(45)),
                                        ),
                                        title: Text(
                                            onTime[index]['taskDescription']),
                                      ),
                                    ),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: const <Widget>[
                                        SizedBox(width: 8),
                                        Padding(
                                            padding: EdgeInsets.all(8.0),
                                            child: Text("")),
                                        SizedBox(width: 8),
                                      ],
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                          ListView.builder(
                            shrinkWrap: true,
                            physics: ClampingScrollPhysics(),
                            itemCount: latesubmitted.length,
                            itemBuilder: (BuildContext context, int index) {
                              return Card(
                                color: Color.fromARGB(255, 243, 210, 210),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: <Widget>[
                                    Padding(
                                      padding: const EdgeInsets.fromLTRB(
                                          5, 10, 0, 10),
                                      child: ListTile(
                                        leading: Container(
                                          width: 15,
                                          decoration: BoxDecoration(
                                              color: Colors.red,
                                              borderRadius:
                                                  BorderRadius.circular(45)),
                                        ),
                                        title: Text(latesubmitted[index]
                                            ['taskDescription']),
                                      ),
                                    ),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: const <Widget>[
                                        SizedBox(width: 8),
                                        Padding(
                                          padding: EdgeInsets.all(8.0),
                                          child: Text(
                                            ("Completed after due time"),
                                            style: TextStyle(color: Colors.red),
                                          ),
                                        ),
                                        SizedBox(width: 8),
                                      ],
                                    ),
                                  ],
                                ),
                              );
                            },
                          )
                        ],
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
