import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:rihla/agency_details_page.dart';

class ReviewsPage extends StatefulWidget {
  const ReviewsPage({Key? key}) : super(key: key);

  @override
  _ReviewsPageState createState() => _ReviewsPageState();
}

class _ReviewsPageState extends State<ReviewsPage> {
  late Stream<QuerySnapshot> _reviewsStream;

  @override
  void initState() {
    super.initState();
    final userId = FirebaseAuth.instance.currentUser!.uid;
    _reviewsStream = FirebaseFirestore.instance
        .collection('Reviews')
        .where('userId', isEqualTo: userId)
        .snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Reviews'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _reviewsStream,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.data == null || snapshot.data!.docs.isEmpty) {
            return Center(child: Text('No reviews found'));
          }

          return ListView.builder(
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              final reviewData =
                  snapshot.data!.docs[index].data() as Map<String, dynamic>;
              final agencyId = reviewData['agencyId'];
              final rating = reviewData['rating'];
              final reviewText = reviewData['reviewText'];

              return ListTile(
                title: Text('Agency: $agencyId'),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Rating: $rating'),
                    Text('Review: $reviewText'),
                  ],
                ),
                onTap: () {
                  // Navigate to the agency details page with the agencyId
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          AgencyDetailsPage(agencyId: agencyId),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
