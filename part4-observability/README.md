# Part 4: Observability and Alerting

This phase deploys the `kube-prometheus-stack` Helm chart into a dedicated `monitoring` namespace. It provides Prometheus, Grafana, Alertmanager, kube-state-metrics, and node-exporter.

## Security model

Grafana and Alertmanager use fixed NodePorts for this lab:

| Service | NodePort | Allowed source |
| --- | --- | --- |
| Grafana | 32000 | Administrator CIDR only |
| Alertmanager | 32001 | Administrator CIDR only |

The matching AWS Security Group rules are managed in `part1-terraform-infrastructure/modules/security_group/main.tf`. No dashboard port is opened to `0.0.0.0/0`.

## Deploy

```bash
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update

helm upgrade --install kube-prometheus-stack prometheus-community/kube-prometheus-stack \
  --namespace monitoring \
  --create-namespace \
  --values values.yaml
```

## Custom alert

`values.yaml` defines `NodeHighCPUUsage`, which enters a firing state when average node CPU usage remains above 50% for more than one minute.

```promql
100 - (avg by(instance) (rate(node_cpu_seconds_total{mode="idle"}[1m])) * 100) > 50
```

The short threshold and duration are intentional so the complete alert lifecycle can be demonstrated in a small lab. Production thresholds should be based on workload baselines and service-level objectives.

## Access

Replace `<EC2_PUBLIC_IP>` with the Terraform output. Requests succeed only from the CIDR configured in `my_ip`.

```text
Grafana:      http://<EC2_PUBLIC_IP>:32000
Alertmanager: http://<EC2_PUBLIC_IP>:32001
```

### Grafana access

![Grafana dashboard access through the restricted NodePort](images/grafana-access.png)

## Trigger and verify the alert

Generate temporary CPU load on the EC2 node:

```bash
yes > /dev/null &
yes > /dev/null &
```

![CPU load generated on the Kubernetes node](images/top-applying-stress.png)

After the alert is observed in Grafana and Alertmanager, stop the test processes:

```bash
pkill yes
```

## Alert lifecycle evidence

### CPU alert firing

![NodeHighCPUUsage alert firing in Grafana](images/grafana-CPU-alert.png)

### Alert routed to Alertmanager

![NodeHighCPUUsage alert visible in Alertmanager](images/Altermanager-main.png)

### Alert recovery

![NodeHighCPUUsage alert recovered after CPU load was removed](images/grafana-CPU-fixed.png)
