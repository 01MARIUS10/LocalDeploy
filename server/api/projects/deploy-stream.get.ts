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

    // Récupérer le slug depuis les query params
    const query = getQuery(event);
    const slug = query.slug as string;

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
      include: {
        envVars: true, // Inclure les variables d'environnement
      },
    });

    if (!project) {
      throw createError({
        statusCode: 404,
        message: "Projet non trouvé",
      });
    }

    // Configurer les headers pour Server-Sent Events
    setResponseHeaders(event, {
      "Content-Type": "text/event-stream",
      "Cache-Control": "no-cache",
      Connection: "keep-alive",
    });

    // Chemin du script orchestrateur
    const scriptPath = path.join(
      process.cwd(),
      "app/backend/commands/scripts/deploy-orchestrator.sh"
    );

    // Fonction pour trouver un port disponible
    const findAvailablePort = async (startPort: number = 3000): Promise<number> => {
      const net = await import('net');
      
      return new Promise((resolve, reject) => {
        const server = net.createServer();
        
        server.listen(startPort, () => {
          const port = (server.address() as any).port;
          server.close(() => resolve(port));
        });
        
        server.on('error', async () => {
          // Port occupé, essayer le suivant
          const nextPort = await findAvailablePort(startPort + 1);
          resolve(nextPort);
        });
      });
    };

    // Port pour le serveur (utiliser le port du projet ou trouver un port disponible)
    let port = project.port || 0;
    
    if (!port) {
      // Générer un port aléatoire entre 3000 et 9000
      const randomStart = Math.floor(Math.random() * 6000) + 3000;
      port = await findAvailablePort(randomStart);
      
      // Mettre à jour le projet avec le port trouvé
      await prisma.project.update({
        where: { id: project.id },
        data: { port }
      });
    }

    const logs: string[] = [];

    // Créer un stream pour envoyer les logs
    const stream = event.node.res;

    // Fonction pour envoyer un événement SSE
    const sendEvent = (data: any) => {
      stream.write(`data: ${JSON.stringify(data)}\n\n`);
    };

    // Envoyer un événement de démarrage
    sendEvent({
      type: "start",
      message: "..................................",
    });

    // Récupérer la commande de build (avec fallback par défaut)
    const buildCommand = project.buildCommand || "npm run build";

    // Récupérer la version Node.js (avec fallback)
    const nodeVersion = project.nodeVersion || "22";

    // Transformer les variables d'environnement en JSON
    const envVarsJson = project.envVars.reduce((acc: Record<string, string>, envVar: any) => {
      acc[envVar.key] = envVar.value;
      return acc;
    }, {});

    // Encoder le JSON en base64 pour éviter les problèmes d'échappement
    const envVarsBase64 = Buffer.from(JSON.stringify(envVarsJson)).toString('base64');

    // Exécuter le script orchestrateur avec toutes les variables
    const deployProcess = exec(
      `bash ${scriptPath} ${slug} ${project.repositoryUrl} ${port} "${buildCommand}" ${nodeVersion} ${envVarsBase64}`,
      {
        maxBuffer: 1024 * 1024 * 10, // 10MB buffer
      }
    );

    // Capturer stdout
    deployProcess.stdout?.on("data", (data) => {
      const log = data.toString();
      logs.push(log);
      console.log(log);
      
      // Détecter le type de log et formater
      if (log.includes("[PHASE]")) {
        sendEvent({ type: "phase", message: log.replace("[PHASE]", "").trim() });
      } else if (log.includes("[SUCCESS]")) {
        sendEvent({ type: "success", message: log.replace("[SUCCESS]", "").trim() });
      } else if (log.includes("[ERROR]")) {
        sendEvent({ type: "error", message: log.replace("[ERROR]", "").trim() });
      } else if (log.includes("[WARN]")) {
        sendEvent({ type: "warn", message: log.replace("[WARN]", "").trim() });
      } else if (log.includes("[INFO]")) {
        sendEvent({ type: "info", message: log.replace("[INFO]", "").trim() });
      } else {
        // Log brut sans tag
        sendEvent({ type: "log", message: log });
      }
    });

    // Capturer stderr
    deployProcess.stderr?.on("data", (data) => {
      const log = data.toString();
      logs.push(`[STDERR] ${log}`);
      sendEvent({ type: "error", message: log });
    });

    // Gérer la fin du processus
    deployProcess.on("close", async (code) => {
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

        // Mettre à jour le statut du projet
        if (code === 0) {
          await prisma.project.update({
            where: { id: project.id },
            data: {
              status: "running",
              lastDeployAt: new Date(),
            },
          });
        } else {
          await prisma.project.update({
            where: { id: project.id },
            data: {
              status: "error",
            },
          });
        }

        // Envoyer le message de fin
        if (code === 0) {
          sendEvent({
            type: "complete",
            message: " Déploiement terminé avec succès !",
            code: code,
          });
        } else {
          sendEvent({
            type: "error",
            message: ` Déploiement échoué avec le code ${code}`,
            code: code,
          });
        }
      } catch (error) {
        sendEvent({
          type: "error",
          message: "Erreur lors de l'enregistrement du déploiement",
          error: (error as Error).message,
        });
      }

      // Fermer le stream
      sendEvent({ type: "end" });
      stream.end();
    });

    // Gérer les erreurs d'exécution
    deployProcess.on("error", (error) => {
      sendEvent({
        type: "error",
        message: "Erreur lors de l'exécution du script de déploiement",
        error: error.message,
      });
      stream.end();
    });

    // Gérer la fermeture de la connexion client
    event.node.req.on("close", () => {
      deployProcess.kill();
    });
  } catch (error) {
    throw createError({
      statusCode: (error as any).statusCode || 500,
      message: (error as Error).message || "Une erreur s'est produite",
    });
  }
});
