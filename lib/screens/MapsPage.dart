import 'dart:async';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocation/geolocation.dart';
import 'package:karvaan/models/Cycles.dart';
import 'package:karvaan/screens/ChatPage.dart';
import 'package:karvaan/screens/services/authentication.dart';
import 'package:karvaan/screens/sideNav/profile/ProfilePage.dart';
import 'package:latlong/latlong.dart';
import '../Presentation/menu_icon_icons.dart';
import 'package:flutter/services.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:toast/toast.dart';

class MapsPage extends StatefulWidget {
  @override
  _MapsPageState createState() => _MapsPageState();
}

class _MapsPageState extends State<MapsPage> {
  LatLng current_location, refresh_location;
  List<Cycles> availableCycles = <Cycles>[];

  @override
  void initState() {
    SystemChrome.setEnabledSystemUIOverlays([SystemUiOverlay.bottom]);
    getUserBikesFromFirebase();
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

  List<Marker> allMarkers = [];
  setMarkers() {
    allMarkers.add(
      new Marker(
          width: 30.0,
          height: 30.0,
          point: refresh_location,
          builder: (context) => new Container(
                child: IconButton(
                  icon: Icon(
                    Icons.location_on,
                    color: Color(0xFFFFC495),
                  ),
                  color: Colors.red,
                  iconSize: 30,
                  onPressed: () {
                    print(current_location);
                  },
                ),
              )),
    );
    return allMarkers;
  }

  MapController controller = new MapController();

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
    //get the location of the user

    // StreamSubscription<LocationResult> subscription = Geolocation.currentLocation(accuracy: LocationAccuracy.best).listen((result) {
    //   if(result.isSuccessful) {
    //     double latitude = result.location.latitude;
    //     // todo with result
    //   }
    // });

    return getPermission().then((result) async {
      if (result.isSuccessful) {
        LocationResult coords = await Geolocation.lastKnownLocation();
        return coords;
      }
    });
  }

  Future getUserBikesFromFirebase() async {
    FirebaseFirestore.instance
        .collection('availableBikes')
        .snapshots()
        .listen((querySnapshot) {
      setState(() {
        querySnapshot.docs.forEach((doc) {
          String name = doc["name"];
          String rent = doc["pricePerHr"];
          String location = doc["location"];
          GeoPoint coords = doc["coordinates"];
          String ownerId = doc["ownerId"];
          String owner = doc["owner"];
          Cycles cycle = Cycles(
            name,
            ownerId,
            owner,
            location,
            coords,
            rent,
          );
          availableCycles.add(cycle);
        });
      });
    });
  }

  buildMap() {
    //build the map with the current location of the user
    getLocation().then((response) {
      if (response.isSuccessful) {
        // response.listen((value) {
        controller.move(
            new LatLng(response.location.latitude, response.location.longitude),
            15.0);
        current_location =
            new LatLng(response.location.latitude, response.location.longitude);
        setState(() {
          refresh_location = current_location;
        });
        // });
        print(current_location);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Color(0xFFFFC495),
      drawer: Drawer(
        child: Container(
          color: Color(0xFF1E1E29),
          child: ListView(
            // Important: Remove any padding from the ListView.
            padding: EdgeInsets.zero,
            children: <Widget>[
              Container(
                height: 200,
                margin: EdgeInsets.fromLTRB(20, 0, 20, 0),
                child: DrawerHeader(
                  child: Text(''),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(17),
                      bottomRight: Radius.circular(17),
                    ),
                    color: Color(0xFFFFC495),
                  ),
                ),
              ),
              SizedBox(
                height: 10,
              ),
              ListTile(
                leading: Icon(
                  Icons.account_circle,
                  color: Color(0xFFFFC495),
                ),
                title: Text(
                  'Profile',
                  style: TextStyle(
                      fontFamily: 'Montserrat SemiBold',
                      color: Color(0xFFFFC495)),
                ),
                onTap: () {
                  return Navigator.push(context,
                      MaterialPageRoute(builder: (context) => ProfilePage()));
                },
              ),
              Divider(
                // thickness: 1,
                color: Color(0xFFFFC495),
              ),
              ListTile(
                leading: Icon(
                  Icons.settings,
                  color: Color(0xFFFFC495),
                ),
                title: Text(
                  'Settings',
                  style: TextStyle(
                      fontFamily: 'Montserrat SemiBold',
                      color: Color(0xFFFFC495)),
                ),
                onTap: () {
                  Toast.show("Incomplete!", context,
                      duration: Toast.LENGTH_SHORT);
                  // Update the state of the app.
                  // ...
                },
              ),
              Divider(
                // thickness: 1,
                color: Color(0xFFFFC495),
              ),
              ListTile(
                leading: Icon(
                  MdiIcons.bike,
                  color: Color(0xFFFFC495),
                ),
                title: Text(
                  'Log Out',
                  style: TextStyle(
                      fontFamily: 'Montserrat SemiBold',
                      color: Color(0xFFFFC495)),
                ),
                onTap: () {
                  AuthService().signOut();
                },
              ),
              Divider(
                // thickness: 1,
                color: Color(0xFFFFC495),
              ),
              ListTile(
                leading: Icon(
                  MdiIcons.alertBox,
                  color: Color(0xFFFFC495),
                ),
                title: Text(
                  'About',
                  style: TextStyle(
                      fontFamily: 'Montserrat SemiBold',
                      color: Color(0xFFFFC495)),
                ),
                onTap: () {
                  Toast.show("Incomplete!", context,
                      duration: Toast.LENGTH_SHORT);
                },
              ),
            ],
          ),
        ),
      ),
      body: Builder(
        builder: (context) => Stack(children: <Widget>[
          FlutterMap(
            mapController: controller,
            options: new MapOptions(
              center: buildMap(),
              zoom: 13.0,
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
              // new PolylineLayerOptions(
              //   polylines: [
              //     new Polyline(
              //       points: points,
              //       strokeWidth: 5.0,
              //       color: Color(0xFF1E1E29),
              //     )
              //   ]
              // ),
              //
              new MarkerLayerOptions(markers: setMarkers())
            ],
          ),
          DraggableScrollableSheet(
            initialChildSize: 0.20,
            maxChildSize: 0.5,
            minChildSize: 0.16,
            builder: (BuildContext context, ScrollController scrollController) {
              return Container(
                // color: Color(0xFF1E1E29),
                child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: ListView.builder(
                    controller: scrollController,
                    itemCount: availableCycles.length,
                    itemBuilder: (BuildContext context, int index) {
                      return Card(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(17)),
                        color: Color(0x001E1E29),
                        child: ListTile(
                          trailing: Container(
                            width: 50,
                            height: 50,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      "Rs",
                                      style: TextStyle(
                                          fontSize: 10,
                                          fontFamily: "Montserrat Regular",
                                          color: Color(0xFFFFF7C6)),
                                    ),
                                    SizedBox(
                                      width: 5,
                                    ),
                                    Text(availableCycles[index].pricePerHr,
                                        style: TextStyle(
                                            fontSize: 24,
                                            fontFamily: "Montserrat Bold",
                                            color: Color(0xFFFFF7C6)))
                                  ],
                                ),
                                Row(
                                  children: [
                                    SizedBox(
                                      width: 15,
                                    ),
                                    Text("per hr",
                                        style: TextStyle(
                                            fontSize: 10,
                                            fontFamily: "Montserrat Regular",
                                            color: Color(0xFFFFF7C6))),
                                  ],
                                )
                              ],
                            ),
                          ),
                          leading: Container(
                            height: 60,
                            width: 60,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(5),
                              image: DecorationImage(
                                  image:
                                      AssetImage('assets/images/profile.png'),
                                  fit: BoxFit.fill),
                              shape: BoxShape.rectangle,
                            ),
                          ),
                          title: Text(
                            availableCycles[index].name,
                            style: TextStyle(
                                fontSize: 18,
                                fontFamily: "Montserrat Medium",
                                color: Color(0xFFFFC495)),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(
                                height: 2,
                              ),
                              Row(
                                children: [
                                  Icon(
                                    Icons.location_on,
                                    color: Color(0xFFFFC495),
                                    size: 20,
                                  ),
                                  SizedBox(
                                    width: 5,
                                  ),
                                  Text(
                                    '0.7km away',
                                    style: TextStyle(
                                        fontSize: 14,
                                        fontFamily: "Montserrat Regular",
                                        color: Color(0xFFCA9367)),
                                  ),
                                ],
                              ),
                              SizedBox(
                                height: 8,
                              ),
                              Text(
                                availableCycles[index].owner,
                                style: TextStyle(
                                    fontSize: 14,
                                    fontFamily: "Montserrat Regular",
                                    color: Color(0xFFCA9367)),
                              ),
                              SizedBox(
                                height: 8,
                              ),
                            ],
                          ),
                          onTap: () {
                            Toast.show("Incomplete!", context,
                                duration: Toast.LENGTH_SHORT);
                            return Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        ChatPage())); //not working because of context, find a fix.
                          },
                        ),
                      );
                    },
                  ),
                ),
                decoration: BoxDecoration(
                    color: Color(0xFF1E1E29),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30),
                    )),
              );
            },
          ),
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
                      MenuIcon.menu,
                      color: Color(0xFFFFC495),
                      size: 40,
                    ),
                    onPressed: () {
                      Scaffold.of(context).openDrawer();
                    },
                  ),
                  Spacer(),
                  IconButton(
                    icon: Icon(
                      MdiIcons.rotateLeft,
                      color: Color(0xFFFFC495),
                      size: 40,
                    ),
                    onPressed: () {
                      setState(() {
                        availableCycles.clear();
                        getUserBikesFromFirebase();
                        refresh_location = current_location;
                      });
                    },
                  ),
                  SizedBox(
                    width: 10,
                  ),
                ],
              ),
            ],
          ),
        ]),
      ),
    );
  }
}
