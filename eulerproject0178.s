// =========================================================================
// Project Euler - Problem 178: Step Numbers
// =========================================================================
// <version>1.0.0.0.1</version>
// Created by: Claude (Anthropic)
// Date: 2025-03-23
//
// Problem statement:
//   Consider the number 45656. Each pair of consecutive digits differs by 1.
//   A number for which every pair of consecutive digits has a difference of
//   exactly 1 is called a step number. A pandigital number contains every
//   decimal digit from 0 to 9 at least once.
//   How many pandigital step numbers are there less than 10^40?
//
// Approach: Dynamic Programming with big-integer arithmetic.
//
//   State: dp[digits][head][low][high]
//     = number of step-number sequences of length 'digits',
//       whose last (rightmost) digit is 'head',
//       and whose complete set of digits used forms the interval [low..high].
//
//   Key insight: because each consecutive digit differs by +-1, the set of
//   all digits used in a step number always forms a contiguous interval.
//   So tracking just 'low' and 'high' is sufficient.
//
//   A pandigital step number satisfies: low==0 AND high==9.
//
//   Transition (extending left by one digit):
//     From (digits, head, low, high):
//       Step DOWN: newHead = head-1 (if head >= 1)
//                  newLow  = min(head-1, low)
//                  newHigh = high
//       Step UP:   newHead = head+1 (if head <= 8)
//                  newLow  = low
//                  newHigh = max(head+1, high)
//     Add dp[digits][head][low][high] to dp[digits+1][newHead][newLow][newHigh]
//
//   Base: dp[1][d][d][d] = 1 for d = 0..9
//
//   Answer = sum of dp[d][h][0][9]  for d=1..40, h=1..9
//   (h starts at 1: no leading zeros allowed in the final number)
//
//   The answer 126461847755 exceeds 32-bit range, so string big-integer
//   addition (BigAdd) is used throughout.
//
//   Storage: the 41 x 10 x 10 x 10 = 41000 table entries are stored as
//   strings in a TSE temp buffer, one value per line.
//   Line number = digits*1000 + head*100 + low*10 + high + 1
//
// History:
//   v1.0.0.0.1 - Initial version. Claude (Anthropic), 2025-03-23.
//                Answer: 126461847755
// =========================================================================

// -------------------------------------------------------------------------
// BigAdd: add two non-negative decimal integer strings, return their sum.
// Handles strings up to 255 digits. Classic right-to-left digit addition.
// -------------------------------------------------------------------------
string proc BigAdd( string aS, string bS )
    string  resultS[255]
    integer carryI
    integer sumI
    integer iAI
    integer iBI
    integer dAI
    integer dBI
    //
    resultS = ""
    carryI  = 0
    iAI     = Length( aS )
    iBI     = Length( bS )
    //
    while iAI >= 1 OR iBI >= 1 OR carryI > 0
        if iAI >= 1
            dAI = Asc( SubStr( aS, iAI, 1 ) ) - 48
            iAI = iAI - 1
        else
            dAI = 0
        endif
        if iBI >= 1
            dBI = Asc( SubStr( bS, iBI, 1 ) ) - 48
            iBI = iBI - 1
        else
            dBI = 0
        endif
        sumI   = dAI + dBI + carryI
        carryI = sumI / 10
        sumI   = sumI mod 10
        resultS = Chr( sumI + 48 ) + resultS
    endwhile
    //
    if Length( resultS ) == 0
        resultS = "0"
    endif
    return( resultS )
end

// -------------------------------------------------------------------------
// DpLineNr: compute 1-based buffer line number for DP table entry.
// digits: 0..40,  head/low/high: 0..9
// flat index = digits*1000 + head*100 + low*10 + high
// -------------------------------------------------------------------------
integer proc DpLineNr( integer digitsI, integer headI, integer lowI, integer highI )
    return( digitsI * 1000 + headI * 100 + lowI * 10 + highI + 1 )
end

// -------------------------------------------------------------------------
// DpGet: retrieve DP entry as a decimal string from the buffer.
// -------------------------------------------------------------------------
string proc DpGet( integer dpBufI, integer digitsI, integer headI, integer lowI, integer highI )
    integer lineI
    //
    lineI = DpLineNr( digitsI, headI, lowI, highI )
    GotoBufferId( dpBufI )
    GotoLine( lineI )
    return( GetText( 1, CurrLineLen() ) )
end

// -------------------------------------------------------------------------
// DpSet: store a decimal string into a DP entry in the buffer.
// -------------------------------------------------------------------------
proc DpSet( integer dpBufI, integer digitsI, integer headI, integer lowI, integer highI, string newValS )
    integer lineI
    //
    lineI = DpLineNr( digitsI, headI, lowI, highI )
    GotoBufferId( dpBufI )
    GotoLine( lineI )
    BegLine()
    KillToEol()
    InsertText( newValS )
end

// =========================================================================
// Main
// =========================================================================
proc Main()
    integer dpBufI
    integer digitsI
    integer headI
    integer lowI
    integer highI
    integer nNewLowI
    integer nNewHighI
    integer nNewHeadI
    integer nLineI
    string  answerS[255]
    string  curS[255]
    string  cellS[255]
    //
    // ------------------------------------------------------------------
    // Allocate DP table buffer: 41000 lines, all initialised to "0".
    // Line index = digits*1000 + head*100 + low*10 + high + 1
    // ------------------------------------------------------------------
    dpBufI = CreateTempBuffer()
    GotoBufferId( dpBufI )
    nLineI = 0
    while nLineI < 41000
        AddLine( "0" )
        nLineI = nLineI + 1
    endwhile
    //
    // ------------------------------------------------------------------
    // Base case: single-digit numbers.
    // dp[1][d][d][d] = 1 for d = 0..9
    // ------------------------------------------------------------------
    headI = 0
    while headI <= 9
        DpSet( dpBufI, 1, headI, headI, headI, "1" )
        headI = headI + 1
    endwhile
    //
    // ------------------------------------------------------------------
    // DP transition: build up from digits 1 to 39 -> fill digits 2..40
    // For each existing non-zero state, propagate to both neighbours.
    // ------------------------------------------------------------------
    digitsI = 1
    while digitsI <= 39
        headI = 0
        while headI <= 9
            lowI = 0
            while lowI <= headI
                highI = headI
                while highI <= 9
                    //
                    curS = DpGet( dpBufI, digitsI, headI, lowI, highI )
                    //
                    if NOT( curS == "0" )
                        //
                        // --- Step DOWN: append digit headI-1 ---
                        if headI >= 1
                            nNewHeadI = headI - 1
                            if nNewHeadI < lowI
                                nNewLowI = nNewHeadI
                            else
                                nNewLowI = lowI
                            endif
                            nNewHighI = highI
                            cellS = DpGet( dpBufI, digitsI + 1, nNewHeadI, nNewLowI, nNewHighI )
                            cellS = BigAdd( cellS, curS )
                            DpSet( dpBufI, digitsI + 1, nNewHeadI, nNewLowI, nNewHighI, cellS )
                        endif
                        //
                        // --- Step UP: append digit headI+1 ---
                        if headI <= 8
                            nNewHeadI = headI + 1
                            nNewLowI  = lowI
                            if nNewHeadI > highI
                                nNewHighI = nNewHeadI
                            else
                                nNewHighI = highI
                            endif
                            cellS = DpGet( dpBufI, digitsI + 1, nNewHeadI, nNewLowI, nNewHighI )
                            cellS = BigAdd( cellS, curS )
                            DpSet( dpBufI, digitsI + 1, nNewHeadI, nNewLowI, nNewHighI, cellS )
                        endif
                        //
                    endif
                    //
                    highI = highI + 1
                endwhile
                lowI = lowI + 1
            endwhile
            headI = headI + 1
        endwhile
        digitsI = digitsI + 1
    endwhile
    //
    // ------------------------------------------------------------------
    // Sum: accumulate dp[d][h][0][9] for d=1..40, h=1..9.
    // h starts at 1: no leading zeros for multi-digit numbers.
    // (No single-digit number can be pandigital, so d=1 contributes 0.)
    // ------------------------------------------------------------------
    answerS = "0"
    digitsI = 1
    while digitsI <= 40
        headI = 1
        while headI <= 9
            curS = DpGet( dpBufI, digitsI, headI, 0, 9 )
            if NOT( curS == "0" )
                answerS = BigAdd( answerS, curS )
            endif
            headI = headI + 1
        endwhile
        digitsI = digitsI + 1
    endwhile
    //
    // ------------------------------------------------------------------
    // Clean up and report result.
    // ------------------------------------------------------------------
    AbandonFile( dpBufI )
    //
    CopyToWinClip( answerS )
    Warn( "Project Euler 178 - Pandigital Step Numbers < 10^40" + Chr(13) +
          "Answer: " + answerS )
    CopyToWinClip( answerS )
end
