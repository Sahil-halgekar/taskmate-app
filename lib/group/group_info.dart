// ignore_for_file: avoid_single_cascade_in_expression_statements

import 'package:taskmate/Screens/HomeScreen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:taskmate/group/create_group/add_members.dart';

class GroupInfo extends StatefulWidget {
  final String groupId, groupName;
  const GroupInfo({required this.groupId, required this.groupName, Key? key})
      : super(key: key);

  @override
  State<GroupInfo> createState() => _GroupInfoState();
}

class _GroupInfoState extends State<GroupInfo> {
  List membersList = [];
  bool isLoading = true;

  FirebaseFirestore _firestore = FirebaseFirestore.instance;
  FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  void initState() {
    super.initState();
    getGroupDetails();
  }

  Future getGroupDetails() async {
    await _firestore
        .collection('groups')
        .doc(widget.groupId)
        .get()
        .then((chatMap) {
      membersList = chatMap['members'];
      isLoading = false;
      setState(() {});
    });
    for (int i = 0; i < membersList.length; i++) {
      await _firestore.collection('users')
        ..where("email", isEqualTo: membersList[i]['email'])
            .get()
            .then((value) {
          setState(() {
            membersList[i]['profileImg'] = value.docs[0].data()['profileImg'];
          });
        });
    }
  }

  bool checkAdmin() {
    bool isAdmin = false;

    membersList.forEach((element) {
      if (element['uid'] == _auth.currentUser!.uid) {
        isAdmin = element['isAdmin'];
      }
    });
    return isAdmin;
  }

  Future removeMembers(int index) async {
    String uid = membersList[index]['uid'];

    setState(() {
      isLoading = true;
      membersList.removeAt(index);
    });

    await _firestore.collection('groups').doc(widget.groupId).update({
      "members": membersList,
    }).then((value) async {
      await _firestore
          .collection('users')
          .doc(uid)
          .collection('groups')
          .doc(widget.groupId)
          .delete();

      setState(() {
        isLoading = false;
      });
    });
  }

  void showDialogBox(int index) {
    if (checkAdmin()) {
      if (_auth.currentUser!.uid != membersList[index]['uid']) {
        showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                content: ListTile(
                  onTap: () => removeMembers(index),
                  title: Text("Remove This Member"),
                ),
              );
            });
      }
    }
  }

  Future onLeaveGroup() async {
    if (!checkAdmin()) {
      setState(() {
        isLoading = true;
      });

      for (int i = 0; i < membersList.length; i++) {
        if (membersList[i]['uid'] == _auth.currentUser!.uid) {
          membersList.removeAt(i);
        }
      }

      await _firestore.collection('groups').doc(widget.groupId).update({
        "members": membersList,
      });

      await _firestore
          .collection('users')
          .doc(_auth.currentUser!.uid)
          .collection('groups')
          .doc(widget.groupId)
          .delete();

      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => HomeScreen()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Group Information",
        ),
        backgroundColor: const Color(0xFFee7b64),
        centerTitle: true,
      ),
      body: isLoading
          ? Container(
              height: size.height,
              width: size.width,
              alignment: Alignment.center,
              child: CircularProgressIndicator(),
            )
          : SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    height: size.height / 8,
                    width: size.width / 1.1,
                    child: Row(
                      children: [
                        Container(
                          height: size.height / 11,
                          width: size.height / 11,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.grey,
                          ),
                          child: Icon(
                            Icons.group,
                            color: Colors.white,
                            size: size.width / 10,
                          ),
                        ),
                        SizedBox(
                          width: size.width / 20,
                        ),
                        Expanded(
                          child: Container(
                            child: Text(
                              widget.groupName,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: size.width / 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  //

                  SizedBox(
                    height: size.height / 20,
                  ),

                  Container(
                    width: size.width / 1.1,
                    child: Text(
                      "${membersList.length} Members",
                      style: TextStyle(
                        fontSize: size.width / 20,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),

                  SizedBox(
                    height: size.height / 20,
                  ),

                  // Members Name

                  checkAdmin()
                      ? ListTile(
                          onTap: () => Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => AddMembersInGroup(
                                groupId: widget.groupId,
                                name: widget.groupName,
                                membersList: membersList,
                              ),
                            ),
                          ),
                          leading: const Icon(Icons.add, size: 35),
                          title: Text(
                            "Add Members",
                            style: TextStyle(
                              fontSize: size.width / 22,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        )
                      : SizedBox(),

                  Flexible(
                    child: ListView.builder(
                      itemCount: membersList.length,
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      itemBuilder: (context, index) {
                        return ListTile(
                          onTap: () => showDialogBox(index),
                          leading: CircleAvatar(
                            radius: 30,
                            backgroundColor: Colors.transparent,
                            child: ClipOval(
                                child: membersList[index]['profileImg'] == ''
                                    ? Image.asset("assets/user.png")
                                    : Image.network(
                                        membersList[index]['profileImg'],
                                        width: 100,
                                        fit: BoxFit.fill)),
                          ),
                          title: Text(
                            membersList[index]['name'],
                            style: TextStyle(
                              fontSize: size.width / 22,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          subtitle: Text(membersList[index]['email']),
                          trailing: Text(
                              membersList[index]['isAdmin'] ? "Admin" : ""),
                        );
                      },
                    ),
                  ),

                  ListTile(
                    onTap: onLeaveGroup,
                    leading: const Icon(
                      Icons.logout,
                      color: Colors.redAccent,
                    ),
                    title: Text(
                      "Leave Group",
                      style: TextStyle(
                        fontSize: size.width / 22,
                        fontWeight: FontWeight.w500,
                        color: Colors.redAccent,
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
