# Wallet Card Audit

Module root Android pour auditer localement les tentatives d ajout de carte dans Google Wallet.

## Modes

- **Manuel** : `Action start` demarre la capture ; `Action stop` l arrete et genere le rapport.
- **Automatique** : `Action auto-on` active un observateur local. La capture demarre uniquement lorsque Google Wallet passe au premier plan et s arrete lorsqu il en sort.
- **Statut** : `Action status` affiche l etat de la capture et du mode automatique.

## WebUI

La WebUI permet de demarrer ou arreter l audit, d activer/desactiver le mode automatique et de consulter les cartes de diagnostic :

- Attestation appareil
- Keystore / StrongBox
- Reseau / VPN
- Provisioning / tokenization
- Crash applicatif

## Installation

1. Creer un ZIP du contenu de `module/`, avec `module.prop` a la racine du ZIP.
2. Installer via Magisk, KernelSU ou APatch.
3. Redemarrer si demande.
4. Utiliser **Action** ou la WebUI.

## Rapports

Les rapports sont dans `/data/adb/wallet-card-audit/<horodatage>/` :

- `report.json` : resultats structures
- `events.txt` : evenements filtres et partiellement masques
- `context.txt` : contexte Android, Wallet, GMS, NFC et reseau
- `capture-errors.txt` : erreurs de capture

## Limites

Le module ne modifie pas Wallet, GMS, l attestation, les props ou SELinux. Il ne peut pas determiner seul une decision serveur ou bancaire ; les correspondances restent des indices.

## Confidentialite

La capture brute est temporaire et supprimee apres filtrage, mais l effacement physique n est pas garanti. Le masquage est partiel : relire `events.txt` avant partage. Ne jamais enregistrer ou committer un numero de carte, CVV, OTP, jeton ou identifiant bancaire.

## Desinstallation

La desinstallation arrete le watcher et la capture, puis supprime integralement `/data/adb/wallet-card-audit`, y compris rapports, verrous et fichiers temporaires.

## Validation

Prototype non teste sur appareil. Tester installation, permissions, start/stop, mode automatique, WebUI, interruption et confidentialite.
