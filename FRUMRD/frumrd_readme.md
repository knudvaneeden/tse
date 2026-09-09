# FRUMRD — CompuServe Forum Reader for TSE

**README version:** 1.0.0.0.0  
**Date:** 2026-09-10  
**Time:** 01:27:32 CEST  
**Session:** Create FRUMRD MarkDown Readme

## Description

FRUMRD, also identified in the source as **FORUMRDR** and **vmForumReader**, is a TSE SAL macro written by Volker Multhopp. It helps users read and edit CompuServe forum messages that have been captured in the current TSE file.

The macro recognizes the traditional CompuServe message headers and provides commands for:

- moving to the previous or next message;
- locating the message to which the current message replies;
- locating the first reply to the current message;
- finding the origin of a discussion thread;
- declaring and following a complete message thread;
- displaying compressed lists of message header fields;
- deleting a complete captured message;
- preparing a reply for later ASCII upload to CompuServe.

The archive contains:

- `FORUMRDR.S` — TSE SAL source code for vmForumReader version 1.1.

## Requirements

- The SemWare Editor (TSE) with a SAL compiler compatible with this source.
- A text file containing captured CompuServe forum messages in the format expected by the macro.
- TSE's `mCompressView(0)` command assigned to `Alt+V` for the compressed-view commands.

This source dates from 1993 and uses the TSE SAL syntax and message format of that period. A current TSE version may report compatibility errors that require source changes before compilation.

## Installation

1. Extract `frumrd.zip` to a working directory.
2. Locate `FORUMRDR.S` in the extracted files.
3. Open a command prompt in that directory.
4. Compile the macro with the TSE SAL compiler:

   ```text
   sc32 FORUMRDR.S
   ```

5. Confirm that compilation creates the loadable TSE macro file.
6. Place the compiled macro where TSE can load it, or specify its full path when loading it.
7. Verify that `Alt+V` calls `mCompressView(0)`. If another key performs that action, change the `pushkey(<alt v>)` line in `FORUMRDR.S` to the appropriate key and compile the source again.

## How to run FRUMRD

1. Start TSE.
2. Open a file containing captured CompuServe forum messages.
3. Load or execute the compiled `FORUMRDR` macro. The capture file and macro may be loaded in either order.
4. Press `CenterCursor` to activate FRUMRD.
5. Press one of the command keys listed below.

FRUMRD takes control of the `CenterCursor` key but is otherwise designed not to interfere with normal editing commands.

## Command reference

Press `CenterCursor` first, followed by the desired command key.

| Key | Action |
| --- | --- |
| `Home` | Find the ultimate origin of the current message thread. |
| `Cursor Up` | Find the message to which the current message is replying. |
| `Cursor Down` | Find the first reply to the current message. |
| `End` | Declare the current message as the origin of the thread to trace. |
| `Cursor Right` | Find the next message in the declared thread. |
| `PgUp` | Go to the previous message. |
| `PgDn` | Go to the next message. |
| `Cursor Left` | Return to the beginning/header of the current message. |
| `Delete` | Delete the complete current message without confirmation. |
| `R` | Create an offline reply to the current message. |
| `F1`, `H`, or `CenterCursor` | Display the built-in help screen. |
| `N` | Show a compressed view of message-number/section header lines. |
| `S` | Show a compressed view of subject (`Sb:`) lines. |
| `F` | Show a compressed view of sender (`Fm:`) lines. |
| `T` | Show a compressed view of recipient (`To:`) lines. |
| `Ctrl+N` | Show a compressed view of the current section. |
| `Ctrl+S` | Show messages having the same subject. |
| `Ctrl+F` | Show references to the current sender's CompuServe ID. |
| `Ctrl+T` | Show references to the current recipient's CompuServe ID. |
| `W` | Show a compressed view for the word at the cursor. |

## Following a message thread

1. Position the cursor inside a valid captured message.
2. Press `CenterCursor`, then `Home` if you first want to locate the earliest available message in the thread.
3. Press `CenterCursor`, then `End` to declare the current message as the thread origin.
4. Repeatedly press `CenterCursor`, then `Cursor Right` to visit each remaining message in the declared thread.
5. FRUMRD reports when the thread has been exhausted.

Thread tracing can only follow messages that exist in the capture file and whose header data is intact.

## Creating an offline reply

1. Position the cursor in the message to which you want to reply.
2. Press `CenterCursor`, then `R`.
3. FRUMRD creates a short reply file such as `R1` or `R2`.
4. Write the reply between the generated `reply nnn` and `/exit` lines.
5. Save the reply file.
6. While connected to the correct CompuServe forum, upload the saved file using ASCII transfer.
7. Delete reply files after they have been used so FRUMRD can efficiently find unused filenames.

The original message must still exist on CompuServe when the prepared reply is uploaded.

## Important cautions

- The `Delete` command removes everything from the current message header up to the next recognized message header without asking for confirmation. TSE's undelete command may be able to restore accidentally deleted text.
- Altered or damaged message headers may prevent FRUMRD from recognizing message boundaries.
- Missing captured messages can break thread navigation.
- A capture containing messages from several forums may occasionally cause thread searches to cross into another forum.
- Compressed-view commands require the expected `mCompressView(0)` key binding.

## Troubleshooting

### The macro does not compile

The source was written for an older TSE SAL environment. Check the compiler's reported line and update obsolete syntax or identifiers as required by your installed TSE version.

### A compressed view does not appear

Confirm that `Alt+V` invokes `mCompressView(0)`. If your editor uses a different key, modify the `pushkey(<alt v>)` statement in the source and recompile it.

### A message or reply cannot be found

Check that the capture includes the referenced message and that its `#:`, `Sb:`, `Fm:`, and `To:` header lines have not been changed.

### Thread following stops early

One or more messages may be absent from the capture. `Ctrl+S` can help locate later messages with the same subject.

### The wrong text is deleted

Use TSE's undelete facility immediately. FRUMRD relies on recognizable message headers to determine where a message ends.

## Original program information

- Program: vmForumReader / FORUMRDR / FRUMRD
- Source version: 1.1
- Source date: 1993-05-27
- Author: Volker Multhopp
- Original CompuServe ID: 71161,2044

The source states that the program may be copied free of charge while all other rights are retained by the author.

## README version history

| Version | Date | Time | Changes |
| --- | --- | --- | --- |
| 1.0.0.0.0 | 2026-09-10 | 01:27:32 CEST | Initial Markdown description, help, command reference, setup instructions, operating steps, cautions, and troubleshooting notes. |

Future README revisions should increment the final component sequentially: `1.0.0.0.1`, `1.0.0.0.2`, and so on.
