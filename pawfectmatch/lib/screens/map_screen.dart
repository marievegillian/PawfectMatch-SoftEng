import 'dart:math';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({Key? key}) : super(key: key);

  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  late GoogleMapController mapController;
  LatLng? userLocation;
  List<Marker> randomMarkers = [];

  @override
  void initState() {
    super.initState();
    _requestLocationPermission();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pawfriends Nearby', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: GoogleMap(
        onMapCreated: _onMapCreated,
        initialCameraPosition: CameraPosition(
          target: userLocation ?? LatLng(10.3157, 123.8854), // Cebu's coordinates
          zoom: 12.0,
        ),
        myLocationButtonEnabled: true,
        myLocationEnabled: true,
        markers: {...?userLocation != null ? randomMarkers.toSet() : {}},
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if (userLocation != null) {
            _goToUserLocation();
          }
        },
        tooltip: 'Go to User Location',
        child: const Icon(Icons.my_location),
      ),
    );
  }

  void _onMapCreated(GoogleMapController controller) {
    setState(() {
      mapController = controller;
    });
  }

  void _requestLocationPermission() async {
    try {
      print('Requesting location permission...');
      // Check if permission is granted
      PermissionStatus status = await Permission.location.request();

      if (status == PermissionStatus.granted) {
        // Permission granted, get current location
        print('Location permission granted. Getting current location...');
        _getCurrentLocation();
      } else {
        // Permission denied, handle accordingly (show a message, etc.)
        print('Location permission denied');
      }
    } catch (e) {
      print('Error requesting location permission: $e');
    }
  }

  void _getCurrentLocation() async {
    try {
      print('Getting current location...');
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      setState(() {
        userLocation = LatLng(position.latitude, position.longitude);
        // Generate random markers nearby user's location
        randomMarkers = _generateRandomMarkers(userLocation!, 5);
      });

      // Set initialCameraPosition to the user's location
      mapController.animateCamera(CameraUpdate.newLatLngZoom(userLocation!, 12.0));

      print('Current location: $userLocation');
    } catch (e) {
      print('Error getting current location: $e');
    }
  }

  void _goToUserLocation() {
    print('Going to user location...');
    mapController.animateCamera(CameraUpdate.newLatLngZoom(userLocation!, 12.0));
  }

  List<Marker> _generateRandomMarkers(LatLng center, int count) {
    List<Marker> markers = [];

    for (int i = 0; i < count; i++) {
      // Generate random coordinates nearby the center
      double lat = center.latitude + Random().nextDouble() * 0.02 - 0.01;
      double lng = center.longitude + Random().nextDouble() * 0.02 - 0.01;

      markers.add(
        Marker(
          markerId: MarkerId('random_$i'),
          position: LatLng(lat, lng),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
          infoWindow: const InfoWindow(title: 'Random Marker'),
        ),
      );
    }

    return markers;
  }
}

void main() {
  runApp(const MaterialApp(
    home: MapScreen(),
  ));
}