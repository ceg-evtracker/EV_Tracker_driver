import 'dart:async';

import 'package:ceg_ev_driver/screens/home_management.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rxdart/rxdart.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../main.dart';
import '../model/user_model.dart';
import 'login_screen.dart';
import 'sidebar_layout.dart';
import 'navigation_bloc.dart';

class SideBar extends StatefulWidget {

  @override
  _SideBarState createState() => _SideBarState();
}

class _SideBarState extends State<SideBar> with SingleTickerProviderStateMixin<SideBar>{
  User? EV_Number = FirebaseAuth.instance.currentUser;
  UserModel loggedInUser = UserModel();
  late AnimationController _animationController;
  late StreamController<bool> isSidebarOpenedStreamController;
  late Stream<bool> isSidebarOpenedStream;
  late StreamSink<bool> isSidebarOpenedSink;
  final _animationDuration = const Duration(milliseconds: 500);
  

  @override
  void initState() {
    super.initState();
    
    FirebaseFirestore.instance
        .collection("EV_Number")
        .doc(EV_Number?.uid)
        .get()
        .then((value) {
      this.loggedInUser = UserModel.fromMap(value.data());
      setState(() {});
    });
    _animationController = AnimationController(vsync: this,duration: _animationDuration);
    isSidebarOpenedStreamController = PublishSubject<bool>();
    isSidebarOpenedStream = isSidebarOpenedStreamController.stream;
    isSidebarOpenedSink = isSidebarOpenedStreamController.sink;

  }
  

  @override
 
  void dispose() {
    _animationController.dispose();
    isSidebarOpenedStreamController.close();
    isSidebarOpenedSink.close();
    super.dispose();
  }

   void onIconPressed(){
    final animationStatus = _animationController.status;
    final isAnimationCompleted = animationStatus == AnimationStatus.completed;

    if(isAnimationCompleted) {
      isSidebarOpenedSink.add(false);
      _animationController.reverse();
    }
    else{
      isSidebarOpenedSink.add(true);
      _animationController.forward();

    }
   }
  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return StreamBuilder<bool>(
      initialData: false,
      stream: isSidebarOpenedStream,
      builder: (context, isSidebarOpenedAsync) {
        return AnimatedPositioned(
      duration: _animationDuration,
      top: 0,
      bottom: 0,
      left: isSidebarOpenedAsync.data! ? 0 : -screenWidth,
      right: isSidebarOpenedAsync.data! ? 110 : screenWidth - 44,
      child: Row(
      children: <Widget>[
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal:20),
              color: Color.fromARGB(255, 201, 225, 243),
              child: Column(
                children: <Widget>[
                  SizedBox(height: 100,),
                  ListTile(
                    title: Text(
                      "${loggedInUser.id}",
                      style: TextStyle(color: Colors.black, fontSize: 20, fontWeight: FontWeight.w800),
                    ),
                    leading: CircleAvatar(
                      backgroundColor: Color.fromARGB(255, 66, 42, 42),
                      child: Icon(
                        Icons.person,
                        color: Colors.white,
                      ),
                      radius: 45,
                    ),
                  ),
                  Divider(
                    height: 64,
                    thickness: 1.0,
                    color: Colors.black,
                    indent: 32,
                    endIndent: 32,                     
                  ),
                  Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Positioned(
      top: 0,
      child: Icon(
        Icons.home,
        size: 30,
        color: Colors.black,
      ),
    ),
              GestureDetector(
                onTap:() {
                  Navigator.push(
                    context, 
                    MaterialPageRoute(
                      builder: (context) {
                        return SideBarLayout();
                      },
                    ),
                    );
                },
              child: Text(
                '\n      Home\n',
              style: TextStyle(
                color: Colors.black,
                fontSize: 30.0,
                fontWeight: FontWeight.w400,
              ),
              ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
               Positioned(
      top: 0,
      child: Icon(
        Icons.exit_to_app,
        size: 30,
        color: Colors.black,
      ),
    ),
              GestureDetector(
                onTap: ()async {
                      final prefs = await SharedPreferences.getInstance();
                    prefs.setBool('isLoggedIn',false);
                    logout(context);
                },
              child: Text(
                '      Logout',
              style: TextStyle(
                color: Colors.black,
                fontSize: 30.0,
                fontWeight: FontWeight.w400,
              ),
              ),
              ),
            ],
          ),
        ),
                 /* MenuItem(
                    icon: Icons.home,
                    title: "Home",
                    onTap: () {
                          onIconPressed() async {
                          BlocProvider.of<NavigationBloc>(context).add(NavigationEvents.HomeManagementClickedEvent);
                          }
                        },
                  ),
                  MenuItem(
                    icon: Icons.exit_to_app,
                    title: "Logout",
                    onTap: () {
                          onIconPressed() async {
                          BlocProvider.of<NavigationBloc>(context).add(NavigationEvents.HomeManagementClickedEvent);
                          }
                        },
                  ),*/
                ]),
          ),
          ),
          Align(
            alignment: Alignment(0, -0.9),
            child: GestureDetector(
              onTap: () {
                onIconPressed();
              },
            child: ClipPath(
              clipper: CustomMenuClipper(),
            child: Container(
              width: 35,
              height: 110,
              color: Color.fromARGB(255, 201, 225, 243),
              alignment: Alignment.centerLeft,
              child: AnimatedIcon(
                progress: _animationController.view,
                icon: AnimatedIcons.menu_close,
                color: Colors.black87,
                size: 25,
              )
            ),
            ),
            ),
          )
      ],
    ),
    );
      },
    );
  }
}

 Future<void> logout(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    Navigator.of(context).push(
        MaterialPageRoute(builder: (context) => LoginScreen()));
  }


class CustomMenuClipper extends CustomClipper<Path>{
  @override
  Path getClip(Size size) {
    Paint paint = Paint();
    paint.color = Colors.white; 
    final width = size.width;
    final height = size.height;
    Path path = Path();
    path.moveTo(0,0);
    path.quadraticBezierTo(0, 8, 10, 16);
    path.quadraticBezierTo(width-1, height/2-20, width, height/2);
    path.quadraticBezierTo(width+1, height/2+20, 10, height-16);
    path.quadraticBezierTo(0, height-8, 0, height);
    path.close();
    
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) {
    
    return true;
  }
  
}

/*class MenuItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final Function onTap;

  const MenuItem({Key? key, required this.icon, required this.title, required this.onTap}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
  
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: <Widget>[
            Icon(
              icon,
              color: Colors.cyan,
              size: 30,
            ),
            SizedBox(
              width: 20,
            ),
            Text(
              title,
              style: TextStyle(fontWeight: FontWeight.w300, fontSize: 26, color: Colors.white),
            )
          ],
        ),
      ),
    );
  }
}*/