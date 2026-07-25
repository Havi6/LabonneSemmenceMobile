# Correction des erreurs d'upload et des entrées vides

J'ai corrigé le problème où des erreurs de connexion lors de l'upload entraînaient des entrées vides sur le serveur et un manque de retour visuel pour l'utilisateur.

## Changements effectués

### 1. Gestion de la progression et retour visuel
- Ajout d'un état `_isActionInProgress` pour suivre les opérations en arrière-plan (upload et création).
- Intégration d'une `LinearProgressIndicator` en haut de la page d'administration qui s'affiche pendant toute la durée de l'upload.
- Mise à jour de `_runAction` pour empêcher les soumissions multiples et gérer automatiquement l'affichage des erreurs.

### 2. Sécurisation du processus d'upload
- Le processus est désormais "transactionnel" du point de vue de l'interface : l'upload du fichier et la création de l'entrée sont regroupés dans le même bloc d'exécution.
- Si l'upload échoue, une erreur claire est affichée via un Snackbar rouge, et l'entrée n'est pas ajoutée localement.

### 3. Réduction des entrées "vides" sur le serveur
- Mise à jour de `AppData.uploadAsset` pour accepter des champs supplémentaires.
- Lors de l'upload d'un sermon ou d'un événement, le titre (et l'auteur pour les sermons) est désormais envoyé **pendant l'upload du fichier**. Cela permet au serveur de remplir ces informations dès la réception du fichier, évitant ainsi les lignes vides si la deuxième requête de création échoue.

## Vérification

> [!TIP]
> Vous pouvez maintenant voir une barre de progression bleue en haut de la page Admin quand vous enregistrez un sermon ou un événement. Si la connexion est perdue, vous recevrez un message d'erreur au lieu que l'application ne fasse rien.

### Fichiers modifiés :
- [admin_page.dart](file:///C:/Users/Pontsho/Documents/Project/LabonneSemmenceMobile/lib/pages/admin_page.dart) : Logique de l'interface et gestion des éditeurs.
- [app_data.dart](file:///C:/Users/Pontsho/Documents/Project/LabonneSemmenceMobile/lib/services/app_data.dart) : Amélioration de la méthode `uploadAsset`.
