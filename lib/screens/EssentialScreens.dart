import 'dart:convert';

import 'package:alz/models/usermodel.dart';
import 'package:alz/providers/UserProvider.dart';
import 'package:alz/screens/AddRelative.dart';
import 'package:alz/screens/GoogleMaps.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:flutter_carousel_widget/flutter_carousel_widget.dart';
import '../games/firstGame.dart';
import '../games/secondGame.dart';
import '../games/thirdGame.dart';
import '../helper/services/getImages.dart';
import 'PersonalInfo.dart';
import 'ShowContacts.dart';




class EssentialScreen extends StatefulWidget {
  static const routeName = '/essential';
  const EssentialScreen({super.key});


  @override
  State<EssentialScreen> createState() => _EssentialScreenState();
}

class _EssentialScreenState extends State<EssentialScreen> {
  String locationMessage="";
  double? _currentLat;
  bool _loading=false;
  double? _currentLng;
  bool _isFetchingLocation = false;
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

      });

      http.Response res = await http.post(
        Uri.parse('https://f752-2409-40c0-7e-776f-d435-b81c-4f9e-7cf0.ngrok-free.app/locate'),
        body: jsonEncode({
          "long": _currentLng.toString(),
          "lat": _currentLat.toString(),
        }),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (res.statusCode==200){

        setState(() {
          locationMessage=json.decode(res.body)["location"];
          _isFetchingLocation = false;
        });
      }

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to fetch location: $e")),
      );
      setState(() {
        _isFetchingLocation = false;
      });
    }
  }
  Future<void> _getCurrentLocation() async {
    try {
      // Get the user's current position
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      // Use the Geocoding package to get address from coordinates
      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];
        setState(() {
          locationMessage = "${place.subLocality}, ${place.administrativeArea}";
        });
      } else {
        setState(() {
          locationMessage = "Location not found.";
        });
      }
    } catch (e) {
      print("error :"+e.toString());
      setState(() {
        locationMessage = "Error fetching location: $e";
      });
    }
  }


@override
  void initState() {
    // TODO: implement initState
    super.initState();
    _fetchCurrentLocation();
    fetchData();
  }
  void fetchData()async{
    setState(() {
      _loading=true;
    });
    await fetchDynamicImageData(FirebaseAuth.instance.currentUser!.uid,context);
    setState(() {
      _loading=false;
    });
  }

  bool isLoading = false;

  int _selectedEvent = 0;
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
  UserModel user=   Provider.of<UserProvider>(context).userModel!;
    return Container(
      decoration: BoxDecoration(
        color: Colors.deepPurple[200],
      ),
      child: Padding(
        padding: EdgeInsets.all(15.0),
        child: ListView(
          children: [
            Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0,vertical: 3),
                          child: Text(
                            'Hi, ${user.name}!',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                        SizedBox(
                          height: 8,
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(DateFormat('dd MMMM yyyy').format(DateTime.now()),
                              style: TextStyle(color: Colors.white)),
                        )
                      ],
                    ),
                    //notification

                  ],
                ),
                Container(
                  height: 100,
                  margin: EdgeInsets.all(10),
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: [
                      GestureDetector(
                        onTap: (_loading)?null:() {
                          Navigator.push(
                              context, MaterialPageRoute(builder: (context){
                                return FirstGameScreen();
                          }));
                        },
                        child: Container(
                          width: 200,
                          decoration: BoxDecoration(
                              color: Colors.deepPurple[600],
                              borderRadius: BorderRadius.circular(12)),
                          margin: EdgeInsets.only(right: 5),
                          child: Center(
                              child: Text(
                                'Connect',
                                style: TextStyle(color: Colors.white),
                              )),
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                              context, MaterialPageRoute(builder: (context){return LetterClickGameScreen();}));
                        },
                        child: Container(
                          width: 200,
                          margin: EdgeInsets.only(left: 5),
                          decoration: BoxDecoration(
                              color: Colors.deepPurple[600],
                              borderRadius: BorderRadius.circular(12)),
                          child: Center(
                              child: Text(
                                'Pronounce It',
                                style: TextStyle(color: Colors.white),
                              )),
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(context, MaterialPageRoute(builder: (_){
                            return QuizPage();
                          }));
                        },
                        child: Container(
                          width: 200,
                          margin: EdgeInsets.only(left: 5),
                          decoration: BoxDecoration(
                              color: Colors.deepPurple[600],
                              borderRadius: BorderRadius.circular(12)),
                          child: Center(
                              child: Text(
                                'Know Yourself',
                                style: TextStyle(color: Colors.white),
                              )),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: 5,
                ),
              ],
            ),

            //search bar

            //How do you feel

            Personal_Info(),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Text('Your Current Location',style: TextStyle(fontSize: 20,fontWeight: FontWeight.bold,color: Colors.white),),
            ),
            Flexible(
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                    color: Colors.deepPurple[400],
                    borderRadius: BorderRadius.circular(30)),
                padding: EdgeInsets.all(12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Flexible(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            margin: EdgeInsets.all(8),
                            height: 70,
                            width: 70,
                            child: Image.network(
                              "https://montsame.mn/files/66739787d0724.jpeg",
                              fit: BoxFit.cover,
                            ),
                          ),
                          Flexible(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                (_isFetchingLocation)
                                    ? Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: CircularProgressIndicator(color: Colors.white),
                                    )
                                    : Text(
                                  locationMessage,
                                  style: TextStyle(color: Colors.white),
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1, // Ensures it stays in a single line
                                ),
                                ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))
                                    ),
                                    onPressed: (){
                                      Navigator.push(context, MaterialPageRoute(builder: (context){
                                        return GoogleMapPage(destinationLocation: LatLng(user.homeLat, user.homeLong), sourceLocation: LatLng(_currentLat!, _currentLng!));
                                      }));
                                }, child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text("Your Home"),
                                )),
                              ],
                            ),
                          ),

                        ],
                      ),
                    ),

                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Relatives',style: TextStyle(fontSize: 20,fontWeight: FontWeight.bold,color: Colors.white),),
                  GestureDetector(
                      onTap: (){
                        Navigator.push(context, MaterialPageRoute(builder: (context){
                          return AddRelativeScreen();
                        }));
                      },
                      child: Text('Add More',style: TextStyle(fontSize: 20,color: Colors.white),))
                ],
              ),
            ),
            ImageListPage()
          ],
        ),
      ),
    );
  }

  Container buildUserEvents(Size size) {
    return Container(
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Container(
              width: size.width / 1.8,
              padding: EdgeInsets.all(8),
              child: MaterialButton(
                elevation: 0.5,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18.0),
                  side: BorderSide(color: Colors.deepPurple.shade700),
                ),
                color: _selectedEvent == 0
                    ? Colors.deepPurple.shade700
                    : Colors.white,
                onPressed: () {
                  setState(() {
                    _selectedEvent = 0;
                  });
                  _navigateToPage(0); // Navigate to Gallery screen
                },
                child: Text(
                  "Relatives",
                  style: TextStyle(
                    color: _selectedEvent == 0
                        ? Colors.white
                        : Colors.deepPurple.shade700,
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Container(
              width: size.width / 1.8,
              padding: EdgeInsets.all(8),
              child: MaterialButton(
                elevation: 0.5,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18.0),
                  side: BorderSide(color: Colors.deepPurple.shade700),
                ),
                color: _selectedEvent == 1
                    ? Colors.deepPurple.shade700
                    : Colors.white,
                onPressed: () {
                  setState(() {
                    _selectedEvent = 1;
                  });
                  _navigateToPage(1); // Navigate to Contact page
                },
                child: Text(
                  "Contact",
                  style: TextStyle(
                    color: _selectedEvent == 1
                        ? Colors.white
                        : Colors.deepPurple.shade700,
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Container(
              width: 30,
              padding: EdgeInsets.all(8),
              child: MaterialButton(
                elevation: 0.5,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18.0),
                  side: BorderSide(color: Colors.deepPurple.shade700),
                ),
                color: _selectedEvent == 2
                    ? Colors.deepPurple.shade700
                    : Colors.white,
                onPressed: () {
                  setState(() {
                    _selectedEvent = 2;
                  });
                  _navigateToPage(2); // Navigate to Image Recognizer page
                },
                child: Text(
                  "Recognize",
                  style: TextStyle(
                    fontSize: 12,
                    color: _selectedEvent == 2
                        ? Colors.white
                        : Colors.deepPurple.shade700,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _navigateToPage(int index) {
    switch (index) {
      case 0:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => Scaffold()),
        );
         break;
      case 1:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => Scaffold()),
        );
        break;
    //   case 2:
    //     Navigator.push(
    //       context,
    //       MaterialPageRoute(builder: (context) => ImageRecognizer()),
    //     );
    //     break;
    }
  }
}
