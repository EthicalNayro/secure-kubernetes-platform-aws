# Part 3: Namespaces, Workloads, and Network Policies

This component deploys two isolated applications (`app1` and `app2`) in separate Kubernetes namespaces and enforces network isolation using Kubernetes NetworkPolicies.

## Deployment

Deploy the applications:

```bash
kubectl apply -f app1.yaml
kubectl apply -f app2.yaml
```

---

## Validation

### Same-Namespace Traffic (Allowed ✅)

Testing communication inside the same namespace:

```bash
kubectl exec -n app1 deploy/app1-nginx -- curl -s http://app1-svc
```

Expected output:

```html
<h1>Hello from APP1</h1>
```

Result: Communication within the namespace is allowed.

---

### Cross-Namespace Traffic (Blocked ❌)

Testing communication between different namespaces:

```bash
kubectl exec -n app2 deploy/app2-nginx -- curl -s --max-time 5 [http://app1-svc.app1.svc.cluster.local](http://app1-svc.app1.svc.cluster.local)
```

Expected output:

```text
curl: (28) Connection timed out after 5001 milliseconds
```

Result: Cross-namespace communication is blocked.

---

## NetworkPolicy Logic

Each namespace uses an Ingress NetworkPolicy with a default-deny posture.

Allowed:

* Traffic from pods inside the same namespace.

Blocked:

* Traffic originating from other namespaces.

This ensures workload isolation between `app1` and `app2`.
