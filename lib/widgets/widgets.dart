import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:taskmate/Screens/ProfileScreen.dart';

import '../Authenticate/LoginScreen.dart';
import '../Authenticate/Methods.dart';
import '../Screens/HomeScreen.dart';
import '../group/groups_screen.dart';

final FirebaseAuth _auth = FirebaseAuth.instance;
const textInputDecoration = InputDecoration(
  labelStyle: TextStyle(color: Colors.black, fontWeight: FontWeight.w300),
  focusedBorder: OutlineInputBorder(
    borderSide: BorderSide(color: Color(0xFFee7b64), width: 2),
  ),
  enabledBorder: OutlineInputBorder(
    borderSide: BorderSide(color: Color(0xFFee7b64), width: 2),
  ),
  errorBorder: OutlineInputBorder(
    borderSide: BorderSide(color: Color(0xFFee7b64), width: 2),
  ),
);

void nextScreen(context, page) {
  Navigator.push(context, MaterialPageRoute(builder: (context) => page));
}

void nextScreenReplace(context, page) {
  Navigator.pushReplacement(
      context, MaterialPageRoute(builder: (context) => page));
}

void showSnackbar(context, color, message) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(
        message,
        style: const TextStyle(fontSize: 14),
      ),
      backgroundColor: color,
      duration: const Duration(seconds: 2),
      action: SnackBarAction(
        label: "OK",
        onPressed: () {},
        textColor: Colors.white,
      ),
    ),
  );
}

class showDrawer extends StatefulWidget {
  bool isHomeSelected;
  bool isGroupSelected;
  bool isProfileSelected;
  showDrawer(
      {super.key,
      required this.isHomeSelected,
      required this.isGroupSelected,
      required this.isProfileSelected});

  @override
  State<showDrawer> createState() => _showDrawerState();
}

class _showDrawerState extends State<showDrawer> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  bool imageAvailable = false;
  final CollectionReference _reference =
      FirebaseFirestore.instance.collection('users');
  String imageUrl = '';
  Map<String, dynamic>? userMap;
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
    return Drawer(
        child: ListView(
      padding: const EdgeInsets.symmetric(vertical: 50),
      children: <Widget>[
        CircleAvatar(
          radius: 60,
          backgroundColor: Colors.transparent,
          child: ClipOval(
            child: imageAvailable
                ? Image.network(imageUrl, width: 150, fit: BoxFit.fill)
                : Image.asset("assets/user.png"),
          ),
        ),
        const SizedBox(
          height: 15,
        ),
        Text(
          _auth.currentUser!.displayName!,
          textAlign: TextAlign.center,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(
          height: 30,
        ),
        const Divider(
          height: 2,
        ),
        ListTile(
          onTap: () {
            if (!widget.isHomeSelected)
              nextScreenReplace(context, const HomeScreen());
            else {}
          },
          selected: widget.isHomeSelected,
          selectedColor: widget.isHomeSelected ? const Color(0xFFee7b64) : null,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
          leading: const Icon(Icons.home),
          title: const Text(
            "Home",
            style: TextStyle(color: Colors.black),
          ),
        ),
        ListTile(
          onTap: () {
            if (!widget.isGroupSelected)
              nextScreenReplace(context, const GroupScreen());
            else {}
          },
          selected: widget.isGroupSelected,
          selectedColor:
              widget.isGroupSelected ? const Color(0xFFee7b64) : null,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
          leading: const Icon(Icons.group),
          title: const Text(
            "Groups",
            style: TextStyle(color: Colors.black),
          ),
        ),
        ListTile(
          onTap: () {
            if (!widget.isProfileSelected) {
              nextScreenReplace(
                  context,
                  ProfileScreen(
                    userName: _auth.currentUser!.displayName!,
                    email: _auth.currentUser!.email!,
                  ));
            } else {}
          },
          selected: widget.isProfileSelected,
          selectedColor:
              widget.isProfileSelected ? const Color(0xFFee7b64) : null,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
          leading: const Icon(Icons.person),
          title: const Text(
            "Profile",
            style: TextStyle(color: Colors.black),
          ),
        ),
        ListTile(
          onTap: () async {
            showDialog(
                barrierDismissible: false,
                context: context,
                builder: (context) {
                  return AlertDialog(
                    title: const Text("Logout"),
                    content: const Text("Are you sure you want to logout?"),
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
                          await logOut(context);
                          Navigator.of(context).pushAndRemoveUntil(
                              MaterialPageRoute(
                                  builder: (context) => const LoginScreen()),
                              (route) => false);
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
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
          leading: const Icon(Icons.exit_to_app),
          title: const Text(
            "Logout",
            style: TextStyle(color: Colors.black),
          ),
        )
      ],
    ));
    ;
  }
}

class EmptyWidget extends StatelessWidget {
  final String message;
  final String imageAsset;

  const EmptyWidget({Key? key, required this.message, required this.imageAsset})
      : super(key: key);
  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    return SizedBox(
      width: size.width,
      height: size.height / 2,
      child: Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/$imageAsset',
              width: size.width / 2,
              height: size.width / 2,
            ),
            const SizedBox(
              height: 10,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 50),
              child: Text(
                message,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyText1,
              ),
            )
          ],
        ),
      ),
    );
  }
}
