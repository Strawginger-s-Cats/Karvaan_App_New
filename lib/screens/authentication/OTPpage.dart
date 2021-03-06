import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:karvaan/screens/MapsPage.dart';
import 'package:karvaan/screens/authentication/PhoneVerifPage.dart';
import 'package:karvaan/screens/authentication/SignUpPage.dart';
import 'package:karvaan/screens/services/authentication.dart';
import 'package:otp_text_field/otp_field.dart';
import 'package:otp_text_field/style.dart';
import 'package:toast/toast.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

//Begin.....

final int user = 0;

class OTPpage extends StatefulWidget {
  //defined a class, OTPpage
  final phoneNumber;

  OTPpage(this.phoneNumber); //constructor which takes phoneNumber as parameter
  @override
  _OTPpageState createState() => _OTPpageState(phoneNumber);
}

class _OTPpageState extends State<OTPpage> {
  //Firebase Authentication
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final databaseReference = Firestore.instance; //using Firestore instance

  String inputData() {
    final User user = _auth.currentUser;
    final uid = user.uid;

    return uid;

    // here you write the codes to input the data into firestore
  }

  void createRecord(String phoneNo) async {
    await databaseReference.collection("users").document(inputData()).setData({
      //creating records of the user..
      'phoneNo': phoneNo,
      'name': "",
      'email': "",
    });
  }

  String phoneNumber; //constructor for taking phone number
  _OTPpageState(this.phoneNumber);

  String verificationId, smsCode; //constructor for smscode/verification id
  bool codeSent = false;

  @override
  void initState() {
    verifyPhone(phoneNumber); //verifying phone number
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    //Starting with the app UI
    return Scaffold(
      appBar: AppBar(
        // toolbarHeight: 35,
        backgroundColor: Color(0xFFFFC495),
        iconTheme: IconThemeData(
          color: Color(0xFF1E1E29),
        ),
        elevation: 0,
      ),
      backgroundColor: Color(0xFFFFC495),
      body: SingleChildScrollView(
        //Scrollable Screen
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            //Child 1: Container for Heading
            Container(
              alignment: Alignment.center,
              margin: EdgeInsets.fromLTRB(40, 10, 40, 0),
              child: Text(
                "Please wait for the OTP sent to your number.",
                textAlign: TextAlign.left,
                style: TextStyle(
                  fontFamily: 'Montserrat SemiBold',
                  color: Color(0xFF1E1E29),
                  fontSize: 30,
                ),
              ),
            ),

            //Child 2: Container for OTP text field
            Container(
              margin: EdgeInsets.fromLTRB(35, 20, 100, 0),
              child: OTPTextField(
                length: 6,
                width: MediaQuery.of(context).size.width,
                fieldWidth: 30,
                style: TextStyle(
                    fontSize: 20,
                    color: Color(0xFF454551),
                    fontFamily: 'Montserrat Medium'),
                textFieldAlignment: MainAxisAlignment.spaceAround,
                fieldStyle: FieldStyle.underline,
                onChanged: (pin) {
                  setState(() {
                    this.smsCode = pin;
                  });
                },
              ),
            ),

            //Child 3: Column
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                //Child 3.1: If you haven't received OTP....
                Container(
                  margin: EdgeInsets.fromLTRB(40, 20, 40, 0),
                  child: Text(
                    "Didn't receive the OTP?",
                    style: TextStyle(
                        fontFamily: 'Montserrat Medium',
                        fontSize: 14,
                        color: Color(0xFF454551D1)),
                  ),
                ),

                //Child 3.2: Resend OTP...
                Container(
                  margin: EdgeInsets.fromLTRB(40, 10, 40, 0),
                  child: new GestureDetector(
                    onTap: () {
                      Toast.show("Resending...", context,
                          duration: Toast.LENGTH_SHORT);
                      verifyPhone(phoneNumber);
                    },
                    child: Text('Resend OTP',
                        style: TextStyle(
                            fontFamily: 'Montserrat Medium',
                            fontSize: 16,
                            color: Color(0xFFFFF7C6))),
                  ),
                )
              ],
            ),

            //Child 4: Verifying the user....
            Container(
                height: 56,
                decoration: BoxDecoration(
                  //to decorate box with circular edges
                  borderRadius: BorderRadius.circular(17),
                  color: Color(0xFF1E1E29),
                ),
                margin: EdgeInsets.fromLTRB(25, 200, 25, 20),
                child: FlatButton(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Spacer(),
                      Text(
                        "Verify",
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
                    print(codeSent);
                    if (codeSent) {
                      AuthService().signInWithOtp(smsCode, verificationId);
                      createRecord(phoneNumber);
                      return Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => SignUpPage()));
                    } else {
                      // Toast.show("Error! Try Again.", context,
                      //     duration: Toast.LENGTH_SHORT);
                      return Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => PhoneVerifPage()));
                    }
                  },
                )),
          ],
        ),
      ),
    );
  }

  Future<void> verifyPhone(phoneNumber) async {
    //method for verifying phone number
    final PhoneVerificationCompleted verified = (AuthCredential authResult) {
      AuthService().signIn(authResult);
    };

    final PhoneVerificationFailed
        verificationfailed = //method, if verification fails
        (FirebaseAuthException authException) {
      print('${authException.message}');
    };

    final PhoneCodeSent smsSent = (String verId, [int forceResend]) {
      //method, sending sms code
      this.verificationId = verId;
      setState(() {
        this.codeSent = true;
      });
    };

    final PhoneCodeAutoRetrievalTimeout autoTimeOut = (String verId) {
      //method, timeout
      this.verificationId = verId;
    };

    await FirebaseAuth.instance.verifyPhoneNumber(
        //awaiting firebase authentication......
        phoneNumber: phoneNumber,
        timeout: const Duration(seconds: 60),
        verificationCompleted: verified,
        verificationFailed: verificationfailed,
        codeSent: smsSent,
        codeAutoRetrievalTimeout: autoTimeOut);
  }
}
