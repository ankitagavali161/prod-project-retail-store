#!/bin/bash

# Retail Store Sample App - Kind Frugal Deployment Script
# Optimized for single-node Kind clusters with limited resources

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if kubectl is installed
if ! command -v kubectl &> /dev/null; then
    print_error "kubectl is not installed. Please install kubectl first."
    exit 1
fi

# Check if kubectl can connect to cluster
if ! kubectl cluster-info &> /dev/null; then
    print_error "Cannot connect to Kubernetes cluster. Please check your kubeconfig."
    exit 1
fi

# Check if we're connected to a Kind cluster
CLUSTER_CONTEXT=$(kubectl config current-context)
if [[ ! "$CLUSTER_CONTEXT" =~ "kind" ]]; then
    print_warning "You don't appear to be connected to a Kind cluster."
    print_warning "Current context: $CLUSTER_CONTEXT"
    print_warning "This script is optimized for Kind clusters."
    read -p "Continue anyway? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        exit 1
    fi
fi

print_status "Starting frugal deployment of Retail Store Sample App to Kind cluster..."
print_status "This deployment is optimized for single-node clusters with limited resources."

# Get the directory where the script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Deploy the frugal manifest
print_status "Deploying frugal manifest (single replica, reduced resources)..."
kubectl apply -f "$SCRIPT_DIR/kind-frugal.yaml"

print_status "Waiting for databases to be ready..."
kubectl wait --for=condition=available --timeout=300s deployment/catalog-db -n retail-store || true
kubectl wait --for=condition=available --timeout=300s deployment/carts-db -n retail-store || true
kubectl wait --for=condition=available --timeout=300s deployment/checkout-redis -n retail-store || true
kubectl wait --for=condition=available --timeout=300s deployment/orders-db -n retail-store || true
kubectl wait --for=condition=available --timeout=300s deployment/rabbitmq -n retail-store || true

print_status "Waiting for application services to be ready..."
kubectl wait --for=condition=available --timeout=300s deployment/catalog -n retail-store || true
kubectl wait --for=condition=available --timeout=300s deployment/cart -n retail-store || true
kubectl wait --for=condition=available --timeout=300s deployment/checkout -n retail-store || true
kubectl wait --for=condition=available --timeout=300s deployment/orders -n retail-store || true
kubectl wait --for=condition=available --timeout=300s deployment/ui -n retail-store || true

print_success "Frugal deployment completed successfully!"

# Display access information
print_status "Getting access information..."

echo ""
echo "=========================================="
echo "  Retail Store Sample App - Kind Access"
echo "=========================================="
echo ""

# Get Kind cluster info
KIND_CLUSTER_NAME=$(kubectl config current-context | sed 's/kind-//')
KIND_NODE_IP=$(docker inspect "${KIND_CLUSTER_NAME}-control-plane" --format='{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' 2>/dev/null || echo "127.0.0.1")

echo "🌐 Kind Cluster Access:"
echo "   Cluster: $KIND_CLUSTER_NAME"
echo "   Node IP: $KIND_NODE_IP"
echo "   NodePort URL: http://$KIND_NODE_IP:30080"
echo ""

# Port forward option
echo "🔧 Port Forward Access (Recommended):"
echo "   Run: kubectl port-forward svc/ui 8080:8080 -n retail-store"
echo "   Then open: http://localhost:8080"
echo ""

# Service information
echo "📊 Service Endpoints:"
kubectl get svc -n retail-store
echo ""

# Pod status
echo "🚀 Pod Status:"
kubectl get pods -n retail-store
echo ""

# Resource usage
echo "💾 Resource Usage:"
kubectl top pods -n retail-store 2>/dev/null || echo "   (Metrics server not available - run 'kubectl top nodes' to check cluster resources)"
echo ""

print_success "Retail Store Sample App is now running on your Kind cluster!"
print_warning "Note: This is a frugal deployment optimized for limited resources."
print_warning "All services run with single replicas and reduced resource limits."

# Show resource summary
echo ""
echo "📋 Resource Summary:"
echo "   • All deployments: 1 replica each"
echo "   • Total estimated memory: ~1.5GB"
echo "   • Total estimated CPU: ~1.5 cores"
echo "   • Databases: MariaDB, DynamoDB Local, Redis, PostgreSQL, RabbitMQ"
echo "   • Applications: UI, Catalog, Cart, Checkout, Orders"
echo ""
