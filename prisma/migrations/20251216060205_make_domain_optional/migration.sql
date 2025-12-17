-- RedefineTables
PRAGMA defer_foreign_keys=ON;
PRAGMA foreign_keys=OFF;
CREATE TABLE "new_Project" (
    "id" INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
    "slug" TEXT NOT NULL,
    "name" TEXT NOT NULL,
    "description" TEXT,
    "repositoryUrl" TEXT NOT NULL,
    "branch" TEXT NOT NULL DEFAULT 'main',
    "clonedPath" TEXT,
    "lastCommit" TEXT,
    "domain" TEXT,
    "status" TEXT NOT NULL DEFAULT 'pending',
    "port" INTEGER,
    "buildCommand" TEXT NOT NULL DEFAULT 'npm run build',
    "startCommand" TEXT NOT NULL DEFAULT 'npm start',
    "outputDir" TEXT NOT NULL DEFAULT 'dist',
    "databaseType" TEXT,
    "databaseUrl" TEXT,
    "technologies" TEXT NOT NULL,
    "createdAt" DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" DATETIME NOT NULL,
    "lastDeployAt" DATETIME,
    "userId" INTEGER NOT NULL,
    CONSTRAINT "Project_userId_fkey" FOREIGN KEY ("userId") REFERENCES "User" ("id") ON DELETE CASCADE ON UPDATE CASCADE
);
INSERT INTO "new_Project" ("branch", "buildCommand", "clonedPath", "createdAt", "databaseType", "databaseUrl", "description", "domain", "id", "lastCommit", "lastDeployAt", "name", "outputDir", "port", "repositoryUrl", "slug", "startCommand", "status", "technologies", "updatedAt", "userId") SELECT "branch", "buildCommand", "clonedPath", "createdAt", "databaseType", "databaseUrl", "description", "domain", "id", "lastCommit", "lastDeployAt", "name", "outputDir", "port", "repositoryUrl", "slug", "startCommand", "status", "technologies", "updatedAt", "userId" FROM "Project";
DROP TABLE "Project";
ALTER TABLE "new_Project" RENAME TO "Project";
CREATE UNIQUE INDEX "Project_slug_key" ON "Project"("slug");
CREATE UNIQUE INDEX "Project_domain_key" ON "Project"("domain");
PRAGMA foreign_keys=ON;
PRAGMA defer_foreign_keys=OFF;
