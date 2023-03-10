import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_stack/image_stack.dart';
import 'package:intl/intl.dart';
import 'package:sizer/sizer.dart';
import 'package:taskmate/group/groups_screen.dart';
import 'package:taskmate/tasks/select_assignee.dart';
import 'package:taskmate/tasks/view_tasks.dart';
import 'package:taskmate/widgets/widgets.dart';
import 'package:uuid/uuid.dart';
import 'package:flutter_image_stack/flutter_image_stack.dart';

class createTask extends StatefulWidget {
  String id;
  List selected = [];
  String description;
  String date;
  bool reminder;
  String gname;
  String reminderDate;
  createTask(
      {super.key,
      required this.id,
      required this.selected,
      required this.description,
      required this.date,
      required this.reminder,
      required this.gname,
      required this.reminderDate});

  @override
  State<createTask> createState() => _createTaskState();
}

class _createTaskState extends State<createTask> {
  final FocusNode taskFocusNode = FocusNode();
  bool isSwitched = false;
  final TextEditingController descriptionTextEditingController =
      TextEditingController();
  final TextEditingController dueDateTextEditingController =
      TextEditingController();
  final TextEditingController reminderDateTextEditingController =
      TextEditingController();
  final DateFormat dateFormat = DateFormat('yyyy-MM-dd HH:mm');
  late DateTime dueDate;
  late DateTime reminderDate;
  DateTime today = DateTime.now();
  String? dateStr;
  String? currentTime;
  String? dateTime;
  List userList = [];
  List assignedTo = [];
  FirebaseFirestore _firestore = FirebaseFirestore.instance;
  FirebaseAuth _auth = FirebaseAuth.instance;
  List<String> images = <String>[];
  List<dynamic> completedBy = [];

  @override
  void initState() {
    super.initState();
    reminderDateTextEditingController.text = widget.reminderDate;
    descriptionTextEditingController.text = widget.description;
    dueDateTextEditingController.text = widget.date;
    isSwitched = widget.reminder;
    dateStr = today.toString().substring(0, 10);
    currentTime = DateFormat.Hm().format(today);
    dateTime = dateStr! + " " + currentTime!;
    assignedTo = widget.selected;
    getMembers();
    getImages();
  }

  void getMembers() async {
    await _firestore.collection("groups").doc(widget.id).get().then((value) {
      setState(() {
        userList = value['members'];
      });
    });
  }

  void getImages() async {
    for (int i = 0; i < widget.selected.length; i++) {
      // ignore: avoid_single_cascade_in_expression_statements
      await _firestore
          .collection('users')
          .where("email", isEqualTo: widget.selected[i])
          .get()
          .then((value) {
        setState(() {
          if (value.docs[0]['profileImg'] != "") {
            images.add(value.docs[0]['profileImg']);
          } else {
            images.add(
                "https://firebasestorage.googleapis.com/v0/b/taskmate-5a6cb.appspot.com/o/profileImages%2Fuser.png?alt=media&token=eae76708-01c5-43e6-ac1d-4d2a58dbee7a");
          }
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
            onPressed: () {
              nextScreenReplace(context, const GroupScreen());
            },
            icon: const Icon(Icons.arrow_back)),
        centerTitle: true,
        backgroundColor: const Color(0xFFee7b64),
        title: const Text("Create Task"),
      ),
      body: Form(
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            Text(
              'What needs to be done ?',
              style: Theme.of(context)
                  .textTheme
                  .bodyText1!
                  .copyWith(fontWeight: FontWeight.w600, fontSize: 13.sp),
            ),
            const SizedBox(
              height: 15,
            ),
            TextFormField(
              controller: descriptionTextEditingController,
              focusNode: taskFocusNode,
              style: Theme.of(context).textTheme.bodyText1,
              textInputAction: TextInputAction.next,
              keyboardType: TextInputType.multiline,
              textCapitalization: TextCapitalization.sentences,
              maxLines: 4,
              cursorColor: Theme.of(context).textSelectionTheme.cursorColor,
              enableInteractiveSelection: true,
              decoration: InputDecoration(
                  filled: false,
                  hintText: 'Start Typing ...',
                  hintStyle: Theme.of(context)
                      .textTheme
                      .bodyText1!
                      .copyWith(color: Colors.grey)),
              validator: (value) {
                if (value!.isEmpty) {
                  return 'Field cannot be Empty';
                }
                return null;
              },
            ),
            const SizedBox(
              height: 20,
            ),
            Text(
              'Select due date and time',
              style: Theme.of(context)
                  .textTheme
                  .bodyText1!
                  .copyWith(fontWeight: FontWeight.w600, fontSize: 13.sp),
            ),
            const SizedBox(
              height: 10,
            ),
            Text(
              'Due date & time',
              style: Theme.of(context)
                  .textTheme
                  .bodyText2!
                  .copyWith(fontWeight: FontWeight.normal, color: Colors.grey),
            ),
            const SizedBox(
              height: 10,
            ),
            InkWell(
              onTap: () async {
                await pickDateTime(context, 1);
              },
              child: TextFormField(
                onTap: () async {
                  await pickDateTime(context, 1);
                },
                controller: dueDateTextEditingController,
                style: Theme.of(context)
                    .textTheme
                    .bodyText1!
                    .copyWith(fontWeight: FontWeight.w600),
                textInputAction: TextInputAction.done,
                keyboardType: TextInputType.datetime,
                maxLines: 1,
                cursorColor: Theme.of(context).textSelectionTheme.cursorColor,
                enableInteractiveSelection: true,
                decoration: InputDecoration(
                    filled: false,
                    border: const UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.black)),
                    hintStyle: Theme.of(context)
                        .textTheme
                        .bodyText1!
                        .copyWith(color: Colors.grey),
                    suffixIcon: const Icon(
                      Icons.arrow_forward,
                      color: Colors.grey,
                    )),
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Field cannot be Empty';
                  }
                  return null;
                },
              ),
            ),
            const SizedBox(
              height: 15,
            ),
            const SizedBox(
              height: 20,
            ),
            Text(
              'Select memebers to whom task must be assigned',
              style: Theme.of(context)
                  .textTheme
                  .bodyText1!
                  .copyWith(fontWeight: FontWeight.w600, fontSize: 13.sp),
            ),
            const SizedBox(
              height: 10,
            ),
            Text(
              'select Assignee',
              style: Theme.of(context)
                  .textTheme
                  .bodyText2!
                  .copyWith(fontWeight: FontWeight.normal, color: Colors.grey),
            ),
            const SizedBox(
              height: 15,
            ),
            Row(
              children: [
                widget.selected.isEmpty
                    ? GestureDetector(
                        onTap: () {
                          nextScreen(
                              context,
                              selectAssignee(
                                  gname: widget.gname,
                                  reminderDate:
                                      reminderDateTextEditingController.text,
                                  id: widget.id,
                                  users: userList,
                                  description:
                                      descriptionTextEditingController.text,
                                  date: dueDateTextEditingController.text,
                                  reminder: isSwitched));
                        },
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: DottedBorder(
                            borderType: BorderType.Circle,
                            radius: const Radius.circular(6),
                            color: Colors.grey,
                            dashPattern: const [6, 3, 6, 3],
                            child: ClipRRect(
                              borderRadius:
                                  const BorderRadius.all(Radius.circular(45)),
                              child: Container(
                                height: 45,
                                width: 45,
                                color: Colors.grey.withOpacity(.2),
                                child: const Center(
                                  child: Icon(
                                    Icons.person_add,
                                    color: Colors.grey,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      )
                    : GestureDetector(
                        onTap: () {
                          nextScreen(
                              context,
                              selectAssignee(
                                  gname: widget.gname,
                                  reminderDate:
                                      reminderDateTextEditingController.text,
                                  id: widget.id,
                                  users: userList,
                                  description:
                                      descriptionTextEditingController.text,
                                  date: dueDateTextEditingController.text,
                                  reminder: isSwitched));
                        },
                        child: Padding(
                            padding: const EdgeInsets.only(right: 8.0),
                            child: FlutterImageStack(
                              itemRadius: 50,
                              itemBorderWidth: 1,
                              showTotalCount: true,
                              imageList: images,
                              totalCount: images.length,
                            )),
                      )
              ],
            ),
            const SizedBox(height: 25),
            TextButton(
              style: TextButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  backgroundColor: Colors.black),
              onPressed: () async {
                if (descriptionTextEditingController.text == "" ||
                    dueDateTextEditingController.text == "" ||
                    widget.selected.isEmpty) {
                  showSnackbar(
                      context, Colors.red, "Please fill all the fields");
                } else {
                  String taskId = Uuid().v1();
                  await FirebaseFirestore.instance
                      .collection("task")
                      .doc(taskId)
                      .set({
                    "id": taskId,
                    "taskDescription": descriptionTextEditingController.text,
                    "dueDate": dueDateTextEditingController.text,
                    "reminder": isSwitched,
                    "assignedTo": widget.selected,
                    "completedBy": completedBy,
                    "assignedTime": dateTime
                  });
                  await FirebaseFirestore.instance
                      .collection('groups')
                      .doc(widget.id)
                      .collection('task')
                      .doc(taskId)
                      .set({'id': taskId});
                  for (int i = 0; i < widget.selected.length; i++) {
                    String email = widget.selected[i];
                    String userId = "";
                    await _firestore
                        .collection("users")
                        .where('email', isEqualTo: email)
                        .get()
                        .then((value) {
                      setState(() {
                        userId = (value.docs[0]['uid']);
                      });
                    });
                    await _firestore
                        .collection('users')
                        .doc(userId)
                        .collection('task')
                        .doc(taskId)
                        .set({"id": taskId, "groupId": widget.id});
                  }
                  final url = Uri.parse(
                      "https://taskmate-email-service.vercel.app/reminder/createTask");
                  http.post(url,
                      headers: <String, String>{
                        'Content-Type': 'application/json; charset=UTF-8',
                      },
                      body: jsonEncode(<String, dynamic>{
                        "assignedTo": assignedTo,
                        "groupName": widget.gname
                      }));

                  showSnackbar(context, Colors.green, "Task Assigned");
                  nextScreen(
                      context,
                      viewTasks(
                        gid: widget.id,
                        name: widget.gname,
                      ));
                }
              },
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Text('Create Task',
                    style: Theme.of(context)
                        .textTheme
                        .button!
                        .copyWith(color: Colors.white)),
              ),
            ),
            const SizedBox(height: 15),
          ],
        ),
      ),
    );
  }

  pickDateTime(BuildContext context, int flag) async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2030),
      helpText: 'Select due date',
    );
    if (picked != null) {
      TimeOfDay? timeOfDay = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
        helpText: 'Select due time',
      );

      if (flag == 1) {
        if (timeOfDay != null) {
          setState(() {
            dueDate = DateTime(picked.year, picked.month, picked.day,
                timeOfDay.hour, timeOfDay.minute);
            dueDateTextEditingController.text = dateFormat.format(dueDate);
          });
        }
      }
      if (flag == 2) {
        if (timeOfDay != null) {
          setState(() {
            reminderDate = DateTime(picked.year, picked.month, picked.day,
                timeOfDay.hour, timeOfDay.minute);
            reminderDateTextEditingController.text =
                dateFormat.format(reminderDate);
          });
        }
      }
    }
  }
}
