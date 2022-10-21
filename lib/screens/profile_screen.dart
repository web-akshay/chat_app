import 'dart:io';
import 'package:chat_app/common_methods/common_methods.dart';
import 'package:chat_app/helpers/user_helper.dart';
import 'package:chat_app/models/user.dart' as user;
import 'package:chat_app/values/collections.dart';
import 'package:chat_app/widgets/app_bar_widget.dart';
import 'package:chat_app/widgets/curved_header_container_widget.dart';
import 'package:chat_app/widgets/loader_widget.dart';
import 'package:chat_app/widgets/text_form_field_widget.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';

import 'package:image_picker/image_picker.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  File? _pickedImage;

  user.User? _currentUserData;
  bool _isLoading = true;

  final GlobalKey<FormState> _formKey = GlobalKey();

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

  Widget _profileImageContainer({String? imageUrl}) {
    return Stack(
      children: [
        Container(
          width: 100.0,
          height: 100.0,
          decoration: BoxDecoration(
            border: Border.all(
              width: 4,
              color: Theme.of(context).primaryColor,
            ),
            boxShadow: [
              BoxShadow(
                  spreadRadius: 2,
                  blurRadius: 10,
                  color: Colors.black.withOpacity(0.1),
                  offset: const Offset(0, 10)),
            ],

            image: imageUrl == null && _pickedImage == null
                ? null
                : DecorationImage(
                    fit: BoxFit.cover,
                    image: _pickedImage != null
                        ? FileImage(_pickedImage!) as ImageProvider
                        : NetworkImage(imageUrl!),
                  ),

            //  backgroundImage: _pickedImage != null
            //                         ? FileImage(_pickedImage!) as ImageProvider
            //                         : _userData!.imageUrl != null
            //                             ? NetworkImage(_userData!.imageUrl!)
            //                             : null,

            shape: BoxShape.circle,
          ),
          // child: imageUrl != null
          //     ? null
          //     : const Icon(
          //         Icons.person_outline,
          //         size: 50.0,
          //         color: Colors.grey,
          //       ),
        ),
        Positioned(
          bottom: 0,
          right: 0,
          child: Container(
            height: 30,
            width: 30,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                width: 2,
                color: Theme.of(context).primaryColor,
              ),
              color: Colors.white,
            ),
            child: GestureDetector(
              child: Icon(
                Icons.edit,
                color: Theme.of(context).primaryColor,
                size: 19,
              ),
              onTap: () {
                _chooseFile();
              },
            ),
          ),
        ),
      ],
    );
  }

  void _chooseFile() async {
    final ImagePicker picker = ImagePicker();
    final pickedImage = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 50,
      maxWidth: 150,
    );
    if (pickedImage == null) {
      return;
    }
    final pickedImageFile = File(pickedImage.path);
    setState(() {
      _pickedImage = pickedImageFile;
    });
  }

  Future<String?> _uploadImage() async {
    final now = DateTime.now();
    final uniqueName = now.microsecondsSinceEpoch.toString();
    final ref = FirebaseStorage.instance
        .ref()
        .child('userimages')
        .child('$uniqueName.jpg');
    await ref.putFile(_pickedImage!);
    final url = await ref.getDownloadURL();
    return url;
  }

  String _getFileName(String url) {
    RegExp regExp = RegExp(r'.+(\/|%2F)(.+)\?.+');
    var matches = regExp.allMatches(url);
    var match = matches.elementAt(0);
    return Uri.decodeFull(match.group(2)!);
  }

  Future<void> _deleteImageFromFirebase({required String? imageUrl}) async {
    if (imageUrl != null) {
      final fileName = _getFileName(imageUrl);
      final ref =
          FirebaseStorage.instance.ref().child('userimages').child(fileName);
      await ref.delete();
    }
  }

  void _submitForm() async {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) {
      // Invalid!
      return;
    }
    final oldImageUrl = _currentUserData!.imageUrl;
    if (_pickedImage != null) {
      _currentUserData!.imageUrl = await _uploadImage();
    }

    _formKey.currentState!.save();
    try {
      if (_currentUserData!.id != null) {
        final userInstance = FirebaseFirestore.instance
            .collection(collectionUsers)
            .doc(_currentUserData!.id);
        await userInstance.update(_currentUserData!.toJson()).then((value) {
          _deleteImageFromFirebase(imageUrl: oldImageUrl);
        });
      }

      if (!mounted) return;
      Navigator.of(context).pop();
    } catch (error) {
      const errorMessage = 'Something went wrong';
      if (mounted) {
        showErrorDialog(errorMessage, context);
      }
    }

    setState(() {
      _isLoading = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AppBarWidget(
        elevation: 0,
      ),
      body: _isLoading
          ? const LoaderWidget()
          : Form(
              key: _formKey,
              child: Column(
                children: [
                  const CurvedHeaderConyainerWidget(
                    title: 'My Profile',
                  ),
                  _profileImageContainer(imageUrl: _currentUserData?.imageUrl),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 20.0),
                    child: TextFormFieldWidget(
                      lableText: 'Name',
                      icon: Icons.group_outlined,
                      // validator: nameValidator,
                      textInputAction: TextInputAction.next,
                      onSaved: (value) {
                        _currentUserData!.name = value;
                      },
                    ),
                  ),
                  ElevatedButton(
                      onPressed: _submitForm, child: Text('Update Profile'))
                ],
              ),
            ),
    );
  }
}
