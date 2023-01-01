import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';

class HomeScreen extends StatefulWidget {
  static const String routName = 'home';

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getCurrentLocation();
  }
  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    streamSubscription?.cancel();
  }

  final Completer<GoogleMapController> _controller =
      Completer<GoogleMapController>();

  static const CameraPosition RoutLocation = CameraPosition(
    target: LatLng(30.035863, -31.1965055),
    zoom: 14.4746,
  );

  Set<Marker>markers={};

// bydefult google maps
  // static const CameraPosition _kLake = CameraPosition(
  //     bearing: 192.8334901395799,
  //     target: LatLng(37.43296265331129, -122.08832357078792),
  //     tilt: 59.440717697143555,
  //     zoom: 19.151926040649414);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: permissionStatus == PermissionStatus.deniedForever
            ? Text('opern your location')
            : Text(
                'GPS',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
      ),
      body: GoogleMap(
        mapType: MapType.hybrid,
        initialCameraPosition:
            MyCurrentLocation == null ? RoutLocation : MyCurrentLocation!,
        markers:markers ,
        onMapCreated: (GoogleMapController controller) {
          _controller.complete(controller);
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _goToTheLake,
        label: const Text('To the lake!'),
        icon: const Icon(Icons.directions_boat),
      ),
    );
  }

  Future<void> _goToTheLake() async {}

  Location location = Location();

  PermissionStatus? permissionStatus;

  bool serviceEnabled = false;

  LocationData? locationData;
  CameraPosition? MyCurrentLocation;
  double defLat=30.035863;
  double defLong=31.1965055;
  StreamSubscription<LocationData>? streamSubscription;



  void getCurrentLocation() async {
    bool permission = await IsPermissionGranted();
    if (permission = false) return;
    bool service = await IsServiseEnabled();
    if (!service) return;

    locationData = await location.getLocation();
    location.changeSettings(accuracy: LocationAccuracy.high);
    streamSubscription= location.onLocationChanged.listen((event) {
      locationData = event;
      print(
          'My location > Let :${locationData?.latitude}long:${locationData?.latitude} ');
      updateUserLocation();
    });
    Marker userMarker=Marker(markerId: MarkerId('userLocation'),
    position: LatLng(locationData?.latitude??defLat,
        locationData?.latitude??defLong)
    );
    markers.add(userMarker);
    MyCurrentLocation = CameraPosition(
        // bearing: 192.8334901395799,
        target: LatLng(locationData!.latitude!, locationData!.latitude!),
        // tilt: 59.440717697143555,
        zoom: 16.151926040649414);
  //   final GoogleMapController controller = await _controller.future;
  //   controller
  //       .animateCamera(CameraUpdate.newCameraPosition(RoutLocation));//
  //   setState(() {});
  // }
  }
  void updateUserLocation()async{
    Marker userMarker=Marker(markerId: MarkerId('userLocation'),
        position: LatLng(locationData?.latitude??defLat,
            locationData?.latitude??defLong)
    );
    markers.add(userMarker);
    final GoogleMapController controller = await _controller.future;
    controller
        .animateCamera(CameraUpdate.newCameraPosition(RoutLocation));//
    setState(() {});
  }
  Future<bool> IsServiseEnabled() async {
    serviceEnabled = await location.serviceEnabled();
    if (serviceEnabled = false) {
      serviceEnabled = await location.serviceEnabled();
      return serviceEnabled;
    } else {
      return serviceEnabled;
    }
  }

  Future<bool> IsPermissionGranted() async {
    permissionStatus = await location.hasPermission();

    if (permissionStatus == PermissionStatus.denied) {
      permissionStatus = await location.requestPermission();
      return permissionStatus == PermissionStatus.granted;
    } else if (permissionStatus == PermissionStatus.deniedForever) {
      return false;
    } else {
      return permissionStatus == PermissionStatus.granted;
    }
  }
}
