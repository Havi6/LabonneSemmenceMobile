# Plan d'ajout d'image aux sermons, sélecteurs de date/heure et correction de la gestion d'erreurs

L'objectif est d'enrichir la fonctionnalité de téléversement de sermons, d'améliorer l'expérience utilisateur avec des sélecteurs natifs, et de fiabiliser la remontée des erreurs lors des opérations d'administration (upload, création, mise à jour).

## User Review Required

> [!IMPORTANT]
> L'ajout des champs `image_url` et `image_caption` (ou `legende`) aux sermons nécessite que le backend accepte ces nouveaux champs.
> La correction de la gestion d'erreurs impactera la façon dont les messages d'erreur du serveur sont extraits et affichés.

## Proposed Changes

### [Core API & Models]

#### [MODIFY] [api_client.dart](file:///C:/Users/Pontsho/Documents/Project/LabonneSemmenceMobile/lib/services/apiService/api_client.dart)
- Améliorer `_extractError` pour retourner le corps de la réponse si c'est une chaîne de caractères (cas des erreurs non-JSON du serveur).
- S'assurer que les exceptions réseau sont mieux identifiées.

#### [MODIFY] [app_data.dart](file:///C:/Users/Pontsho/Documents/Project/LabonneSemmenceMobile/lib/services/app_data.dart)
- Mise à jour de la classe `Sermon` pour inclure `imageUrl` et `imageCaption`.
- Mise à jour des méthodes `fromJson` et `toJson` de `Sermon`.
- S'assurer que `uploadAsset` propage correctement les erreurs détaillées.

### [Admin UI]

#### [MODIFY] [admin_page.dart](file:///C:/Users/Pontsho/Documents/Project/LabonneSemmenceMobile/lib/pages/admin_page.dart)
- Améliorer `_showEditor` pour :
    - Supporter les sélecteurs de date et d'heure.
    - Gérer la validation des fichiers obligatoires (ex: l'audio pour un sermon).
- Modifier `_showSermonEditor` :
    - Ajouter les champs `imageUrl` et `imageCaption`.
    - Gérer le double upload (audio + image).
    - Utiliser le sélecteur de date pour le champ `date`.
- Modifier `_showEventEditor` :
    - Utiliser les sélecteurs de date et d'heure.
- Améliorer `_message(error)` dans `_AdminPageState` pour inclure plus de détails si disponible.

## Verification Plan

### Manual Verification
1. **Gestion d'erreurs** : Simuler une erreur serveur (ex: déconnexion ou mauvais format de fichier) et vérifier que le message affiché est pertinent et non générique.
2. **Sermons** : Ajouter un sermon avec une image et une légende, et vérifier l'upload.
3. **Sélecteurs** : Vérifier que cliquer sur les champs Date ou Heure ouvre les sélecteurs natifs respectifs dans les formulaires Sermon et Événement.
