import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:gomatch/utils/colors.dart';

class DriverProfileScreen extends StatefulWidget {
  static const String idScreen = "driver_profile";

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<DriverProfileScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  User? user;
  final TextEditingController nameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  // final TextEditingController emailController = TextEditingController();

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
      DocumentSnapshot userDoc =
          await _firestore.collection('driver_profile').doc(user?.uid).get();
      if (userDoc.exists) {
        setState(() {
          nameController.text = userDoc['name'] ?? '';
          phoneController.text = userDoc['phone'] ?? '';
          // emailController.text = userDoc['email'] ?? user?.email ?? '';
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error fetching user data: $e")),
      );
    }
  }

  Future<void> saveProfileData() async {
    setState(() {
      isLoading = true;
    });

    try {
      await _firestore.collection('driver_profile').doc(user?.uid).update({
        'name': nameController.text,
        'phone': phoneController.text,
        // 'email': emailController.text,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Profile updated successfully")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error updating profile: $e")),
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
                  // TextFormField(
                  //   controller: emailController,
                  //   decoration: InputDecoration(labelText: "Email"),
                  //   keyboardType: TextInputType.emailAddress,
                  // ),
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
    // emailController.dispose();
    super.dispose();
  }
}
