import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shoe_spot/home_screen.dart';

class AdminPanel extends StatefulWidget {
  const AdminPanel({super.key});

  @override
  State<AdminPanel> createState() => _AdminPanelState();
}

class _AdminPanelState extends State<AdminPanel> {
  final itemUrl = TextEditingController();
  final itemName = TextEditingController();
  Color common = Color(0xFF639BF6);
  final itemPrice = TextEditingController();
  final description = TextEditingController();
  final List<String> items = ['Nike', 'Adidas', 'Puma', 'Bata', 'Campus'];
  String? category;
  final ratings = TextEditingController();
  Map<String, dynamic>? map;
  bool goPreviousOrNot = true;
  String? url;
  @override
  void initState() {
    super.initState();
    fetchUserData(); // Fetch data when the widget is initialized
  }

  Future<void> fetchUserData() async {
    var user = FirebaseAuth.instance.currentUser!.email;
    DocumentSnapshot snapshot =
    await FirebaseFirestore.instance.collection('Users').doc(user).get();
    setState(() {
      map = snapshot.data() as Map<String, dynamic>;
      url = map?['image'];
    });
  }

  Future<bool> _onWillPop() async {
    if (FirebaseAuth.instance.currentUser != null) {
      goPreviousOrNot = false;
      print(goPreviousOrNot);
      return goPreviousOrNot;
    }
    print('Not Exit $goPreviousOrNot');
    return goPreviousOrNot; // Exit the app if on the home screen
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        appBar: AppBar(
          iconTheme: IconThemeData(color: Colors.transparent),
          backgroundColor: common,
          title: Text(
            'Admin Panel',
            style: GoogleFonts.podkova(fontSize: 20, color: Colors.white),
          ),
          actions: [
            OutlinedButton(
                onPressed: () {
                      FirebaseAuth.instance.signOut();
                      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => HomeScreen(),));
                },
                child: Text('Sign Out',style: GoogleFonts.podkova(fontSize: 15, color: Colors.white),))
            ,SizedBox(width: 20,)
          ],
        ),
        resizeToAvoidBottomInset: false,
        body: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundImage: url != null ? NetworkImage(url!) : null,
                    child: url == null
                        ? Icon(Icons.person)
                        : null, // Fallback if no image is available
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  TextField(
                    controller: itemUrl,
                    decoration: InputDecoration(
                        border: OutlineInputBorder(), hintText: 'Enter item url'),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  TextField(
                    controller: itemName,
                    decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: 'Enter item name'),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  TextField(
                    controller: itemPrice,
                    decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: 'Enter item price'),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  TextField(
                    controller: description,
                    decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: 'Enter item description'),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  TextField(
                    controller: ratings,
                    decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: 'Enter item ratings'),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                        border: Border.all(color: Colors.black),
                        borderRadius: BorderRadius.circular(5)),
                    child: Padding(
                      padding:
                          const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
                      child: DropdownButton<String>(
                        menuMaxHeight: 200,
                        icon: SizedBox.shrink(),
                        elevation: 5,
                        underline: SizedBox.shrink(),
                        value: category,
                        hint: Text('Select Category'),
                        items: items.map((String item) {
                          return DropdownMenuItem<String>(
                            value: item,
                            child: Text(item),
                          );
                        }).toList(),
                        onChanged: (String? newValue) {
                          setState(() {
                            category = newValue;
                          });
                        },
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      OutlinedButton(
                          onPressed: () {
                            addItem(
                                itemName.text.toString().trim(),
                                itemUrl.text.toString().trim(),
                                int.parse(itemPrice.text.toString().trim()),
                                description.text.toString().trim(),
                                ratings.text.toString().trim(),
                                category.toString().trim());
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                backgroundColor: common,
                                content: Text('Item Added Successfully',
                                    style: GoogleFonts.poppins(
                                        fontSize: 14, color: Colors.white))));
                          },
                          child: Text(
                            'Add Item',
                            style: GoogleFonts.poppins(fontSize: 14),
                          )),
                      OutlinedButton(
                          onPressed: () {
                            updateItem(
                                itemName.text.toString().trim(),
                                itemUrl.text.toString().trim(),
                                int.parse(itemPrice.text.toString().trim()),
                                description.text.toString().trim(),
                                ratings.text.toString().trim(),
                                category.toString().trim());
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                backgroundColor: common,
                                content: Text(
                                  'Item Update Successfully',
                                  style: GoogleFonts.poppins(
                                      fontSize: 14, color: Colors.white),
                                )));
                          },
                          child: Text(
                            'Update Item',
                            style: GoogleFonts.poppins(fontSize: 14),
                          )),
                    ],
                  ),
                  OutlinedButton(
                      onPressed: () {
                        delete(
                            itemName.text.toString().trim(), category.toString());
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            backgroundColor: common,
                            content: Text('Item Deleted Successfully',
                                style: GoogleFonts.poppins(
                                    fontSize: 14, color: Colors.white))));
                      },
                      child: Text(
                        'Delete Item',
                        style: GoogleFonts.poppins(fontSize: 14),
                      )),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void addItem(String itemName, String itemUrl, int itemPrice,
      String description, String ratings, String category) async {
    var firestore = FirebaseFirestore.instance;
    final Map<String, dynamic> data = {
      'itemName': itemName,
      'itemUrl': itemUrl,
      'itemPrice': itemPrice,
      'description': description,
      'ratings': ratings,
      'category': category,
      'createdAt': FieldValue.serverTimestamp(),
    };
    firestore
        .collection('Category')
        .doc(category)
        .collection('items')
        .doc(itemName)
        .set(data)
        .then((docRef) {
      print("Item added with ");
    }).catchError((error) {
      print("Failed to add item: $error");
    });
  }

  void updateItem(String itemName, String itemUrl, int itemPrice,
      String description, String ratings, String category) async {
    var firestore = FirebaseFirestore.instance;
    final Map<String, dynamic> data = {
      'itemName': itemName,
      'itemUrl': itemUrl,
      'itemPrice': itemPrice,
      'description': description,
      'ratings': ratings,
      'category': category,
      'createdAt': FieldValue.serverTimestamp(),
    };
    firestore
        .collection('Category')
        .doc(category)
        .collection('items')
        .doc(itemName)
        .update(data)
        .then((docRef) {
      print("Item added with ");
    }).catchError((error) {
      print("Failed to add item: $error");
    });
  }

  void delete(String itemName, String category) async {
    var firestroe = FirebaseFirestore.instance;
    firestroe
        .collection('Category')
        .doc(category)
        .collection('items')
        .doc(itemName)
        .delete();
  }
}
