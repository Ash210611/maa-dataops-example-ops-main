# Define a hashtable equivalent to the 'buildPhase' map in Jenkins
$buildPhase = @{
    BuildType = 'plz'
    Container = @{
        Image = 'registry.cigna.com/enterprise-devops/aws-d-megatainer'
        Version = '1.0.14-2'
        CPU = 2000
        Memory = 4000
    }
    BranchPattern = 'dev|test|main|feature.*|hotfix.*'
    CloudName = 'evernorth-qp-gov-solns-openshift-devops1'
    SDLCEnvironment = 'Non-Prod'
    IsStashEnabled = $false
    StashEnabled = $false
    RunInAWS = $false
    CheckmarxEnabled = $false
    SonarEnabled = $false
    ExtraCredentials = @{
        GIT_USER = 'example_user'
        GIT_TOKEN = 'example_token'
    }
    Checkmarx = @{
        Debug = $true
        CredentialsId = 'checkmarx_credentials'
        Settings = @{
            CX_PROJECT_TEAM_NAME = 'MEDICARE_ADVANTAGE_ANALYTICS'
            CX_PROJECT_NAME = 'maa-dataops-example-solutions'
            CX_SCAN_COMMENT = "Branch: {0} - Build: {1}" -f $Env:BRANCH_NAME, $Env:BUILD_NUMBER
            CX_EXCLUDE_FOLDER_LIST = 'plz-out, commands, test_resources, third_party, aws_glue_libs, tests'
        }
    }
    SonarQube = @{
        CredentialsId = 'sonarqube-service-id'
        ScannerProperties = @{
            'sonar.projectKey' = 'maa-dataops-example-solutions'
            'sonar.projectName' = 'maa-dataops-example-solutions'
            'sonar.projectBaseDir' = 'module/aws/'
            'sonar.sources' = 'python_code/src'
            'sonar.tests' = 'python_code/tests'
            'sonar.python.coverage.reportPaths' = 'python_code/reports'
        }
    }
}

# Function to simulate processing of buildPhase settings
function ProcessBuildPhase($buildPhase) {
    Write-Host "Processing build for type:" $buildPhase.BuildType
    Write-Host "Using container:" $buildPhase.Container.Image
    Write-Host "Branch Pattern:" $buildPhase.BranchPattern
    Write-Host "Cloud Name:" $buildPhase.CloudName
    Write-Host "SDLC Environment:" $buildPhase.SDLCEnvironment

    if ($buildPhase.RunInAWS) {
        Write-Host "Running in AWS environment..."
        # Simulate AWS specific operations
    } else {
        Write-Host "Not running in AWS environment."
    }

    if ($buildPhase.CheckmarxEnabled) {
        Write-Host "Checkmarx scan enabled."
        # Simulate Checkmarx scan operation
    }

    if ($buildPhase.SonarEnabled) {
        Write-Host "SonarQube scan enabled."
        # Simulate SonarQube scan operation
    }

    # Output extra credential information for debugging
    Write-Host "Credentials:" $buildPhase.ExtraCredentials.GIT_USER
}

# Call the function with the buildPhase settings
ProcessBuildPhase -buildPhase $buildPhase
