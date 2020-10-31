import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:karvaan/screens/MapsPage.dart';
import 'package:karvaan/screens/authentication/GooglePh.dart';
import 'package:karvaan/screens/authentication/PhoneVerifPage.dart';
import 'package:toast/toast.dart';
import 'package:flutter_auth_buttons/flutter_auth_buttons.dart';
import 'package:google_sign_in/google_sign_in.dart';

class LogInPage extends StatefulWidget {
  @override
  _LogInPageState createState() => _LogInPageState();
}

class _LogInPageState extends State<LogInPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  FirebaseUser _user;
  final GoogleSignIn googleSignIn = new GoogleSignIn();

  static bool isSignIn = false;

  Future<void> handleSignIn() async {
    GoogleSignInAccount googleSignInAccount = await googleSignIn.signIn();
    GoogleSignInAuthentication googleSignInAuthentication =
        await googleSignInAccount.authentication;

    AuthCredential credential = GoogleAuthProvider.getCredential(
        idToken: googleSignInAuthentication.idToken,
        accessToken: googleSignInAuthentication.accessToken);

    //AuthResult result = (await _auth.signInWithCredential(credential));

    _user = (await _auth.signInWithCredential(credential)).user;

    setState(() {
      isSignIn = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Color(0xFFFFC495),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 128, 24, 0),
              child: Container(
                child: Image(image: AssetImage('assets/images/log.png')),
              ),
            ),
            Container(
                alignment: Alignment.center,
                margin: EdgeInsets.fromLTRB(20, 50, 20, 0),
                child: Text(
                  "Welcome",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Montserrat Bold',
                    color: Color(0xFF1E1E29),
                    fontSize: 40,
                    letterSpacing: -0.76,
                  ),
                )),
            Container(
                alignment: Alignment.center,
                margin: EdgeInsets.fromLTRB(20, 0, 20, 30),
                child: Text(
                  "Join the world of sharing and caring",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Montserrat Regular',
                    color: Colors.grey[700],
                    fontSize: 15,
                  ),
                )),
            Container(
                height: 56,
                decoration: BoxDecoration(
                  //to decorate box with circular edges
                  borderRadius: BorderRadius.circular(17),
                  color: Color(0xFF1E1E29),
                ),
                margin: EdgeInsets.fromLTRB(20, 30, 20, 0),
                child: FlatButton(
                  onPressed: () {
                    // Toast.show("Incomplete!", context,
                    //     duration: Toast.LENGTH_SHORT);
                    return Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => PhoneVerifPage()));
                  },
                  child: Text("Continue with Phone Number",
                      style: TextStyle(
                          fontSize: 15,
                          fontFamily: 'Montserrat SemiBold',
                          color: Color(0xFFE5E5E5))),
                )),
            Container(
              height: 56,
              decoration: BoxDecoration(
                //to decorate box with circular edges
                borderRadius: BorderRadius.circular(17),
                color: Color(0xFF1E1E29),
              ),
              margin: EdgeInsets.fromLTRB(20, 20, 20, 0),
              child: GoogleSignInButton(
                onPressed: () {
                  handleSignIn();

                  return Navigator.push(context,
                      MaterialPageRoute(builder: (context) => GooglePh()));
                },
                borderRadius: 17.0,
                darkMode: true,
                centered: true,
                splashColor: Color(0xFF1E1E29),
                //child:
                //Text("Sign in with Google",style:TextStyle(fontSize: 15,fontFamily: 'Montserrat',color: Color(0xFFE5E5E5))
              ),
            ),
          ],
        ));
  }
}
