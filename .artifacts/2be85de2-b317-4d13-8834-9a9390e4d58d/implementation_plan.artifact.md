# Plan d'Implémentation : Téléchargement de la Galerie Photos

Ce plan détaille l'ajout de la fonctionnalité de téléchargement pour les images de la galerie, permettant leur consultation hors-ligne dans la page "Mes téléchargements".

## Changements Proposés

### 1. Modèles [MODIFY] [entities.dart](file:///C:/Users/Pontsho/Documents/Project/LabonneSemmenceMobile/lib/models/entities.dart)
- Ajouter la méthode `toJson()` à la classe `GalleryItem` pour permettre la persistance des métadonnées locales.

### 2. Service de Téléchargement [MODIFY] [download_service.dart](file:///C:/Users/Pontsho/Documents/Project/LabonneSemmenceMobile/lib/services/download_service.dart)
- Ajouter une liste `_downloadedGallery` pour suivre les images téléchargées.
- Implémenter la méthode `downloadGalleryItem(GalleryItem item)` pour télécharger l'image et sauvegarder ses métadonnées.
- Mettre à jour `isDownloaded(String? id)` pour vérifier également dans la galerie.
- Mettre à jour `_loadMetadata()` et `_saveMetadata()` pour gérer à la fois les sermons et les images de la galerie.
- Implémenter `deleteGalleryDownload(String id)`.

### 3. Interface Galerie [MODIFY] [galery_page.dart](file:///C:/Users/Pontsho/Documents/Project/LabonneSemmenceMobile/lib/pages/galery_page.dart) & [image_viewer.dart](file:///C:/Users/Pontsho/Documents/Project/LabonneSemmenceMobile/lib/widget/image_viewer.dart)
- Ajouter un bouton de téléchargement sur chaque image de la galerie (dans `GaleryPage` ou `ImageViewer`).
- Afficher un indicateur de progression ou un état "Téléchargé".

### 4. Page des Téléchargements [MODIFY] [downloads_page.dart](file:///C:/Users/Pontsho/Documents/Project/LabonneSemmenceMobile/lib/pages/downloads_page.dart)
- Ajouter une section ou un onglet pour différencier les "Sermons" des "Photos".
- Permettre la visualisation et la suppression des photos téléchargées.

## Questions Ouvertes
- Préférez-vous des onglets (Tabs) dans "Mes téléchargements" ou une simple liste segmentée par titres de section ?
- Le téléchargement doit-il être déclenché depuis la grille de la galerie ou seulement quand on ouvre l'image en plein écran ?

## Plan de Vérification
### Manuel
- Télécharger une image depuis la galerie.
- Vérifier qu'elle apparaît dans "Mes téléchargements".
- Vérifier qu'elle est consultable sans connexion internet (en utilisant le chemin local).
- Supprimer le téléchargement et vérifier que le fichier est bien retiré du disque.
