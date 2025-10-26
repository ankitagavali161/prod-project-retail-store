# Pet Toy Store - Docker Edition

A simplified Docker-based version of the AWS retail store sample application, focused on local development and testing.

## 🏪 About This Project

This project is a **fork and modification** of the official [AWS Retail Store Sample Application](https://github.com/aws-containers/retail-store-sample-app) by Amazon Web Services.

### Original Repository
- **Source**: [aws-containers/retail-store-sample-app](https://github.com/aws-containers/retail-store-sample-app)
- **License**: MIT-0 (as per original)
- **Copyright**: Amazon.com, Inc. or its affiliates

### What's Different
This version has been simplified for local development by removing:
- Kubernetes and Helm chart configurations
- Terraform infrastructure files
- CI/CD pipeline configurations
- Development environment files (devenv)

The application now runs purely on Docker Compose, making it easier to develop and test locally.

## 🚀 Quick Start

### Prerequisites
- Docker
- Docker Compose

### Running the Application

1. **Clone this repository**
   ```bash
   git clone <your-repo-url>
   cd pet-toystore
   ```

2. **Start all services**
   ```bash
   cd retail-store-sample-app/src/app
   docker compose up -d
   ```

3. **Access the application**
   - Main Application: http://localhost:8889
   - RabbitMQ Management: http://localhost:8161

### Services Overview

| Service | Technology | Port | Description |
|---------|------------|------|-------------|
| UI | Java/Spring Boot | 8889 | Frontend web application |
| Catalog | Go | 8081 | Product catalog service |
| Cart | Java/Spring Boot | 8082 | Shopping cart service |
| Orders | Java/Spring Boot | 8083 | Order management service |
| Checkout | Node.js/NestJS | 8085 | Checkout processing service |

### Databases
- **MariaDB**: Catalog data (port 3306)
- **DynamoDB Local**: Cart data (port 8000)
- **PostgreSQL**: Orders data (port 5432)
- **Redis**: Checkout sessions (port 6379)
- **RabbitMQ**: Message queuing (port 5672)

## 🛠️ Development

### Stopping the Application
```bash
docker compose down
```

### Rebuilding Services
```bash
docker compose build
docker compose up -d
```

### Viewing Logs
```bash
docker compose logs -f [service-name]
```

## 📝 License

This project maintains the same MIT-0 license as the original AWS retail store sample application.

```
Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
SPDX-License-Identifier: MIT-0
```

## 🙏 Acknowledgments

- **Original Authors**: AWS Containers team
- **Original Repository**: [aws-containers/retail-store-sample-app](https://github.com/aws-containers/retail-store-sample-app)
- **Purpose**: Simplified for local development and learning

## 📚 Original Documentation

For the complete original documentation, deployment options, and AWS-specific features, please refer to the [original repository](https://github.com/aws-containers/retail-store-sample-app).

---

*This is a community fork focused on local development. For production deployments and AWS-specific features, please use the original AWS repository.*
