# Réparation du bouton de suppression des sermons téléchargés

L'utilisateur a signalé que le bouton de suppression des sermons téléchargés ne fonctionne pas correctement. L'analyse du code révèle que l'identifiant (`id`) des sermons n'est pas sauvegardé dans les métadonnées locales, ce qui entraîne des valeurs nulles lors du rechargement de l'application et cause potentiellement des erreurs lors de la suppression.

## Problème identifié

Dans `lib/models/entities.dart`, la méthode `toJson()` de la classe `Sermon` ne contient pas le champ `id`. Lorsque `DownloadService` sauvegarde la liste des téléchargements dans `metadata.json`, les IDs sont perdus. Au redémarrage de l'application, `Sermon.fromJson()` reçoit un JSON sans ID, et l'objet `Sermon` résultant a un `id` nul.

Dans `lib/pages/downloads_page.dart`, le bouton de suppression utilise `sermon.id!`. Si `id` est nul, une exception est levée, empêchant l'ouverture de la boîte de dialogue de confirmation ou l'exécution de la suppression.

## Changements proposés

### [lib/models/entities.dart](file:///C:/Users/Pontsho/Documents/Project/LabonneSemmenceMobile/lib/models/entities.dart)

#### [MODIFY] [entities.dart](file:///C:/Users/Pontsho/Documents/Project/LabonneSemmenceMobile/lib/models/entities.dart)
- Ajouter le champ `'id': id` dans la méthode `toJson()` de la classe `Sermon`.
- Par mesure de cohérence, ajouter également le champ `id` dans les méthodes `toJson()` des classes `Event` et `DailyDevotion`.

## Plan de vérification

### Vérification Manuelle
1. Télécharger un sermon.
2. Redémarrer l'application.
3. Aller dans l'onglet "Mes téléchargements".
4. Appuyer sur le bouton de suppression du sermon.
5. Vérifier que la boîte de dialogue de confirmation s'affiche et que la suppression fonctionne (l'item disparaît de la liste et les fichiers sont supprimés).
