pipeline {
    agent any

    environment {
        SCANNER_HOME = tool 'sonar-scanner'
        DOCKER_IMAGE = "siva2234/dealdrop"
        SECRET_FILE_ID = 'my-secret-file'
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
                    script {
                        sh 'docker build -t ${DOCKER_IMAGE}:${BUILD_NUMBER} .'
                    }
                }
        }

        stage('DOCKER PUSH') {
            steps {
                script {
                    def dockerImage = docker.image("${DOCKER_IMAGE}:${BUILD_NUMBER}")
                    withDockerRegistry(credentialsId: 'docker-cred') {
                        dockerImage.push()
                    }
                }
            }
        }

        stage('TRIVY VULNARABILITY SCAN') {
            steps {
                sh 'trivy image ${DOCKER_IMAGE}:${BUILD_NUMBER}'
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

                        sed -i "s#image: ${DOCKER_IMAGE}:.*#image: ${DOCKER_IMAGE}:${BUILD_NUMBER}#g" Deployment.yaml

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
