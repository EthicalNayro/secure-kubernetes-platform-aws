# Part 4: Observability Stack (Prometheus & Grafana)

This component deploys the Prometheus and Grafana monitoring stack via Helm to monitor the single-node Kubernetes cluster, configures a custom high CPU alert, and exposes the dashboards securely.

## Infrastructure & Security Group Configuration

Before deploying the monitoring stack, the AWS Security Group ingress rules were updated via Terraform to allow secure external access to the monitoring UIs. The infrastructure changes were applied **in-place** without interrupting or recreating the existing EC2 node.

Access is strictly restricted to the administrator's public IP (`My ip`) on the following custom NodePorts:
* **Grafana Dashboard:** Port `32000`
* **Alertmanager Dashboard:** Port `32001`

---

## Deployment

### 1. Installation Commands
To add the official repository and deploy the stack using our custom configurations:

```bash
# Add and update the Prometheus community Helm repo
helm repo add prometheus-community [https://prometheus-community.github.io/helm-charts](https://prometheus-community.github.io/helm-charts)
helm repo update

# Install the chart using our custom values file
kubectl create namespace monitoring
helm install kube-prometheus-stack prometheus-community/kube-prometheus-stack -n monitoring -f values.yaml
```
## 2. Verified Helm Values Configuration
The values.yaml file includes the NodePort definition for Grafana access and the Prometheus custom rule for alerting when CPU usage exceeds 50%:
```
grafana:
  service:
    type: NodePort
    nodePort: 32000

alertmanager:
  service:
    type: NodePort
    nodePort: 32001

additionalPrometheusRulesMap:
  custom-node-alerts:
    groups:
      - name: node-cpu-alert-group
        rules:
          - alert: NodeHighCPUUsage
            expr: 100 - (avg by(instance) (rate(node_cpu_seconds_total{mode="idle"}[1m])) * 100) > 50
            for: 1m
            labels:
              severity: critical
            annotations:
              summary: "High CPU usage detected on node {{ $labels.instance }}"
              description: "CPU usage has been above 50% for more than 1 minute."
```

## Validation & Alerts Verification
### 1. Accessing the Dashboards
With the Security Group rules applied, both dashboards are securely accessible from the allowed IP via the EC2 Public IP:

Grafana: http://18.197.168.228:32000

Alertmanager: http://18.197.168.228:32001

### 2. Triggering High CPU Load
To trigger the custom alert condition, a CPU stress load was generated directly on the EC2 node.

### 3. Alert Evidence (Firing)
Alertmanager Proof
[ INSERT ALERTMANAGER SCREENSHOT OR CLI PROOF HERE ]

Grafana Alerting Dashboard Proof
[ INSERT GRAFANA SCREENSHOT HERE ]
