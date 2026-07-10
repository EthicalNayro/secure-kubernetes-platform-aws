# Part 3: Namespaces, Workloads, and Network Policies

This component deploys two isolated applications (`app1` and `app2`) in separate namespaces and enforces strict network isolation using Kubernetes NetworkPolicies.

---

## 1. Deployment Commands
To deploy both applications and their network configurations, execute the following commands:

```bash
kubectl apply -f app1.yaml
kubectl apply -f app2.yaml
```

## 2. Verification & Traffic Validation (Evidence)
Same-Namespace Traffic (Allowed ✅)
Testing connectivity between pods inside the same namespace (app1 to app1-svc):

```bash
kubectl exec -n app1 deploy/app1-nginx -- curl -s http://app1-svc
```
```bash
Output:
<h1>Hello from APP1</h1>
```
Cross-Namespace Traffic (Blocked ❌)
Testing connectivity between different namespaces (app2 to app1-svc):
```bash
kubectl exec -n app2 deploy/app2-nginx -- curl -s --max-time 5 [http://app1-svc.app1.svc.cluster.local](http://app1-svc.app1.svc.cluster.local)
```
```bash
Output:
curl: (28) Connection timed out after 5001 milliseconds
```

## 3. NetworkPolicy Logic Explanation
Default Posture: By default, Kubernetes allows unrestricted communication between all pods across all namespaces.

Isolation Mechanics: Once an Ingress NetworkPolicy selects a pod (using podSelector: {} to target all pods in the namespace), it immediately switches the namespace to a "default deny" posture for inbound traffic.

Whitelisting: We explicitly allowed traffic coming only from a blank podSelector: {} within the same namespace boundary. As a result, Calico drops any packet originating from external namespaces (like app2 trying to reach app1), successfully enforcing the cross-namespace block.
