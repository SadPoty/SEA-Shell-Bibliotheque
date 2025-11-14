# Système de Gestion de Bibliothèque Personnelle

**Projet réalisé dans le cadre du cours [Nom du Cours]**
**Durée : 2 semaines + présentation en semaine 3**
**Date de livraison : 28 Novembre 2025 22:30H**

---

## 📚 Description du Projet

Ce projet consiste à développer un **système de gestion de bibliothèque personnelle** utilisant uniquement des fichiers plats (CSV/texte) pour stocker et manipuler les données. L’objectif est de permettre à un utilisateur de gérer sa collection de livres, d’effectuer des recherches, de générer des statistiques et de gérer les emprunts, le tout via une interface en ligne de commande interactive.

---

## 🎯 Objectifs Pédagogiques

- Manipulation de fichiers texte (CSV, TXT)
- Gestion de données structurées sans base de données
- Création d’un menu interactif et d’une interface utilisateur
- Implémentation de fonctions de recherche et de filtrage

---

## 🔧 Fonctionnalités

### Gestion des Livres
- **Ajout** : Ajouter un livre avec génération automatique d’ID
- **Modification** : Modifier un livre existant
- **Suppression** : Supprimer un livre
- **Liste** : Lister tous les livres (avec pagination)

### Recherche et Filtres
- Recherche par titre (recherche partielle)
- Recherche par auteur
- Filtre par genre
- Filtre par année (plage de dates)
- Recherche avancée (plusieurs critères combinés)

### Statistiques et Rapports
- Nombre total de livres
- Répartition par genre (graphique ASCII)
- Top 5 auteurs les plus présents
- Livres par décennie
- Export des résultats en HTML ou PDF

### Gestion des Emprunts
- Emprunter un livre
- Retourner un livre
- Lister les livres empruntés
- Alertes pour retards
- Historique des emprunts

---

## 📂 Structure du Projet

| Fichier | Description |
|---------|-------------|
| `bibliotheque.sh` | Script principal (menu interactif) |
| `lib_functions.sh` | Bibliothèque de fonctions |
| `livres.txt` | Fichier de stockage des livres (format: `ID|Titre|Auteur|Année|Genre|Statut`) |
| `emprunts.txt` | Fichier de stockage des emprunts (format: `ID_Livre|Emprunteur|Date_Emprunt|Date_Retour_Prévue`) |
| `README.md` | Documentation du projet |

---

## 👥 Équipe de Développement

| Nom | Numéro étudiant | Rôle / Partie développée |
|-----|-----------------|--------------------------|
| [Nom 1] | [Numéro 1] | [Exemple : Gestion des livres, menu principal] |
| [Nom 2] | [Numéro 2] | [Exemple : Recherche et filtres, statistiques] |
| [Nom 3] | [Numéro 3] | [Exemple : Gestion des emprunts, sauvegarde] |

---

## 🛠️ Contraintes Techniques

- **Pas de base de données** : Utilisation exclusive de fichiers texte
- **Menu interactif** : Navigation intuitive
- **Validation des saisies** : Contrôle des entrées utilisateur
- **Sauvegarde automatique** : Après chaque modification
- **Backup quotidien** : Système de sauvegarde automatique

---

## 📊 Jeux de Données de Test

Un jeu de données de test est fourni pour faciliter les tests et la démonstration :
- `livres_test.txt`
- `emprunts_test.txt`

---

## 📌 Instructions d’Installation et d’Utilisation

1. Cloner le dépôt ou télécharger les fichiers.
2. Donner les droits d’exécution aux scripts :
   ```bash
   chmod +x bibliotheque.sh
