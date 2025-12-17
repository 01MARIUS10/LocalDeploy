import { getProfileData } from "~/backend/services/user";

export default defineEventHandler(async () => {
  //temporaire
  const userId = 1;

  const profile = await getProfileData(userId);

  if (!profile) {
    throw createError({
      statusCode: 404,
      statusMessage: "Profil introuvable",
    });
  }

  return profile;
});
