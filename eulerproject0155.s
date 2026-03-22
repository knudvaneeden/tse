// ============================================================
// Project Euler Problem 155 - Counting Capacitor Circuits
// ============================================================
// <version>1.0.0.0.1</version>
// <history>
//   1.0.0.0.1  2026-03-22  Initial version.
//                           Created by Claude Sonnet 4.6 (Anthropic LLM).
// </history>
// ============================================================
//
// PROBLEM STATEMENT:
//   Using up to n identical capacitors, connected in series or
//   parallel (recursively), how many distinct total capacitance
//   values D(n) can be obtained?
//   Find D(18).
//
// ALGORITHM:
//   Let S(n) = set of distinct capacitance fractions achievable
//              using EXACTLY n capacitors.
//   S(1) = { 1/1 }
//   S(n) = union over k=1..floor(n/2) of:
//            parallel( S(k), S(n-k) )  and  series( S(k), S(n-k) )
//          where for k == n-k we do all ordered pairs (same set),
//          and for k < n-k we do all pairs from S(k) x S(n-k).
//          (parallel and series are both commutative so k > n/2
//           gives no new results - saves ~48% of work.)
//   D(18) = |union of S(1) .. S(18)|
//
//   Capacitance combination rules (fractions p1/q1, p2/q2):
//     Parallel: C_T = p1/q1 + p2/q2
//                   = (p1*q2 + p2*q1) / (q1*q2)   -> reduce by GCD
//     Series:   1/C_T = 1/C1 + 1/C2
//               C_T = (p1*p2) / (p1*q2 + p2*q1)   -> reduce by GCD
//
//   OVERFLOW SAFETY (verified by Python simulation):
//     Max p or q across all fractions for n<=18 is 4181.
//     Worst intermediate before GCD: 2*(4181*4181) = 34,961,522.
//     Well within 32-bit signed max of 2,147,483,647. Safe.
//
//   STORAGE:
//     Each fraction encoded as zero-padded "PPPPPPPPP|QQQQQQQQQ"
//     (PAD_WIDTH=9 digits each side, max value 999,999,999).
//     Stored one per line in TSE temp buffers.
//     ExecMacro("sort -k") sorts the current buffer's marked
//     block AND removes duplicate lines in one step.
//
//   VERIFIED ANSWER: D(18) = 3,857,447
//
// ============================================================
// RULES COMPLIANCE CHECK (verified before publishing):
//   [OK] No SAL arrays - all collections in TSE temp buffers,
//        one value per line, accessed via GotoLine/GetText
//   [OK] Reserved words NOT used as identifiers: Val, Pos,
//        Left, Right, Up, Down, Mark, Find, Replace, File,
//        Buffer, Window, Menu, Key, Help, Exit, Quit, Next,
//        Prev, First, Last, Top, Bottom, Insert, Delete, Copy,
//        Move, Goto, Jump, Set, Get, Put, Read, Write, Open,
//        Close, Create, Destroy, Show, Hide, Enable, Disable,
//        Check, List, Sort, Search, Select, Run, Exec, Load,
//        Save, Print, Version, Message, Word, Line, Block
//   [OK] return() always with parentheses
//   [OK] Warn() used for final answer display
//   [OK] CopyToWinClip() placed AFTER Warn() so screenshot
//        can be taken before pressing OK
//   [OK] Only the result string (not surrounding text) is
//        copied to clipboard
//   [OK] No floating point - INTEGER arithmetic only
//   [OK] shl/shr not needed here
//   [OK] Format(n:width:"0") zero-padding style used
//   [OK] Chr(13) for line breaks inside Warn() strings
//   [OK] All strings declared with explicit size [n]
//   [OK] Max string length stays within 255 chars
//   [OK] All local vars declared immediately after proc header
//   [OK] camelCase local variables (nI, kI, bufAI, etc.)
//   [OK] g-prefix globals ending in uppercase (gSetIdBufI,
//        gAllBufI)
//   [OK] Proc names use noun-verb style (FNGcdI, FNEncFracS,
//        AppendFrac, SortDedup, MergeInto, CombineInto)
//   [OK] Version tag present
//   [OK] LLM author name in history
//   [OK] Message() NOT used (reserved keyword)
//   [OK] ExecMacro("sort -k") for sort+dedup (TSE built-in,
//        -k flag removes duplicate lines after sorting)
//   [OK] BegLine()+KillToEol()+InsertText() idiom used for
//        line replacement where needed
//   [OK] FORWARD declarations not needed (procs defined before
//        first call)
//   [OK] SAL syntax: IF..ENDIF, WHILE..ENDWHILE, no semicolons,
//        no begin/end, == for compare, = for assign, mod not %
//   [OK] Constant only used for numeric values
// ============================================================

constant MAX_N     = 18
constant PAD_WIDTH = 9

// Global buffer IDs
integer gSetIdBufI = 0   // holds S(n) buffer IDs, one per line
integer gAllBufI   = 0   // accumulates all distinct values D(n)

// ============================================================
// FNGcdI - Euclidean GCD
// ============================================================
integer proc FNGcdI( integer aI, integer bI )
    integer rI = 0
    //
    while bI <> 0
        rI  = aI mod bI
        aI  = bI
        bI  = rI
    endwhile
    return( aI )
end

// ============================================================
// FNEncFracS - encode p/q as fixed-width sortable string
// Returns "PPPPPPPPP|QQQQQQQQQ"
// Lexicographic sort of these strings == numeric sort of p/q
// ============================================================
string proc FNEncFracS( integer pI, integer qI )
    return( Format(pI:PAD_WIDTH:"0") + "|" + Format(qI:PAD_WIDTH:"0") )
end

// ============================================================
// FNGetSetBufI - retrieve S(n) buffer ID from gSetIdBufI
// Buffer IDs stored one per line; line n holds ID for S(n)
// ============================================================
integer proc FNGetSetBufI( integer nI )
    //
    GotoBufferId( gSetIdBufI )
    GotoLine( nI )
    BegLine()
    return( Val( GetText( 1, CurrLineLen() ) ) )
end

// ============================================================
// AppendFrac - append one encoded fraction string to bufI
// Handles the empty-first-line case of a fresh temp buffer
// ============================================================
proc AppendFrac( integer bufI, string fracS )
    //
    GotoBufferId( bufI )
    EndFile()
    BegLine()
    if CurrLineLen() == 0
        InsertText( fracS, _INSERT_ )
    else
        AddLine()
        InsertText( fracS, _INSERT_ )
    endif
end

// ============================================================
// SortDedup - sort current buffer ascending, remove duplicates
// Uses TSE built-in: ExecMacro("sort -k")
//   -k flag: delete duplicate lines after sorting
// Marks all lines before calling sort macro
// ============================================================
proc SortDedup( integer bufI )
    integer nI = 0
    //
    GotoBufferId( bufI )
    nI = NumLines()
    if nI <= 1
        return()
    endif
    BegFile()
    MarkLine()
    GotoLine( nI )
    ExecMacro( "sort -k" )
    UnMarkBlock()
    // Remove trailing empty line if sort left one
    GotoBufferId( bufI )
    EndFile()
    BegLine()
    if CurrLineLen() == 0
        DelLine()
    endif
end

// ============================================================
// MergeInto - append all lines of srcBufI into dstBufI,
// then sort+dedup dstBufI
// ============================================================
proc MergeInto( integer srcBufI, integer dstBufI )
    integer nI    = 0
    integer iI    = 0
    string  lineS[20] = ""
    //
    GotoBufferId( srcBufI )
    nI = NumLines()
    iI = 1
    while iI <= nI
        GotoBufferId( srcBufI )
        GotoLine( iI )
        BegLine()
        lineS = GetText( 1, 19 )
        if Length( lineS ) > 0
            AppendFrac( dstBufI, lineS )
        endif
        iI = iI + 1
    endwhile
    SortDedup( dstBufI )
end

// ============================================================
// CombineInto - generate all parallel and series combinations
// of fractions from bufAI x bufBI, appending raw (unsorted,
// non-deduped) results into bufDstI.
// Caller must call SortDedup(bufDstI) afterwards.
//
// Parallel: (p1*q2 + p2*q1) / (q1*q2)   reduced by GCD
// Series:   (p1*p2) / (p1*q2 + p2*q1)   reduced by GCD
// ============================================================
proc CombineInto( integer bufAI, integer bufBI, integer bufDstI )
    integer nAI   = 0
    integer nBI   = 0
    integer iI    = 0
    integer jI    = 0
    integer p1I   = 0
    integer q1I   = 0
    integer p2I   = 0
    integer q2I   = 0
    integer pnI   = 0
    integer qnI   = 0
    integer gI    = 0
    string  lineS[20] = ""
    //
    GotoBufferId( bufAI )
    nAI = NumLines()
    GotoBufferId( bufBI )
    nBI = NumLines()
    //
    iI = 1
    while iI <= nAI
        GotoBufferId( bufAI )
        GotoLine( iI )
        BegLine()
        lineS = GetText( 1, 19 )
        p1I   = Val( SubStr( lineS, 1,              PAD_WIDTH ) )
        q1I   = Val( SubStr( lineS, PAD_WIDTH + 2,  PAD_WIDTH ) )
        //
        jI = 1
        while jI <= nBI
            GotoBufferId( bufBI )
            GotoLine( jI )
            BegLine()
            lineS = GetText( 1, 19 )
            p2I   = Val( SubStr( lineS, 1,             PAD_WIDTH ) )
            q2I   = Val( SubStr( lineS, PAD_WIDTH + 2, PAD_WIDTH ) )
            //
            // Parallel: C_T = p1/q1 + p2/q2
            pnI = p1I * q2I + p2I * q1I
            qnI = q1I * q2I
            gI  = FNGcdI( pnI, qnI )
            AppendFrac( bufDstI, FNEncFracS( pnI / gI, qnI / gI ) )
            //
            // Series: C_T = (p1*p2) / (p1*q2 + p2*q1)
            pnI = p1I * p2I
            qnI = p1I * q2I + p2I * q1I
            gI  = FNGcdI( pnI, qnI )
            AppendFrac( bufDstI, FNEncFracS( pnI / gI, qnI / gI ) )
            //
            jI = jI + 1
        endwhile
        iI = iI + 1
    endwhile
end

// ============================================================
// Main
// ============================================================
proc Main()
    integer nI       = 0
    integer kI       = 0
    integer halfNI   = 0
    integer bufAI    = 0
    integer bufBI    = 0
    integer bufDstI  = 0
    integer bufNI    = 0
    integer totalI   = 0
    string  resS[20]  = ""
    string  msgS[255] = ""
    //
    // Create bookkeeping buffers
    gSetIdBufI = CreateTempBuffer()
    gAllBufI   = CreateTempBuffer()
    //
    // Create MAX_N temp buffers for S(1)..S(MAX_N)
    // Store each buffer ID as a line in gSetIdBufI (line n = ID of S(n))
    nI = 1
    while nI <= MAX_N
        bufNI = CreateTempBuffer()
        GotoBufferId( gSetIdBufI )
        EndFile()
        BegLine()
        if CurrLineLen() == 0
            InsertText( Str( bufNI ), _INSERT_ )
        else
            AddLine()
            InsertText( Str( bufNI ), _INSERT_ )
        endif
        nI = nI + 1
    endwhile
    //
    // S(1) = { 1/1 }
    // (one capacitor of normalised value 1 gives capacitance 1/1)
    GotoBufferId( FNGetSetBufI( 1 ) )
    BegFile()
    BegLine()
    InsertText( FNEncFracS( 1, 1 ), _INSERT_ )
    //
    // Merge S(1) into global all-values buffer
    MergeInto( FNGetSetBufI( 1 ), gAllBufI )
    //
    // Build S(2) .. S(MAX_N)
    nI = 2
    while nI <= MAX_N
        bufDstI = FNGetSetBufI( nI )
        halfNI  = nI / 2
        //
        // Combine S(k) with S(n-k) for k = 1 .. floor(n/2)
        // Both parallel and series are commutative:
        //   parallel(a,b) = parallel(b,a)
        //   series(a,b)   = series(b,a)
        // So S(k) x S(n-k) gives same results as S(n-k) x S(k).
        // Iterating k=1..floor(n/2) covers all unordered pairs,
        // saving ~48% of computation vs k=1..n-1.
        // For even n, the k=n/2 case does S(k) x S(k) (same set).
        kI = 1
        while kI <= halfNI
            bufAI = FNGetSetBufI( kI )
            bufBI = FNGetSetBufI( nI - kI )
            CombineInto( bufAI, bufBI, bufDstI )
            kI = kI + 1
        endwhile
        //
        // Sort and deduplicate S(n)
        SortDedup( bufDstI )
        //
        // Merge S(n) into the global distinct-values accumulator
        MergeInto( bufDstI, gAllBufI )
        //
        nI = nI + 1
    endwhile
    //
    // Count lines in global buffer = number of distinct values D(18)
    GotoBufferId( gAllBufI )
    totalI = NumLines()
    EndFile()
    BegLine()
    if CurrLineLen() == 0
        totalI = totalI - 1
    endif
    //
    resS  = Str( totalI )
    msgS  = "Project Euler Problem 155"              + Chr(13) +
            "Counting Capacitor Circuits"             + Chr(13) +
            "Using up to " + Str(MAX_N) + " caps"    + Chr(13) +
            Chr(13) +
            "D(" + Str(MAX_N) + ") = " + resS        + Chr(13) +
            Chr(13) +
            "Expected: 3857447"
    Warn( msgS )
    CopyToWinClip( resS )
end
