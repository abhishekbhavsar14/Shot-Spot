import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shoe_spot/shoes_list.dart';

import 'home_screen.dart';

class ItemHomeScreen extends StatefulWidget {
  void getData(){

  }
   ItemHomeScreen({super.key});

  @override
  State<ItemHomeScreen> createState() => _ItemHomeScreenState();
}

class _ItemHomeScreenState extends State<ItemHomeScreen> {
  Color common = const Color(0xFF639BF6);
  Map<String, dynamic>? map;
  String? url;
  int selectedIndex = 0;
  final List<Widget> _tableContent = [
    ShoesList(category: 'Nike'),
    ShoesList(category: 'Adidas'),
    ShoesList(category: 'Puma'),
    ShoesList(category: 'Bata'),
    ShoesList(category: 'Campus'),
  ];

  @override
  void initState() {
    super.initState();
    fetchUserData();
  }
  final List<String> imageList = [
    'https://images.pexels.com/photos/847371/pexels-photo-847371.jpeg?auto=compress&cs=tinysrgb&w=600',
    'https://images.pexels.com/photos/1240892/pexels-photo-1240892.jpeg?auto=compress&cs=tinysrgb&w=600',
    'https://images.pexels.com/photos/40662/shoes-footwear-hiking-shoes-walking-40662.jpeg?auto=compress&cs=tinysrgb&w=600',
    'https://images.pexels.com/photos/1307128/pexels-photo-1307128.jpeg?auto=compress&cs=tinysrgb&w=600'
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF0F8FF),
      appBar: AppBar(
        backgroundColor: common,
        leading: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: CircleAvatar(
            backgroundImage: url != null ? NetworkImage(url!) : null,
            child: url == null
                ? Icon(Icons.person)
                : null, // Fallback if no image is available
          ),
        ),
        title: Text(
          'Hello ${map?['firstName']}' ?? 'Loading...',
          style: GoogleFonts.podkova(fontSize: 18, color: Colors.white,fontWeight: FontWeight.bold),
        ),
      ),
      body: RefreshIndicator(
        backgroundColor: common,
        color: Colors.white,
        onRefresh: fetchUserData,
        child: Padding(
          padding:  EdgeInsets.symmetric(horizontal: 10,vertical: 5),
          child: Column(
            children: [
              CarouselSlider.builder(
                itemCount: imageList.length,
                itemBuilder: (context, index, realIndex) {
                  final urlImage = imageList[index];
                  return Container(
                    margin: EdgeInsets.symmetric(horizontal: 5.0),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(5.0),
                      child: Image.network(
                        urlImage,
                        fit: BoxFit.fill,
                        width: MediaQuery.of(context).size.width * 0.96,
                      ),
                    ),
                  );
                },
                options: CarouselOptions(
                  height: 150.0,
                  autoPlay: true,
                  autoPlayInterval: Duration(seconds: 2),
                  autoPlayAnimationDuration: Duration(milliseconds: 800),
                  enlargeCenterPage: true,
                  viewportFraction: 1.0,
                ),
              ),
              SizedBox(
                height: 10,
              ),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _buildBrandContainer('Nike', 0),
                    SizedBox(width: 10),
                    _buildBrandContainer('Adidas', 1),
                    SizedBox(width: 10),
                    _buildBrandContainer('Puma', 2),
                    SizedBox(width: 10),
                    _buildBrandContainer('Bata', 3),
                    SizedBox(width: 10),
                    _buildBrandContainer('Campus', 4),
                  ],
                ),
              ),
              Expanded(child: IndexedStack(children: _tableContent,index: selectedIndex,))
            ],
          ),
        ),
      ),
    );
  }
  Widget _buildBrandContainer(String brandName, int index) {
    bool isSelected = selectedIndex == index;
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedIndex = index;
        });
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 13, vertical: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(6),
          color: isSelected ? common : Colors.white, // Change color when selected
        ),
        child: Text(
          brandName,
          style: GoogleFonts.poppins(
            fontSize: 15,
            fontWeight: isSelected ? FontWeight.w600 : null,
            color: isSelected ? Colors.white : Colors.black, // Change text color when selected
          ),
        ),
      ),
    );
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
}
