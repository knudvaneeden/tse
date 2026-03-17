// euler092.s
// Project Euler - Problem 92: Square Digit Chains
// How many starting numbers below 10,000,000 arrive at 89?
// Version: 1.0
// ------------------------------------------------------------
// TSE SAL rules applied:
//  1. No integer arrays -> cache simulated via CreateTempBuffer()
//  2. No reserved/built-in names used as variables
//     (no val, pos, str, s, mark, old, find, insert, delete,
//      length, copy, etc.)
//  3. String literals well within 255-char limit
//  4. 32-bit integers only (max value checked below)
//  5. Return() always with parentheses
//  6. Warn() used to display final answer
//  7. CopyToWinClip() clips bare answer only
//  8. No AddLine/InsertText of result into any buffer
//  9. No val or pos as variable names
// ------------------------------------------------------------
// Algorithm:
//   For n in 1..9,999,999 compute next(n) = sum of squares of
//   digits.  The max possible next() for a 7-digit number is
//   7 * 81 = 567.  So we build a cache of size 568 (lines 1..568
//   representing indices 0..567) storing 1 if that index reaches
//   89, 0 if it reaches 1, -1 if unknown.
//   For each starting number we walk the chain until we land in
//   the cache range (0..567), then look up the result.
// ------------------------------------------------------------

integer cache_buf   // buffer id for the 568-line cache

// DigitSqSum: compute sum of squares of digits of argument n
// result returned as integer return value
integer proc DigitSqSum(integer nn)
    integer dss_rem
    integer dss_dig
    integer dss_tot
    dss_tot = 0
    dss_rem = nn
    while dss_rem > 0
        dss_dig = dss_rem mod 10
        dss_tot = dss_tot + dss_dig * dss_dig
        dss_rem = dss_rem / 10
    endwhile
    return(dss_tot)
end

// GetCache: read the cached value at index idx (0-based)
// returns 1, 0, or -1
integer proc GetCache(integer idx)
    integer gc_res
    GotoBufferId(cache_buf)
    GotoLine(idx + 1)
    gc_res = Val(GetText(1, 10))
    return(gc_res)
end

// SetCache: write value vv at cache index idx (0-based)
proc SetCache(integer idx, integer vv)
    GotoBufferId(cache_buf)
    GotoLine(idx + 1)
    BegLine()
    KillToEol()
    InsertText(Str(vv), _INSERT_)
end

// Reaches89: return 1 if starting number nn eventually reaches 89,
//            return 0 if it reaches 1
integer proc Reaches89(integer nn)
    integer rr_cur
    integer rr_nxt
    integer rr_cached
    rr_cur = nn
    // walk until we land in the memoized range 0..567
    while rr_cur > 567
        rr_cur = DigitSqSum(rr_cur)
    endwhile
    // now rr_cur is in 0..567; look up cache
    rr_cached = GetCache(rr_cur)
    if rr_cached >= 0
        return(rr_cached)
    endif
    // cache miss: keep walking (rr_cur <= 567, chain is short)
    rr_nxt = rr_cur
    while rr_nxt <> 1 and rr_nxt <> 89
        rr_nxt = DigitSqSum(rr_nxt)
    endwhile
    if rr_nxt == 89
        SetCache(rr_cur, 1)
        return(1)
    endif
    SetCache(rr_cur, 0)
    return(0)
end

proc Main()
    integer orig_buf
    integer kk
    integer total_count
    string  ans_str[20]

    orig_buf = GetBufferId()

    // --- build cache buffer: 568 lines, all initialised to -1 ---
    cache_buf = CreateTempBuffer()
    if cache_buf == 0
        Warn("euler092: could not create temp buffer")
        return()
    endif
    GotoBufferId(cache_buf)
    kk = 0
    while kk <= 567
        AddLine("-1")
        kk = kk + 1
    endwhile

    // Seed the two known fixed points directly
    SetCache(1,  0)   // 1 -> reaches 1
    SetCache(89, 1)   // 89 -> reaches 89

    // --- main loop: count starting numbers 1..9,999,999 ---
    total_count = 0
    kk = 1
    while kk <= 9999999
        if Reaches89(kk)
            total_count = total_count + 1
        endif
        kk = kk + 1
    endwhile

    // --- clean up temp buffer ---
    GotoBufferId(cache_buf)
    AbandonFile()
    GotoBufferId(orig_buf)

    // --- show and clip the answer ---
    ans_str = Str(total_count)
    CopyToWinClip(ans_str)
    Warn("Project Euler #92 answer: " + ans_str)
end
