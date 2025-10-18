import { onSchedule } from "firebase-functions/v2/scheduler";
import { initializeApp } from "firebase-admin/app";
import { getFirestore } from "firebase-admin/firestore";
import { getMessaging } from "firebase-admin/messaging";

initializeApp();
const firestore = getFirestore();

export const autoEnergyRecharge = onSchedule(
  {
    schedule: "every 10 minutes",
    timeZone: "Asia/Seoul",
  },
  async (event) => {
    const usersRef = firestore.collection("users");
    const snapshot = await usersRef.get();
    const now = new Date();

    const refillInterval = 10; // 10분마다 1회 충전

    for (const doc of snapshot.docs) {
      const data = doc.data();
      const energy = data.energy ?? 0;
      const maxEnergy = data.energy_max ?? 7;
      const lastRefill = data.energy_last_refill?.toDate?.() ?? new Date();
      const fcmToken = data.fcm_token;

      if (energy >= maxEnergy) continue;

      const elapsedMin = (now - lastRefill) / 60000;
      const gained = Math.floor(elapsedMin / refillInterval);
      if (gained <= 0) continue;

      const newEnergy = Math.min(energy + gained, maxEnergy);
      const newRefillTime = new Date(lastRefill.getTime() + gained * refillInterval * 60000);

      await doc.ref.update({
        energy: newEnergy,
        energy_last_refill: newRefillTime,
      });

      await doc.ref.collection("energy_transactions").add({
        type: "auto_recharge",
        amount: gained,
        created_at: now,
      });

      if (newEnergy === maxEnergy && fcmToken) {
        await getMessaging().send({
          token: fcmToken,
          notification: {
            title: "⚡ 에너지가 가득 찼어요!",
            body: "이제 다시 게임을 즐길 준비가 되었어요!",
          },
        });
      }
    }

    console.log("✅ Energy auto recharge executed at", now);
  }
);