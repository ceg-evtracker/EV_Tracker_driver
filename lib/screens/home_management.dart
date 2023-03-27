import 'package:ceg_ev_driver/main.dart';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:location/location.dart';
import 'package:mapbox_gl/mapbox_gl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../helpers/shared_prefs.dart';
import 'package:web_socket_channel/io.dart';
import 'package:http/http.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'login_screen.dart';


DateTime now = DateTime.now();
String formattedTime = DateFormat.Hm().format(now);

class HomeManagement extends StatefulWidget {
  const HomeManagement({Key? key}) : super(key: key);

  @override
  State<HomeManagement> createState() => _HomeManagementState();
}

class _HomeManagementState extends State<HomeManagement> {
  String? _message;
  bool _isSending = false;
  LatLng latLng = getLatLngFromSharedPrefs();
  LatLng loc = getLatLngFromSharedPrefs();
  late CameraPosition _initialCameraPosition;
  late CameraPosition _currentCameraPosition;
  late MapboxMapController _mapController;
  IOWebSocketChannel? channel;
  Location _location = Location();
  LocationData? _locationData;

  List<LatLng> _points = [
    LatLng(13.008382, 80.235081),
    LatLng(13.009973, 80.235344),
    LatLng(13.010093, 80.235494),
    LatLng(13.010668, 80.235612),
    LatLng(13.010574, 80.236342),
    LatLng(13.013759, 80.236793)
    ];

     List<LatLng> _points1 = [
    LatLng(13.008345, 80.234994),
    LatLng(13.009930, 80.235213),
    LatLng(13.010045, 80.235169),
    LatLng(13.010066, 80.235094),
    LatLng(13.010129, 80.235067),
    LatLng(13.010725, 80.235180),
    LatLng(13.010829, 80.234461),
    LatLng(13.010934, 80.233682),
    LatLng(13.011153, 80.232395),
    LatLng(13.011023, 80.231623),
    LatLng(13.010699, 80.231553)
    ];

List<LatLng> _points2 = [
    LatLng(13.010706, 80.235397),  
    LatLng(13.010829, 80.234461),
    LatLng(13.014327, 80.235126),
    LatLng(13.014109, 80.236849),
    LatLng(13.013753, 80.236801)
    ];

String _buttonText = 'Start';
    void _onButtonPressed() {
      if(_buttonText == 'Start'){
    setState(() {
      _buttonText = 'End'; // change text when FAB is pressed
    });
      }
      else {
        setState(() {
      _buttonText = 'Start'; // change text when FAB is pressed
    });
      }
  }

  @override
  void initState() {
    super.initState();
    _initialCameraPosition = CameraPosition(target: latLng, zoom: 15);
    channel = IOWebSocketChannel.connect('ws://10.0.2.2:3000');
  }

  _onMapCreated(MapboxMapController controller) async {
    this._mapController = controller;
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

      _currentCameraPosition = CameraPosition(target: loc, zoom: 15);
      msg = "H1:" + loc.toString();
      channel?.sink.add(msg);
    });
  }

  void _stopSending() {
    setState(() {
      _isSending = false;
    });
  }

  void sendMsg(msg) {
    // IOWebSocketChannel? channel;
    // try {
    //   print(_message);
    //   // Connect to our backend.
    //   channel = IOWebSocketChannel.connect('ws://10.0.2.2:3000');
    // } catch (e) {
    //   // If there is any error that might be because you need to use another connection.
    //   print("Error on connecting to websocket: " + e.toString());
    // }
    // Send message to backend
    // channel?.sink.add(msg);

    // Listen for any message from backend
    channel?.stream.listen((event) {
      // Just making sure it is not empty
      if (event!.isNotEmpty) {
        print(event);
        // Now only close the connection and we are done here!
        channel!.sink.close();
      }
    });
  }
  _onStyleLoadedCallback() async {
    if(DateTime.now().hour >= 16 && DateTime.now().hour < 18) {
    _mapController.addLine(LineOptions(
      geometry: _points, // Use the stored points to draw the line
      lineColor: 'red',
      lineOpacity: 1.0,
      lineWidth: 3.0,
    )); }
    else if(DateTime.now().hour >= 18 && DateTime.now().hour <= 20){
    _mapController.addLine(LineOptions(
      geometry: _points1, // Use the stored points to draw the line
      lineColor: 'blue',
      lineOpacity: 1.0,
      lineWidth: 3.0,
    )); }
    else {
    _mapController.addLine(LineOptions(
      geometry: _points2, // Use the stored points to draw the line
      lineColor: 'black',
      lineOpacity: 1.0,
      lineWidth: 3.0,
    )); }
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
            ),
          ),
          Column(children: <Widget>[
        Expanded(
            child: Align(
                alignment: Alignment.bottomCenter,
                child: ElevatedButton(
                    onPressed: () async {
                      final prefs = await SharedPreferences.getInstance();
                    prefs.setBool('isLoggedIn',false);
                    logout(context);
                    }, child: const Text('Logout'))))
      ]),
        ],
        
      )
      ),
      floatingActionButton: Stack(
        children: <Widget>[
           FloatingActionButton(
        onPressed: () {
          _onButtonPressed();
          _message = "Hello World!";
          _message = latLng.toString();
          // LatLng latLng = getLatLngFromSharedPrefs();
          // sendMsg(latLng);
          if (_message!.isNotEmpty) {
            if (_isSending == false) {
              _isSending = true;
              _startSending();
            } else {
              _isSending = false;
              _stopSending();
            }
            // sendMsg(_message);
          }
          _mapController.animateCamera(
              CameraUpdate.newCameraPosition(_currentCameraPosition));
        },
        child: const Icon(Icons.my_location),
      ),
      Positioned(
            bottom: 40.0,
            left: 13.0,
            child: Text(
              _buttonText,
              style: const TextStyle(
                fontSize: 18.0,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
      
    );
  }
  Future<void> logout(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => LoginScreen()));
  }
}