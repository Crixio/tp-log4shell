#!/bin/bash

# Définition des chemins
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" &> /dev/null && pwd)"
SRC_DIR="$SCRIPT_DIR/src"

# Fonction pour tout arrêter proprement quand on fait Ctrl+C
cleanup() {
    echo -e "\nArrêt du script..."
    echo "Arrêt du conteneur vulnerable-app..."
    docker stop vulnerable-app >/dev/null 2>&1
    exit 0
}

# Capture le signal d'interruption (Ctrl+C)
trap cleanup SIGINT SIGTERM

echo "=== Lancement de l'application vulnérable (Docker) ==="
# On arrête et supprime un éventuel conteneur existant avec le même nom
docker stop vulnerable-app >/dev/null 2>&1

# Vérifie si l'image Docker existe déjà, sinon on la construit
if ! docker image inspect log4shell-demo >/dev/null 2>&1; then
    echo "L'image Docker 'log4shell-demo' n'existe pas. Construction en cours (cela peut prendre 1 à 2 minutes)..."
    cd "$SRC_DIR/log4shell-vulnerable-app"
    docker build -t log4shell-demo .
    if [ $? -ne 0 ]; then
        echo "Erreur fatale lors de la construction de l'image Docker. Vérifiez que Docker est bien allumé sur votre machine."
        exit 1
    fi
    cd "$SCRIPT_DIR"
fi

# On lance le conteneur en arrière-plan (-d) avec le port 8081
docker run -d --rm --name vulnerable-app --add-host=host.docker.internal:host-gateway -p 8081:8080 log4shell-demo

# Vérifie si le conteneur s'est bien lancé
if [ $? -ne 0 ]; then
    echo "Erreur lors du lancement de l'application Docker."
    echo "Assurez-vous que l'image 'log4shell-demo' est bien construite :"
    echo "  cd src/log4shell-vulnerable-app && docker build -t log4shell-demo ."
    exit 1
fi

echo -e "Application lancée sur http://localhost:8081\n"

echo "=== Lancement du serveur DNS (Listener) ==="
cd "$SRC_DIR/log4shell-listener"

# Activation ou création de l'environnement virtuel python
if [ ! -d "venv" ]; then
    echo "Installation des dépendances Python (dnslib)..."
    if ! python3 -m venv venv; then
        echo -e "\n❌ ERREUR : Impossible de créer l'environnement Python."
        echo "Sur une machine Linux vierge (Ubuntu/Debian), il manque le paquet venv."
        echo "Veuillez exécuter cette commande puis relancez le script :"
        echo -e "\033[1;33msudo apt update && sudo apt install python3-venv python3-pip -y\033[0m\n"
        exit 1
    fi
    
    source venv/bin/activate
    
    if ! pip install dnslib; then
        echo -e "\n❌ ERREUR : Impossible d'installer dnslib via pip."
        exit 1
    fi
else
    source venv/bin/activate
fi

# Lance le script python en premier plan, on reste bloqué ici jusqu'à Ctrl+C
python3 listener.py

# Si listener.py s'arrête de lui-même, on s'assure d'arrêter le conteneur Docker
cleanup
