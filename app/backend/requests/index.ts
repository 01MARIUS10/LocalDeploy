import { getUserFromToken } from "../services/auth";

export function authUser(event: any) {
  const token = getToken(event);
  console.log("Token extracted:", token);
  return getUserFromToken(token);
  // Logique d'authentification ici
}

function getToken(event: any): string {
  const authHeader = getHeader(event, "Authorization");
  console.log("Auth Header:", authHeader);

  let token: string = "";

  if (authHeader?.startsWith("Bearer ")) {
    token = authHeader.substring(7);
  } else {
    // Alternative : token dans un cookie (ex: si tu utilises nuxt-auth-utils ou sessions)
    token = getCookie(event, "auth-token")
      ? getCookie(event, "auth-token")
      : ""; // change le nom du cookie selon ton implé
  }

  if (!token) {
    throw createError({
      statusCode: 401,
      statusMessage: "Unauthorized - No token",
    });
  }

  return token;
}
