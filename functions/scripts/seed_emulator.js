const { initializeApp } = require("firebase-admin/app");
const { getAuth } = require("firebase-admin/auth");
const {
  FieldValue,
  Timestamp,
  getFirestore,
} = require("firebase-admin/firestore");

const PROJECT_ID = "trackademic-0";

initializeApp({
  projectId: PROJECT_ID,
});

const auth = getAuth();
const db = getFirestore();

async function getOrCreateUser({
  email,
  password,
  displayName,
  institutionId,
  role,
}) {
  let user;

  try {
    user = await auth.getUserByEmail(email);
  } catch (error) {
    if (error.code !== "auth/user-not-found") {
      throw error;
    }

    user = await auth.createUser({
      email,
      password,
      displayName,
      emailVerified: true,
    });
  }

  await auth.updateUser(user.uid, {
    displayName,
    emailVerified: true,
  });

  await auth.setCustomUserClaims(user.uid, {
    role,
    institutionId,
  });

  return user;
}

async function main() {
  console.log("Seeding Trackademic emulator...");

  const student = await getOrCreateUser({
    email: "aaa@gmail.com",
    password: "12345678",
    displayName: "Angkan",
    institutionId: "2204010",
    role: "student",
  });

  const teacher = await getOrCreateUser({
    email: "teacher@trackademic.test",
    password: "12345678",
    displayName: "Dr. Kaushik Deb",
    institutionId: "T-CSE-001",
    role: "teacher",
  });

  const timestamp = FieldValue.serverTimestamp();

  const courseIds = [
    "cse315-2026",
    "cse321-2026",
    "cse333-2026",
  ];

  await db.collection("users").doc(student.uid).set(
    {
      uid: student.uid,
      displayName: "Angkan",
      email: "aaa@gmail.com",
      institutionId: "2204010",
      role: "student",
      isActive: true,
      emailVerified: true,
      phone: null,
      photoUrl: null,
      department: "Computer Science and Engineering",
      batch: "22 Batch",
      section: "Section A",
      semester: "Level 3 - Term 2",
      courseIds,
      notificationPreferences: {
        attendance: true,
        marks: true,
        schedule: true,
      },
      updatedAt: timestamp,
    },
    { merge: true },
  );

  await db.collection("users").doc(teacher.uid).set(
    {
      uid: teacher.uid,
      displayName: "Dr. Kaushik Deb",
      email: "teacher@trackademic.test",
      institutionId: "T-CSE-001",
      role: "teacher",
      isActive: true,
      emailVerified: true,
      phone: null,
      photoUrl: null,
      department: "Computer Science and Engineering",
      batch: null,
      section: null,
      semester: "Level 3 - Term 2",
      courseIds,
      notificationPreferences: {
        attendance: true,
        marks: true,
        schedule: true,
      },
      updatedAt: timestamp,
    },
    { merge: true },
  );

  const courses = [
    {
      id: "cse315-2026",
      code: "CSE 315",
      name: "Software Engineering",
      room: "Room 204",
    },
    {
      id: "cse321-2026",
      code: "CSE 321",
      name: "Computer Architecture",
      room: "Room 302",
    },
    {
      id: "cse333-2026",
      code: "CSE 333",
      name: "Computer Networks",
      room: "Network Lab",
    },
  ];

  for (const course of courses) {
    await db.collection("courses").doc(course.id).set({
      code: course.code,
      name: course.name,
      teacherId: teacher.uid,
      teacherName: "Dr. Kaushik Deb",
      department: "Computer Science and Engineering",
      batch: "22 Batch",
      section: "Section A",
      semester: "Level 3 - Term 2",
      room: course.room,
      isActive: true,
      createdAt: timestamp,
      updatedAt: timestamp,
    });

    await db
      .collection("courses")
      .doc(course.id)
      .collection("students")
      .doc(student.uid)
      .set({
        studentId: student.uid,
        institutionId: "2204010",
        displayName: "Angkan",
        enrolledAt: timestamp,
        isActive: true,
      });
  }

  const attendance = [
    {
      courseId: "cse315-2026",
      courseCode: "CSE 315",
      courseName: "Software Engineering",
      attended: 16,
      total: 17,
      attendanceMarks: 9.4,
    },
    {
      courseId: "cse321-2026",
      courseCode: "CSE 321",
      courseName: "Computer Architecture",
      attended: 14,
      total: 16,
      attendanceMarks: 8.8,
    },
    {
      courseId: "cse333-2026",
      courseCode: "CSE 333",
      courseName: "Computer Networks",
      attended: 13,
      total: 16,
      attendanceMarks: 8.1,
    },
  ];

  for (const item of attendance) {
    const percentage =
      item.total === 0 ? 0 : (item.attended / item.total) * 100;

    await db
      .collection("attendanceSummaries")
      .doc(`${item.courseId}_${student.uid}`)
      .set({
        ...item,
        studentId: student.uid,
        percentage,
        updatedAt: timestamp,
      });
  }

  const assessments = [
    {
      id: "cse315-ct1",
      courseId: "cse315-2026",
      courseCode: "CSE 315",
      courseName: "Software Engineering",
      name: "CT 1",
      score: 17,
      maxScore: 20,
    },
    {
      id: "cse315-ct2",
      courseId: "cse315-2026",
      courseCode: "CSE 315",
      courseName: "Software Engineering",
      name: "CT 2",
      score: 18,
      maxScore: 20,
    },
    {
      id: "cse321-ct1",
      courseId: "cse321-2026",
      courseCode: "CSE 321",
      courseName: "Computer Architecture",
      name: "CT 1",
      score: 16,
      maxScore: 20,
    },
    {
      id: "cse333-ct1",
      courseId: "cse333-2026",
      courseCode: "CSE 333",
      courseName: "Computer Networks",
      name: "CT 1",
      score: 15,
      maxScore: 20,
    },
  ];

  for (const item of assessments) {
    await db.collection("assessments").doc(item.id).set({
      courseId: item.courseId,
      courseCode: item.courseCode,
      courseName: item.courseName,
      name: item.name,
      maxScore: item.maxScore,
      status: "published",
      createdBy: teacher.uid,
      createdAt: timestamp,
      updatedAt: timestamp,
    });

    await db
      .collection("marks")
      .doc(`${item.id}_${student.uid}`)
      .set({
        courseId: item.courseId,
        courseCode: item.courseCode,
        courseName: item.courseName,
        assessmentId: item.id,
        assessmentName: item.name,
        studentId: student.uid,
        score: item.score,
        maxScore: item.maxScore,
        published: true,
        updatedAt: timestamp,
      });
  }

  const schedules = [
    {
      id: "sun-cse315",
      courseId: "cse315-2026",
      courseCode: "CSE 315",
      courseName: "Software Engineering",
      dayIndex: 0,
      day: "Sunday",
      startTime: "09:30",
      endTime: "10:20",
      room: "Room 204",
      classType: "Theory",
    },
    {
      id: "mon-cse321",
      courseId: "cse321-2026",
      courseCode: "CSE 321",
      courseName: "Computer Architecture",
      dayIndex: 1,
      day: "Monday",
      startTime: "11:30",
      endTime: "12:20",
      room: "Room 302",
      classType: "Theory",
    },
    {
      id: "wed-cse333",
      courseId: "cse333-2026",
      courseCode: "CSE 333",
      courseName: "Computer Networks",
      dayIndex: 3,
      day: "Wednesday",
      startTime: "14:00",
      endTime: "15:40",
      room: "Network Lab",
      classType: "Practical",
    },
    {
      id: "thu-cse315",
      courseId: "cse315-2026",
      courseCode: "CSE 315",
      courseName: "Software Engineering",
      dayIndex: 4,
      day: "Thursday",
      startTime: "09:00",
      endTime: "09:50",
      room: "Room 204",
      classType: "Theory",
    },
  ];

  for (const item of schedules) {
    await db.collection("schedules").doc(item.id).set({
      ...item,
      teacherId: teacher.uid,
      teacherName: "Dr. Kaushik Deb",
      status: "scheduled",
      updatedAt: timestamp,
    });
  }

  const sessionId = "demo-active-session";

  await db.collection("attendanceSessions").doc(sessionId).set({
    courseId: "cse321-2026",
    courseCode: "CSE 321",
    courseName: "Computer Architecture",
    teacherId: teacher.uid,
    teacherName: "Dr. Kaushik Deb",
    classType: "Theory",
    status: "active",
    requiresPasscode: true,
    requiresGps: false,
    startedAt: Timestamp.fromDate(
      new Date(Date.now() - 5 * 60 * 1000),
    ),
    endsAt: Timestamp.fromDate(
      new Date(Date.now() + 60 * 60 * 1000),
    ),
    createdAt: timestamp,
  });

  await db
    .collection("attendanceSessions")
    .doc(sessionId)
    .collection("private")
    .doc("config")
    .set({
      passcode: "482731",
      requiresGps: false,
      updatedAt: timestamp,
    });

  console.log("");
  console.log("Trackademic emulator seed complete.");
  console.log("");
  console.log("STUDENT");
  console.log("Email: aaa@gmail.com");
  console.log("Password: 12345678");
  console.log("UID:", student.uid);
  console.log("");
  console.log("TEACHER");
  console.log("Email: teacher@trackademic.test");
  console.log("Password: 12345678");
  console.log("UID:", teacher.uid);
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });