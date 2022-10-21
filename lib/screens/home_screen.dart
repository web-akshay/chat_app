import 'package:chat_app/helpers/groups_helper.dart';
import 'package:chat_app/helpers/user_helper.dart';
import 'package:chat_app/models/user.dart' as user;
import 'package:chat_app/values/app_routes.dart';
import 'package:chat_app/values/colors.dart';
import 'package:chat_app/values/collections.dart';
import 'package:chat_app/widgets/app_bar_widget.dart';
import 'package:chat_app/widgets/curved_header_container_widget.dart';
import 'package:chat_app/widgets/group_tile_widget.dart';
import 'package:chat_app/widgets/drawer_widget.dart';
import 'package:chat_app/widgets/loader_widget.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  user.User? _currentUserData;
  bool _isLoading = true;

  @override
  void initState() {
    _getData();
    super.initState();
  }

  Future<void> _getData() async {
    setState(() {
      _isLoading = true;
    });
    _currentUserData = await UsersHelper().getCurrentUserData();
    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final deviceSize = MediaQuery.of(context).size;
    final grouppStream =
        FirebaseFirestore.instance.collection(collectionGroups).snapshots();
    return Scaffold(
        drawer: const DrawerWidget(),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            Navigator.of(context).pushNamed(appRouteAddGroupScreen);
          },
          child: const Icon(Icons.group_add_outlined),
        ),
        appBar: const AppBarWidget(
          elevation: 0,
        ),
        body: _isLoading
            ? const LoaderWidget()
            : SafeArea(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      StreamBuilder(
                        stream: grouppStream,
                        builder: (context,
                            AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>>
                                snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const LoaderWidget();
                          }
                          final listLength = snapshot.data?.docs.length;
                          return CurvedHeaderConyainerWidget(
                            title: 'Chats',
                            subTitle: '$listLength Chats',
                          );

                          // Text(
                          //   '${listLength.toString()} Chats',
                          //   style: const TextStyle(
                          //       fontSize: 20, fontWeight: FontWeight.bold),
                          // );
                        },
                      ),
                      const SizedBox(height: 20),
                      StreamBuilder(
                        stream: GroupsHelper().getAllGroupsStream(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const LoaderWidget();
                          }
                          final groupList = snapshot.data;
                          return ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: groupList!.length,
                            itemBuilder: (context, index) =>
                                GroupTileWidget(groupData: groupList[index]),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ));
  }
}
