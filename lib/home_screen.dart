import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  User? userId=FirebaseAuth.instance.currentUser;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Stack(
      children: [
        Container(
          child: StreamBuilder(
            stream: FirebaseFirestore.instance.collection('users').
            where('user id',isEqualTo: userId?.uid).
            snapshots(),
            builder:(context,AsyncSnapshot<QuerySnapshot> snapshot){
              if(snapshot.hasError){
                return Text('Something went wrong');
              }
              if(snapshot.connectionState==ConnectionState.waiting){
                return Center(
                  child: CupertinoActivityIndicator(),
                );
              }
              if(snapshot.data!.docs.isEmpty){
                return Center(child: Text("No data found"),);
              }
              if(snapshot.hasData){
                return ListView.builder(
                  itemBuilder: (context,index){
                    var uname=snapshot.data!.docs[index]['name'];
                  
                          Container(
          height: double.infinity,
          width: double.infinity,
          decoration: const BoxDecoration(
            gradient: LinearGradient(colors: [
              Color(0xFF5D427A),
              Color(0xFF341359),
            ]),
          ),
          child: Padding(
            padding: const EdgeInsets.only(top: 30.0, left: 22),
            child: Text(
              'Assalamualaikum\n$uname',
              style: GoogleFonts.robotoCondensed(
                fontSize: 20,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        );
                  }
                     );
              }
              return Container();
            } ,),
        ),

  ])
  );
  }
}
