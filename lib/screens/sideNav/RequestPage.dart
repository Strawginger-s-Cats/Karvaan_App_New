import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:karvaan/models/Request.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:toast/toast.dart';

class RequestPage extends StatefulWidget {
  @override
  _RequestPageState createState() => _RequestPageState();
}

class _RequestPageState extends State<RequestPage> {
  String uId;
  List<Request> requests = <Request>[];

  getUserId() {
    FirebaseAuth auth = FirebaseAuth.instance;
    if (auth.currentUser != null) {
      uId = auth.currentUser.uid;
    }
  }

  Future getRentRequestsFromFirebase() async {
    FirebaseFirestore.instance
        .collection('users')
        .doc(uId)
        .collection("rentRequests")
        .snapshots()
        .listen((querySnapshot) {
      setState(() {
        querySnapshot.docs.forEach((doc) {
          Request request = new Request(doc["renterId"], doc["renterName"],
              doc["renterPhone"], doc["location"]);
          requests.add(request);
        });
      });
    });
  }

  Future createChatDoc(String renterId) async {
    Firestore.instance //adding new lender bike document
        .collection('chats')
        .doc(uId + renterId) //chat doc is named as lenderId + renterId
        .set({'bookingFinal': false});
  }

  Future<void> deleteRequest(String name) {
    Firestore.instance
        .collection('users')
        .doc(uId)
        .collection("renterRequests")
        .doc(name)
        .delete();
  }

  @override
  void initState() {
    getUserId();
    getRentRequestsFromFirebase();
    super.initState();
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
          "Chat Requests",
          style: TextStyle(
              fontFamily: "Montserrat Bold",
              color: Color(0xFFE5E5E5),
              fontSize: 16),
        ),
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: ListView.builder(
          itemCount: requests.length,
          itemBuilder: (BuildContext context, int index) {
            return Padding(
              padding: const EdgeInsets.all(5.0),
              child: Card(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(17)),
                color: Color(0xFF2C2C37),
                child: ListTile(
                  leading: Container(
                    height: 60,
                    width: 60,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(60),
                      image: DecorationImage(
                          image: AssetImage('assets/images/profile.png'),
                          fit: BoxFit.fill),
                      shape: BoxShape.rectangle,
                    ),
                  ),
                  title: Text(
                    requests[index].renterName,
                    style: TextStyle(
                        fontSize: 18,
                        fontFamily: "Montserrat Medium",
                        color: Color(0xFFE5E5E5)),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        height: 5,
                      ),
                      Row(
                        children: [
                          Icon(
                            MdiIcons.bicycle,
                            color: Color(0xFFFFC495),
                            size: 20,
                          ),
                          SizedBox(
                            width: 5,
                          ),
                          Text(
                            requests[index].location.toString(),
                            style: TextStyle(
                                fontSize: 14,
                                fontFamily: "Montserrat Regular",
                                color: Color(0xFFCA9367)),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          FlatButton(
                            child: Row(
                              children: [
                                Icon(
                                  MdiIcons.close,
                                  color: Color(0xFFFFF7C6),
                                  size: 19,
                                ),
                                SizedBox(
                                  width: 1,
                                ),
                                Text(
                                  "Decline",
                                  style: TextStyle(
                                      fontFamily: "Montserrat Regular",
                                      color: Color(0xFFFFF7C6)),
                                )
                              ],
                            ),
                            onPressed: () {
                              print((requests[index].renterName));
                              // setState(() {
                              deleteRequest(requests[index].renterName);
                              // });
                            },
                          ),
                          FlatButton(
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  MdiIcons.check,
                                  color: Color(0xFFFFF7C6),
                                  size: 19,
                                ),
                                SizedBox(
                                  width: 1,
                                ),
                                Text(
                                  "Accept",
                                  style: TextStyle(
                                      fontFamily: "Montserrat Regular",
                                      color: Color(0xFFFFF7C6)),
                                )
                              ],
                            ),
                            onPressed: () {
                              Toast.show("Incomplete!", context,
                                  duration: Toast.LENGTH_SHORT);
                              createChatDoc(requests[index].renterId);
                              deleteRequest(requests[index].renterName);
                            },
                          )
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
