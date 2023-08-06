import 'dart:developer';

import 'package:air_talks/api/apis.dart';
import 'package:air_talks/helpers/dialogues.dart';
import 'package:air_talks/helpers/my_date_util.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gallery_saver/gallery_saver.dart';

import '../main.dart';
import '../models/message.dart';

class MessageCard extends StatefulWidget {
  const MessageCard({super.key, required this.message});

  final Message message;

  @override
  State<MessageCard> createState() => _MessageCardState();
}

class _MessageCardState extends State<MessageCard> {
  @override
  Widget build(BuildContext context) {
    bool isMe = APIs.user.uid == widget.message.fromId;
    return InkWell(
      onLongPress: () {
        _showBottomSheet(isMe);
      },
      child: isMe ? _greenMessage() : _blueMessage(),
    );
  }

  //sender or another user message
  Widget _blueMessage() {
    //update last read message if sender and reciever are diffrent
    if (widget.message.read.isEmpty) {
      APIs.updateMessageReadStatus(widget.message);
    }
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        //message content
        Flexible(
          child: Container(
            padding: EdgeInsets.all(widget.message.type == Type.image
                ? mq.width * .02
                : mq.width * .04),
            margin: EdgeInsets.symmetric(
                horizontal: mq.width * .04, vertical: mq.height * .01),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.lightBlue),
              color: const Color.fromARGB(255, 221, 245, 255),
              //making border curved
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
                topRight: Radius.circular(30),
              ),
            ),
            child: widget.message.type == Type.text
                ? Text(
                    widget.message.msg,
                    style: const TextStyle(fontSize: 15, color: Colors.black87),
                    //show image
                  )
                : ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: CachedNetworkImage(
                      imageUrl: widget.message.msg,
                      placeholder: (context, url) => const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                        ),
                      ),
                      errorWidget: (context, url, error) => const CircleAvatar(
                        child: Icon(
                          Icons.image,
                          size: 70,
                        ),
                      ),
                    ),
                  ),
          ),
        ),
        Padding(
          padding: EdgeInsets.only(right: mq.width * .04),
          child: Text(
            MyDateUtil.getFormatedTime(
                context: context, time: widget.message.sent),
            style: const TextStyle(fontSize: 13, color: Colors.black54),
          ),
        )
      ],
    );
  }

//our or user message

  Widget _greenMessage() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            //for adding some space
            SizedBox(
              width: mq.width * .04,
            ),

            //double tick blue icon for message

            if (widget.message.read.isNotEmpty)
              const Icon(
                Icons.done_all_rounded,
                color: Colors.blue,
                size: 20,
              ),

            //for adding some space
            const SizedBox(
              width: 2,
            ),

            //send time
            Text(
              MyDateUtil.getFormatedTime(
                  context: context, time: widget.message.sent),
              style: const TextStyle(fontSize: 13, color: Colors.black54),
            ),
          ],
        ),
        Flexible(
          child: Container(
            padding: EdgeInsets.all(widget.message.type == Type.image
                ? mq.width * .02
                : mq.width * .04),
            margin: EdgeInsets.symmetric(
                horizontal: mq.width * .04, vertical: mq.height * .01),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.lightBlue),
              gradient: LinearGradient(colors: [Colors.indigo.shade400,Colors.purple.shade400]),
              //making border curved
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
                bottomLeft: Radius.circular(20),
              ),
            ),
            child: widget.message.type == Type.text
                ? Text(
                    widget.message.msg,
                    style: const TextStyle(fontSize: 15, color: Colors.white),
                  )
                : ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: CachedNetworkImage(
                      imageUrl: widget.message.msg,
                      placeholder: (context, url) => const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                        ),
                      ),
                      errorWidget: (context, url, error) => const CircleAvatar(
                        child: Icon(
                          Icons.image,
                          size: 70,
                        ),
                      ),
                    ),
                  ),
          ),
        ),
      ],
    );
  }

  //show bottom sheet modifying message
  void _showBottomSheet(bool isMe) {
    showModalBottomSheet(
        backgroundColor: Colors.white.withOpacity(0.8),
        context: context,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        builder: (_) {
          return ListView(
            shrinkWrap: true,
            children: [
              Container(
                height: 4,
                margin: EdgeInsets.symmetric(
                    vertical: mq.height * .015, horizontal: mq.width * .4),
                decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(8)),
              ),

              //copy option
              widget.message.type == Type.text
                  ? _OptionItem(
                      icon: const Icon(
                        Icons.copy_rounded,
                        color: Colors.blue,
                        size: 26,
                      ),
                      name: 'CopyText',
                      onTap: () async {
                        await Clipboard.setData(
                                ClipboardData(text: widget.message.msg))
                            .then((value) {
                          Navigator.pop(context);

                          Dialogs.showSnackBar(context, 'Text Copied');
                        });
                      },
                    )
                  : _OptionItem(
                      icon: const Icon(
                        Icons.download_rounded,
                        color: Colors.blue,
                        size: 26,
                      ),
                      name: 'Save Image',
                      onTap: () async {
                        try {
                          log('img url:${widget.message.msg}');

                          await GallerySaver.saveImage(widget.message.msg,
                                  albumName: 'AirTalksImages')
                              .then((success) {
                            Navigator.pop(context);
                            if (success != null && success) {
                              Dialogs.showSnackBar(
                                  context, 'Image Successfully saved');
                            }
                          });
                        } catch (e) {
                          log('Error in saving image:$e');
                        }
                      },
                    ),

              Divider(
                color: Colors.grey,
                endIndent: mq.width * .04,
                indent: mq.width * .04,
              ),

              //edit option
              if (widget.message.type == Type.text && isMe)
                _OptionItem(
                  icon: const Icon(
                    Icons.edit,
                    color: Colors.purple,
                    size: 26,
                  ),
                  name: 'edit',
                  onTap: () {
                    //for hiding bottom sheet
                    Navigator.pop(context);
                    _showMessageUpdateDialog();
                  },
                ),

              //delete option
              if (isMe)
                _OptionItem(
                  icon: const Icon(
                    Icons.delete,
                    color: Colors.red,
                    size: 26,
                  ),
                  name: 'Delete',
                  onTap: () async {
                    await APIs.deleteMessage(widget.message)
                        .then((value) => Navigator.pop(context));
                  },
                ),
              Divider(
                color: Colors.grey,
                endIndent: mq.width * .04,
                indent: mq.width * .04,
              ),
              //sent time
              _OptionItem(
                icon: const Icon(
                  Icons.remove_red_eye_outlined,
                  color: Colors.blue,
                  size: 26,
                ),
                name: 'sent At:${MyDateUtil.getMessageTime(
                  context: context,
                  time: widget.message.sent,
                )}',
                onTap: () {},
              ),

              //read time
              _OptionItem(
                icon: const Icon(
                  Icons.remove_red_eye_rounded,
                  color: Colors.green,
                  size: 26,
                ),
                name: widget.message.read.isEmpty
                    ? 'Not seen yet'
                    : 'Read At:${MyDateUtil.getMessageTime(
                        context: context,
                        time: widget.message.read,
                      )}',
                onTap: () {},
              ),
            ],
          );
        });
  }

  //dialog for updating message content
  void _showMessageUpdateDialog() {
    String updatedMsg = widget.message.msg;

    showDialog(

      context: context,
      builder: (_) => AlertDialog(
        contentPadding: const EdgeInsets.only(left: 24,right: 24,top: 20,bottom: 10),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        backgroundColor: Colors.white.withOpacity(0.8),
        elevation: 5,
        //title
        title: const Row(
          children: [
            Icon(
              Icons.message,
              color: Colors.blue,
              size: 28,
            ),
            Text(' Update Message')
          ],
        ),
        content: TextFormField(
          initialValue: updatedMsg,
          maxLines: null,
          onChanged: (value)=>updatedMsg =  value,
          decoration: InputDecoration(
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
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
          MaterialButton(
            onPressed: () {
              Navigator.pop(context);
              APIs.updateMessage(widget.message, updatedMsg);
            },
            child: const Text(
              'Update',
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

//custom option for card delet,edit, copy etc
class _OptionItem extends StatelessWidget {
  final Icon icon;
  final String name;
  final VoidCallback onTap;

  const _OptionItem(
      {required this.icon, required this.name, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => onTap(),
      child: Padding(
        padding: EdgeInsets.only(
            left: mq.width * .05,
            top: mq.width * .015,
            bottom: mq.width * .015),
        child: Row(
          children: [
            icon,
            Flexible(
                child: Text(
              '   $name',
              style: const TextStyle(
                  color: Colors.black54, letterSpacing: 0.5, fontSize: 15),
            ))
          ],
        ),
      ),
    );
  }
}
