// ============================================================
// euler084.s
// Project Euler - Problem 84: Monopoly Odds
// https://projecteuler.net/problem=84
//
// Using two 4-sided dice, find the six-digit modal string
// formed by the three most-visited squares on the Monopoly
// board (40 squares, numbered 00..39).
//
// Answer: 101524
//
// Version: 1.4  (fix: SeedRand()->SetRandomSeed())
// ============================================================
//
// TSE SAL rules enforced:
//   [1] No integer arrays  -> counts stored in a temp buffer
//       (40 lines, one integer per line); accessed via
//       SetCount()/GetCount() helper procs
//   [2] No reserved/built-in names as variables
//       -> all variables checked: sq_now, d1, d2, tot, dbl_cnt,
//          cc_ptr, ch_ptr, tmp_sq, crd, nxt, bid, lid,
//          cnt0, cnt1, cnt2, sq0, sq1, sq2, best_c, best_i,
//          ans, s0, s1, s2, kk, mm, line_txt, newval  — none reserved
//          NOTE: 'val' reserved->newval, 'pos' reserved->sq_now
//   [3] return always uses parentheses: return(value)
//   [4] String lengths <= 255  -> all strings are short
//   [5] 32-bit integers only   -> max count ≈ 1 000 000,
//       well within 2 147 483 647
//   [6] Warn() for final answer
//   [7] CopyToWinClip() on the bare answer string only
//   [8] No AddLine/InsertText of the result into any buffer
//   [9] Version number included above
// ============================================================

// ---- global buffer id for the 40-cell count array ----------
integer g_bid = 0

// ---- CC and CH card pointers (cycle 0..15) -----------------
integer g_cc_ptr = 0
integer g_ch_ptr = 0

// ---- doubles counter (3 in a row -> go to JAIL) -----------
integer g_dbl_cnt = 0

// ============================================================
// SetCount(sq, newval) : store newval on line sq+1 of g_bid
// ============================================================
proc SetCount(integer sq, integer newval)
    integer orig_bid
    orig_bid = GetBufferId()
    GotoBufferId(g_bid)
    GotoLine(sq + 1)
    BegLine()
    KillToEol()
    InsertText(Str(newval), _INSERT_)
    GotoBufferId(orig_bid)
end

// ============================================================
// GetCount(sq) : read integer from line sq+1 of g_bid
// ============================================================
integer proc GetCount(integer sq)
    integer orig_bid
    string  line_txt[30]
    orig_bid = GetBufferId()
    GotoBufferId(g_bid)
    GotoLine(sq + 1)
    BegLine()
    line_txt = GetText(1, 20)
    GotoBufferId(orig_bid)
    return(Val(line_txt))
end

// ============================================================
// BumpCount(sq) : increment count for square sq
// ============================================================
proc BumpCount(integer sq)
    SetCount(sq, GetCount(sq) + 1)
end

// ============================================================
// NextRailway(sq) : return position of the next R square
//   Railways at: 5(R1), 15(R2), 25(R3), 35(R4)
// ============================================================
integer proc NextRailway(integer sq)
    if sq < 5
        return(5)
    elseif sq < 15
        return(15)
    elseif sq < 25
        return(25)
    elseif sq < 35
        return(35)
    endif
    return(5)
end

// ============================================================
// NextUtility(sq) : return position of the next U square
//   Utilities at: 12(U1), 28(U2)
// ============================================================
integer proc NextUtility(integer sq)
    if sq < 12
        return(12)
    elseif sq < 28
        return(28)
    endif
    return(12)
end

// ============================================================
// ApplyCCCard(sq) : apply the next Community Chest card.
//   Cards 0 -> GO(0), 1 -> JAIL(10), 2..15 -> stay
//   Returns final square.
// ============================================================
integer proc ApplyCCCard(integer sq)
    integer crd
    crd = g_cc_ptr
    g_cc_ptr = (g_cc_ptr + 1) mod 16
    if crd == 0
        return(0)   // Advance to GO
    elseif crd == 1
        return(10)  // Go to JAIL
    endif
    return(sq)      // Stay
end

// ============================================================
// ApplyCHCard(sq) : apply the next Chance card.
//   10 movement cards (0..9), 6 stay cards (10..15)
//   Returns final square.
// ============================================================
integer proc ApplyCHCard(integer sq)
    integer crd
    integer nxt
    crd = g_ch_ptr
    g_ch_ptr = (g_ch_ptr + 1) mod 16
    case crd
        when 0  return(0)              // Advance to GO
        when 1  return(10)             // Go to JAIL
        when 2  return(11)             // Go to C1
        when 3  return(24)             // Go to E3
        when 4  return(39)             // Go to H2
        when 5  return(5)              // Go to R1
        when 6                         // Go to next R (x2 cards)
            nxt = NextRailway(sq)
            return(nxt)
        when 7
            nxt = NextRailway(sq)
            return(nxt)
        when 8                         // Go to next U
            nxt = NextUtility(sq)
            return(nxt)
        when 9                         // Go back 3 squares
            nxt = (sq - 3 + 40) mod 40
            // If back-3 lands on a CC square, apply CC card
            if (nxt == 2) or (nxt == 17) or (nxt == 33)
                return(ApplyCCCard(nxt))
            endif
            return(nxt)
    endcase
    return(sq)   // cards 10..15 -> stay
end

// ============================================================
// ResolveLanding(sq) : apply G2J / CC / CH rules.
//   Returns the square where the player actually ends up.
// ============================================================
integer proc ResolveLanding(integer sq)
    integer tmp_sq
    // G2J -> go to JAIL
    if sq == 30
        return(10)
    endif
    // Community Chest squares: 2, 17, 33
    if (sq == 2) or (sq == 17) or (sq == 33)
        return(ApplyCCCard(sq))
    endif
    // Chance squares: 7, 22, 36
    if (sq == 7) or (sq == 22) or (sq == 36)
        tmp_sq = ApplyCHCard(sq)
        return(tmp_sq)
    endif
    return(sq)
end

// ============================================================
// SimulateMove(cur_pos) : roll two 4-sided dice, handle
//   three-doubles-in-a-row rule, resolve landing.
//   Returns final square.
// ============================================================
integer proc SimulateMove(integer cur_pos)
    integer d1
    integer d2
    integer tot
    integer nxt
    // Roll two 4-sided dice using TSE's Random()
    // Random(lo,hi) with hi>lo, lo>=0 returns lo..hi inclusive
    d1 = Random(1, 4)
    d2 = Random(1, 4)
    tot = d1 + d2
    if d1 == d2
        g_dbl_cnt = g_dbl_cnt + 1
    else
        g_dbl_cnt = 0
    endif
    // Three consecutive doubles -> go straight to JAIL
    if g_dbl_cnt >= 3
        g_dbl_cnt = 0
        return(10)
    endif
    nxt = (cur_pos + tot) mod 40
    return(ResolveLanding(nxt))
end

// ============================================================
// Main
// ============================================================
proc Main()
    integer sq_now
    integer kk
    integer mm
    integer cnt0, cnt1, cnt2
    integer sq0, sq1, sq2
    integer best_c, best_i
    string  ans[10]
    string  s0[3]
    string  s1[3]
    string  s2[3]

    // ---- Initialise count buffer (40 lines of "0") ---------
    g_bid = CreateTempBuffer()
    kk = 0
    while kk < 40
        AddLine("0")
        kk = kk + 1
    endwhile

    // ---- Seed the PRNG (use current time as seed) ----------
    SetRandomSeed()

    // ---- Reset card pointers and doubles counter -----------
    g_cc_ptr  = 0
    g_ch_ptr  = 0
    g_dbl_cnt = 0

    // ---- Monte Carlo simulation: 1 000 000 moves -----------
    sq_now = 0
    kk    = 0
    while kk < 1000000
        sq_now = SimulateMove(sq_now)
        BumpCount(sq_now)
        kk = kk + 1
    endwhile

    // ---- Find top-3 squares by count ----------------------
    // Pass 1: find 1st highest
    best_c = -1
    best_i = 0
    mm = 0
    while mm < 40
        if GetCount(mm) > best_c
            best_c = GetCount(mm)
            best_i = mm
        endif
        mm = mm + 1
    endwhile
    sq0  = best_i
    cnt0 = best_c

    // Pass 2: find 2nd highest (skip sq0)
    best_c = -1
    best_i = 0
    mm = 0
    while mm < 40
        if (mm <> sq0) and (GetCount(mm) > best_c)
            best_c = GetCount(mm)
            best_i = mm
        endif
        mm = mm + 1
    endwhile
    sq1  = best_i
    cnt1 = best_c

    // Pass 3: find 3rd highest (skip sq0, sq1)
    best_c = -1
    best_i = 0
    mm = 0
    while mm < 40
        if (mm <> sq0) and (mm <> sq1) and (GetCount(mm) > best_c)
            best_c = GetCount(mm)
            best_i = mm
        endif
        mm = mm + 1
    endwhile
    sq2  = best_i
    cnt2 = best_c

    // ---- Build two-digit strings for each square ----------
    // Format each square number as exactly 2 digits
    if sq0 < 10
        s0 = "0" + Str(sq0)
    else
        s0 = Str(sq0)
    endif

    if sq1 < 10
        s1 = "0" + Str(sq1)
    else
        s1 = Str(sq1)
    endif

    if sq2 < 10
        s2 = "0" + Str(sq2)
    else
        s2 = Str(sq2)
    endif

    ans = s0 + s1 + s2

    // ---- Clean up temp buffer ------------------------------
    AbandonFile(g_bid)

    // ---- Show answer in Warn() box -------------------------
    Warn("Project Euler #84 answer: " + ans)

    // ---- Copy ONLY the bare answer to clipboard ------------
    CopyToWinClip(ans)

    // NOTE: result is NOT inserted/pasted into any buffer
end
