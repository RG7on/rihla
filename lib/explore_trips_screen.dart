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
        title: Text('Explore Trips'),
      ),
      body: ListView.builder(
        itemCount: trips.length,
        itemBuilder: (context, index) {
          final tripData = trips[index].data() as Map<String, dynamic>;
          final tripId = trips[index].id;

          return ListTile(
            title: Text(tripData['placesOfVisit'].join(', ')),
            subtitle: Text('Departure: ${tripData['departureDate'].toDate()}'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => TripDetailsPage(tripId: tripId),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
