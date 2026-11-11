# Wallet Card Audit

Module root Android pour auditer localement les tentatives d ajout de carte dans Google Wallet.

## Modes
- Manuel : `Action` puis **1** pour demarrer, **2** pour arreter et generer le rapport.
- Automatique : `Action` puis **4** pour basculer Auto ON/OFF. La capture demarre lorsque Google Wallet passe au premier plan et s arrete lorsqu il en sort.
- Statut : `Action` puis **3**.

## Installation sans redemarrage
L installation cree le repertoire de donnees et active immediatement les scripts. Aucun redemarrage n est requis.

## WebUI
Boutons Demarrer, Arreter, Auto ON/OFF et Actualiser ; cartes de diagnostic.

## Rapports
`/data/adb/wallet-card-audit/<horodatage>/` contient `report.json`, `events.txt`, `context.txt` et `capture-errors.txt`.

## Correction de capture
`capture.pid` contient desormais le PID de `logcat`. L arret termine logcat, puis le script genere les rapports. Auparavant, l arret tuait le script parent et empechait la generation du rapport.

## Limites
Le module ne modifie pas Wallet, GMS, l attestation, les props ou SELinux. Les correspondances sont des indices, pas des causes prouvees.

## Confidentialite
La capture brute est temporaire et supprimee apres filtrage. Le masquage est partiel : relire avant partage. Ne jamais stocker PAN, CVV, OTP ou jetons.

## Desinstallation
Supprime integralement les rapports, verrous, fichiers temporaires et processus du module.
