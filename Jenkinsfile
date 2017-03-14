#!/usr/bin/env groovy

node ('bargelt_dotnetcore_myretail') {
	stage('Build') {    
		git url: 'https://github.com/stevebargelt/myRetail'
		sh 'dotnet restore'
		sh 'dotnet test test/myRetail.Tests/project.json'
	}
	stage('Publish') {
		sh 'dotnet publish src/myRetail/project.json -c release -o $(pwd)/publish/'
		echo "Building: ${env.BUILD_TAG} || Build Number: ${env.BUILD_NUMBER}"
		sh "docker build -t abs-registry.harebrained-apps.com/myretail:${env.BUILD_NUMBER} publish"
		withCredentials([usernamePassword(credentialsId: 'absadmin', passwordVariable: 'REGISTRY_PASSWORD', usernameVariable: 'REGISTRY_USER')]) {
			sh "docker login abs-registry.harebrained-apps.com -u='${REGISTRY_USER}' -p='${REGISTRY_PASSWORD}'"
		}
    	sh "docker push abs-registry.harebrained-apps.com/myretail:${env.BUILD_NUMBER}"
	}
	stage('ABS-Test') {
		docker.withServer('tcp://abs.harebrained-apps.com:2376', 'dockerTLS') {
			sh "docker pull abs-registry.harebrained-apps.com/myretail:${env.BUILD_NUMBER}"
			sh "docker stop mongo || true && docker rm mongo || true"
			sh "docker run --name mongo -p 27017:27017 -v $PWD/data:/data/db -d mongo"
			sh "docker stop myRetail || true && docker rm myRetail || true"
			sh "docker run -d --name myRetail -p 8001:80 abs-registry.harebrained-apps.com/myretail:${env.BUILD_NUMBER}"
			sh "docker build -t mongo-seed mongo-seed"
			sh "docker run --rm --name mongo-seed --link mongo:mongo mongo-seed"
		}
	}
	stage('Prod') {
		docker.withServer('tcp://bargelt.bargelt.com:2376', 'bargeltDockerTLS') {
			docker.withRegistry('https://abs-registry.harebrained-apps.com/', 'absadmin') {
				sh "docker pull abs-registry.harebrained-apps.com/myretail:${env.BUILD_NUMBER}"
			}
			sh "docker stop mongo || true && docker rm mongo || true"
			sh "docker run --name mongo -p 27017:27017 -v $PWD/data:/data/db -d mongo"
			sh "docker stop myRetail || true && docker rm myRetail || true"
			sh "docker run -d --name myRetail -p 80:80 --link mongo:mongo abs-registry.harebrained-apps.com/myretail:${env.BUILD_NUMBER}"
			sh "docker build -t mongo-seed mongo-seed"
			sh "docker run --rm --name mongo-seed --link mongo:mongo mongo-seed"
		}
	}
} //node