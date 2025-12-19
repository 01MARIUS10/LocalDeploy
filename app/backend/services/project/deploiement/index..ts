 const DeploiementFlow = {
  project:{
    id:1,
    name:"MonProjetReact",
    slug:"monprojetreact",
    description:"Un projet React pour démo",
    domain:"monprojet.local",
    repositoryUrl:"https://github.com/01MARIUS10/MonProjetReact.git",
    repositoryBranch:"main"
  },
  environment:{
    nodeVersion:22
  },
  build:{
    buildCommand:"npm install && npm run build",
    folder:{
      codePath:"/var/projects/LocalDeploy",
      artefactPath:"/var/projects/LocalDeploy/dist",
      documentRoot:"/var/www/html"
    },
    outputDirectory:"dist",
  },
  deploiement:{
    outputDirectory:"dist",
    deployCommand:"cp -r dist/* /var/www/html/",
    deploymentDomain:"mamacita",
    deploymentDomainIp:"192.168.1.4",
    deploymentUrl:"http://mamacita.local",
    lastDeployment: new Date('2024-06-20T10:00:00Z'),
    folder:{
      codePath:"/var/projects/LocalDeploy",
      artefactPath:"/var/projects/LocalDeploy/dist",
      documentRoot:"/var/www/html"
    },
  },
  
  environmentVariables:[
    {key:"NODE_ENV", value:"production", secret:false},
    {key:"API_KEY", value:"***hidden***", secret:true}
  ],
}