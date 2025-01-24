import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:workmanager/workmanager.dart';

class LocationCheckPage extends StatefulWidget {
  @override
  _LocationCheckPageState createState() => _LocationCheckPageState();
}

class _LocationCheckPageState extends State<LocationCheckPage> {
  double? _currentLat;
  double? _currentLng;
  bool _isFetchingLocation = false;

  @override
  void initState() {
    super.initState();
    _fetchCurrentLocation(); // Automatically fetch location on page load
  }

  Future<void> _fetchCurrentLocation() async {
    setState(() {
      _isFetchingLocation = true;
    });

    // Request location permission
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Location services are disabled.")),
      );
      setState(() {
        _isFetchingLocation = false;
      });
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Location permission is denied.")),
        );
        setState(() {
          _isFetchingLocation = false;
        });
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Location permissions are permanently denied."),
        ),
      );
      setState(() {
        _isFetchingLocation = false;
      });
      return;
    }

    // Fetch current position
    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.best,
      );
      setState(() {
        _currentLat = position.latitude;
        _currentLng = position.longitude;
        _isFetchingLocation = false;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to fetch location: $e")),
      );
      setState(() {
        _isFetchingLocation = false;
      });
    }
  }

  void startLocationCheck() {
    if (_currentLat == null || _currentLng == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Unable to fetch current location.")),
      );
      return;
    }

    // Workmanager().registerPeriodicTask(
    //   "locationCheckTask",
    //   "checkUserLocation",
    //   inputData: {
    //     'houseLat': _currentLat,
    //     'houseLng': _currentLng,
    //   },
    //   frequency: const Duration(minutes: 15), // Runs every 15 minutes
    // );

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Location check started!")),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            if (_isFetchingLocation)
              Center(
                child: CircularProgressIndicator(),
              )
            else
              Column(
                children: [
                  Text(
                    "Current Location:",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  Text("Latitude: ${_currentLat ?? 'Fetching...'}"),
                  Text("Longitude: ${_currentLng ?? 'Fetching...'}"),
                ],
              ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: _isFetchingLocation ? null : startLocationCheck,
              child: Text("Start Monitoring"),
            ),
          ],

      ),
    );
  }
}
