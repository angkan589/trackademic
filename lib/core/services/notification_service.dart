import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class NotificationService {
  const NotificationService();

  FirebaseAuth get _auth => FirebaseAuth.instance;

  FirebaseFirestore get _database => FirebaseFirestore.instance;

  Stream<List<TrackademicNotification>> watchCurrent() {
    final uid = _auth.currentUser?.uid;

    if (uid == null) {
      return Stream.value(const []);
    }

    return _database
        .collection('notifications')
        .doc(uid)
        .collection('items')
        .orderBy('createdAt', descending: true)
        .limit(50)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map(
                (document) => TrackademicNotification.fromMap(
                  document.id,
                  document.data(),
                ),
              )
              .toList(),
        );
  }

  Future<void> markRead(String notificationId) async {
    final uid = _auth.currentUser?.uid;

    if (uid == null) {
      throw const NotificationServiceException('You are not signed in.');
    }

    try {
      await _database
          .collection('notifications')
          .doc(uid)
          .collection('items')
          .doc(notificationId)
          .update({'isRead': true, 'readAt': FieldValue.serverTimestamp()});
    } on FirebaseException catch (error) {
      throw NotificationServiceException(
        error.message ?? 'The notification could not be updated.',
      );
    }
  }

  Future<void> markAllRead() async {
    final uid = _auth.currentUser?.uid;

    if (uid == null) {
      throw const NotificationServiceException('You are not signed in.');
    }

    try {
      final snapshot = await _database
          .collection('notifications')
          .doc(uid)
          .collection('items')
          .where('isRead', isEqualTo: false)
          .limit(100)
          .get();

      if (snapshot.docs.isEmpty) {
        return;
      }

      final batch = _database.batch();

      for (final document in snapshot.docs) {
        batch.update(document.reference, {
          'isRead': true,
          'readAt': FieldValue.serverTimestamp(),
        });
      }

      await batch.commit();
    } on FirebaseException catch (error) {
      throw NotificationServiceException(
        error.message ?? 'Notifications could not be updated.',
      );
    }
  }
}

class TrackademicNotification {
  final String id;
  final String type;
  final String title;
  final String message;
  final String? courseId;
  final bool isRead;
  final DateTime? createdAt;

  const TrackademicNotification({
    required this.id,
    required this.type,
    required this.title,
    required this.message,
    required this.isRead,
    this.courseId,
    this.createdAt,
  });

  factory TrackademicNotification.fromMap(
    String id,
    Map<String, dynamic> data,
  ) {
    final timestamp = data['createdAt'];

    return TrackademicNotification(
      id: id,
      type: data['type'] as String? ?? 'general',
      title: data['title'] as String? ?? 'Trackademic update',
      message: data['message'] as String? ?? '',
      courseId: data['courseId'] as String?,
      isRead: data['isRead'] as bool? ?? false,
      createdAt: timestamp is Timestamp ? timestamp.toDate() : null,
    );
  }
}

class NotificationServiceException implements Exception {
  final String message;

  const NotificationServiceException(this.message);

  @override
  String toString() => message;
}
