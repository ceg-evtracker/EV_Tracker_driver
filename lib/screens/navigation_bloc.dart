import 'package:bloc/bloc.dart';

import 'login_screen.dart';
import 'home_management.dart';

enum NavigationEvents {
  HomeManagementClickedEvent,
  MyAccountClickedEvent,
}

abstract class NavigationStates {}

class NavigationBloc extends Bloc<NavigationEvents, NavigationStates> {
  NavigationBloc() : super(HomeManagement());

  @override
  HomeManagement get initialState => const HomeManagement();

  @override
  Stream<NavigationStates> mapEventToState(NavigationEvents event) async* {
    switch (event) {
      case NavigationEvents.HomeManagementClickedEvent:
        yield HomeManagement();
        break;
      case NavigationEvents.MyAccountClickedEvent:
        yield LoginScreen();
        break;
    }
  }
}
