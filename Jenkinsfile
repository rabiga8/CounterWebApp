pipeline {
    agent any
    environment {
        DOCKER_CREDENTIALS_ID = '5aec70f1-576f-4bbf-8388-65b31ae0113c'
        DOCKER_IMAGE_NAME = 'rabiga8/group-image'
    }
	stage('Initialize') {
		sh '''
		echo "PATH = %PATH%"
		echo "M2_HOME = %M2_HOME%"
		'''
	}
	
	// stage('SourceCodeMgmt') {
	// 	git changelog: false, poll: false, url: 'https://github.com/mattareddy357/CounterWebApp.git'
	// }
	
	// stage('Build and Package') {
	//     build("maven 3.5.4", "package");
	// }
	stage('Build Maven') {
		steps {
			withMaven(globalMavenSettingsConfig: '', 
					  jdk: '', maven: 'maven', 
					  mavenSettingsConfig: '', 
					  traceability: true) {
				sh 'mvn clean package'
			}
		}
		post {
			success {
				echo "Archiving artifacts"
				archiveArtifacts artifacts: '**/target/*.war'
			}
		}
	}
	
	stage('SonarQube analysis') {
		checkCodeQuality("sonar");
	}
	
	stage('Docker Build and Publish') {
		buildAndPush('mattareddy357', "${env.JOB_NAME}", 'v1');
	}
	
	stage('Deploy to OpenShift') {
		deployOpenShift('mattareddy357', "${env.JOB_NAME}", 'v1', "${env.BUILD_NUMBER}", "piab-demo");
	}
}

def build(mvnVersion, task){
	def mvnHome = tool name: "${mvnVersion}"
	env.PATH = "${mvnHome}/bin:${env.PATH}"
	sh "mvn clean ${task}"
}

def checkCodeQuality(sonarVersion){
	withSonarQubeEnv("${sonarVersion}") { // SonarQube taskId is automatically attached to the pipeline context
		sh "mvn org.sonarsource.scanner.maven:sonar-maven-plugin:3.3.0.603:sonar" 
	}
}

def buildAndPush(registryID, imageName, version){
	def app
	try {
		app = docker.build("${registryID}/${imageName}")
		docker.withRegistry('https://registry.hub.docker.com', 'docker-credentials') {
			sh "echo ${version}.${env.BUILD_NUMBER} "
			app.push("${version}.${env.BUILD_NUMBER}")
		}
	} catch (error){
		sh 'echo "Not able to build and push docker image ${error}"'
	}
}

def deployOpenShift(registryID, imageName, version, buildNo, namespace){

	env.PATH = "/var/lib/jenkins/tools/:${env.PATH}"

	sh "oc login $URL_OS_TEST --token=$TOKEN_OS_TEST --insecure-skip-tls-verify"
	
	output = sh(script: "oc tag --source=docker ${registryID}/${imageName}:${version}.${buildNo} ${imageName}:${version}.${buildNo} -n ${namespace}", returnStdout: true)
	println output
	
	sh "oc import-image ${imageName}:${version}.${buildNo} --insecure -n ${namespace} || true"
	
	try {
		output = sh(script: "oc new-app --name ${imageName}-${version} --image-stream=${namespace}/${imageName}:${version}.${buildNo} -n ${namespace}", returnStdout: true)
		println output
		
		output = sh(script: "oc expose service/${imageName}-${version} --path=/wso2apim-demo --hostname=${imageName}-${version}-test.magellancloud.com -n ${namespace}", returnStdout: true)
		println output
	} catch (error){
		output = sh(script: "oc deploy ${imageName}-${version} --latest -n ${namespace} || true", returnStdout: true)
		println output
	}
}
