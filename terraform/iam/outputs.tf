output "iam_policy_readiness" {
  description = "Output to indicate when IAM policies have been created and the waiting period is complete"
  value       = null_resource.wait_for_iam_propagation.id
}

output "admin_group_name" {
  description = "The name of the admin group created by the IAM module"
  value       = aws_iam_group.admin_group.name
}

output "admin_policy_arns" {
  description = "List of all policy ARNs attached to the admin group"
  value = [
    aws_iam_policy.vpc_permissions.arn,
    aws_iam_policy.eks_permissions.arn,
    aws_iam_policy.acm_permissions.arn,
    aws_iam_policy.tag_permissions.arn,
    aws_iam_policy.cloudwatch_permissions.arn
  ]
}

output "iam_lifecycle_id" {
  description = "ID of the IAM lifecycle controller to create dependencies on"
  value       = null_resource.iam_lifecycle_controller.id
}
