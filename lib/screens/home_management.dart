import 'dart:convert';

import 'package:ceg_ev_driver/main.dart';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:location/location.dart';
import 'package:mapbox_gl/mapbox_gl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../helpers/shared_prefs.dart';
import 'package:web_socket_channel/io.dart';
// import 'package:http/http.dart';

import 'dart:math' as math;

class RequestData {
  String? sender;
  double? latitude, longitude;
  RequestData({this.sender, this.latitude, this.longitude});
  Map<String, dynamic> toJson() => {
        'sender': sender,
        'latitude': latitude,
        'longitude': longitude,
      };
}

class HomeManagement extends StatefulWidget {
  const HomeManagement({Key? key}) : super(key: key);

  @override
  State<HomeManagement> createState() => _HomeManagementState();
}

class _HomeManagementState extends State<HomeManagement> {
  bool _isSending = false;
  LatLng latLng = getLatLngFromSharedPrefs();
  LatLng loc = getLatLngFromSharedPrefs();
  late CameraPosition _initialCameraPosition;
  late CameraPosition _currentCameraPosition;

  late MapboxMapController controller;
  IOWebSocketChannel? channel;

  Location _location = Location();
  LocationData? _locationData;
  Location _curLoc = Location();
  LocationData? _curLocData, _curLocData01;
  Symbol? _locationSymbol;

  LatLng prevLoc = LatLng(0.0, 0.0);
  double bearing = 0.0;
  List<Symbol> _userMarkers = [];

  StreamSubscription<LocationData>? _locationSubscription;

  @override
  void initState() {
    super.initState();
    _initialCameraPosition = CameraPosition(target: latLng, zoom: 15);
    // controller.onSymbolTapped.add(_onSymbolTapped);
    channel = IOWebSocketChannel.connect('ws://10.0.2.2:3000');
    // https://evtracker-location-service.onrender.com
    channel?.stream.listen((message) {
      final userData = json.decode(message.toString());
      final new_data = RequestData(
        sender: userData['sender'],
        latitude: userData['latitude'],
        longitude: userData['longitude'],
      );
      if (new_data.sender == 'USER') {
        _addUserMarker(new_data.latitude, new_data.longitude);
      }
    });

    _startLocationUpdates();
  }

  _addUserMarker(lat, long) async {
    LatLng userloc = LatLng(lat, long);
    Symbol userMarker = await controller.addSymbol(SymbolOptions(
      geometry: userloc,
      iconImage: "assets/icon/user_m2.png",
      iconSize: 0.175,
      iconOpacity: 1.0,

      // iconColor: '#4F936A',
    ));
    _userMarkers.add(userMarker);
    print(userMarker.options.geometry);
  }

  _printLocation(Symbol symbol) {
    if (symbol.options.textField != 'H1') {
      print(symbol.options.geometry);
    }
  }

  void _onSymbolTapped(Symbol symbol) {
    _printLocation(symbol);
  }

  _startLocationUpdates() {
    _locationSubscription = _location.onLocationChanged.listen((locationData) {
      _updateUserLocation(locationData.latitude!, locationData.longitude!);
    });
  }

  void _updateUserLocation(double lat, double lng) async {
    LatLng curLocation = LatLng(lat, lng);

    if (_locationSymbol == null) {
      _locationSymbol = await controller.addSymbol(
        SymbolOptions(
          textField: 'H1',
          geometry: LatLng(lat, lng),
          iconImage: 'assets/icon/EV_TOP.png',
          iconSize: 0.175,
          iconOpacity: 1,
          // iconRotate: bearing - 75,
        ),
      );
    } else {
      controller.updateSymbol(
        _locationSymbol!,
        SymbolOptions(
          geometry: LatLng(lat, lng),
          iconImage: 'assets/icon/EV_TOP.png',
          textField: 'H1',
        ),
      );
    }
    prevLoc = curLocation;
  }

  _onMapCreated(MapboxMapController controller) async {
    this.controller = controller;
    print('ContRoller works0\n');
    // print(LatLng(
    //   _curLocData!.latitude!.toDouble(),
    //   _curLocData!.longitude!.toDouble(),
    // ));
    // controller.animateCamera(
    //   CameraUpdate.newLatLng(
    //     LatLng(
    //       _curLocData!.latitude!.toDouble(),
    //       _curLocData!.longitude!.toDouble(),
    //     ),
    //   ),
    // );
    controller.onSymbolTapped.add(_onSymbolTapped);
  }

  @override
  void dispose() {
    _locationSubscription!.cancel();
    super.dispose();
  }

  void _startSending() {
    setState(() {
      _isSending = true;
    });
    Timer.periodic(Duration(seconds: 1), (timer) async {
      if (!_isSending) {
        timer.cancel();
        return;
      }
      String? msg;
      _locationData = await _location.getLocation();
      print(_locationData);
      loc = LatLng(_locationData!.latitude!.toDouble(),
          _locationData!.longitude!.toDouble());

      // _currentCameraPosition = CameraPosition(target: loc, zoom: 15);

      // controller.animateCamera(
      //     CameraUpdate.newCameraPosition(_currentCameraPosition));

      RequestData reqdata = RequestData(
          sender: "H1_DRIVER",
          latitude: _locationData!.latitude!.toDouble(),
          longitude: _locationData!.longitude!.toDouble());

      String jsonString = jsonEncode(reqdata);

      channel?.sink.add(jsonString);
    });
  }

  void _stopSending() {
    setState(() {
      _isSending = false;
    });
  }

  // void sendMsg(msg) {
  //   // IOWebSocketChannel? channel;
  //   // try {
  //   //   print(_message);
  //   //   // Connect to our backend.
  //   //   channel = IOWebSocketChannel.connect('ws://10.0.2.2:3000');
  //   // } catch (e) {
  //   //   // If there is any error that might be because you need to use another connection.
  //   //   print("Error on connecting to websocket: " + e.toString());
  //   // }
  //   // Send message to backend
  //   // channel?.sink.add(msg);

  //   // Listen for any message from backend
  //   channel?.stream.listen((event) {
  //     // Just making sure it is not empty
  //     if (event!.isNotEmpty) {
  //       print(event);
  //       // Now only close the connection and we are done here!
  //       channel!.sink.close();
  //     }
  //   });
  // }

  _onStyleLoadedCallback() async {
    await controller.addSymbol(
      SymbolOptions(
        geometry: LatLng(
          _curLocData!.latitude!.toDouble(),
          _curLocData!.longitude!.toDouble(),
        ),
        iconSize: 0.2,
        iconImage: "assets/icon/EV_TOP.png",
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('DRIVER APP'),
        centerTitle: true,
      ),
      body: SafeArea(
          child: Stack(
        children: [
          SizedBox(
            height: MediaQuery.of(context).size.height,
            child: MapboxMap(
              accessToken: dotenv.env['MAPBOX_ACCESS_TOKEN'],
              initialCameraPosition: _initialCameraPosition,
              onMapCreated: _onMapCreated,
              onStyleLoadedCallback: _onStyleLoadedCallback,
              myLocationEnabled: true,
              myLocationTrackingMode: MyLocationTrackingMode.TrackingGPS,
              minMaxZoomPreference: const MinMaxZoomPreference(14, 17),

              // onUserLocationUpdated: _evmarker,
            ),
          )
        ],
      )),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if (_isSending == false) {
            _isSending = true;
            _startSending();
          } else {
            _isSending = false;
            _stopSending();
          }
        },
        child: const Icon(Icons.my_location),
      ),
    );
  }
}
