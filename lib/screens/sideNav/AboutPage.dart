import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:karvaan/screens/MapsPage.dart';
import 'package:karvaan/screens/sideNav/ProfilePage.dart';

class About extends StatefulWidget {
  @override
  _AboutState createState() => _AboutState();
}

class _AboutState extends State<About> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF282833),
        iconTheme: IconThemeData(
          color: Color(0xFFFFC495),
        ),
        centerTitle: true,
        title: Text(
          "ABOUT KARVAAN....",
          style: TextStyle(
              fontFamily: "Montserrat Bold",
              color: Color(0xFFFFC495),
              fontSize: 18),
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
            SizedBox(
              height: 30,
              width: 50,
            ),
            Container(
              padding: EdgeInsets.fromLTRB(18.0, 20.0, 10.0, 10.0),
              child: Text(
                'Karvaan: Redefining Limits.....',
                textAlign: TextAlign.left,
                style: TextStyle(
                  fontFamily: 'Montserrat Medium',
                  fontStyle: FontStyle.italic,
                  color: Color(0xFFFFC495),
                  fontSize: 18,
                ),
              ),
            ),
            Container(
              child: Image.asset(
                'assets/images/ic_launcher_round.png',
                height: 120,
              ),
            ),
            Container(
              width: 20,
              padding: EdgeInsets.fromLTRB(20.0, 20.0, 20.0, 10.0),
              child: Row(
                children: [
                  Flexible(
                      child: new Text(
                    "Karvaan, a Cycle Lending App enables people to book a cycle for rent. One can also lend Cycles and get paid in return!!\nThe app with its flexible features paves the way for easy and uninterrupted journey and thus redefines a person's limitations!\n\nSo, set back and be ready to enjoy this wonderful 'Karvaan'. ",
                    style: TextStyle(
                      fontFamily: 'Montserrat Regular',
                      fontStyle: FontStyle.italic,
                      color: Color(0xFFCA9367),
                      fontSize: 16,
                      // letterSpacing: -0.40,
                    ),
                  ))
                ],
              ),
            ),
            Container(
              margin: EdgeInsets.only(left: 70, top: 10, right: 70, bottom: 0),
              child: Divider(
                // thickness: 1,
                color: Color(0xFFFFC495),
                height: 15.0,
                indent: 5.0,
              ),
            ),
            Container(
              padding: EdgeInsets.fromLTRB(18.0, 20.0, 10.0, 10.0),
              child: Column(
                children: [
                  Text(
                    'Wanna Try??',
                    style: TextStyle(
                      fontFamily: 'Montserrat SemiBold',
                      color: Color(0xFFFFC495),
                      fontSize: 22,
                    ),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      RaisedButton(
                          child: Text(
                            'Rent a Cycle',
                            style: TextStyle(color: Colors.blue, fontSize: 16),
                          ),
                          color: Color(0xFFFFC495),
                          onPressed: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => MapsPage()));
                          }),
                      RaisedButton(
                          child: Text(
                            'Lend a Cycle',
                            style: TextStyle(color: Colors.blue, fontSize: 16),
                          ),
                          color: Color(0xFFFFC495),
                          onPressed: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => ProfilePage()));
                          }),
                    ],
                  )
                ],
              ),
            ),
            Container(
              margin: EdgeInsets.only(left: 70, top: 10, right: 70, bottom: 0),
              child: Divider(
                // thickness: 1,
                color: Color(0xFFFFC495),
                height: 10.0,
                indent: 5.0,
              ),
            ),
            Container(
              padding: EdgeInsets.fromLTRB(18.0, 20.0, 10.0, 10.0),
              child: Text(
                '\nDEVELOPERS',
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
                child: Row(
                  children: [
                    Text(
                      'Strawginger-s-Cats:',
                      style: TextStyle(
                        fontFamily: 'Montserrat Medium',
                        color: Color(0xFFFFC495),
                        fontSize: 18,
                      ),
                    ),
                    Column(
                      children: [
                        Text(
                          '      Anushree',
                          style: TextStyle(
                            fontFamily: 'Montserrat SemiBold',
                            color: Color(0xFFFFFFFF),
                            fontSize: 17,
                          ),
                        ),
                        Text(
                          '      Kushagra',
                          style: TextStyle(
                            fontFamily: 'Montserrat SemiBold',
                            color: Color(0xFFFFFFFF),
                            fontSize: 17,
                          ),
                        ),
                        Text(
                          '      Simran',
                          style: TextStyle(
                            fontFamily: 'Montserrat SemiBold',
                            color: Color(0xFFFFFFFF),
                            fontSize: 17,
                          ),
                        ),
                        Text(
                          '      Vibhanshu',
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
      ),
    );
  }
}
