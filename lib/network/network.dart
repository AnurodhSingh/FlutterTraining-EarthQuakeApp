import 'dart:convert';
import 'package:http/http.dart';
import 'package:earth_quake_app/model/earth_quake_model.dart';

class Network {
  Future<EarthQuakeModel> getEarthQuakes() async {
    final apiUrl =
        'https://earthquake.usgs.gov/earthquakes/feed/v1.0/summary/1.0_day.geojson';

    final response = await get(Uri.encodeFull(apiUrl));
    if (response.statusCode == 200) {
      return EarthQuakeModel.fromJson(json.decode(response.body));
    } else {
      throw Exception('Error getting earth quakes data.');
    }
  }
}
