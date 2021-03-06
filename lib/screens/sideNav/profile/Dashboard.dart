import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:geocoder/geocoder.dart';
import 'package:geoflutterfire/geoflutterfire.dart';
import 'package:image_picker/image_picker.dart';
import 'package:karvaan/models/Cycles.dart';
import 'package:karvaan/screens/ChatListPage.dart';
import 'package:karvaan/screens/ChatPage.dart';
import 'package:karvaan/screens/sideNav/profile/EditProfile.dart';
import 'package:latlong/latlong.dart';
import 'package:karvaan/screens/MapsPageRenter.dart';
import 'package:karvaan/screens/sideNav/RequestPage.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:toast/toast.dart';

import '../../ChatPage.dart';

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String uId,
      name = "Error!",
      phone = 'Error!',
      email = "Error!"; //defined default values for the fields.
  String _imageUrl;
  List<Cycles> allCycles = <Cycles>[]; //Dynamic List of Cycles.
  Cycles newCycle;
  TextEditingController _newBikeNameController =
      new TextEditingController(); //controller for bike name
  TextEditingController _newBikeRentController =
      new TextEditingController(); //controller for bike rent
  TextEditingController
      _newBikeLocationController = //controller for bike location
      new TextEditingController();
  bool isSwitched = false; //default value for switch

  Geoflutterfire geo = new Geoflutterfire(); //Location Characteristics

  getUserId() {
    //getting UserId from firestore collection...
    FirebaseAuth auth = FirebaseAuth.instance;
    if (auth.currentUser != null) {
      uId = auth.currentUser.uid;
    }
  }

  Future getUserInfo() async {
    //Extracting user info from firestore...
    //to get user information
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

  Future getUserBikesFromFirebase() async {
    //Getting user bikes info from firebase
    FirebaseFirestore.instance
        .collection('users')
        .doc(uId)
        .collection("lenderBikes")
        .snapshots()
        .listen((querySnapshot) {
      setState(() {
        querySnapshot.docs.forEach((doc) {
          String bikeName = doc["name"];
          String rent = doc["pricePerHr"];
          String location = doc["location"];
          GeoPoint coords = doc["coordinates"];
          Cycles cycle = Cycles(
            bikeName,
            uId,
            name,
            location,
            coords,
            rent,
          );
          allCycles.add(cycle);
        });
      });
    });
  }

  @override
  void initState() {
    //initState...
    getUserId();
    getUserInfo();
    getUserBikesFromFirebase();
    print(allCycles);
    super.initState();
    var ref =
        FirebaseStorage.instance.ref().child('users/' + uId + '/profile.png');
    ref.getDownloadURL().then((loc) =>
        setState(() => _imageUrl = loc)); //setting path for profile image
  }

  Future<void> deleteBike(String name) {
    //Wanna Remove your Cycle??
    FirebaseFirestore.instance
        .collection('users')
        .doc(uId)
        .collection("lenderBikes")
        .doc(name)
        .delete();

    FirebaseFirestore.instance //adding new availble bike document
        .collection('availableBikes')
        .doc(name)
        .delete();
  }

  Future addNewBikeToFirebase() async {
    //add new bike location(lat and long) to firebase database
    final query = newCycle.location;
    var addresses = await Geocoder.local.findAddressesFromQuery(query);
    var first = addresses.first;

    FirebaseFirestore.instance //adding new lender bike document
        .collection('users')
        .doc(uId)
        .collection("lenderBikes")
        .doc(newCycle.name)
        .set({
      'coordinates': //specifying coordinates on the map.....
          new GeoPoint(first.coordinates.latitude, first.coordinates.longitude),
      'location': newCycle.location,
      'pricePerHr': newCycle.pricePerHr,
      'name': newCycle.name,
      'ownerId': uId,
      'owner': name,
    });

    FirebaseFirestore.instance //adding new cycle document
        .collection('users')
        .doc(uId)
        .update({'isLender': true}).then((value) => print("Updated"));

    GeoFirePoint point = geo.point(
        latitude: first.coordinates.latitude,
        longitude: first.coordinates.longitude);
    FirebaseFirestore.instance //adding new availble cycle document
        .collection('availableBikes')
        .doc(newCycle.name)
        .set({
      'position': point.data,
      'location': newCycle.location,
      'pricePerHr': newCycle.pricePerHr,
      'name': newCycle.name,
      'ownerId': uId,
      'owner': name,
      'onRent': false,
    });
  }

  Future<int> createAlertDialog(BuildContext context) {
    //Creating Dialog Box for taking cycle info from Lender...
    return showDialog(
        context: context,
        builder: (context) {
          return Dialog(
            backgroundColor: Color(0xFFFFF7C6),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(17)),
            child: Padding(
              padding: const EdgeInsets.only(top: 20.0, bottom: 20.0),
              child: Container(
                height: 350,
                width: 276,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Enter Bike Details",
                          style: TextStyle(
                              fontFamily: "Montserrat Bold",
                              fontSize: 20,
                              color: Color(0xFF1E1E29)),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 35,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Bike Name",
                            style: TextStyle(
                                fontFamily: "Montserrat Medium",
                                fontSize: 14,
                                color: Color(0xFFCA9367)),
                          ),
                          Container(
                            height: 30,
                            width: 150,
                            child: TextFormField(
                              style: TextStyle(
                                  fontFamily: "Montserrat SemiBold",
                                  color: Color(0xFF1E1E29)),
                              textAlign: TextAlign.start,
                              autocorrect: false,
                              controller: _newBikeNameController,
                              validator: (String value) {
                                if (value.isEmpty) {
                                  return 'Name is Required';
                                }
                                return null;
                              },
                            ),
                          ),
                          SizedBox(
                            height: 30,
                          ),
                          Text(
                            "Rate",
                            style: TextStyle(
                                fontFamily: "Montserrat Medium",
                                fontSize: 14,
                                color: Color(0xFFCA9367)),
                          ),
                          Container(
                            height: 30,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Text("Rs.",
                                    style: TextStyle(
                                        fontFamily: "Montserrat SemiBold",
                                        color: Color(0xFF1E1E29),
                                        fontSize: 18)),
                                SizedBox(
                                  width: 2,
                                ),
                                Container(
                                  height: 30,
                                  width: 50,
                                  child: TextFormField(
                                    style: TextStyle(
                                        fontFamily: "Montserrat SemiBold",
                                        fontSize: 18,
                                        color: Color(0xFF1E1E29)),
                                    textAlign: TextAlign.start,
                                    autocorrect: false,
                                    controller: _newBikeRentController,
                                    validator: (String value) {
                                      if (value.isEmpty) {
                                        return 'Rate is Required';
                                      }
                                      return null;
                                    },
                                  ),
                                ),
                                SizedBox(
                                  width: 2,
                                ),
                                Text("per hr.",
                                    style: TextStyle(
                                        fontFamily: "Montserrat SemiBold",
                                        color: Color(0xFF1E1E29),
                                        fontSize: 18)),
                              ],
                            ),
                          ),
                          SizedBox(
                            height: 30,
                          ),
                          Text(
                            "Location",
                            style: TextStyle(
                                fontFamily: "Montserrat Medium",
                                fontSize: 14,
                                color: Color(0xFFCA9367)),
                          ),
                          Container(
                            height: 30,
                            width: 200,
                            child: TextFormField(
                              style: TextStyle(
                                  fontFamily: "Montserrat SemiBold",
                                  color: Color(0xFF1E1E29)),
                              textAlign: TextAlign.start,
                              autocorrect: false,
                              controller: _newBikeLocationController,
                              validator: (String value) {
                                if (value.isEmpty) {
                                  return 'Bike Location is Required';
                                }
                                return null;
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 38,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Container(
                          height: 39,
                          width: 100,
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
                                "Cancel",
                                style: TextStyle(
                                    color: Color(0xFFE5E5E5),
                                    fontSize: 14,
                                    fontFamily: 'Montserrat Bold'),
                              ),
                            ),
                          ),
                        ),
                        Container(
                          height: 39,
                          width: 100,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            color: Color(0xFF1E1E29),
                          ),
                          child: FlatButton(
                            onPressed: () async {
                              addItemToList();
                              addNewBikeToFirebase();
                              // Toast.show("Incomplete!", context,
                              //     duration: Toast.LENGTH_SHORT);
                              Navigator.of(context).pop(); //pass bike data
                            },
                            child: Center(
                              child: Text(
                                "Save",
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
          );
        });
  }

  void addItemToList() {
    //Method to add cycles dynamically to the list...
    newCycle = new Cycles(
        _newBikeNameController.text.toString(),
        uId,
        name,
        _newBikeLocationController.text.toString(),
        new GeoPoint(0, 0),
        _newBikeRentController.text.toString());
  }

  Widget displayBikeList() {
    //Widget for displaying bike list..
    if (allCycles.length == 0) {
      return Center(
        child: Text(
          "You have not added any cycle!",
          style: TextStyle(
            color: Color(0xFFFFC495),
            fontFamily: "Montserrat SemiBold",
          ),
        ),
      );
    } else {
      return Padding(
        padding: const EdgeInsets.all(10.0),
        child: ListView.builder(
            shrinkWrap: true,
            itemCount: allCycles.length,
            itemBuilder: (BuildContext context, int index) {
              return Card(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(17)),
                color: Color(0xFF2C2C37),
                child: ListTile(
                  trailing: Container(
                    width: 50,
                    height: 50,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Row(
                          children: [
                            SizedBox(
                              height: 2,
                            ),
                            IconButton(
                              icon:
                                  Icon(Icons.delete, color: Color(0xFFFFC495)),
                              onPressed: () {
                                deleteBike(allCycles[index].name);
                                setState(() {
                                  allCycles.clear();
                                });
                              },
                            )
                          ],
                        ),
                      ],
                    ),
                  ),
                  leading: Container(
                    height: 60,
                    width: 60,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(5),
                      image: DecorationImage(
                          image: AssetImage('assets/images/icon.png'),
                          fit: BoxFit.fill),
                      shape: BoxShape.rectangle,
                    ),
                  ),
                  title: Text(
                    '${allCycles[index].name}',
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
                          Text(
                            '${allCycles[index].location}',
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
                        'Rs. ${allCycles[index].pricePerHr} per hr.',
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
                ),
              );
            }),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    //Here starts the UI of the overall Dashboard Screen....
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Color(0xFF2C2C37),
          iconTheme: IconThemeData(
            color: Color(0xFFFFC495),
          ),
          centerTitle: true,
          title: Text(
            "DASHBOARD",
            style: TextStyle(
                fontFamily: "Montserrat Bold",
                color: Color(0xFFE5E5E5),
                fontSize: 16),
          ),
          elevation: 1,
          actions: <Widget>[
            Padding(
              padding: EdgeInsets.only(right: 20.0),
            ),
          ],
        ),
        backgroundColor: Color(0xFF1E1E29),
        body: SingleChildScrollView(
            child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
                child: Column(children: <Widget>[
              Container(
                margin: EdgeInsets.all(30),
                width: 160,
                height: 160,
                decoration: BoxDecoration(
                  border: Border.all(
                      width: 4,
                      color: Theme.of(context).scaffoldBackgroundColor),
                  boxShadow: [
                    BoxShadow(
                        spreadRadius: 2,
                        blurRadius: 10,
                        color: Colors.black.withOpacity(0.1),
                        offset: Offset(0, 10))
                  ],
                  shape: BoxShape.circle,
                  image: DecorationImage(
                      // image: NetworkImage(
                      //     'https://googleflutter.com/sample_image.jpg'),
                      image: _imageUrl == null
                          ? NetworkImage(
                              'https://firebasestorage.googleapis.com/v0/b/karvaan-app-15704.appspot.com/o/users%2Fdownload%20(1).png?alt=media&token=4337d9ee-45dd-4993-a794-ca4a70d7b911')
                          : NetworkImage(_imageUrl),
                      fit: BoxFit.fill),
                ),
              ),
            ])),

            Container(
              height: 380,
              width: 250,
              color: Color(0xFF1E1E29),
              padding: const EdgeInsets.all(10.0),
              child: Card(
                color: Color(0xFF2C2C37),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Column(
                  children: [
                    ListTile(
                      title: Text(
                        name,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontSize: 30,
                            fontFamily: "Montserrat Bold",
                            color: Color(0xFFFFC495)),
                      ),
                    ),
                    Row(
                      children: [
                        Padding(
                            padding: EdgeInsets.fromLTRB(30.0, 20.0, 10.0, 0.0),
                            child: Text(
                              'Phone',
                              style: TextStyle(
                                  fontSize: 16,
                                  fontFamily: "Montserrat Medium",
                                  color: Color(0xFFCA9367)),
                            )),
                      ],
                    ),
                    Row(
                      children: [
                        Padding(
                            padding: EdgeInsets.fromLTRB(20.0, 5.0, 10.0, 5.0),
                            child: Text(
                              phone,
                              style: TextStyle(
                                  fontSize: 19,
                                  fontFamily: "Montserrat Medium",
                                  color: Color(0xFFE5E5E5)),
                            )),
                      ],
                    ),
                    Row(
                      children: [
                        Padding(
                            padding: EdgeInsets.fromLTRB(30.0, 30.0, 10.0, 0.0),
                            child: Text(
                              'Email',
                              style: TextStyle(
                                  fontSize: 16,
                                  fontFamily: "Montserrat Medium",
                                  color: Color(0xFFCA9367)),
                            )),
                      ],
                    ),
                    Row(
                      children: [
                        Padding(
                            padding: EdgeInsets.fromLTRB(20.0, 5.0, 10.0, 5.0),
                            child: Text(
                              email,
                              style: TextStyle(
                                  fontSize: 19,
                                  fontFamily: "Montserrat Medium",
                                  color: Color(0xFFE5E5E5)),
                            )),
                      ],
                    ),
                    Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                      Padding(
                        padding: EdgeInsets.fromLTRB(20.0, 20.0, 20.0, 5.0),
                        child: FloatingActionButton(
                          heroTag: "btn1",
                          backgroundColor: Color(0xFFCA9367),
                          onPressed: () {
                            return Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => EditProfile(uId)));
                          },
                          child: Icon(
                            Icons.edit,
                            size: 30,
                          ),
                        ),
                      ),
                    ]),
                  ],
                ),
              ),
            ),

            //Divider in between two cards....
            Container(
              margin: EdgeInsets.only(left: 90, top: 1, right: 90, bottom: 0),
              child: Divider(
                // thickness: 1,
                color: Color(0xFFFFC495),
                height: 15.0,
                indent: 5.0,
              ),
            ),

            Row(
              children: [
                Padding(
                  padding: EdgeInsets.fromLTRB(20.0, 30.0, 20.0, 5.0),
                  child: Text(
                    'My Cycles',
                    style: TextStyle(
                        fontSize: 27,
                        fontFamily: "Montserrat Bold",
                        color: Color(0xFFE5E5E5)),
                  ),
                ),
              ],
            ),
            //Here begins the second card,displaying a person's cycles....
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(50.0)),
                color: Color(0xFFFFF7C6),
              ),
              margin: EdgeInsets.all(24.0),
              child: SizedBox(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(0.0, 6.0, 0.0, 6.0),
                  child: (Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      FlatButton(
                          //tap on the button to add your cycles.....
                          child: Column(
                            children: <Widget>[
                              Icon(Icons.add),
                              Text(
                                "New Bike",
                                style: TextStyle(
                                    fontFamily: "Montserrat SemiBold",
                                    fontSize: 10),
                              ),
                            ],
                          ),
                          onPressed: () {
                            createAlertDialog(context);
                            _newBikeNameController.clear();
                            _newBikeRentController.clear();
                            _newBikeLocationController.clear();
                            setState(() {
                              allCycles.clear();
                            });
                          }),
                      FlatButton(
                          //tap on the button to add your cycles.....
                          child: Column(
                            children: <Widget>[
                              Icon(Icons.message),
                              Text(
                                "Chat",
                                style: TextStyle(
                                    fontFamily: "Montserrat SemiBold",
                                    fontSize: 10),
                              ),
                            ],
                          ),
                          onPressed: () {
                            return Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => ChatListPage()));
                          }),
                      FlatButton(
                          //tap on the button to add your cycles.....
                          child: Column(
                            children: <Widget>[
                              Icon(Icons.map),
                              Text(
                                "Map",
                                style: TextStyle(
                                    fontFamily: "Montserrat SemiBold",
                                    fontSize: 10),
                              ),
                            ],
                          ),
                          onPressed: () {
                            return Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => MapsPageRenter()));
                          }),
                    ],
                  )),
                ),
              ),
            ),
            SizedBox(
              height: 400,
              child: Container(
                child: displayBikeList(),
              ),
            ),

            Container(
              margin: EdgeInsets.only(left: 90, top: 1, right: 90, bottom: 0),
              child: Divider(
                // thickness: 1,
                color: Color(0xFF1E1E29),
                height: 1.0,
                indent: 5.0,
              ),
            ),
          ],
        )));
  }
}
