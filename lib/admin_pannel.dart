import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gomatch/screens/login_screen.dart';
import 'package:gomatch/utils/colors.dart';
import 'package:rxdart/rxdart.dart';

class AdminPanel extends StatefulWidget {
  static const String idScreen = 'adminPanel';
  @override
  _AdminPanelState createState() => _AdminPanelState();
}

class _AdminPanelState extends State<AdminPanel> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Panel'),
        backgroundColor: AppColors.primaryColor,
        elevation: 0,
        titleTextStyle: const TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
        centerTitle: true,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [AppColors.primaryColor, AppColors.secondaryColor],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              // height: 100,
              decoration: BoxDecoration(
                color: AppColors.primaryColor,
              ),
              child: Text(
                'Admin Panel',
                style: TextStyle(
                  color: AppColors.secondaryColor,
                  fontSize: 24,
                ),
              ),
            ),
            ListTile(
              leading: Icon(Icons.logout),
              title: Text('Logout'),
              onTap: () async {
                // Add your logout functionality here
                Navigator.of(context).pop();
                // ScaffoldMessenger.of(context).showSnackBar(
                //   SnackBar(
                //     content: Text('Logged out successfully',
                //         style: TextStyle(color: Colors.white)),
                //     backgroundColor: AppColors.secondaryColor,
                //   ),
                // );
                try {
                  await FirebaseAuth.instance.signOut(); // Firebase sign out
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (context) => LoginScreen()),
                  );

                  // Show SnackBar message after logging out
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('You have been logged out successfully.',
                          style: TextStyle(color: AppColors.primaryColor)),
                      backgroundColor: AppColors.secondaryColor,
                      duration: Duration(seconds: 3),
                    ),
                  );
                } catch (e) {
                  // Handle any errors if logout fails
                  print("Logout failed: $e");
                }
              },
            ),
          ],
        ),
      ),
      body: StreamBuilder<List<QuerySnapshot>>(
        stream: Rx.combineLatest2(
          _firestore.collection('driver_profile').snapshots(),
          _firestore.collection('passenger_profile').snapshots(),
          (QuerySnapshot driverSnapshot, QuerySnapshot passengerSnapshot) =>
              [driverSnapshot, passengerSnapshot],
        ),
        builder: (context, AsyncSnapshot<List<QuerySnapshot>> snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }

          final driverDocs = snapshot.data![0].docs;
          final passengerDocs = snapshot.data![1].docs;

          return ListView(
            padding: const EdgeInsets.all(16.0),
            children: [
              _buildSectionHeader('Drivers'),
              ...driverDocs
                  .map((doc) => _buildUserCard(doc, 'driver_profile'))
                  .toList(),
              const SizedBox(height: 16.0),
              _buildSectionHeader('Passengers'),
              ...passengerDocs
                  .map((doc) => _buildUserCard(doc, 'passenger_profile'))
                  .toList(),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Container(
      alignment: Alignment.center,
      padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
      decoration: BoxDecoration(
        color: AppColors.primaryColor,
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.group, color: AppColors.secondaryColor),
          const SizedBox(width: 8.0),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.secondaryColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserCard(DocumentSnapshot doc, String collectionName) {
    final userData = doc.data() as Map<String, dynamic>?;
    final name = userData?['name'] ?? 'No Name';
    final email = userData?['email'] ?? 'No Email';

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      elevation: 5,
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: AppColors.primaryColor.withOpacity(0.5),
          child: const Icon(Icons.person, color: Colors.white),
        ),
        title: Text(
          name,
          style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
              color: AppColors.secondaryColor),
        ),
        subtitle: Text(
          email,
          style: const TextStyle(
            color: Colors.grey,
            fontSize: 14,
          ),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit, color: Colors.green),
              onPressed: () => _editUser(doc, collectionName),
            ),
            // IconButton(
            //   icon: const Icon(Icons.delete, color: Colors.red),
            //   onPressed: () => _deleteUser(doc.id, collectionName),
            // ),
          ],
        ),
      ),
    );
  }

  void _editUser(DocumentSnapshot doc, String collectionName) {
    TextEditingController nameController =
        TextEditingController(text: doc['name']);
    TextEditingController emailController =
        TextEditingController(text: doc['email']);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Edit User'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Name'),
              ),
              TextField(
                controller: emailController,
                decoration: const InputDecoration(labelText: 'Email'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                _firestore.collection(collectionName).doc(doc.id).update({
                  'name': nameController.text,
                  'email': emailController.text,
                });
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('User updated successfully',
                        style: TextStyle(color: AppColors.primaryColor)),
                    backgroundColor: AppColors.secondaryColor,
                  ),
                );
              },
              child: const Text('Save'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  // void _deleteUser(String userId, String collectionName) async {
  //   try {
  //     // Delete user from Firestore
  //     await _firestore.collection(collectionName).doc(userId).delete();

  //     // Delete user from Firebase Auth
  //     User? user = FirebaseAuth.instance.currentUser;
  //     if (user != null) {
  //       await user.delete();
  //     }

  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(
  //         content: Text('User deleted successfully',
  //             style: TextStyle(color: AppColors.primaryColor)),
  //         backgroundColor: AppColors.secondaryColor,
  //       ),
  //     );
  //   } catch (error) {
  //     print("Failed to delete user: $error");
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(
  //         content: Text('Failed to delete user',
  //             style: TextStyle(color: AppColors.primaryColor)),
  //         backgroundColor: AppColors.secondaryColor,
  //       ),
  //     );
  //   }
  // }
}
