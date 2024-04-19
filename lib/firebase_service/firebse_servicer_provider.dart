import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class FirebaseProvider extends ChangeNotifier {
  List _data = [];
  List get data => _data;

  final FirebaseFirestore _fireStore = FirebaseFirestore.instance;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  Future<void> fetchFirebaseData() async {
    try {
      _isLoading = true;
      QuerySnapshot querySnapshot =
          await _fireStore.collection('product_id').get();
      _data = querySnapshot.docs.map((doc) => doc.data()).toList();
      _isLoading = false;
      notifyListeners();

      log('Firebase Data  : $data');
    } catch (e) {
      _isLoading = false;
      notifyListeners();
    }
  }
}
