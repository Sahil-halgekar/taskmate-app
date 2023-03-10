import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:taskmate/group/group_info.dart';
import 'package:taskmate/tasks/create_task.dart';
import 'package:taskmate/tasks/view_completed_group_tasks.dart';
import 'package:taskmate/tasks/view_completed_tasks.dart';
import 'package:taskmate/tasks/view_group_tasks.dart';
import 'package:taskmate/tasks/view_tasks.dart';
import 'package:taskmate/widgets/widgets.dart';

class GroupMethods extends StatefulWidget {
  String name;
  String id;
  GroupMethods({super.key, required this.name, required this.id});

  @override
  State<GroupMethods> createState() => _GroupMethodsState();
}

class _GroupMethodsState extends State<GroupMethods> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          centerTitle: true,
          backgroundColor: const Color(0xFFee7b64),
          title: const Text("Select Action"),
        ),
        body: Column(
          children: [
            Row(
              children: const [
                SizedBox(
                  height: 10,
                ),
              ],
            ),
            const SizedBox(
              height: 30,
            ),
            Expanded(
              child: GridView(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    mainAxisSpacing: 5.0,
                    crossAxisSpacing: 5.0,
                    childAspectRatio: 0.9),
                children: [
                  buildContainer(context, "Add a member", "assets/add-user.png",
                      GroupInfo(groupId: widget.id, groupName: widget.name)),
                  buildContainer(
                      context,
                      "Create new Task",
                      "assets/create-task.png",
                      createTask(
                          id: widget.id,
                          selected: [],
                          reminderDate: "",
                          description: "",
                          date: "",
                          reminder: false,
                          gname: widget.name)),
                  buildContainer(
                      context,
                      "View Tasks",
                      "assets/view-tasks.png",
                      viewTasks(
                        gid: widget.id,
                        name: widget.name,
                      )),
                  buildContainer(
                      context,
                      "View Completed Tasks",
                      "assets/completed.png",
                      viewCompletedTasks(
                        groupID: widget.id,
                      )),
                  buildContainer(
                      context,
                      "View Group Tasks",
                      "assets/view-group-task.png",
                      viewGroupTasks(
                        groupID: widget.id,
                      )),
                  buildContainer(
                      context,
                      "View Completed Group Tasks",
                      "assets/completed-group-task.png",
                      viewCompletedGroupTasks(
                        groupID: widget.id,
                      ))
                ],
              ),
            ),
          ],
        ));
  }

  InkWell buildContainer(
      BuildContext context, String text, String img, Object screen) {
    return InkWell(
      onTap: () {
        nextScreen(context, screen);
      },
      child: Container(
        margin:
            const EdgeInsets.only(left: 5.0, top: 1.0, right: 1.0, bottom: 5.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: const Color.fromARGB(255, 62, 61, 61),
        ),
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Expanded(
            child: Image(
              image: AssetImage(img),
              height: 18.h,
              width: 18.w,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              text,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 10.sp,
              ),
            ),
          )
        ]),
      ),
    );
  }
}
