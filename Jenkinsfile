def TAG_SELECTOR = "UNINTIALIZED"
pipeline {
    agent any


    environment {
        NAME = readMavenPom().getArtifactId()
        NAME_NETWORK_REC = 'sirh-network-rec'
        NAME_NETWORK_PROD = 'cdc_prod'
        EMAIL = 'ibrahima.diop@afrilins.net'
        PROJECT_PORT_REC = '8082'
        PORT_EXPOSE_REC = '28081'

        imageName = 'ndoudy24/backendgestetudiant'
        //registryCredentials = "admin"
        // registry = "192.168.1.38:8081/"
        dockerImage = ''
//
        dockerHubRegistry = "https://registry.hub.docker.com"



    }

    options {
        timeout(time: 120, unit: 'MINUTES')
    }

    stages {

        stage('Clean Package') {
            steps {
                sh  "/usr/share/maven/bin/mvn clean package -DskipTests"
                stash includes: 'target/*', name: 'target'
                script {
                    TAG_SELECTOR = readMavenPom().getVersion()
                }
                echo("TAG_SELECTOR====================>${TAG_SELECTOR}")

            }
        }

        stage('Units Tests') {
            when { branch 'recette' }
            steps {
                sh '/usr/local/maven/bin/mvn clean verify -Dmaven.test.skip=true'
            }
            post {
                success {
                    junit 'target/surefire-reports/**/*.xml'
                }
            }
        }


        // Uploading  jar into Nexus Registry
        /*stage('Snapshot On Nexus') {
            when { branch 'develop' }
            steps {
                sh  "/usr/local/maven/bin/mvn deploy -DskipTests"
            }
        }*/

        // Building Docker images

         stage('Building image') {
         steps{
         script {
         dockerImage = docker.build imageName
         }
         }
         }


        //

         stage('Dockerize: Pushing Image docker hub') {
         environment {
         registryCredential = 'DOCKER_CREDENTIALS'
         }
         steps{
         script {
         docker.withRegistry( dockerHubRegistry,registryCredential){
         dockerImage.push("${TAG_SELECTOR}")
         }
         }
         }
         }


        stage('Trigger ManifestUpdate') {
            steps {
                    build job: 'updateManifestFiles', parameters: [string(name: 'DOCKERTAG', value: TAG_SELECTOR)]
            }

        }
        //jenkins k8S





    }

    post {

        changed {
            emailext attachLog: true, body: '$DEFAULT_CONTENT', subject: '$DEFAULT_SUBJECT',  to: '${EMAIL}'
        }
        failure {
            emailext attachLog: true, body: '$DEFAULT_CONTENT', subject: '$DEFAULT_SUBJECT',  to: '${EMAIL}'
        }

    }
}
