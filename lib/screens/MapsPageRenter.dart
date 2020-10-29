import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocation/geolocation.dart';
import 'package:latlong/latlong.dart';
import 'package:flutter/services.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

class MapsPageRenter extends StatefulWidget {
  @override
  _MapsPageRenterState createState() => _MapsPageRenterState();
}

class _MapsPageRenterState extends State<MapsPageRenter> {
  LatLng current_location, refresh_location;
  List<Marker> allMarkers = [];
  String uId;

  @override
  void initState() {
    getUserId();
    SystemChrome.setEnabledSystemUIOverlays([SystemUiOverlay.bottom]);
    super.initState();
  }

  final GlobalKey _scaffoldKey = new GlobalKey();

  var points = <LatLng>[
    //somepoints for polyline
    new LatLng(25.43, 81.84),
    new LatLng(25.49, 81.85),
    // new LatLng(25.53,81.86),
    // new LatLng(25.59,81.87),
    // new LatLng(25.62,81.89),
  ];

  MapController controller = new MapController();

  getUserId() {
    FirebaseAuth auth = FirebaseAuth.instance;
    if (auth.currentUser != null) {
      uId = auth.currentUser.uid;
    }
  }

  getPermission() async {
    //ask permission for geolocation
    final GeolocationResult result =
        await Geolocation.requestLocationPermission(
            permission: const LocationPermission(
                android: LocationPermissionAndroid.fine,
                ios: LocationPermissionIOS.always));
    return result;
  }

  getLocation() {
    return getPermission().then((result) async {
      if (result.isSuccessful) {
        LocationResult coords = await Geolocation.lastKnownLocation();
        return coords;
      }
    });
  }

  buildMap() {
    //build the map with the current location of the user
    getLocation().then((response) {
      if (response.isSuccessful) {
        // response.listen((value) {
        controller.move(
            new LatLng(response.location.latitude, response.location.longitude),
            13.4);
        current_location =
            new LatLng(response.location.latitude, response.location.longitude);
        // setState(() {
        //   refresh_location = current_location;
        // });
        // });
        allMarkers.add(
          new Marker(
              width: 30.0,
              height: 30.0,
              point: refresh_location,
              builder: (context) => new Container(
                    child: IconButton(
                      icon: Icon(
                        Icons.location_on,
                        color: Color(0xFFFFF7C6),
                      ),
                      iconSize: 35,
                      onPressed: () {
                        print(current_location);
                      },
                    ),
                  )),
        );
        print("LOCATION: " + current_location.toString());
      }
    });
  }

  Widget loadMap() {
    return StreamBuilder(
        stream: Firestore.instance
            .collection("users")
            .doc(uId)
            .collection("lenderBikes")
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return Text('Loading maps..Please Wait');
          for (int i = 0; i < snapshot.data.documents.length; i++) {
            allMarkers.add(new Marker(
                width: 30,
                height: 30,
                point: new LatLng(
                  snapshot.data.documents[i]['coordinates'].latitude,
                  snapshot.data.documents[i]['coordinates'].longitude,
                ),
                builder: (context) => new Container(
                      child: IconButton(
                        icon: Icon(
                          MdiIcons.bicycle,
                          color: Color(0xFFFFC495),
                        ),
                        iconSize: 30,
                        onPressed: () {
                          print(snapshot.data.documents[i]['location']);
                        },
                      ),
                    )));
          }
          return FlutterMap(
            mapController: controller,
            options: new MapOptions(
              center: buildMap(),
              zoom: 13.4,
            ),
            layers: [
              new TileLayerOptions(
                  urlTemplate:
                      'https://api.mapbox.com/styles/v1/vibhanshuv/ckg9buo07066e19o9xjy4w9f3/tiles/256/{z}/{x}/{y}@2x?access_token=pk.eyJ1IjoidmliaGFuc2h1diIsImEiOiJja2c5MjltZ2IwajZnMndvMzhnZmNmcng1In0.1pJL10lwpPsJCuN4Yh6TDg',
                  additionalOptions: {
                    'accessToken':
                        "pk.eyJ1IjoidmliaGFuc2h1diIsImEiOiJja2c5MjltZ2IwajZnMndvMzhnZmNmcng1In0.1pJL10lwpPsJCuN4Yh6TDg",
                    'id': 'mapbox.mapbox-streets-v8'
                  }),
              new MarkerLayerOptions(markers: allMarkers)
            ],
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Color(0xFFFFC495),
      body: Builder(
        builder: (context) => Stack(children: <Widget>[
          loadMap(),
          Column(
            children: [
              SizedBox(
                height: 10,
              ),
              Row(
                children: [
                  SizedBox(
                    width: 10,
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.arrow_back,
                      color: Color(0xFFFFC495),
                      size: 40,
                    ),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  )
                ],
              ),
              Spacer(),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  GestureDetector(
                    child: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Color(0xFF1E1E29),
                      ),
                      child: Center(
                        child: Icon(
                          MdiIcons.crosshairsGps,
                          color: Color(0xFFFFC495),
                          size: 55,
                        ),
                      ),
                    ),
                    onTap: () {
                      setState(() {
                        refresh_location = current_location;
                      });

                      controller.move(
                          new LatLng(current_location.latitude,
                              current_location.longitude),
                          13.4);
                    },
                  ),
                ],
              ),
              SizedBox(
                height: 20,
              )
            ],
          ),
        ]),
      ),
    );
  }
}
