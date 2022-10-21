import 'package:chat_app/models/group.dart';
import 'package:chat_app/models/user.dart';
import 'package:chat_app/values/app_routes.dart';
import 'package:flutter/material.dart';

class GroupTileWidget extends StatelessWidget {
  const GroupTileWidget({required this.groupData, super.key});
  final Group? groupData;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.only(left: 0),
      leading: const CircleAvatar(
        radius: 50,
        backgroundColor: Colors.yellow,
        child: FlutterLogo(
            // size: 40,
            ),
      ),
      title: Text(groupData!.name!),
      onTap: () {
        Navigator.of(context)
            .pushNamed(appRouteChatScreen, arguments: groupData);
      },
    );
  }
}
