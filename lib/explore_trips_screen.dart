import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rihla/trip_details.dart';

class ExploreTripsScreen extends StatelessWidget {
  final List<QueryDocumentSnapshot> trips;

  const ExploreTripsScreen({Key? key, required this.trips}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Explore Trips',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Color(0xFF341359),
        iconTheme: IconThemeData(color: Colors.white), // Set arrow color here
      ),
      body: ListView.builder(
        itemCount: trips.length,
        itemBuilder: (context, index) {
          final tripData = trips[index].data() as Map<String, dynamic>;
          final tripId = trips[index].id;
          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => TripDetailsPage(tripId: tripId),
                ),
              );
            },
            child: Card(
              elevation: 3,
              margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      tripData['placesOfVisit'].join(', '),
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF341359),
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Departure: ${tripData['departureDate'].toDate()}',
                      style: TextStyle(
                        fontSize: 14,
                        color: Color(0xFF341359),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
