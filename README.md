# maa-marketing-analytics-ops
The DevOps repo of the maa-marketing-analytics repo
# Jenkins Pipeline:
https://orchestrator21.orchestrator-v2.sys.cigna.com/job/orchestrators-folders/job/ma-analytics/job/ma-analytics-dataops-blueprint/job/maa-marketing-analytics/
# Jenkins File Config:
- Solutions repo env var needs to be changed from maa-marketing-analytics to the name of the solutions repo
- Case statements need to be updated to match the branching pattern used by the team
  - Ex. dev, test, main
```
switch(env.BRANCH_NAME) {
    case "develop": # Update to match branching pattern
        env.ACCOUNT_NUMBER = "215132885729"
        env.ENV = "dev"
        break
    case "next": # Update to match branching pattern
        env.ACCOUNT_NUMBER = "883528617975"
        env.ENV = "test"
        break
    case "main": # Update to match branching pattern
        env.ACCOUNT_NUMBER = "160989692528"
        env.ENV = "prod"
        break
    default:
        env.ACCOUNT_NUMBER = "215132885729"
        env.ENV = "dev"
        break
}
```
- Deploy phases also need to be updated to match the team's branching pattern
  - ex: 
```
def devDeploy = deployTemplate + [
        branchPattern   : 'main|develop|feature.*|hotfix.*', # Update to match branching pattern
        sdlcEnvironment : 'dev',
        isProductionDeployment: false,
]

def testDeploy = deployTemplate + [
        branchPattern   : 'next', # Update to match branching pattern
        sdlcEnvironment : 'test',
        isProductionDeployment: false
]

# Update to match branching pattern
if (env.BRANCH_NAME == "main" && env.SNOW_TICKET_NO?.trim() == "" && RUN_DEPLOY){
    error("To deploy to prod, a SNOW ticket is required.")
}

def prodDeploy = deployTemplate + [
        branchPattern   : 'main', # Update to match branching pattern
        sdlcEnvironment : 'prod',
        isProductionDeployment: true,
        ticket: [
                ticketType: 'Servicenow',
                title: "${SNOW_TICKET_NO}",
        ]
]
```

# Solutions Repo Structure:
- Maintain a flat structure for the repository with all modules at the top level.
	- Each module should include: 
		- Liquibase changelogs
          - dev.changelog.xml
		  - test.changelog.xml
		  - main.changelog.xml
		  - prod.changelog.xml
		- A pyproject.toml file following the Poetry dependency management pattern, with an additional "data-op-config" section.
        - A config directory divided into subdirectories for different environments (DEV, INT, TEST, PROD).
        - Additional directories containing DDLs/DMLs to be deployed.
	- The pyproject.toml file must have a "type" parameter under "data-op-config" to specify the deployment type, which is essential for deployment. Valid options are: 
		- ddl
		- dml
		- tdv_ddl
		- tdv_dml
	- The config directory's subdirectories should contain: 
		- Liquibase env.properties files
		- Liquibase.properties files
	- Directories containing SQL files for DDLs/DMLs should be appropriately labeled, such as "tables" or "views," based on their contents.
```
solutions-repo/
│
├── module-1/
│   ├── liquibase-changelogs
│   ├── pyproject.toml
│   ├── config/
│   │   ├── DEV/
│   │   │   ├── env.properties
│   │   │   └── liquibase.properties
│   │   ├── INT/
│   │   │   ├── env.properties
│   │   │   └── liquibase.properties
│   │   ├── TEST/
│   │   │   ├── env.properties
│   │   │   └── liquibase.properties
│   │   └── PROD/
│   │       ├── env.properties
│   │       └── liquibase.properties
│   ├── tables/
│   └── views/
│
├── module-2/
│   ├── liquibase-changelogs
│   ├── pyproject.toml
│   ├── config/
│   │   ├── DEV/
│   │   │   ├── env.properties
│   │   │   └── liquibase.properties
│   │   ├── INT/
│   │   │   ├── env.properties
│   │   │   └── liquibase.properties
│   │   ├── TEST/
│   │   │   ├── env.properties
│   │   │   └── liquibase.properties
│   │   └── PROD/
│   │       ├── env.properties
│   │       └── liquibase.properties
│   ├── tables/
│   └── views/
│
... (additional modules as needed)
```