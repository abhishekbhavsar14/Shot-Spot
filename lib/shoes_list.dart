import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:page_transition/page_transition.dart';
import 'package:shoe_spot/item_data_screen.dart';

class ShoesList extends StatefulWidget {
  String category;
  ShoesList({super.key, required this.category});

  @override
  State<ShoesList> createState() => _ShoesListState();
}

class _ShoesListState extends State<ShoesList> {
  Color common = Color(0xFF639BF6);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF0F8FF),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 0,vertical: 10),
        child: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('Category')
              .doc(widget.category)
              .collection('items')
              .snapshots(),
          builder: (context, snapshot) {
            try{
              List<DocumentSnapshot> list = snapshot.data!.docs;
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator(color: common,));
              }else if(snapshot.hasError){
                return Center(child: Text('${snapshot.error}'),);
              }else {
                return GridView.builder(
                  itemCount: list.length,
                  gridDelegate:
                  SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2,crossAxisSpacing: 0,mainAxisSpacing: 0),
                  itemBuilder: (context, index) {
                    Map<String,dynamic> map =list[index].data() as Map<String,dynamic>;
                    var url = map['itemUrl'];
                    var itemName = map['itemName'];
                    var price = map['itemPrice'];
                    var ratings = map['ratings'];
                    var description = map['description'];
                    return InkWell(
                      onTap: () => Navigator.push(context,PageTransition(child: ItemDataScreen(itemUrl: url, itemName: itemName, price: price, description: description, ratings: ratings,), type: PageTransitionType.bottomToTop)),
                      child: Card(
                        color: Colors.white,
                        child: Padding(
                          padding: const EdgeInsets.all(4.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Image.network(url,height: 80,width: double.infinity,fit: BoxFit.contain,),
                              SizedBox(height: 8,),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(child: Text(itemName,style: GoogleFonts.poppins(fontSize: 14, color: Colors.black,),maxLines: 1,overflow:TextOverflow.ellipsis,)),
                                  SizedBox(width: 3,),
                                  Row(
                                    children: [
                                      Icon(Icons.star,color: Colors.yellow,size: 18,),
                                      Text('${ratings}',style: GoogleFonts.poppins(fontSize: 15, color: Colors.black,),maxLines: 2,overflow:TextOverflow.ellipsis,),
                                    ],
                                  ),
                                ],
                              )
                              ,SizedBox(height: 2,),
                              Text('\u0024 ${price}',style: GoogleFonts.workSans(fontSize: 18, color: Colors.black,fontWeight: FontWeight.bold),),

                            ],
                          ),
                        ),
                      ),
                    );
                  },
                );
              }
            }catch(e){
              print(e);
            }
            return Container();
          },
        ),
      ),
    );
  }
}
