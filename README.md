# Wallet Card Audit 0.5.1

Correctif ciblant le pont WebUI BakaSU/KernelSU `ksu.exec(command, optionsJSON, callbackName)`. Aucun serveur HTTP local fictif.

## Utilisation
Installer le ZIP de la release ou de l'artefact GitHub Actions. Fermer puis rouvrir la WebUI apres mise a jour. Le titre et le backend doivent afficher 0.5.1.
Un seul bouton bascule la capture manuelle. Un second interrupteur distinct gere le mode automatique. Action bascule la capture sans saisie clavier. L'etat est relu toutes les 5 secondes. Arreter la capture pour produire le rapport puis consulter Evenements et Diagnostics.

## Installation a chaud
Demande officielle MODULE_HOT_INSTALL_REQUEST si KSU_HAS_HOT_INSTALL=true ; sinon avertissement explicite. Support de cette fonction dans le build BakaSU de l'utilisateur non confirme. Pas de copie forcee dans les repertoires du gestionnaire. Zero reboot non garanti sans prise en charge par celui-ci.

## Capture
Processus detache, arret par indicateur avec attente du rapport. Limite par session : 10 minutes ou environ 20 Mio. Buffers main/system/crash. Compteurs d'octets et lignes filtrees, sortie logcat et diagnostic accessibles. Une absence de signal ne prouve pas un succes. Decisions serveur/bancaires non accessibles.

## Automatique
OFF par defaut, non persistant apres reboot. Detection activite Wallet, delai de sortie de 10 secondes. Ne reconnait pas specifiquement un ajout de carte. Formats dumpsys variables : utiliser le manuel si necessaire. Desactiver le mode automatique pour garder le controle manuel d'une session.

## Confidentialite et desinstallation
Donnees root en /data/adb/wallet-card-audit. Masquage partiel seulement : relire avant partage, ne pas publier PAN/CVV/OTP/jetons. Brut temporaire supprime apres filtrage ou sortie normale. Arret brutal pouvant laisser des fichiers : inspection manuelle necessaire. Pas d'effacement physique securise. Desinstallation : attend l'arret avant suppression ; echoue explicitement si l'arret n'est pas confirme. Les exports externes ne sont pas supprimes.

## Validation
Workflow verifie syntaxe shell, syntaxe JS, integrite ZIP et SHA256. Ces verifications ne remplacent pas les tests sur telephone. Aucun test BakaSU sur appareil effectue. Aucune modification Wallet, GMS, attestation, props, montages systeme ou SELinux.
