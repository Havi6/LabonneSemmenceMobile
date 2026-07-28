# Téléchargement de la Galerie Photos

L'application permet désormais de télécharger les photos de la galerie pour une consultation hors-ligne, en complément des sermons.

## Changements Réalisés

### 1. Gestion des Photos dans le Service de Téléchargement
- **Extension du Service** : `DownloadService` a été mis à jour pour supporter les objets `GalleryItem`.
- **Métadonnées unifiées** : Le fichier de métadonnées local (`metadata.json`) stocke désormais à la fois les sermons et les photos téléchargées dans une structure organisée.
- **Stockage structuré** : Les fichiers sont organisés dans des sous-dossiers `downloads/sermons/` et `downloads/gallery/`.

### 2. Interface de Consultation
- **Bouton de Téléchargement** : Un bouton de téléchargement a été ajouté dans la barre d'outils de la vue plein écran des photos (`ImageViewer`).
- **Retour de progression** : Comme pour les sermons, un indicateur de progression circulaire s'affiche pendant le téléchargement.

### 3. Page "Mes Téléchargements" Améliorée
- **Organisation par Onglets** : La page a été refondue pour utiliser des onglets (`TabBar`) permettant de basculer facilement entre les **Sermons** et les **Photos**.
- **Grille de Photos** : Les photos téléchargées sont présentées sous forme de grille interactive, optimisant l'espace visuel.
- **Suppression Facilitée** : Chaque élément peut être supprimé individuellement, libérant l'espace disque.

## Détails Techniques
- **Persistance** : Utilisation de `toJson()` sur `GalleryItem` pour conserver les titres et IDs originaux.
- **Mode Hors-ligne** : L'application détecte automatiquement si une photo est présente localement et utilise le fichier disque au lieu du réseau si nécessaire.

> [!TIP]
> Vous pouvez maintenant emporter vos moments forts avec vous, même sans connexion internet !
