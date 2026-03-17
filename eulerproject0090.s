// ============================================================
// euler090.s
// Project Euler - Problem 90: Cube Digit Pairs
//
// Each of the six faces on a cube has a different digit (0-9).
// Two cubes side-by-side can form 2-digit numbers.
// Choosing digits carefully allows all 2-digit squares below 100
// to be displayed: 01, 04, 09, 16, 25, 36, 49, 64, 81.
// 6 and 9 may be flipped upside-down (interchangeable).
// How many distinct unordered pairs of dice arrangements allow
// all nine square numbers to be displayed?
//
// Answer: 1217
//
// Version: 1.0
// ============================================================

// ============================================================
// TSE SAL RULES CHECK
// ============================================================
// [1] No integer arrays:
//       Uses two CreateTempBuffer() buffers:
//       - bid_combos : stores the 210 6-digit combination lines
//       - bid_squares: stores the 9 required square pairs
//       All loops use GotoLine() + GetText() to access "rows".
// [2] No reserved/built-in names as variables:
//       All names checked - none are SAL built-in or reserved:
//       bid_combos, bid_squares, nCombos, nSqr,
//       iIdx, jIdx, sqOk, aOk, bOk,
//       dA0..dA5, dB0..dB5, dg0..dg5,
//       sqPairA, sqPairB, lineA, lineB, lineS,
//       cntValid, ansStr, dg (loop var),
//       c0..c9 (combo digit vars), cnt6, cnt (combo counter),
//       sqA, sqB (square digit pairs),
//       d0..d5 (scratch), chkA, chkB, flipA, flipB
// [3] String lengths <= 255: all strings are short (< 20 chars)
// [4] 32-bit integers only: max value used = 210*210 = 44100
// [5] Return() always has parentheses: yes, used Return(0)
// [6] Warn() for final answer: Warn("Project Euler #90: " + ansStr)
// [7] CopyToWinClip() answer only (bare number string)
// [8] No paste of result into any .s buffer
// [9] Version number in file: Version 1.0 (header above)
// [10] No use of 'val' or 'pos' as variable names: confirmed
// ============================================================

// ------------------------------------------------------------
// HasDigit(die_buf_id, die_line, digit)
//   Checks if a die (6 digits stored in a temp buffer line as
//   a space-separated string "d0 d1 d2 d3 d4 d5") contains the
//   given digit. 6 and 9 are interchangeable.
//   Returns 1 if found, 0 otherwise.
// ------------------------------------------------------------
INTEGER PROC HasDigit(INTEGER die_bid, INTEGER die_ln, INTEGER tgt)
    INTEGER dk, found6or9, k
    STRING  dline[40]

    GotoBufferId(die_bid)
    GotoLine(die_ln)
    dline = GetText(1, 40)

    // If target is 6 or 9, we accept either
    found6or9 = (tgt == 6) OR (tgt == 9)

    FOR k = 1 TO 6
        dk = Val(GetToken(dline, " ", k))
        IF found6or9
            IF (dk == 6) OR (dk == 9)
                RETURN(1)
            ENDIF
        ELSE
            IF dk == tgt
                RETURN(1)
            ENDIF
        ENDIF
    ENDFOR
    RETURN(0)
END

// ------------------------------------------------------------
// ValidPair(combos_bid, lineA, lineB, squares_bid, nSqr)
//   Checks whether the pair of dice at lines lineA and lineB
//   in the combos buffer can display all nSqr squares stored
//   in squares_bid (each line: "sA sB").
//   Returns 1 if valid, 0 otherwise.
// ------------------------------------------------------------
INTEGER PROC ValidPair(INTEGER cb, INTEGER lnA, INTEGER lnB,
                        INTEGER sb, INTEGER nSq)
    INTEGER sqIdx, sqA, sqB, fwdOk, revOk
    STRING  sline[20]

    FOR sqIdx = 1 TO nSq
        GotoBufferId(sb)
        GotoLine(sqIdx)
        sline = GetText(1, 20)
        sqA = Val(GetToken(sline, " ", 1))
        sqB = Val(GetToken(sline, " ", 2))

        // Forward: die A shows sqA, die B shows sqB
        fwdOk = HasDigit(cb, lnA, sqA) AND HasDigit(cb, lnB, sqB)
        // Reverse: die A shows sqB, die B shows sqA
        revOk = HasDigit(cb, lnA, sqB) AND HasDigit(cb, lnB, sqA)

        IF NOT (fwdOk OR revOk)
            RETURN(0)
        ENDIF
    ENDFOR
    RETURN(1)
END

// ------------------------------------------------------------
// Main
// ------------------------------------------------------------
PROC Main()
    INTEGER bid_combos, bid_squares
    INTEGER cnt, iIdx, jIdx, cntValid
    INTEGER c0, c1, c2, c3, c4, c5
    STRING  ansStr[12]

    // ----------------------------------------------------------
    // Build squares buffer: 9 required 2-digit square pairs
    // Each line: "tensDigit unitsDigit"
    // Squares: 01,04,09,16,25,36,49,64,81
    // ----------------------------------------------------------
    bid_squares = CreateTempBuffer()
    GotoBufferId(bid_squares)
    // CreateTempBuffer() leaves one empty first line - use it
    GotoLine(1) BegLine() KillToEol() InsertText("0 1")
    AddLine("0 4")
    AddLine("0 9")
    AddLine("1 6")
    AddLine("2 5")
    AddLine("3 6")
    AddLine("4 9")
    AddLine("6 4")
    AddLine("8 1")

    // ----------------------------------------------------------
    // Build combos buffer: all C(10,6) = 210 combinations
    // Each die is 6 distinct digits chosen from 0..9
    // Line format: "c0 c1 c2 c3 c4 c5"
    // Generated via 6 nested loops with strictly increasing indices
    // ----------------------------------------------------------
    bid_combos = CreateTempBuffer()
    GotoBufferId(bid_combos)
    // Use first line for first combo
    GotoLine(1) BegLine() KillToEol()

    cnt = 0

    FOR c0 = 0 TO 4
      FOR c1 = c0+1 TO 5
        FOR c2 = c1+1 TO 6
          FOR c3 = c2+1 TO 7
            FOR c4 = c3+1 TO 8
              FOR c5 = c4+1 TO 9
                cnt = cnt + 1
                GotoBufferId(bid_combos)
                IF cnt == 1
                    GotoLine(1) BegLine() KillToEol()
                    InsertText(Str(c0)+" "+Str(c1)+" "+Str(c2)+" "+Str(c3)+" "+Str(c4)+" "+Str(c5))
                ELSE
                    GotoLine(cnt - 1)
                    AddLine(Str(c0)+" "+Str(c1)+" "+Str(c2)+" "+Str(c3)+" "+Str(c4)+" "+Str(c5))
                ENDIF
              ENDFOR
            ENDFOR
          ENDFOR
        ENDFOR
      ENDFOR
    ENDFOR

    // cnt should now be 210
    // cnt is used only as a build counter - not reused below

    // ----------------------------------------------------------
    // Count valid unordered pairs (i <= j)
    // ----------------------------------------------------------
    cntValid = 0

    FOR iIdx = 1 TO 210
        FOR jIdx = iIdx TO 210
            IF ValidPair(bid_combos, iIdx, jIdx, bid_squares, 9)
                cntValid = cntValid + 1
            ENDIF
        ENDFOR
    ENDFOR

    // ----------------------------------------------------------
    // Show answer and copy bare number to clipboard
    // ----------------------------------------------------------
    ansStr = Str(cntValid)

    CopyToWinClip(ansStr)

    Warn("Project Euler #90: " + ansStr)

    // Clean up temp buffers
    AbandonFile(bid_combos)
    AbandonFile(bid_squares)

END
