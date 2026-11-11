# Wallet Card Audit 0.5.5

Local diagnostic module using the BakaSU/KernelSU ksu.exec WebUI bridge. No changes to Wallet/GMS, attestation, SELinux or system mounts.

## Recommended capture
Start manually at least 30 seconds before adding a card. Recording begins immediately; status shows the remaining preparation time. Once it shows Capturing, reproduce the attempt, wait for the visible failure, then stop manually. This is guidance, not a block on opening Wallet. Report is generated on stop. Limit: 10 minutes or approximately 20 MiB. Automatic mode starts only when Wallet is foregrounded and cannot guarantee a 30-second lead-in.

## Tag selection
Exact logcat tags at verbose priority: KeyMintSecurityLevelInterceptor, SystemLogger, keystore2, Pay, TapAndPay, NetworkMonitor, KeymasterUtils. Other tags, including UI-specific KsuWebUI tags, are not selected. Other apps may emit the same selected tags; these events are not proven to belong to Wallet. Tags vary by device and build, so missing events do not establish success.
All selected lines are retained after partial redaction. No provisioning keyword gate is applied during collection. Provisioning remains an optional display category. The tag selection narrows collection: crash and network counts outside these tags are not available.

## Viewer
Case-insensitive literal filters: Keystore, TapAndPay, GMS, KeyMintSecurityLevelInterceptor, createOperation, generateKey, SoftwareOperation and Pay, plus custom text. Search runs on retained events of the latest session only, 100 lines per page. Copy displayed events copies the current page. Pay matches substrings including TapAndPay. Tags not captured cannot be recovered by custom search. Suggested viewing order: keystore, KeyMintSecurityLevelInterceptor, SystemLogger (custom), Pay, TapAndPay, tokenization (custom), NetworkMonitor (custom).

## Deletion
Stop capture and turn Automatic OFF, then Delete logs and confirm. Deletes module sessions/report/internal logs, not Android global logs or Wallet/GMS data. Redaction is partial; review before sharing. Logical deletion only, no secure physical erasure.

## Installation
Use workflow release ZIP. Close and reopen WebUI after update. Hot install is requested only if KSU_HAS_HOT_INSTALL=true. Reboot-free activation on the user's BakaSU build remains unverified. Automatic mode is OFF by default and does not persist across reboot. Failed package-manager calls are no longer included in optional context collection.

## Validation
GitHub workflow checks shell syntax, app.js syntax, archive integrity and SHA256. This does not replace device tests; this version has not been run on the user's phone. Diagnostics expose logcat stderr and engine output. Wallet outcome stays unknown unless confirmed externally; counts are heuristic clues, not bank/server rejection reasons.
