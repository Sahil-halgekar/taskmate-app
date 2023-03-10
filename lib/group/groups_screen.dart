import 'package:taskmate/group/create_group/create_group.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:taskmate/group/group_methods.dart';
import 'package:taskmate/group/group_info.dart';
import '../widgets/widgets.dart';

class GroupScreen extends StatefulWidget {
  const GroupScreen({Key? key}) : super(key: key);

  @override
  State<GroupScreen> createState() => _GroupScreenState();
}

class _GroupScreenState extends State<GroupScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  bool isLoading = true;
  List<Map<String, dynamic>> membersList = [];
  List groupList = [];

  @override
  void initState() {
    super.initState();
    getCurrentUserDetails();
    getAvailableGroups();
  }

  void getCurrentUserDetails() async {
    await _firestore
        .collection('users')
        .doc(_auth.currentUser!.uid)
        .get()
        .then((map) {
      setState(() {
        membersList.add({
          "name": map['name'],
          "email": map['email'],
          "uid": map['uid'],
          "profileImg": map['profileImg'],
          "isAdmin": true,
        });
      });
    });
  }

  void getAvailableGroups() async {
    String uid = _auth.currentUser!.uid;

    await _firestore
        .collection('users')
        .doc(uid)
        .collection('groups')
        .get()
        .then((value) {
      setState(() {
        groupList = value.docs;
      });
    });
    isLoading = false;
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: const Color(0xFFee7b64),
        title: const Text("Groups"),
      ),
      drawer: showDrawer(
          isHomeSelected: false,
          isGroupSelected: true,
          isProfileSelected: false),
      body: isLoading
          ? Container(
              height: size.height,
              width: size.width,
              alignment: Alignment.center,
              child: const CircularProgressIndicator(),
            )
          : groupList.isEmpty
              ? const EmptyWidget(
                  message: "You are not a member of any group",
                  imageAsset: 'no_groups.png')
              : ListView.builder(
                  itemCount: groupList.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => GroupMethods(
                            name: groupList[index]['name'],
                            id: groupList[index]['id'],
                          ),
                        ),
                      ),
                      leading: const Icon(Icons.group),
                      title: Text(groupList[index]['name']),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => CreateGroup(
              membersList: membersList,
            ),
          ),
        ),
        tooltip: "Create Group",
        child: const Icon(Icons.add),
        backgroundColor: const Color(0xFFee7b64),
      ),
    );
  }
}
