# Home-Task: Automated Kubernetes Infrastructure
This project showcases a production-grade, secure, and monitored Kubernetes environment deployed on AWS. The infrastructure is fully automated using Terraform and managed via Helm, covering the entire lifecycle from cluster bootstrapping to advanced observability.




🛠️ Tech Stack
Infrastructure: AWS, Terraform.

Orchestration: Kubernetes.

Package Management: Helm Charts.

Observability: Prometheus, Grafana, Alertmanager.

Security: NetworkPolicies, AWS EC2 Security Groups.

🚀 Workflow
To reproduce the environment, follow these steps in order:

Infrastructure: Navigate to part1 and run terraform apply to provision the network and compute resources.

Cluster: Perform cluster bootstrapping in part2.

Networking: Apply the NetworkPolicies in part3 to enforce traffic security.

Monitoring: Deploy the Helm stack in part4 using the provided values.yaml.

📈 Observability & Alerts
Phase 4 features a custom PrometheusRule (NodeHighCPUUsage) that triggers an alert when CPU utilization exceeds 50%.

Grafana Dashboard: Exposed via NodePort '32000' (restricted to authorized IP).

Alertmanager: Exposed via NodePort '32001' (restricted to authorized IP).

Note: Each directory contains a dedicated README file with detailed instructions, execution commands, and verification screenshots.
