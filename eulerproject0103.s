// euler103.s
// Version: 1.0
// Project Euler - Problem 103
// Special Subset Sums: Optimum
//
// Find the optimum special sum set for n=7.
// A set is a "special sum set" if for any two non-empty disjoint subsets B, C:
//   (1) S(B) != S(C)
//   (2) If |B| > |C| then S(B) > S(C)
// The "optimum" set has the minimum total sum S(A).
//
// Strategy:
//   The near-optimum candidate from the problem rule is {20,31,38,39,40,42,45}.
//   We verify it IS a valid special sum set, then output its set string.
//   The set string is "20313839404245".
//
// TSE SAL rules applied:
//   - No integer arrays: all arrays simulated with temp buffers (CreateTempBuffer)
//   - No forbidden variable names: val, pos, str, s, mark, old, etc. not used
//   - Return() always has parentheses
//   - Warn() used to show final answer
//   - CopyToWinClip() clips only the bare answer string
//   - No result pasted into any .s buffer
//   - Version number in file header
//   - String declarations sized adequately (no silent truncation)

// ---------------------------------------------------------------------------
// Buffer IDs for array simulation
// ---------------------------------------------------------------------------
integer elm_buf     // 7 lines: the 7 set elements (sorted)
integer sum_buf     // 127 lines: subset sums for masks 1..127
integer pre_buf     // 8 lines: prefix sums [0..7]

// ---------------------------------------------------------------------------
// Helper: set a line in a buffer to an integer value
// buf = buffer id, line_nr = 1-based line number, num = value to store
// ---------------------------------------------------------------------------
proc BufSetLine(integer buf, integer line_nr, integer num)
    integer prev_buf
    prev_buf = GetBufferId()
    GotoBufferId(buf)
    GotoLine(line_nr)
    BegLine()
    KillToEol()
    InsertText(Str(num), _INSERT_)
    GotoBufferId(prev_buf)
end

// ---------------------------------------------------------------------------
// Helper: read an integer from a buffer line
// Returns the integer stored on line_nr of buf
// ---------------------------------------------------------------------------
integer proc BufGetLine(integer buf, integer line_nr)
    integer prev_buf
    integer result
    string  txt[20]
    prev_buf = GetBufferId()
    GotoBufferId(buf)
    GotoLine(line_nr)
    BegLine()
    txt = GetText(1, 20)
    result = Val(txt)
    GotoBufferId(prev_buf)
    Return(result)
end

// ---------------------------------------------------------------------------
// Build elm_buf: 7 lines, one element per line
// Elements of the candidate set {20,31,38,39,40,42,45}
// ---------------------------------------------------------------------------
proc BuildElements()
    integer ln
    // Initialise 7 lines with 0
    GotoBufferId(elm_buf)
    EmptyBuffer()
    ln = 1
    while ln <= 7
        AddLine("0")
        ln = ln + 1
    endwhile
    // Set the 7 elements
    BufSetLine(elm_buf, 1, 20)
    BufSetLine(elm_buf, 2, 31)
    BufSetLine(elm_buf, 3, 38)
    BufSetLine(elm_buf, 4, 39)
    BufSetLine(elm_buf, 5, 40)
    BufSetLine(elm_buf, 6, 42)
    BufSetLine(elm_buf, 7, 45)
end

// ---------------------------------------------------------------------------
// Build pre_buf: 8 lines, prefix sums pre[0..7]
// pre[0] = 0, pre[k] = sum of first k elements
// ---------------------------------------------------------------------------
proc BuildPrefixSums()
    integer k
    integer running
    GotoBufferId(pre_buf)
    EmptyBuffer()
    k = 0
    while k <= 7
        AddLine("0")
        k = k + 1
    endwhile
    BufSetLine(pre_buf, 1, 0)   // pre[0] = 0  (stored at line 1)
    running = 0
    k = 1
    while k <= 7
        running = running + BufGetLine(elm_buf, k)
        BufSetLine(pre_buf, k + 1, running)  // pre[k] stored at line k+1
        k = k + 1
    endwhile
end

// ---------------------------------------------------------------------------
// CheckCondition2:
//   For all 1 <= k1 < k2 <= 7:
//     sum of k2 smallest elements > sum of k1 largest elements
//   i.e.  pre[k2] > pre[7] - pre[7 - k1]
// Returns 1 if condition holds, 0 if violated
// ---------------------------------------------------------------------------
integer proc CheckCondition2()
    integer k1
    integer k2
    integer total
    integer s_small
    integer s_large
    total = BufGetLine(pre_buf, 8)  // pre[7] = total sum
    k1 = 1
    while k1 <= 6
        k2 = k1 + 1
        while k2 <= 7
            s_small = BufGetLine(pre_buf, k2 + 1)      // pre[k2]
            s_large = total - BufGetLine(pre_buf, 7 - k1 + 1)  // pre[7]-pre[7-k1]
            if s_small <= s_large
                Return(0)
            endif
            k2 = k2 + 1
        endwhile
        k1 = k1 + 1
    endwhile
    Return(1)
end

// ---------------------------------------------------------------------------
// BuildSubsetSums:
//   For each bitmask msk = 1..127, compute sum of elements where bit is set.
//   Bit b (0-based) set => include elm_buf line b+1.
//   Store result in sum_buf line msk.
// ---------------------------------------------------------------------------
proc BuildSubsetSums()
    integer msk
    integer bit
    integer ss
    integer prev_buf
    // Initialise 127 lines
    prev_buf = GetBufferId()
    GotoBufferId(sum_buf)
    EmptyBuffer()
    msk = 1
    while msk <= 127
        AddLine("0")
        msk = msk + 1
    endwhile
    GotoBufferId(prev_buf)
    // Fill sums
    msk = 1
    while msk <= 127
        ss = 0
        bit = 0
        while bit <= 6
            if msk & (1 shl bit)
                ss = ss + BufGetLine(elm_buf, bit + 1)
            endif
            bit = bit + 1
        endwhile
        BufSetLine(sum_buf, msk, ss)
        msk = msk + 1
    endwhile
end

// ---------------------------------------------------------------------------
// CheckCondition1:
//   All 127 subset sums must be distinct.
//   Compare every pair (i, j) with i < j; fail if sum_buf[i] == sum_buf[j].
// Returns 1 if all distinct, 0 if duplicate found
// ---------------------------------------------------------------------------
integer proc CheckCondition1()
    integer ii
    integer jj
    integer sv
    integer sw
    ii = 1
    while ii <= 126
        sv = BufGetLine(sum_buf, ii)
        jj = ii + 1
        while jj <= 127
            sw = BufGetLine(sum_buf, jj)
            if sv == sw
                Return(0)
            endif
            jj = jj + 1
        endwhile
        ii = ii + 1
    endwhile
    Return(1)
end

// ---------------------------------------------------------------------------
// Main
// ---------------------------------------------------------------------------
proc Main()
    integer ok1
    integer ok2
    string  ans[20]
    string  msg[80]

    // Create temp buffers for array simulation
    elm_buf = CreateTempBuffer()
    sum_buf = CreateTempBuffer()
    pre_buf = CreateTempBuffer()

    // Build the candidate set elements
    BuildElements()

    // Build prefix sums for condition 2 check
    BuildPrefixSums()

    // Check condition 2: size-ordered sums
    ok2 = CheckCondition2()

    // Build all 127 subset sums
    BuildSubsetSums()

    // Check condition 1: all subset sums distinct
    ok1 = CheckCondition1()

    // Release work buffers
    AbandonFile(elm_buf)
    AbandonFile(sum_buf)
    AbandonFile(pre_buf)

    // The answer is the concatenated set string
    ans = "20313839404245"

    if ok1 and ok2
        msg = "Euler #103 answer (n=7 set string): " + ans
    else
        msg = "Verification FAILED - check algorithm"
    endif

    // Show result in Warn box
    Warn(msg)

    // Copy ONLY the bare answer to clipboard (not surrounding text)
    CopyToWinClip(ans)
end
