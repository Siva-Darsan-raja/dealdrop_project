pipeline {
    agent any

    environment {
        SCANNER_HOME = tool 'sonar-scanner'
        DOCKER_IMAGE = "siva2234/dealdrop:${BUILD_NUMBER}"
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
                // Securely bind the secret file to a temporary path variable
                withCredentials([file(credentialsId: "${SECRET_FILE_ID}", variable: 'SECRET_PATH')]) {
                    script {
                        // Use BuildKit by setting DOCKER_BUILDKIT=1
                        // id=app_config must match the id in the Dockerfile
                        
                        sh 'docker build --secret id=app_config,src=$SECRET_PATH -t ${DOCKER_IMAGE} --load .'
                    }
                }
            }
        }

        stage('DOCKER PUSH') {
            steps {
                script {
                    def dockerImage = docker.image("${DOCKER_IMAGE}")
                    withDockerRegistry(credentialsId: 'docker-cred') {
                        dockerImage.push()
                    }
                }
            }
        }

         stage('TRIVY VULNARABILITY SCAN') {
            steps {
                sh 'trivy image ${DOCKER_IMAGE}'
            }
         }

    }
}
