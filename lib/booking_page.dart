import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';

class BookingPage extends StatefulWidget {
  final String tripId;

  const BookingPage({Key? key, required this.tripId}) : super(key: key);

  @override
  _BookingPageState createState() => _BookingPageState();
}

class _BookingPageState extends State<BookingPage> {
  final _formKey = GlobalKey<FormState>();
  int _numberOfTravelers = 1;
  List<Map<String, dynamic>> _travelerDetails = [];

  @override
  void initState() {
    super.initState();
    _travelerDetails = List.generate(
        _numberOfTravelers,
        (index) => {
              'fullName': '',
              'phoneNumber': '',
              'gender': 'Male',
              'pickupLocation': ''
            });
  }

  void _submitBooking() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      try {
        final userId = FirebaseAuth.instance.currentUser!.uid;

        await FirebaseFirestore.instance.collection('Bookings').add({
          'userId': userId,
          'tripId': widget.tripId,
          'numberOfTravelers': _numberOfTravelers,
          'travelerDetails': _travelerDetails,
          'bookingDate': DateTime.now(),
        });

        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Booking successful')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Booking failed: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Booking'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: EdgeInsets.all(16),
          children: [
            TextFormField(
              initialValue: _numberOfTravelers.toString(),
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Number of Travelers',
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter the number of travelers';
                }
                return null;
              },
              onSaved: (value) {
                _numberOfTravelers = int.parse(value!);
              },
            ),
            SizedBox(height: 16),
            Text(
              'Traveler Details',
              style: GoogleFonts.robotoCondensed(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            ...List.generate(_numberOfTravelers, (index) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Traveler ${index + 1}',
                    style: GoogleFonts.robotoCondensed(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  TextFormField(
                    decoration: InputDecoration(labelText: 'Full Name'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter the full name';
                      }
                      return null;
                    },
                    onSaved: (value) {
                      _travelerDetails[index]['fullName'] = value;
                    },
                  ),
                  TextFormField(
                    decoration: InputDecoration(labelText: 'Phone Number'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter the phone number';
                      }
                      return null;
                    },
                    onSaved: (value) {
                      _travelerDetails[index]['phoneNumber'] = value;
                    },
                  ),
                  DropdownButtonFormField<String>(
                    value: _travelerDetails[index]['gender'],
                    decoration: InputDecoration(labelText: 'Gender'),
                    items: ['Male', 'Female'].map((gender) {
                      return DropdownMenuItem(
                        value: gender,
                        child: Text(gender),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _travelerDetails[index]['gender'] = value!;
                      });
                    },
                  ),
                  TextFormField(
                    decoration: InputDecoration(labelText: 'Pickup Location'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter the pickup location';
                      }
                      return null;
                    },
                    onSaved: (value) {
                      _travelerDetails[index]['pickupLocation'] = value;
                    },
                  ),
                  SizedBox(height: 16),
                ],
              );
            }),
            ElevatedButton(
              onPressed: _submitBooking,
              child: Text('Submit Booking'),
            ),
          ],
        ),
      ),
    );
  }
}