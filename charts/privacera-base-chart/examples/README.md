# 📁 **Chart Examples**

This directory contains comprehensive examples demonstrating various deployment patterns and configurations for the Privacera Helm Chart. Each example showcases different use cases and chart capabilities.

## ☁️ **Cloud-Agnostic Design**

This Helm chart is **fully cloud-agnostic** and works on **any** Kubernetes cluster:
- ☁️ **AWS EKS** (Amazon Elastic Kubernetes Service)
- ☁️ **Azure AKS** (Azure Kubernetes Service)
- ☁️ **GCP GKE** (Google Kubernetes Engine)
- 🏢 On-premises Kubernetes clusters
- 📦 Any other Kubernetes distribution

The chart uses conditional cloud-specific configurations. See values.yaml `ingress.aws`, `ingress.azure`, `ingress.gcp` blocks.

## 🚀 **Available Examples**

| Example | Workload Type | Description | Use Case |
|---------|---------------|-------------|----------|
| `basic-microservice.yaml` | **Deployment** | Simple 2-replica setup with health checks | Development/Testing |
| `production-microservice.yaml` | **Deployment** | Full production setup with HPA, advanced security | Production Web Services |
| `advanced-microservice.yaml` | **Deployment** | Complex setup with init containers, sidecars, KEDA scaling | Advanced Microservices |
| `multi-container-microservice.yaml` | **Deployment** | Service mesh pattern with nginx proxy and sidecars | Multi-container Applications |
| `database-statefulset.yaml` | **StatefulSet** | PostgreSQL database with persistent storage | Stateful Applications |
| `testing-examples.yaml` | **Deployment** | Comprehensive validation configuration | Testing/Validation |

## 🏗️ **Workload Types**

### **Deployment (Default)**
- **Use for:** Stateless applications, web services, APIs
- **Features:** Rolling updates, horizontal scaling, load balancing
- **Storage:** Ephemeral or shared volumes

### **StatefulSet** 
- **Use for:** Databases, stateful services, applications requiring stable network identity
- **Features:** Ordered deployment, stable hostnames, persistent per-pod storage
- **Storage:** Individual persistent volume claims per pod

## 📋 **Configuration Selection**

### **Values Files**
- **`values.yaml`** - Default configuration optimized for **Deployments** (stateless applications)
- **`values-statefulset.yaml`** - Comprehensive reference for **StatefulSets** (stateful applications)

### **Choosing Workload Type**
To switch between Deployment and StatefulSet:

```yaml
# For stateless applications (default in values.yaml)
deployment:
  enabled: true
statefulset:
  enabled: false

# For stateful applications (default in values-statefulset.yaml)
deployment:
  enabled: false  
statefulset:
  enabled: true
```

## 🔧 **StatefulSet-Specific Configuration**

When using StatefulSet (`statefulset.enabled: true`), additional configuration options are available.
See `values-statefulset.yaml` for comprehensive examples and documentation.

### **StatefulSet Settings**
```yaml
statefulset:
  enabled: true
  serviceName: ""  # Headless service name (auto-generated if empty)
  podManagementPolicy: "OrderedReady"  # or "Parallel"
  updateStrategy:
    type: "RollingUpdate"
    rollingUpdate:
      maxUnavailable: 1
      # partition: 0  # For canary updates
```

### **Persistent Storage**
```yaml
statefulset:
  volumeClaimTemplates:
    - metadata:
        name: "data"
        annotations:
          volume.beta.kubernetes.io/storage-class: "gp2"
      spec:
        accessModes: ["ReadWriteOnce"]
        storageClassName: "gp2"
        resources:
          requests:
            storage: "50Gi"
```

### **Headless Service**
StatefulSets require a headless service for stable network identity:

```yaml
service:
  headless:
    enabled: true  # Required for StatefulSets
    name: ""  # Auto-generated as "fullname-headless"
    publishNotReadyAddresses: true  # Include not-ready pods in DNS
```

## 🗄️ **Database Example (StatefulSet)**

The `database-statefulset.yaml` example demonstrates a production-ready PostgreSQL setup:

- **Storage:** Separate volumes for data (50Gi) and WAL logs (10Gi)
- **Replication:** 3 replicas (1 primary + 2 replicas)
- **Networking:** Headless service for peer discovery
- **Security:** Non-root containers, network policies, secrets
- **Initialization:** Init container for directory setup
- **Configuration:** PostgreSQL-specific ConfigMaps

## 🧪 **Testing Examples**

### **Template Rendering**
```bash
# Test Deployment example
helm template test-deployment chart/ -f chart/examples/basic-microservice.yaml

# Test StatefulSet example  
helm template test-statefulset chart/ -f chart/examples/database-statefulset.yaml
```

### **Validation Script**
```bash
# Run all example validations
./scripts/test-examples.sh

# Test specific example
./scripts/test-examples.sh database-statefulset
```

## 📖 **Usage Examples**

### **Basic Development Setup**
```bash
helm install my-app chart/ -f chart/examples/basic-microservice.yaml
```

### **Production Web Service**
```bash
helm install my-service chart/ -f chart/examples/production-microservice.yaml
```

### **Database Deployment**
```bash
# Using StatefulSet example
helm install postgres-db chart/ -f chart/examples/database-statefulset.yaml

# Using StatefulSet values template
helm install postgres-db chart/ -f chart/values-statefulset.yaml
```

## 🔄 **Migration Between Workload Types**

⚠️ **Important:** You cannot directly change workload types in-place. To migrate:

1. **Backup data** (for StatefulSets)
2. **Uninstall** existing release
3. **Update** configuration (`deployment.enabled: false` + `statefulset.enabled: true`)
4. **Reinstall** with new configuration
5. **Restore data** (if applicable)

## 🔍 **Feature Comparison**

| Feature | Deployment | StatefulSet | Notes |
|---------|------------|-------------|-------|
| **Replica Scaling** | ✅ Parallel | ✅ Sequential | StatefulSet scales pods in order |
| **Rolling Updates** | ✅ Configurable | ✅ One-by-one | StatefulSet updates sequentially |
| **Persistent Storage** | ✅ Shared | ✅ Per-pod | StatefulSet provides individual PVCs |
| **Network Identity** | ❌ Random | ✅ Stable | StatefulSet provides stable hostnames |
| **Headless Service** | ⚠️ Optional | ✅ Required | Must be enabled for StatefulSets |
| **Init Containers** | ✅ | ✅ | Supported in both workload types |
| **Sidecar Containers** | ✅ | ✅ | Supported in both workload types |
| **KEDA Autoscaling** | ✅ | ✅ | Works with both workload types |

## 🎯 **Best Practices**

### **For Deployments:**
- Use for stateless applications
- Configure resource limits appropriately
- Use rolling update strategy for zero-downtime deployments
- Enable horizontal pod autoscaling for variable load

### **For StatefulSets:**
- Plan storage requirements carefully  
- Use stable network identities for peer discovery
- Configure proper backup strategies for persistent data
- Consider using `podManagementPolicy: Parallel` for faster scaling when order doesn't matter

## 🤝 **Contributing**

To add new examples:

1. Create a new YAML file in this directory
2. Follow the naming convention: `purpose-workloadtype.yaml`
3. Include comprehensive comments explaining the configuration
4. Test with the validation script
5. Update this README with the new example

For questions or improvements, please open an issue or pull request. 