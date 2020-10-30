import 'dart:async';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocation/geolocation.dart';
import 'package:karvaan/models/Cycles.dart';
import 'package:karvaan/screens/ChatPage.dart';
import 'package:karvaan/screens/enterPrice.dart';
import 'package:karvaan/screens/services/authentication.dart';
import 'package:karvaan/screens/sideNav/AboutPage.dart';
import 'package:karvaan/screens/sideNav/BookingHistory.dart';
import 'package:karvaan/screens/sideNav/RequestPage.dart';
import 'package:karvaan/screens/sideNav/profile/Dashboard.dart';
import 'package:latlong/latlong.dart';
import 'package:shimmer/shimmer.dart';
import '../Presentation/menu_icon_icons.dart';
import 'package:flutter/services.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:toast/toast.dart';
import 'package:google_sign_in/google_sign_in.dart';

class MapsPage extends StatefulWidget {
  @override
  _MapsPageState createState() => _MapsPageState();
}

class _MapsPageState extends State<MapsPage> {
  LatLng current_location, refresh_location;
  List<Cycles> availableCycles = <Cycles>[];
  String name, email, phone, uId;

  @override
  void initState() {
    SystemChrome.setEnabledSystemUIOverlays([SystemUiOverlay.bottom]);
    getUserInfo();
    getUserBikesFromFirebase();
    super.initState();
  }

  final GlobalKey _scaffoldKey = new GlobalKey();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  FirebaseUser _user;
  final GoogleSignIn googleSignIn = new GoogleSignIn();

  Future<void> signOutGoogle() async {
    await googleSignIn.signOut();
  }

  // var points = <LatLng>[
  //   //somepoints for polyline
  //   new LatLng(25.43, 81.84),
  //   new LatLng(25.49, 81.85),
  //   // new LatLng(25.53,81.86),
  //   // new LatLng(25.59,81.87),
  //   // new LatLng(25.62,81.89),
  // ];

  List<Marker> allMarkers = [];

  // setMarkers() {
  //   allMarkers.add(
  //     new Marker(
  //         width: 30.0,
  //         height: 30.0,
  //         point: refresh_location,
  //         builder: (context) => new Container(
  //               child: IconButton(
  //                 icon: Icon(
  //                   Icons.location_on,
  //                   color: Color(0xFFFFC495),
  //                 ),
  //                 color: Colors.red,
  //                 iconSize: 30,
  //                 onPressed: () {
  //                   print(current_location);
  //                 },
  //               ),
  //             )),
  //   );
  //   return allMarkers;
  // }

  MapController controller = new MapController();

  Future getUserInfo() async {
    //to get user information
    FirebaseAuth auth = FirebaseAuth.instance;
    if (auth.currentUser != null) {
      uId = auth.currentUser.uid;
      FirebaseFirestore.instance
          .collection('users')
          .doc(uId)
          .snapshots()
          .listen((snapshot) {
        setState(() {
          name = snapshot["name"];
          email = snapshot["email"];
          phone = snapshot["phoneNo"];
        });
      });
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
    //get the location of the user
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
        .where('onRent', isEqualTo: false)
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
            13.4);
        current_location =
            new LatLng(response.location.latitude, response.location.longitude);
        allMarkers.add(
          new Marker(
              width: 30.0,
              height: 30.0,
              point: refresh_location,
              builder: (context) => new Container(
                    child: IconButton(
                      icon: Icon(
                        MdiIcons.circleSlice8,
                        color: Color(0xFFFFF7C6),
                      ),
                      iconSize: 20,
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

  Future sendChatRequest(String ownerId, String cycleName) async {
    Firestore.instance //adding new lender bike document
        .collection('users')
        .doc(ownerId)
        .collection("rentRequests")
        .doc(name)
        .set({
      'renterName': name,
      'bikeName': cycleName,
      'renterPhone': phone,
      'renterId': uId,
      'location': "Nearby",
    });
  }

  Future<int> createConfirmationDialog(BuildContext context, Cycles cycle) {
    return showDialog(
        context: context,
        builder: (context) {
          return Dialog(
            backgroundColor: Color(0xFFFFF7C6),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(17)),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                height: 180,
                width: 120,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            cycle.name,
                            style: TextStyle(
                                fontFamily: "Montserrat Bold",
                                fontSize: 20,
                                color: Color(0xFF1E1E29)),
                          ),
                        ],
                      ),
                      Container(
                        margin: EdgeInsets.only(
                            left: 60, top: 0, right: 60, bottom: 0),
                        child: Divider(
                          thickness: 1,
                          color: Color(0xFFFFC495),
                          height: 15.0,
                          indent: 5.0,
                        ),
                      ),
                      SizedBox(
                        width: 5,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Text("Pick-Up:",
                              style: TextStyle(
                                  fontSize: 14,
                                  fontFamily: "Montserrat Bold",
                                  color: Color(0xFF1E1E29))),
                          SizedBox(
                            width: 5,
                          ),
                          Text(cycle.location,
                              style: TextStyle(
                                  fontSize: 14,
                                  fontFamily: "Montserrat SemiBold",
                                  color: Color(0xFF1E1E29))),
                        ],
                      ),
                      SizedBox(
                        height: 15,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Text("Rent:",
                              style: TextStyle(
                                  fontSize: 14,
                                  fontFamily: "Montserrat Bold",
                                  color: Color(0xFF1E1E29))),
                          SizedBox(
                            width: 5,
                          ),
                          Text(cycle.pricePerHr + "/hr.",
                              style: TextStyle(
                                  fontSize: 14,
                                  fontFamily: "Montserrat SemiBold",
                                  color: Color(0xFF1E1E29))),
                        ],
                      ),
                      Container(
                        margin: EdgeInsets.only(
                            left: 20, top: 0, right: 20, bottom: 0),
                        child: Divider(
                          // thickness: 1,
                          color: Color(0xFFFFC495),
                          height: 15.0,
                          indent: 5.0,
                        ),
                      ),
                      SizedBox(
                        height: 5,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text("Do you want to send a chat request?",
                              style: TextStyle(
                                  fontSize: 13,
                                  fontFamily: "Montserrat Regular",
                                  color: Color(0xFF1E1E29))),
                        ],
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Container(
                            height: 30,
                            width: 80,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              color: Color(0xFF1E1E29),
                            ),
                            child: FlatButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                              child: Center(
                                child: Text(
                                  "No",
                                  style: TextStyle(
                                      color: Color(0xFFE5E5E5),
                                      fontSize: 14,
                                      fontFamily: 'Montserrat Bold'),
                                ),
                              ),
                            ),
                          ),
                          Container(
                            height: 30,
                            width: 80,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              color: Color(0xFF1E1E29),
                            ),
                            child: FlatButton(
                              onPressed: () async {
                                String _ownerId = cycle.ownerId;
                                sendChatRequest(_ownerId, cycle.name);
                                Navigator.of(context).pop(); //pass bike data
                              },
                              child: Center(
                                child: Text(
                                  "Yes",
                                  style: TextStyle(
                                      color: Color(0xFFE5E5E5),
                                      fontSize: 14,
                                      fontFamily: 'Montserrat Bold'),
                                ),
                              ),
                            ),
                          )
                        ],
                      )
                    ],
                  ),
                ),
              ),
            ),
          );
        });
  }

  Widget loadMap() {
    return StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection("availableBikes")
            .where("onRent", isEqualTo: false)
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
                          GeoPoint loc = new GeoPoint(
                            snapshot.data.documents[i]['coordinates'].latitude,
                            snapshot.data.documents[i]['coordinates'].longitude,
                          );
                          Cycles _thisCycle = new Cycles(
                            snapshot.data.documents[i]["name"],
                            snapshot.data.documents[i]["ownerId"],
                            snapshot.data.documents[i]["owner"],
                            snapshot.data.documents[i]["location"],
                            loc,
                            snapshot.data.documents[i]["pricePerHr"],
                          );
                          createConfirmationDialog(context, _thisCycle);
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

  Widget displayAvailableBikes(ScrollController scrollController) {
    if (availableCycles.length == 0) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Oops! No Bikes Available.",
              style: TextStyle(
                color: Color(0xFFFFC495),
                fontFamily: "Montserrat SemiBold",
              ),
            ),
            Text(
              "Please Try Later...",
              style: TextStyle(
                color: Color(0xFFFFC495),
                fontFamily: "Montserrat SemiBold",
              ),
            ),
          ],
        ),
      );
    } else {
      return Container(
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
                    width: 55,
                    height: 55,
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
                                    fontSize: 20,
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
                          image: AssetImage('assets/images/profile.png'),
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
                    createConfirmationDialog(context, availableCycles[index]);
                  },
                ),
              );
            },
          ),
        ),
      );
    }
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
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          height: 130,
                          width: 130,
                          decoration: BoxDecoration(
                              image: DecorationImage(
                            image: AssetImage('assets/images/icon.png'),
                            fit: BoxFit.fill,
                          )),
                        ),
                      ],
                    ),
                  ),
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
              Divider(
                thickness: 1,
                color: Color(0xFF282833),
              ),
              ListTile(
                leading: Icon(
                  MdiIcons.viewDashboard,
                  color: Color(0xFFFFC495),
                ),
                title: Text(
                  'Dashboard',
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
                thickness: 1,
                color: Color(0xFF282833),
              ),
              ListTile(
                leading: Icon(
                  MdiIcons.bell,
                  color: Color(0xFFFFC495),
                ),
                title: Text(
                  'Rent Requests',
                  style: TextStyle(
                      fontFamily: 'Montserrat SemiBold',
                      color: Color(0xFFFFC495)),
                ),
                onTap: () {
                  bool isLender = true;
                  if (isLender) {
                    return Navigator.push(context,
                        MaterialPageRoute(builder: (context) => RequestPage()));
                  } else {
                    Toast.show("You have not added any bike!", context,
                        duration: Toast.LENGTH_SHORT);
                  }
                  // rent requests
                  // ...
                },
              ),
              Divider(
                thickness: 1,
                color: Color(0xFF282833),
              ),
              ListTile(
                leading: Icon(
                  Icons.library_books,
                  color: Color(0xFFFFC495),
                ),
                title: Text(
                  'Previous Bookings',
                  style: TextStyle(
                      fontFamily: 'Montserrat SemiBold',
                      color: Color(0xFFFFC495)),
                ),
                onTap: () {
                  return Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => BookingHistory()));
                  // app settings
                  // ...
                },
              ),
              Divider(
                thickness: 1,
                color: Color(0xFF282833),
              ),
              ListTile(
                leading: Icon(
                  MdiIcons.information,
                  color: Color(0xFFFFC495),
                ),
                title: Text(
                  'About',
                  style: TextStyle(
                      fontFamily: 'Montserrat SemiBold',
                      color: Color(0xFFFFC495)),
                ),
                onTap: () {
                  return Navigator.push(context,
                      MaterialPageRoute(builder: (context) => About()));
                },
              ),
              Divider(
                thickness: 1,
                color: Color(0xFF282833),
              ),
              /* &&&&&&   Added a test list tile for enterPrice page &&&&&&&&&&&&&&&&&*/
              ListTile(
                leading: Icon(
                  Icons.monetization_on,
                  color: Color(0xFFFFC495),
                ),
                title: Text(
                  'Test Price page',
                  style: TextStyle(
                      fontFamily: 'Montserrat SemiBold',
                      color: Color(0xFFFFC495)),
                ),
                onTap: () {
                  return Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => enterPrice()));
                  // app settings
                  // ...
                },
              ),
              Divider(
                thickness: 1,
                color: Color(0xFF282833),
              ),
              /* &&&&&&&&&&&&&&&&&&&&& Test list tile ends here &&&&&&&&&&&&&& */
              ListTile(
                leading: Icon(
                  MdiIcons.logout,
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
                  signOutGoogle();
                },
              ),
            ],
          ),
        ),
      ),
      body: Builder(
        builder: (context) => Stack(children: <Widget>[
          loadMap(),
          DraggableScrollableSheet(
            initialChildSize: 0.20,
            maxChildSize: 0.5,
            minChildSize: 0.16,
            builder: (BuildContext context, ScrollController scrollController) {
              return Container(
                // color: Color(0xFF1E1E29),
                child: displayAvailableBikes(scrollController),
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
                      MdiIcons.crosshairsGps,
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
