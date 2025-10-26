# Retail Store Sample App - Kubernetes Deployment

This directory contains Kubernetes manifests and deployment scripts for the AWS Retail Store Sample Application.

## Architecture

The application consists of the following microservices:

- **UI Service** (Java) - Frontend web application
- **Catalog Service** (Go) - Product catalog API with MariaDB
- **Cart Service** (Java) - Shopping cart API with DynamoDB Local
- **Checkout Service** (Node.js) - Checkout orchestration with Redis
- **Orders Service** (Java) - Order management with PostgreSQL and RabbitMQ

## Prerequisites

- Kubernetes cluster (v1.19+)
- `kubectl` configured to connect to your cluster
- Sufficient cluster resources (recommended: 4+ CPU cores, 8+ GB RAM)

## Quick Deployment

### Option 1: Automated Deployment Script

```bash
# Deploy the application
./deploy.sh

# Remove the application
./undeploy.sh
```

### Option 2: Manual Deployment

Deploy the manifests in order:

```bash
kubectl apply -f 01-namespace.yaml
kubectl apply -f 02-secrets.yaml
kubectl apply -f 03-configmaps.yaml
kubectl apply -f 04-databases.yaml

# Wait for databases to be ready
kubectl wait --for=condition=available --timeout=300s deployment/catalog-db -n retail-store
kubectl wait --for=condition=available --timeout=300s deployment/carts-db -n retail-store
kubectl wait --for=condition=available --timeout=300s deployment/checkout-redis -n retail-store
kubectl wait --for=condition=available --timeout=300s deployment/orders-db -n retail-store
kubectl wait --for=condition=available --timeout=300s deployment/rabbitmq -n retail-store

kubectl apply -f 05-catalog.yaml
kubectl apply -f 06-cart.yaml
kubectl apply -f 07-checkout.yaml
kubectl apply -f 08-orders.yaml
kubectl apply -f 09-ui.yaml
kubectl apply -f 10-ingress.yaml
```

## Accessing the Application

### Option 1: Port Forward (Recommended for Testing)

```bash
kubectl port-forward svc/ui 8080:8080 -n retail-store
```

Then open http://localhost:8080 in your browser.

### Option 2: LoadBalancer Service

If your cluster supports LoadBalancer services:

```bash
kubectl get svc ui-loadbalancer -n retail-store
```

Use the external IP or hostname to access the application.

### Option 3: Ingress (If nginx-ingress is installed)

1. Add to your `/etc/hosts` file:
   ```
   127.0.0.1 retail-store.local
   ```

2. Access the application at: http://retail-store.local

## Monitoring and Troubleshooting

### Check Pod Status

```bash
kubectl get pods -n retail-store
```

### Check Service Status

```bash
kubectl get svc -n retail-store
```

### View Logs

```bash
# View logs for a specific service
kubectl logs -f deployment/ui -n retail-store
kubectl logs -f deployment/catalog -n retail-store
kubectl logs -f deployment/cart -n retail-store
kubectl logs -f deployment/checkout -n retail-store
kubectl logs -f deployment/orders -n retail-store
```

### Check Database Status

```bash
# Check database pods
kubectl get pods -l app=catalog-db -n retail-store
kubectl get pods -l app=carts-db -n retail-store
kubectl get pods -l app=checkout-redis -n retail-store
kubectl get pods -l app=orders-db -n retail-store
kubectl get pods -l app=rabbitmq -n retail-store
```

## Configuration

### Environment Variables

The application uses ConfigMaps and Secrets for configuration:

- **ConfigMaps**: Service endpoints and non-sensitive configuration
- **Secrets**: Database passwords and API keys

### Scaling

To scale individual services:

```bash
kubectl scale deployment ui --replicas=3 -n retail-store
kubectl scale deployment catalog --replicas=3 -n retail-store
```

### Resource Limits

Each service has resource requests and limits configured. Adjust them in the deployment manifests if needed.

## Security Considerations

- All containers run as non-root users
- Security contexts are configured to drop unnecessary capabilities
- Read-only root filesystems where possible
- Secrets are used for sensitive data

## Cleanup

To remove the entire application:

```bash
# Using the script
./undeploy.sh

# Or manually
kubectl delete namespace retail-store
```

## File Structure

```
k8s/
├── 01-namespace.yaml      # Namespace definition
├── 02-secrets.yaml        # Database credentials and API keys
├── 03-configmaps.yaml     # Application configuration
├── 04-databases.yaml      # Database services (MariaDB, DynamoDB, Redis, PostgreSQL, RabbitMQ)
├── 05-catalog.yaml        # Catalog service deployment
├── 06-cart.yaml          # Cart service deployment
├── 07-checkout.yaml      # Checkout service deployment
├── 08-orders.yaml        # Orders service deployment
├── 09-ui.yaml            # UI service deployment
├── 10-ingress.yaml       # Ingress and LoadBalancer services
├── deploy.sh             # Automated deployment script
├── undeploy.sh           # Automated cleanup script
└── README.md             # This file
```

## Notes

- This is a sample application for educational purposes only
- The application uses pre-built container images from AWS ECR
- All services include health checks and proper resource limits
- The deployment is designed to be production-ready with security best practices
