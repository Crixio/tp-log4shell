# TP — Log4Shell (CVE-2021-44228) 💥

Un environnement complet et "prêt à l'emploi" pour découvrir, comprendre et exploiter (localement) la célèbre vulnérabilité **Log4Shell** dans un format court et dynamique d'environ 30 minutes.

## 🎯 Objectif du TP
Ce TP est conçu pour aller à l'essentiel :
1. **Comprendre** le rôle de Log4j et de JNDI.
2. **Observer** les logs d'une application Spring Boot vulnérable.
3. **Exploiter** la faille pour déclencher un *callback* vers un faux serveur DNS local.
4. **Appliquer une remédiation** immédiate sans modifier le code source.

## 🗂️ Contenu du dépôt
- 📄 **`sujet_tp.md`** : L'énoncé complet du TP étape par étape.
- 🚀 **`start.sh`** : Le script magique qui s'occupe de tout (installation des dépendances, création du réseau Docker, lancement de l'application et du faux serveur DNS).
- 🧹 **`clean.sh`** : Pour nettoyer l'environnement (arrête les conteneurs et les processus Python).
- 📁 **`src/`** : Le code source de l'application vulnérable (Java/Spring) et du script Python (`listener.py`).

## 🛠️ Prérequis
Pour que l'environnement fonctionne, il suffit d'avoir sur sa machine :
- **Docker** installé et allumé.
- **Python 3** (avec `pip` et `venv` disponibles).

*(Testé et optimisé pour macOS et Linux).*

## 🚀 Démarrage Rapide

1. Clonez ce dépôt :
   ```bash
   git clone https://github.com/VOTRE_PSEUDO/tp-log4shell.git
   cd tp-log4shell
   ```

2. Lancez l'environnement :
   ```bash
   chmod +x start.sh clean.sh
   ./start.sh
   ```

3. Suivez les instructions du fichier `sujet_tp.md` !

> ⚠️ **Avertissement :** Ce projet contient volontairement une application vulnérable. Il est destiné **exclusivement à un usage pédagogique** dans un environnement contrôlé (localhost).