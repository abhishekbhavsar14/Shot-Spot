import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:insta_image_viewer/insta_image_viewer.dart';
import 'package:shoe_spot/cart_screen.dart';
import 'package:shoe_spot/order_summary_screen.dart';

class ItemDataScreen extends StatefulWidget {
  String itemUrl;
  String itemName;
  String ratings;
  String description;
  int price;
  String? documentId;
  ItemDataScreen(
      {super.key,
      required this.itemUrl,
      required this.itemName,
      required this.price,
      required this.description,
      required this.ratings,
      this.documentId});

  @override
  State<ItemDataScreen> createState() => _ItemDataScreenState();
}

class _ItemDataScreenState extends State<ItemDataScreen> {
  int selectedSizeIndex = -1; // No size selected initially
  String cartButton = 'Add to Cart';
  final List<String> sizes = ['38', '40', '42', '44', '46']; // Sizes list

  @override
  void initState() {
    super.initState();
    getData();
  }

  void getData() {
    FirebaseFirestore.instance
        .collection('Cart Items')
        .doc(FirebaseAuth.instance.currentUser?.email)
        .collection('Items')
        .snapshots()
        .listen((snapshot) {
      for (var data in snapshot.docs) {
        var map = data.data();
        var itemName = map['itemName'];
        if (widget.itemName == itemName) {
          setState(() {
            cartButton = 'Go to Cart';
          });
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    Color common = Color(0xFF639BF6);
    return WillPopScope(
      onWillPop: () async{
        Navigator.pop(context);
        return false;
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
            iconTheme: IconThemeData(color: Colors.white),
            backgroundColor: common,
            title: Text('Prouduct detail',
                style: GoogleFonts.podkova(
                    fontSize: 20,
                    color: Colors.white,
                    fontWeight: FontWeight.bold))),
        body: Center(
          child: Column(
            children: [
              InstaImageViewer(
                  child: Image.network(
                widget.itemUrl,
                fit: BoxFit.contain,
                width: MediaQuery.sizeOf(context).width * 0.7,
                height: 200,
              )),
              SizedBox(
                height: 10,
              ),
              Expanded(
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                      boxShadow: [
                        BoxShadow(
                            color: Colors.black12, spreadRadius: 1, blurRadius: 4)
                      ],
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(35),
                          topRight: Radius.circular(35))),
                  child: Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 15, vertical: 20),
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Text(
                                  widget.itemName,
                                  style: GoogleFonts.roboto(
                                      fontSize: 19,
                                      color: Colors.black,
                                      fontWeight: FontWeight.w600),
                                ),
                              ),
                              SizedBox(
                                width: 10,
                              ),
                              Text(
                                '\u0024 ${widget.price}',
                                style: GoogleFonts.workSans(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 20,
                                    color: Colors.black),
                              ),
                            ],
                          ),
                          SizedBox(
                            height: 5,
                          ),
                          Row(
                            children: [
                              Icon(
                                Icons.star,
                                color: Colors.yellow,
                                size: 25,
                              ),
                              Text(
                                ' ${widget.ratings}',
                                style: GoogleFonts.roboto(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w400,
                                  color: Colors.black,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                          SizedBox(height: 8),
                          Align(
                            alignment: Alignment.topLeft,
                            child: Text(
                              widget.description,
                              style: GoogleFonts.nunito(
                                  fontSize: 17, color: Colors.black),
                            ),
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          Align(
                            alignment: Alignment.topLeft,
                            child: Text('Size :',
                                style: GoogleFonts.roboto(
                                  fontSize: 19,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black,
                                )),
                          ),
                          SizedBox(
                            height: 5,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: sizes.asMap().entries.map((entry) {
                              int idx = entry.key;
                              String size = entry.value;
                              return GestureDetector(
                                onTap: () {
                                  setState(() {
                                    selectedSizeIndex =
                                        idx; // Update selected size
                                  });
                                },
                                child: Container(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 20, vertical: 10),
                                  margin: EdgeInsets.symmetric(
                                      horizontal: 3), // Spacing between sizes
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      color: selectedSizeIndex == idx
                                          ? common
                                          : Colors.black12,
                                    ),
                                    borderRadius: BorderRadius.circular(10),
                                    color: selectedSizeIndex == idx
                                        ? common
                                        : Colors.transparent,
                                  ),
                                  child: Text(
                                    size,
                                    style: GoogleFonts.poppins(
                                      fontSize: 14,
                                      color: selectedSizeIndex == idx
                                          ? Colors.white
                                          : Colors.black,
                                    ),
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              Container(
                width: double.infinity,
                height: 50,
                child: Row(
                  children: [
                    Expanded(
                        child: InkWell(
                      onTap: () {
                        if (cartButton == 'Go to Cart') {
                          Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (context) => CartScreen(),
                              ));
                        } else {
                          setState(() {
                            addToCart(widget.itemUrl, widget.itemName,
                                widget.price, widget.description, widget.ratings);
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                              duration: Duration(milliseconds: 1000),
                              backgroundColor: common,
                              content: Text(
                                'Item Added to Cart Successfully',
                                style: GoogleFonts.poppins(
                                    color: Colors.white, fontSize: 17),
                              ),
                            ));
                          });
                        }
                      },
                      child: Container(
                        alignment: Alignment.center,
                        height: double.infinity,
                        decoration: BoxDecoration(boxShadow: [
                          BoxShadow(
                              color: Colors.black12,
                              blurRadius: 1,
                              spreadRadius: 1)
                        ], color: Colors.white),
                        child: Text(cartButton,
                            style: GoogleFonts.roboto(
                              fontSize: 18,
                              color: Colors.black,
                            )),
                      ),
                    )),
                    Expanded(
                        child: InkWell(
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => OrderSummaryScreen(
                                itemUrl: widget.itemUrl,
                                itemName: widget.itemName,
                                price: widget.price,
                                description: widget.description,
                                ratings: widget.ratings,
                                documentId: widget.documentId,
                              ),
                            ));
                      },
                      child: Container(
                        decoration: BoxDecoration(boxShadow: [
                          BoxShadow(
                              color: Colors.black12,
                              blurRadius: 1,
                              spreadRadius: 1)
                        ], color: common),
                        alignment: Alignment.center,
                        child: Text('Buy Now',
                            style: GoogleFonts.roboto(
                              fontSize: 18,
                              color: Colors.white,
                            )),
                      ),
                    )),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  void addToCart(String itemUrl, String itemName, int price, String description,
      String ratings) {
    Map<String, dynamic> itemData = {
      'itemUrl': itemUrl,
      'itemName': itemName,
      'price': price,
      'description': description,
      'ratings': ratings,
    };
    try {
      var store = FirebaseFirestore.instance;
      store
          .collection('Cart Items')
          .doc(FirebaseAuth.instance.currentUser?.email)
          .collection('Items')
          .add(itemData);
    } on FirebaseException catch (e) {
      print(e.message);
    }
  }
}
