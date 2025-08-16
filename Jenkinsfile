pipeline {
  agent any

  tools {
    jdk 'jdk17'          // 🔁 Must match Jenkins → Global Tool Configuration
    maven 'Maven3'       // 🔁 Same here
  }

  environment {
    NEXUS_HOST = '43.205.205.27'
    IMAGE_NAME = 'demoapp'
    IMAGE_TAG  = 'v1.0.0'
    DOCKER_REPO = "${NEXUS_HOST}:5000"
  }

  stages {
    stage('Checkout Code') {
      steps {
        git 'https://github.com/jasiq-labs-admin/demoapp.git'
      }
    }

    stage('Build JAR') {
      steps {
        sh 'mvn clean package -DskipTests'
      }
    }

    stage('Deploy to Nexus (Maven)') {
      steps {
        // ✅ Inject settings.xml with Nexus credentials
        configFileProvider([configFile(fileId: 'global-maven-settings', variable: 'MAVEN_SETTINGS')]) {
          sh 'mvn deploy -DskipTests -s $MAVEN_SETTINGS'
        }
      }
    }

    stage('Build Docker Image') {
      steps {
        sh """
          docker build -t ${IMAGE_NAME}:${IMAGE_TAG} .
          docker tag ${IMAGE_NAME}:${IMAGE_TAG} ${DOCKER_REPO}/${IMAGE_NAME}:${IMAGE_TAG}
        """
      }
    }

    stage('Push to Nexus Docker Registry') {
      steps {
        withCredentials([usernamePassword(credentialsId: 'nexus-creds', usernameVariable: 'NEXUS_USER', passwordVariable: 'NEXUS_PASS')]) {
          sh """
            echo \$NEXUS_PASS | docker login ${DOCKER_REPO} -u \$NEXUS_USER --password-stdin
            docker push ${DOCKER_REPO}/${IMAGE_NAME}:${IMAGE_TAG}
          """
        }
      }
    }
  }

  post {
    success {
      echo '✅ Build and Deployment to Nexus succeeded.'
    }
    failure {
      echo '❌ Build failed. Check the console output for errors.'
    }
  }
}
