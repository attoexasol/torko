import 'package:cloud_firestore/cloud_firestore.dart';

/// Firestore user document: users/{firebase_uid}
class FirestoreUser {
  final String uid;
  final String? fullname;
  final String phone;
  final String? profileImage;
  final bool isOnline;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const FirestoreUser({
    required this.uid,
    this.fullname,
    required this.phone,
    this.profileImage,
    this.isOnline = false,
    this.createdAt,
    this.updatedAt,
  });

  factory FirestoreUser.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data() ?? {};
    Timestamp? tsCreated = d['createdAt'];
    Timestamp? tsUpdated = d['updatedAt'];
    return FirestoreUser(
      uid: doc.id,
      fullname: d['fullname']?.toString(),
      phone: d['phone']?.toString() ?? '',
      profileImage: d['profileImage']?.toString(),
      isOnline: d['isOnline'] == true,
      createdAt: tsCreated?.toDate(),
      updatedAt: tsUpdated?.toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'fullname': fullname,
      'phone': phone,
      'profileImage': profileImage,
      'isOnline': isOnline,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }
}
