import 'package:carousel_slider/carousel_options.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:shoe_spot/admin_panel.dart';
import 'package:shoe_spot/cart_screen.dart';
import 'package:shoe_spot/home_screen.dart';
import 'package:shoe_spot/item_home_screen.dart';
import 'package:shoe_spot/order_history.dart';
import 'package:shoe_spot/shoes_list.dart';
import 'package:shoe_spot/user_profile_screen.dart';

class HomePageScreen extends StatefulWidget {
  @override
  _MyWidgetState createState() => _MyWidgetState();
}

class _MyWidgetState extends State<HomePageScreen> {
  Color common = Color(0xFF639BF6);
  Map<String, dynamic>? map;
  String? url;
  int _selectedIndex = 0;

  final List<Widget> bottomNavList = [
    ItemHomeScreen(),
    CartScreen(),
    OrderHistory(),
    UserProfileScreen()
  ];

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
    if (_selectedIndex != 0) {
      setState(() {
        _selectedIndex = 0; // Navigate back to home screen
      });
      return false; // Prevent the app from closing
    }
    return true; // Exit the app if on the home screen
  }


  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop ,
      child: Scaffold(
        backgroundColor: Color(0xFFF0F8FF),
        body:IndexedStack(index: _selectedIndex,children: bottomNavList,),
        bottomNavigationBar: Container(
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(10.0),color: Colors.white,),
          padding: EdgeInsets.symmetric(horizontal: 5,vertical: 10),
          child: Padding(
            padding: const EdgeInsets.only(left: 4,right: 5),
            child: GNav(
                rippleColor: Colors.grey, // tab button ripple color when pressed
                haptic: true, // haptic feedback
                tabBorderRadius: 15,
                tabActiveBorder: Border.all(color: Colors.white, width: 1), // tab button border
                curve: Curves.easeOutExpo, // tab animation curves
                duration: Duration(milliseconds: 200), // tab animation duration
                gap: 8, // the tab button gap between icon and text
                color: Colors.black, // unselected icon color
                activeColor: Colors.white, // selected icon and text color
                iconSize: 28, // tab button icon size
                tabBackgroundColor: common, // selected tab background color
                padding: EdgeInsets.symmetric(horizontal: 17, vertical: 5),
                selectedIndex: _selectedIndex, // current selected index
                onTabChange: (index) {
                  setState(() {
                    _selectedIndex = index; // update the selected index
                  });
                },// navigation bar padding
                tabs: [
                  GButton(
                    icon: Icons.home,
                    text: 'Home',
                    textStyle: GoogleFonts.poppins(
                        fontSize: 15,color: Colors.white),
                  ),
                  GButton(
                    icon: Icons.shopping_cart,
                    text: 'Cart',
                    textStyle: GoogleFonts.poppins(
                      fontSize: 15,color: Colors.white),
                  ),
                  GButton(
                    icon: Icons.assignment,
                    text: 'Orders',
                    textStyle: GoogleFonts.poppins(
                        fontSize: 15,color: Colors.white),
                  ),
                  GButton(
                    icon: Icons.account_circle_rounded,
                    text: 'Profile',
                    textStyle: GoogleFonts.poppins(
                      fontSize: 15,color: Colors.white),
                  ),
                ],
              ),
          ),
        ),
      ),
    );
  }
}
