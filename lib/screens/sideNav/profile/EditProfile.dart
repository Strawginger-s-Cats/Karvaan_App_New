import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:toast/toast.dart';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:image_picker/image_picker.dart';

class EditProfile extends StatefulWidget {
  final String currentUserId;
  EditProfile(
      this.currentUserId); //Constructor taking currentUserId as parameter
  @override
  _EditProfileState createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  String uId,
      name = "",
      phone = '',
      email = ""; //Default values for the fields.
  String _imageUrl, profImagePath;
  bool isLoading = false;
  User user;
  TextEditingController
      _emailController; //controllers for email and username fields, kept private.
  TextEditingController _usernameController;
  bool _isEditingText = false;
  bool _isEditingUser = false;

  getUserId() {
    //getting user id from database, cloud firestore
    FirebaseAuth auth = FirebaseAuth.instance;
    if (auth.currentUser != null) {
      uId = auth.currentUser.uid;
    }
  }

  Future getUserInfo() async {
    //to get user information
    FirebaseFirestore.instance
        .collection('users')
        .doc(uId)
        .snapshots()
        .listen((snapshot) {
      setState(() {
        name = snapshot["name"];
        email = snapshot["email"];
        phone = snapshot["phoneNo"];
      });
    });
  }

  Future updateInfo() async {
    //add new bike location(lat and long) to firebase database

    FirebaseFirestore.instance //adding new lender bike document
        .collection('users')
        .doc(uId)
        .update({
      'name': name,
      'email': email,
    });
  }

  @override
  void initState() {
    getUserId();
    getUserInfo();
    super.initState();
    //setting initial values of fields of email,username....
    _emailController = TextEditingController(text: email);
    _usernameController = TextEditingController(text: name);
    var ref =
        FirebaseStorage.instance.ref().child('users/' + uId + '/profile.png');
    ref.getDownloadURL().then((loc) => setState(() => _imageUrl = loc));
  }

  @override
  Widget build(BuildContext context) {
    //UI for the Edit Profile Page
    return Scaffold(
      backgroundColor: Color(0xFF1E1E29),
      appBar: AppBar(
        backgroundColor: Color(0xFF2C2C37),
        leading: IconButton(
          icon: Icon(
            Icons.close,
            color: Color(0xFFFFF7C6),
          ),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        centerTitle: true,
        title: Text(
          "Edit Profile",
          style: TextStyle(
              fontFamily: "Montserrat Bold",
              color: Color(0xFFE5E5E5),
              fontSize: 16),
        ),
        actions: [
          IconButton(
            icon: Icon(
              Icons.check,
              color: Color(0xFFFFF7C6),
            ),
            onPressed: () {
              updateInfo();
              uploadProfilePicture(
                  profImagePath); //saves and updates the changes in dashboard..
              Toast.show("Changes Saved", context,
                  duration: Toast.LENGTH_SHORT);
            },
          ),
        ],
      ),
      body: Container(
        padding: EdgeInsets.only(left: 16, top: 25, right: 16),
        child: ListView(
          children: [
            SizedBox(
              height: 15,
            ),
            Center(
              child: Stack(
                children: [
                  Container(
                    width: 130,
                    height: 130,
                    decoration: BoxDecoration(
                      border: Border.all(
                          width: 4,
                          color: Theme.of(context).scaffoldBackgroundColor),
                      boxShadow: [
                        BoxShadow(
                            spreadRadius: 2,
                            blurRadius: 10,
                            color: Colors.black.withOpacity(0.1),
                            offset: Offset(0, 10))
                      ],
                      shape: BoxShape.circle,
                      image: DecorationImage(
                        fit: BoxFit.cover,
                        // image: NetworkImage(
                        //     'https://googleflutter.com/sample_image.jpg'),
                        image: _imageUrl == null
                            ? NetworkImage(
                                'https://firebasestorage.googleapis.com/v0/b/karvaan-app-15704.appspot.com/o/users%2Fdownload%20(1).png?alt=media&token=4337d9ee-45dd-4993-a794-ca4a70d7b911')
                            : NetworkImage(_imageUrl),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: GestureDetector(
                      child: Container(
                        height: 40,
                        width: 40,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            width: 4,
                            color: Theme.of(context).scaffoldBackgroundColor,
                          ),
                          color: Color(0xFFFFC495),
                        ),
                        child: Icon(
                          Icons.edit,
                          color: Colors.black,
                        ),
                      ),
                      onTap: () async {
                        File image = await ImagePicker.pickImage(
                            source: ImageSource.gallery);
                        print(image.path);
                        setState(() {
                          profImagePath = image.path.toString(); //Image Picker
                        });
                        ;
                      },
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 20,
            ),
            Container(
              height: 230,
              child: Card(
                color: Color(0xFF2C2C37),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Column(
                  children: [
                    ListTile(
                      title: _editUserNameField(),
                    ),
                    GestureDetector(
                      child: Container(
                        margin: EdgeInsets.only(top: 5),
                        color: Colors.grey[600],
                        padding: EdgeInsets.only(left: 18, top: 4, right: 7),
                        child: Row(
                          children: [
                            Column(
                              children: [
                                SizedBox(
                                  height: 2,
                                ),
                                Text(
                                  'Phone',
                                  style: TextStyle(
                                      fontSize: 14,
                                      fontFamily: "Montserrat Medium",
                                      color: Color(0xFFE5E5E5)),
                                ),
                                Text(
                                  phone,
                                  style: TextStyle(
                                      fontSize: 15,
                                      fontFamily: "Montserrat Medium",
                                      color: Color(0xFFE5E5E5)),
                                )
                              ],
                            ),
                            IconButton(
                              padding: EdgeInsets.only(
                                  left: 130, top: 4, right: 2, bottom: 2),
                              icon: Icon(
                                Icons.https,
                                color: Color(0xFF1E1E29),
                              ),
                              onPressed: () {},
                            ),
                          ], //Can't edit the phone number
                        ),
                      ),
                      onTap: () async {
                        Toast.show("Can't Edit", context,
                            duration: Toast.LENGTH_SHORT);
                      },
                    ),

                    //Let's Edit email......
                    GestureDetector(
                      child: Container(
                        margin: EdgeInsets.only(top: 15),
                        padding: EdgeInsets.only(left: 1, top: 4, right: 10),
                        child: Column(
                          children: [
                            SizedBox(
                              height: 2,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: EdgeInsets.fromLTRB(
                                      45.0, 10.0, 10.0, 0.0),
                                  child: Text(
                                    'Email',
                                    style: TextStyle(
                                        fontSize: 14,
                                        fontFamily: "Montserrat Medium",
                                        color: Color(0xFFCA9367)),
                                  ),
                                ),
                              ],
                            ),
                            _editEmailTextField(),
                          ],
                        ),
                      ),
                      onTap: () async {},
                    ),
                  ],
                ),
              ),
            ),
            Container(
              margin: EdgeInsets.only(top: 5),
              child: Text(
                'Tap on the fields to edit them',
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 13,
                    fontFamily: "Montserrat Medium",
                    color: Color(0xFFCA9367)),
              ),
            )
          ],
        ),
      ),
    );
    void showToast(String msg, {int duration, int gravity}) {
      Toast.show(msg, context, duration: duration, gravity: gravity);
    }
  }

  uploadProfilePicture(String imagePath) async {
    //uploading profile picture,specifying path
    File file = File(imagePath);
    try {
      await FirebaseStorage.instance
          .ref()
          .child('users/' + uId + '/profile.png')
          .putFile(file);
    } on FirebaseException catch (e) {
      print(e);
    }
  }

  Widget _editEmailTextField() {
    //specifically for email edit.....
    if (_isEditingText)
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Center(
          child: TextField(
            style: TextStyle(
              color: Color(0xFFE5E5E5),
              fontFamily: 'Montserrat Regular',
            ),
            onSubmitted: (newValue) {
              setState(() {
                email = newValue;
                _isEditingText = false;
              });
            },
            autofocus: true,
            controller: _emailController,
          ),
        ),
      );
    return InkWell(
      onTap: () {
        setState(() {
          _isEditingText = true;
        });
      },
      child: Row(
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 17),
            child: Text(_isEditingText ?
              _emailController.text: email,
              style: TextStyle(
                  color: Color(0xFFE5E5E5),
                  fontSize: 16.0,
                  fontFamily: "Montserrat Medium"),
            ),
          ),
        ],
      ),
    );
  }

  Widget _editUserNameField() {
    //specifically for Username edit.....
    if (_isEditingUser)
      return Center(
        child: TextField(
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Color(0xFFFFC495),
            fontFamily: 'Montserrat Regular',
          ),
          onSubmitted: (newValue) {
            setState(() {
              name = newValue;
              _isEditingUser = false;
            });
          },
          autofocus: true,
          controller: _usernameController,
        ),
      );
    return InkWell(
      onTap: () {
        setState(() {
          _isEditingUser = true;
        });
      },
      child: Text(
        _isEditingUser ? _usernameController.text :name,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 28.0,
          fontFamily: "Montserrat Bold",
          color: Color(0xFFFFC495),
        ),
      ),
    );
  }
}
