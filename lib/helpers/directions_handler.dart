import 'package:mapbox_gl/mapbox_gl.dart';
import 'package:ceg_ev_driver/main.dart';

// import '../constants/restaurants.dart';
import '../requests/mapbox_requests.dart';

Future<Map> getDirectionsAPIResponse(
    LatLng currentLatLng, LatLng destLatLng) async {
  final response = await getCyclingRouteUsingMapbox(currentLatLng, destLatLng);
  Map geometry = response['routes'][0]['geometry'];
  num duration = response['routes'][0]['duration'];
  num distance = response['routes'][0]['distance'];
  // print('-------------------${restaurants[index]['name']}-------------------');
  print(distance);
  print(duration);

  Map modifiedResponse = {
    "geometry": geometry,
    "duration": duration,
    "distance": distance,
  };
  return modifiedResponse;
}

void saveDirectionsAPIResponse(int index, String response) {
  sharedPreferences.setString('restaurant--$index', response);
}
