#!/bin/bash
# Script to import existing AWS resources into Terraform state
# Use this when the state file has been lost but resources still exist in AWS

set -e

# Set your AWS region
AWS_REGION="eu-north-1"
ENVIRONMENT="staging"
WORKSPACE="staging"

# Extract information from the GitLab job output
echo "Setting up Terraform workspace..."
terraform init
terraform workspace select $WORKSPACE 2>/dev/null || terraform workspace new $WORKSPACE

echo "Starting resource import process..."

# Import IAM policies
echo "Importing IAM policies..."
terraform import module.iam.aws_iam_policy.vpc_permissions arn:aws:iam::838612703539:policy/VPCModulePermissions
terraform import module.iam.aws_iam_policy.eks_permissions arn:aws:iam::838612703539:policy/EKSModulePermissions
terraform import module.iam.aws_iam_policy.acm_permissions arn:aws:iam::838612703539:policy/ACMModulePermissions
terraform import module.iam.aws_iam_policy.tag_permissions arn:aws:iam::838612703539:policy/TagResourcePermissions
terraform import module.iam.aws_iam_policy.cloudwatch_permissions arn:aws:iam::838612703539:policy/CloudWatchPermissions

# Import VPC
echo "Importing VPC resources..."
terraform import module.vpc.aws_vpc.main vpc-03bbed4f1798e8117

# Import subnets from the job output
echo "Importing subnets..."
terraform import module.vpc.aws_subnet.private[0] subnet-01898cfda36d2d1cf
terraform import module.vpc.aws_subnet.private[1] subnet-08eca934bab8dfff7

# Import public subnets (we need to find the IDs)
echo "Checking for public subnets in VPC vpc-03bbed4f1798e8117..."
PUBLIC_SUBNETS=$(aws ec2 describe-subnets --filters "Name=vpc-id,Values=vpc-03bbed4f1798e8117" "Name=tag:Name,Values=*public*" --query 'Subnets[*].SubnetId' --output text --region $AWS_REGION)
if [ -n "$PUBLIC_SUBNETS" ]; then
  # Convert to array
  PUBLIC_SUBNET_ARRAY=($PUBLIC_SUBNETS)
  echo "Found public subnets: $PUBLIC_SUBNETS"
  
  # Import public subnets if found
  if [ -n "${PUBLIC_SUBNET_ARRAY[0]}" ]; then
    echo "Importing public subnet 0: ${PUBLIC_SUBNET_ARRAY[0]}"
    terraform import module.vpc.aws_subnet.public[0] ${PUBLIC_SUBNET_ARRAY[0]}
  fi
  
  if [ -n "${PUBLIC_SUBNET_ARRAY[1]}" ]; then
    echo "Importing public subnet 1: ${PUBLIC_SUBNET_ARRAY[1]}"
    terraform import module.vpc.aws_subnet.public[1] ${PUBLIC_SUBNET_ARRAY[1]}
  fi
fi

# Import internet gateway
echo "Checking for internet gateway..."
IGW_ID=$(aws ec2 describe-internet-gateways --filters "Name=attachment.vpc-id,Values=vpc-03bbed4f1798e8117" --query 'InternetGateways[0].InternetGatewayId' --output text --region $AWS_REGION)
if [ -n "$IGW_ID" ] && [ "$IGW_ID" != "None" ]; then
  echo "Importing internet gateway: $IGW_ID"
  terraform import module.vpc.aws_internet_gateway.main $IGW_ID
fi

# Import NAT gateways
echo "Checking for NAT gateways..."
NAT_GATEWAY_IDS=$(aws ec2 describe-nat-gateways --filter "Name=vpc-id,Values=vpc-03bbed4f1798e8117" --query 'NatGateways[*].NatGatewayId' --output text --region $AWS_REGION)
if [ -n "$NAT_GATEWAY_IDS" ]; then
  NAT_GATEWAY_ARRAY=($NAT_GATEWAY_IDS)
  
  if [ -n "${NAT_GATEWAY_ARRAY[0]}" ]; then
    echo "Importing NAT gateway 0: ${NAT_GATEWAY_ARRAY[0]}"
    terraform import module.vpc.aws_nat_gateway.main[0] ${NAT_GATEWAY_ARRAY[0]}
  fi
  
  if [ -n "${NAT_GATEWAY_ARRAY[1]}" ]; then
    echo "Importing NAT gateway 1: ${NAT_GATEWAY_ARRAY[1]}"
    terraform import module.vpc.aws_nat_gateway.main[1] ${NAT_GATEWAY_ARRAY[1]}
  fi
fi

# Import EKS cluster
echo "Importing EKS cluster..."
terraform import module.eks.aws_eks_cluster.main cloud-design-cluster-staging

# Import cluster security group 
echo "Importing EKS security groups..."
terraform import module.eks.aws_security_group.eks_cluster_sg sg-029a421ee003f0b2c
terraform import module.eks.aws_security_group.eks_nodes_sg sg-0d038bd2e309f0a0e

# Import node group
echo "Importing EKS node group..."
terraform import module.eks.aws_eks_node_group.main cloud-design-cluster-staging:cloud-design-cluster-staging-node-group

# Import IAM roles for EKS
echo "Importing IAM roles..."
terraform import module.eks.aws_iam_role.eks_cluster_role cloud-design-cluster-staging-cluster-role
terraform import module.eks.aws_iam_role.eks_node_role cloud-design-cluster-staging-node-role

# Import OIDC provider
echo "Importing OIDC provider..."
terraform import module.eks.aws_iam_openid_connect_provider.eks arn:aws:iam::838612703539:oidc-provider/oidc.eks.${AWS_REGION}.amazonaws.com/id/A2F3B78F0DFE71C36BEC8B5DD20ABF58

echo "Import completed. Now you can run terraform plan to see if the state is synchronized."
echo "After verification, run: terraform destroy -var-file=terraform-${ENVIRONMENT}.tfvars"