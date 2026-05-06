# Sample NGINX Workload

NGINX smoke test deployed via Helm to validate basic GKE cluster functionality (load balancer provisioning, pod scheduling, external connectivity).

## Deploy

```bash
helm repo add bitnami https://charts.bitnami.com/bitnami
helm repo update

helm install sample-nginx bitnami/nginx \
  --version 20.0.8 \
  --set service.type=LoadBalancer \
  --set replicaCount=2
```

## Validate

```bash
# Wait for external IP
kubectl get svc sample-nginx -w

# Run once IP is assigned
EXTERNAL_IP=$(kubectl get svc sample-nginx -o jsonpath='{.status.loadBalancer.ingress[0].ip}')
curl -I http://$EXTERNAL_IP
```

## Cleanup

```bash
helm uninstall sample-nginx
```
