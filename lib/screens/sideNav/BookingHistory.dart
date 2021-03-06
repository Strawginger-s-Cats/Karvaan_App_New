import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:karvaan/models/Cycles.dart';
import 'package:karvaan/models/Request.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:toast/toast.dart';

/* &&&&&&&&&&&&&&&&    For testing purposes only &&&&&&&&&&&& */

List<String> bikeName = <String>[
  'Hero Honda 1',
  'bike 2',
  'bike 3',
  'bike 4',
  'bike 5',
  'bike 6',
  'bike 7',
  'bike 8'
];
List<String> totalFare = <String>['1', '2', '223', '4', '5', '6', '7', '8'];
List<String> bikeOwnderName = <String>[
  'Albus Dumbledore',
  'Owner 2',
  'Ownder 3',
  'Ownder 4',
  'Ownder 5',
  'Ownder 6',
  'Ownder 7',
  'Ownder 8'
];

/* &&&&&&&&&&&&&&&&    For testing purposes only &&&&&&&&&&&& */

class BookingHistory extends StatefulWidget {
  @override
  _BookingHistoryState createState() => _BookingHistoryState();
}

class _BookingHistoryState extends State<BookingHistory> {
  String uId;
  List<Cycles> allBookings = <Cycles>[];
  Future getBookingHistory() async {
    FirebaseFirestore.instance
        .collection('users')
        .doc(uId)
        .collection("history")
        .snapshots()
        .listen((querySnapshot) {
      setState(() {
        querySnapshot.docs.forEach((doc) {
          Cycles request = new Cycles.fromCycles(
              doc["ownerName"], doc["bikeName"], doc["totalFare"]);
          allBookings.add(request);
        });
      });
    });
  }

  getUserId() {
    FirebaseAuth auth = FirebaseAuth.instance;
    if (auth.currentUser != null) {
      uId = auth.currentUser.uid;
    }
  }

  Widget displayWidget() {
    if (allBookings.length == 0) {
      return Center(
        child: Text(
          "You have no bookings!",
          style: TextStyle(
            color: Color(0xFFFFC495),
            fontFamily: "Montserrat SemiBold",
          ),
        ),
      );
    } else {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 24.0),
        child: ListView.builder(
          itemCount: allBookings.length,
          itemBuilder: (BuildContext context, int index) {
            return Padding(
              padding: const EdgeInsets.all(6.0),
              child: Card(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(17.0)),
                color: Color(0xFF282833),
                elevation: 45.0,
                child: Container(
                  padding: EdgeInsets.all(16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Column(
                        children: [
                          Text(
                            //bike name
                            allBookings[index].name,
                            style: TextStyle(
                              fontFamily: 'Montserrat Bold',
                              fontSize: 22.0,
                              color: Color(0xFFe5e5e5),
                            ),
                          ),
                          SizedBox(
                            height: 8.0,
                          ),
                          Text(
                            //owner name
                            allBookings[index].owner,
                            style: TextStyle(
                              fontFamily: 'Montserrat Regular',
                              fontSize: 12.0,
                              color: Color(0xFFCA9367),
                            ),
                          ),
                          SizedBox(
                            height: 16.0,
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            //total fare
                            'Total fare',
                            style: TextStyle(
                                fontFamily: 'Montserrat Regular',
                                fontSize: 12.0,
                                color: Color(0xFFE5E5E5)),
                          ),
                          Row(
                            //with the word Rs and the value of total fare
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                'Rs.',
                                style: TextStyle(
                                  color: Color(0xFFFFF7c6),
                                  fontFamily: 'Montserrat Regular',
                                  fontSize: 12.0,
                                ),
                              ),
                              SizedBox(
                                width: 2.0,
                              ),
                              Text(
                                allBookings[index].pricePerHr,
                                style: TextStyle(
                                  color: Color(0xFFFFF7c6),
                                  fontFamily: 'Montserrat Bold',
                                  fontSize: 24.0,
                                ),
                              )
                            ],
                          )
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
            //   padding: const EdgeInsets.all(5.0),
            //   child: Card(
            //     shape: RoundedRectangleBorder(
            //         borderRadius: BorderRadius.circular(17)),
            //     color: Color(0xFF2C2C37),
            //     child: Padding(
            //       padding: const EdgeInsets.all(8.0),
            //       child: ListTile(
            //         title: Text(
            //           bikeName[index],
            //           // requests[index].renterName,
            //           style: TextStyle(
            //               fontSize: 22,
            //               fontFamily:  "Montserrat Medium",
            //               color: Color(0xFFFFFFFF)),
            //         ),
            //         subtitle: Column(
            //           crossAxisAlignment: CrossAxisAlignment.start,
            //           children: [
            //             SizedBox(
            //               height: 5,
            //             ),
            //             Text(
            //               bikeOwnderName[index],
            //               //requests[index].location.toString(),
            //               style: TextStyle(
            //                   fontSize: 14,
            //                   fontFamily: "Montserrat Regular",
            //                   color: Color(0xFFCA9367)),
            //             ),
            //           ],
            //         ),
            //       ),
            //     ),
            //   ),
            // );
          },
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF1E1E29),
      appBar: AppBar(
        // toolbarHeight: 35,
        backgroundColor: Color(0xFF2C2C37),
        iconTheme: IconThemeData(
          color: Color(0xFFFFC495),
        ),
        centerTitle: true,
        title: Text(
          "Previous Bookings",
          style: TextStyle(
              fontFamily: "Montserrat Bold",
              color: Color(0xFFE5E5E5),
              fontSize: 16),
        ),
        elevation: 0,
      ),
      body: displayWidget(),
    );
  }
}
