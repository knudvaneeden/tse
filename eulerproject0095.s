// euler095.s
// Version: 1.1
//
// Project Euler - Problem 95: Amicable Chains
//
// The proper divisors of a number are all divisors excluding the number itself.
// For example, proper divisors of 28 are 1, 2, 4, 7, 14 (sum = 28 => perfect).
// 220 and 284 form an amicable pair (chain of length 2).
// 12496 -> 14288 -> 15472 -> 14536 -> 14264 -> 12496 is a chain of length 5.
//
// Goal: Find the smallest member of the longest amicable chain
//       with no element exceeding 1,000,000.
//
// Answer: 14316  (chain length 28)
//
// KEY BUG FIX vs Version 1.0:
//   The old code required chain_cur == chain_n to accept a cycle.
//   But chain_n may enter the cycle via a tail (e.g. 5916 -> 9204 -> 14316 -> ...).
//   The repeat is chain_cur == 14316, not 5916, so the old code rejected the cycle
//   but STILL marked all 28 cycle nodes as visited, poisoning every later search.
//
//   Fix: when chain_cur reappears anywhere in path_buf, extract the CYCLE PORTION
//   (from cyc_start_idx to end of path) and compare its length with best_len.
//   The tail (path before cyc_start_idx) is not part of the cycle.
//
// Strategy:
//   Phase 1 - Sieve to build sum-of-proper-divisors in ds_buf.
//             One integer per line: line (n+1) = aliquot_sum[n].
//             For each divisor d from 1 to HALF_LIM, add d to every
//             proper multiple 2d, 3d, ... up to LIMIT.
//
//   Phase 2 - For each unvisited n, walk the aliquot chain.
//             path_buf: one line per step, format "node:step_index"
//             so we can both recover the node value and look up where
//             a repeat first appeared (= cycle start index).
//             When chain_cur reappears in path_buf, the cycle is
//             path_buf[cyc_start_idx .. path_len-1].
//             Measure that length; if longest so far, record min member.
//             Mark ALL path nodes visited after each walk.
//
// TSE SAL constraints honoured:
//   - No integer arrays: all tables stored in hidden TSE buffers.
//   - No val/pos as variable names.
//   - No iterate/continue: loop skipping done with nested if/endif.
//   - Return() always with parentheses.
//   - 32-bit integer safety: max sieve product = HALF_LIM*2 = 1,000,000;
//     aliquot sums bounded well below 2,147,483,647.
//   - Warn() displays the final answer.
//   - CopyToWinClip() clips only the bare numeric result.
//   - Result is NOT pasted into any buffer.
//   - All variable declarations immediately after procedure header.
//   - Version number present at top of file.

// -----------------------------------------------------------------------
// Constants
// -----------------------------------------------------------------------
constant LIMIT    = 1000000
constant HALF_LIM = 500000

// -----------------------------------------------------------------------
// Helper: SetDs(idx, new_val)
//   Writes new_val to line (idx+1) of the CURRENT buffer (ds_buf).
// -----------------------------------------------------------------------
proc SetDs(integer idx, integer new_val)
    GotoLine(idx + 1)
    BegLine()
    KillLine()
    InsertLine(Str(new_val))
End

// -----------------------------------------------------------------------
// Helper: GetDs(idx) -> integer
//   Reads line (idx+1) of the CURRENT buffer (ds_buf).
// -----------------------------------------------------------------------
integer proc GetDs(integer idx)
    GotoLine(idx + 1)
    Return(Val(GetText(1, 20)))
End

// -----------------------------------------------------------------------
// Helper: SetVis(idx, mark_val)
//   Writes mark_val to line (idx+1) of the CURRENT buffer (vis_buf).
// -----------------------------------------------------------------------
proc SetVis(integer idx, integer mark_val)
    GotoLine(idx + 1)
    BegLine()
    KillLine()
    InsertLine(Str(mark_val))
End

// -----------------------------------------------------------------------
// Helper: GetVis(idx) -> integer
//   Reads line (idx+1) of the CURRENT buffer (vis_buf).
// -----------------------------------------------------------------------
integer proc GetVis(integer idx)
    GotoLine(idx + 1)
    Return(Val(GetText(1, 20)))
End

// -----------------------------------------------------------------------
// Main procedure
// -----------------------------------------------------------------------
proc Main()
    // -- all variable declarations immediately after procedure header --
    integer ds_buf         // buffer id: aliquot sums (line n+1 = sum for n)
    integer vis_buf        // buffer id: visited flags (0 = unvisited)
    integer path_buf       // buffer id: current walk path, "node:idx" per line
    integer orig_buf       // buffer id to return to at the end
    integer div_k          // outer sieve divisor
    integer mult_j         // sieve multiple counter
    integer cur_prod       // current sieve multiple = div_k * mult_j
    integer cur_sum        // aliquot sum read back during sieve update
    integer chain_n        // outer chain-search loop variable
    integer chain_cur      // current node while walking a chain
    integer chain_next     // next node in chain (= ds[chain_cur])
    integer path_len       // number of entries currently in path_buf
    integer path_lnum      // line-number iterator over path_buf
    integer path_node      // node value read from a path_buf line
    integer path_idx       // step-index value read from a path_buf line
    integer in_cycle       // 0=walking, 1=cycle found, -1=dead end
    integer cyc_start_idx  // 0-based step index where the cycle begins
    integer cyc_len        // length of the detected cycle
    integer best_len       // longest cycle length found so far
    integer best_min       // smallest member of that longest cycle
    integer cur_min        // smallest member of current cycle candidate
    integer tmp_node       // temporary node value during min-search
    integer lnum           // generic line-number iterator
    integer colon_at       // position of ':' separator in path_buf line
    string  line_txt[32]   // raw text of a path_buf line
    string  result_str[12] // Str() of best_min for Warn/clipboard

    orig_buf = GetBufferId()

    // ---------------------------------------------------------------
    // Phase 0: allocate the three working buffers
    // ---------------------------------------------------------------
    ds_buf   = CreateTempBuffer()
    vis_buf  = CreateTempBuffer()
    path_buf = CreateTempBuffer()

    // ---------------------------------------------------------------
    // Phase 1a: fill ds_buf with LIMIT+1 lines, all "0"
    //           line 1 = aliquot_sum[0]  (unused placeholder)
    //           line n+1 = aliquot_sum[n]
    // ---------------------------------------------------------------
    GotoBufferId(ds_buf)
    lnum = 0
    while lnum <= LIMIT
        AddLine("0")
        lnum = lnum + 1
    endwhile

    // ---------------------------------------------------------------
    // Phase 1b: fill vis_buf with LIMIT+1 lines, all "0"
    // ---------------------------------------------------------------
    GotoBufferId(vis_buf)
    lnum = 0
    while lnum <= LIMIT
        AddLine("0")
        lnum = lnum + 1
    endwhile

    // ---------------------------------------------------------------
    // Phase 1c: sieve — for each divisor d, add d to every proper
    //           multiple  2d, 3d, ... up to LIMIT.
    //           Starts at mult_j=2 so we never add n to ds[n].
    // ---------------------------------------------------------------
    GotoBufferId(ds_buf)
    div_k = 1
    while div_k <= HALF_LIM
        mult_j   = 2
        cur_prod = div_k * 2
        while cur_prod <= LIMIT
            cur_sum = GetDs(cur_prod)
            SetDs(cur_prod, cur_sum + div_k)
            mult_j   = mult_j + 1
            cur_prod = div_k * mult_j
        endwhile
        div_k = div_k + 1
    endwhile

    // ---------------------------------------------------------------
    // Phase 2: find longest amicable cycle
    // ---------------------------------------------------------------
    best_len = 0
    best_min = 0

    chain_n = 2
    while chain_n <= LIMIT

        GotoBufferId(vis_buf)
        if GetVis(chain_n) == 0

            // --- walk the aliquot chain from chain_n ---
            GotoBufferId(path_buf)
            EmptyBuffer()      // reuse path_buf for each walk

            path_len  = 0
            chain_cur = chain_n
            in_cycle  = 0

            while in_cycle == 0

                if chain_cur > LIMIT
                    in_cycle = -1
                else
                    if chain_cur <= 1
                        in_cycle = -1
                    else
                        GotoBufferId(vis_buf)
                        if GetVis(chain_cur) <> 0
                            in_cycle = -1
                        else
                            // Scan path_buf for chain_cur
                            // Each line is "node:step_index"
                            GotoBufferId(path_buf)
                            cyc_start_idx = -1
                            path_lnum = 1
                            while path_lnum <= path_len
                                GotoLine(path_lnum)
                                line_txt  = GetText(1, 32)
                                colon_at  = Pos(":", line_txt)
                                path_node = Val(SubStr(line_txt, 1, colon_at - 1))
                                if path_node == chain_cur
                                    path_idx      = Val(SubStr(line_txt, colon_at + 1, 10))
                                    cyc_start_idx = path_idx
                                    path_lnum     = path_len + 1  // exit inner scan
                                else
                                    path_lnum = path_lnum + 1
                                endif
                            endwhile

                            if cyc_start_idx >= 0
                                // cycle found: path entries with step_index >= cyc_start_idx
                                // form the cycle
                                cyc_len = path_len - cyc_start_idx
                                in_cycle = 1
                            else
                                // Append "chain_cur:path_len" to path_buf
                                GotoBufferId(path_buf)
                                AddLine(Str(chain_cur) + ":" + Str(path_len))
                                path_len = path_len + 1

                                GotoBufferId(ds_buf)
                                chain_next = GetDs(chain_cur)
                                chain_cur  = chain_next
                            endif
                        endif
                    endif
                endif

            endwhile  // inner walk loop

            // --- if a cycle was found, check if it is the longest ---
            if in_cycle == 1
                if cyc_len > best_len
                    // Find minimum value among cycle members only
                    // (those with step_index >= cyc_start_idx)
                    cur_min   = LIMIT + 1
                    path_lnum = 1
                    while path_lnum <= path_len
                        GotoBufferId(path_buf)
                        GotoLine(path_lnum)
                        line_txt  = GetText(1, 32)
                        colon_at  = Pos(":", line_txt)
                        path_node = Val(SubStr(line_txt, 1, colon_at - 1))
                        path_idx  = Val(SubStr(line_txt, colon_at + 1, 10))
                        if path_idx >= cyc_start_idx
                            if path_node < cur_min
                                cur_min = path_node
                            endif
                        endif
                        path_lnum = path_lnum + 1
                    endwhile
                    best_len = cyc_len
                    best_min = cur_min
                endif
            endif

            // --- mark ALL walked nodes visited (tail + cycle) ---
            path_lnum = 1
            while path_lnum <= path_len
                GotoBufferId(path_buf)
                GotoLine(path_lnum)
                line_txt  = GetText(1, 32)
                colon_at  = Pos(":", line_txt)
                tmp_node  = Val(SubStr(line_txt, 1, colon_at - 1))
                GotoBufferId(vis_buf)
                SetVis(tmp_node, 1)
                path_lnum = path_lnum + 1
            endwhile

        endif  // if not visited

        chain_n = chain_n + 1
    endwhile  // outer loop

    // ---------------------------------------------------------------
    // Phase 3: display answer and copy to clipboard
    // ---------------------------------------------------------------
    result_str = Str(best_min)

    Warn("Project Euler #95 - Amicable Chains: " + result_str)

    // Copy ONLY the bare numeric answer to the Windows clipboard
    CopyToWinClip(result_str)

    // ---------------------------------------------------------------
    // Phase 4: clean up and restore original buffer
    //          (do NOT paste result into any buffer)
    // ---------------------------------------------------------------
    AbandonFile(path_buf)
    AbandonFile(vis_buf)
    AbandonFile(ds_buf)

    GotoBufferId(orig_buf)

End  // Main
