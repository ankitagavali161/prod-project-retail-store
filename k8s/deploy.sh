#!/bin/bash

# Retail Store Sample App - Kubernetes Deployment Script
# This script deploys the retail store sample application to Kubernetes

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

print_status "Starting deployment of Retail Store Sample App to Kubernetes..."

# Get the directory where the script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Deploy in order
print_status "Creating namespace..."
kubectl apply -f "$SCRIPT_DIR/01-namespace.yaml"

print_status "Creating secrets..."
kubectl apply -f "$SCRIPT_DIR/02-secrets.yaml"

print_status "Creating configmaps..."
kubectl apply -f "$SCRIPT_DIR/03-configmaps.yaml"

print_status "Deploying databases..."
kubectl apply -f "$SCRIPT_DIR/04-databases.yaml"

print_status "Waiting for databases to be ready..."
kubectl wait --for=condition=available --timeout=300s deployment/catalog-db -n retail-store
kubectl wait --for=condition=available --timeout=300s deployment/carts-db -n retail-store
kubectl wait --for=condition=available --timeout=300s deployment/checkout-redis -n retail-store
kubectl wait --for=condition=available --timeout=300s deployment/orders-db -n retail-store
kubectl wait --for=condition=available --timeout=300s deployment/rabbitmq -n retail-store

print_status "Deploying application services..."
kubectl apply -f "$SCRIPT_DIR/05-catalog.yaml"
kubectl apply -f "$SCRIPT_DIR/06-cart.yaml"
kubectl apply -f "$SCRIPT_DIR/07-checkout.yaml"
kubectl apply -f "$SCRIPT_DIR/08-orders.yaml"
kubectl apply -f "$SCRIPT_DIR/09-ui.yaml"

print_status "Waiting for application services to be ready..."
kubectl wait --for=condition=available --timeout=300s deployment/catalog -n retail-store
kubectl wait --for=condition=available --timeout=300s deployment/cart -n retail-store
kubectl wait --for=condition=available --timeout=300s deployment/checkout -n retail-store
kubectl wait --for=condition=available --timeout=300s deployment/orders -n retail-store
kubectl wait --for=condition=available --timeout=300s deployment/ui -n retail-store

print_status "Creating ingress..."
kubectl apply -f "$SCRIPT_DIR/10-ingress.yaml"

print_success "Deployment completed successfully!"

# Display access information
print_status "Getting access information..."

echo ""
echo "=========================================="
echo "  Retail Store Sample App - Access Info"
echo "=========================================="
echo ""

# Check if LoadBalancer service is available
LB_IP=$(kubectl get svc ui-loadbalancer -n retail-store -o jsonpath='{.status.loadBalancer.ingress[0].ip}' 2>/dev/null || echo "")
LB_HOSTNAME=$(kubectl get svc ui-loadbalancer -n retail-store -o jsonpath='{.status.loadBalancer.ingress[0].hostname}' 2>/dev/null || echo "")

if [ -n "$LB_IP" ]; then
    echo "🌐 LoadBalancer Access:"
    echo "   URL: http://$LB_IP"
    echo ""
elif [ -n "$LB_HOSTNAME" ]; then
    echo "🌐 LoadBalancer Access:"
    echo "   URL: http://$LB_HOSTNAME"
    echo ""
fi

# Port forward option
echo "🔧 Port Forward Access:"
echo "   Run: kubectl port-forward svc/ui 8080:8080 -n retail-store"
echo "   Then open: http://localhost:8080"
echo ""

# Ingress information
echo "🌍 Ingress Access (if nginx-ingress is installed):"
echo "   Add to /etc/hosts: 127.0.0.1 retail-store.local"
echo "   URL: http://retail-store.local"
echo ""

# Service information
echo "📊 Service Endpoints:"
kubectl get svc -n retail-store
echo ""

# Pod status
echo "🚀 Pod Status:"
kubectl get pods -n retail-store
echo ""

print_success "Retail Store Sample App is now running on Kubernetes!"
print_warning "Note: This is a sample application for educational purposes only."
