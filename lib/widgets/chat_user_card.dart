
import 'package:air_talks/helpers/my_date_util.dart';
import 'package:air_talks/models/chat_user.dart';
import 'package:air_talks/models/message.dart';
import 'package:air_talks/screens/chat_screen.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../api/apis.dart';
import '../dialogues/profile_dialog.dart';
import '../main.dart';


class ChatUserCard extends StatefulWidget {
  final ChatUser user;

  const ChatUserCard({super.key, required this.user});

  @override
  State<ChatUserCard> createState() => _ChatUserCardState();
}

class _ChatUserCardState extends State<ChatUserCard> {
  //last message info(if null --> no message)
  Message? _message;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white.withOpacity(0.7),
      margin: EdgeInsets.symmetric(horizontal: mq.width * .01, vertical: 4),
      elevation: 0.5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: InkWell(
          onTap: () {
            //for Navigating to chat Screen
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => ChatScreen(
                          user: widget.user,
                        )));
          },
          child: StreamBuilder(
              stream: APIs.getLastMessage(widget.user),
              builder: (context, snapshot) {
                final data = snapshot.data?.docs;
                final list =
                    data?.map((e) => Message.fromJson(e.data())).toList() ?? [];
                if (list.isNotEmpty) _message = list[0];

                return ListTile(
                  // leading: const CircleAvatar(child: Icon(CupertinoIcons.ant_circle),),
                  leading: InkWell(
                    onTap: (){
                      showDialog(context: context, builder: (_)=>ProfieDialogue(user: widget.user,));
                    },
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(mq.height * .3),
                      child: CachedNetworkImage(
                        imageUrl: widget.user.image,
                        height: mq.height * .055,
                        width: mq.height * .055,
                        errorWidget: (context, url, error) => const CircleAvatar(
                          child: Icon(CupertinoIcons.person),
                        ),
                      ),
                    ),
                  ),

                  //user name
                  title: Text(widget.user.name),

                  //last message
                  subtitle: Text(
                    _message != null
                        ? _message!.type == Type.image
                            ? '🖼 Photo'
                            : _message!.msg
                        : widget.user.about,
                    maxLines: 1,
                  ),
                  trailing: _message == null
                      ? null //show nothing when no message is sent
                      : _message!.read.isEmpty &&
                              _message!.fromId != APIs.user.uid
                          //show unread message
                          ? Container(
                              height: 15,
                              width: 15,
                              decoration: BoxDecoration(
                                  color: Colors.greenAccent.shade400,
                                  borderRadius: BorderRadius.circular(10)),
                            )
                          //message sent time
                          : Text(
                              MyDateUtil.getLastMessageTime(
                                  context: context, time: _message!.sent),
                              style: const TextStyle(color: Colors.black54),
                            ),
                );
              })),
    );
  }
}
