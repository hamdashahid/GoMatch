import 'package:firebase_database/firebase_database.dart';

final DatabaseReference usersRef = FirebaseDatabase.instance.ref().child("users");
