import 'dart:async';
import 'package:earth_quake_app/model/earth_quake_model.dart';
import 'package:earth_quake_app/network/network.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

/// Map screen
class MapScreen extends StatefulWidget {
  @override
  _MapScreenWidgetState createState() => _MapScreenWidgetState();
}

/// Map screen widget state
class _MapScreenWidgetState extends State<MapScreen> {
  Completer<GoogleMapController> _controller = Completer();
  static LatLng _center = LatLng(22.719568, 75.857727);
  static double _zoomVal = 3.0;
  static CameraPosition _cameraPosition = CameraPosition(
    target: _center,
    zoom: _zoomVal,
  );
  Future<EarthQuakeModel> earthQuakeData;
  Set<Marker> earthQuakeMarkers = new Set<Marker>();

  @override
  void initState() {
    super.initState();
    earthQuakeData = Network().getEarthQuakes();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [_buildGoogleMap(context), _zoomPlus(), _zoomMinus()],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          findQuakes();
        },
        backgroundColor: Colors.green,
        label: Text("Find Quakes"),
      ),
    );
  }

  Widget _buildGoogleMap(BuildContext context) {
    return (Container(
      height: MediaQuery.of(context).size.height,
      width: MediaQuery.of(context).size.width,
      child: GoogleMap(
        mapType: MapType.normal,
        initialCameraPosition: _cameraPosition,
        onMapCreated: (GoogleMapController controller) {
          _controller.complete(controller);
        },
        myLocationButtonEnabled: false,
        markers: earthQuakeMarkers,
        onCameraMove: (CameraPosition _newCameraPosition) {
          updateCameraPosition(_newCameraPosition);
        },
      ),
    ));
  }

  updateCameraPosition(CameraPosition _newCameraPosition) {
    setState(() {
      _cameraPosition = _newCameraPosition;
      _center = _newCameraPosition.target;
    });
  }

  void findQuakes() {
    setState(() {
      earthQuakeMarkers.clear();
      handleResponse();
      resetMap();
    });
  }

  void resetMap() async {
    setState(() {
      _center = LatLng(22.719568, 75.857727);
      _zoomVal = 3.0;
      _cameraPosition = CameraPosition(
        target: _center,
        zoom: _zoomVal,
      );
    });
    final GoogleMapController controller = await _controller.future;
    controller.animateCamera(CameraUpdate.newCameraPosition(
        CameraPosition(target: _center, zoom: _zoomVal)));
  }

  void handleResponse() {
    setState(() {
      earthQuakeData.then((quakes) {
        quakes.features.forEach((quake) {
          LatLng currentQuakeCoords = LatLng(
              quake.geometry.coordinates[1], quake.geometry.coordinates[0]);
          earthQuakeMarkers.add(Marker(
            markerId: MarkerId(quake.id),
            position: currentQuakeCoords,
            infoWindow: InfoWindow(
                title: quake.properties.place,
                snippet:
                    'mag: ${quake.properties.mag}\ntime: ${new DateTime.fromMillisecondsSinceEpoch(quake.properties.time)}'),
            icon: BitmapDescriptor.defaultMarkerWithHue(
                BitmapDescriptor.hueMagenta),
          ));
        });
      });
    });
  }

  Widget _zoomPlus() {
    return Padding(
      padding: EdgeInsets.only(top: 38),
      child: Align(
        alignment: Alignment.topRight,
        child: IconButton(
            icon: Icon(
              FontAwesomeIcons.searchPlus,
              color: Colors.black87,
            ),
            onPressed: () {
              if (_zoomVal < 14) {
                _zoomVal++;
                _plus(_zoomVal);
              }
            }),
      ),
    );
  }

  Widget _zoomMinus() {
    return Padding(
      padding: const EdgeInsets.only(top: 38.0),
      child: Align(
        alignment: Alignment.topLeft,
        child: IconButton(
          onPressed: () {
            if (_zoomVal > 2) {
              _zoomVal--;
              _minus(_zoomVal);
            }
          },
          icon: Icon(
            FontAwesomeIcons.searchMinus,
            color: Colors.black87,
          ),
        ),
      ),
    );
  }

  Future<void> _minus(double zoomVal) async {
    final GoogleMapController controller = await _controller.future;
    controller.animateCamera(CameraUpdate.newCameraPosition(
        CameraPosition(target: _center, zoom: zoomVal)));
  }

  Future<void> _plus(double zoomVal) async {
    final GoogleMapController controller = await _controller.future;
    controller.animateCamera(CameraUpdate.newCameraPosition(
        CameraPosition(target: _center, zoom: zoomVal)));
  }
}
