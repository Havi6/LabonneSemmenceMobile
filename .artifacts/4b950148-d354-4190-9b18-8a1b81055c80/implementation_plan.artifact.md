# Résolution de l'erreur FCM `SERVICE_NOT_AVAILABLE`

L'erreur `java.io.IOException: SERVICE_NOT_AVAILABLE` indique que l'application Android ne parvient pas à communiquer avec les serveurs de Google (FCM). Cela est généralement dû à un problème d'environnement (réseau, services Google Play) plutôt qu'à une erreur de code pure.

## Diagnostic

L'erreur survient lors de la synchronisation des topics ou de la récupération du token FCM. Dans votre code, cela se produit probablement dans `NotificationService.initialize()`.

## User Review Required

> [!IMPORTANT]
> Cette erreur est souvent liée à l'appareil de test. Veuillez vérifier les points suivants :
> 1. **Services Google Play** : Si vous utilisez un émulateur, assurez-vous qu'il possède le **Google Play Store** (icône Play Store dans le gestionnaire AVD).
> 2. **Connexion Réseau** : Vérifiez que l'appareil a accès à Internet. Certains pare-feux bloquent les ports FCM (5228-5230).
> 3. **Heure du système** : Assurez-vous que la date et l'heure de l'appareil sont réglées sur **Automatique**. Un décalage empêche la connexion sécurisée SSL.
> 4. **VPN/Proxy** : Si vous utilisez un VPN, essayez de le désactiver.

## Proposed Changes

Nous allons améliorer la robustesse du service de notification en ajoutant une gestion d'erreurs plus fine et en s'assurant que l'échec d'un service n'empêche pas l'initialisation du reste.

### Flutter (Dart)

#### [MODIFY] [notification_service.dart](file:///C:/Users/Pontsho/Documents/Project/LabonneSemmenceMobile/lib/services/notification_service.dart)
- Ajouter des blocs `try-catch` autour des appels à `subscribeToTopic` et `getToken`.
- Ajouter des logs plus descriptifs pour aider au débogage.

## Verification Plan

### Manual Verification
1. Relancer l'application sur un appareil avec les services Google Play actifs.
2. Vérifier les logs pour voir si le token FCM est récupéré avec succès.
3. Vérifier que l'application ne crash pas en cas d'échec de connexion aux services Google.
