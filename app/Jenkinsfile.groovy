pipeline {
    agent {
        docker {
            image 'jmeraq/tools:latest'
            args '-u root:root'
        }
    }

    environment {
        CI = 'true'
        IMAGE_OWNER          = "jmeraq"
        REPOSITORY_BASE_NAME = """${sh(
                returnStdout: true,
                script: 'git config --get remote.origin.url | cut -d "/" -f 5 | cut -d "." -f 1 | tr -d \'[[:space:]]\'').trim()}"""
    }


    stages {
        stage('Init'){
            stages{
                stage('Init: Confirm Deploy to Producction') {
                    when {
                        anyOf { branch 'master' }
                    }
                    steps {
                        timeout(time: 5, unit: 'MINUTES') {
                            input "Really want to deploy to production?"
                        }
                    }
                }
                stage('Init: Define Version and Variables') {
                    steps {
                        timeout(time: 5, unit: 'MINUTES') {
                            script {
                                VERSION     = new Date().format( 'yyyy.MM.dd.H.m.s' )
                                if (env.BRANCH_NAME == 'master') {
                                    ENVIRONMENT = "production"
                                    VERSION     = "${ENVIRONMENT}-${VERSION}"
                                } else {
                                    ENVIRONMENT = "demo"
                                    VERSION     = "${ENVIRONMENT}-${VERSION}"
                                }
                            }
                        }
                    }
                }
            }
        }

        stage('Build: Image'){
            steps{
                withDockerRegistry([credentialsId: "docker-hub-registry", url: "https://index.docker.io/v1/"]){
                    sh "docker build -t ${IMAGE_OWNER}/microservice-bp:${VERSION} -f app/Dockerfile ."
                    sh "docker push ${IMAGE_OWNER}/microservice-bp:${VERSION}"
                    sh "docker rmi ${IMAGE_OWNER}/microservice-bp:${VERSION}"
                }
            }
        }

        stage('Deploy: Get IPs') {
            steps {
                withCredentials([[$class: 'AmazonWebServicesCredentialsBinding', credentialsId: 'aws_credential', accessKeyVariable: 'AWS_ACCESS_KEY_ID', secretKeyVariable: 'AWS_SECRET_ACCESS_KEY']]) {
                    sh "aws ec2 describe-instances --region us-east-1 --filters 'Name=tag:Name,Values=${ENVIRONMENT}-microservice-bp' 'Name=instance-state-name,Values=running' --query 'Reservations[*].Instances[*].[PublicIpAddress]' --output text >> app/ips.txt"
                    sh "cat app/ips.txt"
                }
            }
        }

        stage('Config: SSH'){
            steps{
                withCredentials([sshUserPrivateKey(credentialsId: "microservice_bp_private_key", keyFileVariable: 'keyfile')]) {
                    sh """
                        mkdir /root/.ssh
                        touch /root/.ssh/known_hosts
                        touch /root/.ssh/id_rsa
                        ssh-keyscan github.com >> /root/.ssh/known_hosts
                        cat ${keyfile} >> /root/.ssh/id_rsa
                        chmod 400 /root/.ssh/id_rsa
                    """
                }
            }
        }

        stage ('Deploy: Depoly Microservice') {
            steps {
                sh """
                    chmod 777 -R app/deploy.sh
                    ./app/deploy.sh
                """
            }
        }

        stage ('Deploy: Publish Tag Git') {
            steps {
                sh """
                    git remote set-url origin git@github.com:${IMAGE_OWNER}/${REPOSITORY_BASE_NAME}.git
                    git config --global user.email "jenkins@detic.ec"
                    git config --global user.name "Jenkins"
                    git tag -a "microservice-bp-${VERSION}" -m "microservice-bp-${VERSION}"
                    git push origin "${VERSION}"
                """
            }
        }
    }
}