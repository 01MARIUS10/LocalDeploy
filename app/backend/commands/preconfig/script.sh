# Configuration initiale (première fois)
sudo ./00-setup-environment.sh

# Clone
sudo ./01-clone-repo.sh monprojetreact https://github.com/user/repo.git main

# Variables d'environnement
sudo ./02-setup-env.sh monprojetreact

# Build
sudo ./03-build-project.sh monprojetreact

# Créer release
sudo ./04-create-release.sh monprojetreact

# Déployer
RELEASE=$(ls -t /var/projects/LocalDeploy/monprojetreact/releases | head -1)
sudo ./05-deploy-release.sh monprojetreact $RELEASE

# Configure Nginx
sudo ./06-setup-nginx.sh monprojetreact monprojet.local 80

# Health check
sudo ./07-health-check.sh monprojetreact monprojet.local 80


# Rollback immédiat
sudo ./08-rollback.sh monprojetreact




# #################################################
cd app/backend/commands/deploimentFlow

sudo ./deploy-full.sh \
  monprojetreact \
  https://github.com/user/MonProjetReact.git \
  main \
  monprojet.local \
  80