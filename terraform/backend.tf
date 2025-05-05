terraform {
  backend "s3" {
    # These values will be provided during terraform init via the -backend-config flag
    # The GitLab CI/CD pipeline creates a backend_config.hcl file with:
    # - bucket: The S3 bucket name for storing Terraform state (from TF_VAR_TERRAFORM_STATE_BUCKET)
    # - key: The S3 object key for the state file
    # - region: The AWS region where the S3 bucket is located (from AWS_DEFAULT_REGION)
    # - use_lockfile: Whether to use DynamoDB for state locking
    # - encrypt: Whether to encrypt the state file
  }
}
