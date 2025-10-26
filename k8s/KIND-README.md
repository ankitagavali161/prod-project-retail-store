# Retail Store Sample App - Kind Frugal Deployment

This directory contains a **frugal** Kubernetes deployment optimized for single-node Kind clusters with limited resources.

## 🎯 **Optimizations for Kind**

### **Resource Reductions:**
- **Single Replicas**: All deployments run with 1 replica instead of 2
- **Reduced Memory**: 50-75% reduction in memory requests/limits
- **Reduced CPU**: 50-75% reduction in CPU requests/limits
- **No Health Checks**: Removed liveness/readiness probes to save resources
- **Simplified Security**: Removed some security contexts to reduce overhead

### **Resource Summary:**
```
Total Estimated Usage:
• Memory: ~1.5GB (vs ~3GB in full deployment)
• CPU: ~1.5 cores (vs ~3 cores in full deployment)
• Pods: 10 total (5 databases + 5 applications)
```

## 🚀 **Quick Deployment**

### **Option 1: Automated Script (Recommended)**
```bash
cd k8s
./deploy-kind.sh
```

### **Option 2: Direct kubectl**
```bash
kubectl apply -f kind-frugal.yaml
```

## 🌐 **Accessing the Application**

### **Port Forward (Recommended)**
```bash
kubectl port-forward svc/ui 8080:8080 -n retail-store
# Open http://localhost:8080
```

### **NodePort (Kind)**
```bash
# Get Kind node IP
docker inspect <kind-cluster-name>-control-plane --format='{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}'

# Access via NodePort
http://<kind-node-ip>:30080
```

## 📊 **Monitoring**

### **Check Status**
```bash
# Pod status
kubectl get pods -n retail-store

# Service endpoints
kubectl get svc -n retail-store

# Resource usage (if metrics-server is installed)
kubectl top pods -n retail-store
```

### **View Logs**
```bash
# Application logs
kubectl logs -f deployment/ui -n retail-store
kubectl logs -f deployment/catalog -n retail-store
kubectl logs -f deployment/cart -n retail-store
kubectl logs -f deployment/checkout -n retail-store
kubectl logs -f deployment/orders -n retail-store

# Database logs
kubectl logs -f deployment/catalog-db -n retail-store
kubectl logs -f deployment/carts-db -n retail-store
kubectl logs -f deployment/checkout-redis -n retail-store
kubectl logs -f deployment/orders-db -n retail-store
kubectl logs -f deployment/rabbitmq -n retail-store
```

## 🧹 **Cleanup**

### **Remove Everything**
```bash
./undeploy-kind.sh
```

### **Or Manual Cleanup**
```bash
kubectl delete namespace retail-store
```

## ⚠️ **Important Notes**

### **Kind Cluster Requirements:**
- **Minimum**: 4GB RAM, 2 CPU cores
- **Recommended**: 6GB RAM, 3 CPU cores
- **Docker**: At least 8GB available space

### **Limitations:**
- **No High Availability**: Single replicas mean no failover
- **No Health Checks**: Pods may not restart automatically on failure
- **Reduced Performance**: Lower resource limits may cause slower response times
- **No Load Balancing**: Single replica means no load distribution

### **Troubleshooting:**

#### **Out of Memory Issues:**
```bash
# Check cluster resources
kubectl describe nodes

# Check pod resource usage
kubectl top pods -n retail-store

# If pods are OOMKilled, increase Kind cluster resources
```

#### **Slow Performance:**
- This is expected with reduced resources
- Consider increasing Kind cluster memory/CPU
- Monitor with `kubectl top pods -n retail-store`

#### **Pod Startup Issues:**
```bash
# Check pod events
kubectl describe pod <pod-name> -n retail-store

# Check logs
kubectl logs <pod-name> -n retail-store
```

## 🔧 **Customization**

### **Increase Resources (if you have more space):**
Edit `kind-frugal.yaml` and increase the `resources.requests` and `resources.limits` values.

### **Add Health Checks:**
Add back the `livenessProbe` and `readinessProbe` sections from the full deployment manifests.

### **Scale Up:**
```bash
kubectl scale deployment ui --replicas=2 -n retail-store
kubectl scale deployment catalog --replicas=2 -n retail-store
```

## 📁 **Files**

- `kind-frugal.yaml` - Frugal deployment manifest
- `deploy-kind.sh` - Automated deployment script
- `undeploy-kind.sh` - Cleanup script
- `KIND-README.md` - This documentation

## 🆚 **Comparison with Full Deployment**

| Feature | Full Deployment | Frugal Deployment |
|---------|----------------|-------------------|
| Replicas | 2 per service | 1 per service |
| Memory | ~3GB total | ~1.5GB total |
| CPU | ~3 cores total | ~1.5 cores total |
| Health Checks | ✅ Full probes | ❌ None |
| Security | ✅ Full context | ⚠️ Simplified |
| High Availability | ✅ Yes | ❌ No |
| Load Balancing | ✅ Yes | ❌ No |

This frugal deployment is perfect for development, testing, and learning on resource-constrained Kind clusters!
