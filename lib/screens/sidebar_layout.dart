import 'package:ceg_ev_driver/screens/home_management.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'sidebar.dart'; 
import 'navigation_bloc.dart';
import 'package:bloc/bloc.dart';

class SideBarLayout extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocProvider<NavigationBloc>(
        create: (context) => NavigationBloc(),
        child: Stack(
          children: <Widget>[
            BlocBuilder<NavigationBloc, NavigationStates>(
              builder: (context, navigationState) {
                return navigationState as Widget;
              },
            ),
  
            SideBar(),
          ],
        ),
      ),
    );
  }
}