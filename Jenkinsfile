pipeline {
    agent any 


    parameters {
        choice (
            name: 'TF_ACTION',
            choices :['plan','apply', 'destroy'],
            descrption: 'Select which Terraform action to run'
        )
    }
    
    environment {
        
        AWS_SECRET_ACCESS_KEY = credentials ('aws-secret-access-key')
        AWS_ACCESS_KEY_ID = credentials ('aws-access-key-id')
        AWS_DEFAULT_REGION = 'eu-west-1'
    }
    
    stages {
        stage ('checkout') {
            steps {
                git branch: 'main', 
                url: 'https://github.com/techbleat/class2025iac.git'
            }
        }
        stage ('terraform init') {
            steps {
                dir ('terraform') {
                    sh ' terraform init'
                }
            }
        }

        stage ('terraform validate') {
            steps {
                dir ('terraform') {
                    sh ' terraform validate'
                }
            }
        } 
        
        stage ('terraform plan') {
            when  {
                expression { params.TF_ACTION == 'plan'}
            }
            steps {
                dir ('terraform') {
                    sh ' terraform plan'
                }
            }
        } 

        stage ('terraform apply') {
         when  {
                expression { params.TF_ACTION == 'apply'}
            }
            steps {
                dir ('terraform') {
                    sh ' terraform apply -auto-approve'
                }
            }
        } 

        stage ('terraform destroy') {
         when  {
                expression { params.TF_ACTION == 'destroy'}
            }
            steps {
                dir ('terraform') {
                    sh ' terraform destroy apply -auto-approve'
                }
            }
        } 
    
    }
}
