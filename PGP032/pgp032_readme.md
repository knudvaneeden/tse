# PGP032 for TSE

Version: **1.0.0.0.0**  
Prepared: **2026-09-26 14:42 CEST (Europe/Amsterdam)**  
Original macro: PGP 0.032, 1994-10-18; package update: OpenAI Codex.

## Description

`PGP.S` is a legacy TSE SAL menu for the command-line **PGP 2.x** program. It can encrypt a marked block or the entire current file, encrypt and sign a file, clear-sign text, decrypt or check a signature, import a public key, and insert your public key at the cursor. It invokes the external `pgp` command through `Dos()`; this package does not include PGP or convert the commands to GPG.

**Take a backup of your file before trying encryption or signing.** Several choices replace text in the current editor buffer. The original macro also uses DOS `DEL` commands to remove temporary output files. Test with disposable files first. The original source has older short filename buffers and assumptions about paths; long paths and modern Windows setups may need further changes.

## Files

- `PGP.S`: original macro with an added `Main()` entry point and INI controlled help box.
- `pgp032.ini`: startup message setting.
- `PGP.INF`, `PGP.QEM`, `FILE_ID.DIZ`: original archive documentation and companion files. `PGP.QEM` is for TSE Jr. and is not compiled with `PGP.S`.
- `pgp032_readme.md`: this guide.

## Setup and run

1. Extract the ZIP to a working directory. Keep `pgp032.ini` in the directory from which you run TSE so the macro can read it.
2. Install and configure a compatible command-line PGP executable. Confirm that `pgp` runs from the command prompt used by TSE; configure its key directory and your keys according to that PGP release. The old `PGP.INF` provides historical setup notes.
3. In `PGP.S`, change `first_name`, `last_name`, and `signed_name` from the original author's values to your own PGP user ID and preferred heading before using the public-key and signing features. The source marks these entries with `//!//`.
4. Compile `PGP.S` with your TSE SAL compiler, for example `sc32 PGP.S`, to produce `PGP.MAC`. Compilation and runtime with a modern TSE version have not been verified here.
5. Open a disposable text file in TSE and execute `PGP.MAC` through TSE's macro command. `Main()` reads the INI file, shows a help box by default, and opens the menu. The original `<Ctrl S>` then `<E>` key sequence also opens the menu while the macro is loaded.
6. Select an operation. For **Encrypt Marked Block**, mark a block first. For file actions, save the current file before selecting the operation and inspect the result before saving changes.

## Menu choices

| Choice | Intended action |
| --- | --- |
| Encrypt Marked Block | Encrypt the selected text and insert armored output. |
| Encrypt Entire File | Replace the current buffer with armored encrypted output. |
| Encrypt Entire File and SIGN | Encrypt and sign the current file. |
| SIGN A PlainText Message | Clear-sign the current buffer. |
| Decrypt File or Check Signature | Run PGP on the current file and open its decrypted output. |
| Obtain Public key from this file | Import a public key from the current file. |
| Insert Your Public Key at Cursor | Export the configured key and insert it. |

## `pgp032.ini`

```ini
[PGP032]
silent=false
```

With `silent=false` (the default), running `Main()` displays one informative `Warn()` box before the menu. Set `silent=true` to skip that box. The existing `<Ctrl S>`, `<E>` binding opens the menu directly and does not invoke `Main()`.

## Compatibility notes

This macro was written for TSE 2.00 and PGP 2.x. It invokes `pgp -ea`, `pgp -esa`, `pgp -sta`, `pgp -ka`, and `pgp -kx`; it does not automatically work with GnuPG. The accompanying `PGP.INF` describes historical behavior, including limitations when open files have different paths. No PGP executable or key material is included.
