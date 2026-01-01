pipeline {
    agent any

    environment {
        SCANNER_HOME = tool 'sonar-scanner'
        IMAGE_NAME = 'dealdrop'
        ECR_REPO = '313712213829.dkr.ecr.ap-south-1.amazonaws.com/dealdrop-app'
        AWS_REGION = 'ap-south-1'

    }
    stages {
        stage('GIT CHECKOUT') {
            steps {
                checkout scm
            }
        }

        stage('SONAR ANALYSIS') {
            steps {
                sh '$SCANNER_HOME/bin/sonar-scanner -Dsonar.host.url=http://localhost:9000 -Dsonar.login=squ_9784a55c8904065b74673919d655e98f6cb7a07d -Dsonar.projectKey=dealdrop-application -Dsonar.projectName=dealdrop-application -Dsonar.sources=.'
            }
        }

        stage('DOCKER BUILD') {
            steps {
                echo "Using updated Image tag ${IMAGE_NAME}:${BUILD_NUMBER}"
                sh 'docker build -t ${IMAGE_NAME}:${BUILD_NUMBER} .'
                sh 'docker tag ${IMAGE_NAME}:${BUILD_NUMBER} ${IMAGE_NAME}:latest'
            }
        }


        stage('TRIVY VULNARABILITY SCAN') {
            steps {
                sh 'trivy image ${IMAGE_NAME}:${BUILD_NUMBER} > report.txt'
            }
        }

        stage('Push to ECR') {
            steps {
                withCredentials([[$class: 'AmazonWebServicesCredentialsBinding', credentialsId: 'aws-cred']]) {
                    sh '''
                        aws ecr get-login-password --region $AWS_REGION | docker login --username AWS --password-stdin $ECR_REPO
                        docker tag $IMAGE_NAME:$BUILD_NUMBER $ECR_REPO:$BUILD_NUMBER
                        docker push $ECR_REPO:$BUILD_NUMBER

                        docker tag $IMAGE_NAME:$BUILD_NUMBER $ECR_REPO:latest
                        docker push $ECR_REPO:latest
                    '''
                }
            }
         }

        stage('Update GitOps Repo') {
            steps {
                withCredentials([usernamePassword(
                    credentialsId: 'git-pass',
                    usernameVariable: 'GIT_USERNAME',
                    passwordVariable: 'GIT_PASSWORD'
                )]) {
                    sh '''
                        rm -rf gitops-repo
                        git clone https://$GIT_USERNAME:$GIT_PASSWORD@github.com/Siva-Darsan-raja/dd-deploymentrepo.git gitops-repo

                        cd gitops-repo/k8s || exit 1

                        echo "Before update:"
                        grep image Deployment.yaml

                        sed -i "s#image: ${ECR_REPO}:.*#image: ${ECR_REPO}:${BUILD_NUMBER}}#g" Deployment.yaml

                        echo "After update:"
                        grep image Deployment.yaml

                        git config user.email "sivadarsan48@gmail.com"
                        git config user.name "Siva Darsan"

                        git add Deployment.yaml
                        git commit -m "Update the deployment file" || echo "No changes to commit"
                        git push origin main
                    '''
                }
            }
        }
}
}
