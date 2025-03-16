import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;

import 'map_screen.dart';

class FoodFeatsChallenge extends StatefulWidget {
  @override
  _FoodFeatsChallengeState createState() => _FoodFeatsChallengeState();
}

class _FoodFeatsChallengeState extends State<FoodFeatsChallenge> {
  final TextEditingController _destinationController = TextEditingController();
  String? _selectedDifficulty;
  double? _latitude;
  double? _longitude;
  List<String> _suggestions = [];
  bool _isLoadingSuggestions = false;

  final List<Map<String, String>> _difficultyLevels = [
    {"name": "Tourist (0 - 999 XP)", "details": "2 Stops @50XP"},
    {"name": "Explorer (1K - 5K XP)", "details": "3 Stops @70XP"},
    {"name": "Adventure (5K - 15K XP)", "details": "4 Stops @100XP"},
    {"name": "Yardie (15K - 20K XP)", "details": "5 Stops @150XP"},
  ];

  bool get isButtonEnabled {
    return _destinationController.text.isNotEmpty && _selectedDifficulty != null;
  }

  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _initLocationProcess();
  }

  Future<void> _initLocationProcess() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      permission = await Geolocator.requestPermission();
      if (permission != LocationPermission.whileInUse &&
          permission != LocationPermission.always) {
        print("Location permission denied.");
        return;
      }
    }

    await _loadUserLocation();
  }

  Future<void> _loadUserLocation() async {
    final prefs = await SharedPreferences.getInstance();
    final storedLat = prefs.getDouble("latitude");
    final storedLng = prefs.getDouble("longitude");

    if (storedLat != null && storedLng != null) {
      setState(() {
        _latitude = storedLat;
        _longitude = storedLng;
      });
    } else {
      await _getUserCurrentLocation();
    }
  }

  Future<void> _getUserCurrentLocation() async {
    try {
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      if (!mounted) return;

      setState(() {
        _latitude = position.latitude;
        _longitude = position.longitude;
      });

      final prefs = await SharedPreferences.getInstance();
      prefs.setDouble("latitude", _latitude!);
      prefs.setDouble("longitude", _longitude!);
    } catch (e) {
      print("Location error: $e");
    }
  }

  void _onDestinationChanged(String value) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();

    _debounce = Timer(const Duration(milliseconds: 500), () {
      // Only call Google Places API if we have a query
      if (value.isNotEmpty) {
        _getPlaceSuggestions(value);
      } else {
        setState(() {
          _suggestions.clear();
        });
      }
    });
  }

  Future<void> _getPlaceSuggestions(String query) async {
    if (_latitude == null || _longitude == null) {
      print("User location is not available yet.");
      return;
    }

    setState(() {
      _isLoadingSuggestions = true;
    });

    const String apiKey = "AIzaSyBarmCj4wKx8b65fJ_-VOUTcg-bp-B1VUQ";
    final String url =
        "https://maps.googleapis.com/maps/api/place/autocomplete/json?"
        "input=$query&"
        "key=$apiKey&"
        "location=$_latitude,$_longitude&"
        "radius=5000";

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        List predictions = data["predictions"] ?? [];
        setState(() {
          _suggestions = predictions
              .map<String>((place) => place["description"] as String)
              .toList();
        });
      } else {
        print("Places API Error. Status Code: ${response.statusCode}");
      }
    } catch (e) {
      print("API Error: $e");
    } finally {
      setState(() {
        _isLoadingSuggestions = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Food Feats"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Challenge: Food Feats!",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              "Where’s your next bite taking you?",
              style: TextStyle(fontSize: 16, color: Colors.black54),
            ),
            const SizedBox(height: 20),

            Center(
              child: Image.asset(
                "assets/images/food_feats.png",
                height: 200,
                fit: BoxFit.contain,
              ),
            ),
            const SizedBox(height: 20),

            Text("Destination", style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 5),
            Column(
              children: [
                TextField(
                  controller: _destinationController,
                  onChanged: _onDestinationChanged, // Use debounce method
                  decoration: InputDecoration(
                    hintText: "Enter your destination",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    contentPadding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                  ),
                ),
                if (_isLoadingSuggestions)
                  const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: CircularProgressIndicator(),
                  ),
                if (_suggestions.isNotEmpty)
                  Container(
                    height: 150,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey,
                          blurRadius: 5,
                          offset: Offset(0, 3),
                        ),
                      ],
                    ),
                    child: ListView.builder(
                      itemCount: _suggestions.length,
                      itemBuilder: (context, index) {
                        return ListTile(
                          title: Text(_suggestions[index]),
                          onTap: () {
                            setState(() {
                              _destinationController.text = _suggestions[index];
                              _suggestions = [];
                            });
                          },
                        );
                      },
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 15),

            Text("Difficulty Level", style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            DropdownButtonFormField<String>(
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                contentPadding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
              ),
              hint: const Text("Select your difficulty level"),
              value: _selectedDifficulty,
              onChanged: (newValue) {
                setState(() {
                  _selectedDifficulty = newValue;
                });
              },
              items: _difficultyLevels.map((level) {
                return DropdownMenuItem(
                  value: level["name"],
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        level["name"]!,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        level["details"]!,
                        style: const TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 30),

            Center(
              child: ElevatedButton(
                onPressed: isButtonEnabled
                    ? () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => MapScreen()),
                  );
                }
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: isButtonEnabled ? Colors.black : Colors.grey[300],
                  foregroundColor: isButtonEnabled ? Colors.white : Colors.black54,
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text("CREATE QUEST"),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}