import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:taskmate/group/group_info.dart';
import 'package:taskmate/widgets/widgets.dart';

class AddMembersInGroup extends StatefulWidget {
  final String groupId, name;
  final List membersList;
  const AddMembersInGroup(
      {required this.name,
      required this.membersList,
      required this.groupId,
      Key? key})
      : super(key: key);

  @override
  State<AddMembersInGroup> createState() => _AddMembersInGroupState();
}

class _AddMembersInGroupState extends State<AddMembersInGroup> {
  final TextEditingController _search = TextEditingController();
  FirebaseFirestore _firestore = FirebaseFirestore.instance;
  FirebaseAuth _auth = FirebaseAuth.instance;
  List newMemberList = [];
  bool isLoading = false;
  Map<String, dynamic>? userMap;

  @override
  void initState() {
    super.initState();
  }

  void onSearch() async {
    setState(() {
      isLoading = true;
    });
    try {
      await _firestore
          .collection('users')
          .where("email", isEqualTo: _search.text)
          .get()
          .then((value) {
        setState(() {
          userMap = value.docs[0].data();
          isLoading = false;
        });
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      showSnackbar(context, Colors.red, "No user found");
    }
    bool isAlreadyExist = false;

    for (int i = 0; i < widget.membersList.length; i++) {
      if (widget.membersList[i]['uid'] == userMap!['uid']) {
        isAlreadyExist = true;
      }
    }
    if (isAlreadyExist) {
      showSnackbar(context, Colors.red, "User already present in group");
    }
  }

  void onResultTap() {
    bool isAlreadyExist = false;

    for (int i = 0; i < widget.membersList.length; i++) {
      if (widget.membersList[i]['uid'] == userMap!['uid']) {
        isAlreadyExist = true;
      }
    }

    if (!isAlreadyExist) {
      setState(() {
        newMemberList.add({
          "name": userMap!['name'],
          "email": userMap!['email'],
          "uid": userMap!['uid'],
          "profileImg":userMap!['profileImg'],
          "isAdmin": false,
        });
        if (isAlreadyExist) {
          showSnackbar(context, Colors.red, "User already present in group");
        }
        userMap = null;
      });
    }
  }

  void onRemoveMembers(int index) {
    if (newMemberList[index]['uid'] != _auth.currentUser!.uid) {
      setState(() {
        newMemberList.removeAt(index);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;

    return Scaffold(
        appBar: AppBar(
          title: const Text("Add Members"),
          centerTitle: true,
          backgroundColor: const Color(0xFFee7b64),
        ),
        body: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Flexible(
                child: ListView.builder(
                  itemCount: newMemberList.length,
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemBuilder: (context, index) {
                    return ListTile(
                      onTap: () => onRemoveMembers(index),
                      leading: Icon(Icons.account_circle),
                      title: Text(newMemberList[index]['name']),
                      subtitle: Text(newMemberList[index]['email']),
                      trailing: Icon(Icons.close),
                    );
                  },
                ),
              ),
              SizedBox(
                height: size.height / 20,
              ),
              Container(
                height: size.height / 14,
                width: size.width,
                alignment: Alignment.center,
                child: Container(
                  height: size.height / 14,
                  width: size.width / 1.15,
                  child: TextField(
                    controller: _search,
                    decoration: InputDecoration(
                      hintText: "Search",
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(
                              color: Color(0xFFee7b64), width: 2)),
                      focusedBorder: const OutlineInputBorder(
                        borderSide:
                            BorderSide(color: Color(0xFFee7b64), width: 2),
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(
                height: size.height / 50,
              ),
              isLoading
                  ? Container(
                      height: size.height / 12,
                      width: size.height / 12,
                      alignment: Alignment.center,
                      child: CircularProgressIndicator(),
                    )
                  : ElevatedButton(
                      onPressed: onSearch,
                      style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFee7b64)),
                      child: const Text("Search"),
                    ),
              userMap != null
                  ? ListTile(
                      onTap: onResultTap,
                      leading: const Icon(Icons.account_box),
                      title: Text(userMap!['name']),
                      subtitle: Text(userMap!['email']),
                      trailing: const Icon(Icons.add),
                    )
                  : SizedBox(),
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton(
          backgroundColor: const Color(0xFFee7b64),
          child: const Icon(Icons.forward),
          onPressed: () async {
            for (int i = 0; i < newMemberList.length; i++) {
              widget.membersList.add(newMemberList[i]);
            }
            await _firestore.collection('groups').doc(widget.groupId).update({
              "members": widget.membersList,
            });
            for (int i = 0; i < widget.membersList.length; i++) {
              String uid = widget.membersList[i]['uid'];
              await _firestore
                  .collection('users')
                  .doc(uid)
                  .collection('groups')
                  .doc(widget.groupId)
                  .set({
                "name": widget.name,
                "id": widget.groupId,
              });
            }
            Navigator.of(context).push(
              MaterialPageRoute(
                  builder: (_) => GroupInfo(
                      groupId: widget.groupId, groupName: widget.name)),
            );
          },
        ));
  }
}
