# Plan d'implémentation - Nettoyage de l'interface du lecteur audio

Ce plan vise à retirer les boutons non implémentés de l'interface du lecteur de sermons pour simplifier l'expérience utilisateur.

## User Review Required

> [!NOTE]
> Les boutons de favoris, de lecture aléatoire (shuffle) et de répétition (repeat) seront retirés car ils n'ont pas de fonctionnalité associée dans la version actuelle de l'application.

## Proposed Changes

### [UI Components]

#### [MODIFY] [sermon_player_page.dart](file:///C:/Users/Pontsho/Documents/Project/LabonneSemmenceMobile/lib/pages/sermon_player_page.dart)
- Retirer le bouton `Icons.favorite_border`.
- Retirer le bouton `Icons.shuffle`.
- Retirer le bouton `Icons.repeat`.
- Réajuster l'alignement des contrôles restants (Précédent, Lecture/Pause, Suivant).

## Verification Plan

### Manual Verification
- Ouvrir le lecteur audio depuis la page d'accueil ou la page des sermons.
- Vérifier que seuls les boutons fonctionnels (Précédent, Lecture/Pause, Suivant, Téléchargement) sont visibles.
- Vérifier que l'interface reste centrée et esthétique.
