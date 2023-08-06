class Message {
  Message({
    required this.fromId,
    required this.msg,
    required this.read,
    required this.toId,
    required this.type,
    required this.sent,
  });
  late final String fromId;
  late final String msg;
  late final String read;
  late final String toId;
  late final Type type;
  late final String sent;

  Message.fromJson(Map<String, dynamic> json){
    fromId = json['fromId'];
    msg = json['msg'].toString();
    read = json['read'].toString();
    toId = json['toId'].toString();
    type = json['type'].toString()==Type.image.name?Type.image:Type.text;
    sent = json['sent'].toString();
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['fromId'] = fromId;
    data['msg'] = msg;
    data['read'] = read;
    data['toId'] = toId;
    data['type'] = type.name;
    data['sent'] = sent;
    return data;
  }
}
enum Type{text,image}