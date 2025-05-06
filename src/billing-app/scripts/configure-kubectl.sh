#!/bin/bash
set -e

# Default values
ENVIRONMENT="${STAGING_KUBE_NAMESPACE:-staging}"
REGION="${AWS_DEFAULT_REGION}"

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

# Determine which cluster to use based on environment
if [ -z "${CLUSTER_NAME}" ]; then
  if [ "${ENVIRONMENT}" == "production" ]; then
    CLUSTER_NAME="${AWS_CLUSTER_NAME}-production"
    echo "Using production cluster: ${CLUSTER_NAME}"
  else
    CLUSTER_NAME="${AWS_CLUSTER_NAME}-staging"
    echo "Using staging cluster: ${CLUSTER_NAME}"
  fi
fi

# Verify AWS credentials are available
echo "Verifying AWS credentials..."
if [ -z "${AWS_ACCESS_KEY_ID}" ] || [ -z "${AWS_SECRET_ACCESS_KEY}" ]; then
  echo "ERROR: AWS credentials not found in environment variables."
  echo "Please ensure AWS_ACCESS_KEY_ID and AWS_SECRET_ACCESS_KEY are set."
  echo "Current environment variables:"
  env | grep -i aws || echo "No AWS-related variables found."
  exit 1
fi

# Explicitly export AWS credentials to ensure they are available to the AWS CLI
export AWS_ACCESS_KEY_ID="${AWS_ACCESS_KEY_ID}"
export AWS_SECRET_ACCESS_KEY="${AWS_SECRET_ACCESS_KEY}"
export AWS_DEFAULT_REGION="${REGION}"

# Check for cluster name
if [ -z "${CLUSTER_NAME}" ]; then
  echo "ERROR: No cluster name provided. Set AWS_PROD_CLUSTER_NAME or AWS_STAGING_CLUSTER_NAME in GitLab CI/CD variables"
  exit 1
fi

echo "Configuring kubectl for cluster: ${CLUSTER_NAME} in region: ${REGION} for environment: ${ENVIRONMENT}"
echo "Using AWS credentials with key ID: ${AWS_ACCESS_KEY_ID:0:5}..."

# Test AWS credentials
echo "Testing AWS credentials with STS get-caller-identity..."
aws sts get-caller-identity || {
  echo "ERROR: AWS credentials are invalid or insufficiently privileged."
  exit 1
}

# Update kubeconfig
aws eks update-kubeconfig --name "${CLUSTER_NAME}" --region "${REGION}"

# Verify connection
kubectl get ns "${ENVIRONMENT}" || kubectl create ns "${ENVIRONMENT}"

echo "Successfully configured kubectl for cluster: ${CLUSTER_NAME}"
