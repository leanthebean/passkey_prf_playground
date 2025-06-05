# Passkey PRF Playground

A comprehensive playground to explore and test the WebAuthn PRF (Pseudo-Random Function) extension for passkeys.

## What is PRF?

The PRF (Pseudo-Random Function) extension is a WebAuthn extension that allows passkeys to generate deterministic cryptographic keys from provided salt values. This enables secure key derivation scenarios, such as:

- **Client-side encryption/decryption**: Generate encryption keys without storing them
- **Deterministic key generation**: Same salt + same passkey = same derived key pair
- **Asymmetric encryption**: Encrypt data that only the passkey holder can decrypt

## Current Support Status

### ✅ Supported Platforms/Devices (as of June 2025)

| Layer                               | Platform / product                                     | PRF today                      | Notes                                                                                                                                                                                               |
| ----------------------------------- | ------------------------------------------------------ | ------------------------------ | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| **Platform passkeys**               | **iOS 18 / iPadOS 18**                                 | ✅ (full)                       | Shipped with Safari 18; `ASAuthorizationPublicKeyCredentialPrf…` APIs now public ([medium.com][1], [developer.apple.com][2])                                                                        |
|                                     | **macOS Sequoia 15.4+**                                | ✅ (iCloud Keychain passkeys) | Works in Safari 18.4 and Chrome/Edge ≥128 that call the OS APIs. **Requires iCloud Keychain to be enabled**. External security-key "QR-code" flows still omit PRF ([developer.apple.com][2], [reddit.com][3])                                   |
|                                     | **Android 14 + Google Password Manager (Chrome ≥130)** | ✅                              | Blink's "Intent-to-Ship" covers all six Chromium platforms, incl. Android; depends on updated WebAuthn libs in Play-Services ([groups.google.com][4], [developers.google.com][5])                   |
|                                     | **Windows Hello (Windows 11 24H1)**                    | ❌                              | Microsoft has not enabled the PRF code path yet; feature-request thread still open ([answers.microsoft.com][6])                                                                                     |
| **Roaming security keys**           | **YubiKey 5 series / Bio / Security Key 2**            | ✅                              | Firmware ≥ 5.2 advertises CTAP2 `hmac-secret`, which WebAuthn PRF reuses ([docs.yubico.com][7])                                                                                                     |
|                                     | Google Titan M2, Feitian BioPass, Solo V2              | ✅                              | All ship with `hmac-secret`; PRF works in any PRF-aware browser                                                                                                                                     |
| **Browsers**                        | Chrome / Edge desktop ≥ 128                            | ✅ (default-on)                 | First stable version with PRF fully on by default ([bugzilla.mozilla.org][8])                                                                                                                       |
|                                     | Chrome Android ≥ 130                                   | ✅ (default-on)                 | Same Blink code path as desktop ([groups.google.com][4])                                                                                                                                            |
|                                     | Safari 18.0+                                           | ✅ (platform credentials)       | PRF only returned for **platform** passkeys; external keys & QR-flows still return `undefined` ([developer.apple.com][2], [reddit.com][3])                                                          |
|                                     | Firefox ≥ 114                                          | 🟡                             | PRF available **only** when a CTAP-level hardware key (e.g., YubiKey) is used; no platform-passkey PRF yet ([community.bitwarden.com][9])                                                           |
| **Password-manager passkey vaults** | **1Password**                                          | ✅ on iOS 8.10.74+; 🟡 desktop  | iOS build adds PRF-based vault unlock ([blog.1password.com][11]); desktop editions rely on the underlying OS/browser, so PRF works on macOS 15.4+ but not Windows yet |
|                                     | **Bitwarden (web & browser-ext v2025.2)**              | ✅                              | Uses PRF to decrypt the vault when both the browser **and** authenticator expose it ([bitwarden.com][12], [bitwarden.com][13])                                                                      |
|                                     | Google Password Manager                                | ✅                              | Passkeys synced via Google TPM-backed store expose PRF in Chrome ([theverge.com][14])                                                                                                               |
|                                     | Dashlane, Proton Pass, Enpass                          | ❌                              | Have announced passkey storage but no PRF roadmap yet                                                                                                                                               |

[1]: https://medium.com/%40corbado_tech/automatic-passkey-upgrade-prf-extension-related-origins-18667123006f "Automatic Passkey Upgrade & WebAuthn PRF Extension | Medium"
[2]: https://developer.apple.com/documentation/safari-release-notes/safari-18-release-notes?utm_source=chatgpt.com "Safari 18.0 Release Notes | Apple Developer Documentation"
[3]: https://www.reddit.com/r/Bitwarden/comments/1g4vop0/prf_support_on_safari_18/?utm_source=chatgpt.com "PRF support on Safari 18 : r/Bitwarden - Reddit"
[4]: https://groups.google.com/a/chromium.org/g/blink-dev/c/N8bEfUybqaQ/ "Intent to Ship: WebAuthn PRF extension"
[5]: https://developers.google.com/identity/passkeys/supported-environments?utm_source=chatgpt.com "Passkey support on Android and Chrome - Google for Developers"
[6]: https://answers.microsoft.com/en-us/windows/forum/all/windows-hello-support-for-webauthn-prf-extension/51060a5f-46e2-4510-9389-a45487f01658?utm_source=chatgpt.com "Windows Hello support for WebAuthn PRF extension"
[7]: https://docs.yubico.com/hardware/yubikey/yk-tech-manual/webdocs.pdf?utm_source=chatgpt.com "[PDF] YubiKey Technical Manual - Yubico Product Documentation"
[8]: https://bugzilla.mozilla.org/show_bug.cgi?id=1807856&utm_source=chatgpt.com "[wpt-sync] Sync PR 37690 - webauthn: support PRF extension."
[9]: https://community.bitwarden.com/t/log-in-using-passkey-not-working-with-windows-10-firefox/67483?utm_source=chatgpt.com "Log in using Passkey not working with Windows 10 Firefox"
[11]: https://blog.1password.com/encrypt-data-saved-passkeys/?utm_source=chatgpt.com "1Password Can Now Encrypt Data Using Your Saved Passkeys"
[12]: https://bitwarden.com/blog/prf-webauthn-and-its-role-in-passkeys/?utm_source=chatgpt.com "PRF WebAuthn and its role in passkeys - Bitwarden"
[13]: https://bitwarden.com/help/login-with-passkeys/?utm_source=chatgpt.com "Log In With Passkeys - Bitwarden"
[14]: https://www.theverge.com/2024/9/19/24248820/google-chrome-passkey-logins-device-sync-password-manager-pin?utm_source=chatgpt.com "Google's passkey syncing makes it easier to move on from passwords"

✅ (full) – PRF works out-of-the-box with the built-in passkey store.

🟡 (partial) – Only certain combinations (e.g., hardware keys) expose PRF, or you must enable a browser flag.

❌ – No PRF yet.

## Technical Details

### PRF Extension Flow

1. **Registration**: Request PRF extension support during passkey creation
2. **Authentication**: Include PRF evaluation request with salt value
3. **Key Generation**: Authenticator returns deterministic 32-byte key
4. **Deterministic**: Same salt + same passkey = same key every time

### Example Use Cases

```javascript
// Registration with PRF support
const credential = await navigator.credentials.create({
  publicKey: {
    // ... standard options
    extensions: {
      prf: {} // Request PRF support
    }
  }
});

// Authentication with PRF evaluation
const assertion = await navigator.credentials.get({
  publicKey: {
    // ... standard options
    extensions: {
      prf: {
        eval: {
          first: saltBytes // Your salt as Uint8Array
        }
      }
    }
  }
});

// Extract the generated key
const prfResults = assertion.getClientExtensionResults().prf;
const derivedKey = prfResults.results.first; // 32-byte Uint8Array
```

## Local Deployment

```bash
# Host locally
python3 -m http.server 8080

# Visit
https://localhost:8080/index.html
```

## Browser Requirements

- Modern browser with WebAuthn support
- HTTPS (required for WebAuthn)
- For best results: Safari on macOS 15.4+ or Chrome/Edge with hardware security key

## Security Considerations

- **Salt handling**: Use random, unique salts for different purposes
- **Key storage**: Never store the derived keys long-term
- **Transport security**: Always use HTTPS in production
- **Authenticator variation**: Different authenticators may have different PRF implementations

## Resources

- [WebAuthn PRF Extension Spec](https://w3c.github.io/webauthn/#prf-extension)
- [FIDO Alliance PRF Documentation](https://fidoalliance.org/)
- [WebAuthn Guide](https://webauthn.guide/)

---

**Note**: PRF extension support is still evolving. Check the latest platform documentation for the most current support status.
