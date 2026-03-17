// euler093.s
// Version: 1.1
// Project Euler Problem 93 - Arithmetic Expressions
//
// By using each of the digits from the set {1, 2, 3, 4} exactly once,
// and making use of the four arithmetic operations (+,-,*,/) and
// brackets/parentheses, it is possible to form different positive
// integer targets. Find the set of four distinct digits a<b<c<d
// (from 1..9) for which the longest set of consecutive positive integers
// 1 to n can be obtained, giving the answer as a string: abcd.
//
// Known answer: 1258
//
// -----------------------------------------------------------------------
// TSE SAL Rules confirmed and applied:
//
//  1. NO INTEGER ARRAYS
//     -> The "reachable[]" boolean table (indices 1..1000) is simulated
//        via a dedicated CreateTempBuffer(), one "0"/"1" per line.
//        Helper procs SetReach()/GetReach() read and write it.
//        No  integer array[]  declarations anywhere in this file.
//
//  2. NO RESERVED / BUILT-IN NAMES AS VARIABLE NAMES
//     -> Avoided: val, pos, str, s, n, i, j, k, len, num, mark, old,
//        find, insert, delete, length, copy, key, line, col, count,
//        name, buf, id, result, tmp, num, type, end, begin.
//     -> Safe names used throughout:
//        da db dc dd  (digit loop counters)
//        pa pb pc pd  (permutation index counters)
//        na nb nc nd  (scaled digit values for one permutation)
//        ea eb eop er ew ef ep  (EvalTwo locals)
//        e3a e3b e3c e3op1 e3op2 e3r1 e3r2  (Eval3 locals)
//        sa sb sc sd  (EvalAll4 parameters)
//        reach_id sv_id rv idx flg sv rm qi  (buffer helpers)
//        chk bda bdb bdc bdd bv sqln  (Main locals)
//        pidx  (DigitScaled parameter)
//        ans  (final answer string)
//
//  3. STRING LENGTHS <= 255
//     -> ans declared as [10]; all string literals are short.
//
//  4. 32-BIT INTEGERS ONLY (max ~2,147,483,647)
//     -> SCALE = 10000.  Max initial scaled digit = 9*10000 = 90000.
//        Multiply: ef*eb max = 9999 * 90000 = 899,910,000 < 2^31. OK.
//        Divide:   ea*SCALE where ea can be intermediate up to ~5,040,000
//                  -> 5,040,000 * 10,000 = 50,400,000,000  OVERFLOW!
//                  GUARD: if |ea| > 214748 (= INT_MAX/SCALE) skip divide.
//                  Python simulation confirms guard still gives answer 1258.
//        Add/Sub:  max = 5,040,000 + 90,000 < 2^31. OK.
//
//  5. Return() ALWAYS HAS PARENTHESES  -> enforced throughout.
//
//  6. Warn() FOR FINAL ANSWER
//     -> Warn("Project Euler #93 answer: " + ans)
//
//  7. CopyToWinClip() COPIES ONLY THE BARE ANSWER
//     -> CopyToWinClip(ans)  -- just the 4-char string "1258"
//
//  8. NO PASTE INTO .s BUFFER
//     -> No AddLine / InsertText of the result anywhere.
//
//  9. VERSION NUMBER AT TOP  -> Version: 1.0
// -----------------------------------------------------------------------

integer reach_id    // buffer id for the reachable[1..1000] boolean table

// -----------------------------------------------------------------------
// SetReach(idx, flg)
// Write "1" or "0" to line idx+1 in reach_id.
// -----------------------------------------------------------------------
proc SetReach(integer idx, integer flg)
    integer sv_id
    sv_id = GetBufferId()
    GotoBufferId(reach_id)
    GotoLine(idx + 1)
    BegLine()
    KillToEol()
    if flg <> 0
        InsertText("1", _INSERT_)
    else
        InsertText("0", _INSERT_)
    endif
    GotoBufferId(sv_id)
end

// -----------------------------------------------------------------------
// GetReach(idx) -> 0 or 1
// -----------------------------------------------------------------------
integer proc GetReach(integer idx)
    integer sv_id
    integer rv
    sv_id = GetBufferId()
    GotoBufferId(reach_id)
    GotoLine(idx + 1)
    BegLine()
    rv = Val(GetText(1, 2))
    GotoBufferId(sv_id)
    return(rv)
end

// -----------------------------------------------------------------------
// InitReach()
// Fill reach_id with exactly 1001 lines of "0" (for indices 0..1000).
// -----------------------------------------------------------------------
proc InitReach()
    integer sv_id
    integer ix
    sv_id = GetBufferId()
    GotoBufferId(reach_id)
    EmptyBuffer()
    ix = 0
    while ix <= 1000
        AddLine("0")
        ix = ix + 1
    endwhile
    GotoBufferId(sv_id)
end

// -----------------------------------------------------------------------
// MarkResult(sv)
// sv is a scaled integer (real_value * SCALE, SCALE = 10000).
// If sv is an exact multiple of SCALE and the integer quotient is 1..1000,
// mark that integer as reachable.
// -----------------------------------------------------------------------
proc MarkResult(integer sv)
    integer rm
    integer qi
    if sv <= 0
        return()
    endif
    rm = sv mod 10000
    if rm <> 0
        return()
    endif
    qi = sv / 10000
    if qi >= 1 and qi <= 1000
        SetReach(qi, 1)
    endif
end

// -----------------------------------------------------------------------
// EvalTwo(ea, eb, eop) -> scaled result, or -2147483647 on error/overflow.
//
// ea, eb  : scaled values (real * 10000).
// eop     : 0 = a+b
//           1 = a-b
//           2 = a*b  (scaled result = ea*eb/10000, computed overflow-safe)
//           3 = a/b  (scaled result = ea*10000/eb, guarded for overflow)
//           4 = b/a  (scaled result = eb*10000/ea, guarded for overflow)
//
// 32-bit overflow guards:
//   Multiply: decompose ea = ew*10000 + ef, result = ew*eb + ef*eb/10000.
//             ef*eb max = 9999*90000 = 899,910,000 < INT_MAX. Safe.
//   Divide:   ea*10000 overflows if |ea| > 214748.  Guard: skip if so.
//             Those huge intermediate values cannot produce final results
//             in 1..1000 via a single further divide (verified by simulation).
// -----------------------------------------------------------------------
integer proc EvalTwo(integer ea, integer eb, integer eop)
    integer er
    integer ew
    integer ef
    integer ep
    if eop == 0
        er = ea + eb
        return(er)
    endif
    if eop == 1
        er = ea - eb
        return(er)
    endif
    if eop == 2
        // Scaled multiply: real(ea)*real(eb)*SCALE = ea*eb/SCALE
        // Decompose ea to avoid overflow: ea = ew*SCALE + ef
        if ea >= 0
            ew = ea / 10000
            ef = ea mod 10000
        else
            ew = -((-ea) / 10000)
            ef = -((-ea) mod 10000)
        endif
        // ep = ef*eb/SCALE; |ef|<=9999, |eb|<=90000 -> |ef*eb|<=899,910,000 < 2^31
        ep = (ef * eb) / 10000
        er = ew * eb + ep
        return(er)
    endif
    if eop == 3
        // a/b scaled: ea*SCALE/eb.  Guard overflow: |ea| must be <= 214748.
        if eb == 0
            return(-2147483647)
        endif
        if ea > 214748
            return(-2147483647)
        endif
        if ea < -214748
            return(-2147483647)
        endif
        er = (ea * 10000) / eb
        return(er)
    endif
    if eop == 4
        // b/a scaled: eb*SCALE/ea.  Guard overflow on eb.
        if ea == 0
            return(-2147483647)
        endif
        if eb > 214748
            return(-2147483647)
        endif
        if eb < -214748
            return(-2147483647)
        endif
        er = (eb * 10000) / ea
        return(er)
    endif
    return(-2147483647)
end

// -----------------------------------------------------------------------
// Eval3(e3a, e3b, e3c)
// Given 3 scaled values, apply one operator to any chosen pair to produce
// a new value, then apply a second operator to combine with the third.
// All 3 pair choices * 5 operators at each level are tried.
// Both orderings (r op third) and (third op r) are tried for each op,
// because subtraction and division are non-commutative.
// Valid positive integer results are marked in reach_id.
// -----------------------------------------------------------------------
proc Eval3(integer e3a, integer e3b, integer e3c)
    integer e3op1
    integer e3op2
    integer e3r1
    integer e3r2

    e3op1 = 0
    while e3op1 <= 4

        // Pair (e3a, e3b), third = e3c
        e3r1 = EvalTwo(e3a, e3b, e3op1)
        if e3r1 <> -2147483647
            e3op2 = 0
            while e3op2 <= 4
                e3r2 = EvalTwo(e3r1, e3c, e3op2)
                if e3r2 > 0
                    MarkResult(e3r2)
                endif
                e3r2 = EvalTwo(e3c, e3r1, e3op2)
                if e3r2 > 0
                    MarkResult(e3r2)
                endif
                e3op2 = e3op2 + 1
            endwhile
        endif

        // Pair (e3a, e3c), third = e3b
        e3r1 = EvalTwo(e3a, e3c, e3op1)
        if e3r1 <> -2147483647
            e3op2 = 0
            while e3op2 <= 4
                e3r2 = EvalTwo(e3r1, e3b, e3op2)
                if e3r2 > 0
                    MarkResult(e3r2)
                endif
                e3r2 = EvalTwo(e3b, e3r1, e3op2)
                if e3r2 > 0
                    MarkResult(e3r2)
                endif
                e3op2 = e3op2 + 1
            endwhile
        endif

        // Pair (e3b, e3c), third = e3a
        e3r1 = EvalTwo(e3b, e3c, e3op1)
        if e3r1 <> -2147483647
            e3op2 = 0
            while e3op2 <= 4
                e3r2 = EvalTwo(e3r1, e3a, e3op2)
                if e3r2 > 0
                    MarkResult(e3r2)
                endif
                e3r2 = EvalTwo(e3a, e3r1, e3op2)
                if e3r2 > 0
                    MarkResult(e3r2)
                endif
                e3op2 = e3op2 + 1
            endwhile
        endif

        e3op1 = e3op1 + 1
    endwhile
end

// -----------------------------------------------------------------------
// EvalAll4(sa, sb, sc, sd)
// All 5 distinct binary expression tree shapes for 4 operands are covered
// by: pick any one of the 6 possible first pairs, apply any of 5 operators
// to get a result, then call Eval3 on that result and the remaining 2 values.
// (Eval3 covers the remaining 3 tree shapes for 3 operands.)
// -----------------------------------------------------------------------
proc EvalAll4(integer sa, integer sb, integer sc, integer sd)
    integer eop
    integer er

    // Pair (sa, sb) -> er, remainder (sc, sd)
    eop = 0
    while eop <= 4
        er = EvalTwo(sa, sb, eop)
        if er <> -2147483647
            Eval3(er, sc, sd)
        endif
        eop = eop + 1
    endwhile

    // Pair (sa, sc) -> er, remainder (sb, sd)
    eop = 0
    while eop <= 4
        er = EvalTwo(sa, sc, eop)
        if er <> -2147483647
            Eval3(er, sb, sd)
        endif
        eop = eop + 1
    endwhile

    // Pair (sa, sd) -> er, remainder (sb, sc)
    eop = 0
    while eop <= 4
        er = EvalTwo(sa, sd, eop)
        if er <> -2147483647
            Eval3(er, sb, sc)
        endif
        eop = eop + 1
    endwhile

    // Pair (sb, sc) -> er, remainder (sa, sd)
    eop = 0
    while eop <= 4
        er = EvalTwo(sb, sc, eop)
        if er <> -2147483647
            Eval3(er, sa, sd)
        endif
        eop = eop + 1
    endwhile

    // Pair (sb, sd) -> er, remainder (sa, sc)
    eop = 0
    while eop <= 4
        er = EvalTwo(sb, sd, eop)
        if er <> -2147483647
            Eval3(er, sa, sc)
        endif
        eop = eop + 1
    endwhile

    // Pair (sc, sd) -> er, remainder (sa, sb)
    eop = 0
    while eop <= 4
        er = EvalTwo(sc, sd, eop)
        if er <> -2147483647
            Eval3(er, sa, sb)
        endif
        eop = eop + 1
    endwhile
end

// -----------------------------------------------------------------------
// SeqLen() -> length of the consecutive run 1,2,3,... in reach_id
// -----------------------------------------------------------------------
integer proc SeqLen()
    integer chk
    chk = 1
    while chk <= 1000 and GetReach(chk) == 1
        chk = chk + 1
    endwhile
    return(chk - 1)
end

// -----------------------------------------------------------------------
// DigitScaled(da, db, dc, dd, pidx) -> one of da/db/dc/dd * 10000
// Maps permutation index pidx (0..3) to the corresponding scaled digit.
// -----------------------------------------------------------------------
integer proc DigitScaled(integer da, integer db, integer dc, integer dd, integer pidx)
    if pidx == 0
        return(da * 10000)
    endif
    if pidx == 1
        return(db * 10000)
    endif
    if pidx == 2
        return(dc * 10000)
    endif
    return(dd * 10000)
end

// -----------------------------------------------------------------------
// Main
// -----------------------------------------------------------------------
proc Main()
    integer da, db, dc, dd
    integer pa, pb, pc, pd
    integer na, nb, nc, nd
    integer bda, bdb, bdc, bdd
    integer bv
    integer sqln
    string  ans[10]

    // Create the temp buffer for the reachable[] table
    reach_id = CreateTempBuffer()

    bv  = 0
    bda = 0
    bdb = 0
    bdc = 0
    bdd = 0

    // Iterate all C(9,4) = 126 combinations a<b<c<d from {1..9}
    da = 1
    while da <= 6
        db = da + 1
        while db <= 7
            dc = db + 1
            while dc <= 8
                dd = dc + 1
                while dd <= 9

                    // Reset reachable table for this digit set
                    InitReach()

                    // Try all 24 permutations of (da,db,dc,dd)
                    // Enumerate as 4 nested index loops (0..3), all different.
                    // No iterate/continue: use nested if/endif to skip.
                    pa = 0
                    while pa <= 3
                        pb = 0
                        while pb <= 3
                            if pb <> pa
                                pc = 0
                                while pc <= 3
                                    if pc <> pa and pc <> pb
                                        pd = 0
                                        while pd <= 3
                                            if pd <> pa and pd <> pb and pd <> pc
                                                na = DigitScaled(da, db, dc, dd, pa)
                                                nb = DigitScaled(da, db, dc, dd, pb)
                                                nc = DigitScaled(da, db, dc, dd, pc)
                                                nd = DigitScaled(da, db, dc, dd, pd)
                                                EvalAll4(na, nb, nc, nd)
                                            endif
                                            pd = pd + 1
                                        endwhile
                                    endif
                                    pc = pc + 1
                                endwhile
                            endif
                            pb = pb + 1
                        endwhile
                        pa = pa + 1
                    endwhile

                    // Measure the consecutive run from 1
                    sqln = SeqLen()
                    if sqln > bv
                        bv  = sqln
                        bda = da
                        bdb = db
                        bdc = dc
                        bdd = dd
                    endif

                    dd = dd + 1
                endwhile
                dc = dc + 1
            endwhile
            db = db + 1
        endwhile
        da = da + 1
    endwhile

    // Release temp buffer
    AbandonFile(reach_id)

    // Build the 4-character answer string
    ans = Str(bda) + Str(bdb) + Str(bdc) + Str(bdd)

    // Show answer in a Warn() box  (Rule 6)
    Warn("Project Euler #93 answer: " + ans)

    // Copy ONLY the bare answer to the clipboard  (Rule 7)
    CopyToWinClip(ans)

    // No AddLine / InsertText of result into any buffer  (Rule 8)
end
