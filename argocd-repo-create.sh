#!/bin/bash
# Install jq if not already installed
if ! command -v jq &> /dev/null; then
        echo "jq could not be found. Installing..."
        sudo apt-get update && sudo apt-get install -y jq
fi

# Variables
GITLAB_URL="YOUR_GITLAB_FQDN"
GITLAB_API_URL="$GITLAB_URL/api/v4"
PRIVATE_TOKEN="YOUR_PRIVATE_TOKEN" # Replace with your private token

# Function to fetch project names
get_project_names() {
            curl --header "PRIVATE-TOKEN: $PRIVATE_TOKEN" "$GITLAB_API_URL/groups/$GROUP_ID/projects" | jq -r '.[].name'
    }

# Fetch project names and assign to listofproject

read -p "Enter your ArgoCD URL: " ARGOCD_URL
read -p "Enter your Project name: " PROJ_NAME
read -p "Enter the chart folder name which you want to use it in ArgoCD application: " CHART_FOLDER
read -p "Enter the GITLAB GROUP ID: " GROUP_ID
read -p "Enter the GITLAB GROUP NAME: " GROUP_NAME
read -p "Enter the GITLAB SUBGROUP NAME: " SUBGROUP_NAME
read -p "Enter ArgoCD admin username: " ARGOCD_ADMIN_USER
read -p "Enter ArgoCD admin user password: " ARGOCD_ADMIN_PASS
read -p "Enter Gitlab CI username: " GITLAB_USER
read -p "Enter Gitlab CI user password: " GITLAB_USER_PASS
K8S_SERVER="https://kubernetes.default.svc"

repo_list=$(get_project_names | tr '[:upper:]' '[:lower:]')

# Ensure repo_list is not empty
if [ -z "$repo_list" ]; then
    echo "No projects found or failed to fetch project names."
    exit 1
fi

mapfile -t repos <<< "$repo_list"
export ARGOCD_URL PROJ_NAME GITLAB_USER GITLAB_USER_PASS CHART_FOLDER ARGOCD_ADMIN_USER ARGOCD_ADMIN_PASS
argocd login $ARGOCD_URL --username $ARGOCD_ADMIN_USER --password $ARGOCD_ADMIN_PASS --insecure

for i in ${repos[@]}
do
	argocd repo add $GITLAB_URL/$GROUP_NAME/$SUBGROUP_NAME/${CHART_FOLDER}/$i.git --type git --project $PROJ_NAME --username $GITLAB_USER --password $GITLAB_USER_PASS --insecure
done
