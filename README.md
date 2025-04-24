# CRV-iac  
## TME6 & TME7 – Déploiement d'une application web avec Redis, Node.js et React

---

## 🔧 Objectif

Déployer une application web composée de trois services :
- Un serveur **Redis**
- Un backend **Node.js** qui interagit avec Redis
- Un frontend **React** qui communique avec le backend

---

## 🧪 TME6 – Construction et test local avec Podman

### 1. Arborescence du projet

```
Iac/
├── redis/
├── node-redis/
└── react-frontend/
```

### 2. Création des images

Dans chaque dossier :

#### 🟥 Backend Node.js (`node-redis`)
```bash
podman build -t node-redis-server .
```

#### 🟦 Frontend React (`react-frontend`)
```bash
podman build -t redis-frontend .
```

#### Redis (image officielle)
Pas besoin de build :
```bash
podman pull redis
```

### 3. Lancement en local avec Podman

Création d'un réseau :
```bash
podman network create redisnet
```

Déploiement :
```bash
podman run -d --name redis-container --network redisnet -p 6379:6379 redis
podman run -d --name node-server --network redisnet -p 8080:8080 node-redis-server
podman run -d --name frontend --network redisnet -p 5400:80 redis-frontend
```

### 4. Tests

- Ajout de clé/valeur via l'interface React
- Vérification de la connexion entre les conteneurs
- Débogage de l'accès Redis via `host.containers.internal` (ping impossible → solution : réseau commun)

---

## ☸️ TME7 – Déploiement avec Minikube + Kubernetes

### 1. Lancement de Minikube avec Podman

```bash
minikube start --driver=podman
```

⚠️ Podman doit être en version ≥ 4.9

### 2. Chargement des images locales dans Minikube

```bash
minikube image load node-redis-server
minikube image load redis-frontend
```

### 3. Fichiers de déploiement Kubernetes

#### `redis/`
- `redis-deployment.yaml`
- `redis-service.yaml`

#### `node-redis/`
- `node-redis-deployment.yaml`
- `node-redis-service.yaml`

#### `react-frontend/`
- `frontend-deployment.yaml`
- `frontend-service.yaml`

### 4. Application des fichiers YAML

```bash
kubectl apply -f redis/
kubectl apply -f node-redis/
kubectl apply -f react-frontend/
```

### 5. Vérification des pods

```bash
kubectl get pods
kubectl describe pod <nom-du-pod>
```

### 6. Accès à l'application

```bash
minikube service frontend-service
```

---

## ✅ Résultats

- Les trois composants sont déployés avec succès via Kubernetes.
- La communication interservices fonctionne.
- L’interface React permet d’ajouter et d’afficher des paires clé/valeur via le backend Node.js connecté à Redis.

---

## 🧠 Problèmes rencontrés

- `host.containers.internal` inaccessible via Podman → résolu avec `--network redisnet`
- Minikube ne trouve pas les images locales → résolu avec `minikube image load`
- Version Podman < 4.9 → message ignoré temporairement

---

## 📁 À faire

- Ajouter des readiness/liveness probes dans les YAML
- Ajouter un Ingress Controller (optionnel)

---

# TME8 — Infrastructure Kubernetes avec AutoScaling et Monitoring

## 📦 Architecture

- 🎯 React (Frontend) — Appelle le serveur NodeJS  
- ⚙️ NodeJS (Backend) — Accède à Redis (lecture/écriture)  
- 🛢️ Redis (Primary + Replicas) — Base de données avec réplication  
- 📈 Prometheus — Récupère les métriques du backend  
- 📊 Grafana — Affiche les métriques récupérées  



## ✅ Objectifs

- Déploiement de l'application complète dans Kubernetes  
- Mise en place de Redis avec un pattern master/replica  
- Auto-scaling des pods NodeJS et Redis replicas  
- Monitoring du système via Prometheus et Grafana  

## 🗂️ Structure du projet

```
Iac/
├── React/
│   └── redis-replica-hpa.yml
├── NodeJs/
│   ├── node-hpa.yml
├── Redis/
│   ├── redis-deployment.yml
│   ├── redis-replica-deployment.yml
│   └── redis-service.yml
├── monitoring/
│   ├── prometheus-deployment.yml
│   ├── prometheus-service.yml
│   ├── grafana-deployment.yml
│   └── grafana-service.yml
└── README.md
```

## ⚙️ Déploiement

1. Lancer Minikube :
```bash
minikube start
```

2. Déployer les composants :
```bash
kubectl apply -f Redis/
kubectl apply -f NodeJs/
kubectl apply -f React/
kubectl apply -f monitoring/
```

3. Vérifier le statut :
```bash
kubectl get pods
kubectl get svc
```

4. Accéder à Grafana :
```bash
minikube service grafana-service
```

- Utilisateur : admin  
- Mot de passe : admin  
- Ajouter Prometheus comme source de données : http://prometheus-service:9090  

## 📈 Monitoring

- NodeJS expose ses métriques via l’endpoint `/metrics` (format Prometheus)  
- Prometheus scrape cet endpoint  
- Grafana affiche les métriques en dashboard (requêtes HTTP, temps de réponse, charge CPU...)  

Tu peux utiliser l’exporter officiel Redis : `bitnami/redis-exporter` pour exposer les métriques Redis si tu veux aller plus loin.

## ⚖️ AutoScaling

- AutoScaling horizontal via HPA basé sur la consommation CPU.  
- Possible d’ajouter des métriques personnalisées via Prometheus Adapter.  



- Observer la montée en charge avec :
```bash
kubectl get pods -w
```

---

📌 Projet réalisé dans le cadre du cours de Cloud & Réseaux Virtuels — Sorbonne Université
