@Library('epf') _
env.TERRAFORM_VERSION = '1.4.7'
env.TERRAGRUNT_VERSION = '0.50.14'
env.AUTH_TYPE = 'gatekeeper'
env.SOLUTION_REPO = 'maa-dataops-example-solutions'
env.DAG_ID = 'blueprint_ddl_liquibase_v2'
env.SECURITY_REVIEW_ID = 'RITM7392745'

def container = [
        image: "registry.cigna.com/enterprise-devops/aws-d-megatainer",
        version: "1.0.14-2",
        cpu: 2000,
        memory: 4000
]

String accountRoleName = "Enterprise/MAAEVERNORTHGATEKEEPERJENKINS"
String cloud_name = "evernorth-qp-gov-solns-openshift-devops1"
String eks_gatekeeper_cloud_name = "evernorth-qp-gov-solns-eks-prod"

//pods label name generation
def buildNumber = JOB_NAME.replace("/","-")
def build = BUILD_NUMBER
arrBuildNumber = buildNumber.split("-")
def arrIndex = arrBuildNumber.size()
def label = "${build}-${arrBuildNumber[arrIndex-1]}${arrBuildNumber[arrIndex-2]}${arrBuildNumber[arrIndex-3]}"
if (label.length() > 59)
{
    label = label.substring(0,58)
}
label = label + 'z'
//pod and node creation
podTemplate(label: label, cloud: cloud_name, yaml: """
apiVersion: v1
kind: Pod
metadata:
  name: build
  labels:
    jenkins: pipeline
    group: gies.devops-coe
    app: conduit-cicd
spec:
  nodeSelector:
    beta.kubernetes.io/os: linux
  containers:
    - name: jnlp
      image: registry.cigna.com/enterprise-devops/conduit-jnlp:latest
      tty: true
      workingDir: "/home/jenkins/agent"
      resources:
        requests:
          cpu: "25m"
          memory: "999Mi"
        limits:
          cpu: "499m"
          memory: "999Mi"  
"""
) {
    timeout(time: 10, unit: 'MINUTES') {
        node(label) {

            stage('Solution Repo Branches') {
                script {
                    withCredentials([
                            usernamePassword(
                                    credentialsId: 'SVPDEVOP-CIG-CLONEA_UserPw',
                                    usernameVariable: 'GIT_USER',
                                    passwordVariable: 'GIT_TOKEN'
                            )
                    ],) {
                        def GIT_BRANCHES = sh(script: "curl -H \"Accept: application/vnd.github+json\" -H \"Authorization: token \$GIT_TOKEN\" https://api.github.sys.cigna.com/repos/cigna/${env.SOLUTION_REPO}/branches | jq -r '.[].name'", returnStdout: true).trim()
                        inputResult = input(
                                message: "Select a git branch",
                                parameters: [choice(name: "git_branch", choices: "${GIT_BRANCHES}", description: "Git branches")]
                        )
                        env.SOLUTION_BRANCH = inputResult
                        def TDV_DEFAULT = 'all_tdv'
                        env.TDV_ENV = TDV_DEFAULT
//                         def ENV_DEV = ['dev', 'dev2', 'int']
//                         def ENV_TEST = ['uat', 'qa', 'ite']
//                         def ENV_PROD = ['prd']
//                         def ENV_ALL = ENV_DEV + ENV_TEST + ENV_PROD
//
//                         def TDV_ENV_CHOICES = ''
//                         switch(env.SOLUTION_BRANCH.trim()) {
//                             case "dev":
//                                 ENV_DEV.each {
//                                     TDV_ENV_CHOICES += it + '\n'
//                                 }
//                                 break
//                             case "test":
//                                 ENV_TEST.each {
//                                     TDV_ENV_CHOICES += it + '\n'
//                                 }
//                                 break
//                             case "main":
//                                 ENV_PROD.each {
//                                     TDV_ENV_CHOICES += it + '\n'
//                                 }
//                                 break
//                             default:
//                                 ENV_ALL.each {
//                                     TDV_ENV_CHOICES += it + '\n'
//                                 }
//                                 break
//                         }   // closes switch statement
//
//                         tdvEnvInputResult = input(
//                             message: "Select a TDV environment",
//                             parameters: [choice(name: "tdv_environment", choices: "${TDV_ENV_CHOICES}", description: "TDV Environments")]
//                         )
//
//                         env.TDV_ENV = tdvEnvInputResult
                    }
                }
            }
        }
    }
}


switch(env.SOLUTION_BRANCH.trim()) {
    case "dev":
        env.ACCOUNT_NUMBER = "215132885729"
        env.ENV = "dev"
        env.TDV_SERVICE_ACCOUNT_NAME_1 = "SVT_DATAOPS_DEV"
        env.TDV_SERVICE_ACCOUNT_NAME_2 = "SVT_DATAOPS_DEV"
        env.TDV_SERVICE_ACCOUNT_NAME_3 = "SVT_DATAOPS_INT"
        break
    case "test":
        env.ACCOUNT_NUMBER = "883528617975"
        env.ENV = "test"
        env.TDV_SERVICE_ACCOUNT_NAME_1 = "SVT_DATAOPS_UAT"
        env.TDV_SERVICE_ACCOUNT_NAME_2 = "SVT_DATAOPS_UAT"
        env.TDV_SERVICE_ACCOUNT_NAME_3 = "SVT_DATAOPS_UAT"
        break
    case "main":
        env.ACCOUNT_NUMBER = "160989692528"
        env.ENV = "prod"
        env.TDV_SERVICE_ACCOUNT_NAME_1 = "SVT_DATAOPS_PRD"
        env.TDV_SERVICE_ACCOUNT_NAME_2 = ""
        env.TDV_SERVICE_ACCOUNT_NAME_3 = ""
        break
    default:
        env.ACCOUNT_NUMBER = "215132885729"
        env.ENV = "dev"
        env.TDV_SERVICE_ACCOUNT_NAME_1 = "SVT_DATAOPS_DEV"
        env.TDV_SERVICE_ACCOUNT_NAME_2 = "SVT_DATAOPS_DEV"
        env.TDV_SERVICE_ACCOUNT_NAME_3 = "SVT_DATAOPS_INT"
        break
}

String cloudServiceAccountName = "jenkins-robot-${ENV}"
String targetAccount = "${ACCOUNT_NUMBER}"
String sdlcEnvName = "${ENV}"

String MODULE_NAME = params.MODULE_NAME ?: "pipeline_infra"
String PLZ_ALIAS = params.PLZ_ALIAS ?: "apply_all"
String REGION_NAME = params.REGION_NAME ?: "us-east-1"
env.SNOW_TICKET_NO = params.SNOW_TICKET_NO ?: ""
boolean RUN_BUILD = params.BUILD ?: false
boolean RUN_DEPLOY = params.DEPLOY ?: false
boolean RUN_CONFTEST = params.CONFTEST ?: false
boolean RUN_GAMEDAY = params.GAMEDAY ?: false
String OPS_TYPE = params.OPS_TYPE ?: "all"

def buildPhase = [
        buildType       : 'plz',
        container       : container,
        branchPattern   : 'dev|test|main|feature.*|hotfix.*',
        cloudName: "${cloud_name}",
        sdlcEnvironment : 'Non-Prod',
        isStashEnabled : false,
        stashEnabled : false,
        runInAWS: false,
        //enable checkmarx & sonar
        checkmarxEnabled: "0" == "1",
        sonarEnabled: "0" == "1",
        extraCredentials: [
                usernamePassword(
                        credentialsId: 'SVPDEVOP-CIG-CLONEA_UserPw',
                        usernameVariable: 'GIT_USER',
                        passwordVariable: 'GIT_TOKEN'
                )
        ],

       checkmarx: [
               debug: "1" == "1",
               credentialsId: 'checkmarx_credentials',
               settings     : [
                       CX_PROJECT_TEAM_NAME: 'MEDICARE_ADVANTAGE_ANALYTICS',
                       CX_PROJECT_NAME: 'maa-dataops-example-solutions',
                       CX_SCAN_COMMENT     : "Branch: ${BRANCH_NAME} - Build: ${BUILD_NUMBER}",
                       CX_EXCLUDE_FOLDER_LIST  : 'plz-out, commands, test_resources, third_party, aws_glue_libs, tests',
               ],
            ],

       sonarQube: [
                   credentialsId       : 'sonarqube-service-id',
                   scannerProperties   : [
                           'sonar.projectKey=maa-dataops-example-solutions',
                           'sonar.projectName=maa-dataops-example-solutions',
                           'sonar.projectBaseDir=module/aws/',
                           'sonar.sources=python_code/src',
                           'sonar.tests=python_code/tests',
                           'sonar.python.coverage.reportPaths=python_code/reports'
                   ],
           ],
]

def extraCredentials = [
    usernamePassword(
        credentialsId: 'SVPDEVOP-CIG-CLONEA_UserPw',
        usernameVariable: 'GIT_USER',
        passwordVariable: 'GIT_TOKEN'
    ),
    usernamePassword(
        credentialsId: "${TDV_SERVICE_ACCOUNT_NAME_1}",
        usernameVariable: 'tdv_sa_username_1',
        passwordVariable: 'tdv_sa_password_1'
    ),
]

if (env.ENV != "prod") {
    if (env.TDV_SERVICE_ACCOUNT_NAME_2 != "") {
        extraCredentials = extraCredentials + [
            usernamePassword(
                credentialsId: "${TDV_SERVICE_ACCOUNT_NAME_2}",
                usernameVariable: 'tdv_sa_username_2',
                passwordVariable: 'tdv_sa_password_2'
            ),
        ]
    }
    if (env.TDV_SERVICE_ACCOUNT_NAME_3 != "") {
            extraCredentials = extraCredentials + [
            usernamePassword(
                credentialsId: "${TDV_SERVICE_ACCOUNT_NAME_3}",
                usernameVariable: 'tdv_sa_username_3',
                passwordVariable: 'tdv_sa_password_3'
            ),
        ]
    }
}

def deployTemplate = [
        isStashEnabled : false,
        runInAWS: true,
        cloudName: "${eks_gatekeeper_cloud_name}",
        ticketCloudName: "${cloud_name}",
        aws:
                [
                        cloudServiceAccountName: "${cloudServiceAccountName}",
                        targetAccount: "${targetAccount}",
                        accountRoleName: "${accountRoleName}",
                        region: 'us-east-1'
                ],
        verbosityFlag: '-vvv',
        container       : container,
        deploymentType  : 'plz',
        alias           : '${PLZ_ALIAS} ${MODULE_NAME}',
        extraArgs       : '${ENV} ${REGION_NAME} ${TDV_ENV} ${OPS_TYPE} ${ASSIGN_TAG} ${LIQUIBASE_TAG}',
        extraCredentials: extraCredentials,
]

def confTest = [
        testing: [
                [
                        testType: 'plz',
                        runInAWS: true,
                        cloudName: "${eks_gatekeeper_cloud_name}",
                        aws:
                                [
                                        cloudServiceAccountName: "${cloudServiceAccountName}",
                                        targetAccount: "${targetAccount}",
                                        accountRoleName: "${accountRoleName}",
                                        region: 'us-east-1'
                                ],
                        verbosityFlag: '-vvvv',
                        labels: [
                                'conftest',
                        ],
                        container: container,
                        extraTestArgs: "${MODULE_NAME} ${ENV} ${REGION_NAME}",
                        runBeforeDeployment: true,
                        extraCredentials: [
                                usernamePassword(
                                        credentialsId: 'SVPDEVOP-CIG-CLONEA_UserPw',
                                        usernameVariable: 'GIT_USER',
                                        passwordVariable: 'GIT_TOKEN'
                                )
                        ],
                ]
        ]
]

if(RUN_CONFTEST){
    deployTemplate = deployTemplate + confTest
}

def pleaseDeploy = deployTemplate + [
        branchPattern   : 'dev|test|main|.*|feature.*|hotfix.*',
        sdlcEnvironment : env.ENV,
        isProductionDeployment: env.ENV == "prod",
]

def gameDay = [
        testType : 'plz',
        typeOverride: 'integration',
        runInAWS: true,
        cloudName: "${eks_gatekeeper_cloud_name}",
        aws:
                [
                        cloudServiceAccountName: "${cloudServiceAccountName}",
                        targetAccount: "${targetAccount}",
                        accountRoleName: "${accountRoleName}",
                        region: 'us-east-1'
                ],
        verbosityFlag: '-vvvv',
        branchPattern   : 'dev|test|main|feature.*|hotfix.*',
        labels   : [
                'gameday',
        ],
        sdlcEnvironment : "${sdlcEnvName}",
        container: container,
        extraTestArgs: "${MODULE_NAME} ${ENV} ${REGION_NAME}",
        runBeforeDeployment: false,
        isProductionDeployment: env.ENV == "prod",
        extraCredentials: [
                usernamePassword(
                        credentialsId: 'SVPDEVOP-CIG-CLONEA_UserPw',
                        usernameVariable: 'GIT_USER',
                        passwordVariable: 'GIT_TOKEN'
                )
        ],
]

if (!RUN_BUILD) {
    buildPhase.branchPattern = "ignored_branch_not_to_run"
}

if (!RUN_DEPLOY) {
    pleaseDeploy.branchPattern = "ignored_branch_not_to_run"
}

if (!RUN_GAMEDAY) {
    gameDay.branchPattern = "ignored_branch_not_to_run"
}

if (env.ENV == "prod" && RUN_DEPLOY){
    pleaseDeploy = pleaseDeploy + [
        ticket: [
            ticketType: 'Servicenow',
            title: "${SNOW_TICKET_NO}",
        ]
    ]
}

if (!RUN_BUILD && !RUN_DEPLOY && !RUN_GAMEDAY) {
    def stars = "******************************************************************************************************************************************\n"
    starts = stars + stars +stars
    echo(starts+"WARNING: No stages defined because BUILD, DEPLOY nor GAMEDAY were not selected in the build parameters.\n" +
            "If this was the first build on the branch then please reload the job page and use \"Build with Parameters\"\n"+starts)
}

ansiColor('xterm') {
    cignaBuildFlow {
        additionalProperties = [
                parameters([
                        booleanParam(
                                defaultValue: true,
                                name: 'BUILD',
                                description: 'If true then run Build and run tests for this build.'
                        ),
                        booleanParam(
                                defaultValue: true,
                                name: 'DEPLOY',
                                description: 'If true then run terraform apply for this build.'
                        ),
                        choice(
                                choices: ['plan_all', 'destroy_all', 'apply_all', 'rollback_all'],
                                description: 'Please build alias to run as described in your product\'s .plzconfig file',
                                name: 'PLZ_ALIAS'
                        ),
                        booleanParam(
                                name: 'ASSIGN_TAG',
                                defaultValue: false,
                                description: 'If true then use the text of the LIQUIBASE_TAG field as the tag to assign on the liquibase.\nThis must be true for Rollback action.'
                        ),
                        string(
                                name: 'LIQUIBASE_TAG',
                                defaultValue: 'default',
                                description: 'The tag used by liquibase commands such as rollback.\n For "apply_all" alias, use "default" to automatically use the hash code of the last git commit, or input your own tag.\nFor "rollback_all" alias, the "default" is invalid that you must input the tag you want to rollback.'
                        ),
                        choice(
                                choices: ['all', 'tdv_ddl', 'tdv_dml', 'dml_with_dag', 'stored_proc'],
                                description: 'Operations type to deploy. Defaults to all.',
                                name: 'OPS_TYPE'
                        ),
                        choice(
                                choices: ['pipeline_infra'],
                                description: 'Module name used when apply, destroy or plan is used. NOT used for apply_all, destroy_all, plan_all',
                                name: 'MODULE_NAME'
                        ),
                        choice(
                                choices: ['us-east-1'],
                                description: 'Name of the region (us-east-1).',
                                name: 'REGION_NAME'
                        ),
                        string(
                                name: 'SNOW_TICKET_NO',
                                defaultValue: '',
                                description: 'Service Now ticket number required for prod release'
                        )
                ])
        ]
        cloudName = "${cloud_name}"
        gitlabConnectionName = 'cigna_github'
        phases = [buildPhase, pleaseDeploy]
    }
}