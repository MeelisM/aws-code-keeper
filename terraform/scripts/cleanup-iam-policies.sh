#!/bin/bash

# Cleanup script for detaching AWS IAM policies 
# Use this when Terraform fails to delete policies due to "Cannot delete a policy attached to entities" errors

set -e

# Environment (dev by default)
ENV=${1:-dev}

echo "==============================================="
echo "IAM Policy Cleanup Script - Environment: $ENV"
echo "==============================================="

# Define the policies to clean up
POLICIES=(
  "${ENV}_VPCModulePermissions"
  "${ENV}_EKSModulePermissions"
  "${ENV}_ACMModulePermissions"
  "${ENV}_TagResourcePermissions"
  "${ENV}_CloudWatchPermissions"
)

# Function to get full ARN for a policy
get_policy_arn() {
  local policy_name=$1
  aws iam list-policies --query "Policies[?PolicyName=='$policy_name'].Arn" --output text
}

# Function to detach policy from all users
detach_from_users() {
  local policy_arn=$1
  local policy_name=$2
  
  echo "Checking users with $policy_name attached..."
  
  # List all users with this policy attached
  ATTACHED_USERS=$(aws iam list-entities-for-policy --policy-arn "$policy_arn" --entity-filter User --query 'PolicyUsers[*].UserName' --output text)
  
  if [ -z "$ATTACHED_USERS" ]; then
    echo "  No users have $policy_name attached."
  else
    echo "  Found users with $policy_name attached: $ATTACHED_USERS"
    for user in $ATTACHED_USERS; do
      echo "  Detaching $policy_name from user $user..."
      aws iam detach-user-policy --user-name "$user" --policy-arn "$policy_arn"
      echo "  ✓ Detached $policy_name from user $user"
    done
  fi
}

# Function to detach policy from all groups
detach_from_groups() {
  local policy_arn=$1
  local policy_name=$2
  
  echo "Checking groups with $policy_name attached..."
  
  # List all groups with this policy attached
  ATTACHED_GROUPS=$(aws iam list-entities-for-policy --policy-arn "$policy_arn" --entity-filter Group --query 'PolicyGroups[*].GroupName' --output text)
  
  if [ -z "$ATTACHED_GROUPS" ]; then
    echo "  No groups have $policy_name attached."
  else
    echo "  Found groups with $policy_name attached: $ATTACHED_GROUPS"
    for group in $ATTACHED_GROUPS; do
      echo "  Detaching $policy_name from group $group..."
      aws iam detach-group-policy --group-name "$group" --policy-arn "$policy_arn"
      echo "  ✓ Detached $policy_name from group $group"
    done
  fi
}

# Function to detach policy from all roles
detach_from_roles() {
  local policy_arn=$1
  local policy_name=$2
  
  echo "Checking roles with $policy_name attached..."
  
  # List all roles with this policy attached
  ATTACHED_ROLES=$(aws iam list-entities-for-policy --policy-arn "$policy_arn" --entity-filter Role --query 'PolicyRoles[*].RoleName' --output text)
  
  if [ -z "$ATTACHED_ROLES" ]; then
    echo "  No roles have $policy_name attached."
  else
    echo "  Found roles with $policy_name attached: $ATTACHED_ROLES"
    for role in $ATTACHED_ROLES; do
      echo "  Detaching $policy_name from role $role..."
      aws iam detach-role-policy --role-name "$role" --policy-arn "$policy_arn"
      echo "  ✓ Detached $policy_name from role $role"
    done
  fi
}

# Process each policy
for policy_name in "${POLICIES[@]}"; do
  echo ""
  echo "Processing policy: $policy_name"
  echo "---------------------------"
  
  # Get the policy ARN
  POLICY_ARN=$(get_policy_arn "$policy_name")
  
  if [ -z "$POLICY_ARN" ]; then
    echo "Policy $policy_name not found, skipping."
    continue
  fi
  
  echo "Policy ARN: $POLICY_ARN"
  
  # Detach from all entity types
  detach_from_users "$POLICY_ARN" "$policy_name"
  detach_from_groups "$POLICY_ARN" "$policy_name"
  detach_from_roles "$POLICY_ARN" "$policy_name"
  
  echo "Completed processing for $policy_name"
done

echo ""
echo "Waiting 30 seconds for IAM changes to propagate..."
sleep 30
echo "Cleanup completed! You can now try running terraform apply again."