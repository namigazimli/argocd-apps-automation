#!/bin/bash

read -p "Enter your Project name: " PROJ_NAME
read -p "Enter your Project description: " PROJ_DESC

export PROJ_NAME PROJ_DESC
envsubst < ./project.yaml.temp > ./project.yaml  
kubectl apply -f ./project.yaml
