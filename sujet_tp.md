# TP Express — Log4Shell (CVE-2021-44228)

- **Durée :** 30 minutes (5 min intro + 25 min TP)
- **Objectif :** Comprendre, exploiter (localement), et corriger la célèbre faille Log4Shell.

> 📋 **Livrable attendu :** 
> Ouvrez un fichier texte vierge (votre compte-rendu). À chaque étape, vous devrez simplement y copier-coller les **commandes que vous avez utilisées et qui ont fonctionné**, ainsi que les réponses courtes demandées. L'objectif est d'aller à l'essentiel, pas de faire de la grande rédaction !

---

## 🧠 Introduction : 5 minutes de questions

Avant de commencer la pratique, répondez (à l'oral ou par écrit) à ces quelques questions pour bien poser le contexte :

1. **Qu'est-ce que Log4j et pourquoi est-il autant utilisé en entreprise ?**
2. **À quoi sert le protocole JNDI dans l'écosystème Java ?**
3. **Pourquoi la vulnérabilité Log4Shell a-t-elle fait trembler internet fin 2021 ?**

> 📝 **Compte-rendu :** Si demandé par l'intervenant, notez brièvement vos réponses (une ou deux phrases par question).

---

## 🚀 Étape 1 : Lancement et observation des logs

L'environnement est prêt. Vous avez à votre disposition un script `start.sh` à la racine qui va lancer simultanément l'application vulnérable (via Docker) et un serveur DNS local (pour observer les attaques).

1. **Lancez l'environnement :**
   Ouvrez un terminal et exécutez :
   ```bash
   ./start.sh
   ```
2. **Vérifiez que l'application répond bien :**
   Dans un *deuxième* terminal, lancez une requête classique :
   ```bash
   curl http://localhost:8081 -H 'X-Api-Version: 1.0'
   ```
3. **Observez les logs :**
   Regardez le premier terminal où tourne votre script. Vous devriez voir que l'application enregistre la version de l'API demandée.
4. **Votre mission :** 
   Faites en sorte que la phrase **"One for all, All for Hedi"** apparaisse textuellement dans les logs de l'application en modifiant votre requête HTTP (la commande `curl`).

> 📝 **Compte-rendu :** Notez la commande `curl` complète que vous avez utilisée pour réussir cette mission.

---

## 🎯 Étape 2 : L'Exploitation via DNS Callback

La faille Log4Shell réside dans le fait que Log4j permet d'évaluer dynamiquement du texte placé entre `${...}` au moment de l'écriture des logs, et notamment de contacter un serveur externe via JNDI. 
Puisque le serveur DNS de démonstration tourne sur votre propre machine (port UDP 8053), nous allons forcer l'application à s'y connecter.

**Votre mission :**
En utilisant la fonctionnalité de *lookup* JNDI avec le protocole DNS (la syntaxe commence par `${jndi:dns://...}`), construisez une nouvelle requête HTTP qui va forcer l'application vulnérable à envoyer une requête DNS à votre machine locale (`host.docker.internal`). 

Le but est de faire apparaître **votre prénom** dans les logs de votre serveur DNS local.

> 📝 **Compte-rendu :** Notez la commande `curl` contenant le payload JNDI que vous avez utilisée et qui a fait réagir le serveur DNS.

---

## 🎨 Étape 3 : Schématisation

Maintenant que vous avez réussi l'attaque, dessinez un petit schéma (sur papier ou traitement de texte) représentant les 4 étapes de l'attaque :
1. Vous (le client / l'attaquant)
2. L'application (Spring Boot / Log4j)
3. L'API JNDI
4. Le serveur DNS (votre machine locale)

*Faites valider votre schéma par l'intervenant pour vérifier que vous avez bien compris le flux de la donnée.*

> 📝 **Compte-rendu :** Si vous faites le schéma sur ordinateur, incluez-le ou prenez-le en capture d'écran. Sinon, montrez-le simplement à l'intervenant.

---

## 🛡️ Étape 4 : Remédiation

Dans l'urgence, pour bloquer la faille Log4Shell sans avoir à modifier le code source de l'application (valable pour Log4j versions 2.10 à 2.14.1), on peut désactiver la fonctionnalité de "lookup" des messages.

1. **Arrêtez votre script `start.sh`** (faites `Ctrl+C` dans le premier terminal).
2. **Appliquez le correctif (mitigation) :**
   Relancez manuellement le conteneur Docker en lui passant la variable d'environnement `LOG4J_FORMAT_MSG_NO_LOOKUPS=true` :
   ```bash
   docker run -d --rm --name vulnerable-app -p 8081:8080 -e LOG4J_FORMAT_MSG_NO_LOOKUPS=true log4shell-demo
   ```
   Et dans un autre terminal, relancez le DNS :
   ```bash
   cd src/log4shell-listener
   source venv/bin/activate
   python3 listener.py
   ```
3. **Vérification :**
   Relancez votre attaque de l'Étape 2. 
   - Que se passe-t-il dans les logs de l'application Docker (`docker logs vulnerable-app`) ? 
   - La requête DNS part-elle toujours ?

> 📝 **Compte-rendu :** Copiez la commande `docker run` utilisée et répondez en une courte phrase aux deux questions de vérification (ex: "Le log affiche X, et la requête DNS ne part plus").

---

## 📝 Étape 5 : Conclusion

En un petit paragraphe, expliquez avec vos propres mots comment fonctionne Log4Shell selon ce que vous avez compris aujourd'hui. D'où vient le danger ?

> 📝 **Compte-rendu :** Rédigez votre explication finale (3 ou 4 lignes maximum).