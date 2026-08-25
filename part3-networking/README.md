# Part 3: Namespace Isolation with Kubernetes NetworkPolicies

This phase deploys two NGINX applications in separate namespaces and uses Calico-enforced NetworkPolicies to allow same-namespace ingress while blocking cross-namespace ingress.

## Deploy

```bash
kubectl apply -f app1.yaml
kubectl apply -f app2.yaml
```

Each application includes a Namespace, ServiceAccount, ConfigMap, Deployment, Service, resource requests and limits, a readiness probe, and an ingress NetworkPolicy.

## Validate same-namespace traffic

```bash
kubectl exec -n app1 deploy/app1-nginx -- curl -s http://app1-svc
```

Expected response:

```html
<h1>Hello from APP1</h1>
```

## Validate cross-namespace isolation

```bash
kubectl exec -n app2 deploy/app2-nginx -- \
  curl -s --max-time 5 http://app1-svc.app1.svc.cluster.local
```

Expected result:

```text
curl: (28) Connection timed out after 5000 milliseconds
```

## Policy behavior

- Pods can receive ingress traffic from pods in the same namespace.
- Ingress traffic originating in another namespace is denied.
- Egress is not restricted by these policies.

This proves the isolation behavior directly instead of relying only on manifest inspection.
