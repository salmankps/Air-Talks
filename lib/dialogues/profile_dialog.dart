import 'package:air_talks/models/chat_user.dart';
import 'package:air_talks/screens/chat_screen.dart';
import 'package:air_talks/screens/view_profile_screeen.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../main.dart';

class ProfieDialogue extends StatelessWidget {
  const ProfieDialogue({super.key, required this.user});

  final ChatUser user;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      contentPadding: const EdgeInsets.all(13),
      backgroundColor: Colors.white.withOpacity(0.4),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      content: SizedBox(
        width: mq.width * .6,
        height: mq.height * .39,
        child: Stack(
          children: [
            Column(
              children: [
                Text(
                  user.name,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(
                  height: 7,
                ),
                Align(
                  alignment: Alignment.center,

                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(15),
                    child: SizedBox(
                      height: mq.height*.3,
                      child: CachedNetworkImage(
                        imageUrl: user.image,
                        height: mq.height*.5,
                       width: mq.width*5,

                        fit: BoxFit.cover,

                        errorWidget: (context, url, error) => const CircleAvatar(
                          child: Icon(CupertinoIcons.person),
                        ),
                      ),
                    ),
                  ),
                ),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    IconButton(
                        onPressed: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) =>
                                      ViewProfileScreen(user: user)));
                        },
                        icon: const Icon(
                          Icons.info,
                          color: Colors.white,
                          size: 40,
                        )),
                    const VerticalDivider(
                        thickness: 4, color: Colors.black, width: 2),
                    IconButton(
                        onPressed: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) =>
                                      ChatScreen(user: user)));
                        },
                        icon: const Icon(
                          Icons.chat,
                          color: Colors.white,
                          size: 40,
                        )),
                  ],
                )
              ],
            ),
          ],
        ),
      ),
    );
  }
}
