import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Map & OpenRouteService Demo',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const MapScreen(),
    );
  }
}

class MapScreen extends StatefulWidget {
  const MapScreen({Key? key}) : super(key: key);

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final Completer<GoogleMapController> _controller = Completer();

  final Set<Polyline> _polylines = {};

  LatLng? _currentPosition;

  final LatLng _destination = const LatLng(34.0536909, -118.242766);

  static const CameraPosition _initialPosition = CameraPosition(
    target: LatLng(37.7749, -122.4194),
    zoom: 4,
  );

  @override
  void initState() {
    super.initState();
    _initLocationAndRoute();
  }

  /// 1. Gets location permission + current position
  /// 2. Moves the camera to the user's position
  /// 3. Fetches the route from current position to destination (OpenRouteService)
  Future<void> _initLocationAndRoute() async {
    try {
      Position position = await _determinePosition();
      _currentPosition = LatLng(position.latitude, position.longitude);

      // Move the map camera to current location
      final controller = await _controller.future;
      controller.animateCamera(
        CameraUpdate.newLatLngZoom(_currentPosition!, 14),
      );

      // Call OpenRouteService to get the route
      await _getRouteFromOpenRouteService(
        start: _currentPosition!,
        end: _destination,
      );
    } catch (e) {
      debugPrint('Error in _initLocationAndRoute: $e');
    }
  }

  /// Request location permission and get the user's current position
  Future<Position> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Check if location services are enabled
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception('Location services are disabled.');
    }

    // Check permission
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception('Location permissions are denied.');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw Exception('Location permissions are permanently denied.');
    }

    // If we reach here, permissions are granted
    return Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
  }

  /// Calls OpenRouteService to get a route (polyline) from start to end
  Future<void> _getRouteFromOpenRouteService({
    required LatLng start,
    required LatLng end,
  }) async {
    // NOTE: The coords must be LONGITUDE,LATITUDE
    final startStr = '${start.longitude},${start.latitude}';
    final endStr = '${end.longitude},${end.latitude}';

    // Replace with your real ORS API key
    const orsApiKey = 'YOUR_ORS_API_KEY';

    final url = Uri.parse(
      'https://api.openrouteservice.org/v2/directions/driving-car'
          '?api_key=$orsApiKey'
          '&start=$startStr'
          '&end=$endStr',
    );

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final coords = data["features"][0]["geometry"]["coordinates"] as List<dynamic>;

        final routePoints = coords
            .map((c) => LatLng(c[1], c[0]))
            .toList();

        final routePolyline = Polyline(
          polylineId: const PolylineId('route'),
          width: 4,
          color: Colors.blue, // default color
          points: routePoints,
        );

        setState(() {
          _polylines.clear();
          _polylines.add(routePolyline);
        });
      } else {
        debugPrint('OpenRouteService error: ${response.body}');
      }
    } catch (e) {
      debugPrint('Exception calling ORS: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Google Maps + Route'),
      ),
      body: GoogleMap(
        initialCameraPosition: _initialPosition,
        onMapCreated: (controller) => _controller.complete(controller),
        myLocationEnabled: true,
        myLocationButtonEnabled: true,
        polylines: _polylines,
      ),
      bottomNavigationBar: Container(
        color: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        child: Row(
          children: [
            const SizedBox(width: 8),
            // Cancel Button
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.zero, // squared corners
                ),
              ),
              onPressed: () {
                // Handle Cancel
                debugPrint('Cancel pressed!');
              },
              child: const Text('Cancel'),
            ),
            const SizedBox(width: 10),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.zero,
                ),
              ),
              onPressed: () {
                debugPrint('Start Quest pressed!');
              },
              child: const Text('Start Quest'),
            ),
          ],
        ),
      ),
    );
  }
}