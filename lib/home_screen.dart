import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:rihla/drawer_widget.dart';
import 'package:rihla/explore_trips_screen.dart';
import 'package:rihla/trip_details.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  TextEditingController locationController = TextEditingController();
  TextEditingController travelersController = TextEditingController();
  TextEditingController dateController = TextEditingController();

  bool visitMakkah = false;
  bool visitMadina = false;
  DateTime? departureDate;

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: departureDate ?? DateTime.now(),
        firstDate: DateTime(2000),
        lastDate: DateTime(2101));
    if (picked != null && picked != departureDate) {
      setState(() {
        departureDate = picked;
        dateController.text = DateFormat('dd/MM/yyyy').format(picked);
      });
    }
  }

  void _searchTrips() async {
    if (locationController.text.isEmpty ||
        dateController.text.isEmpty ||
        travelersController.text.isEmpty) {
      _showDialog('Error', 'Please fill in all fields to continue.');
      return;
    }

    String destinations = '';
    if (visitMakkah) destinations += 'Makkah ';
    if (visitMadina) destinations += 'AlMadina';

    try {
      final QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('Trips')
          .where('placesOfVisit', arrayContainsAny: destinations.split(' '))
          .where('departureDate', isGreaterThanOrEqualTo: departureDate)
          .where('seatsAvailable',
              isGreaterThanOrEqualTo: int.parse(travelersController.text))
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        // Navigate to the TripDetailsPage with the first matching trip
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                TripDetailsPage(tripId: querySnapshot.docs.first.id),
          ),
        );
      } else {
        _showDialog('No Trips Found', 'No trips match your search criteria.');
      }
    } catch (e) {
      print('Error searching for trips: $e');
      _showDialog('Error',
          'An error occurred while searching for trips. Please try again later.');
    }
  }

  void _exploreTrips() async {
    try {
      final QuerySnapshot querySnapshot =
          await FirebaseFirestore.instance.collection('Trips').get();

      if (querySnapshot.docs.isNotEmpty) {
        // Navigate to a new screen that displays all the available trips
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ExploreTripsScreen(trips: querySnapshot.docs),
          ),
        );
      } else {
        _showDialog('No Trips Found', 'No trips are currently available.');
      }
    } catch (e) {
      print('Error exploring trips: $e');
      _showDialog('Error',
          'An error occurred while exploring trips. Please try again later.');
    }
  }

  void _showDialog(String title, String content) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(content),
          actions: <Widget>[
            TextButton(
              child: Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Serch"),
      ),
      drawer: const AppDrawer(),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF5D427A),
              Color(0xFF341359),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 19),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(height: 20),
                Text(
                  'Plan Your Journey',
                  style: GoogleFonts.robotoCondensed(
                    fontSize: 45,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 20),
                Expanded(
                  child: Center(
                    child: Container(
                      padding: EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: SingleChildScrollView(
                        child: Column(
                          children: [
                            _buildTextField(
                                locationController,
                                'Place collecting passengers',
                                Icons.location_on),
                            SizedBox(height: 16),
                            _buildDateField(),
                            SizedBox(height: 16),
                            _buildTextField(
                                travelersController, 'Travelers', Icons.person),
                            SizedBox(height: 16),
                            Row(
                              children: [
                                Expanded(
                                  child: Padding(
                                    padding: EdgeInsets.only(right: 4),
                                    child: _buildCheckbox('Makkah', visitMakkah,
                                        (bool? value) {
                                      setState(() {
                                        visitMakkah = value ?? false;
                                      });
                                    }),
                                  ),
                                ),
                                Expanded(
                                  child: Padding(
                                    padding: EdgeInsets.only(left: 4),
                                    child: _buildCheckbox(
                                        'AlMadina', visitMadina, (bool? value) {
                                      setState(() {
                                        visitMadina = value ?? false;
                                      });
                                    }),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 24),
                            ElevatedButton(
                              onPressed: _searchTrips,
                              child: Text(
                                'Search',
                                style: GoogleFonts.robotoCondensed(
                                  fontSize: 20,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Color(0xFF5D427A),
                                minimumSize: Size(double.infinity, 55),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30),
                                ),
                              ),
                            ),
                            SizedBox(height: 16),
                            OutlinedButton(
                              onPressed: () {
                                _exploreTrips();
                              }, // Define what happens when 'Explore' is tapped
                              child: Text(
                                'Explore',
                                style: GoogleFonts.robotoCondensed(
                                  fontSize: 20,
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              style: OutlinedButton.styleFrom(
                                side: BorderSide(color: Colors.black, width: 2),
                                minimumSize: Size(double.infinity, 55),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
      TextEditingController controller, String label, IconData icon) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.white,
        labelText: label,
        labelStyle: TextStyle(color: Colors.grey),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide(color: Colors.black54, width: 1),
        ),
        prefixIcon: Icon(icon, color: Color(0xFF5D427A)),
      ),
    );
  }

  Widget _buildDateField() {
    return TextField(
      controller: dateController,
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.white,
        labelText: 'Departure',
        labelStyle: TextStyle(color: Colors.grey),
        hintText: 'Select date',
        hintStyle: TextStyle(color: Colors.grey),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide(color: Colors.black54, width: 1),
        ),
        prefixIcon: Icon(Icons.calendar_today, color: Color(0xFF5D427A)),
      ),
      readOnly: true,
      onTap: () => _selectDate(context),
    );
  }

  Widget _buildCheckbox(String title, bool value, Function(bool?) onChanged) {
    return Expanded(
      child: CheckboxListTile(
        title: Text(title, style: TextStyle(color: Colors.black)),
        value: value,
        onChanged: onChanged,
        controlAffinity: ListTileControlAffinity.leading,
        checkColor: Color(0xFF5D427A),
        activeColor: Colors.white,
      ),
    );
  }

  Widget _buildSearchButton() {
    return ElevatedButton(
      onPressed: () {},
      child: Text(
        'Search',
        style: GoogleFonts.robotoCondensed(
          fontSize: 20,
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: Color(0xFF5D427A),
        minimumSize: Size(double.infinity, 55),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
      ),
    );
  }

  Widget _buildExploreButton() {
    return OutlinedButton(
      onPressed: () {}, // Define what happens when 'Explore' is tapped
      child: Text(
        'Explore',
        style: GoogleFonts.robotoCondensed(
          fontSize: 20,
          color: Colors.black,
          fontWeight: FontWeight.bold,
        ),
      ),
      style: OutlinedButton.styleFrom(
        side: BorderSide(color: Colors.black, width: 2),
        minimumSize: Size(double.infinity, 55),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
      ),
    );
  }
}
