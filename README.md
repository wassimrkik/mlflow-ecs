# MLflow on AWS ECS

This repository provides infrastructure as code (IaC) to deploy **MLflow** on **Amazon ECS (Elastic Container Service)** using **Terraform**. It sets up a scalable and containerized MLflow environment with persistent storage and AWS integrations.

## Features

- **MLflow** deployment on **AWS ECS** with auto-scaling.
- **Amazon EFS** for persistent storage of MLflow artifacts.
- **Terraform** for infrastructure management.
- **AWS ECR** for storing Docker images.
- Integrated with **CloudWatch** for monitoring.

## Prerequisites

- AWS account with appropriate permissions.
- Terraform installed.
- AWS CLI configured.

## Setup

1. Clone the repository:
   ```bash
   git clone https://github.com/wassimrkik/mlflow-ecs.git
   cd mlflow-ecs
   terraform init
   terraform apply
   ```