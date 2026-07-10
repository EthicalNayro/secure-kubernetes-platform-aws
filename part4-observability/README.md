# Part 4: Observability Stack (Prometheus & Grafana)

📋 Design Explanation
We deployed the production-grade kube-prometheus-stack via Helm to monitor cluster-wide metrics.

Security & Isolation: The stack was deployed in a dedicated monitoring namespace. Access to Grafana and Alertmanager is restricted at the AWS infrastructure level using EC2 Security Groups, limiting traffic exclusively to the administrator's IP address.

Alerting: A custom native PrometheusRule (NodeHighCPUUsage) was injected via Helm values to fire when any node's CPU usage exceeds 50% for more than 1 minute.

## Infrastructure & Security Group Configuration

Before deploying the monitoring stack, the AWS Security Group ingress rules were updated via Terraform to allow secure external access to the monitoring UIs. The infrastructure changes were applied **in-place** without interrupting or recreating the existing EC2 node.

Access is strictly restricted to the administrator's public IP (`My ip`) on the following custom NodePorts:
* **Grafana Dashboard:** Port `32000`
* **Alertmanager Dashboard:** Port `32001`

### new changes to the ingress:
```
resource "aws_security_group" "k8s" {
  name        = "k8s-sg"
  description = "Security group for Kubernetes node"
  vpc_id      = var.vpc_id

  ingress {
    description = "SSH access"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.my_ip]
  }

  ingress {
    description = "Grafana NodePort"
    from_port   = 32000
    to_port     = 32000
    protocol    = "tcp"
    cidr_blocks = [var.my_ip]
  }

  ingress {
    description = "Alertmanager NodePort"
    from_port   = 32001
    to_port     = 32001
    protocol    = "tcp"
    cidr_blocks = [var.my_ip]
  }

  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
```
### Then Terraform Apply
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

```bash
# Generate synthetic CPU stress in the background
yes > /dev/null &
yes > /dev/null &
```
### 3. Alert Evidence (Firing)
Grafana Alerting Dashboard Proof:
After the high CPU condition sustained for over 1 minute, the rule successfully transitioned into Firing status, indicating that Prometheus scraped the metric and Grafana evaluated the rule correctly:

[ INSERT ALERTMANAGER SCREENSHOT OR CLI PROOF HERE ]

Alertmanager UI Proof
The alert was successfully routed to the Alertmanager cluster component on port 32001 for notification management:
[ INSERT ALERTMANAGER SCREENSHOT OR CLI PROOF HERE ]

### 4. Post-Verification Teardown
Once the firing state was verified and captured, the synthetic load was safely terminated to bring the EC2 node back to normal baseline operations:
```bash
# Terminate the stress processes
pkill yes
```
