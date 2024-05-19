import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  TextEditingController locationController = TextEditingController();
  TextEditingController travelersController = TextEditingController();
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
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
            padding: EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Plan Your Journey',
                  style: GoogleFonts.robotoCondensed(
                    fontSize: 45,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 24),
                TextField(
                  controller: locationController,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.white.withOpacity(0.8),
                    labelText: 'Place collecting passengers',
                    labelStyle: TextStyle(color: Colors.grey),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: BorderSide.none,
                    ),
                    prefixIcon:
                        Icon(Icons.location_on, color: Color(0xFF5D427A)),
                  ),
                ),
                SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => _selectDate(context),
                        child: AbsorbPointer(
                          child: TextField(
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: Colors.white.withOpacity(0.8),
                              labelText: 'Departure',
                              labelStyle: TextStyle(color: Colors.grey),
                              hintText: (departureDate == null)
                                  ? 'Select date'
                                  : DateFormat('dd/MM/yyyy')
                                      .format(departureDate!),
                              hintStyle: TextStyle(color: Colors.grey),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(30),
                                borderSide: BorderSide.none,
                              ),
                              prefixIcon: Icon(Icons.calendar_today,
                                  color: Color(0xFF5D427A)),
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      child: TextField(
                        controller: travelersController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.white.withOpacity(0.8),
                          labelText: 'Travelers',
                          labelStyle: TextStyle(color: Colors.grey),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30),
                            borderSide: BorderSide.none,
                          ),
                          prefixIcon:
                              Icon(Icons.person, color: Color(0xFF5D427A)),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 24),
                Text(
                  'Destinations',
                  style: GoogleFonts.robotoCondensed(
                    fontSize: 24,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 16),
                CheckboxListTile(
                  title: Text(
                    'Makkah',
                    style: TextStyle(color: Colors.white),
                  ),
                  value: visitMakkah,
                  onChanged: (bool? value) {
                    setState(() {
                      visitMakkah = value ?? false;
                    });
                  },
                  controlAffinity: ListTileControlAffinity.leading,
                  checkColor: Color(0xFF5D427A),
                  activeColor: Colors.white,
                ),
                CheckboxListTile(
                  title: Text(
                    'AlMadina',
                    style: TextStyle(color: Colors.white),
                  ),
                  value: visitMadina,
                  onChanged: (bool? value) {
                    setState(() {
                      visitMadina = value ?? false;
                    });
                  },
                  controlAffinity: ListTileControlAffinity.leading,
                  checkColor: Color(0xFF5D427A),
                  activeColor: Colors.white,
                ),
                SizedBox(height: 32),
                ElevatedButton(
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
                ),
                SizedBox(height: 16),
                OutlinedButton(
                  onPressed: () {},
                  child: Text(
                    'Explore',
                    style: GoogleFonts.robotoCondensed(
                      fontSize: 20,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: Colors.white, width: 2),
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
    );
  }
}
