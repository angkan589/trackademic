import {initializeApp} from "firebase-admin/app";
import {getAuth} from "firebase-admin/auth";
import {
  FieldValue,
  Timestamp,
  getFirestore,
} from "firebase-admin/firestore";
import * as logger from "firebase-functions/logger";
import {setGlobalOptions} from "firebase-functions/v2";
import {HttpsError, onCall} from "firebase-functions/v2/https";

initializeApp();

setGlobalOptions({
  region: "asia-south1",
  maxInstances: 10,
});

type RegistrationData = {
  displayName?: unknown;
  email?: unknown;
  institutionId?: unknown;
  password?: unknown;
};

type CreateCourseData = {
  code?: unknown;
  name?: unknown;
  department?: unknown;
  batch?: unknown;
  section?: unknown;
  semester?: unknown;
  room?: unknown;
};

type EnrollStudentData = {
  courseId?: unknown;
  institutionId?: unknown;
};

type CreateScheduleData = {
  courseId?: unknown;
  dayIndex?: unknown;
  day?: unknown;
  startTime?: unknown;
  endTime?: unknown;
  room?: unknown;
  classType?: unknown;
};

type UserRole = "student" | "teacher";

function requiredString(
  value: unknown,
  field: string,
  minimum: number,
  maximum: number,
): string {
  if (typeof value !== "string") {
    throw new HttpsError(
      "invalid-argument",
      `${field} is required.`,
    );
  }

  const result = value.trim();

  if (result.length < minimum || result.length > maximum) {
    throw new HttpsError(
      "invalid-argument",
      `${field} must contain ${minimum}-${maximum} characters.`,
    );
  }

  return result;
}

function optionalString(
  value: unknown,
  field: string,
  maximum: number,
): string | null {
  if (value == null) {
    return null;
  }

  if (typeof value !== "string") {
    throw new HttpsError(
      "invalid-argument",
      `${field} must be text.`,
    );
  }

  const result = value.trim();

  if (result.length > maximum) {
    throw new HttpsError(
      "invalid-argument",
      `${field} is too long.`,
    );
  }

  return result.length === 0 ? null : result;
}

function validateEmail(value: unknown): string {
  const email = requiredString(
    value,
    "Email",
    5,
    254,
  ).toLowerCase();

  if (!/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(email)) {
    throw new HttpsError(
      "invalid-argument",
      "Enter a valid email address.",
    );
  }

  return email;
}

function validateInstitutionId(value: unknown): string {
  const institutionId = requiredString(
    value,
    "Institution ID",
    3,
    40,
  ).toUpperCase();

  if (!/^[A-Z0-9_-]+$/.test(institutionId)) {
    throw new HttpsError(
      "invalid-argument",
      "Institution ID contains invalid characters.",
    );
  }

  return institutionId;
}

function validatePassword(value: unknown): string {
  if (
    typeof value !== "string" ||
    value.length < 8 ||
    value.length > 128
  ) {
    throw new HttpsError(
      "invalid-argument",
      "Password must contain 8-128 characters.",
    );
  }

  return value;
}

function validateTime(value: unknown, field: string): string {
  const time = requiredString(
    value,
    field,
    5,
    5,
  );

  if (!/^([01]\d|2[0-3]):[0-5]\d$/.test(time)) {
    throw new HttpsError(
      "invalid-argument",
      `${field} must use HH:MM format.`,
    );
  }

  return time;
}

function validateDayIndex(value: unknown): number {
  if (
    typeof value !== "number" ||
    !Number.isInteger(value) ||
    value < 0 ||
    value > 6
  ) {
    throw new HttpsError(
      "invalid-argument",
      "Day index must be between 0 and 6.",
    );
  }

  return value;
}

function validateInvite(
  invite: FirebaseFirestore.DocumentData | undefined,
  email: string,
): UserRole {
  if (!invite || invite.isActive !== true || invite.usedAt) {
    throw new HttpsError(
      "permission-denied",
      "This institution ID is invalid or has already been used.",
    );
  }

  const invitationEmail =
    typeof invite.email === "string" ?
      invite.email.trim().toLowerCase() :
      "";

  if (invitationEmail !== email) {
    throw new HttpsError(
      "permission-denied",
      "The email does not match this institution ID.",
    );
  }

  if (invite.role !== "student" && invite.role !== "teacher") {
    throw new HttpsError(
      "failed-precondition",
      "The invitation contains an invalid role.",
    );
  }

  if (
    invite.expiresAt instanceof Timestamp &&
    invite.expiresAt.toMillis() <= Date.now()
  ) {
    throw new HttpsError(
      "permission-denied",
      "This registration invitation has expired.",
    );
  }

  return invite.role;
}

function optionalText(value: unknown): string | null {
  return typeof value === "string" ? value.trim() : null;
}

async function requireActiveTeacher(
  uid: string,
): Promise<FirebaseFirestore.DocumentData> {
  const database = getFirestore();

  const profile = await database
    .collection("users")
    .doc(uid)
    .get();

  const data = profile.data();

  if (
    !profile.exists ||
    !data ||
    data.isActive !== true ||
    data.role !== "teacher"
  ) {
    throw new HttpsError(
      "permission-denied",
      "An active teacher account is required.",
    );
  }

  return data;
}

async function requireOwnedCourse(
  teacherId: string,
  courseId: string,
): Promise<FirebaseFirestore.DocumentData> {
  const database = getFirestore();

  const course = await database
    .collection("courses")
    .doc(courseId)
    .get();

  const data = course.data();

  if (!course.exists || !data) {
    throw new HttpsError(
      "not-found",
      "Course not found.",
    );
  }

  if (data.teacherId !== teacherId) {
    throw new HttpsError(
      "permission-denied",
      "You do not manage this course.",
    );
  }

  if (data.isActive !== true) {
    throw new HttpsError(
      "failed-precondition",
      "This course is inactive.",
    );
  }

  return data;
}

export const registerWithInvite = onCall<RegistrationData>(
  {
    timeoutSeconds: 30,
    maxInstances: 10,
  },
  async (request) => {
    if (request.auth) {
      throw new HttpsError(
        "failed-precondition",
        "Sign out before creating another account.",
      );
    }

    const displayName = requiredString(
      request.data.displayName,
      "Full name",
      2,
      80,
    );

    const email = validateEmail(request.data.email);

    const institutionId = validateInstitutionId(
      request.data.institutionId,
    );

    const password = validatePassword(
      request.data.password,
    );

    const database = getFirestore();

    const inviteReference = database
      .collection("registrationInvites")
      .doc(institutionId);

    const initialInvite = await inviteReference.get();

    const role = validateInvite(
      initialInvite.data(),
      email,
    );

    let createdUserId: string | null = null;

    try {
      const user = await getAuth().createUser({
        displayName,
        email,
        password,
        emailVerified: false,
        disabled: false,
      });

      createdUserId = user.uid;

      await getAuth().setCustomUserClaims(user.uid, {
        role,
        institutionId,
      });

      await database.runTransaction(
        async (transaction) => {
          const currentInvite = await transaction.get(
            inviteReference,
          );

          const inviteData = currentInvite.data();

          const currentRole = validateInvite(
            inviteData,
            email,
          );

          if (!inviteData || currentRole !== role) {
            throw new HttpsError(
              "aborted",
              "The invitation changed. Please try again.",
            );
          }

          const timestamp =
            FieldValue.serverTimestamp();

          const userReference = database
            .collection("users")
            .doc(user.uid);

          const auditReference = database
            .collection("auditLogs")
            .doc();

          transaction.create(userReference, {
            uid: user.uid,
            displayName,
            email,
            institutionId,
            role,
            isActive: true,
            emailVerified: false,
            phone: null,
            photoUrl: null,
            department: optionalText(
              inviteData.department,
            ),
            batch: optionalText(
              inviteData.batch,
            ),
            section: optionalText(
              inviteData.section,
            ),
            semester: optionalText(
              inviteData.semester,
            ),
            notificationPreferences: {
              attendance: true,
              marks: true,
              schedule: true,
            },
            createdAt: timestamp,
            updatedAt: timestamp,
          });

          transaction.update(inviteReference, {
            isActive: false,
            usedBy: user.uid,
            usedAt: timestamp,
            updatedAt: timestamp,
          });

          transaction.create(auditReference, {
            action: "user.registered",
            actorId: user.uid,
            actorRole: role,
            targetId: user.uid,
            metadata: {
              institutionId,
            },
            createdAt: timestamp,
          });
        },
      );

      return {
        uid: user.uid,
        role,
      };
    } catch (error) {
      if (createdUserId != null) {
        try {
          await getAuth().deleteUser(
            createdUserId,
          );
        } catch (rollbackError) {
          logger.error(
            "Registration rollback failed.",
            rollbackError,
          );
        }
      }

      if (error instanceof HttpsError) {
        throw error;
      }

      const errorCode =
        typeof error === "object" &&
        error !== null &&
        "code" in error ?
          String(error.code) :
          "";

      if (errorCode === "auth/email-already-exists") {
        throw new HttpsError(
          "already-exists",
          "An account already exists for this email.",
        );
      }

      logger.error(
        "Registration failed.",
        error,
      );

      throw new HttpsError(
        "internal",
        "Registration failed. Please try again.",
      );
    }
  },
);

export const createCourse = onCall<CreateCourseData>(
  {
    timeoutSeconds: 30,
    maxInstances: 10,
  },
  async (request) => {
    const teacherId = request.auth?.uid;

    if (!teacherId) {
      throw new HttpsError(
        "unauthenticated",
        "Sign in before creating a course.",
      );
    }

    const teacher = await requireActiveTeacher(
      teacherId,
    );

    const code = requiredString(
      request.data.code,
      "Course code",
      2,
      30,
    ).toUpperCase();

    const name = requiredString(
      request.data.name,
      "Course name",
      2,
      120,
    );

    const department = optionalString(
      request.data.department,
      "Department",
      120,
    );

    const batch = optionalString(
      request.data.batch,
      "Batch",
      80,
    );

    const section = optionalString(
      request.data.section,
      "Section",
      80,
    );

    const semester = optionalString(
      request.data.semester,
      "Semester",
      80,
    );

    const room = optionalString(
      request.data.room,
      "Room",
      80,
    );

    const database = getFirestore();

    const duplicate = await database
      .collection("courses")
      .where(
        "teacherId",
        "==",
        teacherId,
      )
      .where(
        "code",
        "==",
        code,
      )
      .limit(1)
      .get();

    if (!duplicate.empty) {
      throw new HttpsError(
        "already-exists",
        "You already have a course with this code.",
      );
    }

    const courseReference = database
      .collection("courses")
      .doc();

    const auditReference = database
      .collection("auditLogs")
      .doc();

    const timestamp =
      FieldValue.serverTimestamp();

    const teacherName =
      typeof teacher.displayName === "string" ?
        teacher.displayName :
        "";

    const batchWrite = database.batch();

    batchWrite.create(courseReference, {
      code,
      name,
      teacherId,
      teacherName,
      department,
      batch,
      section,
      semester,
      room,
      isActive: true,
      createdAt: timestamp,
      updatedAt: timestamp,
    });

    batchWrite.create(auditReference, {
      action: "course.created",
      actorId: teacherId,
      actorRole: "teacher",
      targetId: courseReference.id,
      metadata: {
        code,
        name,
      },
      createdAt: timestamp,
    });

    await batchWrite.commit();

    return {
      courseId: courseReference.id,
    };
  },
);

export const enrollStudent = onCall<EnrollStudentData>(
  {
    timeoutSeconds: 30,
    maxInstances: 10,
  },
  async (request) => {
    const teacherId = request.auth?.uid;

    if (!teacherId) {
      throw new HttpsError(
        "unauthenticated",
        "Sign in before enrolling a student.",
      );
    }

    await requireActiveTeacher(
      teacherId,
    );

    const courseId = requiredString(
      request.data.courseId,
      "Course ID",
      1,
      128,
    );

    const institutionId = validateInstitutionId(
      request.data.institutionId,
    );

    const course = await requireOwnedCourse(
      teacherId,
      courseId,
    );

    const database = getFirestore();

    const students = await database
      .collection("users")
      .where(
        "institutionId",
        "==",
        institutionId,
      )
      .where(
        "role",
        "==",
        "student",
      )
      .limit(1)
      .get();

    if (students.empty) {
      throw new HttpsError(
        "not-found",
        "No registered student was found with this institution ID.",
      );
    }

    const studentDocument = students.docs[0];

    const student = studentDocument.data();

    if (student.isActive !== true) {
      throw new HttpsError(
        "failed-precondition",
        "This student account is inactive.",
      );
    }

    const enrollmentReference = database
      .collection("courses")
      .doc(courseId)
      .collection("students")
      .doc(studentDocument.id);

    const auditReference = database
      .collection("auditLogs")
      .doc();

    const timestamp =
      FieldValue.serverTimestamp();

    const batchWrite = database.batch();

    batchWrite.set(
      enrollmentReference,
      {
        studentId: studentDocument.id,
        institutionId,
        displayName:
          typeof student.displayName === "string" ?
            student.displayName :
            "",
        email:
          typeof student.email === "string" ?
            student.email :
            "",
        isActive: true,
        enrolledAt: timestamp,
        updatedAt: timestamp,
      },
      {
        merge: true,
      },
    );

    batchWrite.set(
      studentDocument.ref,
      {
        courseIds: FieldValue.arrayUnion(
          courseId,
        ),
        updatedAt: timestamp,
      },
      {
        merge: true,
      },
    );

    batchWrite.create(auditReference, {
      action: "course.student_enrolled",
      actorId: teacherId,
      actorRole: "teacher",
      targetId: studentDocument.id,
      metadata: {
        courseId,
        courseCode: course.code,
        institutionId,
      },
      createdAt: timestamp,
    });

    await batchWrite.commit();

    return {
      studentId: studentDocument.id,
      institutionId,
    };
  },
);

export const createSchedule = onCall<CreateScheduleData>(
  {
    timeoutSeconds: 30,
    maxInstances: 10,
  },
  async (request) => {
    const teacherId = request.auth?.uid;

    if (!teacherId) {
      throw new HttpsError(
        "unauthenticated",
        "Sign in before creating a schedule.",
      );
    }

    const teacher = await requireActiveTeacher(
      teacherId,
    );

    const courseId = requiredString(
      request.data.courseId,
      "Course ID",
      1,
      128,
    );

    const course = await requireOwnedCourse(
      teacherId,
      courseId,
    );

    const dayIndex = validateDayIndex(
      request.data.dayIndex,
    );

    const day = requiredString(
      request.data.day,
      "Day",
      3,
      20,
    );

    const startTime = validateTime(
      request.data.startTime,
      "Start time",
    );

    const endTime = validateTime(
      request.data.endTime,
      "End time",
    );

    if (endTime <= startTime) {
      throw new HttpsError(
        "invalid-argument",
        "End time must be after start time.",
      );
    }

    const room = requiredString(
      request.data.room,
      "Room",
      1,
      80,
    );

    const classType = requiredString(
      request.data.classType,
      "Class type",
      2,
      40,
    );

    const database = getFirestore();

    const scheduleReference = database
      .collection("schedules")
      .doc();

    const auditReference = database
      .collection("auditLogs")
      .doc();

    const timestamp =
      FieldValue.serverTimestamp();

    const teacherName =
      typeof teacher.displayName === "string" ?
        teacher.displayName :
        "";

    const batchWrite = database.batch();

    batchWrite.create(scheduleReference, {
      courseId,
      courseCode:
        typeof course.code === "string" ?
          course.code :
          "",
      courseName:
        typeof course.name === "string" ?
          course.name :
          "",
      teacherId,
      teacherName,
      dayIndex,
      day,
      startTime,
      endTime,
      room,
      classType,
      status: "scheduled",
      createdAt: timestamp,
      updatedAt: timestamp,
    });

    batchWrite.create(auditReference, {
      action: "schedule.created",
      actorId: teacherId,
      actorRole: "teacher",
      targetId: scheduleReference.id,
      metadata: {
        courseId,
        day,
        startTime,
      },
      createdAt: timestamp,
    });

    await batchWrite.commit();

    return {
      scheduleId: scheduleReference.id,
    };
  },
);
