import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shoe_spot/dumy.dart';
import 'package:shoe_spot/item_home_screen.dart';

class OrderSummaryScreen extends StatefulWidget {
  String itemUrl;
  String itemName;
  String ratings;
  String description;
  int price;
  String? documentId;
  OrderSummaryScreen(
      {super.key,
      required this.itemUrl,
      required this.itemName,
      required this.price,
      required this.description,
      required this.ratings,
      this.documentId,});

  @override
  State<OrderSummaryScreen> createState() => _OrderSummaryScreenState();
}

class _OrderSummaryScreenState extends State<OrderSummaryScreen> {
  Razorpay razorpay = Razorpay();
  Color common = Color(0xFF639BF6);
  final TextEditingController _addressController = TextEditingController();
  bool flag = true;
  @override
  void initState() {
    super.initState();
    getAddress();
  }

  getAddress() async {
    var snapshot = await FirebaseFirestore.instance
        .collection("Address")
        .doc(FirebaseAuth.instance.currentUser!.email)
        .get();
    var data = snapshot.data()!['Address'];
    _addressController.text = data;
    setState(() {
      if(_addressController.text.isNotEmpty){
        flag = false;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    return WillPopScope(
      onWillPop: () async {
        Navigator.pop(context);
        return false;
      },
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          iconTheme: IconThemeData(color: Colors.white),
          backgroundColor: common,
          title: Text(
            'Order Summary',
            style: GoogleFonts.podkova(
                fontSize: 20, color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                decoration: BoxDecoration(color: Colors.white, boxShadow: [
                  BoxShadow(
                      color: Colors.black12, spreadRadius: 1, blurRadius: 1)
                ]),
                child: Padding(
                  padding: const EdgeInsets.all(14.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Deliver to :',
                          style: GoogleFonts.roboto(
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                            color: Colors.black,
                          )),
                      SizedBox(
                        height: 5,
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 10),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: TextField(
                          enabled: flag,
                          controller: _addressController,
                          maxLines:
                              4, // Allows multiple lines for long addresses
                          decoration: InputDecoration(
                            border:
                                InputBorder.none, // Removes default underline
                            hintText: "Enter your address here",
                          ),
                          keyboardType: TextInputType.streetAddress,
                        ),
                      ),
                      SizedBox(
                        height: 8,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          InkWell(
                            onTap: () {
                              setState(() {
                                flag = true;
                              });
                            },
                              child: Icon(
                                color: common,
                            Icons.edit,
                            size: 26,
                          )),
                          SizedBox(width: 14,),
                          InkWell(
                              onTap: () {
                                setState(() {
                                  addAddress(_addressController.text.toString());
                                  flag = false;
                                });
                              },
                              child: Icon(
                                color: common,
                                Icons.check_circle,
                                size: 28,
                              )),
                          SizedBox(width: 5,)
                        ],
                      )
                    ],
                  ),
                ),
              ),
              SizedBox(
                height: 20,
              ),
              Container(
                  decoration: BoxDecoration(color: Colors.white, boxShadow: [
                    BoxShadow(
                        color: Colors.black12, spreadRadius: 1, blurRadius: 1)
                  ]),
                  child: Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 6, vertical: 10),
                    child: Column(
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Image.network(
                              widget.itemUrl,
                              height: 120,
                              width: 120,
                              fit: BoxFit.contain,
                            ),
                            SizedBox(
                              width: 10,
                            ),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Text(
                                    widget.itemName,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: GoogleFonts.roboto(
                                        fontSize: 16,
                                        color: Colors.black,
                                        fontWeight: FontWeight.w600),
                                  ),
                                  SizedBox(
                                    width: 10,
                                  ),
                                  Text(
                                    '\u0024 ${widget.price}',
                                    style: GoogleFonts.workSans(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 19,
                                        color: Colors.black),
                                  ),
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.star,
                                        color: Colors.yellow,
                                        size: 20,
                                      ),
                                      Text(
                                        ' ${widget.ratings}',
                                        style: GoogleFonts.roboto(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w400,
                                          color: Colors.black,
                                        ),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        Align(
                          alignment: Alignment.topLeft,
                          child: Text(
                            widget.description,
                            style: GoogleFonts.nunito(
                                fontSize: 15, color: Colors.black54),
                          ),
                        ),
                      ],
                    ),
                  )),
              Spacer(),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: InkWell(
                  onTap: () {
                    if (_addressController.text.isEmpty) {
                      Fluttertoast.showToast(
                          msg: 'Please enter your address',
                          backgroundColor: common,
                          textColor: Colors.white,
                          gravity: ToastGravity.SNACKBAR,
                          toastLength: Toast.LENGTH_SHORT,
                          fontSize: 17);
                    } else {
                      addAddress(_addressController.text.toString());
                      var options = {
                        'key': 'rzp_test_1DP5mmOlF5G5ag',
                        'amount': (widget.price * 100) * 83,
                        'name': widget.itemName,
                        'description': 'Fine T-Shirt',
                        'prefill': {
                          'contact': '8888888888',
                          'email': 'test@razorpay.com'
                        }
                      };
                      razorpay.open(options);
                    }
                  },
                  child: Container(
                    alignment: Alignment.center,
                    width: double.infinity,
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.all(
                          Radius.circular(15),
                        ),
                        color: common),
                    child: Text(
                      'Pay now',
                      style: GoogleFonts.poppins(
                          fontSize: 18,
                          color: Colors.white,
                          fontWeight: FontWeight.w500),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  bool isOrderAdded = false; // Add a flag

  void _handlePaymentSuccess(PaymentSuccessResponse response) {
    if (!isOrderAdded) { // Check if the order has already been added
      isOrderAdded = true; // Set the flag to true to prevent multiple additions

      Fluttertoast.showToast(
        msg: 'Payment success',
        backgroundColor: Colors.green,
        textColor: Colors.white,
        gravity: ToastGravity.SNACKBAR,
        toastLength: Toast.LENGTH_SHORT,
        fontSize: 17,
      );

      print('document id is ${widget.documentId}');

      addOrderHistory(widget.itemUrl, widget.itemName, widget.price, widget.description, widget.ratings);

      FirebaseFirestore.instance
          .collection('Cart Items')
          .doc(FirebaseAuth.instance.currentUser!.email)
          .collection('Items')
          .doc(widget.documentId)
          .delete();

      // Navigate to the HomePageScreen
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => HomePageScreen(),
        ),
      );
    }
  }


  void _handlePaymentError(PaymentFailureResponse response) {
    Fluttertoast.showToast(
        msg: 'Payment failed',
        backgroundColor: Colors.red,
        textColor: Colors.white,
        gravity: ToastGravity.SNACKBAR,
        toastLength: Toast.LENGTH_SHORT,
        fontSize: 17);
  }

  @override
  void dispose() {
    super.dispose();
    try {
      razorpay.clear();
    } catch (e) {
      print(e);
    }
  }

  void addAddress(String address) {
    FirebaseFirestore.instance
        .collection('Address')
        .doc(FirebaseAuth.instance.currentUser!.email)
        .set({'Address': address});
  }
  void addOrderHistory(String itemUrl, String itemName, int price, String description,
      String ratings){
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
          .collection('Orders History')
          .doc(FirebaseAuth.instance.currentUser?.email)
          .collection('Orders')
          .add(itemData);
    } on FirebaseException catch (e) {
      print(e.message);
    }
  }
}
