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
    const password = validatePassword(request.data.password);

    const database = getFirestore();
    const inviteReference = database
      .collection("registrationInvites")
      .doc(institutionId);

    const initialInvite = await inviteReference.get();
    const role = validateInvite(initialInvite.data(), email);

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

      await database.runTransaction(async (transaction) => {
        const currentInvite = await transaction.get(
          inviteReference,
        );

        const inviteData = currentInvite.data();
        const currentRole = validateInvite(inviteData, email);

        if (!inviteData || currentRole !== role) {
          throw new HttpsError(
            "aborted",
            "The invitation changed. Please try again.",
          );
        }

        const timestamp = FieldValue.serverTimestamp();

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
          department: optionalText(inviteData.department),
          batch: optionalText(inviteData.batch),
          section: optionalText(inviteData.section),
          semester: optionalText(inviteData.semester),
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
      });

      return {
        uid: user.uid,
        role,
      };
    } catch (error) {
      if (createdUserId != null) {
        try {
          await getAuth().deleteUser(createdUserId);
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

      logger.error("Registration failed.", error);

      throw new HttpsError(
        "internal",
        "Registration failed. Please try again.",
      );
    }
  },
);
