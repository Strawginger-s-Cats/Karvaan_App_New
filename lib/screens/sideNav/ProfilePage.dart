import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:karvaan/screens/sideNav/CycleInfo.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:toast/toast.dart';

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  List<String> names =
      <String>[]; //defining lists for names and rates of bicycles..
  List<int> rates = <int>[];
  String _name;
  String _rate;
  final GlobalKey<FormState> _formkey = GlobalKey<FormState>();
  TextEditingController nameController =
      new TextEditingController(); //holding values of textfields in the dialog box....
  TextEditingController rateController = new TextEditingController();
  bool isSwitched = false; //concerning switch......

  void addItemToList() {
    setState(() {
      names.insert(
          0,
          nameController
              .text); //function to add inputs provided by the user to the lists and making a card at the top of the list.
      rates.insert(0, rateController.hashCode);
    });
  }

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
            "MY DASHBOARD",
            style: TextStyle(
                fontFamily: "Montserrat Bold",
                color: Color(0xFFE5E5E5),
                fontSize: 20),
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
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  image: DecorationImage(
                      image: NetworkImage(
                          'https://googleflutter.com/sample_image.jpg'),
                      fit: BoxFit.fill),
                ),
              ),
            ])),

            Container(
              height: 380,
              width: 300,
              color: Color(0xFF1E1E29),
              padding: const EdgeInsets.all(8.0),
              child: Card(
                color: Color(0xFF2C2C37),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Column(
                  children: [
                    ListTile(
                      title: Text(
                        'John Wick',
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
                              '+91 1234567890',
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
                              'johnwick@gmail.com',
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
                          onPressed: () {},
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

            //Divider ..........
            Container(
              margin: EdgeInsets.only(left: 90, top: 1, right: 90, bottom: 0),
              child: Divider(
                // thickness: 1,
                color: Color(0xFFFFC495),
                height: 15.0,
                indent: 5.0,
              ),
            ),

            //Section for User's Cycles......

            Row(
              children: [
                Padding(
                  padding: EdgeInsets.fromLTRB(20.0, 30.0, 20.0, 5.0),
                  child: Text(
                    'My Cycles',
                    style: TextStyle(
                        fontSize: 28,
                        fontFamily: "Montserrat Bold",
                        color: Color(0xFFE5E5E5)),
                  ),
                ),
              ],
            ),

            FloatingActionButton(
                //tap on the button to add your cycles......
                backgroundColor: Color(0xFFFFC495),
                child: Icon(Icons.add),
                mini: true,
                onPressed: () {
                  customDialog(context);
                }),

            //Dynamic Cards.......

            SizedBox(
              height: 200,
              child: Container(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: names.length,
                      itemBuilder: (BuildContext context, int index) {
                        return Card(
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(17)),
                          color: Color(0x001E1E29),
                          child: ListTile(
                            trailing: Container(
                              width: 60,
                              height: 50,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Row(
                                    children: [
                                      SizedBox(
                                        height: 2,
                                      ),
                                      Switch(
                                        value: isSwitched,
                                        onChanged: (value) {
                                          setState(() {
                                            isSwitched = value;
                                            print(isSwitched);
                                          });
                                        },
                                        activeTrackColor:
                                            Colors.lightGreenAccent,
                                        activeColor: Colors.green,
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
                                    image:
                                        AssetImage('assets/images/profile.png'),
                                    fit: BoxFit.fill),
                                shape: BoxShape.rectangle,
                              ),
                            ),
                            title: Text(
                              '${names[index]}',
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
                                    Icon(
                                      Icons.rate_review,
                                      color: Color(0xFFFFC495),
                                      size: 20,
                                    ),
                                    SizedBox(
                                      width: 5,
                                    ),
                                    Text(
                                      'Rate',
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
                                  'Rs. ${rates[index]} per hr.',
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
                ),
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

  //Custom Dialog....

  customDialog(BuildContext context) {
    return showDialog(
        context: context,
        builder: (BuildContext c) {
          return Dialog(
            shape: new RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20.0)),
            child: new Container(
              padding: EdgeInsets.fromLTRB(20.0, 5.0, 20.0, 20.0),
              height: 300.0,
              width: MediaQuery.of(context).size.width,
              decoration: new BoxDecoration(
                borderRadius: BorderRadius.circular(20.0),
                color: Color(0xFFFFF7C6),
              ),
              child: new Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Enter Bike Details',
                        style: TextStyle(
                          fontSize: 20,
                          fontFamily: "Montserrat Bold",
                          color: Color(0xFF1E1E29),
                        ),
                      )
                    ],
                  ),
                  TextFormField(
                    controller: nameController,
                    decoration: InputDecoration(labelText: 'Name'),
                    validator: (String value) {
                      if (value.isEmpty) {
                        return 'Name is Required';
                      }
                    },
                    onSaved: (String value) {
                      _name = value;
                    },
                  ),
                  TextFormField(
                    controller: rateController,
                    decoration:
                        InputDecoration(labelText: 'Enter Rate per hr.'),
                    keyboardType: TextInputType.phone,
                    validator: (String value) {
                      if (value.isEmpty) {
                        return 'Rate is Required';
                      }

                      return null;
                    },
                    onSaved: (String value) {
                      _rate = value;
                    },
                  ),
                  Row(
                    children: [
                      Padding(
                        padding:
                            EdgeInsets.only(left: 2.0, right: 40.0, top: 40.0),
                        child: RaisedButton(
                          onPressed: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ProfilePage(),
                                ));
                          },
                          textColor: Color(0xFF1E1E29),
                          color: Color(0xFFFFF7C6),
                          child: Text("Cancel"),
                          shape: new RoundedRectangleBorder(
                            borderRadius: new BorderRadius.circular(30.0),
                          ),
                        ),
                      ),
                      Padding(
                        padding:
                            EdgeInsets.only(left: 0.0, right: 20.0, top: 40.0),
                        child: RaisedButton(
                          onPressed: () {
                            Navigator.pop(context, addItemToList());
                          },
                          textColor: Color(0xFF1E1E29),
                          color: Color(0xFFFFF7C6),
                          child: Text("Save"),
                          shape: new RoundedRectangleBorder(
                            borderRadius: new BorderRadius.circular(30.0),
                          ),
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ),
          );
        });
  }
}
