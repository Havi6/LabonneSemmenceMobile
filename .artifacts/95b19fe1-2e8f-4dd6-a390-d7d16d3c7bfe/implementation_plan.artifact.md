# Ajout de miniatures aux cartes de dévotions (sermons textes)

Ce plan détaille l'ajout d'une miniature aux cartes des dévotions quotidiennes (appelées "sermons textes" par l'utilisateur). Ces miniatures seront récupérées depuis le serveur via le champ `image_url`.

## User Review Required

> [!IMPORTANT]
> Les miniatures seront affichées si le serveur renvoie une URL d'image. Un substitut (icône par défaut) sera affiché si aucune image n'est disponible.

## Proposed Changes

### Modèle de données

#### [MODIFY] [entities.dart](file:///C:/Users/Pontsho/Documents/Project/LabonneSemmenceMobile/lib/models/entities.dart)
- Ajouter le champ `imageUrl` à la classe `DailyDevotion`.
- Mettre à jour `fromJson` pour extraire l'URL de l'image (via `image_url`, `imageUrl` ou `image`).
- Mettre à jour `toJson` pour inclure l'URL de l'image.

### Interface Utilisateur (UI)

#### [MODIFY] [home_page.dart](file:///C:/Users/Pontsho/Documents/Project/LabonneSemmenceMobile/lib/pages/home_page.dart)
- Modifier `_buildDailyDevotionCard` pour afficher l'image en arrière-plan ou en miniature à côté du texte.
- Utiliser un `Stack` pour superposer le texte sur l'image si elle est présente, ou garder le dégradé actuel comme fallback.

#### [MODIFY] [sermons_page.dart](file:///C:/Users/Pontsho/Documents/Project/LabonneSemmenceMobile/lib/pages/sermons_page.dart)
- Modifier `_buildDevotionsTab` pour remplacer l'icône statique par l'image provenant du serveur dans le `leading` du `ListTile`.

#### [MODIFY] [daily_devotion_detail_page.dart](file:///C:/Users/Pontsho/Documents/Project/LabonneSemmenceMobile/lib/pages/daily_devotion_detail_page.dart)
- Ajouter l'affichage de l'image en haut de la page de détail pour une meilleure cohérence visuelle.

### Administration (Optionnel mais cohérent)

#### [MODIFY] [admin_page.dart](file:///C:/Users/Pontsho/Documents/Project/LabonneSemmenceMobile/lib/pages/admin_page.dart)
- Ajouter le support de l'image dans l'éditeur de dévotions quotidiennes (`_showDailyDevotionEditor`).

## Verification Plan

### Manual Verification
1. Lancer l'application.
2. Vérifier la carte "Prière du Jour" sur la page d'accueil.
3. Vérifier l'onglet "Prières" dans la page des sermons.
4. Cliquer sur une dévotion pour voir si l'image s'affiche dans les détails.
5. (Si possible) Tester avec une dévotion ayant une image et une sans image pour vérifier le fallback.
