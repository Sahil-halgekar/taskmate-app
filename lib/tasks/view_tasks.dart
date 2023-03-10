import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:taskmate/group/group_methods.dart';
import 'package:taskmate/tasks/view_completed_tasks.dart';
import '../group/groups_screen.dart';
import '../widgets/widgets.dart';

class viewTasks extends StatefulWidget {
  String gid;
  String name;
  viewTasks({super.key, required this.gid, required this.name});

  @override
  State<viewTasks> createState() => _viewTasksState();
}

class _viewTasksState extends State<viewTasks> {
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  FirebaseAuth auth = FirebaseAuth.instance;
  List taskID = [];
  List tasks = [];
  int flag = 0;
  DateTime today = DateTime.now();
  String? dateStr;
  String? currentTime;
  String? dateTime;
  List completedTask = [];
  List remainingTasks = [];
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
          if (widget.gid == value.docs[i]['groupId']) {
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
          flag = 0;
          for (var emailMap in map) {
            if (emailMap.containsKey(auth.currentUser!.email)) {
              flag = 1;
            }
          }
          if (flag == 0) {
            remainingTasks.add(tasks[i]);
          }
        } else {
          remainingTasks.add(tasks[i]);
        }
      });
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
          title: const Text("Assigned Tasks"),
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: !isLoading
                ? remainingTasks.isEmpty
                    ? const EmptyWidget(
                        message:
                            'Tasks asigned to you and tasks created for you appears here',
                        imageAsset: 'no_task.png')
                    : ListView.builder(
                        shrinkWrap: true,
                        physics: ClampingScrollPhysics(),
                        itemCount: remainingTasks.length,
                        itemBuilder: (BuildContext context, int index) {
                          return Card(
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
                                  title: Text(
                                      remainingTasks[index]['taskDescription']),
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: <Widget>[
                                    TextButton(
                                      child: const Text('Completed?'),
                                      onPressed: () async {
                                        showDialog(
                                            barrierDismissible: false,
                                            context: context,
                                            builder: (context) {
                                              return AlertDialog(
                                                title: const Text(
                                                    "Task Completed"),
                                                content: const Text(
                                                    "Are you sure you have completed the task?"),
                                                actions: [
                                                  IconButton(
                                                    onPressed: () {
                                                      Navigator.pop(context);
                                                    },
                                                    icon: const Icon(
                                                      Icons.cancel,
                                                      color: Colors.red,
                                                    ),
                                                  ),
                                                  IconButton(
                                                    onPressed: () async {
                                                      completedTask.add({
                                                        auth.currentUser!.email:
                                                            dateTime
                                                      });

                                                      await firestore
                                                          .collection('task')
                                                          .doc(remainingTasks[
                                                              index]['id'])
                                                          .update({
                                                        "completedBy": FieldValue
                                                            .arrayUnion(
                                                                completedTask)
                                                      });
                                                      showSnackbar(
                                                          context,
                                                          (Colors.green),
                                                          "Task Completed Successfully");
                                                      // ignore: use_build_context_synchronously
                                                      Navigator.pushReplacement(
                                                          context,
                                                          MaterialPageRoute(
                                                            builder: (context) =>
                                                                GroupMethods(
                                                              id: widget.gid,
                                                              name: widget.name,
                                                            ),
                                                          ));
                                                    },
                                                    icon: const Icon(
                                                      Icons.done,
                                                      color: Colors.green,
                                                    ),
                                                  ),
                                                ],
                                              );
                                            });
                                      },
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      ("Due Date: " +
                                          remainingTasks[index]['dueDate']
                                              .split(' ')[0] +
                                          "\nDue Time:" +
                                          remainingTasks[index]['dueDate']
                                              .split(' ')[1]),
                                    ),
                                    const SizedBox(width: 8),
                                  ],
                                ),
                              ],
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
