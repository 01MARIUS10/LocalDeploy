import bcrypt from "bcrypt";
import prisma from "~/../server/utils/prisma";
import {
  generateTokens,
  verifyToken,
  type AuthTokens,
  type JWTPayload,
} from "./token";

export interface LoginResponse {
  user: {
    id: number;
    email: string;
    name: string;
  };
  tokens: AuthTokens;
}

/**
 * Hasher un mot de passe
 */
export async function hashPassword(password: string): Promise<string> {
  const saltRounds = 10;
  return bcrypt.hash(password, saltRounds);
}

/**
 * Vérifier un mot de passe
 */
export async function verifyPassword(
  password: string,
  hashedPassword: string
): Promise<boolean> {
  return bcrypt.compare(password, hashedPassword);
}

/**
 * Enregistrer un nouvel utilisateur
 */
export async function registerUser(
  email: string,
  password: string,
  name: string
): Promise<LoginResponse> {
  // Vérifier si l'utilisateur existe déjà
  const existingUser = await prisma.user.findUnique({
    where: { email },
  });

  if (existingUser) {
    throw new Error("Un utilisateur avec cet email existe déjà");
  }

  // Hasher le mot de passe
  const hashedPassword = await hashPassword(password);

  // Créer l'utilisateur
  const user = await prisma.user.create({
    data: {
      email,
      password: hashedPassword,
      name,
    },
    select: {
      id: true,
      email: true,
      name: true,
    },
  });

  // Générer les tokens
  const tokens = generateTokens(user);

  return {
    user,
    tokens,
  };
}

/**
 * Connexion d'un utilisateur
 */
export async function loginUser(
  email: string,
  password: string
): Promise<LoginResponse> {
  // Trouver l'utilisateur
  const user = await prisma.user.findUnique({
    where: { email },
  });

  if (!user) {
    throw new Error("Email ou mot de passe incorrect");
  }

  // Vérifier le mot de passe
  const isPasswordValid = await verifyPassword(password, user.password);

  if (!isPasswordValid) {
    throw new Error("Email ou mot de passe incorrect");
  }

  // Générer les tokens
  const tokens = generateTokens({
    id: user.id,
    email: user.email,
    name: user.name,
  });

  return {
    user: {
      id: user.id,
      email: user.email,
      name: user.name,
    },
    tokens,
  };
}

/**
 * Rafraîchir l'access token avec un refresh token
 */
export async function refreshAccessToken(
  refreshToken: string
): Promise<AuthTokens> {
  // Vérifier le refresh token
  const payload = verifyToken(refreshToken);

  if (!payload) {
    throw new Error("Refresh token invalide ou expiré");
  }

  // Vérifier que l'utilisateur existe toujours
  const user = await prisma.user.findUnique({
    where: { id: payload.userId },
    select: {
      id: true,
      email: true,
      name: true,
    },
  });

  if (!user) {
    throw new Error("Utilisateur introuvable");
  }

  // Générer de nouveaux tokens
  return generateTokens(user);
}

/**
 * Récupérer l'utilisateur depuis le token
 */
export async function getUserFromToken(token: string) {
  const payload = verifyToken(token);

  console.log("Token payload:", payload);
  if (!payload) {
    return null;
  }

  const user = await prisma.user.findUnique({
    where: { id: payload.userId },
    select: {
      id: true,
      email: true,
      name: true,
      createdAt: true,
      updatedAt: true,
    },
  });

  return user;
}

/**
 * Changer le mot de passe d'un utilisateur
 */
export async function changePassword(
  userId: number,
  oldPassword: string,
  newPassword: string
): Promise<void> {
  // Récupérer l'utilisateur
  const user = await prisma.user.findUnique({
    where: { id: userId },
  });

  if (!user) {
    throw new Error("Utilisateur introuvable");
  }

  // Vérifier l'ancien mot de passe
  const isPasswordValid = await verifyPassword(oldPassword, user.password);

  if (!isPasswordValid) {
    throw new Error("Ancien mot de passe incorrect");
  }

  // Hasher le nouveau mot de passe
  const hashedPassword = await hashPassword(newPassword);

  // Mettre à jour le mot de passe
  await prisma.user.update({
    where: { id: userId },
    data: { password: hashedPassword },
  });
}

/**
 * Réinitialiser le mot de passe (sans vérification de l'ancien)
 * À utiliser avec un système de reset par email
 */
export async function resetPassword(
  userId: number,
  newPassword: string
): Promise<void> {
  const hashedPassword = await hashPassword(newPassword);

  await prisma.user.update({
    where: { id: userId },
    data: { password: hashedPassword },
  });
}

// Ré-exporter les types et fonctions de token pour faciliter l'import

export {
  generateTokens,
  verifyToken,
  type AuthTokens,
  type JWTPayload,
} from "./token";
