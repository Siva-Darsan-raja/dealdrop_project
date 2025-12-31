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

        stage('Update Deployment File') {
            environment {
                GIT_REPO_NAME = 'dd-deploymentrepo'
                GIT_USER_NAME = 'Siva-Darsan-raja'
            }
            steps {
                withCredentials([string(credentialsId: 'github', variable: 'GITHUB_TOKEN')]) {
                    sh '''
                    git config user.email "sivadarsan48@gmail.com"
                    git config user.name "Siva Darsan"
                    BUILD_NUMBER=${BUILD_NUMBER}
                    sed -i "s/replaceImageTag/${BUILD_NUMBER}/g" k8s/deployment.yml
                    git add k8s/deployment.yml
                    git commit -m "Update deployment image to version ${BUILD_NUMBER}"
                    git push https://${GITHUB_TOKEN}@github.com/${GIT_USER_NAME}/${GIT_REPO_NAME} HEAD:main
                '''
                }
            }
        }
    }
}
