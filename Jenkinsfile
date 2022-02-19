@Library("shared-library") _

pipeline {
    agent {
        ecs {
            inheritFrom 'builds'
        }
    }
    parameters{
        choice(
                name: 'TARGET_WORKSPACE',
                choices: getEnvironmentList(account:account_name),
                description: 'Infra deployment workspace'
        )
        booleanParam(name: 'APPLY', defaultValue: false, description: 'The infra will be applied to the chosen workspace.')
        booleanParam(name: 'DESTROY', defaultValue: false, description: 'The infra will be destroyed in the chosen workspace.')
    }
    environment {
        REGION = 'us-west-2'
        ACCOUNT_NAME = credentials('account_name')
    }
    stages {
        stage("Initialize Workspace"){
            steps{
                dir('terraform'){
                    initWorkspace(
                            repo:"${env.GIT_URL}",
                            account:"${env.ACCOUNT_NAME}",
                            env: "${params.TARGET_WORKSPACE}"
                    )
                }
            }
        }
        stage("Validate & Plan") {
            steps {
                dir('terraform') {
                    validateAndPlan(
                            account:"${env.ACCOUNT_NAME}",
                            env: "${params.TARGET_WORKSPACE}"
                    )
                }
            }
        }
        stage("Apply") {
            steps {
                dir('terraform') {
                    terraformApply(
                            account:"${env.ACCOUNT_NAME}",
                            apply: "${params.APPLY}",
                            branch: env.BRANCH_NAME,
                            env: "${params.TARGET_WORKSPACE}"
                    )
                }
            }
        }
        stage("Terraform destroy") {
            when { expression {(params.APPLY == true && params.DESTROY == true) } }
            steps {
                sh "terraform destroy -var 'env=${env.ACCOUNT_NAME}' -auto-approve"
            }
        }
    }
}
