#!/bin/bash
set -e

# Default values
CLUSTER_NAME="cloud-design-cluster-staging"
REGION="${AWS_DEFAULT_REGION:-eu-north-1}"
ENVIRONMENT="${STAGING_KUBE_NAMESPACE:-staging}"

# Parse command line arguments
while [[ $# -gt 0 ]]; do
  key="$1"
  case $key in
    --cluster-name)
      CLUSTER_NAME="$2"
      shift
      shift
      ;;
    --region)
      REGION="$2"
      shift
      shift
      ;;
    --environment)
      ENVIRONMENT="$2"
      shift
      shift
      ;;
    *)
      echo "Unknown option: $key"
      exit 1
      ;;
  esac
done

echo "Configuring kubectl for cluster: ${CLUSTER_NAME} in region: ${REGION}"

# Update kubeconfig
aws eks update-kubeconfig --name "${CLUSTER_NAME}" --region "${REGION}"

# Verify connection
kubectl get ns "${ENVIRONMENT}" || kubectl create ns "${ENVIRONMENT}"

echo "Successfully configured kubectl for cluster: ${CLUSTER_NAME}"
