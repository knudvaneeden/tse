/****************************************************************************
 * euler018.s  -  Project Euler Problem 18: Maximum Path Sum I
 *
 * Strategy: bottom-up dynamic programming stored in a TSE buffer.
 *   Each line of the buffer holds one integer (one triangle cell).
 *   Row r, column c  ->  buffer line  r*(r+1)/2 + c + 1  (1-based).
 *
 *   Work upward from row 13. For each cell add the larger of its two
 *   children. After the pass the answer is on line 1 of the buffer.
 *
 * Answer: 1074
 *
 * Version: 1.0.0.2
 ****************************************************************************/

CONSTANT MAX_ROWS = 15

INTEGER g_bufG = 0      // buffer id for the triangle data

/*--------------------------------------------------------------------------
 * triLine  -  (row, col) -> 1-based buffer line number
 *--------------------------------------------------------------------------*/
INTEGER PROC triLine(INTEGER row, INTEGER col)
    RETURN (row * (row + 1) / 2 + col + 1)
END

/*--------------------------------------------------------------------------
 * triGet  -  read integer from triangle cell (row, col)
 *--------------------------------------------------------------------------*/
INTEGER PROC triGet(INTEGER row, INTEGER col)
    INTEGER ln
    ln = triLine(row, col)
    GotoBufferId(g_bufG)
    GotoLine(ln)
    RETURN (Val(GetText(1, CurrLineLen())))
END

/*--------------------------------------------------------------------------
 * triSet  -  write integer to triangle cell (row, col)
 *--------------------------------------------------------------------------*/
PROC triSet(INTEGER row, INTEGER col, INTEGER n)
    INTEGER ln
    ln = triLine(row, col)
    GotoBufferId(g_bufG)
    GotoLine(ln)
    BegLine()
    KillToEol()
    InsertText(Str(n), _INSERT_)
END

/*--------------------------------------------------------------------------
 * initTriangle  -  create scratch buffer and populate with triangle data
 *--------------------------------------------------------------------------*/
PROC initTriangle()
    g_bufG = CreateTempBuffer()
    GotoBufferId(g_bufG)

    // Insert all 120 lines (row by row, one value per line).
    // Row 0
    AddLine("75")
    // Row 1
    AddLine("95")   AddLine("64")
    // Row 2
    AddLine("17")   AddLine("47")   AddLine("82")
    // Row 3
    AddLine("18")   AddLine("35")   AddLine("87")   AddLine("10")
    // Row 4
    AddLine("20")   AddLine("4")    AddLine("82")
    AddLine("47")   AddLine("65")
    // Row 5
    AddLine("19")   AddLine("1")    AddLine("23")
    AddLine("75")   AddLine("3")    AddLine("34")
    // Row 6
    AddLine("88")   AddLine("2")    AddLine("77")
    AddLine("73")   AddLine("7")    AddLine("63")   AddLine("67")
    // Row 7
    AddLine("99")   AddLine("65")   AddLine("4")
    AddLine("28")   AddLine("6")    AddLine("16")
    AddLine("70")   AddLine("92")
    // Row 8
    AddLine("41")   AddLine("41")   AddLine("26")
    AddLine("56")   AddLine("83")   AddLine("40")
    AddLine("80")   AddLine("70")   AddLine("33")
    // Row 9
    AddLine("41")   AddLine("48")   AddLine("72")
    AddLine("33")   AddLine("47")   AddLine("32")
    AddLine("37")   AddLine("16")   AddLine("94")
    AddLine("29")
    // Row 10
    AddLine("53")   AddLine("71")   AddLine("44")
    AddLine("65")   AddLine("25")   AddLine("43")
    AddLine("91")   AddLine("52")   AddLine("97")
    AddLine("51")   AddLine("14")
    // Row 11
    AddLine("70")   AddLine("11")   AddLine("33")
    AddLine("28")   AddLine("77")   AddLine("73")
    AddLine("17")   AddLine("78")   AddLine("39")
    AddLine("68")   AddLine("17")   AddLine("57")
    // Row 12
    AddLine("91")   AddLine("71")   AddLine("52")
    AddLine("38")   AddLine("17")   AddLine("14")
    AddLine("91")   AddLine("43")   AddLine("58")
    AddLine("50")   AddLine("27")   AddLine("29")
    AddLine("48")
    // Row 13
    AddLine("63")   AddLine("66")   AddLine("4")
    AddLine("68")   AddLine("89")   AddLine("53")
    AddLine("67")   AddLine("30")   AddLine("73")
    AddLine("16")   AddLine("69")   AddLine("87")
    AddLine("40")   AddLine("31")
    // Row 14  (bottom)
    AddLine("4")    AddLine("62")   AddLine("98")
    AddLine("27")   AddLine("23")   AddLine("9")
    AddLine("70")   AddLine("98")   AddLine("73")
    AddLine("93")   AddLine("38")   AddLine("53")
    AddLine("60")   AddLine("4")    AddLine("23")
END

/*--------------------------------------------------------------------------
 * maxPathSum  -  bottom-up DP; returns the maximum path sum
 *--------------------------------------------------------------------------*/
INTEGER PROC maxPathSum()
    INTEGER r, c, childL, childR, bigger, cellVal

    r = MAX_ROWS - 2          // row 13 (second-to-last)
    WHILE r >= 0
        c = 0
        WHILE c <= r
            childL = triGet(r + 1, c)
            childR = triGet(r + 1, c + 1)
            IF childL > childR
                bigger = childL
            ELSE
                bigger = childR
            ENDIF
            cellVal = triGet(r, c)
            triSet(r, c, cellVal + bigger)
            c = c + 1
        ENDWHILE
        r = r - 1
    ENDWHILE

    RETURN (triGet(0, 0))
END

/*--------------------------------------------------------------------------
 * main  -  entry point
 *--------------------------------------------------------------------------*/
PROC main()
    INTEGER answer
    INTEGER prevBufG

    prevBufG = GetBufferId()

    initTriangle()
    answer = maxPathSum()

    AbandonFile(g_bufG)
    g_bufG = 0

    GotoBufferId(prevBufG)

    Warn("Euler #18 - Maximum Path Sum I:  ", answer)
    CopyToWinClip( Str( answer) )
END
