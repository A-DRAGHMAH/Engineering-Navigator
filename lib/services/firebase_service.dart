import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:io';

class FirebaseService {
  static final FirebaseFirestore _db = FirebaseFirestore.instance;
  static final _storage = FirebaseStorage.instance;

  // Get a stream of collection data
  static Stream<QuerySnapshot> getDataStream(String collection) {
    return _db.collection(collection).snapshots();
  }

  // Get a single document
  static Future<Map<String, dynamic>?> getDocument(String collection, String documentId) async {
    final doc = await _db.collection(collection).doc(documentId).get();
    return doc.data();
  }

  // Save data to Firestore
  static Future<void> saveData(String collection, String? documentId, Map<String, dynamic> data) async {
    if (documentId != null) {
      await _db.collection(collection).doc(documentId).set(data);
    } else {
      await _db.collection(collection).add(data);
    }
  }

  // Delete data from Firestore
  static Future<void> deleteData(String collection, String documentId) async {
    await _db.collection(collection).doc(documentId).delete();
  }

  // Upload file to Storage
  static Future<String> uploadFile(String path, File file) async {
    final ref = _storage.ref().child(path);
    await ref.putFile(file);
    return await ref.getDownloadURL();
  }

  // Delete file from Storage
  static Future<void> deleteFile(String path) async {
    await _storage.ref().child(path).delete();
  }

  // Notifications
  static Future<void> sendNotification({
    required String message,
    required String priority,
  }) async {
    await _db.collection('notifications').add({
      'message': message,
      'priority': priority,
      'timestamp': FieldValue.serverTimestamp(),
      'isRead': false,
    });
  }

  // Events
  static Future<void> addEvent(Map<String, dynamic> eventData) async {
    await _db.collection('events').add({
      ...eventData,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  // Links
  static Future<void> addLink(Map<String, dynamic> linkData) async {
    await _db.collection('links').add({
      ...linkData,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  // Get real-time streams
  static Stream<QuerySnapshot> getNotificationsStream() {
    return _db
        .collection('notifications')
        .orderBy('timestamp', descending: true)
        .snapshots();
  }

  static Stream<QuerySnapshot> getEventsStream() {
    return _db.collection('events').orderBy('timestamp').snapshots();
  }

  static Stream<QuerySnapshot> getLinksStream(String type) {
    return _db
        .collection('links')
        .where('type', isEqualTo: type)
        .orderBy('timestamp', descending: true)
        .snapshots();
  }

  // Settings
  static Future<void> updateSettings(String setting, dynamic value) async {
    await _db.collection('settings').doc('app_settings').set({
      setting: value,
    }, SetOptions(merge: true));
  }

  static Stream<DocumentSnapshot> getSettingsStream() {
    return _db.collection('settings').doc('app_settings').snapshots();
  }

  // Chatbot
  static Future<void> saveChatHistory(String message, bool isUser) async {
    await _db.collection('chat_history').add({
      'message': message,
      'isUser': isUser,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }
} 