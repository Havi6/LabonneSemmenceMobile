# Plan d'Optimisation Responsive Globale

Ce plan vise à rendre l'intégralité de l'application responsive et à éliminer tout risque d'overflow sur les petits écrans, tout en améliorant le rendu sur les grands écrans.

## Proposed Changes

### [Component] Layouts

#### [MODIFY] [home_layout.dart](file:///C:/Users/Pontsho/Documents/Project/LabonneSemmenceMobile/lib/widget/home_layout.dart)
- Rendre la `SalomonBottomBar` flexible en limitant sa largeur sur tablette/desktop.
- Ajuster les marges de la barre de navigation selon la taille de l'écran.

### [Component] Pages

#### [MODIFY] [calendar_page.dart](file:///C:/Users/Pontsho/Documents/Project/LabonneSemmenceMobile/lib/pages/calendar_page.dart)
- Rendre le nombre de colonnes du `GridView` dynamique (1 sur très petit, 2 sur mobile standard, 3+ sur tablette).
- Ajuster le `childAspectRatio` ou utiliser un layout plus flexible pour les cartes d'évènements.

#### [MODIFY] [galery_page.dart](file:///C:/Users/Pontsho/Documents/Project/LabonneSemmenceMobile/lib/pages/galery_page.dart)
- Ajuster la taille des textes et des indicateurs visuels.
- Rendre l'`AspectRatio` des images adaptatif.

#### [MODIFY] [about_us_page.dart](file:///C:/Users/Pontsho/Documents/Project/LabonneSemmenceMobile/lib/pages/about_us_page.dart)
- Remplacer les `Row` de cartes par des `Wrap` ou une disposition en colonne sur les écrans étroits pour éviter l'écrasement du texte.

#### [MODIFY] [account_page.dart](file:///C:/Users/Pontsho/Documents/Project/LabonneSemmenceMobile/lib/pages/account_page.dart)
- Adapter la taille de l'avatar et des polices.
- Utiliser des paddings adaptatifs.

#### [MODIFY] [sermons_page.dart](file:///C:/Users/Pontsho/Documents/Project/LabonneSemmenceMobile/lib/pages/sermons_page.dart)
- Optimiser le `ListTile` pour les titres longs et les petits écrans.
- Utiliser des tailles d'icônes et de textes adaptatives.

#### [MODIFY] [donnation_page.dart](file:///C:/Users/Pontsho/Documents/Project/LabonneSemmenceMobile/lib/pages/donnation_page.dart)
- Rendre l'icône et les textes adaptatifs.
- Ajuster les marges du formulaire.

#### [MODIFY] [event_detail_page.dart](file:///C:/Users/Pontsho/Documents/Project/LabonneSemmenceMobile/lib/pages/event_detail_page.dart)
- S'assurer que le `FlexibleSpaceBar` et le contenu textuel ne causent pas d'overflow.

## Verification Plan

### Manual Verification
- Test sur simulateur mobile (étroit).
- Test sur tablette ou mode paysage.
- Vérification systématique de l'absence de "Yellow Lines" d'overflow.
