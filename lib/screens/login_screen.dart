import 'package:chat_app/common_methods/common_methods.dart';
import 'package:chat_app/common_methods/field_validators.dart';
import 'package:chat_app/values/colors.dart';
import 'package:chat_app/values/collections.dart';
import 'package:chat_app/widgets/text_form_field_widget.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey();
  final _auth = FirebaseAuth.instance;
  final Map<String, String?> _userData = {
    'name': '',
    'email': '',
    'password': '',
  };

  bool _isSignUp = false;
  _submitAuthForm() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    _formKey.currentState!.save();

    try {
      //     setState(() {
      //   _isLoading = true;
      // });
      if (_isSignUp) {
        final authUser = await _auth.createUserWithEmailAndPassword(
            email: _userData['email']!, password: _userData['password']!);

        final userInstance =
            FirebaseFirestore.instance.collection(collectionUsers).doc();
        await userInstance.set({
          'id': userInstance.id,
          'name': _userData['name'],
          'email': _userData['email'],
          'authId': authUser.user!.uid,
          // 'image_url': url,
        });
      } else {
        await _auth.signInWithEmailAndPassword(
            email: _userData['email']!, password: _userData['password']!);
      }
    } catch (error) {
      print(error);
      var message = 'An error occurred, please check your credentials';

      displaySnackbar(context: context, msg: message);
    }
  }

  @override
  Widget build(BuildContext context) {
    const textFieldPadding =
        EdgeInsets.symmetric(horizontal: 20, vertical: 7.0);
    return SafeArea(
      child: Scaffold(
        body: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                Stack(
                  children: [
                    Container(
                      height: 280,
                      decoration: BoxDecoration(
                        borderRadius: const BorderRadius.only(
                          bottomLeft: Radius.circular(100),
                        ),
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: <Color>[
                            Theme.of(context).primaryColor,
                            secondGradientColor,
                          ],
                        ),
                      ),
                      child: Center(
                        child: Container(
                          height: 110.0,
                          padding: const EdgeInsets.all(15),
                          decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.white,
                                width: 3.0,
                              )),
                          child: const FlutterLogo(
                            size: 70,
                          ),
                        ),
                      ),
                    ),
                    const Positioned(
                      bottom: 35.0,
                      right: 40.0,
                      child: Text(
                        'Chat App',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 28.0,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 70,
                ),
                if (_isSignUp)
                  Padding(
                    padding: textFieldPadding,
                    child: TextFormFieldWidget(
                      lableText: 'Name',
                      icon: Icons.group_outlined,
                      validator: nameValidator,
                      textInputAction: TextInputAction.next,
                      onSaved: (value) {
                        _userData['name'] = value;
                      },
                    ),
                  ),
                Padding(
                  padding: textFieldPadding,
                  child: TextFormFieldWidget(
                    lableText: 'Email',
                    icon: Icons.email_outlined,
                    validator: requiredEmailValidator,
                    textInputAction: TextInputAction.next,
                    keyboardType: TextInputType.emailAddress,
                    onSaved: (value) {
                      _userData['email'] = removeSpaceFromString(value!);
                    },
                  ),
                ),
                Padding(
                  padding: textFieldPadding,
                  child: TextFormFieldWidget(
                    lableText: 'Password',
                    obscureText: true,
                    icon: Icons.lock_outline,
                    validator: nameValidator,
                    textInputAction: TextInputAction.done,
                    onSaved: (value) {
                      _userData['password'] = value;
                    },
                  ),
                ),
                const SizedBox(
                  height: 30.0,
                ),
                ElevatedButton(
                  onPressed: _submitAuthForm,
                  child: Text(
                    _isSignUp ? 'SignUp' : 'Login',
                  ),
                ),
                TextButton(
                    onPressed: () {
                      setState(() {
                        _isSignUp = !_isSignUp;
                      });
                    },
                    child: Text(!_isSignUp
                        ? 'Don\'t have an account? SignUp'
                        : 'already have an account? Login'))
              ],
            ),
          ),
        ),
      ),
    );
  }
}
