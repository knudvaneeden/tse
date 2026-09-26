# PGPTSEAW / PGPAW

Version: 1.0.0.0.0  
Date and time: 2026-09-26 15:10 CEST (Europe/Amsterdam)

## Description

`PGPAW.S` is Anthony Williams's TSE Pro macro from 1995 for working with classic PGP 2.6 era command-line software. It can encrypt a marked block or an entire file, optionally sign while encrypting, sign a marked plaintext block, decrypt or check a signature, import a public key from a file, and insert your public key at the cursor. Its menu key is **Ctrl+Alt+P**. It invokes the external `pgp` command; it does not implement encryption itself. This release adds an optional startup notice controlled by `pgptseaw.ini`.

## Package contents

- `PGPAW.S`: main TSE SAL source, with the startup notice.
- `pgptseaw.ini`: startup notice setting.
- `pgptseaw_readme.md`: these instructions.
- `HWINSIZ.S`: optional horizontal-window macro for external mail editor use.
- `README.1ST`: original author's instructions and signed message.
- `PGPALT.HLP`: historical PGP command help.
- `PGPREFCD.TXT`: historical PGP 2.6 command reference.
- `FILE_ID.DIZ`: original archive description.

## Requirements and setup

1. Install a compatible **PGP 2.6 era** command-line program separately and confirm `pgp` runs from the shell used by TSE. Modern GnuPG is not a direct substitute for these command options.
2. Set up PGP's keyrings and your own key pair as described by that PGP distribution. The original macro mentions `PGPPATH` and `TZ` environment variables.
3. Edit the global values near line 160 of `PGPAW.S`: set `last_name`, `mykey_id`, and `signed_name` to your own details. `mykey_id` expects a `0x` prefix. The shipped values refer to the original author and must be changed before using signing or your public key.
4. Edit the hardcoded `Q:\` temporary paths (`stmp` and `fn`) to an existing writable drive or directory. Read the original comments around those variables. The default assumes the original author's RAM disk.
5. For decrypting your own outgoing messages, the original source recommends `EncryptToSelf=ON` in PGP's configuration. Check your particular PGP setup.
6. Keep `pgptseaw.ini` in TSE's **current working directory** when running the macro. The macro reads `.\pgptseaw.ini`; if the file is absent it defaults to `false`.

## Compile and run

1. Compile `PGPAW.S` with the SAL compiler appropriate for your TSE installation, for example `sc32 PGPAW.S` for TSE Win32. Compile `HWINSIZ.S` separately only if you need that optional macro.
2. Run/load the compiled `PGPAW.MAC` in TSE. On execution, `main()` shows a `Warn()` explaining the hotkey and setup when `silent=false`.
3. Press **Ctrl+Alt+P** to open the menu. For block operations, mark the desired text first. Choose the relevant menu item and follow PGP's prompts. For file operations, open the desired file first.
4. Try a disposable test file and verify the output and key selection before editing valuable text. The source contains separate actions for signed encryption, encryption, plaintext signing, decryption, key import, and key insertion.

## INI option

```ini
[PGPTSEAW]
silent=false
```

Set `silent=true` to suppress the **startup** `Warn()` only. Error warnings inside the original encryption and signing routines still appear. Only the literal value `true` suppresses the startup notice; missing or other values show it.

## Compatibility notes

This is historical source tested by its author with TSE 2.50 and PGP 2.62(i). It uses DOS-era command syntax, a fixed temporary drive, and original TSE macro calls. The included package has not been compiled or run against your TSE 4.50 installation here. Consult `README.1ST` and the source comments for additional original instructions.
