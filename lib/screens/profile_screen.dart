import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:gomatch/utils/colors.dart';

class ProfileScreen extends StatefulWidget {
  static const String idScreen = "profile";

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  User? user;
  final TextEditingController nameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController emailController = TextEditingController();

  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    user = _auth.currentUser;
    if (user != null) {
      fetchUserData();
    } else {
      // Navigate to login if user is not logged in
      Navigator.pushReplacementNamed(context, 'loginScreen');
    }
  }

  Future<void> fetchUserData() async {
    try {
      DocumentSnapshot userDoc = await _firestore.collection('Profile').doc(user?.uid).get();
      if (userDoc.exists) {
        setState(() {
          nameController.text = userDoc['Name'] ?? '';
          phoneController.text = userDoc['Phone'] ?? '';
          emailController.text = userDoc['Email'] ?? user?.email ?? '';
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error fetching user data: $e")),
      );
    }
  }

  Future<void> saveProfileData() async {
    if (user == null) return;

    setState(() {
      isLoading = true;
    });

    try {
      DocumentSnapshot userDoc = await _firestore.collection('Profile').doc(user!.uid).get();
      if (userDoc.exists) {
        String savedEmail = userDoc['Email'] ?? '';
        if (savedEmail == emailController.text) {
          await _firestore.collection('Profile').doc(user!.uid).set({
            'Name': nameController.text,
            'Phone': phoneController.text,
            'Email': emailController.text,
          }, SetOptions(merge: true)); // Only update specified fields

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Profile updated successfully!")),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Email does not match the saved data.")),
          );
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to update profile: $e")),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Edit Profile"),
        backgroundColor: AppColors.primaryColor,
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  TextFormField(
                    controller: nameController,
                    decoration: InputDecoration(labelText: "Name"),
                  ),
                  SizedBox(height: 16),
                  TextFormField(
                    controller: phoneController,
                    decoration: InputDecoration(labelText: "Phone Number"),
                    keyboardType: TextInputType.phone,
                  ),
                  SizedBox(height: 16),
                  TextFormField(
                    controller: emailController,
                    decoration: InputDecoration(labelText: "Email"),
                    keyboardType: TextInputType.emailAddress,
                  ),
                  SizedBox(height: 32),
                  ElevatedButton(
                    onPressed: saveProfileData,
                    child: Text("Save Changes"),
                  ),
                ],
              ),
            ),
    );
  }

  @override
  void dispose() {
    // Dispose controllers to free resources
    nameController.dispose();
    phoneController.dispose();
    emailController.dispose();
    super.dispose();
  }
}
