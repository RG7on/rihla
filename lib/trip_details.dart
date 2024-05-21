import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:rihla/booking_page.dart';
import 'package:rihla/review_page.dart';

class TripDetailsPage extends StatefulWidget {
  final String tripId;

  const TripDetailsPage({Key? key, required this.tripId}) : super(key: key);

  @override
  _TripDetailsPageState createState() => _TripDetailsPageState();
}

class _TripDetailsPageState extends State<TripDetailsPage> {
  late Stream<DocumentSnapshot> _tripStream;
  bool _isFavorite = false;

  @override
  void initState() {
    super.initState();
    _tripStream = FirebaseFirestore.instance
        .collection('Trips')
        .doc(widget.tripId)
        .snapshots();
  }

  void _checkIfFavorite() async {
    final userId = FirebaseAuth.instance.currentUser!.uid;
    final snapshot = await FirebaseFirestore.instance
        .collection('Users')
        .doc(userId)
        .collection('Favorites')
        .doc(widget.tripId)
        .get();

    setState(() {
      _isFavorite = snapshot.exists;
    });
  }

  void _toggleFavorite() async {
    final userId = FirebaseAuth.instance.currentUser!.uid;
    final favoritesRef = FirebaseFirestore.instance
        .collection('Users')
        .doc(userId)
        .collection('Favorites');

    if (_isFavorite) {
      await favoritesRef.doc(widget.tripId).delete();
    } else {
      await favoritesRef.doc(widget.tripId).set({});
    }

    setState(() {
      _isFavorite = !_isFavorite;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Trip Details'),
        actions: [
          IconButton(
            icon: Icon(
              _isFavorite ? Icons.favorite : Icons.favorite_border,
              color: _isFavorite ? Colors.red : null,
            ),
            onPressed: _toggleFavorite,
          ),
        ],
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: _tripStream,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data?.data() == null) {
            return Center(child: Text('No trip found'));
          }

          final tripData = snapshot.data!.data() as Map<String, dynamic>;

          return SingleChildScrollView(
            child: Container(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    tripData['placesOfVisit'].join(', '),
                    style: GoogleFonts.robotoCondensed(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Departure: ${DateFormat('dd MMM yyyy').format((tripData['departureDate'] as Timestamp).toDate())}',
                    style: TextStyle(fontSize: 18),
                  ),
                  Text(
                    'Return: ${DateFormat('dd MMM yyyy').format((tripData['returnDate'] as Timestamp).toDate())}',
                    style: TextStyle(fontSize: 18),
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Services Offered:',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  ...tripData['servicesOffered']
                      .map((service) => Text(service)),
                  SizedBox(height: 16),
                  Text(
                    'Pickup Locations:',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  ...tripData['pickupLocations']
                      .map((location) => Text(location)),
                  SizedBox(height: 16),
                  Text(
                    'Available Seats: ${tripData['seatsAvailable']}',
                    style: TextStyle(fontSize: 18),
                  ),
                  SizedBox(height: 32),
                  ElevatedButton(
                    onPressed: () {
                      // Navigate to the booking page with the tripId
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              BookingPage(tripId: widget.tripId),
                        ),
                      );
                    },
                    child: Text('Book Now'),
                  ),
                  SizedBox(height: 32),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              ReviewPage(tripId: widget.tripId),
                        ),
                      );
                    },
                    child: Text('Write Review'),
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
