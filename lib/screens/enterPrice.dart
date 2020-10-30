import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:karvaan/models/Request.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:toast/toast.dart';

class enterPrice extends StatefulWidget {
  @override
  _enterPriceState createState() => _enterPriceState();
}

class _enterPriceState extends State<enterPrice> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF1E1E29),
      appBar: AppBar(
        backgroundColor: Color(0xFF282833),
        iconTheme: IconThemeData(
          color: Color(0xFFFFC495),
        ),
        title: Text(
          'Enter Amount',
          style: TextStyle(
            fontFamily: "Montserrat Bold",
            color: Color(0xFFFFC495),
            fontSize: 18,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          SizedBox(
            height: 40.0,
          ),
          Padding(
            padding: const EdgeInsets.all(32.0),
            child: TextField(
              autofocus: true,
              cursorColor: Color(0xFFFFF7C6),
              enableInteractiveSelection: true,
              style: TextStyle(color: Color(0xFFFFF7c6),
              fontFamily: 'Montserrat Medium'),
              decoration: InputDecoration(
                  hintText: 'Enter the amount',
                  hintStyle: TextStyle(
                      color: Color(0xFF626262),
                      fontFamily: 'Montserrat Regular')),
            ),
          ),
          SizedBox(
            height: 20.0,
          ),
          FlatButton(
            color: Color(0xFFFFF7C6),
            child: Text(
              'Pay',
              style: TextStyle(
                fontFamily: 'Montserrat Bold',
                color: Color(0xFF1E1E29),
              ),
            ),
            onPressed: () {
              //enter on pressed code here
            },
          )
        ],
      ),
    );
  }
}
