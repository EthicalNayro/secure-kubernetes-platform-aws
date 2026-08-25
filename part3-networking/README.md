# Part 3: Namespace Isolation with Kubernetes NetworkPolicies

This phase deploys two NGINX applications in separate namespaces and uses Calico-enforced NetworkPolicies to allow same-namespace ingress while blocking cross-namespace ingress.

## Deploy

```bash
kubectl apply -f app1.yaml
kubectl apply -f app2.yaml
```

Each application includes a Namespace, ServiceAccount, ConfigMap, Deployment, Service, resource requests and limits, a readiness probe, and an ingress NetworkPolicy.

The NGINX image intentionally contains only the application runtime, so the checks use a temporary dedicated curl pod.

## Validate same-namespace traffic

```bash
kubectl run curl-test -n app1 \
  --image=curlimages/curl:8.10.1 \
  --restart=Never --command -- sleep 300

kubectl wait -n app1 --for=condition=Ready pod/curl-test --timeout=60s
kubectl exec -n app1 curl-test -- curl -s http://app1-svc
kubectl delete pod curl-test -n app1
```

Expected response:

```html
<h1>Hello from APP1</h1>
```

## Validate cross-namespace isolation

```bash
kubectl run curl-test -n app2 \
  --image=curlimages/curl:8.10.1 \
  --restart=Never --command -- sleep 300

kubectl wait -n app2 --for=condition=Ready pod/curl-test --timeout=60s
kubectl exec -n app2 curl-test -- \
  curl -sS --max-time 5 http://app1-svc.app1.svc.cluster.local
kubectl delete pod curl-test -n app2
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
