import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';

class AgencyDetailsPage extends StatefulWidget {
  final String agencyId;

  const AgencyDetailsPage({Key? key, required this.agencyId}) : super(key: key);

  @override
  _AgencyDetailsPageState createState() => _AgencyDetailsPageState();
}

class _AgencyDetailsPageState extends State<AgencyDetailsPage> {
  late Stream<DocumentSnapshot> _agencyStream;
  late Stream<QuerySnapshot> _reviewsStream;

  @override
  void initState() {
    super.initState();
    _agencyStream = FirebaseFirestore.instance
        .collection('Agencies')
        .doc(widget.agencyId)
        .snapshots();
    _reviewsStream = FirebaseFirestore.instance
        .collection('Reviews')
        .where('agencyId', isEqualTo: widget.agencyId)
        .snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Agency Details'),
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: _agencyStream,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data?.data() == null) {
            return Center(child: Text('No agency found'));
          }

          final agencyData = snapshot.data!.data() as Map<String, dynamic>;

          return SingleChildScrollView(
            child: Container(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    agencyData['name'],
                    style: GoogleFonts.robotoCondensed(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 16),
                  Image.network(agencyData['photoUrl']),
                  SizedBox(height: 16),
                  Text(
                    'Description:',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  Text(agencyData['description']),
                  SizedBox(height: 16),
                  Text(
                    'Rating: ${agencyData['rating']}',
                    style: TextStyle(fontSize: 18),
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Reviews',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  StreamBuilder<QuerySnapshot>(
                    stream: _reviewsStream,
                    builder: (context, reviewSnapshot) {
                      if (reviewSnapshot.hasError) {
                        return Text('Error: ${reviewSnapshot.error}');
                      }

                      if (reviewSnapshot.connectionState ==
                          ConnectionState.waiting) {
                        return CircularProgressIndicator();
                      }

                      final reviews = reviewSnapshot.data!.docs;

                      return ListView.builder(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        itemCount: reviews.length,
                        itemBuilder: (context, index) {
                          final reviewData =
                              reviews[index].data() as Map<String, dynamic>;

                          return ListTile(
                            leading: Icon(Icons.star, color: Colors.amber),
                            title: Text(
                              '${reviewData['rating']} stars',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            subtitle: Text(reviewData['reviewText']),
                          );
                        },
                      );
                    },
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
