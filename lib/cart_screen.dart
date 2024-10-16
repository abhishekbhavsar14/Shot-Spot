
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shoe_spot/item_data_screen.dart';
import 'package:shoe_spot/order_summary_screen.dart';

import 'dumy.dart';

class CartScreen extends StatefulWidget {
  String? itemUrl;
  String? itemName;
  String? ratings;
  String? description;
  int? price;
  CartScreen({super.key})
      : itemUrl =
            null, // Set null or provide defaults for the default constructor
        itemName = null,
        price = null,
        description = null,
        ratings = null;
  CartScreen.toCart(
      {super.key,
      required this.itemUrl,
      required this.itemName,
      required this.price,
      required this.description,
      required this.ratings});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  Razorpay razorpay = Razorpay();
  List<Map<String, dynamic>> itemList = [];
  Color common = Color(0xFF639BF6);
  num totalPrice = 0;

  @override
  void initState() {
    super.initState();
    // Fetch and calculate total price when the widget is created
    calculateTotalPrice();
    setState(() {
      totalPrice = 0;
    });
    NoItemFound();
  }


  void calculateTotalPrice() {
    FirebaseFirestore.instance
        .collection('Cart Items')
        .doc(FirebaseAuth.instance.currentUser?.email)
        .collection('Items')
        .snapshots()
        .listen((snapshot) {
      double newTotalPrice = 0;

      // Iterate over all documents in the snapshot to calculate total price
      for (var doc in snapshot.docs) {
        var data = doc.data();
        var price = data['price'];

        if (price != null) {
          newTotalPrice += price;
        }
      }

      setState(() {
        totalPrice = newTotalPrice;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    return WillPopScope(
      onWillPop: () async{
      Navigator.pop(context);
      return true;
      },
      child: Scaffold(
          appBar: AppBar(
            iconTheme: IconThemeData(color: Colors.white),
            backgroundColor: common,
            title: Text(
              'Cart',
              style: GoogleFonts.podkova(
                  fontSize: 20, color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
          backgroundColor: Color(0xFFF0F8FF),
          body: totalPrice == 0 ? NoItemFound() : Column(
            children: [
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('Cart Items')
                      .doc(FirebaseAuth.instance.currentUser?.email)
                      .collection('Items')
                      .snapshots(),
                  builder: (context, snapshot) {
                    try {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Center(
                            child: CircularProgressIndicator(
                          color: Colors.black,
                        ));
                      } else if (snapshot.hasError) {
                        print(snapshot.error);
                      } else {
                        List<DocumentSnapshot> list = snapshot.data!.docs;
                        itemList = list.map((doc) {
                          return doc.data() as Map<String, dynamic>;
                        }).toList();
                        return ListView.builder(
                          itemBuilder: (context, index) {
                            Map<String, dynamic> data =
                                list[index].data() as Map<String, dynamic>;
                            var image = data['itemUrl'];
                            var itemName = data['itemName'];
                            var price = data['price'];
                            var ratings = data['ratings'];
                            var description = data['description'];
                            var documentId = list[index].id;
                            totalPrice += price;
                            print(totalPrice);
                            return Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 5),
                              child: InkWell(
                                onTap: () => Navigator.push(context,MaterialPageRoute(builder: (context) => ItemDataScreen(itemUrl: image, itemName: itemName, price: price, description: description, ratings: ratings,documentId: documentId,),)),
                                child: Container(
                                  padding: EdgeInsets.all(12.0),
                                  decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(10),
                                      boxShadow: [
                                        BoxShadow(
                                            color: Colors.black12,
                                            blurRadius: 1,
                                            spreadRadius: 1)
                                      ]),
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Image.network(
                                        image,
                                        height: 80,
                                        width: 100,
                                        fit: BoxFit.contain,
                                      ),
                                      SizedBox(
                                        width: 4,
                                      ),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              itemName,
                                              style: GoogleFonts.poppins(
                                                fontWeight: FontWeight.w500,
                                                fontSize: 16,
                                              ),
                                            ),
                                            Text(
                                              ' \$ $price',
                                              style: GoogleFonts.workSans(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold),
                                            ),
                                            Row(
                                              children: [
                                                Icon(
                                                  Icons.star,
                                                  color: Colors.yellow,
                                                ),
                                                Text(
                                                  ratings,
                                                  style: GoogleFonts.poppins(
                                                      fontSize: 15),
                                                ),
                                              ],
                                            )
                                          ],
                                        ),
                                      ),
                                      Column(
                                        children: [
                                          InkWell(
                                              onTap: () async {
                                                  FirebaseFirestore.instance
                                                      .collection('Cart Items')
                                                      .doc(FirebaseAuth.instance
                                                          .currentUser?.email)
                                                      .collection('Items')
                                                      .doc(documentId)
                                                      .delete();
                                              },
                                              child: Icon(
                                                Icons.delete,
                                                color: common,
                                              ))
                                        ],
                                      )
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                          itemCount: list.length,
                        );
                      }
                    } catch (e) {
                      print('error $e');
                    }
                    return Container();
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10,vertical: 6),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      children: [
                        Text('Total Price',
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              color: Colors.black,
                            )),
                        Text(
                          '\$ $totalPrice',
                          style: GoogleFonts.workSans(
                              fontSize: 18,
                              color: Colors.black,
                              fontWeight: FontWeight.bold),
                        )
                      ],
                    ),
                    InkWell(
                      onTap: () {
                        var options = {
                          'key': 'rzp_test_1DP5mmOlF5G5ag',
                          'amount': (totalPrice * 100)*83,
                          'name': "All Cart Items",
                          'description': 'Fine T-Shirt',
                          'prefill': {
                            'contact': '8888888888',
                            'email': 'test@razorpay.com'
                          }
                        };
                        razorpay.open(options);
                      },
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 20,vertical: 10),
                        decoration: BoxDecoration(color: common,borderRadius: BorderRadius.circular(10.0)),
                        child: Text('Proceed',
                            style: GoogleFonts.poppins(
                              fontSize: 17,
                              color: Colors.white,
                            )),
                      ),
                    ),
                  ],
                ),
              )
            ],
          )),
    );
  }
  Widget NoItemFound(){
    return Center(child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
      Image.asset('assets/images/add_item.png'),
      SizedBox(height: 20,),
      Text('No Items Found!',style: GoogleFonts.poppins(fontSize: 23,color: Colors.black,fontWeight: FontWeight.w600),)
    ],),);
  }
  @override
  void dispose() {
    razorpay.clear();
    super.dispose();
  }
  bool isOrderAdded = false; // Add a flag
  void _handlePaymentSuccess(PaymentSuccessResponse response) async{
    if (!isOrderAdded) { // Check if the order has already been added
      isOrderAdded = true; // Set the flag to true to prevent multiple additions

      Fluttertoast.showToast(
        msg: 'Payment success',
        backgroundColor: common,
        textColor: Colors.white,
        gravity: ToastGravity.SNACKBAR,
        toastLength: Toast.LENGTH_SHORT,
        fontSize: 17,
      );
      CollectionReference cartItemsRef = FirebaseFirestore.instance.collection('Cart Items');
      QuerySnapshot cartItemsSnapshot = await cartItemsRef.doc(FirebaseAuth.instance.currentUser!.email).collection('Items').get();
      List<QueryDocumentSnapshot> cartItems = cartItemsSnapshot.docs;
      for(var data in cartItems){
       addOrderHistory(data['itemUrl'], data['itemName'], data['price'], data['ratings']);
      }
      for(var data in cartItems){
        FirebaseFirestore.instance
            .collection('Cart Items')
            .doc(FirebaseAuth.instance.currentUser!.email)
            .collection('Items')
            .doc(data.id)
            .delete();
      }

      // Navigate to the HomePageScreen
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => HomePageScreen(),
        ),
      );
    }
  }

  void addOrderHistory(String itemUrl, String itemName, int price,
      String ratings){
    Map<String, dynamic> itemData = {
      'itemUrl': itemUrl,
      'itemName': itemName,
      'price': price,
      'ratings': ratings,
    };
    try {
      var store = FirebaseFirestore.instance;
      store
          .collection('Orders History')
          .doc(FirebaseAuth.instance.currentUser?.email)
          .collection('Orders')
          .add(itemData);
    } on FirebaseException catch (e) {
      print(e.message);
    }
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    Fluttertoast.showToast(
        msg: 'Payment failed',
        backgroundColor: common,
        textColor: Colors.white,
        gravity: ToastGravity.SNACKBAR,
        toastLength: Toast.LENGTH_SHORT,
        fontSize: 17);
  }
}
