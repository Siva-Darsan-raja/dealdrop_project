pipeline {
    agent any

    environment {
        SCANNER_HOME = tool 'sonar-scanner'
        DOCKER_IMAGE = "siva2234/dealdrop:${BUILD_NUMBER}"
        SECRET_FILE_ID = 'my-secret-file'

    }
    
    stages {
        stage('GIT CHECKCOUT') {
            steps {
                 checkout scm
            }
        }

        stage('SONAR ANALYSIS') {
            steps {
                sh '$SCANNER_HOME/bin/sonar-scanner -Dsonar.host.url=http://localhost:9000 -Dsonar.login=squ_c0f4efdf543f68d9b1c326ae50afd4a5e8d7e417 -Dsonar.projectKey=dealdrop-application -Dsonar.projectName=dealdrop-application -Dsonar.sources=.'
            }
        }

        stage('Docker Build') {
            steps {
                // Securely bind the secret file to a temporary path variable
                withCredentials([file(credentialsId: "${SECRET_FILE_ID}", variable: 'SECRET_PATH')]) {
                    script {
                        // Use BuildKit by setting DOCKER_BUILDKIT=1
                        // id=app_config must match the id in the Dockerfile
                        sh 'DOCKER_BUILDKIT=1 docker buildx build --secret id=app_config,src=$SECRET_PATH -t ${DOCKER_IMAGE} --load .'
                        sh "docker tag ${DOCKER_IMAGE}:${env.BUILD_NUMBER} ${DOCKER_IMAGE}:${env.BUILD_NUMBER}"
                    }
                }
            }
        }

        stage('Docker Push') {
            steps {
                script {
                    def dockerImage = docker.image("${DOCKER_IMAGE}")
                    withDockerRegistry(credentialsId: 'docker-cred') {
                        dockerImage.push()
                    }
                }
            }
        }

         stage('trivy vulnerability scan') {
            steps {
                sh 'trivy image ${DOCKER_IMAGE}'
            }
         }

    }
}
