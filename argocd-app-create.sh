#!/bin/bash

# Install jq if not already installed
if ! command -v jq &> /dev/null; then
    echo "jq could not be found. Installing..."
    sudo apt-get update && sudo apt-get install -y jq
fi

# Variables
GITLAB_URL="YOUR_GITLAB_FQDN"
GITLAB_API_URL=${GITLAB_URL}/api/v4
PRIVATE_TOKEN="YOUR_PRIVATE_TOKEN" # Replace with your private token

# Function to fetch project names
get_project_names() {
    curl --header "PRIVATE-TOKEN: $PRIVATE_TOKEN" "$GITLAB_API_URL/groups/$GROUP_ID/projects" | jq -r '.[].name'
}

# Fetch project names and assign to listofproject
read -p "Enter your ArgoCD URL: " ARGOCD_URL
read -p "Enter your Project name: " PROJ_NAME
read -p "Enter the chart folder name which you want to use it in ArgoCD application: " CHART_FOLDER
read -p "Enter your GROUP ID: " GROUP_ID
read -p "Enter the repo branch name: " BRANCH_NAME
K8S_SERVER="https://kubernetes.default.svc"

# Fetch project names, convert to lowercase and parse as an array
repo_list=$(get_project_names | tr '[:upper:]' '[:lower:]')

# Ensure repo_list is not empty
if [ -z "$repo_list" ]; then
    echo "No projects found or failed to fetch project names."
    exit 1
fi

# Convert newline-separated string to array
mapfile -t repos <<< "$repo_list"

# Export necessary variables
export ARGOCD_URL PROJ_NAME BRANCH_NAME DEST_NAMESPACE K8S_SERVER CHART_FOLDER

# Process each repository
for i in "${repos[@]}"; do
    export i
    echo "Processing repo: $i"
    envsubst < ./application.yaml.temp > ./application.yaml  
    kubectl apply -f ./application.yaml
done
