# HISTORY for TSE Pro

**Session:** Create HISTORY MarkDown Readme  
**README version:** 1.0.0.0.0  
**Date and time:** 2026-09-11 00:15:10 CEST  
**Original macro version:** 5.0.6 (29 March 2007)  
**Author:** Carlo Hogeveen  
**Compatibility:** TSE Pro 4.00e and later

## Description

HISTORY is a TSE Pro macro for managing the editor's history lists. It can keep history lists independent, display the history lists currently in use, delete complete lists or individual entries, and automatically remove unwanted entries with configurable cleanup rules.

The independent-list option prevents a frequently used history list from displacing older entries in less frequently used lists. This is useful when you want seldom-used prompts to retain their previous answers.

## Main features

- Keeps TSE history lists independent of one another.
- Enables persistent history automatically when independent histories are selected.
- Balances the available history capacity across the lists in use.
- Shows an overview containing each history-list number, name, and entry count.
- Opens an individual history list for inspection.
- Deletes a selected history item or an entire history list.
- Defines any number of case-insensitive cleanup rules per history list.
- Supports both simple search expressions and TSE regular expressions.
- Performs cleanup periodically while TSE is idle and once more when TSE closes.

## Package contents

| File | Purpose |
| --- | --- |
| `History.s` | TSE SAL source code for the macro. |
| `History.hlp` | Help text displayed from the configuration menu. |
| `History.not` | Cleanup-rule data supplied with the package. |
| `File_id.diz` | Brief package description. |

## Installation

1. Extract `history.zip` into a temporary directory.
2. Copy `History.s` and `History.hlp` to TSE's `mac` directory.
3. Copy `History.not` to the same directory if you want to use the supplied cleanup rules. Preserve an existing customized `History.not` rather than overwriting it.
4. Compile `History.s` with the TSE SAL compiler. For example:

   ```text
   sc32 History.s
   ```

5. Confirm that `History.mac` was created successfully.
6. Start or return to TSE Pro.

Keep `History.hlp` with the macro files because the macro loads it when **Help** is selected.

## How to run and configure HISTORY

1. In TSE, choose **Macro > Execute**.
2. Enter `History` and press **Enter**.
3. Use the **History Configuration** menu:
   - Select **Help** to view the built-in explanation.
   - Select **Independent History Lists** to toggle the feature between `Yes` and `No`.
   - Select **Options per history list...** to view all active history lists.
4. Press **Escape** when configuration is complete. Changes take effect immediately.

If independent histories or cleanup rules are enabled, HISTORY adds itself to TSE's autoload configuration so that maintenance continues in later editor sessions.

## Viewing and deleting history data

1. Execute `History` and select **Options per history list...**.
2. Highlight a history list.
3. Press **Enter** to view its entries, or press **Delete** to delete the complete list.
4. Inside a history list, highlight an entry and press **Delete** to remove that item.
5. Press **Enter** inside the list to edit the cleanup rules belonging to that history list.

Deleting an item or list changes TSE's stored history. Review the selected entry before confirming the operation.

## Cleanup rules

A cleanup rule is a search expression that removes matching entries from one selected history list. Rules are useful for temporary filenames, temporary directories, or command-line entries that should not remain in history.

Cleanup rules are:

- associated with a specific history list;
- case-insensitive;
- either simple expressions or TSE regular expressions;
- checked approximately every five idle minutes;
- checked again when TSE closes;
- also applied immediately before a history list is displayed.

To manage rules:

1. Open **Options per history list...**.
2. Select a history list and press **Enter**.
3. Press **Enter** again to open **Cleanup Rules**.
4. Add, edit, or delete rules using the commands displayed in the list footer.
5. Choose whether each new rule is a simple expression or a regular expression.

For regular-expression syntax, consult the **Regular Expressions** section in the TSE Pro help.

## Independent history lists

With TSE's default behavior, a new entry can remove the oldest entry from any history list when the global limit is reached. HISTORY's independent mode instead protects infrequently used lists by configuring:

- **Persistent History:** On
- **Max History Entries:** TSE's supported maximum
- **Max History Per List:** the available maximum divided among the history lists currently in use

The allocation is recalculated after editor startup. The tradeoff is that busy lists cannot expand by consuming the capacity of less frequently used lists.

## Disabling the macro

1. Execute `History`.
2. Set **Independent History Lists** to `No`.
3. Remove all cleanup rules if none are required.
4. Exit the configuration menu.

When neither feature is active, the macro removes its profile section and autoload entry and purges itself from memory.

## Troubleshooting

### The help screen does not open

Verify that `History.hlp` is present in TSE's `mac` directory and retains the same base name as the macro.

### Cleanup does not occur immediately

Cleanup normally runs while TSE is idle. Open the affected history list to trigger a check immediately, or close TSE normally to run the final cleanup.

### A useful history entry disappears

Review the cleanup rules for that particular list. Rules are case-insensitive, and a broad simple or regular expression may match more entries than intended.

### Changes appear after restarting TSE

HISTORY adjusts persistent-history limits during startup. Restart TSE after the initial setup if you want to verify the resulting behavior from a clean session.

## Version history

### 1.0.0.0.0 — 2026-09-11 00:15:10 CEST

- Created the Markdown description and user guide.
- Documented package contents, installation, configuration, history browsing, cleanup rules, independent-list behavior, disabling, and troubleshooting.
- Based on HISTORY 5.0.6 and its supplied help file.

Future README revisions should increment the last component sequentially: `1.0.0.0.1`, `1.0.0.0.2`, and so on.

