import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:rihla/drawer_widget.dart';
import 'package:file_picker/file_picker.dart';

class UserProfilePage extends StatefulWidget {
  const UserProfilePage({Key? key}) : super(key: key);

  @override
  _UserProfilePageState createState() => _UserProfilePageState();
}

class _UserProfilePageState extends State<UserProfilePage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  var _obscurePassword = true;

  late User user;
  late DocumentSnapshot userProfile;
  bool _isLoading = false;
  String? userPhotoURL;

  @override
  void initState() {
    super.initState();
    user = FirebaseAuth.instance.currentUser!;
    _loadUserProfile();
  }

  void _loadUserProfile() async {
    setState(() => _isLoading = true);
    userProfile = await FirebaseFirestore.instance
        .collection('Users')
        .doc(user.uid)
        .get();
    _nameController.text = userProfile.get('fullName');
    _emailController.text = user.email ?? '';
    setState(() => _isLoading = false);
  }

  Future<void> _updateProfile() async {
    if (_formKey.currentState!.validate()) {
      try {
        setState(() => _isLoading = true);
        await user.updateEmail(_emailController.text);
        await user.updatePassword(_passwordController.text);
        await FirebaseFirestore.instance
            .collection('Users')
            .doc(user.uid)
            .update({
          'fullName': _nameController.text,
          'email': _emailController.text,
        });
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Profile updated successfully')));
      } on FirebaseAuthException catch (e) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Error: ${e.message}')));
      } finally {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _pickImage() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      allowMultiple: false,
    );

    if (result != null) {
      setState(() {
        userPhotoURL = result.files.single.path;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
      ),
      drawer: const AppDrawer(),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    GestureDetector(
                      onTap: _pickImage,
                      child: Stack(
                        children: [
                          Container(
                            width: 120,
                            height: 120,
                            decoration: BoxDecoration(
                              border: Border.all(
                                  color: Colors.blueAccent, width: 2),
                              borderRadius: BorderRadius.circular(100),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(100),
                              child: userPhotoURL != null
                                  ? Image.file(
                                      File(userPhotoURL!),
                                      width: 120,
                                      height: 120,
                                      fit: BoxFit.cover,
                                    )
                                  : Image.asset(
                                      'user.png',
                                      width: 120,
                                      height: 120,
                                      fit: BoxFit.cover,
                                    ),
                            ),
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: Container(
                              width: 35,
                              height: 35,
                              decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.primary,
                                borderRadius: BorderRadius.circular(100),
                              ),
                              child: const Icon(Icons.photo_camera,
                                  color: Colors.white, size: 20),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 50),
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        label: Text('Full Name'),
                        prefixIcon: Icon(Icons.person),
                      ),
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: _emailController,
                      decoration: const InputDecoration(
                        label: Text('Email'),
                        prefixIcon: Icon(Icons.email),
                      ),
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: _passwordController,
                      obscureText: _obscurePassword,
                      decoration: InputDecoration(
                        label: const Text('Password'),
                        prefixIcon: const Icon(Icons.lock_outline),
                        suffixIcon: IconButton(
                          icon: Icon(
                              _obscurePassword
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                              color: Colors.grey),
                          onPressed: () {
                            setState(() {
                              _obscurePassword = !_obscurePassword;
                            });
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),
                    ElevatedButton(
                      onPressed: _updateProfile,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF341359),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 32.0,
                          vertical: 12.0,
                        ),
                      ),
                      child: Text(
                        'Update Profile',
                        style: TextStyle(
                          color: Colors.white,
                          fontFamily: GoogleFonts.poppins().fontFamily,
                          fontSize: 16,
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
