# Centralized IAM permissions for infrastructure modules
# This file defines all the necessary permissions for the CLI admin user
# to work with VPC, EKS, ACM and Kubernetes-addons modules

# Get the CLI admin user data
data "aws_iam_user" "cli_admin" {
  user_name = var.cli_admin_username
}

# Create an IAM group for admin users with environment-specific name
resource "aws_iam_group" "admin_group" {
  name = "admin_group_${var.environment}"
}

# Add the CLI admin user to the environment-specific admin group
resource "aws_iam_user_group_membership" "admin_group_membership" {
  user = data.aws_iam_user.cli_admin.user_name
  groups = [
    aws_iam_group.admin_group.name
  ]
}

# VPC permissions
resource "aws_iam_policy" "vpc_permissions" {
  name        = "VPCModulePermissions_${var.environment}"
  description = "Policy allowing necessary permissions for VPC module operations in ${var.environment}"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Action = [
        "ec2:CreateVpc", "ec2:AllocateAddress", "ec2:CreateTags", "ec2:DescribeVpcs",
        "ec2:DescribeAddresses", "ec2:DescribeAddressesAttribute", "ec2:DescribeVpcAttribute",
        "ec2:DeleteVpc", "ec2:ReleaseAddress", "ec2:ModifyVpcAttribute", "ec2:CreateInternetGateway",
        "ec2:CreateSubnet", "ec2:DeleteSubnet", "ec2:AttachInternetGateway", "ec2:DescribeSubnets",
        "ec2:DescribeInternetGateways", "ec2:DeleteInternetGateway", "ec2:DescribeNetworkInterfaces",
        "ec2:ModifySubnetAttribute", "ec2:CreateRouteTable", "ec2:CreateNatGateway", "ec2:DescribeRouteTables",
        "ec2:DeleteRouteTable", "ec2:DescribeNatGateways", "ec2:DeleteNatGateway", "ec2:CreateRoute",
        "ec2:DetachInternetGateway", "ec2:DisassociateAddress", "ec2:AssociateRouteTable",
        "ec2:DisassociateRouteTable", "ec2:DescribeInstances", "ec2:DescribeVolumes",
        "ec2:DescribeSecurityGroups", "ec2:DescribeDhcpOptions", "ec2:DescribeManagedPrefixLists",
        "ec2:DescribeSpotPriceHistory", "ec2:CreateSecurityGroup", "ec2:RevokeSecurityGroupEgress",
        "ec2:DeleteSecurityGroup", "ec2:AuthorizeSecurityGroupEgress", "ec2:DescribeRegions",
        "ec2:DescribeSnapshots", "ec2:DescribeImages", "ec2:AuthorizeSecurityGroupIngress",
        "ec2:DescribeSecurityGroupRules", "ec2:RevokeSecurityGroupIngress"
      ],
      Resource = "*"
    }]
  })

  lifecycle {
    create_before_destroy = true
  }
}

# EKS permissions
resource "aws_iam_policy" "eks_permissions" {
  name        = "EKSModulePermissions_${var.environment}"
  description = "Policy allowing necessary permissions for EKS module operations in ${var.environment}"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "eks:DescribeNodegroup", "eks:CreateCluster", "eks:DescribeCluster",
          "eks:TagResource", "eks:DeleteCluster", "eks:ListClusters",
          "eks:CreateNodegroup", "eks:DeleteNodegroup"
        ],
        Resource = "*"
      },
      {
        Effect = "Allow",
        Action = [
          "iam:CreateRole", "iam:DeleteRole", "iam:GetRole", "iam:PassRole",
          "iam:ListRolePolicies", "iam:ListAttachedRolePolicies", "iam:AttachRolePolicy",
          "iam:DetachRolePolicy", "iam:PutRolePolicy", "iam:DeleteRolePolicy",
          "iam:CreateServiceLinkedRole", "iam:CreateOpenIDConnectProvider",
          "iam:GetOpenIDConnectProvider", "iam:DeleteOpenIDConnectProvider",
          "iam:TagOpenIDConnectProvider", "iam:ListOpenIDConnectProviders",
          "iam:ListInstanceProfilesForRole"
        ],
        Resource = "*"
      },
      {
        Effect = "Allow",
        Action = [
          "autoscaling:CreateAutoScalingGroup", "autoscaling:DeleteAutoScalingGroup",
          "autoscaling:DescribeAutoScalingGroups", "autoscaling:DescribeScalingActivities",
          "autoscaling:UpdateAutoScalingGroup"
        ],
        Resource = "*"
      }
    ]
  })

  lifecycle {
    create_before_destroy = true
  }
}

# ACM permissions
resource "aws_iam_policy" "acm_permissions" {
  name        = "ACMModulePermissions_${var.environment}"
  description = "Policy allowing necessary permissions for ACM module operations in ${var.environment}"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Action = [
        "acm:DescribeCertificate", "acm:ImportCertificate", "acm:AddTagsToCertificate",
        "acm:ListTagsForCertificate", "acm:DeleteCertificate", "acm:RequestCertificate",
        "acm:ListCertificates"
      ],
      Resource = "*"
    }]
  })

  lifecycle {
    create_before_destroy = true
  }
}

# Tag permissions
resource "aws_iam_policy" "tag_permissions" {
  name        = "TagResourcePermissions_${var.environment}"
  description = "Policy allowing tag operations needed by various modules in ${var.environment}"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect   = "Allow",
      Action   = "tag:GetResources",
      Resource = "*"
    }]
  })

  lifecycle {
    create_before_destroy = true
  }
}

# CloudWatch permissions
resource "aws_iam_policy" "cloudwatch_permissions" {
  name        = "CloudWatchPermissions_${var.environment}"
  description = "Policy allowing necessary permissions for CloudWatch module operations in ${var.environment}"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "cloudwatch:GetDashboard", "cloudwatch:DeleteDashboards", "cloudwatch:PutMetricData",
          "cloudwatch:GetMetricStatistics", "cloudwatch:ListMetrics", "cloudwatch:GetMetricData",
          "cloudwatch:PutDashboard", "cloudwatch:ListDashboards", "logs:CreateLogGroup",
          "logs:CreateLogStream", "logs:PutLogEvents", "logs:DescribeLogStreams"
        ],
        Resource = "*"
      },
      {
        Effect = "Allow",
        Action = [
          "eks:DescribeAddon", "eks:CreateAddon", "eks:DeleteAddon",
          "eks:UpdateAddon", "eks:ListAddons", "eks:DescribeCluster"
        ],
        Resource = "*"
      }
    ]
  })

  lifecycle {
    create_before_destroy = true
  }
}

# Attach policies to group
resource "aws_iam_group_policy_attachment" "admin_group_vpc" {
  group      = aws_iam_group.admin_group.name
  policy_arn = aws_iam_policy.vpc_permissions.arn
  lifecycle { create_before_destroy = true }
}

resource "aws_iam_group_policy_attachment" "admin_group_eks" {
  group      = aws_iam_group.admin_group.name
  policy_arn = aws_iam_policy.eks_permissions.arn
  lifecycle { create_before_destroy = true }
}

resource "aws_iam_group_policy_attachment" "admin_group_acm" {
  group      = aws_iam_group.admin_group.name
  policy_arn = aws_iam_policy.acm_permissions.arn
  lifecycle { create_before_destroy = true }
}

resource "aws_iam_group_policy_attachment" "admin_group_tag" {
  group      = aws_iam_group.admin_group.name
  policy_arn = aws_iam_policy.tag_permissions.arn
  lifecycle { create_before_destroy = true }
}

resource "aws_iam_group_policy_attachment" "admin_group_cloudwatch" {
  group      = aws_iam_group.admin_group.name
  policy_arn = aws_iam_policy.cloudwatch_permissions.arn
  lifecycle { create_before_destroy = true }
}

# Wait for IAM propagation
resource "null_resource" "wait_for_iam_propagation" {
  depends_on = [
    aws_iam_group_policy_attachment.admin_group_vpc,
    aws_iam_group_policy_attachment.admin_group_eks,
    aws_iam_group_policy_attachment.admin_group_acm,
    aws_iam_group_policy_attachment.admin_group_tag,
    aws_iam_group_policy_attachment.admin_group_cloudwatch,
    aws_iam_user_group_membership.admin_group_membership
  ]

  provisioner "local-exec" {
    command = "echo 'IAM policies have been created. Waiting 30s for propagation...' && sleep 30"
  }
}

# Detach policies before destroy
resource "null_resource" "detach_policies" {
  triggers = {
    destroy_marker = "detach_on_destroy"
    group_name     = aws_iam_group.admin_group.name
    vpc_policy     = aws_iam_policy.vpc_permissions.arn
    eks_policy     = aws_iam_policy.eks_permissions.arn
    acm_policy     = aws_iam_policy.acm_permissions.arn
    tag_policy     = aws_iam_policy.tag_permissions.arn
    cw_policy      = aws_iam_policy.cloudwatch_permissions.arn
    environment    = var.environment
  }

  provisioner "local-exec" {
    when    = destroy
    command = <<-EOT
      echo 'Detaching IAM policies from ${self.triggers.environment} group before destroying...'
      aws iam detach-group-policy --group-name "${self.triggers.group_name}" --policy-arn "${self.triggers.vpc_policy}" || echo "VPC policy already detached"
      aws iam detach-group-policy --group-name "${self.triggers.group_name}" --policy-arn "${self.triggers.eks_policy}" || echo "EKS policy already detached"
      aws iam detach-group-policy --group-name "${self.triggers.group_name}" --policy-arn "${self.triggers.acm_policy}" || echo "ACM policy already detached"
      aws iam detach-group-policy --group-name "${self.triggers.group_name}" --policy-arn "${self.triggers.tag_policy}" || echo "Tag policy already detached"
      aws iam detach-group-policy --group-name "${self.triggers.group_name}" --policy-arn "${self.triggers.cw_policy}" || echo "CloudWatch policy already detached"

      echo 'Waiting 10 seconds for detachment to propagate...'
      sleep 10
    EOT
  }

  depends_on = [
    aws_iam_group_policy_attachment.admin_group_vpc,
    aws_iam_group_policy_attachment.admin_group_eks,
    aws_iam_group_policy_attachment.admin_group_acm,
    aws_iam_group_policy_attachment.admin_group_tag,
    aws_iam_group_policy_attachment.admin_group_cloudwatch
  ]
}

# Final destroy step
resource "null_resource" "iam_destroyer" {
  triggers = {
    environment = var.environment
  }

  provisioner "local-exec" {
    when    = destroy
    command = "echo 'All IAM resources for ${self.triggers.environment} are now destroyed.'"
  }

  depends_on = [
    null_resource.detach_policies,
    null_resource.wait_for_iam_propagation
  ]
}
