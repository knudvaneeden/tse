// ===========================================================================
// Project Euler - Problem 169: Sums of Powers of Two
// ===========================================================================
// Define f(0)=1 and f(n) to be the number of different ways n can be
// expressed as a sum of integer powers of 2, using each power no more
// than twice.
// What is f(10^25)?
//
// Recurrence (derived from LSB analysis):
//   f(0)        = 1
//   f(n) n odd  = f((n-1)/2)
//   f(n) n even = f(n/2) + f(n/2-1)
//
// Fully iterative: a TSE buffer acts as an explicit call-stack so there
// is zero SAL recursion.  A second buffer holds the memoisation table.
// All arithmetic on n uses decimal big-integer strings (n up to 26 digits).
// Result values also use decimal strings: final answer ~1.78e11 > 2^31-1.
//
// Expected answer: 178653872807
//
// <version>1.0.0.0.2</version>
// Created by: Claude (Anthropic)
// History:
//   1.0.0.0.1  2026-03-22  Recursive version - stack overflow on SAL.
//   1.0.0.0.2  2026-03-22  Fully iterative (explicit stack buffer).
//                           Claude (Anthropic).
// ===========================================================================

// ---------------------------------------------------------------------------
// Globals
// ---------------------------------------------------------------------------
integer gMemoBufI  = 0   // memoisation buffer  - lines "key|value"
integer gStackBufI = 0   // explicit call stack - lines = decimal key strings

// ---------------------------------------------------------------------------
// BigIsZero: TRUE if decimal string represents 0
// ---------------------------------------------------------------------------
integer proc BigIsZero(string nS)
    integer idxI, resultI
    //
    resultI = TRUE
    for idxI = 1 to Length(nS)
        if SubStr(nS, idxI, 1) <> "0"
            resultI = FALSE
        endif
    endfor
    return( resultI )
end

// ---------------------------------------------------------------------------
// BigIsEven: TRUE if decimal string represents an even number
// ---------------------------------------------------------------------------
integer proc BigIsEven(string nS)
    integer lastDigitI
    //
    lastDigitI = Asc(SubStr(nS, Length(nS), 1)) - Asc("0")
    return( (lastDigitI mod 2) == 0 )
end

// ---------------------------------------------------------------------------
// BigDivBy2: divide decimal string by 2, return quotient string
// ---------------------------------------------------------------------------
string proc BigDivBy2(string nS)
    string qS[255]
    string digitS[4]
    integer nLenI, idxI, digitI, curI, remI
    //
    qS     = ""
    digitS = ""
    nLenI  = Length(nS)
    remI   = 0
    //
    for idxI = 1 to nLenI
        digitI = Asc(SubStr(nS, idxI, 1)) - Asc("0")
        curI   = remI * 10 + digitI
        digitS = Chr((curI / 2) + Asc("0"))
        qS     = qS + digitS
        remI   = curI mod 2
    endfor
    //
    while Length(qS) > 1 AND SubStr(qS, 1, 1) == "0"
        qS = SubStr(qS, 2, Length(qS) - 1)
    endwhile
    if Length(qS) == 0
        qS = "0"
    endif
    return( qS )
end

// ---------------------------------------------------------------------------
// BigSubOne: subtract 1 from a positive decimal string (result >= 0)
// ---------------------------------------------------------------------------
string proc BigSubOne(string nS)
    string rS[255]
    integer lenI, idxI, digitI, doneI
    //
    rS    = nS
    lenI  = Length(rS)
    doneI = FALSE
    idxI  = lenI
    //
    while idxI >= 1 AND doneI == FALSE
        digitI = Asc(SubStr(rS, idxI, 1)) - Asc("0")
        if digitI > 0
            rS    = SubStr(rS, 1, idxI - 1)
                  + Chr(digitI - 1 + Asc("0"))
                  + SubStr(rS, idxI + 1, lenI - idxI)
            doneI = TRUE
        else
            rS   = SubStr(rS, 1, idxI - 1)
                 + "9"
                 + SubStr(rS, idxI + 1, lenI - idxI)
            idxI = idxI - 1
        endif
    endwhile
    //
    while Length(rS) > 1 AND SubStr(rS, 1, 1) == "0"
        rS = SubStr(rS, 2, Length(rS) - 1)
    endwhile
    return( rS )
end

// ---------------------------------------------------------------------------
// BigAdd: add two non-negative decimal strings, return result string
// ---------------------------------------------------------------------------
string proc BigAdd(string aS, string bS)
    string rS[255]
    string digitS[4]
    integer aI, bI, carryI, sumI, aLenI, bLenI
    //
    rS     = ""
    digitS = ""
    aLenI  = Length(aS)
    bLenI  = Length(bS)
    carryI = 0
    //
    while aLenI > 0 OR bLenI > 0 OR carryI > 0
        aI = 0
        bI = 0
        if aLenI > 0
            aI    = Asc(SubStr(aS, aLenI, 1)) - Asc("0")
            aLenI = aLenI - 1
        endif
        if bLenI > 0
            bI    = Asc(SubStr(bS, bLenI, 1)) - Asc("0")
            bLenI = bLenI - 1
        endif
        sumI   = aI + bI + carryI
        carryI = sumI / 10
        sumI   = sumI mod 10
        digitS = Chr(sumI + Asc("0"))
        rS     = digitS + rS
    endwhile
    //
    if Length(rS) == 0
        rS = "0"
    endif
    return( rS )
end

// ---------------------------------------------------------------------------
// MemoGet: look up keyS in gMemoBufI.  Returns "" if not found.
//          Line format: "key|value"
// ---------------------------------------------------------------------------
string proc MemoGet(string keyS)
    integer savedBufI, nLinesI, idxI, jI, sepPosI, foundI
    string  lineS[255], curKeyS[255], curValS[255]
    //
    savedBufI = GetBufferId()
    GotoBufferId(gMemoBufI)
    nLinesI   = NumLines()
    foundI    = FALSE
    curValS   = ""
    //
    for idxI = 1 to nLinesI
        GotoLine(idxI)
        lineS   = GetText(1, CurrLineLen())
        sepPosI = 0
        for jI = 1 to Length(lineS)
            if SubStr(lineS, jI, 1) == "|"
                sepPosI = jI
            endif
        endfor
        if sepPosI > 0
            curKeyS = SubStr(lineS, 1, sepPosI - 1)
            if curKeyS == keyS
                curValS = SubStr(lineS, sepPosI + 1, Length(lineS) - sepPosI)
                foundI  = TRUE
            endif
        endif
    endfor
    //
    GotoBufferId(savedBufI)
    if foundI == TRUE
        return( curValS )
    endif
    return( "" )
end

// ---------------------------------------------------------------------------
// MemoSet: store keyS -> valS in gMemoBufI
// ---------------------------------------------------------------------------
proc MemoSet(string keyS, string valS)
    integer savedBufI
    string  entryS[255]
    //
    savedBufI = GetBufferId()
    GotoBufferId(gMemoBufI)
    entryS    = keyS + "|" + valS
    EndFile()
    AddLine(entryS)
    GotoBufferId(savedBufI)
end

// ---------------------------------------------------------------------------
// StackPush: push a decimal string onto gStackBufI
// ---------------------------------------------------------------------------
proc StackPush(string nS)
    integer savedBufI
    //
    savedBufI = GetBufferId()
    GotoBufferId(gStackBufI)
    EndFile()
    AddLine(nS)
    GotoBufferId(savedBufI)
end

// ---------------------------------------------------------------------------
// StackPop: remove top (last) line from gStackBufI
// ---------------------------------------------------------------------------
proc StackPop()
    integer savedBufI, nLinesI
    //
    savedBufI = GetBufferId()
    GotoBufferId(gStackBufI)
    nLinesI   = NumLines()
    if nLinesI > 0
        GotoLine(nLinesI)
        BegLine()
        KillToEol()
        // Remove the now-empty line if there are multiple lines
        if nLinesI > 1
            DelLine()
        endif
    endif
    GotoBufferId(savedBufI)
end

// ---------------------------------------------------------------------------
// StackTop: return the top (last) line of gStackBufI, or "" if empty
// ---------------------------------------------------------------------------
string proc StackTop()
    integer savedBufI, nLinesI
    string  topS[255]
    //
    savedBufI = GetBufferId()
    GotoBufferId(gStackBufI)
    nLinesI   = NumLines()
    topS      = ""
    if nLinesI > 0
        GotoLine(nLinesI)
        topS = GetText(1, CurrLineLen())
    endif
    GotoBufferId(savedBufI)
    return( topS )
end

// ---------------------------------------------------------------------------
// StackSize: return number of entries in gStackBufI
// ---------------------------------------------------------------------------
integer proc StackSize()
    integer savedBufI, nI
    //
    savedBufI = GetBufferId()
    GotoBufferId(gStackBufI)
    nI = NumLines()
    // If only 1 line and it is empty the stack is empty
    if nI == 1
        GotoLine(1)
        if CurrLineLen() == 0
            nI = 0
        endif
    endif
    GotoBufferId(savedBufI)
    return( nI )
end

// ---------------------------------------------------------------------------
// ComputeF: iterative driver.
//   Pushes the root problem, then loops:
//     - peek top of stack
//     - if already in memo: pop and continue
//     - if n==0: store memo["0"]="1", pop
//     - if n odd: if child in memo use it, else push child
//     - if n even: if both children in memo compute sum, else push missing child
// ---------------------------------------------------------------------------
string proc ComputeF(string rootS)
    string nS[255]
    string c1S[255]
    string c2S[255]
    string v1S[255]
    string v2S[255]
    string memoS[255]
    //
    nS    = ""
    c1S   = ""
    c2S   = ""
    v1S   = ""
    v2S   = ""
    memoS = ""
    //
    StackPush(rootS)
    //
    while StackSize() > 0
        nS    = StackTop()
        memoS = MemoGet(nS)
        //
        if Length(memoS) > 0
            // Already computed - just pop
            StackPop()
        elseif BigIsZero(nS)
            // Base case
            MemoSet("0", "1")
            StackPop()
        elseif BigIsEven(nS) == FALSE
            // n is odd: need f((n-1)/2)
            c1S   = BigDivBy2(BigSubOne(nS))
            v1S   = MemoGet(c1S)
            if Length(v1S) > 0
                MemoSet(nS, v1S)
                StackPop()
            else
                StackPush(c1S)
            endif
        else
            // n is even: need f(n/2) and f(n/2-1)
            c1S = BigDivBy2(nS)
            c2S = BigSubOne(c1S)
            v1S = MemoGet(c1S)
            v2S = MemoGet(c2S)
            if Length(v1S) > 0 AND Length(v2S) > 0
                MemoSet(nS, BigAdd(v1S, v2S))
                StackPop()
            elseif Length(v1S) == 0
                StackPush(c1S)
            else
                StackPush(c2S)
            endif
        endif
    endwhile
    //
    return( MemoGet(rootS) )
end

// ---------------------------------------------------------------------------
// Main
// ---------------------------------------------------------------------------
proc Main()
    string  nS[255]      = ""
    string  resultS[255] = ""
    integer idxI
    //
    // Build 10^25 as decimal string: "1" followed by 25 zeros
    nS = "1"
    for idxI = 1 to 25
        nS = nS + "0"
    endfor
    //
    // Create working buffers
    gMemoBufI  = CreateTempBuffer()
    gStackBufI = CreateTempBuffer()
    //
    // Compute f(10^25) - fully iterative, no SAL recursion
    resultS = ComputeF(nS)
    //
    // Output
    CopyToWinClip(resultS)
    Warn("Project Euler 169 - f(10^25) = " + resultS)
    CopyToWinClip(resultS)
    //
    // Clean up
    AbandonFile(gMemoBufI)
    AbandonFile(gStackBufI)
end
