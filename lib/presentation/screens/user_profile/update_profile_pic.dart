import 'package:batuaa/colors.dart';
import 'package:batuaa/logic/profile_controller.dart';
import 'package:batuaa/presentation/widgets/button.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:provider/provider.dart';
import 'dart:io';
import '../../../logic/flutter_toast.dart';

class profilepicScreen extends StatefulWidget {
  const profilepicScreen({super.key});

  @override
  State<profilepicScreen> createState() => _profilepicScreenState();
}

class _profilepicScreenState extends State<profilepicScreen> {
  String imageUrl = " ";

  String? value;

  DropdownMenuItem<String> buildMenuItem(String item) =>
      DropdownMenuItem(value: item, child: Text(item));

  DatabaseReference ref = FirebaseDatabase.instance.ref().child('Users');

  final user = FirebaseAuth.instance.currentUser!;

  final _formKey = GlobalKey<FormState>();

  bool loading = false;


DatabaseReference splitRef = FirebaseDatabase.instance.ref().child('Users');


  Future update() async {
    setState(() {
      loading = true;
    });
    await ref.child(user.uid).update({
    }).then((value) {
      Navigator.pop(context);
      ToastMessage().toastMessage('Updated!', Colors.green);
      setState(() {
        loading = false;
      });
    }).onError((error, stackTrace) {
      ToastMessage().toastMessage(error.toString(), Colors.red);
      setState(() {
        loading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ChangeNotifierProvider(
        create: (_) => ProfileController(),
        child: Consumer<ProfileController>(
          builder: (context, provider, child) {
            return LayoutBuilder(
              builder: (BuildContext context, BoxConstraints constraints) {
                return OrientationBuilder(
                  builder: (BuildContext context, Orientation orientation) {
                    return SafeArea(
                      child: SingleChildScrollView(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 30),
                          child: Form(
                            key: _formKey,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(height: constraints.maxHeight * 0.03),
                                Row(
                                  children: [
                                    IconButton(
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                      },
                                      icon: const Icon(
                                        Icons.keyboard_backspace,
                                        size: 22,
                                      ),
                                    ),
                                    SizedBox(
                                      width: constraints.maxWidth * 0.03,
                                    ),
                                    const Text(
                                      'Update Profile Icon',
                                      textAlign: TextAlign.start,
                                      style: TextStyle(
                                          fontSize: 24,
                                          fontWeight: FontWeight.w400),
                                    ),
                                  ],
                                ),
                                SizedBox(height: constraints.maxHeight * 0.03),
                                Center(
                                  child: Stack(
                                    children: [
                                      Container(
                                        height: 120,
                                        width: 130,
                                        decoration: BoxDecoration(
                                            border: Border.all(
                                                width: 4,
                                                color: Theme.of(context)
                                                    .cardColor),
                                            shape: BoxShape.circle,
                                            color:
                                                Theme.of(context).canvasColor),
                                        child: ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(100),
                                          child: provider.image == null
                                              ? const Icon(
                                                  Icons.person,
                                                  size: 90,
                                                  color: kGrayTextC,
                                                )
                                              : Image.file(
                                                  File(provider.image!.path)
                                                      .absolute),
                                        ),
                                      ),
                                      Positioned(
                                        bottom: 10,
                                        right: 3,
                                        child: Container(
                                            height: 35,
                                            width: 35,
                                            decoration: BoxDecoration(
                                                border: Border.all(
                                                    width: 3,
                                                    color: Theme.of(context)
                                                        .primaryColor),
                                                shape: BoxShape.circle,
                                                color: Theme.of(context)
                                                    .cardColor),
                                            child: GestureDetector(
                                              onTap: () {
                                                provider.pickImage(context);
                                              },
                                              child: const Icon(
                                                Icons.edit,
                                                size: 20,
                                                color: kGrayTextC,
                                              ),
                                            )),
                                      ),
                                    ],
                                  ),
                                ),


                                SizedBox(
                                  height: constraints.maxHeight * 0.05,
                                ),
                                TButton(
                                  constraints: constraints,
                                  btnColor: Theme.of(context).primaryColor,
                                  btnText: 'Continue',
                                  onPressed: () {
                                    if (_formKey.currentState!.validate()) {
                                      _formKey.currentState!.save();
                                      update();
                                    }
                                  },
                                ),
                                SizedBox(
                                  height: orientation == Orientation.portrait
                                      ? constraints.maxHeight * 0.04
                                      : constraints.maxHeight * 0.08,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            );
          },
        ),
      ),
    );
  }

  SizedBox SBox(BoxConstraints constraints) =>
      SizedBox(height: constraints.maxHeight * 0.015);
}
