# Plan d'implémentation - Téléchargement des Exhortations et Prières du Jour

Ce plan vise à rendre visible et fonctionnel le téléchargement des exhortations vocales et des prières quotidiennes dans la section "Mes téléchargements". Bien que les boutons de téléchargement existent déjà dans les détails, ces éléments ne sont pas encore affichés dans la liste des téléchargements.

## User Review Required

> [!IMPORTANT]
> Les prières du jour sont composées uniquement de texte, leur "téléchargement" consiste donc à sauvegarder les données textuelles localement pour une consultation hors-ligne. Les exhortations vocales incluent le téléchargement du fichier audio (.mp3).

## Proposed Changes

### 1. Service de Téléchargement

#### [MODIFY] [download_service.dart](file:///C:/Users/Pontsho/Documents/Project/LabonneSemmenceMobile/lib/services/download_service.dart)
- Correction des clés de métadonnées pour les exhortations afin qu'elles soient correctement rechargées au démarrage (utilisation de `createdAt` au lieu de `scheduled_date`).

### 2. Interface Utilisateur (UI)

#### [MODIFY] [downloads_page.dart](file:///C:/Users/Pontsho/Documents/Project/LabonneSemmenceMobile/lib/pages/downloads_page.dart)
- Ajout de deux nouveaux onglets dans la `TabBar` : "Exhortations" et "Dévotions".
- Implémentation de `_ExhortationDownloads` pour lister les audios téléchargés avec possibilité de lecture.
- Implémentation de `_DevotionDownloads` pour lister les prières sauvegardées avec possibilité de lecture.
- Mise à jour du nombre d'onglets (`length: 4`).

## Verification Plan

### Manual Verification
1.  Ouvrir une exhortation vocale et cliquer sur le bouton de téléchargement.
2.  Ouvrir une prière du jour et cliquer sur le bouton de téléchargement.
3.  Aller dans le menu "Mes téléchargements".
4.  Vérifier que les nouveaux onglets "Exhortations" et "Dévotions" sont présents.
5.  Vérifier que les éléments téléchargés s'y trouvent et peuvent être ouverts (même sans connexion).
6.  Vérifier que la suppression d'un téléchargement fonctionne pour ces nouveaux types.
