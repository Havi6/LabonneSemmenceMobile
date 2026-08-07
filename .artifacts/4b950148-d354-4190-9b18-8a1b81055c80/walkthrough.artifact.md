# Résolution de l'erreur FCM `SERVICE_NOT_AVAILABLE`

J'ai sécurisé l'initialisation des notifications pour éviter que l'erreur `SERVICE_NOT_AVAILABLE` ne bloque ou ne pollue l'exécution de l'application sans explication claire.

## Changements effectués

### [Notification Service](file:///C:/Users/Pontsho/Documents/Project/LabonneSemmenceMobile/lib/services/notification_service.dart)

J'ai ajouté des blocs de capture d'erreurs (`try-catch`) autour des appels réseau de Firebase Messaging qui provoquaient l'exception :
- **Abonnement au topic** (`subscribeToTopic`) : Désormais, si le service n'est pas disponible, l'erreur est logguée proprement au lieu de remonter brutalement.
- **Récupération du Token** (`getToken`) : Idem pour la récupération du token FCM.

```dart
// Exemple de modification
try {
  await _messaging.subscribeToTopic('all_users');
} catch (e) {
  debugPrint("Failed to subscribe to topic: $e");
}
```

## Prochaines étapes pour vous

1. **Relancez l'application** : Vous devriez voir des messages de log plus clairs dans votre console (ex: `Failed to get FCM token: [log de l'erreur]`).
2. **Vérifiez votre émulateur** : Assurez-vous d'utiliser un émulateur avec le label "Google Play" dans le Device Manager d'Android Studio.
3. **Vérifiez la date/heure** : Sur l'appareil de test, allez dans Paramètres > Système > Date et heure > Régler automatiquement.

render_diffs(file:///C:/Users/Pontsho/Documents/Project/LabonneSemmenceMobile/lib/services/notification_service.dart)
