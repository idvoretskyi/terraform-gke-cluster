# Rock Paper Scissors Arena

An interactive Rock Paper Scissors game with statistics tracking and a leaderboard, deployed on GKE.

## Endpoints

| Path | Method | Description |
|------|--------|-------------|
| `/` | GET | Game UI |
| `/play` | POST | Submit a move (JSON) |
| `/api/stats` | GET | Statistics (JSON) |
| `/health` | GET | Health check |

### Play a game

```bash
curl -X POST http://EXTERNAL_IP/play \
  -H "Content-Type: application/json" \
  -d '{"player_name": "alice", "player_move": "rock"}'
```

Valid moves: `rock`, `paper`, `scissors`.

## Deployment

### Prerequisites

- GKE cluster running and `kubectl` configured
- Docker with `buildx` support
- [`kustomize`](https://kubectl.docs.kubernetes.io/installation/kustomize/) or `kubectl` ≥ 1.14

### 1. Build and push the image

```bash
export PROJECT_ID=$(gcloud config get-value project)
export TAG=$(git rev-parse --short HEAD)

docker buildx build --platform linux/amd64 \
  -t gcr.io/$PROJECT_ID/rock-paper-scissors-game:$TAG . --push
```

### 2. Set the image in Kustomize

```bash
kustomize edit set image \
  rock-paper-scissors-game=gcr.io/$PROJECT_ID/rock-paper-scissors-game:$TAG
```

This updates `kustomization.yaml` in-place — commit the change to track the deployed revision.

### 3. Apply

```bash
kubectl apply -k .
```

### 4. Get the external IP

```bash
kubectl get svc rock-paper-scissors-service -n workloads
```

## Local development

```bash
go run .
# http://localhost:8080
```

```bash
docker build -t rock-paper-scissors-game .
docker run --rm -p 8080:8080 rock-paper-scissors-game
```

## Observability

```bash
kubectl get deployments,pods,services,hpa,pdb -n workloads -o wide
kubectl logs -f deployment/rock-paper-scissors-game -n workloads
kubectl top pods -l app=rock-paper-scissors-game -n workloads
```

## Architecture

- **Backend**: Go HTTP server, in-memory storage
- **Namespace**: `workloads`
- **Replicas**: 2, autoscaled up to 10 via HPA
- **Security**: distroless runtime, non-root (UID 65532), read-only filesystem, dropped capabilities, `RuntimeDefault` seccomp
- **Load balancer**: GCP external LoadBalancer
