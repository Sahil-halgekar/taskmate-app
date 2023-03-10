import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sizer/sizer.dart';
import 'package:taskmate/widgets/widgets.dart';
import 'package:flutter/material.dart';

class ProfileScreen extends StatefulWidget {
  String userName;
  String email;
  ProfileScreen({Key? key, required this.email, required this.userName})
      : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  bool imageAvailable = false;
  final CollectionReference _reference =
      FirebaseFirestore.instance.collection('users');
  String imageUrl = '';
  Map<String, dynamic>? userMap;
  List groupList = [];
  Map<String, dynamic>? g;
  @override
  void initState() {
    super.initState();
    getdata();
  }

  void getdata() async {
    await firestore
        .collection('users')
        .where('uid', isEqualTo: _auth.currentUser!.uid)
        .get()
        .then((value) {
      userMap = value.docs[0].data();
      imageUrl = (userMap!['profileImg']);
    });
    setState(() {
      if (imageUrl != '') {
        imageAvailable = true;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFee7b64),
        elevation: 0,
        centerTitle: true,
        title: const Text(
          "Profile",
          style: TextStyle(
              color: Colors.white, fontSize: 27, fontWeight: FontWeight.bold),
        ),
      ),
      drawer: showDrawer(
        isHomeSelected: false,
        isGroupSelected: false,
        isProfileSelected: true,
      ),
      body: Container(
        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 80),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            CircleAvatar(
              radius: 50.sp,
              backgroundImage: imageAvailable
                  ? NetworkImage(imageUrl)
                  : const AssetImage('assets/user.png') as ImageProvider,
              backgroundColor: Colors.blueAccent,
              child: Stack(children: [
                Align(
                  alignment: Alignment.bottomRight,
                  child: GestureDetector(
                    onTap: () async {
                      ImagePicker imagePicker = ImagePicker();
                      XFile? file = await imagePicker.pickImage(
                          source: ImageSource.gallery);
                      if (file == null) return;
                      String uniqueFileName =
                          DateTime.now().millisecondsSinceEpoch.toString();
                      Reference referenceRoot = FirebaseStorage.instance.ref();
                      Reference referenceDirImages =
                          referenceRoot.child('profileImages');
                      Reference referenceImageToUpload =
                          referenceDirImages.child(uniqueFileName);
                      try {
                        await referenceImageToUpload.putFile(File(file.path));
                        imageUrl =
                            await referenceImageToUpload.getDownloadURL();
                        await FirebaseFirestore.instance
                            .collection('users')
                            .doc(_auth.currentUser!.uid)
                            .set({'profileImg': imageUrl},
                                SetOptions(merge: true));

                        getdata();
                      } catch (error) {
                        showSnackbar(context, Colors.red, "Image upload error");
                      }
                    },
                    child: CircleAvatar(
                      radius: 18.sp,
                      backgroundColor: Colors.blueGrey,
                      child: Icon(CupertinoIcons.camera),
                    ),
                  ),
                ),
              ]),
            ),
            const SizedBox(
              height: 15,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Full Name", style: TextStyle(fontSize: 14.sp)),
                Text(widget.userName, style: TextStyle(fontSize: 14.sp)),
              ],
            ),
            const Divider(
              height: 20,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Email", style: TextStyle(fontSize: 14.sp)),
                Text(widget.email, style: TextStyle(fontSize: 14.sp)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
