# README — Simulation Monte-Carlo : Arbre de Décision vs Forêt Aléatoire

Ce projet compare les performances prédictives et les temps de calcul de deux algorithmes d'apprentissage supervisé — l'arbre de décision (rpart) et la forêt aléatoire (randomForest) — à travers une simulation Monte-Carlo rigoureuse.

## Objectif

Évaluer si les forêts aléatoires surpassent systématiquement les arbres de décision dans divers contextes de complexité des données (nombre d'observations, nombre de variables, relation linéaire vs quadratique).

## Méthodologie

* **8 scénarios simulés** : combinaison de tailles d'échantillons (petite vs grande), nombre de prédicteurs (petit vs élevé) et relations (linéaire vs quadratique).
* **1000 répétitions par scénario** : robustesse statistique assurée.
* **Métriques évaluées** : Erreur Quadratique Moyenne (EQM), temps d'entraînement.
* **Comparaison visuelle** : graphiques ggplot2 des EQM moyens (avec écart-types) et des temps d'entraînement moyens.

## Fichiers principaux

* `Projet_simulation_final_V3.r` : script R principal qui génère les données, entraîne les modèles, mesure les performances et produit les graphiques comparatifs.
* `Rapport.pdf` : rapport détaillant les résultats, conclusions et recommandations basées sur les analyses.

## Résultats clés

* La forêt aléatoire offre des performances prédictives supérieures dans tous les scénarios.
* L'avantage est particulièrement marqué dans les scénarios complexes (grande taille d'échantillon, nombreuses variables, relation quadratique).
* Le coût computationnel des forêts est plus élevé, mais justifié par une meilleure robustesse et précision.

## Exécution

1. Ouvrir le script `Projet_simulation_final_V3.r` dans RStudio.
2. Exécuter l'ensemble du code pour générer les résultats et graphiques.
3. Les résultats sont exportés dans `resultats_simulation.csv`.

## Technologies

* R, ggplot2, dplyr, tidyr, rpart, randomForest

Ce projet fournit une base solide pour comparer des algorithmes supervisés dans des contextes simulés, et peut facilement être adapté à d'autres méthodes ou scénarios expérimentaux.
