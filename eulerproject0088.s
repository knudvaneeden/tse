// euler088.s
// Project Euler - Problem 88: Product-sum Numbers
// https://projecteuler.net/problem=88
//
// A natural number N that can be written as both the sum and product of a set
// of at least two natural numbers {a1, a2, ..., ak} is called a product-sum
// number.  For a given set size k, the smallest such N is the minimal
// product-sum number.  Find the sum of all distinct minimal product-sum
// numbers for 2 <= k <= 12000.
//
// Algorithm:
//   For any factorisation of N into m factors (each >= 2) with product P
//   and factor-sum S, padding with (P - S) ones gives a set of size
//   k = m + (P - S) whose product and sum both equal P.
//   Upper bound: 2*k always works, so products only need to reach
//   NMAX = 2 * 12000 = 24000.
//
// Buffer layout (TSE SAL CreateTempBuffer always has 1 initial line):
//
//   minN_buf   11999 lines.
//              Initialise: write BIGVAL to line 1, AddLine(BIGVAL) for 11998 more.
//              Line i = minN[i+1], so GotoLine(k-1) accesses minN[k].
//              k=2 -> line 1; k=12000 -> line 11999. All within bounds.
//
//   stack_buf  4 lines per DFS frame (prod / sumf / nf / cf).
//              Initialise: write root prod=1 to line 1, AddLine for sumf/nf/cf.
//              Top frame = last 4 lines; frm_base = NumLines()-3.
//              After full pop: 1 line remains (TSE minimum); NumLines()=1 < 4.
//
//   seen_buf   24001 lines (flags for product values 0..24000).
//              Initialise: write "0" to line 1, AddLine("0") for 24000 more.
//              Line (v+1) = flag for value v.
//              GotoLine(cur_val+1): v=0->line 1; v=24000->line 24001.
//
// Version: 1.2
// ---------------------------------------------------------------------------

CONSTANT KMAX   = 12000   // maximum set size k
CONSTANT NMAX   = 24000   // upper bound for product (2 * KMAX)
CONSTANT BIGVAL = 48001   // "infinity" sentinel for minN initialisation

// ---------------------------------------------------------------------------
// WriteInt : overwrite current line with integer wv
// ---------------------------------------------------------------------------
PROC WriteInt(INTEGER wv)
    BegLine()
    KillToEol()
    InsertText(Str(wv), _INSERT_)
END WriteInt

// ---------------------------------------------------------------------------
// ReadInt : read integer from current line
// ---------------------------------------------------------------------------
INTEGER PROC ReadInt()
    RETURN(Val(GetText(1, 20)))
END ReadInt

// ---------------------------------------------------------------------------
// Main
// ---------------------------------------------------------------------------
PROC Main()

    INTEGER minN_buf    // buffer id: minN[2..12000], 11999 lines
    INTEGER stack_buf   // buffer id: DFS stack, 4 lines per frame
    INTEGER seen_buf    // buffer id: uniqueness flags, 24001 lines

    INTEGER sp_prod     // top frame: current product
    INTEGER sp_sumf     // top frame: sum of chosen factors
    INTEGER sp_nf       // top frame: number of factors chosen so far
    INTEGER sp_cf       // top frame: factor currently being tried

    INTEGER nw_prod     // child: product after adding factor sp_cf
    INTEGER nw_sumf     // child: sum after adding factor sp_cf
    INTEGER nw_nf       // child: factor count after adding sp_cf

    INTEGER kv          // k = nw_nf + nw_prod - nw_sumf
    INTEGER old_min     // previous best value for minN[kv]
    INTEGER frm_base    // line number of first line of top DFS frame
    INTEGER idx         // loop counter
    INTEGER tot_sum     // accumulator: sum of distinct minN values
    INTEGER cur_val     // one minN value during final summation
    STRING  ans_str[30] // final answer as printable string

    // -----------------------------------------------------------------------
    // 1.  minN_buf: 11999 lines, each = BIGVAL.
    //     Line 1 = minN[2], line 2 = minN[3], ..., line 11999 = minN[12000].
    //     Access: GotoLine(k - 1).
    //     Initialise line 1 directly (it already exists after CreateTempBuffer).
    //     Then AddLine for lines 2..11999.
    // -----------------------------------------------------------------------
    minN_buf = CreateTempBuffer()
    IF minN_buf == -1
        Warn("euler088: cannot create minN buffer")
        RETURN()
    ENDIF
    WriteInt(BIGVAL)              // line 1 = minN[2]
    idx = 2
    WHILE idx <= KMAX - 1        // add lines 2..11999 = minN[3..12000]
        AddLine(Str(BIGVAL))
        idx = idx + 1
    ENDWHILE

    // -----------------------------------------------------------------------
    // 2.  stack_buf: root DFS frame in lines 1..4.
    //     prod=1, sumf=0, nf=0, cf=2.
    //     Line 1 already exists; write prod to it, AddLine for the rest.
    // -----------------------------------------------------------------------
    stack_buf = CreateTempBuffer()
    IF stack_buf == -1
        Warn("euler088: cannot create stack buffer")
        RETURN()
    ENDIF
    WriteInt(1)    // line 1: prod = 1
    AddLine("0")   // line 2: sumf = 0
    AddLine("0")   // line 3: nf   = 0
    AddLine("2")   // line 4: cf   = 2

    // -----------------------------------------------------------------------
    // 3.  Iterative DFS.
    //     Top frame occupies lines frm_base .. frm_base+3 where
    //     frm_base = NumLines() - 3.
    //     If cf * prod > NMAX: pop the 4 lines.
    //     Else: update minN, increment cf in top frame, push child frame.
    // -----------------------------------------------------------------------
    GotoBufferId(stack_buf)

    WHILE NumLines() >= 4

        frm_base = NumLines() - 3

        GotoLine(frm_base)
        sp_prod = ReadInt()

        GotoLine(frm_base + 1)
        sp_sumf = ReadInt()

        GotoLine(frm_base + 2)
        sp_nf = ReadInt()

        GotoLine(frm_base + 3)
        sp_cf = ReadInt()

        IF (sp_cf * sp_prod) > NMAX

            // Pop: kill lines from top down to keep numbering stable
            GotoLine(frm_base + 3)
            KillLine()
            GotoLine(frm_base + 2)
            KillLine()
            GotoLine(frm_base + 1)
            KillLine()
            GotoLine(frm_base)
            KillLine()

        ELSE

            nw_prod = sp_prod * sp_cf
            nw_sumf = sp_sumf + sp_cf
            nw_nf   = sp_nf + 1

            // Update minN when we have at least 2 factors
            IF nw_nf >= 2
                kv = nw_nf + nw_prod - nw_sumf
                IF (kv >= 2) AND (kv <= KMAX)
                    GotoBufferId(minN_buf)
                    GotoLine(kv - 1)      // line (k-1) = minN[k]
                    old_min = ReadInt()
                    IF nw_prod < old_min
                        WriteInt(nw_prod)
                    ENDIF
                    GotoBufferId(stack_buf)
                ENDIF
            ENDIF

            // Increment cf so next visit tries cf+1
            GotoLine(frm_base + 3)
            WriteInt(sp_cf + 1)

            // Push child frame (go deeper; min-factor stays sp_cf)
            AddLine(Str(nw_prod))
            AddLine(Str(nw_sumf))
            AddLine(Str(nw_nf))
            AddLine(Str(sp_cf))

        ENDIF

    ENDWHILE

    AbandonFile(stack_buf)

    // -----------------------------------------------------------------------
    // 4.  seen_buf: 24001 lines for flags of values 0..24000.
    //     Line 1 = flag for value 0; line (v+1) = flag for value v.
    //     Initialise line 1 to "0", AddLine("0") for lines 2..24001.
    // -----------------------------------------------------------------------
    seen_buf = CreateTempBuffer()
    IF seen_buf == -1
        Warn("euler088: cannot create seen buffer")
        RETURN()
    ENDIF
    WriteInt(0)                   // line 1 = flag for value 0
    idx = 1
    WHILE idx <= NMAX             // add lines 2..24001 (flags for values 1..24000)
        AddLine("0")
        idx = idx + 1
    ENDWHILE

    // -----------------------------------------------------------------------
    // 5.  Sum distinct minN values for k = 2..12000.
    //     idx runs 1..11999; GotoLine(idx) gives minN[idx+1] = minN[k] for k=idx+1.
    //     So k = 2..12000 as idx = 1..11999.
    // -----------------------------------------------------------------------
    tot_sum = 0
    idx = 1
    WHILE idx <= KMAX - 1

        GotoBufferId(minN_buf)
        GotoLine(idx)             // line idx = minN[idx+1]
        cur_val = ReadInt()

        GotoBufferId(seen_buf)
        GotoLine(cur_val + 1)     // line (v+1) = flag for value v
        IF ReadInt() == 0
            WriteInt(1)
            tot_sum = tot_sum + cur_val
        ENDIF

        idx = idx + 1
    ENDWHILE

    AbandonFile(seen_buf)
    AbandonFile(minN_buf)

    // -----------------------------------------------------------------------
    // 6.  Output.
    // -----------------------------------------------------------------------
    ans_str = Str(tot_sum)

    CopyToWinClip(ans_str)
    Warn("Project Euler #88 answer: " + ans_str)

END Main
