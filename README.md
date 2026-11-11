# Wallet Card Audit

[![Latest release](https://img.shields.io/github/v/release/wfire06100/wallet-card-audit)](https://github.com/wfire06100/wallet-card-audit/releases/latest)

Read-only Android root module for collecting diagnostic logs while adding a payment card to Google Wallet. It does not modify Wallet, Google Play services or attestation, and does not bypass payment controls.

## Latest release and download

Open [the latest published release](https://github.com/wfire06100/wallet-card-audit/releases/latest) and download its `wallet-card-audit-v*.zip` asset. Install the module ZIP, not GitHub's source-code archives. SHA256SUMS is provided with the release.

The badge and link above follow the latest published release automatically; no version number is hard-coded in this README. The badge may briefly show a cached value. The release page identifies the published version; module/module.prop and Diagnostics identify the installed module. Documentation of features still needs updating when behavior changes.

## Collection and retained clues

Collects main/system/crash logcat buffers at verbose level, then retains events matching tag OR message content. No provisioning-only gate and no seven-tag allowlist.

Retained clues include:

- KeyMintSecurityLevelInterceptor, SystemLogger, SoftwareOperation, OperationInterceptor.
- createOperation, generateKey, importKey, post-importKey, authorizecreate, TXID and KeyId.
- NOT FOUND, Forwarding to HAL, Generating software key, Creating SOFTWARE operation, Found new IKeystoreOperation and Registering interceptor.
- Restoring persisted key, Failed to restore key and Failed to restore symmetric metadata.
- keymint_finish_operation, VERIFICATION_FAILED and Failed to create EncryptedData.
- Keystore/KeyMint/Keymaster/StrongBox, TapAndPay/tokenization, the Pay tag, NetworkMonitor and common network/crash clues.

Recognized interface-origin tags KsuWebUI/KsuWebUIStandalone/WalletCardAudit/wallet-card-audit are excluded using threadtime metadata. Useful messages merely mentioning the interface are not globally discarded. Other apps may use shared tags.

## Capture

Start manually at least 30 seconds BEFORE card addition. Recording begins immediately and status displays preparation time; it does not prevent an early attempt. Stop after the visible failure. Automatic mode cannot ensure the 30-second lead-in.

Limits: 10 minutes or approximately 20 MiB; wide collection may reach the size limit sooner. Start earlier when investigating key generation/import preceding the attempt: the preparation countdown does not guarantee that those events will be captured. Excluded lines in older sessions cannot be reconstructed. Logging verbosity flags cannot generate messages absent from the component build.

## Viewer

The English WebUI provides a Keystore / TEESimulator / HAL expanded category, individual event presets and case-insensitive literal custom search. Filters operate on retained events, 100 lines per page. Search TXID, KeyId, UID or operation text to inspect sequences; nearby timestamps alone do not prove that events belong to the same operation. Copy displayed events copies only the current page.

Delete logs requires capture stopped and Automatic OFF.

## Privacy

Raw temporary capture includes unrelated app activity and is deleted on normal cleanup. Retained text has partial email/Bearer/13-19 digit number masking only, NOT guaranteed anonymization or PAN detection. Shorter numeric TXIDs remain searchable; longer identifiers may be masked. Never share PAN/CVV/OTP/credentials. Abrupt termination can leave files. No secure physical erasure. Never commit captured logs.

## Installation and validation

The build workflow reads the module version from module/module.prop and publishes the module ZIP and checksums. The latest-release link and badge above track published releases rather than unreleased commits on main.

Hot install is conditional on manager support; reboot-free BakaSU activation remains unverified. No modifications to Wallet/GMS/SELinux/attestation/system mounts. Device behavior has not been verified here. Counts are heuristic clues, not proven causes or server-side bank results.
