import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shoe_spot/item_data_screen.dart';

class OrderHistory extends StatefulWidget {
  String? itemUrl;
  String? itemName;
  String? ratings;
  String? description;
  int? price;
  OrderHistory({super.key})
      : itemUrl =
  null, // Set null or provide defaults for the default constructor
        itemName = null,
        price = null,
        description = null,
        ratings = null;
  OrderHistory.toCart(
      {super.key,
        required this.itemUrl,
        required this.itemName,
        required this.price,
        required this.description,
        required this.ratings});

  @override
  State<OrderHistory> createState() => _CartScreenState();
}

class _CartScreenState extends State<OrderHistory> {
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
        .collection('Orders History')
        .doc(FirebaseAuth.instance.currentUser?.email)
        .collection('Orders')
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
              'Order History',
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
                      .collection('Orders History')
                      .doc(FirebaseAuth.instance.currentUser?.email)
                      .collection('Orders')
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
        Text('No Orders Found!',style: GoogleFonts.poppins(fontSize: 23,color: Colors.black,fontWeight: FontWeight.w600),)
      ],),);
  }
}
