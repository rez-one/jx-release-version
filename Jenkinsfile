#!groovy
pipeline {
    agent none
    environment {
        NEXUS_REPO = credentials('nexus-repo-credentials')
        GITHUB_AUTH_TOKEN = credentials('jx-release-version-github-token')
        GITHUB_REPO = 'jx-release-version'
    }
    options {
        skipDefaultCheckout()
        timeout(time: 1, unit: 'HOURS')
    }
    stages {
        stage('CI Build') {
            agent {
                label 'linux&&jdk8'
            }
            when {
                not {
                    branch 'master'
                }
            }
            steps {
                checkout scm
                sh 'make snapshot'
                archiveArtifacts 'bin/*'
                milestone label: 'build', ordinal: 1
            }
        }
        stage('Release Build') {
            agent {
                label 'linux&&jdk8'
            }
            environment {
                DOCKER_HUB_AUTH = credentials('docker-hub-clank')
            }
            when {
                branch 'master'
            }
            steps {
                checkout scm
                sshagent(['jenkins-worker-ssh-key']) {
                    sh "docker login --username ${DOCKER_HUB_AUTH_USR} --password ${DOCKER_HUB_AUTH_PSW}"
                    sh 'make release'
                }
                milestone label: 'build', ordinal: 2
            }
        }
    }
    post {
        aborted {
            slackSend channel: "#ci-utils",
                    message: "${GITHUB_REPO} <${env.BUILD_URL}|${env.JOB_BASE_NAME} - ${env.BUILD_DISPLAY_NAME}>: build aborted"
        }
        failure {
            slackSend channel: "#ci-utils", color: 'danger',
                    message: "${GITHUB_REPO} <${env.BUILD_URL}|${env.JOB_BASE_NAME} - ${env.BUILD_DISPLAY_NAME}>: build failed"
        }
        success {
            slackSend channel: "#ci-utils", color: 'good',
                    message: "${GITHUB_REPO} <${env.BUILD_URL}|${env.JOB_BASE_NAME} - ${env.BUILD_DISPLAY_NAME}>: build success"
        }
        unstable {
            slackSend channel: "#ci-utils", color: 'warning',
                    message: "${GITHUB_REPO} <${env.BUILD_URL}|${env.JOB_BASE_NAME} - ${env.BUILD_DISPLAY_NAME}>: build unstable"
        }
    }
}
