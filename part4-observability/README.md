# Part 4: Observability Stack (Prometheus & Grafana)

This component deploys the Prometheus and Grafana monitoring stack via Helm to monitor the single-node Kubernetes cluster, configures a custom high CPU alert, and exposes Grafana via NodePort.

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
# 1. Accessing Grafana
Grafana is exposed on NodePort 32000. Access was restricted to the administrator's public IP inside the EC2 Security Group.

# 2. Triggering High CPU Load
To trigger the custom alert condition, a CPU stress load was generated directly on the EC2 node.

# 3. Alert Evidence (Firing)
Alertmanager Proof
[ INSERT ALERTMANAGER SCREENSHOT OR CLI PROOF HERE ]

Grafana Alerting Dashboard Proof
[ INSERT GRAFANA SCREENSHOT HERE ]
