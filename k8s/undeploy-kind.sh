#!/bin/bash

# Retail Store Sample App - Kind Frugal Undeployment Script
# Removes the frugal deployment from Kind cluster

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

print_status "Starting removal of Retail Store Sample App from Kind cluster..."

# Get the directory where the script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Remove the frugal deployment
print_status "Removing frugal deployment..."
kubectl delete -f "$SCRIPT_DIR/kind-frugal.yaml" --ignore-not-found=true

print_success "Frugal deployment removal completed successfully!"
print_warning "All resources in the retail-store namespace have been deleted."
print_status "Your Kind cluster resources have been freed up."
