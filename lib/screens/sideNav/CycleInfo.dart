import 'package:flutter/material.dart';
import 'package:karvaan/screens/services/SharedPref.dart';
import 'package:karvaan/screens/sideNav/ProfilePage.dart';

class CycleInfo extends StatefulWidget {
  @override
  _CycleInfoState createState() => _CycleInfoState();
}

class _CycleInfoState extends State<CycleInfo> {
  var nameString = '';
  var rateString = '';
  String _name;
  String _rate;

  final GlobalKey<FormState> _formkey = GlobalKey<FormState>();

  Widget _buildName() {
    return TextFormField(
      decoration: InputDecoration(labelText: 'Name'),
      validator: (String value) {
        if (value.isEmpty) {
          return 'Name is Required';
        }
      },
      onSaved: (String value) {
        _name = value;
        StorageUtil.putString("name", _name);
      },
    );
  }

  Widget _buildRate() {
    return TextFormField(
      decoration: InputDecoration(labelText: 'Enter Rate per hr.'),
      keyboardType: TextInputType.phone,
      validator: (String value) {
        if (value.isEmpty) {
          return 'Rate is Required';
        }

        return null;
      },
      onSaved: (String value) {
        _rate = value;
        StorageUtil.putString("rate", _rate);
      },
    );
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
      body: Container(
        margin: EdgeInsets.all(24),
        child: Form(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildName(),
              _buildRate(),
              SizedBox(
                height: 100,
              ),
              RaisedButton(
                child: Text(
                  'Save',
                  style: TextStyle(color: Colors.blue, fontSize: 16),
                ),
                onPressed: () {
                  if (!_formkey.currentState.validate()) {
                    return;
                  } else {
                    _formkey.currentState.save();
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ProfilePage(),
                        ));
                  }

                  //Send to API
                },
              )
            ],
          ),
        ),
      ),
    );
  }
}
