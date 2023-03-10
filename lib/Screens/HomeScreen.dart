import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:pie_chart/pie_chart.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sizer/sizer.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../group/groups_screen.dart';
import '../widgets/widgets.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {
  Map<String, double> dataMap = {};

  List<Color> colorList = [
    const Color(0xffD95AF3),
    const Color(0xff3EE094),
    const Color(0xff3398F6),
    const Color(0xffFA4A42),
    const Color(0xffFE9539)
  ];
  final gradientList = <List<Color>>[
    [
      Color.fromARGB(255, 102, 250, 92),
      Color.fromRGBO(129, 250, 112, 1),
    ],
    [
      Color.fromARGB(255, 230, 30, 67),
      Color.fromRGBO(254, 154, 92, 1),
    ]
  ];

  FirebaseFirestore firestore = FirebaseFirestore.instance;
  FirebaseAuth auth = FirebaseAuth.instance;
  List taskID = [];
  List tasks = [];
  int flag = 0;
  DateTime today = DateTime.now();
  String? dateStr;
  String? currentTime;
  String? dateTime;
  List remainingTasks = [];
  bool isLoading = true;
  @override
  void initState() {
    super.initState();
    dateStr = today.toString().substring(0, 10);
    currentTime = DateFormat.Hm().format(today);
    dateTime = dateStr! + " " + currentTime!;
    getData();
  }

  void getData() async {
    await firestore
        .collection("users")
        .doc(auth.currentUser!.uid)
        .collection("task")
        .get()
        .then((value) {
      setState(() {
        for (int i = 0; i < value.docs.length; i++) {
          taskID.add(value.docs[i]['id']);
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
    double ctp = ((tasks.length - remainingTasks.length) / tasks.length) * 100;
    double rtp = (remainingTasks.length / tasks.length) * 100;
    dataMap = {"Completed Tasks": ctp, "Remaining Tasks": rtp};
    isLoading = false;
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        backgroundColor: const Color(0xFFee7b64),
        title: const Text("Home"),
      ),
      drawer: showDrawer(
          isHomeSelected: true,
          isGroupSelected: false,
          isProfileSelected: false),
      body: !isLoading
          ? SingleChildScrollView(
              child: Column(
                children: [
                  Container(
                    color: Colors.grey.withOpacity(.1),
                    height: 6.h,
                    width: size.width,
                    child: Align(
                        alignment: Alignment.centerLeft,
                        child: Padding(
                          padding: const EdgeInsets.only(left: 1.6),
                          child: Center(
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                'My Summary',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyText1!
                                    .copyWith(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 15.sp),
                              ),
                            ),
                          ),
                        )),
                  ),
                  Padding(
                    padding: EdgeInsets.all(16.0),
                    child: SizedBox(
                      child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            HomeTaskCountCard(
                                size: size,
                                count: remainingTasks.length,
                                desc: 'Remaining Tasks',
                                image: 'dots.png',
                                color: Color.fromARGB(255, 49, 142, 223)),
                            HomeTaskCountCard(
                              size: size,
                              count: tasks.length - remainingTasks.length,
                              desc: 'Completed Tasks',
                              image: 'layers.png',
                              color: const Color(0xff4caf50),
                            ),
                          ]),
                    ),
                  ),
                  SizedBox(
                    height: 1.h,
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: PieChart(
                      dataMap: dataMap,
                      colorList: colorList,
                      chartRadius: MediaQuery.of(context).size.width / 1.5,
                      ringStrokeWidth: 24,
                      animationDuration: const Duration(seconds: 3),
                      chartValuesOptions: const ChartValuesOptions(
                          showChartValues: true,
                          showChartValuesOutside: true,
                          showChartValuesInPercentage: true,
                          showChartValueBackground: false),
                      gradientList: gradientList,
                      legendOptions: LegendOptions(
                          showLegendsInRow: false,
                          legendShape: BoxShape.circle,
                          legendTextStyle: TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                          showLegends: true,
                          legendPosition: LegendPosition.bottom),
                    ),
                  ),
                ],
              ),
            )
          : Container(
              height: size.height,
              width: size.width,
              alignment: Alignment.center,
              child: CircularProgressIndicator()),
      floatingActionButton: FloatingActionButton(
        child: Icon(
          Icons.group,
          size: 25.sp,
        ),
        backgroundColor: const Color(0xFFee7b64),
        onPressed: () => Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => const GroupScreen(),
          ),
        ),
      ),
    );
  }
}

class HomeTaskCountCard extends StatelessWidget {
  const HomeTaskCountCard({
    Key? key,
    required this.size,
    required this.desc,
    required this.count,
    required this.image,
    this.color,
  }) : super(key: key);

  final Size size;
  final String desc;
  final int? count;
  final String image;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: color!.withOpacity(.4),
      elevation: 0.5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: SizedBox(
        height: 20.0.h,
        width: 42.w,
        child: Stack(
          children: [
            Positioned(
                top: 2,
                child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.asset(
                      'assets/$image',
                      fit: BoxFit.cover,
                    ))),
            Positioned(
                child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Container(
                height: 20.h,
                width: 42.w,
                color: Colors.black87.withOpacity(.3),
              ),
            )),
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Center(
                    child: Text(
                      desc,
                      style: Theme.of(context).textTheme.bodyText1!.copyWith(
                          fontWeight: FontWeight.normal,
                          color: Colors.white,
                          fontSize: 13.sp),
                    ),
                  ),
                  Center(
                    child: Text(
                      '$count',
                      style: Theme.of(context).textTheme.headline4!.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          fontSize: 25.sp),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
