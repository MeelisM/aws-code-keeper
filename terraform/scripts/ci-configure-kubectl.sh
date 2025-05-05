#!/bin/bash

# CI/CD script to configure kubectl for an EKS cluster
# This script is designed to be run in CI/CD pipelines

set -e

LIGHTBLUE='\033[1;36m'
LIGHTGREEN='\033[1;32m'
LIGHTRED='\033[1;31m'
NC='\033[0m'

# Default values
CLUSTER_NAME=${CLUSTER_NAME:-}
AWS_REGION=${AWS_REGION:-}
ENVIRONMENT=${ENVIRONMENT:-staging}
TERRAFORM_OUTPUT_FILE=${TERRAFORM_OUTPUT_FILE:-}

# Parse command line arguments
while [[ $# -gt 0 ]]; do
  case $1 in
    --cluster-name)
      CLUSTER_NAME="$2"
      shift 2
      ;;
    --region)
      AWS_REGION="$2"
      shift 2
      ;;
    --environment)
      ENVIRONMENT="$2"
      shift 2
      ;;
    --terraform-output)
      TERRAFORM_OUTPUT_FILE="$2"
      shift 2
      ;;
    *)
      echo "Unknown option: $1"
      exit 1
      ;;
  esac
done

# Try to get values from Terraform output file if provided
if [ -n "$TERRAFORM_OUTPUT_FILE" ] && [ -f "$TERRAFORM_OUTPUT_FILE" ]; then
  echo -e "${LIGHTBLUE}Extracting cluster information from Terraform output...${NC}"
  if command -v jq &> /dev/null; then
    CLUSTER_NAME=$(jq -r '.cluster_id.value // empty' "$TERRAFORM_OUTPUT_FILE" 2>/dev/null) || true
    AWS_REGION=$(jq -r '.aws_region.value // empty' "$TERRAFORM_OUTPUT_FILE" 2>/dev/null) || true
    
    if [ -n "$CLUSTER_NAME" ]; then
      echo "Found cluster name from Terraform output: ${CLUSTER_NAME}"
    fi
    if [ -n "$AWS_REGION" ]; then
      echo "Found AWS region from Terraform output: ${AWS_REGION}"
    fi
  else
    echo -e "${LIGHTRED}jq command not found, can't parse Terraform output file${NC}"
  fi
fi

# Check for required values
if [ -z "$CLUSTER_NAME" ]; then
  echo -e "${LIGHTRED}Error: Cluster name is required. Provide it via --cluster-name or Terraform output.${NC}"
  exit 1
fi

if [ -z "$AWS_REGION" ]; then
  # Try to get from AWS CLI configuration
  AWS_REGION=$(aws configure get region 2>/dev/null || echo "")
  if [ -z "$AWS_REGION" ]; then
    echo -e "${LIGHTRED}Error: AWS region is required. Provide it via --region or Terraform output.${NC}"
    exit 1
  fi
fi

# Configure kubectl for EKS
echo -e "${LIGHTBLUE}Configuring kubectl for EKS...${NC}"  
echo "Updating kubeconfig for cluster: ${CLUSTER_NAME} in region: ${AWS_REGION}"
aws eks update-kubeconfig --name ${CLUSTER_NAME} --region ${AWS_REGION}

if [ $? -eq 0 ]; then
  echo -e "${LIGHTGREEN}Successfully configured kubectl for EKS cluster: ${CLUSTER_NAME}${NC}"
else
  echo -e "${LIGHTRED}Failed to configure kubectl. Please check your cluster name and region.${NC}"
  exit 1
fi

# Verify kubectl configuration
echo "Verifying kubectl configuration..."
kubectl get nodes

if [ $? -eq 0 ]; then
  echo -e "${LIGHTGREEN}Successfully connected to the EKS cluster!${NC}"
else
  echo -e "${LIGHTRED}Could not connect to the EKS cluster. Please check your AWS permissions.${NC}"
  exit 1
fi

# Create namespace if it doesn't exist
echo -e "${LIGHTBLUE}Ensuring namespace ${ENVIRONMENT} exists...${NC}"
kubectl create namespace ${ENVIRONMENT} --dry-run=client -o yaml | kubectl apply -f -

# Check permissions for deploying
echo -e "${LIGHTBLUE}Checking permissions for deploying to namespace: ${ENVIRONMENT}${NC}"
kubectl auth can-i create deployments --namespace=${ENVIRONMENT}

echo -e "${LIGHTGREEN}Kubernetes configuration complete!${NC}"