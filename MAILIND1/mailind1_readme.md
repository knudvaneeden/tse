# MAILIND1

## Version information

- Version: 1.0.0.0.2
- Date: 2026-09-20
- Time: 20:49:22 UTC
- Macro filename: `mail.s`
- Macro language: TSE SAL

## Description

MAILIND1 is a block-based plain-text email-indexing macro for The SemWare Editor (TSE). Version 1.0.0.0.2 recognizes ordinary RFC-style email headers inside the marked block and prevents the original wraparound loop.

The macro scans only the marked block and creates a one-line index immediately before that block. Each index line contains:

- Generated message number
- Date
- Sender
- Subject

The generated index is bounded by `MAILIND1 INDEX BEGIN` and `MAILIND1 INDEX END`. When the same email block is marked again, rebuilding removes the preceding generated index and leaves the email text unchanged.

## Included files

- `mail.s` — TSE SAL source code.
- `FILE_ID.DIZ` — original short package description.
- `mailind1.ini` — initialization file reserved for future configuration.
- `mailind1_readme.md` — this documentation.

## Requirements

- The SemWare Editor with a compatible SAL compiler.
- A plain-text email export containing standard header blocks with:
  - `Date:`
  - `From:`
  - `To:`
  - `Subject:`
  - `Message-ID:` (optional)

At least one of `Date:`, `Subject:`, or `Message-ID:` must accompany a `From:` header within the marked block. This validation prevents ordinary body lines beginning with `From:` from automatically becoming index entries.

## How the index is formatted

The macro creates a block similar to:

```text
MAILIND1 INDEX BEGIN
No.    Date                     From                     Subject
------ ------------------------ ------------------------ --------------------------------
#1     Fri, 18 Sep 2026         sender@example.com       Example subject
MAILIND1 INDEX END
```

Index data is placed in fixed columns. Long names or subjects are shortened in the generated index only.

## Installation

1. Extract all files from `mailind11.0.0.0.2.zip` into a working directory.
2. Keep `mail.s`, `mailind1.ini`, `FILE_ID.DIZ`, and this readme together.
3. Compile `mail.s` with the TSE SAL compiler, for example:

   ```text
   sc32 mail.s
   ```

4. Confirm that the compiler creates `mail.mac`.
5. Copy or load `mail.mac` according to your normal TSE macro setup.

## Steps to run it

1. Make a backup of the saved-mail file before testing a new macro version.
2. Open the saved-mail file in TSE.
3. Mark the lines containing the email messages to index. A line block is recommended.
4. Load or execute `mail.mac`.
5. When the macro is executed through its `Main()` procedure, it rebuilds the index immediately before the marked block and reports the number of messages indexed.
6. Review the generated index.
7. Save the file if the result is correct.

## Keyboard commands

### `<Alt J>` — build or update the index

Requires a block in the current file. It removes a previous MAILIND1 index immediately preceding that block, validates email headers only within the block, and builds a fresh index before it.

### `<Alt H>` — find the indexed message

Keep the indexed email block marked, place the cursor on a generated `#` entry, and press `<Alt H>`. The macro counts validated `From:` header blocks inside that block and moves to the corresponding message.

## Configuration file

`mailind1.ini` is reserved for future configuration. Version 1.0.0.0.2 does not require or read settings from it.

## Important behavior

- The macro requires a marked block in the current TSE buffer.
- Only lines inside that block are searched for email headers.
- Insert mode and word-wrap mode are restored when indexing finishes.
- A previously generated MAILIND1 index immediately before the marked block is removed before rebuilding.
- Email header lines and message bodies are not modified.
- Searches do not use the global wraparound option that caused the original endless loop.
- Header scanning is limited to 100 lines and ends at the first blank line.

## Limitations

- Input must be plain text; proprietary Outlook, PST, OST, HTML-only, and database formats must first be exported to plain text.
- MIME-encoded header text is indexed as stored and is not decoded.
- Folded multi-line headers are represented by their first physical line.
- Display fields are shortened to fixed widths in the index, but the source messages remain unchanged.
- The initialization file is not yet connected to the SAL source.

## Troubleshooting

### No index entries appear

Confirm that a block is marked in the current file. Then check that each email has a `From:` header followed before the first blank line and before the block end by at least one of `Date:`, `Subject:`, or `Message-ID:`.

### An index entry contains incorrect text

Confirm that the header names begin in column 1 and use the conventional colon form, such as `Subject:`.

### `<Alt H>` does not find a message

Place the cursor on a generated line beginning with `#` before pressing `<Alt H>`.

### The macro changes the wrong file

Make sure the saved-mail file is the current active buffer before running the macro.

## Original authorship

The original 1993 source identifies Steve Kraus as the author and states that it is based on Tom Hogshead's TSE Jr. mail-indexing macro. Versions 1.0.0.0.1 and 1.0.0.0.2 are safety and modern-format rewrites by OpenAI Codex.
