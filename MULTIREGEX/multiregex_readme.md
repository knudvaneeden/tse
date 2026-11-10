# MULTIREGEX - version 1.0.0.0.21

TSE SAL-only development release. Correctness-focused final iteration for 10 November 2026. Compile with TSE 4.50.33 before use. No external programs or DLLs. ClipStack is embedded.

## What was fixed

Version 20 stored each source-line length as min(actual_length,125) when planning overlap. That was an approximation, and could change chunk ownership and match results. Version 21 uses TWO 255-byte SAL strings, encoding the exact line length as base-180 digits (digit+1). This preserves the overlap calculation without truncation. If a chunk has 256 lines, the original reverse-scanning planner is used for that chunk. All other search and navigation functions are preserved.

The previously measured difference (23,040 matches in v19 versus 23,270 in v20 on the 10-million-line test) is not proof which version is correct: regex results may depend on available context and chunk boundaries. Version 21 sets FastPlan=0 by default, preserving version 19's planning path. FastPlan=1 enables exact-length cached overlap planning for a controlled comparison. Please do not interpret identical counts alone as proof of complete coverage.

## Package files

- multiregex.s - source, including embedded ClipStack
- multiregex.ini - configuration (FastPlan=0 by default)
- multiregex_readme.md - these notes
- multiregex_test.txt - test data

Only the ZIP name includes the version number. The interface remains two prompts: expression and alphabetically ordered options. The 'v' option opens clickable results, CtrlAltShift G returns, and 'l' restricts to the marked block.

## Correctness tests

1. Compile: sc32 multiregex.s. Confirm no errors.
2. On the supplied small file, search BEGIN TRANSACTION.*COMMIT TRANSACTION using givx. Expect positions 3,1 and 11,1.
3. Mark the second transaction with an inclusive block, search using gilvx. Expect exactly 11,1.
4. Run run.*exe / givx on a COPY of the same 10,046,760-line file with FastPlan=0; record count, skipped lines, chunk count, time. Repeat with FastPlan=1. Compare result COORDINATES, not only counts.
5. If these match, optionally repeat on the 16,364,141-line copy. Do not delete version 19.

## Known limitations

- The scan is NOT proven exhaustive. Regex matches spanning more context than the configured window/overlap may be missed; chunk position can change how greedy and non-greedy operators behave.
- Lines longer than AdaptiveWindow=30000 are still skipped and explicitly counted (4 in one benchmark file, 50 in the other). No claim of full coverage is made.
- This change does not add cancel support or guaranteed speed improvement.
- Timing, coordinate reporting, results navigation and clipboard behavior should be rechecked in the TSE runtime; no TSE compiler is available here.
