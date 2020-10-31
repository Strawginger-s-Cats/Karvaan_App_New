import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:karvaan/models/ChatItem.dart';
import 'package:karvaan/screens/MapsPage.dart';
import 'package:karvaan/screens/PaymentsPage.dart';
import 'package:toast/toast.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ChatPage extends StatefulWidget {
  final ChatItem chatInfo;
  ChatPage(this.chatInfo);

  @override
  _ChatPageState createState() => _ChatPageState(chatInfo);
}

class _ChatPageState extends State<ChatPage> {
  String uId, name, phone, email;
  ChatItem chatInfo;
  _ChatPageState(this.chatInfo);
  Future<void> _launched;
  String _phone = '';

  Stream chatMessageStream;

  @override
  void initState() {
    getUserId();
    getUserInfo();
    getConversationMessages(chatInfo.chatDoc).then((value) {
      setState(() {
        chatMessageStream = value;
      });
    });
    super.initState();
  }

  Widget chatMessageList() {
    return StreamBuilder(
      stream: chatMessageStream,
      builder: (context, snapshot) {
        return snapshot.hasData
            ? ListView.builder(
                itemCount: snapshot.data.documents.length,
                itemBuilder: (context, index) {
                  return MessageTile(
                      snapshot.data.documents[index].data()["message"],
                      snapshot.data.documents[index].data()["sendBy"] == name);
                })
            : Container();
      },
    );
  }

  TextEditingController _chatBoxController = new TextEditingController();

  String getUserId() {
    FirebaseAuth auth = FirebaseAuth.instance;
    if (auth.currentUser != null) {
      uId = auth.currentUser.uid;
    }
    return uId;
  }

  Future getUserInfo() async {
    //to get user information
    FirebaseFirestore.instance
        .collection('users')
        .doc(getUserId())
        .snapshots()
        .listen((snapshot) {
      setState(() {
        name = snapshot["name"];
        email = snapshot["email"];
        phone = snapshot["phoneNo"];
      });
    });
  }

  sendMessage() {
    if (_chatBoxController.text.isNotEmpty) {
      //getUserInfo();
      Map<String, dynamic> messageMap = {
        "sendBy": name,
        "message": _chatBoxController.text.toString(),
        "time": DateTime.now().microsecondsSinceEpoch,
      };
      addConversationMessages(chatInfo.chatDoc, messageMap);
      _chatBoxController.text = "";
    }
  }

  addConversationMessages(String chatId, messageMap) {
    FirebaseFirestore.instance
        .collection("chats")
        .doc(chatId)
        .collection("ChatPage")
        .add(messageMap)
        .catchError((e) {
      print(e.toString());
    });
  }

  getConversationMessages(String chatId) async {
    return await FirebaseFirestore.instance
        .collection("chats")
        .document(chatId)
        .collection("ChatPage")
        .orderBy("time", descending: false)
        .snapshots();
  }

  Future<int> createConfirmationDialog(BuildContext context) {
    return showDialog(
        context: context,
        builder: (context) {
          return Dialog(
            backgroundColor: Color(0xFFFFF7C6),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(17)),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                width: 120,
                height: 135,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Confirm Booking",
                            style: TextStyle(
                                fontFamily: "Montserrat Bold",
                                fontSize: 20,
                                color: Color(0xFF1E1E29)),
                          ),
                        ],
                      ),
                      Container(
                        margin: EdgeInsets.only(
                            left: 40, top: 0, right: 40, bottom: 0),
                        child: Divider(
                          thickness: 1,
                          color: Color(0xFFFFC495),
                          height: 15.0,
                          indent: 5.0,
                        ),
                      ),
                      SizedBox(
                        width: 5,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Flexible(
                            child: Text(
                                "Do you want to confirm this ride and go to payments?",
                                textAlign: TextAlign.start,
                                overflow: TextOverflow.visible,
                                style: TextStyle(
                                    fontSize: 13,
                                    fontFamily: "Montserrat SemiBold",
                                    color: Color(0xFF1E1E29))),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 15,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Container(
                            height: 30,
                            width: 80,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              color: Color(0xFF1E1E29),
                            ),
                            child: FlatButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                              child: Center(
                                child: Text(
                                  "No",
                                  style: TextStyle(
                                      color: Color(0xFFE5E5E5),
                                      fontSize: 14,
                                      fontFamily: 'Montserrat Bold'),
                                ),
                              ),
                            ),
                          ),
                          Container(
                            height: 30,
                            width: 80,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              color: Color(0xFF1E1E29),
                            ),
                            child: FlatButton(
                              onPressed: () async {
                                // navigate to payments
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            PaymentsPage(chatInfo)));
                              },
                              child: Center(
                                child: Text(
                                  "Yes",
                                  style: TextStyle(
                                      color: Color(0xFFE5E5E5),
                                      fontSize: 14,
                                      fontFamily: 'Montserrat Bold'),
                                ),
                              ),
                            ),
                          )
                        ],
                      )
                    ],
                  ),
                ),
              ),
            ),
          );
        });
  }

  Future<int> createCancelationDialog(BuildContext context) {
    return showDialog(
        context: context,
        builder: (context) {
          return Dialog(
            backgroundColor: Color(0xFFFFF7C6),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(17)),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                width: 120,
                height: 135,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Cancel",
                            style: TextStyle(
                                fontFamily: "Montserrat Bold",
                                fontSize: 20,
                                color: Color(0xFF1E1E29)),
                          ),
                        ],
                      ),
                      Container(
                        margin: EdgeInsets.only(
                            left: 60, top: 0, right: 60, bottom: 0),
                        child: Divider(
                          thickness: 1,
                          color: Color(0xFFFFC495),
                          height: 15.0,
                          indent: 5.0,
                        ),
                      ),
                      SizedBox(
                        width: 5,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Flexible(
                            child: Text(
                                "Are You Sure? You won't be able to chat after this!",
                                textAlign: TextAlign.start,
                                overflow: TextOverflow.visible,
                                style: TextStyle(
                                    fontSize: 13,
                                    fontFamily: "Montserrat SemiBold",
                                    color: Color(0xFF1E1E29))),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 15,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Container(
                            height: 30,
                            width: 80,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              color: Color(0xFF1E1E29),
                            ),
                            child: FlatButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                              child: Center(
                                child: Text(
                                  "No",
                                  style: TextStyle(
                                      color: Color(0xFFE5E5E5),
                                      fontSize: 14,
                                      fontFamily: 'Montserrat Bold'),
                                ),
                              ),
                            ),
                          ),
                          Container(
                            height: 30,
                            width: 80,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              color: Color(0xFF1E1E29),
                            ),
                            child: FlatButton(
                              onPressed: () async {
                                clearChat();
                                Navigator.pushAndRemoveUntil(
                                  context,
                                  MaterialPageRoute(
                                      builder: (BuildContext context) =>
                                          MapsPage()),
                                  ModalRoute.withName('/MapsPage'),
                                );
                              },
                              child: Center(
                                child: Text(
                                  "Yes",
                                  style: TextStyle(
                                      color: Color(0xFFE5E5E5),
                                      fontSize: 14,
                                      fontFamily: 'Montserrat Bold'),
                                ),
                              ),
                            ),
                          )
                        ],
                      )
                    ],
                  ),
                ),
              ),
            ),
          );
        });
  }

  Future<void> clearChat() {
    FirebaseFirestore.instance
        .collection('chats')
        .doc(chatInfo.chatDoc)
        .delete();

    FirebaseFirestore.instance
        .collection('users')
        .doc(uId)
        .collection("chatlist")
        .doc(chatInfo.name)
        .delete();

    FirebaseFirestore.instance
        .collection('users')
        .doc(chatInfo.id)
        .collection("chatlist")
        .doc(chatInfo.name)
        .delete();
  }

  Future<void> changeBikeRentStatus() {
    //to change bike availabiltiy status when renter confirms the bike
    FirebaseFirestore.instance
        .collection('availableBikes')
        .doc(chatInfo.forBike)
        .update({"onRent": true});
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
          chatInfo.name,
          style: TextStyle(
              fontFamily: "Montserrat Bold",
              color: Color(0xFFE5E5E5),
              fontSize: 16,
              letterSpacing: 2),
        ),
        elevation: 1,
        actions: <Widget>[
          Container(
            alignment: Alignment.center,
            child: IconButton(
              icon: Icon(
                Icons.phone,
                color: Color(0xFFFFC495),
              ),
              onPressed: () {},
            ),
          ),
          SizedBox(
            width: 10,
          )
        ],
      ),
      backgroundColor: Color(0xFF1E1E29),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: Container(
              width: double.infinity,
              child: Stack(
                children: [
                  chatMessageList(),
                ],
              ),
            ),
          ),
          Container(
            child: Padding(
              padding: const EdgeInsets.only(top: 10.0),
              child: Row(
                children: [
                  Container(
                    alignment: Alignment.bottomLeft,
                    height: 38,
                    width: 130,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(48),
                      color: Color(0xFFFFF7C6),
                    ),
                    child: FlatButton(
                      onPressed: () {
                        createConfirmationDialog(context);
                      },
                      child: Center(
                        child: Text(
                          "Confirm Booking",
                          style: TextStyle(
                              color: Color(0xFF1E1E29),
                              fontSize: 11,
                              fontFamily: 'Montserrat SemiBold'),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 10,
                  ),
                  Container(
                    alignment: Alignment.bottomLeft,
                    height: 38,
                    width: 90,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(48),
                      color: Color(0xFFFFF7C6),
                    ),
                    child: FlatButton(
                      onPressed: () {
                        createCancelationDialog(context);
                        Toast.show("Incomplete!", context,
                            duration: Toast.LENGTH_SHORT);
                      },
                      child: Center(
                        child: Text(
                          "Cancel",
                          style: TextStyle(
                              color: Color(0xFF1E1E29),
                              fontSize: 11,
                              fontFamily: 'Montserrat SemiBold'),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Container(
            alignment: Alignment.center,
            height: 52,
            margin: EdgeInsets.fromLTRB(12, 8, 12, 8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(28),
              color: Color(0xFF282833),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  child: Container(
                    margin: EdgeInsets.only(left: 16),
                    child: TextField(
                      controller: _chatBoxController,
                      decoration: InputDecoration(
                          hintText: "Type a message…",
                          border: InputBorder.none),
                      style: TextStyle(
                          color: Color(0xFF858484),
                          fontSize: 16,
                          fontFamily: 'Montserrat Regular'),
                    ),
                  ),
                ),
                Center(
                  child: GestureDetector(
                    onTap: () {
                      sendMessage();
                      Toast.show("Incomplete!", context,
                          duration: Toast.LENGTH_SHORT);
                    },
                    child: Container(
                      margin: EdgeInsets.only(right: 5),
                      height: 50,
                      width: 50,
                      decoration: BoxDecoration(
                          color: Color(0xFF282833),
                          borderRadius: BorderRadius.circular(40)),
                      padding: EdgeInsets.all(12),
                      child: Icon(
                        Icons.arrow_forward,
                        color: Color(0xFFFFF7C6),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class MessageTile extends StatelessWidget {
  final String message;
  final bool isSendByMe;
  MessageTile(this.message, this.isSendByMe);
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 8),
      padding: EdgeInsets.only(
          left: isSendByMe ? 0 : 24, right: isSendByMe ? 24 : 0),
      width: MediaQuery.of(context).size.width,
      alignment: isSendByMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        decoration: BoxDecoration(
            color: isSendByMe ? Color(0xFFFFC495) : Color(0xFF282833),
            borderRadius: isSendByMe
                ? BorderRadius.only(
                    topLeft: Radius.circular(23),
                    topRight: Radius.circular(23),
                    bottomLeft: Radius.circular(23),
                  )
                : BorderRadius.only(
                    topLeft: Radius.circular(23),
                    topRight: Radius.circular(23),
                    bottomRight: Radius.circular(23),
                  )),
        child: Text(
          message,
          style: TextStyle(
            color: isSendByMe ? Color(0xFF1E1E29) : Color(0xFFE5E5E5),
            fontSize: 17,
          ),
        ),
      ),
    );
  }
}
