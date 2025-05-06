# Code Keeper

> **Project Focus**: This project demonstrates infrastructure as code using Terraform and AWS cloud services, specifically focused on deploying a microservices architecture to AWS EKS with a complete GitLab CI/CD pipeline. The primary goal is to showcase cloud infrastructure design, automated deployment, and continuous integration/delivery practices.

A cloud-native microservices architecture deployed on AWS EKS (Elastic Kubernetes Service), designed for high availability, scalability, and security, with fully automated CI/CD pipelines using self-hosted GitLab.

![Architecture Diagram](./images/diagram.png)

## Project Overview

This project implements a cloud-native movie catalog service with three microservices:

1. **API Gateway**

   - Entry point for all client requests
   - Routes requests to appropriate backend services
   - Swagger/OpenAPI documentation at `/api-docs`
   - Built with Node.js/Express

2. **Inventory Service**

   - Manages movie catalog with CRUD operations via RESTful API
   - PostgreSQL database for persistent storage
   - RESTful API endpoints

3. **Billing Service**
   - Processes orders through a message queue system
   - PostgreSQL database for order history
   - Asynchronous processing using RabbitMQ

## CI/CD Pipeline

This project features a complete GitLab CI/CD setup for automated testing, building, and deployment:

1. **Self-hosted GitLab**

   - Runs in Docker containers for easy setup and management
   - Includes GitLab Runner for executing CI/CD pipelines
   - Configured via Ansible for automated setup and maintenance

2. **Pipeline Workflows**

   - **Service Pipelines**: Each microservice has its own automated build, test, scan and deployment pipeline
   - **Infrastructure Pipeline**: Manages infrastructure changes through Terraform
   - All environment-specific variables managed securely through GitLab CI variables

3. **Automated Deployment**
   - Staging and Production environments configured via CI/CD
   - Infrastructure changes tracked and applied automatically
   - Kubernetes deployments managed through GitLab CI/CD

![Service Pipeline](./images/service_pipeline.png)
![Infrastructure Pipeline](./images/infra_pipeline.png)

## Deployment Status

### Kubernetes Resources

The following image shows the running Kubernetes services and pods in the cluster:

![Kubernetes Resources](./images/pods-and-ingress.png)

### API Testing Results

Successful API test results from Postman showing the Movie CRUD operations working against the AWS ingress endpoint:

##### API test results - Staging

![API Test Results - Staging](./images/staging_postman_results.png)

##### API test results - Production

![API Test Results - Production](./images/prod_postman_results.png)

## Architecture Components

### Infrastructure (AWS)

- **VPC**: Custom VPC (10.0.0.0/16) spanning multiple availability zones
- **EKS Cluster**: Managed Kubernetes with nodes in private subnets
- **Multi-AZ Setup**: Resources distributed across eu-north-1a and eu-north-1b for high availability
- **Load Balancing**: Application Load Balancer with HTTPS support
- **Security**: Private/public subnet separation with proper gateway configuration
- **Monitoring**: CloudWatch integration with comprehensive dashboard for monitoring cluster performance
- **State Management**: Terraform state in S3 with DynamoDB locking
- **Autoscaling**: Horizontal Pod Autoscaling (HPA) for stateless services based on CPU utilization

### GitLab CI/CD Implementation

- **Self-hosted GitLab**: Containerized GitLab instance for complete CI/CD control
- **GitLab Runner**: Docker-based runner for executing pipeline jobs
- **Multi-stage Pipelines**: Development, staging, and production environments
- **Environment Variables**: Stored securely in GitLab's CI/CD variables
- **Infrastructure as Code**: Terraform changes managed through CI/CD
- **Automated Testing**: Integrated testing before deployment
- **Deployment Automation**: Scripts for configuring kubectl and deploying to EKS

### Kubernetes Deployment Strategy

- **Stateless Services** (API Gateway, Inventory App):

  - Deployed as Kubernetes Deployments
  - Configured with Horizontal Pod Autoscaler (HPA)
  - Minimum of 1 replica, scaling up to 3 replicas based on 60% CPU utilization
  - Topology spread constraints to ensure pods are distributed across availability zones

- **Stateful Components** (Billing App, Billing Queue, Databases):
  - Deployed as StatefulSets to preserve state and identity
  - Persistent volume claims for data retention
  - Single replica with backup strategies

## Technologies

- **Container Orchestration**: Kubernetes via Amazon EKS
- **Infrastructure as Code**: Terraform modules for AWS resource provisioning
- **CI/CD**: Self-hosted GitLab with GitLab Runner
- **Configuration Management**: Ansible for GitLab setup and management
- **Databases**: PostgreSQL for persistent storage
- **Messaging**: RabbitMQ for asynchronous communication
- **API Documentation**: OpenAPI/Swagger
- **Languages & Frameworks**: Node.js, Express
- **Container Registry**: Docker Hub

## Project Structure

```
code-keeper/
├── ansible/                     # Ansible playbooks for GitLab setup
│   ├── gitlab_setup.yml        # Main GitLab setup playbook
│   ├── group_vars/             # Variables for Ansible playbooks
│   ├── inventory/              # Ansible inventory files
│   └── roles/                  # Ansible roles for GitLab configuration
├── gitlab/                     # GitLab Docker configuration
│   └── docker-compose.yml      # Docker Compose for GitLab services
├── docker-compose.yaml         # Docker configuration reference
├── kustomization.yaml          # Kubernetes resource management
├── images/                     # Architecture diagrams and screenshots
├── manifests/                  # Kubernetes manifests
│   ├── api-gateway-app.yaml
│   ├── billing-app.yaml
│   ├── billing-db.yaml
│   ├── billing-queue.yaml
│   ├── inventory-app.yaml
│   ├── inventory-db.yaml
│   └── networking/
│       └── api-gateway-ingress.tpl.yaml
├── postman/                    # API test collections
├── scripts/                    # Utility scripts
│   ├── build-and-push.sh
│   ├── cleanup-k8s-resources.sh
│   ├── configure-kubectl-helm.sh
│   ├── init-billing-db.sh
│   └── init-inventory-db.sh
├── src/                        # Application source code
│   ├── api-gateway/            # API Gateway service
│   ├── billing-app/            # Billing service
│   └── inventory-app/          # Inventory service
└── terraform/                  # Infrastructure as code
    ├── acm/                    # Certificate management
    ├── bootstrap/              # Terraform state setup
    ├── cloudwatch/             # Monitoring
    ├── eks/                    # Kubernetes cluster
    ├── iam/                    # Identity & access
    ├── kubernetes-addons/      # K8s addons (ALB, metrics)
    ├── scripts/                # CI/CD scripts for Terraform
    │   └── ci-configure-kubectl.sh
    └── vpc/                    # Network configuration
```

## Getting Started

### Prerequisites

- Docker and Docker Compose
- AWS account
- Terraform v1.11.4+
- Ansible
- kubectl
- Python3

### Required AWS Permissions

Before beginning the deployment, ensure your AWS user has the following IAM permissions:

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "SetupIAM",
      "Effect": "Allow",
      "Action": [
        "iam:GetUser",
        "iam:CreatePolicy",
        "iam:GetPolicy",
        "iam:GetPolicyVersion",
        "iam:AttachUserPolicy",
        "iam:ListAttachedUserPolicies",
        "iam:ListPolicyVersions",
        "iam:DetachUserPolicy",
        "iam:DeletePolicy",
        "iam:DeletePolicyVersion",
        "iam:CreatePolicyVersion",
        "iam:UpdateAssumeRolePolicy",
        "iam:ListAttachedGroupPolicies",
        "iam:CreateGroup",
        "iam:GetGroup",
        "iam:DeleteGroup",
        "iam:AddUserToGroup",
        "iam:AttachGroupPolicy",
        "iam:ListGroupsForUser",
        "iam:DetachGroupPolicy",
        "iam:RemoveUserFromGroup",
        "iam:UpdateGroup",
        "iam:ListEntitiesForPolicy",
        "iam:ListPolicies"
      ],
      "Resource": "*"
    }
  ]
}
```

You can create this policy in the AWS Management Console or see the `bootstrap/initial-user-policy.json` file for a ready-to-use policy document.

### Setup Process

#### 1. Start GitLab Services

First, set up the self-hosted GitLab instance:

```bash
cd gitlab
cp .env.example .env
# Edit .env file to configure your environment variables
docker-compose up -d
```

Wait for GitLab to start (this may take a few minutes). Access the GitLab UI at http://localhost (or your configured URL) and set your initial admin password.

#### 2. Configure Ansible for GitLab Setup

Configure your GitLab API token and other variables:

```bash
cd ansible
cp group_vars/all.yml.example group_vars/all.yml
cp group_vars/vault.yml.example group_vars/vault.yml
# Edit the .yml files to add your GitLab token and other variables
```

#### 3. Run the GitLab Setup Playbook

```bash
cd ansible
ansible-playbook gitlab_setup.yml
```

This will:

- Create repositories for each service
- Configure CI/CD variables
- Set up webhooks and access permissions
- Initialize repositories with code and CI/CD configuration

#### 4. Set up Infrastructure

- Rename `/terraform/terraform.tfvars.example` to `/terraform/terraform.tfvars` and fill it with information.
- For testing, `t3.medium` instance can be used. It allows just enough pods to run the project on minimum load. `t3.large` is needed for full load.

a. **Initialize Terraform state backend**:

```bash
cd terraform/bootstrap
terraform init
terraform apply
```

b. **Deploy main infrastructure**:

```bash
cd ..
terraform init
terraform apply
```

c. **Configure kubectl and Helm**:

```bash
./scripts/configure-kubectl-helm.sh
```

#### 5. Use the CI/CD Pipeline or Deploy Manually

CI/CD will automatically deploy changes when you push to the repositories. You want to pause microservice pipelines and let the infrastructure pipeline run first to set everything up.

## CI/CD Pipeline Details

### Pipeline Stages

1. **Build**: Compiles code, runs linting, and unit tests
2. **Test**: Runs integration test. Just a simulated step. No actual tests currently.
3. **Deploy to Staging**: Automatic deployment to staging environment
4. **Manual Approval**: Required before production deployment
5. **Deploy to Production**: Deployment to production environment

### Repository Structure

Each service repository created by the Ansible playbook includes:

- Source code for the service
- Dockerfile for containerization
- CI/CD configuration (.gitlab-ci.yml)
- Kubernetes manifests for deployment
- Documentation and README files

## API Documentation

When running, API documentation is available at `/api-docs` endpoint of the API Gateway service.

## Testing with Postman

Import the collections and environment from the `postman/` directory to test the API:

1. Import `code-keeper.postman_collection.json`
2. Import `code-keeper.postman_environment.json`
3. Update the environment variables with your deployment details

## Monitoring & Observability

The project includes a comprehensive CloudWatch dashboard that provides visibility into cluster performance:

##### Staging Dashboard

![Cloudwatch Dashboard - Staging](./images/staging_dashboard.png)

##### Production Dashboard

![Cloudwatch Dashboard - Production](./images/production_dashboard.png)

- **Overall Cluster Metrics**: Pod and node-level CPU and memory utilization across the cluster
- **Namespace Monitoring**: Separate metrics for default and kube-system namespaces
- **Application Performance**: Dedicated panels tracking CPU and memory for each microservice (API Gateway, Inventory, Billing)
- **Infrastructure Monitoring**: Specialized metrics for stateful components (databases and message queue)
- **Resource Optimization**: Tracking of resource utilization against defined limits to optimize container configurations
- **Container Insights**: AWS EKS addon enabled for deep visibility into container performance

The dashboard provides both high-level overview panels and detailed component-specific metrics, enabling quick identification of performance bottlenecks or potential issues.

## Cleanup

To clean up resources:

1. **Remove application resources**:

   ```bash
   ./scripts/cleanup-k8s-resources.sh
   ```

2. **Destroy infrastructure**:

   ```bash
   cd terraform
   terraform destroy
   cd bootstrap
   terraform destroy
   ```

3. **Shut down GitLab**:
   ```bash
   cd gitlab
   docker-compose down
   ```

## Architecture Features

- **High Availability**: Multi-AZ deployment with automatic failover
- **Scalability**: EKS auto-scaling with configurable node groups
- **Security**: Private subnets for application pods, public-only for ingress
- **Disaster Recovery**: AZ2 configured for disaster recovery and scaling
- **HTTPS Support**: Integrated with AWS Certificate Manager using a self-signed certificate (a proper ACM certificate would be used with a registered domain name)
- **Automated Deployment**: Complete CI/CD pipeline for code and infrastructure changes
- **Self-hosted GitLab**: Full control over the CI/CD environment with Docker-based setup

## Future Enhancements

### Database Improvements

- **Migrate to Amazon RDS**: Replace StatefulSet PostgreSQL databases with Amazon RDS for improved reliability, automatic backups, and Multi-AZ deployments

### Security Enhancements

- **Custom Domain**: Register a custom domain name to replace the self-signed certificate with a properly validated AWS ACM certificate
- **Amazon CloudFront**: Add CloudFront content delivery network (CDN) for faster content delivery
- **AWS WAF Integration**: Add AWS Web Application Firewall for additional protection against common exploits
- **Secret Management**: Migrate from Kubernetes Secrets to AWS Secrets Manager or HashiCorp Vault

### CI/CD Improvements

- **Automated Rollbacks**: Add automated rollback capability if deployments fail
- **Canary Releases**: Implement canary deployment strategy for gradual rollouts
- **Extended Test Coverage**: Add performance and security testing to the CI/CD pipeline

## License

See the [LICENSE](./LICENSE) file for licensing details.
