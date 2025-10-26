#!/bin/bash

# Retail Store Sample App - Kubernetes Undeployment Script
# This script removes the retail store sample application from Kubernetes

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

print_status "Starting removal of Retail Store Sample App from Kubernetes..."

# Get the directory where the script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Remove in reverse order
print_status "Removing ingress..."
kubectl delete -f "$SCRIPT_DIR/10-ingress.yaml" --ignore-not-found=true

print_status "Removing application services..."
kubectl delete -f "$SCRIPT_DIR/09-ui.yaml" --ignore-not-found=true
kubectl delete -f "$SCRIPT_DIR/08-orders.yaml" --ignore-not-found=true
kubectl delete -f "$SCRIPT_DIR/07-checkout.yaml" --ignore-not-found=true
kubectl delete -f "$SCRIPT_DIR/06-cart.yaml" --ignore-not-found=true
kubectl delete -f "$SCRIPT_DIR/05-catalog.yaml" --ignore-not-found=true

print_status "Removing databases..."
kubectl delete -f "$SCRIPT_DIR/04-databases.yaml" --ignore-not-found=true

print_status "Removing configmaps..."
kubectl delete -f "$SCRIPT_DIR/03-configmaps.yaml" --ignore-not-found=true

print_status "Removing secrets..."
kubectl delete -f "$SCRIPT_DIR/02-secrets.yaml" --ignore-not-found=true

print_status "Removing namespace..."
kubectl delete -f "$SCRIPT_DIR/01-namespace.yaml" --ignore-not-found=true

print_success "Removal completed successfully!"
print_warning "All resources in the retail-store namespace have been deleted."
