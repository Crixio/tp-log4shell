#!/bin/bash

echo "🧹 Nettoyage de l'environnement Log4Shell..."

echo "📦 Arrêt et suppression des conteneurs Docker..."
# On arrête le conteneur vulnérable s'il tourne encore
docker stop vulnerable-app >/dev/null 2>&1
# On le supprime (au cas où il n'aurait pas été lancé avec --rm)
docker rm vulnerable-app >/dev/null 2>&1

# Sécurité supplémentaire si le nom vuln-app avait été utilisé
docker stop vuln-app >/dev/null 2>&1
docker rm vuln-app >/dev/null 2>&1

echo "🐍 Fermeture du serveur DNS local..."
# On cherche et on tue tous les processus Python qui font tourner "listener.py"
pkill -f "listener.py" >/dev/null 2>&1

echo "✨ Nettoyage terminé ! L'environnement est prêt pour un prochain lancement."
