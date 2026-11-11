# Wallet Card Audit 0.5.7

Fix: collect all logcat tags in main/system/crash at verbose level, then retain events matching tag OR message content. No provisioning-only gate and no seven-tag allowlist.

## Retained clues
KeyMintSecurityLevelInterceptor, SystemLogger, SoftwareOperation, OperationInterceptor, createOperation, generateKey, authorizecreate, TXID, Creating SOFTWARE operation, Found new IKeystoreOperation, Registering interceptor, Restoring persisted key, Failed to restore key, Failed to restore symmetric metadata. Also retains Keystore/KeyMint/Keymaster/StrongBox, TapAndPay/tokenization, Pay tag, NetworkMonitor and common network/crash clues. UI tags KsuWebUI/KsuWebUIStandalone/WalletCardAudit/wallet-card-audit are excluded when recognized in threadtime metadata. Other apps can still use shared tags. Messages mentioning UI are not globally discarded.

## Capture
Start manually 30 seconds BEFORE card addition. Recording begins immediately and status displays preparation time; it does not prevent an early attempt. Stop after the visible failure. Automatic mode cannot ensure the 30-second lead-in. Limits: 10 minutes or approximately 20 MiB; wide collection may reach the size limit sooner. New capture required; excluded lines in older sessions cannot be reconstructed. Logging verbosity flags cannot generate messages absent from the component build.

## Viewer
Filters and custom search operate on retained events, 100 lines per page. Use custom TXID or operation text to follow the sequence. Copy displayed events copies only the current page. Existing WebUI header may still show 0.5.6; module.prop and Diagnostics identify the engine as 0.5.7.

## Privacy
Raw temporary capture includes unrelated app activity; deleted on normal cleanup. Retained text has partial email/Bearer/13-19 digit number masking only, NOT guaranteed anonymization or PAN detection. Shorter numeric TXIDs remain searchable; longer identifiers may be masked. Never share PAN/CVV/OTP/credentials. Abrupt termination can leave files. No secure physical erasure. Delete logs requires capture stopped and Automatic OFF.

## Installation and validation
Workflow builds release ZIP with version from module.prop. Hot install is conditional on manager support; reboot-free BakaSU activation remains unverified. No modifications to Wallet/GMS/SELinux/attestation/system mounts. Device behavior not tested. Counts are heuristic clues, not proven causes or server-side bank results.
