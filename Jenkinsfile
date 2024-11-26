pipeline {
    agent any
    
    environment {
        DOCKER_REGISTRY = 'docker.io'
        KUBE_NAMESPACE = 'default'
        IMAGE_TAG = '${BUILD_NUMBER}'
        AWS_REGION = 'us-east-1'
        EKS_CLUSTER_NAME = 'docker-k8s'
    }
    
    stages {
        stage('Checkout code') {
            steps {
                git branch: 'main', url: 'https://github.com/zorroborrolol/Dockers-k8s.git', credentialsId: 'github-creds'
            }
        }

        stage('Build docker image') {
            steps {
                script {
                    withCredentials([usernamePassword(credentialsId: 'docker-creds', usernameVariable: 'DOCKER_USERNAME', passwordVariable: 'DOCKER_PASSWORD')]) {
                        sh '''
                        echo "Logging into Docker Hub..."
                        docker login -u $DOCKER_USERNAME -p $DOCKER_PASSWORD
                        echo 'Building Docker image'
                        docker build -t jk0909/flask-web-app:${BUILD_NUMBER} .
                        '''
                    }
                }
            }
        }

        stage('Push the artifacts') {
            steps {
                script {
                    sh '''
                    echo 'Pushing Docker image to Docker Hub'
                    docker push jk0909/flask-web-app:${BUILD_NUMBER}
                    '''
                }
            }
        }

        stage('Update Deployment YAML') {
            steps {
                script {
                    withCredentials([usernamePassword(credentialsId: 'github-creds', usernameVariable: 'GIT_USERNAME', passwordVariable: 'GIT_PASSWORD')]) {
                        sh '''
                        echo 'Updating deployment YAML with the new Docker image tag...'
                        # sed -i '' "s|image: jk0909/flask-web-app|image: jk0909/flask-web-app:${BUILD_NUMBER}|g" deployment.yaml
                        sed -i "s|image: jk0909/flask-web-app:[^[:space:]]*|image: jk0909/flask-web-app:${BUILD_NUMBER}|g" deployment.yaml
                        # sed -i "s/replacetag/${BUILD_NUMBER}/g" deployment.yaml
                        echo 'Updated deployment.yaml:'
                        cat deployment.yaml
                        git config --global user.email "zorroborrolol@gmail.com"
                        git config --global user.name "${GIT_USERNAME}"
                        git add deployment.yaml
                        git commit -m "Update deployment YAML with build number ${BUILD_NUMBER}"
                        git push https://${GIT_USERNAME}:${GIT_PASSWORD}@github.com/zorroborrolol/Dockers-k8s.git HEAD:main
                        '''
                    }
                }
            }
        }

        stage('Apply Deployment to Kubernetes') {
            steps {
                script {
                    echo 'Installing kubectl and applying Kubernetes manifests...'
                    withAWS(credentials: 'aws-creds', region: "${AWS_REGION}") {
                        sh '''
                        # Install kubectl if not already installed
                        if ! command -v kubectl &>/dev/null; then
                            echo "Installing kubectl..."
                            sudo curl -Lo /usr/local/bin/kubectl https://dl.k8s.io/release/v1.18.9/bin/linux/amd64/kubectl
                            sudo chmod +x /usr/local/bin/kubectl
                        fi
                        
                        # Update kubeconfig to connect kubectl to the EKS cluster
                        echo "Updating kubeconfig..."
                        aws eks --region ${AWS_REGION} update-kubeconfig --name ${EKS_CLUSTER_NAME}

                        # Apply the Kubernetes manifests
                        echo "Applying Kubernetes manifests..."
                        kubectl apply -f deployment.yaml -n ${KUBE_NAMESPACE}
                        kubectl apply -f service.yaml -n ${KUBE_NAMESPACE}

                        echo "Deployment and service applied successfully."
                        '''
                    }
                }
            }
        }
    }
}
