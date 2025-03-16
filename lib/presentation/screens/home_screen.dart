import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:side_quest/services/auth_service.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String? username;
  int? xp;
  double? latitude;
  double? longitude;
  String locationStatus = "Fetching location...";
  List<dynamic> recommendedPlaces = [];
  bool isLoading = true;
  bool userLoading = true;
  String errorMessage = "";

  final String apiUrl = "http://10.0.2.2:3001/api";

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _getUserLocation();
    _initializeUserAndLocation();
  }

  Future<void> _loadCachedUserData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      username = prefs.getString("username") ?? "Traveler";
      xp = prefs.getInt("xp") ?? 0;
      userLoading = false;
    });
  }

  Future<void> _loadCachedRecommendations() async {
    final prefs = await SharedPreferences.getInstance();
    final savedRecommendations = prefs.getString("recommendations");
    var lastLatitude = prefs.getDouble("latitude");
    var lastLongitude = prefs.getDouble("longitude");

    if (savedRecommendations != null) {
      setState(() {
        recommendedPlaces = jsonDecode(savedRecommendations);
        isLoading = false;
      });
    }
  }

  // ✅ Ensures user data is loaded before fetching location
  Future<void> _initializeUserAndLocation() async {
    await _loadUserData(); // Load user first
    await _getUserLocation(); // Then fetch location
  }

  // ✅ Load User Data (Ensures the username is properly set)
  Future<void> _loadUserData() async {
    final userProfile = await AuthService.getUserProfile();
    if (userProfile != null) {
      setState(() {
        username = userProfile['username'];
        xp = userProfile['experience'];
        userLoading = false; // ✅ Mark user data as loaded
      });
    } else {
      setState(() {
        username = "Traveler"; // Default if user not found
        xp = 0;
        userLoading = false;
      });
    }
  }

  Future<void> _getUserLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      setState(() {
        locationStatus = "Location services are disabled.";
        isLoading = false;
      });
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        setState(() {
          locationStatus = "Location permission denied.";
          isLoading = false;
        });
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      setState(() {
        locationStatus = "Location permissions are permanently denied.";
        isLoading = false;
      });
      return;
    }

    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    setState(() {
      latitude = position.latitude;
      longitude = position.longitude;
      locationStatus = "Location: ${latitude?.toStringAsFixed(2)}, ${longitude?.toStringAsFixed(2)}";
    });

    _fetchRecommendations();
  }
  Future<void> _fetchRecommendations() async {
    if (latitude == null || longitude == null) return;

    try {
      final response = await http.post(
        Uri.parse("$apiUrl/places"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"latitude": latitude, "longitude": longitude}),
      );

      print("API Response: ${response.body}");
      var jsonResponse = json.decode(response.body);
      print("Decoded JSON Response: $jsonResponse"); // Debugging print

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);

        if (jsonResponse is Map && jsonResponse.containsKey("recommendations")) {
          setState(() {
            recommendedPlaces = (jsonResponse["recommendations"] as List).map((place) {
              return {
                "name": place["name"] ?? "Unknown",
                "address": place["address"] ?? "No address available",
                "rating": place["rating"] != null ? place["rating"].toString() : "No rating", // 🔥 Convert rating to String
                "types": place["types"] ?? [],
                "image": place["image"] ?? "",
              };
            }).toList();
            isLoading = false;
          });
        } else {
          setState(() {
            errorMessage = "Invalid API response format.";
            isLoading = false;
          });
        }
      } else {
        setState(() {
          errorMessage = "Failed to load recommendations.";
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = "Error fetching places: $e";
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              SizedBox(height: 15),
              _buildLocationInfo(),
              _buildSearchBar(),
              SizedBox(height: 20),
              _buildChallengeSection(),
              SizedBox(height: 20),
              _buildRecommendationSection(),
              SizedBox(height: 20),
              _buildViewAllButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Hey $username,",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            Row(
              children: [
                Icon(Icons.emoji_events, color: Colors.black54, size: 18),
                SizedBox(width: 5),
                Text("$xp XP | Tourist", style: TextStyle(color: Colors.black54)),
              ],
            ),
          ],
        ),
        IconButton(
          icon: Icon(Icons.notifications, color: Colors.black54),
          onPressed: () {},
        ),
      ],
    );
  }
  Widget _buildCategoryButton(String imagePath, String label) {
    return GestureDetector(
      onTap: () {
        print("$label selected"); // Placeholder for navigation
      },
      child: Column(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.blue.withOpacity(0.1),
            ),
            child: Center(
              child: Image.asset(imagePath, width: 40, height: 40, fit: BoxFit.contain),
            ),
          ),
          SizedBox(height: 5),
          Text(label, textAlign: TextAlign.center, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
  Widget _buildChallengeSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Don't know where to start?",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 5),
        Text(
          "Pick a challenge. Earn XP. Get bragging rights.",
          style: TextStyle(color: Colors.black54),
        ),
        SizedBox(height: 15),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildCategoryButton("assets/icons/foodiefeast.png", "Foodie Feasts"),
            _buildCategoryButton("assets/icons/cultureq.png", "Culture Quests"),
            _buildCategoryButton("assets/icons/wildcard.png", "Wildcard"),
          ],
        ),
      ],
    );
  }

  Widget _buildLocationInfo() {
    return Row(
      children: [
        Icon(Icons.location_on, color: Colors.redAccent),
        SizedBox(width: 8),
        Text(locationStatus, style: TextStyle(color: Colors.black54)),
      ],
    );
  }

  Widget _buildSearchBar() {
    return TextField(
      decoration: InputDecoration(
        hintText: "Where are we going today?",
        prefixIcon: Icon(Icons.search, color: Colors.black54),
        filled: true,
        fillColor: Colors.grey[200],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  Widget _buildRecommendationSection() {
    if (isLoading) {
      return Center(child: CircularProgressIndicator());
    }

    if (errorMessage.isNotEmpty) {
      return Center(child: Text(errorMessage, style: TextStyle(color: Colors.red)));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Text("Not into Quests?", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        // SizedBox(height: 5),
        // Text("No problem. We'll still help you find the good stuff.", style: TextStyle(color: Colors.black54)),
        // SizedBox(height: 15),
        Column(
          children: recommendedPlaces.isEmpty
              ? [Text("No recommendations available.", style: TextStyle(color: Colors.black54))]
              : recommendedPlaces.map((place) {
            return _buildRecommendationCard(
              place["name"],
              place["address"],
              place["rating"],
              place["image"],
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildRecommendationCard(String title, String rating, String address, String? imageUrl) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Column(
        children: [
          if (imageUrl != null)
            ClipRRect(
              borderRadius: BorderRadius.vertical(top: Radius.circular(10)),
              child: Image.network(imageUrl, height: 150, width: double.infinity, fit: BoxFit.cover),
            ),
          Padding(
            padding: EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                SizedBox(height: 5),
                Row(
                  children: [
                    Icon(Icons.star, color: Colors.yellow, size: 16),
                    SizedBox(width: 5),
                    Text(rating),
                    SizedBox(width: 10),
                    Icon(Icons.location_on, color: Colors.red, size: 16),
                    SizedBox(width: 5),
                    Text(address),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildViewAllButton() {
    return Center(
      child: ElevatedButton(
        onPressed: () {},
        child: Text("VIEW ALL"),
      ),
    );
  }
}