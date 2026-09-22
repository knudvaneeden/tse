# MPGP20 for GnuPG

Version: 1.0.0.0.7  
Date: 2026-09-22  
Time: 19:35 UTC  
Prepared with: OpenAI Codex

## Description

MPGP20 is a menu-driven TSE SAL interface for GnuPG. Version 1.0.0.0.2 replaces the obsolete PGP 2.x command-line integration with commands for the user's portable GnuPG 2.5.22 `gpg.exe`.

The macro can encrypt and decrypt the current file, select a recipient from the GnuPG public-key list, import and export keys, display keys and fingerprints, manage keys, create signatures, and start GnuPG's interactive key-management commands.

The original `MPGP.DOC` is retained as historical documentation. Its PGP 2.x commands and installation directions no longer describe the updated program.

## Important: hidden GnuPG passphrase window

During encryption, decryption, signing, or private-key operations, GnuPG may open a separate pinentry window asking for the key passphrase. On Windows this passphrase window can appear underneath TSE, TCC, or another window. MPGP20 then appears to hang because it is waiting for GnuPG, while GnuPG is waiting for the hidden passphrase entry.

If an operation appears to hang, use **Alt+Tab** or the Windows taskbar to find the GnuPG pinentry window, enter the passphrase, and confirm it. Control then returns to TSE. The `_DONT_PROMPT_` flag suppresses TSE's command-completion prompt, but it cannot bring GnuPG's separate pinentry window to the foreground.

## Package contents

- `MPGP.S` - updated ASCII TSE SAL source.
- `MPGP.DOC` - original 1994 MPGP 2.0 documentation.
- `mpgp20.ini` - GnuPG path, local user, and startup-message settings.
- `mpgp20_readme.md` - current documentation.

## Requirements

- The SemWare Editor and its matching SAL compiler.
- GnuPG. This revision was prepared for portable GnuPG 2.5.22.
- Portable GPG download: <https://portableapps.com/apps/security/gpg-plugin-portable>
- At least one imported public key for public-key encryption.
- A secret key when signing or decrypting messages addressed to that key.

## Configuration

Keep `mpgp20.ini` in the same directory as `MPGP.MAC`. When `MPGP.S` is compiled normally, `MPGP.MAC` is created beside it, so the source, compiled macro, and INI file remain together:

```ini
silent=false
gpg=G:\security\gpg\bin\gpg.exe
localuser=
```

- `silent=false` displays the startup information box.
- `silent=true` suppresses the startup information box.
- `gpg=` contains the full path to the portable `gpg.exe`.
- `localuser=` contains the GnuPG user ID, email address, or fingerprint used for signing.

The GnuPG executable is configured in the INI file and is not hard-coded in `MPGP.S`. MPGP20 uses `CurrMacroFilename()` and `SplitPath()` to find the compiled macro directory; it does not use `LoadDir()` and does not depend on the current document directory.

If the INI file is not found beside `MPGP.MAC`, or its `gpg=` path is invalid, MPGP20 asks for the full path to `gpg.exe`. This prompt uses `_EDIT_HISTORY_`.

## Compile

1. Extract all files into one directory.
2. Open a command prompt in that directory.
3. Compile the source with the compiler belonging to the target TSE version:

```text
sc32 MPGP.S
```

4. Confirm that `MPGP.MAC` is produced without errors.
5. Load or execute `MPGP.MAC` using the normal TSE macro mechanism.

Do not reuse a `.MAC` compiled by an incompatible TSE/SAL version.

## Simplest test: passphrase encryption

This test requires no public or secret keys.

1. Create `C:\TEMP\test.txt` containing `Hello world`.
2. Open and save `test.txt` in TSE.
3. Run `MPGP.MAC`.
4. Select **PGP > Encrypt with Passphrase**.
5. Enter and confirm a temporary passphrase in the GnuPG prompt.
6. Confirm that MPGP20 opens `C:\TEMP\test.asc`.
7. Confirm that the file starts with `-----BEGIN PGP MESSAGE-----`.
8. With `test.asc` open, run MPGP20 and select **Decrypt Message**.
9. Enter the same passphrase.
10. Confirm that TSE opens `C:\TEMP\test.decrypted` containing `Hello world`.

Output files are created beside the file being processed, not beside `MPGP.S`. For example:

- Input `C:\TEMP\test.txt` creates `C:\TEMP\test.asc` when ASCII Armor is on.
- Input `C:\TEMP\test.txt` creates `C:\TEMP\test.gpg` when ASCII Armor is off.
- Decrypting `C:\TEMP\test.asc` creates `C:\TEMP\test.decrypted`.

The original file is preserved.

## Public-key list test

1. Import at least one public key into GnuPG.
2. Run MPGP20.
3. Select **PGP > Create Keylist File**.
4. Confirm that `mpgp20_keys.lst` is created beside the executing `MPGP.MAC` file.

The key-list file uses GnuPG's stable `--with-colons` format. When selecting a recipient, choose a line beginning with `uid:`. MPGP20 extracts its user-ID field and passes that value to `gpg.exe --recipient`.

## Encrypt a file with a public key

1. Import the recipient's public key into GnuPG.
2. Open a disposable plaintext file in TSE.
3. Run MPGP20.
4. Leave **ASCII Armor** enabled for email-friendly output.
5. Select **Encrypt with Public Key**.
6. In the key list, select the desired `uid:` line.

MPGP20 runs the equivalent of:

```text
gpg.exe --armor --encrypt --recipient USER-ID --output FILE.asc FILE
```

The encrypted `.asc` file is opened in TSE. The original plaintext file is preserved.

## Public-key and private-key round-trip test

This test uses your own key pair so that you can test both sides without sending a message to another person.

1. Confirm that your key pair is available with `gpg.exe --list-secret-keys --keyid-format long`.
2. Create `C:\TEMP\test.txt` containing `Hello world`, then open and save it in TSE.
3. Run `MPGP.MAC` and select **PGP > Encrypt with Public Key**.
4. In the GnuPG key list, select the `uid:` line belonging to your own public key.
5. Confirm that MPGP20 opens `C:\TEMP\test.asc` and that it starts with `-----BEGIN PGP MESSAGE-----`.
6. With `test.asc` open, run `MPGP.MAC` again and select **PGP > Decrypt Message**.
7. If GnuPG displays its pinentry window, enter the private-key passphrase.
8. Confirm that TSE opens `C:\TEMP\test.decrypted` containing `Hello world`.

Encryption uses the selected public key. Decryption automatically locates the corresponding private key in the GnuPG secret-key store. GnuPG may not ask for the private-key passphrase again while `gpg-agent` still has it cached; that is normal.

For a real exchange, select the other person's imported public key when encrypting. Only the matching private key can decrypt the resulting message.

## Get or export your public and private keys with GnuPG

Use the configured portable GnuPG executable in these examples. Replace the email address and backup paths when necessary.

### Generate a new public/private key pair

```text
G:\security\gpg\bin\gpg.exe --full-generate-key
```

Follow the prompts, choose a key type that supports encryption, enter your identity, and protect the private key with a strong passphrase. GnuPG stores the generated public and private keys in its key store; it does not normally create ordinary public/private key files automatically.

### List your keys

List public keys:

```text
G:\security\gpg\bin\gpg.exe --list-keys --keyid-format long
```

List private/secret keys:

```text
G:\security\gpg\bin\gpg.exe --list-secret-keys --keyid-format long
```

### Export the public key for sharing

```text
G:\security\gpg\bin\gpg.exe --armor --output "C:\TEMP\knud-public-key.asc" --export "knud_van_eeden@yahoo.com"
```

The resulting `knud-public-key.asc` file may be sent to people who need to encrypt messages to you or verify your signatures.

### Export the private key for a secure backup

```text
G:\security\gpg\bin\gpg.exe --armor --output "X:\secure-backup\knud-private-key.asc" --export-secret-keys "knud_van_eeden@yahoo.com"
```

Store this file offline or in strongly protected encrypted storage. Never email it, publish it, paste it into a conversation, or give it to another person. Anyone who obtains both this private key and its passphrase may impersonate you or decrypt messages addressed to the key.

Optionally back up the owner-trust database:

```text
G:\security\gpg\bin\gpg.exe --export-ownertrust > "X:\secure-backup\ownertrust.txt"
```

The `.rev` file created during key generation is the revocation certificate, not the private key. Protect it and retain it separately so the public key can be revoked if the private key is lost or compromised.

## Encrypt with a passphrase

1. Select **Encrypt with Passphrase**.
2. Enter the passphrase through GnuPG when requested.

This uses `gpg.exe --symmetric`. No public key is required.

## Decrypt

1. Open an encrypted `.asc` or `.gpg` file in TSE.
2. Run MPGP20.
3. Select **Decrypt Message**.
4. Supply the passphrase when GnuPG requests it. If TSE appears to hang, use **Alt+Tab** because the GnuPG pinentry window may be hidden underneath TSE or TCC.

The decrypted data is written to a new file whose name ends in `.decrypted`. The encrypted source is preserved.

## Options

- **ASCII Armor** adds `--armor` and normally creates readable `.asc` output.
- **Sign** adds `--sign --local-user`; configure `localuser=` first.
- **Textmode** adds `--textmode`.
- **Encrypt with Public Key** uses `--encrypt` and asks for a recipient.
- **Encrypt with Passphrase** uses `--symmetric` and does not open the key list.

## Key commands

The menus map the original operations to current GnuPG commands, including:

- Add key: `--import`
- Export key: `--armor --export`
- Remove key: `--delete-keys`
- View key: `--list-keys`
- Fingerprint: `--fingerprint`
- View signatures: `--list-signatures`
- Edit key or trust: `--edit-key`
- Certify key: `--sign-key`
- Create key: `--full-generate-key`
- Create revocation certificate: `--generate-revocation`
- Detached signature: `--armor --detach-sign`

Revoking an individual key signature needs two fingerprints and is not automated by this menu. MPGP20 displays command-line guidance instead.

## Hotkeys

- `Ctrl+E` encrypts the current file.
- `Ctrl+D` decrypts the current file.

Check for conflicts with existing TSE key assignments before using these bindings.

## Safety

This revision preserves the original file during encryption and decryption and opens the generated output as a separate file. Nevertheless, use disposable files for initial testing and retain backups.

Before sending encrypted data, verify the recipient key's fingerprint through an independent trusted channel.

## Troubleshooting

### Decryption appears to hang

GnuPG is probably waiting for the private-key passphrase in its separate pinentry window. That window can open underneath TSE, TCC, or other Windows applications and therefore may not be visible.

Use **Alt+Tab** or the Windows taskbar to locate the GnuPG pinentry window, enter the passphrase, and confirm it. Do not terminate TCC unless no pinentry window exists and the operation is genuinely stuck. GnuPG may skip this prompt on later operations while `gpg-agent` has the passphrase cached.

### GnuPG does not start

Confirm that `gpg=` contains the complete executable path and that no surrounding quotes were placed in the INI value. MPGP20 adds the required quotes itself.

The INI file is searched for beside the executing `MPGP.MAC`, normally the same directory as `MPGP.S`. Opening `C:\TEMP\test.txt` therefore does not change where MPGP20 searches for its INI file.

When an encryption or decryption command fails, MPGP20 redirects GnuPG diagnostics to `mpgp20_gpg.log` beside the input file and opens that log in TSE.

For an independent command-line test, run:

```text
"G:\security\gpg\bin\gpg.exe" --armor --symmetric --output "C:\TEMP\test.asc" "C:\TEMP\test.txt"
```

GnuPG should display its passphrase prompt and create `C:\TEMP\test.asc`.

### No recipients appear

Import a public key, then select **Create Keylist File** again. Choose a `uid:` row rather than a `pub:`, `sub:`, or fingerprint row.

### Signing fails

Set `localuser=` to a user ID, email address, or fingerprint belonging to an available secret key. Signing is disabled by default.

### Output already exists

GnuPG may request permission to overwrite the file. Rename or move the existing `.asc`, `.gpg`, or `.decrypted` output before retrying.

## Version history

### 1.0.0.0.7 - 2026-09-22 21:07 UTC

- Added a prominent warning that GnuPG's pinentry passphrase window may open underneath TSE, TCC, or other windows.
- Added recovery instructions using Alt+Tab or the Windows taskbar when an operation appears to hang.
- Clarified that `_DONT_PROMPT_` cannot control the position of GnuPG's separate pinentry window.

### 1.0.0.0.6 - 2026-09-22 20:53 UTC

- Corrected the TSE SAL `Dos()` flag spelling to `_DONT_PROMPT_` in every GnuPG execution.

### 1.0.0.0.5 - 2026-09-22 20:46 UTC

- Changed every GnuPG `Dos()` execution from `_DEFAULT_` to `_DONT_PROMPT_` so TSE does not wait for the TCC command window after GnuPG finishes.
- Added a public-key encryption and private-key decryption round-trip test.
- Added commands to generate, list, and export public and private keys and to back up owner trust.
- Added the PortableApps GPG download URL.
- Documented automatic private-key selection and normal `gpg-agent` passphrase caching.

### 1.0.0.0.4 - 2026-09-22 20:10 UTC

- Added a `_EDIT_HISTORY_` prompt for the full `gpg.exe` path when the INI file or configured executable is unavailable.
- Changed INI and generated key-list lookup to the `MPGP.MAC` directory by using `CurrMacroFilename()` and `SplitPath()`.
- Added `mpgp20_gpg.log` diagnostic capture beside the input file.
- Changed failed encryption and decryption operations to open the GnuPG diagnostic log in TSE.
- Added a direct command-line test to the troubleshooting documentation.

### 1.0.0.0.3 - 2026-09-22 19:58 UTC

- Added the complete simplest passphrase-encryption and decryption test.
- Documented that output is created beside the current input file.
- Added separate public-key and passphrase encryption menu commands.
- Fixed public-key selection so it uses the stored key-list buffer ID instead of accidentally displaying the current document.

### 1.0.0.0.2 - 2026-09-22 19:35 UTC

- Replaced legacy `pgp.exe` commands with GnuPG 2.5.22 commands.
- Added configurable `gpg=` and `localuser=` INI parameters.
- Added GnuPG public-key list generation and `uid:` parsing.
- Updated encryption, decryption, signing, and key-management operations.
- Changed encryption and decryption to preserve the original file.
- Removed obsolete PGP-only menu options.

### 1.0.0.0.1 - 2026-09-22 19:06 UTC

- Updated both legacy `Sound()` calls for the two-parameter syntax required by SAL Compiler V4.50.rc23.
- Removed an unused local variable reported by the compiler.

### 1.0.0.0.0 - 2026-09-22 18:55 UTC

- Added Markdown documentation and configurable startup information.
