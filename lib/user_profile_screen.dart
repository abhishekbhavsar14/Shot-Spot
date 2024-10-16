import 'dart:async';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shoe_spot/admin_panel.dart';
import 'package:shoe_spot/dumy.dart';
import 'package:shoe_spot/item_home_screen.dart';

import 'forgot_password_screen.dart';
import 'home_screen.dart';

class UserProfileScreen extends StatefulWidget {
  const UserProfileScreen({super.key});

  @override
  State<UserProfileScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<UserProfileScreen> {
  TextEditingController name = TextEditingController();
  TextEditingController email = TextEditingController();
  TextEditingController password = TextEditingController();
  Color common = Color(0xFF639BF6);
  bool flag = true;
  bool progress = false;
  var imageUrl;
  bool _isLoading = false;
  File? image;
  bool checkImage = false;
  @override
  void initState() {
    super.initState();
    fetchUserData();
  }

  Future<void> fetchUserData() async {
    var user = FirebaseAuth.instance.currentUser!.email;
    DocumentSnapshot snapshot =
        await FirebaseFirestore.instance.collection('Users').doc(user).get();
    setState(() {
      // Assuming the user's name is stored under the key 'name' in Firestore
      name.text = snapshot['firstName'] ?? '';
      email.text = snapshot['email'] ?? '';
      imageUrl = snapshot['image'];
      _isLoading = false;
    });
  }

  showAlertDialog() {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: Text(
                'Camera',
                style: GoogleFonts.abel(
                    fontSize: 19,
                    fontWeight: FontWeight.w600,
                    color: Colors.black),
              ),
              onTap: () {
                pickImage(ImageSource.camera);
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: Text(
                'Gallery',
                style: GoogleFonts.abel(
                    fontSize: 19,
                    fontWeight: FontWeight.w600,
                    color: Colors.black),
              ),
              onTap: () {
                pickImage(ImageSource.gallery);
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        actions: [
          InkWell(
              onTap: () => setState(() {
                    image = null;
                    _isLoading = true;
                    fetchUserData();
                  }),
              child: Icon(
                Icons.refresh_outlined,
                color: Colors.white,
                size: 29,
              )),
          SizedBox(
            width: 25,
          )
        ],
        iconTheme: IconThemeData(color: Colors.white),
        backgroundColor: common,
        title: Text(
          'Edit Profile',
          style: GoogleFonts.podkova(
              fontSize: 20, color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: fetchUserData,
        color: Colors.white,
        backgroundColor: common,
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  InkWell(
                      onTap: showAlertDialog,
                      child: CircleAvatar(
                        radius: 50,
                        backgroundImage: image != null
                            ? FileImage(
                                image!) // Show user-selected image if not saved
                            : (imageUrl != null && imageUrl!.isNotEmpty
                                    ? NetworkImage(
                                        imageUrl!) // Show Firebase image if available
                                    : AssetImage(
                                        'assets/images/user.png') // Default image
                                ) as ImageProvider,
                      )),
                  SizedBox(
                    height: 14,
                  ),
                  TextField(
                    onSubmitted: (value) => FocusScope.of(context).unfocus(),
                    controller: name,
                    style: GoogleFonts.abel(
                        fontSize: 17, fontWeight: FontWeight.w600),
                    cursorHeight: 16,
                    cursorColor: Colors.black,
                    decoration: InputDecoration(
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        hintText: 'Enter name',
                        hintStyle: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.w400,
                            fontSize: 15),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10))),
                  ),
                  SizedBox(
                    height: 14,
                  ),
                  TextField(
                    enabled: false,
                    controller: email,
                    style: GoogleFonts.abel(
                        fontSize: 17, fontWeight: FontWeight.w600),
                    cursorHeight: 16,
                    cursorColor: Colors.black,
                    decoration: InputDecoration(
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        hintText: 'Enter mail',
                        hintStyle: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.w400,
                            fontSize: 15),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10))),
                  ),
                  SizedBox(height: 10,),
                  if(_isLoading)
                    Center(child: CircularProgressIndicator(color: common,),),
                  SizedBox(
                    height: 15,
                  ),
                  TextField(
                    onSubmitted: (value) => FocusScope.of(context).unfocus(),
                    controller: password,
                    style: GoogleFonts.abel(
                        fontSize: 17, fontWeight: FontWeight.w600),
                    cursorColor: Colors.black,
                    cursorHeight: 16,
                    obscureText: flag,
                    decoration: InputDecoration(
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        hintText: 'Enter password',
                        hintStyle: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.w400,
                            fontSize: 15),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10)),
                        suffixIcon: IconButton(
                            onPressed: () {
                              setState(() {
                                flag = !flag;
                              });
                            },
                            icon: Icon(flag
                                ? Icons.visibility_off
                                : Icons.visibility))),
                  ),
                  SizedBox(
                    height: 15,
                  ),
                  Align(
                    alignment: Alignment.bottomRight,
                    child: InkWell(
                      onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ForgotPasswordScreen(),
                          )),
                      child: Text(
                        'Forgot Password?',
                        style: GoogleFonts.poppins(
                            fontSize: 15,
                            color: common,
                            fontWeight: FontWeight.w500),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 15,
                  ),
                  InkWell(
                    child: Container(
                      alignment: Alignment.center,
                      width: double.infinity,
                      padding: EdgeInsets.all(12),
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.all(
                            Radius.circular(15),
                          ),
                          color: common),
                      child: progress
                          ? CircularProgressIndicator(
                              color: Colors.white,
                            )
                          : Text(
                              'Edit',
                              style: GoogleFonts.poppins(
                                  fontSize: 18,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w500),
                            ),
                    ),
                    onTap: () {
                      setState(() {
                        if (name.text.toString().isNotEmpty &&
                            email.text.toString().isNotEmpty &&
                            password.text.toString().isNotEmpty) {
                          progress = true;
                          checkImage = true;
                        }
                      });
                      print(
                          'Current User is : ${FirebaseAuth.instance.currentUser}');
                      if (name.text.toString().isNotEmpty &&
                          email.text.toString().isNotEmpty &&
                          password.text.toString().isNotEmpty) {
                        updateUser(
                            name.text.toString().trim(),
                            email.text.toString().trim(),
                            password.text.toString().trim());
                        password.text = '';
                        FocusScope.of(context).unfocus();
                      } else {
                        Fluttertoast.showToast(
                            msg: 'Please fill the fields',
                            backgroundColor: common,
                            textColor: Colors.white,
                            gravity: ToastGravity.BOTTOM,
                            toastLength: Toast.LENGTH_SHORT);
                      }
                    },
                  ),
                  SizedBox(
                    height: 14,
                  ),
                  InkWell(
                    onTap: () {
                      FirebaseAuth.instance.signOut();
                      Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => HomeScreen(),
                          ));
                    },
                    child: Container(
                      alignment: Alignment.center,
                      width: double.infinity,
                      padding: EdgeInsets.all(12),
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.all(
                            Radius.circular(15),
                          ),
                          color: Colors.redAccent),
                      child: Text(
                        'Sign out',
                        style: GoogleFonts.poppins(
                            fontSize: 18,
                            color: Colors.white,
                            fontWeight: FontWeight.w500),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void updateUser(String name, String newEmail, String password) async {
    try {
      User? user = FirebaseAuth.instance.currentUser;

      // Step 1: Re-authenticate the user to ensure email can be changed
      AuthCredential credential = EmailAuthProvider.credential(
        email: user!.email!,
        password: password, // User needs to enter their current password
      );

      await user.reauthenticateWithCredential(credential);

      // Step 2: Update email if a new email is provided
      if (newEmail.isNotEmpty && newEmail != user.email) {
        await user.updateEmail(newEmail);
        print('Email updated to $newEmail');
      }

      // Step 3: Upload the new profile image to Firebase Storage (if applicable)
      String? imageUrl;
      if (image != null) {
        UploadTask uploadTask = FirebaseStorage.instance
            .ref('Images')
            .child(
                name) // You can use the user's name or uid to store the image
            .putFile(image!);

        TaskSnapshot snapshot = await uploadTask;
        imageUrl = await snapshot.ref
            .getDownloadURL(); // Get the download URL of the uploaded image
      }

      // Step 4: Update user's display name and photo URL in FirebaseAuth (if applicable)
      await user.updateProfile(displayName: name, photoURL: imageUrl);

      // Step 5: Update the Firestore document with the new name, email, and image URL (if needed)
      Map<String, dynamic> userMap = {
        'firstName': name,
        'email': newEmail.isNotEmpty ? newEmail : user.email,
        'image': imageUrl,
        // Add more fields if necessary
      };
      setState(() {
        FirebaseFirestore.instance
            .collection('Users')
            .doc(user
                .email) // Use old email as document ID if you update email later
            .update(userMap)
            .then((_) {
          fetchUserData();
          print('User data updated in Firestore');
        }).catchError((error) {
          print('Error while updating Firestore data: $error');
        });
      });

      // Step 6: Notify the user that the updates were successful

      Fluttertoast.showToast(
        msg: 'User details updated successfully',
        backgroundColor: common,
        textColor: Colors.white,
        gravity: ToastGravity.BOTTOM,
        toastLength: Toast.LENGTH_SHORT,
      );
      setState(() {
        progress = false;
      });
      // Optional: Redirect the user after the update
    } on FirebaseAuthException catch (e) {
      setState(() {
        progress = false;
      });
      if (e.code == 'email-already-in-use') {
        Fluttertoast.showToast(
          msg: 'Email already in use',
          backgroundColor: common,
          textColor: Colors.white,
          gravity: ToastGravity.BOTTOM,
          toastLength: Toast.LENGTH_SHORT,
        );
      }
      // Handle errors in Firebase Authentication
      if (e.code == 'requires-recent-login') {
        Fluttertoast.showToast(
          msg: 'Please re-authenticate to perform this operation.',
          backgroundColor: common,
          textColor: Colors.white,
          gravity: ToastGravity.BOTTOM,
          toastLength: Toast.LENGTH_SHORT,
        );
      } else {
        print('Error is that: ${e.message}');
        Fluttertoast.showToast(
          msg: '${e.message}',
          backgroundColor: common,
          textColor: Colors.white,
          gravity: ToastGravity.BOTTOM,
          toastLength: Toast.LENGTH_LONG,
        );
      }
    } catch (error) {
      print('Error: $error');
    }
  }

  void pickImage(ImageSource source) async {
    try {
      var photo = await ImagePicker().pickImage(source: source);
      if (photo != null) {
        var tempfile = File(photo.path);
        setState(() {
          image = tempfile;
        });
      }
    } catch (e) {
      print(e);
    }
  }
}
