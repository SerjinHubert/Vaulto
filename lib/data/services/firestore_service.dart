import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/transaction_model.dart';
import '../models/subscription_model.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final String uid;

  FirestoreService(this.uid);

  // Users
  Stream<Map<String, dynamic>?> streamUserProfile() {
    return _db.collection('users').doc(uid).snapshots().map((snapshot) {
      if (snapshot.exists) {
        return snapshot.data();
      }
      return null;
    });
  }

  Future<void> updateUserProfile(String firstName, String lastName, String email) async {
    await _db.collection('users').doc(uid).set({
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
    }, SetOptions(merge: true));
  }

  Future<void> updateProfileImage(String base64Image) async {
    await _db.collection('users').doc(uid).set({
      'profileImageBase64': base64Image,
    }, SetOptions(merge: true));
  }

  Stream<List<Map<String, dynamic>>> streamAllUsers() {
    return _db.collection('users').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['uid'] = doc.id;
        return data;
      }).toList();
    });
  }

  // Transactions
  Stream<List<TransactionModel>> streamTransactions() {
    return _db
        .collection('users').doc(uid).collection('transactions')
        .orderBy('date', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => TransactionModel.fromJson(doc.data()))
            .toList());
  }

  Future<void> addTransaction(TransactionModel transaction) async {
    await _db.collection('users').doc(uid).collection('transactions').doc(transaction.id).set(transaction.toJson());
  }

  Future<void> deleteTransaction(String id) async {
    await _db.collection('users').doc(uid).collection('transactions').doc(id).delete();
  }

  // Subscriptions
  Stream<List<SubscriptionModel>> streamSubscriptions() {
    return _db
        .collection('users').doc(uid).collection('subscriptions')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => SubscriptionModel.fromJson(doc.data()))
            .toList());
  }

  Future<void> addSubscription(SubscriptionModel sub) async {
    await _db.collection('users').doc(uid).collection('subscriptions').doc(sub.id).set(sub.toJson());
  }

  Future<void> deleteSubscription(String id) async {
    await _db.collection('users').doc(uid).collection('subscriptions').doc(id).delete();
  }

  Future<void> updateSubscription(SubscriptionModel sub) async {
    await _db.collection('users').doc(uid).collection('subscriptions').doc(sub.id).update(sub.toJson());
  }

  // User Settings
  Stream<double> streamBudget() {
    return _db.collection('users').doc(uid).collection('settings').doc('userSettings').snapshots().map((snapshot) {
      if (snapshot.exists && snapshot.data() != null) {
        return (snapshot.data()!['monthlyBudget'] ?? 120000).toDouble();
      }
      return 120000.0;
    });
  }

  Future<void> updateBudget(double budget) async {
    await _db.collection('users').doc(uid).collection('settings').doc('userSettings').set(
      {'monthlyBudget': budget},
      SetOptions(merge: true),
    );
  }
}
