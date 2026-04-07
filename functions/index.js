const functions = require("firebase-functions");
const admin = require("firebase-admin");

admin.initializeApp();

exports.sendAdminNotification = functions.firestore
  .document("notifications/{notifId}")
  .onCreate(async (snap, context) => {

    const data = snap.data();
    if (!data || data.isActive !== true) return;

    const title = data.title;
    const message = data.message;

    // 1️⃣ Get all users with FCM tokens
    const usersSnap = await admin.firestore()
      .collection("users")
      .where("fcmToken", "!=", null)
      .get();

    if (usersSnap.empty) return;

    const tokens = [];
    const batch = admin.firestore().batch();

    usersSnap.forEach(doc => {
      const user = doc.data();
      const uid = doc.id;

      if (user.fcmToken) {
        tokens.push(user.fcmToken);

        // 2️⃣ Save inbox notification
        const inboxRef = admin.firestore()
          .collection("user_notifications")
          .doc(uid)
          .collection("items")
          .doc();

        batch.set(inboxRef, {
          title: title,
          message: message,
          read: false,
          createdAt: admin.firestore.FieldValue.serverTimestamp(),
          type: "admin",
        });
      }
    });

    await batch.commit();

    // 3️⃣ Send FCM push
    const payload = {
      notification: {
        title: title,
        body: message,
      },
      data: {
        type: "admin",
      },
    };

    await admin.messaging().sendEachForMulticast({
      tokens: tokens,
      ...payload,
    });

    console.log("Admin notification sent to users:", tokens.length);
  });
