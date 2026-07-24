# Plan d'implémentation - Fiabilisation du chargement des images et des données

Ce plan vise à corriger les problèmes d'affichage des images et des listes au lancement de l'application en rendant le parsing des données JSON plus robuste et flexible.

## Problèmes identifiés
1. **Structure JSON** : Le serveur peut renvoyer des données imbriquées différemment selon l'endpoint.
2. **Identification des images** : Les fichiers sans extension (URLs de téléchargement direct) sont actuellement ignorés.
3. **Fallbacks manquants** : Certains modèles n'ont pas de mécanisme de secours si l'URL de l'image n'est pas explicitement fournie.

## Proposed Changes

### [Services](file:///C:/Users/Pontsho/Documents/Project/LabonneSemmenceMobile/lib/services/app_data.dart)

#### [MODIFY] [app_data.dart](file:///C:/Users/Pontsho/Documents/Project/LabonneSemmenceMobile/lib/services/app_data.dart)

- **`_readList`** : Ajouter une recherche récursive pour extraire la liste de données quel que soit le nom de la clé (`data`, `files`, `items`, etc.).
- **`_readString`** : Étendre la recherche aux clés `path`, `uri`, `id`, `_id`, `filepath`.
- **`_isImage`** : Assouplir la détection pour accepter les URLs qui semblent être des endpoints de téléchargement d'images même sans extension explicite.
- **`Event.fromJson`** : Ajouter un fallback vers `_fileUrl(id)` si aucune image n'est trouvée.
- **`_normalizeUrl`** : Améliorer la gestion des chemins pour éviter les doubles slashes.

## Verification Plan

### Manual Verification
- Lancer l'application.
- Vérifier l'affichage des carrousels sur l'écran d'accueil.
- Vérifier que les pages Galerie et Événements affichent bien leurs contenus.
- Inspecter les logs de débogage pour confirmer la normalisation des URLs.
