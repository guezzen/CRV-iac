# Étape 1: Utiliser l'image officielle de Node.js
FROM node:16

# Étape 2: Créer et définir le répertoire de travail
WORKDIR /app

# Étape 3: Copier le package.json et installer les dépendances
COPY package*.json ./
RUN npm install --force

# Étape 4: Copier tous les fichiers du serveur Node.js
COPY . .

# Étape 5: Exposer le port utilisé par le serveur Node.js (par défaut 3000)
EXPOSE 3000

# Étape 6: Configurer l'URL de connexion à Redis en tant que variable d'environnement
# Ici, l'adresse Redis est configurée pour se connecter à Redis sur "redis-container:6379".
# Remplace "redis-container" par le nom ou l'IP de ton conteneur Redis.
ENV REDIS_URL redis://redis-container:6379

# Étape 7: Démarrer le serveur Node.js
CMD ["npm", "start"]

