// server/api/profile.put.ts

import { defineEventHandler, readBody, createError } from "h3";
import { updatePassword } from "~/backend/services/user";

export default defineEventHandler(async (event) => {
  const userId = 2;

  await updatePassword(Number(userId), "12345678");
  return { success: true };
});
