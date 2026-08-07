# Réparation du bouton de suppression des sermons téléchargés

Les modifications apportées permettent de conserver l'identifiant des sermons téléchargés lors de la sauvegarde locale, ce qui corrige le dysfonctionnement du bouton de suppression.

## Changements effectués

### [lib/models/entities.dart](file:///C:/Users/Pontsho/Documents/Project/LabonneSemmenceMobile/lib/models/entities.dart)

J'ai mis à jour les méthodes `toJson()` pour inclure le champ `id`. Cela garantit que lorsque `DownloadService` enregistre les métadonnées dans `metadata.json`, l'ID est préservé.

```diff
class Sermon {
  // ...
  Map<String, dynamic> toJson() => {
+   'id': id,
    'titre': title,
    // ...
  };
}

class Event {
  // ...
  Map<String, dynamic> toJson() => {
+   'id': id,
    'titre': title,
    // ...
  };
}

class DailyDevotion {
  // ...
  Map<String, dynamic> toJson() => {
+       'id': id,
        'scheduled_date': scheduledDate.toIso8601String(),
    // ...
  };
}
```

## Résultat attendu

- Les nouveaux téléchargements seront désormais enregistrés avec leur ID dans `metadata.json`.
- Après un redémarrage de l'application, l'identifiant sera correctement rechargé.
- Le bouton de suppression dans `downloads_page.dart` pourra accéder à `sermon.id` sans provoquer d'erreur, permettant la suppression effective des fichiers et de l'entrée dans la liste.

> [!NOTE]
> Les téléchargements déjà effectués avant cette correction pourraient toujours avoir un ID nul dans le fichier `metadata.json` local de l'utilisateur. Il se peut qu'il doive les supprimer manuellement (via un explorateur de fichiers si nécessaire) ou les retélécharger pour que la correction soit pleinement effective pour ces éléments spécifiques.
