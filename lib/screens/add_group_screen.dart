import 'package:chat_app/common_methods/common_methods.dart';
import 'package:chat_app/common_methods/field_validators.dart';
import 'package:chat_app/helpers/groups_helper.dart';
import 'package:chat_app/models/group.dart';
import 'package:chat_app/models/user.dart';
import 'package:chat_app/values/colors.dart';
import 'package:chat_app/widgets/app_bar_widget.dart';
import 'package:chat_app/widgets/curved_header_container_widget.dart';
import 'package:chat_app/widgets/loader_widget.dart';
import 'package:chat_app/widgets/text_form_field_widget.dart';
import 'package:flutter/material.dart';

class AddGroupScreen extends StatefulWidget {
  const AddGroupScreen({super.key});

  @override
  State<AddGroupScreen> createState() => _AddGroupScreenState();
}

class _AddGroupScreenState extends State<AddGroupScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey();

  final Group _groupData = Group(
    id: null,
    name: null,
    createdAt: null,
  );

  bool _isLoading = false;

  _submitAuthForm() async {
    final navigator = Navigator.of(context);
    if (!_formKey.currentState!.validate()) {
      return;
    }
    _formKey.currentState!.save();

    try {
      setState(() {
        _isLoading = true;
      });

      await GroupsHelper().createGroup(groupData: _groupData);

      navigator.pop();
    } catch (error) {
      print(error);
      var message = 'Something went wrong!';

      displaySnackbar(context: context, msg: message);
    }
  }

  @override
  Widget build(BuildContext context) {
    final deviceSize = MediaQuery.of(context).size;

    return Scaffold(
      appBar: const AppBarWidget(
        elevation: 0,
      ),
      body: _isLoading
          ? const LoaderWidget()
          : Form(
              key: _formKey,
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    CurvedHeaderConyainerWidget(title: 'Create Group'),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 30.0),
                      child: TextFormFieldWidget(
                        lableText: 'Name',
                        icon: Icons.group_outlined,
                        validator: nameValidator,
                        textInputAction: TextInputAction.next,
                        onSaved: (value) {
                          _groupData.name = value;
                        },
                      ),
                    ),
                    const SizedBox(height: 50),
                    ElevatedButton(
                      onPressed: _submitAuthForm,
                      child: const Text('Create'),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
