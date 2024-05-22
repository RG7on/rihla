import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class Reservation extends StatefulWidget {
  const Reservation({super.key});

  @override
  State<Reservation> createState() => _ReservationState();
}

class _ReservationState extends State<Reservation> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final User? _user = FirebaseAuth.instance.currentUser;

  Stream<List<Map<String, dynamic>>> _getReservations() async* {
    var bookingsSnapshot = await _firestore
        .collection('Bookings')
        .where('userId', isEqualTo: _user?.uid)
        .get();
    List<Map<String, dynamic>> reservations = [];

    for (var booking in bookingsSnapshot.docs) {
      var tripSnapshot =
          await _firestore.collection('Trips').doc(booking['tripId']).get();
      var agencySnapshot = await _firestore
          .collection('Agencies')
          .doc(tripSnapshot['agencyId'])
          .get();

      reservations.add({
        'bookingDetails': booking.data(),
        'tripDetails': tripSnapshot.data(),
        'agencyDetails': agencySnapshot.data(),
      });
    }

    yield reservations;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Reservations'),
      ),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: _getReservations(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No reservations found.'));
          }
          return ListView.builder(
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              var booking = snapshot.data![index]['bookingDetails'];
              var trip = snapshot.data![index]['tripDetails'];
              var agency = snapshot.data![index]['agencyDetails'];
              String title =
                  '${agency['name']} - ${trip['departureDate'].toDate()}';

              return ExpansionTile(
                title: Text(title),
                subtitle: Text('Travelers: ${booking['numberOfTravelers']}'),
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Return Date: ${trip['returnDate'].toDate()}'),
                        Text(
                            'Services Offered: ${trip['servicesOffered'].join(", ")}'),
                        Text(
                            'Places of Visit: ${trip['placesOfVisit'].join(", ")}'),
                        SizedBox(height: 10),
                        Text('Traveler Details:',
                            style: Theme.of(context).textTheme.titleMedium),
                        ...booking['travelerDetails'].map<Widget>((traveler) {
                          return ListTile(
                            title: Text(traveler['fullName']),
                            subtitle:
                                Text('Pickup: ${traveler['pickupLocation']}'),
                          );
                        }).toList(),
                      ],
                    ),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}
