import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:karvaan/screens/MapsPage.dart';
import 'package:karvaan/screens/sideNav/profile/Dashboard.dart';

class About extends StatefulWidget {
  @override
  _AboutState createState() => _AboutState();
}

class _AboutState extends State<About> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF1E1E29),
      appBar: AppBar(
        backgroundColor: Color(0xFF282833),
        iconTheme: IconThemeData(
          color: Color(0xFFFFC495),
        ),
        centerTitle: true,
        title: Text(
          "About Karvaan",
          style: TextStyle(
              fontFamily: "Montserrat Bold",
              color: Color(0xFFFFC495),
              fontSize: 18),
        ),
        elevation: 0,
        // actions: <Widget>[
        //   Padding(
        //     padding: EdgeInsets.only(right: 20.0),
        //   ),
        // ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          SizedBox(
            height: 40,
          ),
          Container(
            padding: EdgeInsets.fromLTRB(16.0, 0.0, 16.0, 20.0),
            //margin: EdgeInsets.only(bottom: 22),
            child: Text(
              'Welcome to the world of sharing and caring',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Montserrat Regular',
                color: Color(0xFFE5E5E5),
                fontSize: 22,
              ),
            ),
          ),
          SizedBox(
            height: 20.0,
          ),
          Container(
            child: Image.asset(
              'assets/images/ic_launcher_round.png',
              height: 120,
            ),
          ),
          Container(
            width: 20,
            padding: EdgeInsets.fromLTRB(20.0, 40.0, 20.0, 40.0),
            child: Row(
              children: [
                Flexible(
                    child: new Text(
                  '\" Karvaan is a simple bicycle sharing app that enables its users to share and rent bicycles. Its intuitive UI and seamless security features promises the users a wonderful experience \"',
                  style: TextStyle(
                    fontFamily: 'Montserrat Medium',
                    color: Color(0xFFCA9367),
                    fontSize: 16,
                    // letterSpacing: -0.40,
                  ),
                  textAlign: TextAlign.center,
                ))
              ],
            ),
          ),
          Container(
            margin: EdgeInsets.only(left: 70, top: 10, right: 70, bottom: 0),
            child: Divider(
              thickness: 2,
              color: Color(0xFF4E4E4E),
              height: 15.0,
              indent: 5.0,
            ),
          ),
          Container(
            padding: EdgeInsets.fromLTRB(18.0, 20.0, 10.0, 10.0),
            child: Text(
              'DEVELOPERS',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Montserrat Bold',
                color: Color(0xFFFFFFFF),
                fontSize: 25,
              ),
            ),
          ),
          Container(
              padding: EdgeInsets.fromLTRB(18.0, 10.0, 10.0, 10.0),
              child: Column(
                children: [
                  Text(
                    'Strawginger-s-Cats:',
                    style: TextStyle(
                      fontFamily: 'Montserrat Medium',
                      color: Color(0xFFFFC495),
                      fontSize: 18,
                    ),
                  ),
                  SizedBox(
                    height: 8.0,
                  ),
                  Column(
                    children: [
                      Text(
                        'Anushree',
                        style: TextStyle(
                          fontFamily: 'Montserrat SemiBold',
                          color: Color(0xFFFFFFFF),
                          fontSize: 17,
                        ),
                      ),
                      Text(
                        'Kushagra',
                        style: TextStyle(
                          fontFamily: 'Montserrat SemiBold',
                          color: Color(0xFFFFFFFF),
                          fontSize: 17,
                        ),
                      ),
                      Text(
                        'Simran',
                        style: TextStyle(
                          fontFamily: 'Montserrat SemiBold',
                          color: Color(0xFFFFFFFF),
                          fontSize: 17,
                        ),
                      ),
                      Text(
                        'Vibhanshu',
                        style: TextStyle(
                          fontFamily: 'Montserrat SemiBold',
                          color: Color(0xFFFFFFFF),
                          fontSize: 17,
                        ),
                      ),
                    ],
                  )
                ],
              )),
        ],
      ),
    );
  }
}
