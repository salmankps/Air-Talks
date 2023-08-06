import 'dart:developer';

import 'package:air_talks/api/apis.dart';
import 'package:air_talks/models/chat_user.dart';
import 'package:air_talks/screens/profile_screen.dart';
import 'package:air_talks/widgets/chat_user_card.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../helpers/dialogues.dart';
import '../main.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<ChatUser> _list = [];
  final List<ChatUser> _searchList = [];
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    APIs.getSelfInfo();

    SystemChannels.lifecycle.setMessageHandler((message) {
      log('Message:$message');
      if (APIs.auth.currentUser != null) {
        if (message.toString().contains('resume')) {
          APIs.updateActiveStatus(true);
        }
        if (message.toString().contains('pause')) {
          APIs.updateActiveStatus(false);
        }
      }

      return Future.value(message);
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      //for hiding keyboard when tap detect on keyboard
      onTap: () => FocusScope.of(context).unfocus(),
      child: WillPopScope(
        //is search is on and back button is pressed then close the searh
        //or release simple close current screen on back button click
        onWillPop: () {
          if (_isSearching) {
            setState(() {
              _isSearching = !_isSearching;
            });
            return Future.value(false);
          } else {
            return Future.value(true);
          }
        },
        child: Scaffold(
            appBar: AppBar(
              leading: const Icon(
                CupertinoIcons.home,
              ),
              title: _isSearching
                  ? TextField(
                      decoration: const InputDecoration(
                          border: InputBorder.none, hintText: 'Name,E-mail'),
                      autofocus: true,
                      style: const TextStyle(fontSize: 17, letterSpacing: 0.5),
                      //when search text changes then updated search list
                      onChanged: (val) {
                        //search logic
                        _searchList.clear();
                        for (var i in _list) {
                          if (i.name.toLowerCase().contains(val.toLowerCase()) |
                              i.email
                                  .toLowerCase()
                                  .contains(val.toLowerCase())) {
                            _searchList.add(i);
                          }
                          setState(() {
                            _searchList;
                          });
                        }
                      },
                    )
                  : const Text('Air Talks'),
              actions: [
                IconButton(
                  onPressed: () {
                    setState(() {
                      _isSearching = !_isSearching;
                    });
                  },
                  icon:
                      Icon(_isSearching ? CupertinoIcons.clear : Icons.search),
                ),
                IconButton(
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => ProfileScreen(
                                  user: APIs.me,
                                )));
                  },
                  icon: const Icon(Icons.more_vert),
                ),
              ],
            ),
            floatingActionButton: Padding(
              padding: const EdgeInsets.only(bottom: 10.0),
              child: Container(
                decoration: BoxDecoration(
                  shape:BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [Colors.purple.shade400, Colors.indigo.shade400],
                  ),
                ),
                child: FloatingActionButton(
                  onPressed: () {
                    _addChatUserDialog();
                  },
                  elevation: 3,
                  backgroundColor: Colors.transparent,
                  child: const Icon(
                    Icons.add_comment_rounded,
                  ),
                ),
              ),
            ),
            body: Stack(children: [
              Container(
                alignment: Alignment.center,
                child: Image.asset(
                  'images/icon.png',
                  alignment: Alignment.center,
                ),
              ),
              StreamBuilder(
                  stream: APIs.getMyUsersId(),
                  builder: (context, snapshot) {
                    switch (snapshot.connectionState) {
                      //if data is loading
                      case ConnectionState.waiting:
                      case ConnectionState.none:
                        return const Center(
                          child: CircularProgressIndicator(),
                        );
                      //is some or all data is loaded then show it
                      case ConnectionState.active:
                      case ConnectionState.done:
                        return StreamBuilder(
                            stream: APIs.getAllUsers(
                                snapshot.data?.docs.map((e) => e.id).toList() ??
                                    []),
                            builder: (context, snapshot) {
                              switch (snapshot.connectionState) {
                                //if data is loading
                                case ConnectionState.waiting:
                                case ConnectionState.none:
                                  return const Center(
                                    child: CircularProgressIndicator(),
                                  );
                                //is some or all data is loaded then show it
                                case ConnectionState.active:
                                case ConnectionState.done:
                                  final data = snapshot.data?.docs;
                                  _list = data
                                          ?.map((e) =>
                                              ChatUser.fromJson(e.data()))
                                          .toList() ??
                                      [];

                                  if (_list.isNotEmpty) {
                                    return ListView.builder(
                                        itemCount: _isSearching
                                            ? _searchList.length
                                            : _list.length,
                                        physics: const BouncingScrollPhysics(),
                                        padding: EdgeInsets.only(
                                            top: mq.height * .01),
                                        itemBuilder: (context, index) {
                                          return ChatUserCard(
                                              user: _isSearching
                                                  ? _searchList[index]
                                                  : _list[index]);
                                        });
                                  } else {
                                    return const Center(
                                        child: Text(
                                      'No connection found!',
                                      style: TextStyle(fontSize: 20),
                                    ));
                                  }
                              }
                            });
                    }
                  }),
            ])),
      ),
    );
  }

  //for adding new chat user
  void _addChatUserDialog() {
    String email = '';

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        contentPadding:
            const EdgeInsets.only(left: 24, right: 24, top: 20, bottom: 10),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        backgroundColor: Colors.white.withOpacity(0.8),
        elevation: 5,
        //title
        title: const Row(
          children: [
            Icon(
              Icons.person_add,
              color: Colors.purple,
              size: 28,
            ),
            Text('  Add User')
          ],
        ),
        content: TextFormField(
          maxLines: null,
          onChanged: (value) => email = value,
          decoration: InputDecoration(
            hintText: 'Email ID',
            prefixIcon: const Icon(
              Icons.email_outlined,
              color: Colors.purple,
            ),
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: const BorderSide(width: 3, color: Colors.purple)),
          ),
        ),
        actions: [
          MaterialButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text(
              'Cancel',
              style: TextStyle(
                color: Colors.blue,
                fontSize: 16,
              ),
            ),
          ),

          //add button
          MaterialButton(
            onPressed: () async {
              Navigator.pop(context);
              if (email.isNotEmpty) {
                await APIs.addChatUser(email).then((value) {
                  if (!value) {
                    Dialogs.showSnackBar(context, 'User does not Exist!');
                  }
                });
              }
            },
            child: const Text(
              'Add',
              style: TextStyle(
                color: Colors.blue,
                fontSize: 16,
              ),
            ),
          )
        ],
      ),
    );
  }
}
