import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';

class TeacherAcademicService {
  const TeacherAcademicService();

  FirebaseFirestore get _database => FirebaseFirestore.instance;

  FirebaseFunctions get _functions =>
      FirebaseFunctions.instanceFor(region: 'asia-south1');

  String get _currentTeacherId {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      throw const TeacherAcademicServiceException('You are not signed in.');
    }

    return user.uid;
  }

  Future<List<TeacherCourse>> loadMyCourses() async {
    final teacherId = _currentTeacherId;

    final snapshot = await _database
        .collection('courses')
        .where('teacherId', isEqualTo: teacherId)
        .get();

    final courses = snapshot.docs
        .map((document) => TeacherCourse.fromMap(document.id, document.data()))
        .where((course) => course.isActive)
        .toList();

    courses.sort((first, second) => first.code.compareTo(second.code));

    return courses;
  }

  Future<String> createCourse({
    required String code,
    required String name,
    String? department,
    String? batch,
    String? section,
    String? semester,
    String? room,
  }) async {
    try {
      final callable = _functions.httpsCallable('createCourse');

      final result = await callable.call<Map<String, dynamic>>({
        'code': code,
        'name': name,
        'department': department,
        'batch': batch,
        'section': section,
        'semester': semester,
        'room': room,
      });

      final courseId = result.data['courseId'];

      if (courseId is! String || courseId.isEmpty) {
        throw const TeacherAcademicServiceException(
          'The course was created but its ID was not returned.',
        );
      }

      return courseId;
    } on FirebaseFunctionsException catch (error) {
      throw TeacherAcademicServiceException(
        error.message ?? 'Could not create the course.',
      );
    }
  }

  Future<void> enrollStudent({
    required String courseId,
    required String institutionId,
  }) async {
    try {
      final callable = _functions.httpsCallable('enrollStudent');

      await callable.call<Map<String, dynamic>>({
        'courseId': courseId,
        'institutionId': institutionId,
      });
    } on FirebaseFunctionsException catch (error) {
      throw TeacherAcademicServiceException(
        error.message ?? 'Could not enroll the student.',
      );
    }
  }

  Future<List<EnrolledStudent>> loadCourseStudents(String courseId) async {
    final snapshot = await _database
        .collection('courses')
        .doc(courseId)
        .collection('students')
        .get();

    final students = snapshot.docs
        .map(
          (document) => EnrolledStudent.fromMap(document.id, document.data()),
        )
        .where((student) => student.isActive)
        .toList();

    students.sort(
      (first, second) => first.institutionId.compareTo(second.institutionId),
    );

    return students;
  }
}

class TeacherCourse {
  final String id;
  final String code;
  final String name;
  final String teacherId;
  final String teacherName;
  final String? department;
  final String? batch;
  final String? section;
  final String? semester;
  final String? room;
  final bool isActive;

  const TeacherCourse({
    required this.id,
    required this.code,
    required this.name,
    required this.teacherId,
    required this.teacherName,
    required this.department,
    required this.batch,
    required this.section,
    required this.semester,
    required this.room,
    required this.isActive,
  });

  factory TeacherCourse.fromMap(String id, Map<String, dynamic> data) {
    return TeacherCourse(
      id: id,
      code: data['code'] as String? ?? '',
      name: data['name'] as String? ?? '',
      teacherId: data['teacherId'] as String? ?? '',
      teacherName: data['teacherName'] as String? ?? '',
      department: _nullableText(data['department']),
      batch: _nullableText(data['batch']),
      section: _nullableText(data['section']),
      semester: _nullableText(data['semester']),
      room: _nullableText(data['room']),
      isActive: data['isActive'] as bool? ?? false,
    );
  }

  static String? _nullableText(dynamic value) {
    if (value is! String) {
      return null;
    }

    final text = value.trim();

    return text.isEmpty ? null : text;
  }
}

class EnrolledStudent {
  final String uid;
  final String institutionId;
  final String displayName;
  final String email;
  final bool isActive;

  const EnrolledStudent({
    required this.uid,
    required this.institutionId,
    required this.displayName,
    required this.email,
    required this.isActive,
  });

  factory EnrolledStudent.fromMap(String uid, Map<String, dynamic> data) {
    return EnrolledStudent(
      uid: uid,
      institutionId: data['institutionId'] as String? ?? '',
      displayName: data['displayName'] as String? ?? '',
      email: data['email'] as String? ?? '',
      isActive: data['isActive'] as bool? ?? true,
    );
  }
}

class TeacherAcademicServiceException implements Exception {
  final String message;

  const TeacherAcademicServiceException(this.message);

  @override
  String toString() => message;
}
