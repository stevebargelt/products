#!/usr/bin/env groovy

node ('aspdotnetcore_products') {
	stage('Build') {    
		git url: 'https://github.com/stevebargelt/products'
		sh 'dotnet restore'
		sh 'dotnet test test/products.tests/project.json'
	}
	stage('Publish') {
		sh 'dotnet publish src/products/project.json -c release -o $(pwd)/publish/'
		echo "Building: ${env.BUILD_TAG} || Build Number: ${env.BUILD_NUMBER}"
		sh "docker build -t abs-registry.harebrained-apps.com/products:${env.BUILD_NUMBER} publish"
		withCredentials([usernamePassword(credentialsId: 'absadmin', passwordVariable: 'REGISTRY_PASSWORD', usernameVariable: 'REGISTRY_USER')]) {
			sh "docker login abs-registry.harebrained-apps.com -u='${REGISTRY_USER}' -p='${REGISTRY_PASSWORD}'"
		}
    	sh "docker push abs-registry.harebrained-apps.com/products:${env.BUILD_NUMBER}"
	}
	stage('ABS-Test') {
		docker.withServer('tcp://abs.harebrained-apps.com:2376', 'dockerTLS') {
			sh "docker pull abs-registry.harebrained-apps.com/products:${env.BUILD_NUMBER}"
			sh "docker stop products || true && docker rm products || true"
			sh "docker run -d --name products -p 8002:80 abs-registry.harebrained-apps.com/products:${env.BUILD_NUMBER}"
		}
	}
} //node