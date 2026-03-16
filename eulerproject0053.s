// Project Euler - Problem 53: Combinatoric Selections
// How many values of C(n,r) for 1 <= n <= 100, 0 <= r <= n
// are greater than one million?
//
// Strategy:
//   Build Pascal's triangle row by row using the recursive identity:
//     C(n,0) = 1
//     C(n,k) = C(n-1,k-1) + C(n-1,k)    for 0 < k < n
//     C(n,n) = 1
//   Cap values at CAP+1 = 2000001 to prevent 32-bit overflow.
//   Count entries exceeding 1000000.
//
// Since SAL strings max out at 255 chars, we cannot store a whole row
// as space-separated tokens on one line (row 100 would need ~800 chars).
// Instead, each temp buffer stores ONE INTEGER PER LINE:
//   line 1 = C(n,0), line 2 = C(n,1), ..., line n+1 = C(n,n)
// GetVal(buf_id, k) simply goes to line k+1 and reads the number.

integer g_prev_id   = 0
integer g_curr_id   = 0
integer g_count     = 0
integer CAP         = 2000000

// ------------------------------------------------------------
// GetVal(buf_id, k) -- return C(row, k) stored at line k+1
// ------------------------------------------------------------
integer proc GetVal(integer buf_id, integer k)
    string  s[32]
    GotoBufferId(buf_id)
    GotoLine(k + 1)
    s = GetText(1, CurrLineLen())
    return( Val(s) )
end

// ------------------------------------------------------------
// BuildRow(n)
//   Reads g_prev_id (row n-1), writes row n into g_curr_id.
//   Each value on its own line.
// ------------------------------------------------------------
proc BuildRow(integer n)
    integer k
    integer left_val
    integer right_val
    integer new_val
    string  s[32]

    GotoBufferId(g_curr_id)
    EmptyBuffer()

    k = 0
    while k <= n
        if k == 0 or k == n
            new_val = 1
        else
            left_val  = GetVal(g_prev_id, k - 1)
            right_val = GetVal(g_prev_id, k)
            new_val   = left_val + right_val
            if new_val > CAP
                new_val = CAP + 1
            endif
        endif

        s = Str(new_val)
        GotoBufferId(g_curr_id)
        AddLine(s)

        k = k + 1
    endwhile
end

// ------------------------------------------------------------
// CopyCurrentToPrev -- make prev a copy of curr
// ------------------------------------------------------------
proc CopyCurrentToPrev()
    integer nLines
    integer i
    string  s[32]

    GotoBufferId(g_curr_id)
    nLines = NumLines()

    GotoBufferId(g_prev_id)
    EmptyBuffer()

    i = 1
    while i <= nLines
        GotoBufferId(g_curr_id)
        GotoLine(i)
        s = GetText(1, CurrLineLen())
        GotoBufferId(g_prev_id)
        AddLine(s)
        i = i + 1
    endwhile
end

// ------------------------------------------------------------
// CountRow(n) -- count entries in g_curr_id exceeding 1000000
// ------------------------------------------------------------
proc CountRow(integer n)
    integer k
    integer v

    k = 0
    while k <= n
        v = GetVal(g_curr_id, k)
        if v > 1000000
            g_count = g_count + 1
        endif
        k = k + 1
    endwhile
end

// ------------------------------------------------------------
// Main
// ------------------------------------------------------------
proc Main()
    integer n
    integer orig_id
    string  result[64]

    orig_id = GetBufferId()

    g_prev_id = CreateTempBuffer()
    g_curr_id = CreateTempBuffer()
    g_count   = 0

    // Seed row 0: one line containing "1"
    GotoBufferId(g_prev_id)
    EmptyBuffer()
    AddLine("1")

    // Process rows 1 to 100
    n = 1
    while n <= 100
        BuildRow(n)
        CountRow(n)
        CopyCurrentToPrev()
        n = n + 1
    endwhile

    // Clean up
    AbandonFile(g_curr_id)
    AbandonFile(g_prev_id)

    GotoBufferId(orig_id)

    result = "PE053 answer: " + Str(g_count)
    Warn(result)
    CopyToWinClip(result)
end
