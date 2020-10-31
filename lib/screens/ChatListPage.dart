import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:karvaan/models/ChatItem.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:toast/toast.dart';

import 'ChatPage.dart';

class ChatListPage extends StatefulWidget {
  @override
  _ChatListPageState createState() => _ChatListPageState();
}

class _ChatListPageState extends State<ChatListPage> {
  String uId;
  List<ChatItem> chatListItems = <ChatItem>[];
  
  //to get user id
  getUserId() {
    FirebaseAuth auth = FirebaseAuth.instance;
    if (auth.currentUser != null) {
      uId = auth.currentUser.uid;
    }
  }

  @override
  void initState() {
    getUserId();
    getChatList();
    super.initState();
  }

  //to fetch the chat messages
  Future getChatList() async {
    FirebaseFirestore.instance
        .collection('users')
        .doc(uId)
        .collection("chatlist")
        .snapshots()
        .listen((querySnapshot) {
      setState(() {
        querySnapshot.docs.forEach((doc) {
          ChatItem request = new ChatItem(doc["name"], doc["forBike"],
              doc["chatDoc"], doc["contact"], doc["id"]);
          chatListItems.add(request);
        });
      });
    });
  }

  //to display
  Widget displayContent() {
    if (chatListItems.length == 0) {
      return Center(
        child: Text(
          "You have no chats!",
          style: TextStyle(
            color: Color(0xFFFFC495),
            fontFamily: "Montserrat SemiBold",
          ),
        ),
      );
    } else {
      return Padding(
        padding: const EdgeInsets.all(10.0),
        child: ListView.builder(
          itemCount: chatListItems.length,
          itemBuilder: (BuildContext context, int index) {
            return Card(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(17)),
              color: Color(0xFF282833),
              child: ListTile(
                onTap: () {
                  return Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) =>
                              ChatPage(chatListItems[index])));
                },
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
                  chatListItems[index].name,
                  style: TextStyle(
                      fontSize: 18,
                      fontFamily: "Montserrat Bold",
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
                        Text(
                          chatListItems[index].forBike,
                          style: TextStyle(
                              fontSize: 14,
                              fontFamily: "Montserrat SemiBold",
                              color: Color(0xFFCA9367)),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF2C2C37),
      appBar: AppBar(
        title: Text(
          "Chats",
          style: TextStyle(
              fontFamily: "Montserrat Bold",
              color: Color(0xFF2C2C37),
              fontSize: 18),
        ),
        backgroundColor: Color(0xFFFFC495),
        actions: <Widget>[
          Container(
            alignment: Alignment.center,
            child: IconButton(
              icon: Icon(
                Icons.search,
                color: Color(0xFF2C2C37),
              ),
              onPressed: () {
                Toast.show("Incomplete!", context,
                    duration: Toast.LENGTH_SHORT);
              },
            ),
          ),
          SizedBox(
            width: 10,
          )
        ],
      ),
      body: displayContent(),
    );
  }
}
