import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoder/geocoder.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MyApp> {
  static String _homeloc = "Searching...";
  static String _currentAdd;
  static double restlat, restlon;
  static double latitude = 6.4676929;
  static double longitude = 100.5067673;
  static Completer<GoogleMapController> _controller = Completer();
  static Position _currentPosition;
  static GoogleMapController gmcontroller;
  static CameraPosition _home;
  static MarkerId markerId1 = MarkerId("12");
  static Set<Marker> markers = Set();
  static CameraPosition _userpos;
  static String gmaploc = "";

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: mappage(),
    );
  }
}

class mappage extends StatefulWidget {
  @override
  _mappagestate createState() => _mappagestate();
}

class _mappagestate extends State<mappage> {
  @override
  Widget build(BuildContext context) {
    double alheight = MediaQuery.of(context).size.height;
    try {
      _MapScreenState._userpos = CameraPosition(
        target: LatLng(_MapScreenState.latitude, _MapScreenState.longitude),
        zoom: 17,
      );
      return MaterialApp(
          theme: new ThemeData(primarySwatch: Colors.amber),
          debugShowCheckedModeBanner: false,
          home: Scaffold(
              resizeToAvoidBottomPadding: false,
              appBar: AppBar(
                title: Text('Select Your Location'),
              ),
              body: Center(
                  child: Padding(
                      padding: EdgeInsets.fromLTRB(10, 10, 10, 15),
                      child: SingleChildScrollView(
                        child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            mainAxisSize: MainAxisSize.max,
                            children: [
                              Container(
                                height: alheight - 300,
                                child: GoogleMap(
                                    mapType: MapType.normal,
                                    initialCameraPosition: CameraPosition(
                                      target: LatLng(6.4676929, 100.5067673),
                                      zoom: 17,
                                    ),
                                    markers: _MapScreenState.markers.toSet(),
                                    onMapCreated: (controller) {
                                      _MapScreenState._controller
                                          .complete(controller);
                                    },
                                    onTap: (newLatLng) {
                                      _loadLoc(newLatLng, setState);
                                    }),
                              ),
                              SizedBox(height: 10),
                              Stack(
                                children: [
                                  Center(
                                    child: Container(
                                      height: 140,
                                      width: 320,
                                    ),
                                  ),
                                  Column(
                                    children: [
                                      Container(
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: [
                                            Center(
                                              child: Container(
                                                child: Text("Address: ",
                                                    style: TextStyle(
                                                        color: Colors.black,
                                                        fontSize: 16,
                                                        fontWeight:
                                                            FontWeight.bold)),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Container(
                                        padding:
                                            EdgeInsets.fromLTRB(5, 2, 0, 0),
                                        child: Text(
                                          _MapScreenState._currentAdd
                                              .toString(),
                                          style: TextStyle(
                                              color: Colors.black,
                                              fontSize: 16),
                                        ),
                                      ),
                                      SizedBox(height: 10),
                                      Container(
                                        child: Text(
                                          "Current latitude: ",
                                          style: TextStyle(
                                              color: Colors.black,
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                      Container(
                                        child: Text(
                                          _MapScreenState.latitude.toString(),
                                          style: TextStyle(
                                            color: Colors.black,
                                          ),
                                        ),
                                      ),
                                      SizedBox(height: 10),
                                      Container(
                                        child: Text(
                                          "Current longitude: ",
                                          style: TextStyle(
                                              color: Colors.black,
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                      Container(
                                        child: Text(
                                          _MapScreenState.longitude.toString(),
                                          style: TextStyle(
                                            color: Colors.black,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ]),
                      )))));
    } catch (e) {
      print(e);
    }
  }

  _getLocationfromlatlng(double lat, double lng, setState) async {
    final Geolocator geolocator = Geolocator()
      ..placemarkFromCoordinates(lat, lng);
    _MapScreenState._currentPosition = await geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    final coordinates = new Coordinates(lat, lng);
    var addresses =
        await Geocoder.local.findAddressesFromCoordinates(coordinates);
    var first = addresses.first;
    setState(() {
      _MapScreenState._currentAdd = first.addressLine;
      print("${first.addressLine}");
      if (_MapScreenState._currentAdd != null) {
        _MapScreenState.latitude = lat;
        _MapScreenState.longitude = lng;
        return;
      }
    });
    print("${first.featureName} : ${first.addressLine}");
  }

  Future<void> _getLocation() async {
    try {
      final Geolocator geolocator = Geolocator()..forceAndroidLocationManager;
      geolocator
          .getCurrentPosition(desiredAccuracy: LocationAccuracy.best)
          .then((Position position) async {
        _MapScreenState._currentPosition = position;
        if (_MapScreenState._currentPosition != null) {
          final coordinates = new Coordinates(
              _MapScreenState._currentPosition.latitude,
              _MapScreenState._currentPosition.longitude);
          var addresses =
              await Geocoder.local.findAddressesFromCoordinates(coordinates);

          setState(() {
            var first = addresses.first;
            _MapScreenState._currentAdd = first.addressLine;
            print("${first.addressLine}");

            if (_MapScreenState._currentAdd != null) {
              _MapScreenState.latitude =
                  _MapScreenState._currentPosition.latitude;
              _MapScreenState.longitude =
                  _MapScreenState._currentPosition.longitude;
              return;
            }
          });
        }
      }).catchError((e) {
        print(e);
      });
    } catch (exception) {
      print(exception.toString());
    }
  }

  void _loadLoc(LatLng loc, setState) async {
    setState(() {
      print("insetstate");
      _MapScreenState.markers.clear();
      _MapScreenState.latitude = loc.latitude;
      _MapScreenState.longitude = loc.longitude;
      _getLocationfromlatlng(
          _MapScreenState.latitude, _MapScreenState.longitude, setState);
      _MapScreenState._home = CameraPosition(
        target: loc,
        zoom: 17,
      );
      _MapScreenState.markers.add(Marker(
        markerId: _MapScreenState.markerId1,
        position: LatLng(_MapScreenState.latitude, _MapScreenState.longitude),
        infoWindow: InfoWindow(
          title: 'New Location',
          snippet: 'New Map Location',
        ),
        icon:
            BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueMagenta),
      ));
    });
    _MapScreenState._userpos = CameraPosition(
      target: LatLng(_MapScreenState.latitude, _MapScreenState.longitude),
      zoom: 17,
    );
    _newhomeLocation();
  }

  Future<void> _newhomeLocation() async {
    _MapScreenState.gmcontroller = await _MapScreenState._controller.future;
    _MapScreenState.gmcontroller
        .animateCamera(CameraUpdate.newCameraPosition(_MapScreenState._home));
  }
}
