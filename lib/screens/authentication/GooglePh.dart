import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:international_phone_input/international_phone_input.dart';
import 'package:karvaan/screens/MapsPage.dart';
import 'package:karvaan/screens/authentication/OTPpage.dart';
import 'package:karvaan/screens/services/authentication.dart';
import 'package:toast/toast.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class GooglePh extends StatefulWidget {
  @override
  _GooglePhState createState() => _GooglePhState();
}

class _GooglePhState extends State<GooglePh> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final databaseReference = Firestore.instance;

  String getUId() {
    final User user = _auth.currentUser;
    final uid = user.uid;
    return uid;
  }

  User getUser() {
    final User user = _auth.currentUser;

    return user;
  }

  void createRecord(String email, String name, String phoneNo) async {
    await databaseReference.collection("users").document(getUId()).set({
      'email': email,
      'name': name,
      'phoneNo': phoneNo,
    });
  }

  String phoneNumber = "", verificationId, smsCode;
  bool codeSent = false;
  String phoneIsoCode = "IN";

  void onPhoneNumberChange(
      String number, String internationalizedPhoneNumber, String isoCode) {
    setState(() {
      phoneNumber = number;
      phoneIsoCode = isoCode;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Color(0xFFFFC495),
        appBar: AppBar(
          // toolbarHeight: 35,
          backgroundColor: Color(0xFFFFC495),
          iconTheme: IconThemeData(
            color: Color(0xFF1E1E29),
          ),
          elevation: 0,
        ),
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                  margin: EdgeInsets.fromLTRB(40, 10, 40, 0),
                  child: Text(
                    "Enter Phone Number For Verification",
                    textAlign: TextAlign.left,
                    style: TextStyle(
                      fontSize: 30,
                      fontFamily: 'Montserrat SemiBold',
                      color: Color(0xFF1E1E29),
                    ),
                  )),
              Container(
                  margin: EdgeInsets.fromLTRB(40, 5, 40, 0),
                  child: Text(
                    "This number will be used for all ride-related communication.You shall receive an SMS with a code for verification.",
                    style: TextStyle(
                      fontSize: 15,
                      fontFamily: 'Montserrat Medium',
                      color: Color(0xFF454551),
                    ),
                  )),
              Container(
                margin: EdgeInsets.fromLTRB(40, 30, 40, 0),
                child: InternationalPhoneInput(
                    errorText: "Please Enter a valid phone number!",
                    decoration: InputDecoration.collapsed(
                        hintText: 'Enter Phone Number',
                        hintStyle: TextStyle(
                            fontFamily: "Montserrat Medium", fontSize: 15)),
                    onPhoneNumberChange: onPhoneNumberChange,
                    initialPhoneNumber: phoneNumber,
                    initialSelection: phoneIsoCode,
                    showCountryFlags: true,
                    showCountryCodes: true),
              ),
              new Padding(
                  padding: EdgeInsets.fromLTRB(40, 0, 40, 0),
                  child: new Divider(
                    thickness: 2,
                    color: Color(0xFFFFF7C6),
                  )),
              Container(
                  margin: EdgeInsets.fromLTRB(25, 160, 25, 20),
                  height: 56,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(17),
                      color: Color(0xFF1E1E29)),
                  child: FlatButton(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Spacer(),
                        Text(
                          "Next",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontFamily: 'Montserrat SemiBold',
                              fontSize: 16,
                              color: Color(0xFFE5E5E5)),
                        ),
                        Spacer(),
                        Icon(
                          Icons.arrow_forward,
                          color: Color(0xFFFFF7C6),
                        )
                      ],
                    ),
                    onPressed: () {
                      print(phoneNumber);
                      // Toast.show("Incomplete!", context,
                      //     duration: Toast.LENGTH_SHORT);
                      createRecord(getUser().email, getUser().displayName,
                          "+91" + phoneNumber);

                      return Navigator.push(context,
                          MaterialPageRoute(builder: (context) => MapsPage()));
                    },
                  ))
            ],
          ),
        ));
  }
}
