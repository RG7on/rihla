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

  final List<String> _locations = [
    'Ibri',
    'Yanqul',
    'Dhank',
    'Sohar',
    'Shinas',
    'Liwa',
    'Saham',
    'Al Khaburah',
    'As Suwayq',
    'Rustaq',
    'Al Awabi',
    'Nakhal',
    'Wadi Al Maawil',
    'Barka',
    'Al Musanaah',
    'Al Buraimi',
    'Mahdah',
    'Al Sinaina',
    'Haima',
    'Mahout',
    'Duqm',
    'Al Jazir',
    'Ibra',
    'Al Mudaybi',
    'Bidiya',
    'Al Qabil',
    'Wadi Bani Khalid',
    'Dima Wa Al-Taien',
    'Sur',
    'Al Kamil Wal Wafi',
    'Jalan Bani Bu Hassan',
    'Jalan Bani Bu Ali',
    'Masirah',
    'Salalah',
    'Taqah',
    'Mirbat',
    'Rakhyut',
    'Thumrait',
    'Shalim and the Hallaniyat Islands',
    'Al Mazyona',
    'Dhalkut',
    'Al Muqshin',
    'Sadah',
    'Khasab',
    'Bukha',
    'Daba Al Bayah',
    'Madha',
    'Muscat',
    'Muttrah',
    'Baushar',
    'As Seeb',
    'Al Amrat',
    'Qurayyat'
  ];

  @override
  void initState() {
    super.initState();
    _generateTravelerDetails();
  }

  void _generateTravelerDetails() {
    _travelerDetails = List.generate(
      _numberOfTravelers,
      (index) => {
        'fullName': '',
        'phoneNumber': '',
        'gender': 'Male',
        'pickupLocation': _locations.first // Default to the first location
      },
    );
  }

  void _updateNumberOfTravelers(String value) {
    final int numberOfTravelers = int.tryParse(value) ?? 1;
    setState(() {
      _numberOfTravelers = numberOfTravelers;
      _generateTravelerDetails();
    });
  }

  void _submitBooking() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      try {
        final userId = FirebaseAuth.instance.currentUser!.uid;

        // Get the current trip document
        DocumentSnapshot tripSnapshot = await FirebaseFirestore.instance
            .collection('Trips')
            .doc(widget.tripId)
            .get();

        if (tripSnapshot.exists) {
          // Get the current seats available
          int seatsAvailable = tripSnapshot['seatsAvailable'];

          if (seatsAvailable >= _numberOfTravelers) {
            // Subtract the number of travelers from seats available
            seatsAvailable -= _numberOfTravelers;

            // Create a Firestore batch to perform atomic writes
            WriteBatch batch = FirebaseFirestore.instance.batch();

            // Add booking document
            DocumentReference bookingRef =
                FirebaseFirestore.instance.collection('Bookings').doc();
            batch.set(bookingRef, {
              'userId': userId,
              'tripId': widget.tripId,
              'numberOfTravelers': _numberOfTravelers,
              'travelerDetails': _travelerDetails,
              'bookingDate': DateTime.now(),
            });

            // Update seats available in the trip document
            DocumentReference tripRef = FirebaseFirestore.instance
                .collection('Trips')
                .doc(widget.tripId);
            batch.update(tripRef, {'seatsAvailable': seatsAvailable});

            // Commit the batch
            await batch.commit();

            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Booking successful')),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Not enough seats available')),
            );
          }
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Trip not found')),
          );
        }
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
        title: Text(
          'Booking',
          style: TextStyle(
            color: Colors.white,
            fontFamily: GoogleFonts.poppins().fontFamily,
          ),
        ),
        backgroundColor: Color(0xFF341359),
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: ListView(
            children: [
              Text(
                'Number of Travelers',
                style: TextStyle(
                  fontSize: 18,
                  fontFamily: GoogleFonts.poppins().fontFamily,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 8.0),
              TextFormField(
                initialValue: _numberOfTravelers.toString(),
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  hintText: 'Enter number of travelers',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                    borderSide: BorderSide(color: Color(0xFF341359)),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the number of travelers';
                  }
                  return null;
                },
                onChanged: _updateNumberOfTravelers,
                onSaved: (value) {
                  _numberOfTravelers = int.parse(value!);
                },
              ),
              SizedBox(height: 24.0),
              Text(
                'Traveler Details',
                style: TextStyle(
                  fontSize: 20,
                  fontFamily: GoogleFonts.poppins().fontFamily,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 16.0),
              ...List.generate(_numberOfTravelers, (index) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Traveler ${index + 1}',
                      style: TextStyle(
                        fontSize: 18,
                        fontFamily: GoogleFonts.poppins().fontFamily,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8.0),
                    TextFormField(
                      decoration: InputDecoration(
                        hintText: 'Full Name',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                          borderSide: BorderSide(color: Color(0xFF341359)),
                        ),
                      ),
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
                    SizedBox(height: 8.0),
                    TextFormField(
                      decoration: InputDecoration(
                        hintText: 'Phone Number',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                          borderSide: BorderSide(color: Color(0xFF341359)),
                        ),
                      ),
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
                    SizedBox(height: 8.0),
                    DropdownButtonFormField<String>(
                      value: _travelerDetails[index]['gender'],
                      decoration: InputDecoration(
                        hintText: 'Gender',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                          borderSide: BorderSide(color: Color(0xFF341359)),
                        ),
                      ),
                      items: ['Male', 'Female']
                          .map((gender) => DropdownMenuItem(
                                value: gender,
                                child: Text(gender),
                              ))
                          .toList(),
                      onChanged: (value) {
                        setState(() {
                          _travelerDetails[index]['gender'] = value!;
                        });
                      },
                      onSaved: (value) {
                        _travelerDetails[index]['gender'] = value!;
                      },
                    ),
                    SizedBox(height: 8.0),
                    DropdownButtonFormField<String>(
                      value: _travelerDetails[index]['pickupLocation'],
                      decoration: InputDecoration(
                        hintText: 'Pickup Location',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                          borderSide: BorderSide(color: Color(0xFF341359)),
                        ),
                      ),
                      items: _locations
                          .map((location) => DropdownMenuItem(
                                value: location,
                                child: Text(location),
                              ))
                          .toList(),
                      onChanged: (value) {
                        setState(() {
                          _travelerDetails[index]['pickupLocation'] = value!;
                        });
                      },
                      onSaved: (value) {
                        _travelerDetails[index]['pickupLocation'] = value!;
                      },
                    ),
                    SizedBox(height: 16.0),
                  ],
                );
              }),
              SizedBox(height: 24.0),
              Center(
                child: ElevatedButton(
                  onPressed: _submitBooking,
                  child: Text(
                    'Submit Booking',
                    style: TextStyle(
                      color: Colors.white,
                      fontFamily: GoogleFonts.poppins().fontFamily,
                      fontSize: 16,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF341359),
                    padding: EdgeInsets.symmetric(
                      horizontal: 32.0,
                      vertical: 12.0,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
