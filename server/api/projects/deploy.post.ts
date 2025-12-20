import { exec } from "child_process";
import path from "path";
import { authUser } from "~/backend/requests";
import prisma from "~/../server/utils/prisma";

export default defineEventHandler(async (event) => {
  try {
    // Authentification
    const user = await authUser(event);
    if (!user) {
      throw createError({
        statusCode: 401,
        message: "Unauthorized",
      });
    }

    // Récupérer les données de la requête
    const body = await readBody(event);
    const { slug } = body;

    if (!slug) {
      throw createError({
        statusCode: 400,
        message: "Le slug du projet est requis",
      });
    }

    // Récupérer le projet
    const project = await prisma.project.findFirst({
      where: {
        slug,
        userId: user.id,
      },
    });

    if (!project) {
      throw createError({
        statusCode: 404,
        message: "Projet non trouvé",
      });
    }

    // Chemin du script de build
    const scriptPath = path.join(
      process.cwd(),
      "app/backend/commands/scripts/create-project.sh"
    );

    // Chemin du projet (à adapter selon votre configuration)
    const projectPath = `/var/www/projects/${slug}`;

    // Créer un tableau pour stocker les logs
    const logs: string[] = [];

    return new Promise((resolve, reject) => {
      // Exécuter le script
      const buildProcess = exec(`bash ${scriptPath} ${projectPath}`, {
        maxBuffer: 1024 * 1024 * 10, // 10MB buffer
      });

      // Capturer stdout
      buildProcess.stdout?.on("data", (data) => {
        const log = data.toString();
        logs.push(log);
        console.log(log);
      });

      // Capturer stderr
      buildProcess.stderr?.on("data", (data) => {
        const log = data.toString();
        logs.push(`[STDERR] ${log}`);
        console.error(log);
      });

      // Gérer la fin du processus
      buildProcess.on("close", async (code) => {
        try {
          // Enregistrer le déploiement dans la base de données
          await prisma.deployment.create({
            data: {
              projectId: project.id,
              status: code === 0 ? "success" : "failed",
              logs: logs.join("\n"),
              deployedAt: new Date(),
            },
          });

          if (code === 0) {
            resolve({
              success: true,
              message: "Build terminé avec succès",
              logs: logs,
            });
          } else {
            reject(
              createError({
                statusCode: 500,
                message: `Build échoué avec le code ${code}`,
                data: {
                  logs: logs,
                },
              })
            );
          }
        } catch (dbError) {
          console.error("Erreur lors de l'enregistrement du déploiement:", dbError);
          reject(
            createError({
              statusCode: 500,
              message: "Erreur lors de l'enregistrement du déploiement",
              data: {
                error: (dbError as Error).message,
                logs: logs,
              },
            })
          );
        }
      });

      // Gérer les erreurs d'exécution
      buildProcess.on("error", (error) => {
        reject(
          createError({
            statusCode: 500,
            message: "Erreur lors de l'exécution du script de build",
            data: {
              error: error.message,
              logs: logs,
            },
          })
        );
      });
    });
  } catch (error) {
    console.error("Erreur dans deploy.post.ts:", error);
    
    throw createError({
      statusCode: (error as any).statusCode || 500,
      message: (error as Error).message || "Une erreur inattendue s'est produite",
      data: {
        error: (error as Error).message,
      },
    });
  }
});
