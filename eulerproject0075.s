// ===========================================================================
// euler075.s  -  Project Euler Problem 75
// ---------------------------------------------------------------------------
// Problem:
//   It turns out that 12 cm is the smallest length of wire that can be bent
//   to form an integer sided right angle triangle in exactly one way, but
//   there are many more examples:
//     12 cm: (3,4,5)    24 cm: (6,8,10)   30 cm: (5,12,13)
//     36 cm: (9,12,15)  40 cm: (8,15,17)  48 cm: (12,16,20)
//   In contrast, some lengths like 20 cm cannot form a triangle at all,
//   and some lengths allow more than one solution:
//     120 cm: (30,40,50), (20,48,52), (24,45,51)   [three solutions]
//   For how many values of L <= 1,500,000 can exactly ONE integer-sided
//   right angle triangle be formed?
//
// Algorithm:
//   Euclid's formula generates every primitive Pythagorean triple:
//       a = mValue^2 - nValue^2
//       b = 2 * mValue * nValue
//       c = mValue^2 + nValue^2
//   with mValue > nValue > 0, gcd(mValue,nValue) = 1, (mValue+nValue) odd.
//   Primitive perimeter = a + b + c = 2 * mValue * (mValue + nValue).
//   Non-primitive triples are multiples kValue * (a,b,c).
//
//   A dedicated hidden buffer (iHitsBufferID) acts as a virtual array:
//     Line (iPerimeterIndex + 1) holds the integer count hits[iPerimeterIndex].
//   Read:  GotoLine(iPerimeterIndex + 1)  =>  Val(GetText(1, 10))
//   Write: GotoLine(iPerimeterIndex + 1)  =>  BegLine() KillToEol()
//                                              InsertText(Str(iNewValue))
//
//   The answer is the count of indices where the stored value equals 1.
//
// Verified:
//   Brute force for L <= 1000  =>  112  (matches Euclid sieve)
//   Python sieve for L <= 1,500,000  =>  161667
//
// Expected answer: 161667
//
// TSE SAL constraints:
//   - No integer arrays  (SAL does not support them)
//   - All strings <= 255 characters
//   - No floating-point arithmetic
//   - All integers 32-bit signed
//   - No reserved keywords used as variable names
//     (Reserved: and, break, by, case, constant, datadef, downto, end,
//      enddo, endif, endloop, endwhile, for, forward, if, iif, include,
//      integer, loop, Main, mod, not, or, proc, public, repeat, return,
//      string, to, until, var, while)
// ===========================================================================

constant iMaxWireLength = 1500000   // upper limit on wire length L

// ---------------------------------------------------------------------------
// FNIntegerGetGcd(iValueA, iValueB)
//   Returns the GCD of iValueA and iValueB via iterative Euclidean algorithm.
// ---------------------------------------------------------------------------
integer proc FNIntegerGetGcd(integer iValueA, integer iValueB)
    integer iTemp
    while iValueB <> 0
        iTemp   = iValueB
        iValueB = iValueA mod iValueB
        iValueA = iTemp
    endwhile
    return (iValueA)
end

// ---------------------------------------------------------------------------
// FNIntegerGetHitsBufferRead(iHitsBufferID, iPerimeterIndex)
//   Reads the integer stored at line (iPerimeterIndex + 1) of iHitsBufferID.
// ---------------------------------------------------------------------------
integer proc FNIntegerGetHitsBufferRead(integer iHitsBufferID, integer iPerimeterIndex)
    integer iSavedBufferID
    integer iStoredValue
    iSavedBufferID = GetBufferID()
    GotoBufferID(iHitsBufferID)
    GotoLine(iPerimeterIndex + 1)
    iStoredValue = Val(GetText(1, 10))
    GotoBufferID(iSavedBufferID)
    return (iStoredValue)
end

// ---------------------------------------------------------------------------
// PROCHitsBufferWrite(iHitsBufferID, iPerimeterIndex, iNewValue)
//   Writes iNewValue to line (iPerimeterIndex + 1) of iHitsBufferID.
// ---------------------------------------------------------------------------
proc PROCHitsBufferWrite(integer iHitsBufferID, integer iPerimeterIndex, integer iNewValue)
    integer iSavedBufferID
    iSavedBufferID = GetBufferID()
    GotoBufferID(iHitsBufferID)
    GotoLine(iPerimeterIndex + 1)
    BegLine()
    KillToEol()
    InsertText(Str(iNewValue))
    GotoBufferID(iSavedBufferID)
end

// ---------------------------------------------------------------------------
// PROCHitsBufferIncrement(iHitsBufferID, iPerimeterIndex)
//   Increments the value at line (iPerimeterIndex + 1) by 1.
// ---------------------------------------------------------------------------
proc PROCHitsBufferIncrement(integer iHitsBufferID, integer iPerimeterIndex)
    PROCHitsBufferWrite(iHitsBufferID, iPerimeterIndex,
        FNIntegerGetHitsBufferRead(iHitsBufferID, iPerimeterIndex) + 1)
end

// ---------------------------------------------------------------------------
// Main
// ---------------------------------------------------------------------------
proc Main()
    integer iHitsBufferID       // buffer used as virtual array for hit counts
    integer iResultBufferID     // buffer for final output text
    integer iOuterM             // outer loop variable (Euclid parameter m)
    integer iInnerN             // inner loop variable (Euclid parameter n)
    integer iPrimitivePerimeter // perimeter of the primitive triple
    integer iMultiple           // multiplier for non-primitive triples
    integer iTotalAnswer        // final count of perimeters with exactly 1 triple
    integer iGcdValue           // gcd(iOuterM, iInnerN)
    string  sResultLine[80]     // one line of result text (max 255)

    // ------------------------------------------------------------------
    // Step 1: Create the hits buffer.
    //   Pre-populate lines 1 .. (iMaxWireLength + 1), each holding "0".
    //   Line (iPerimeterIndex + 1) will store hits[iPerimeterIndex].
    // ------------------------------------------------------------------
    iHitsBufferID = CreateTempBuffer()
    GotoBufferID(iHitsBufferID)
    BegFile()
    iMultiple = 0
    while iMultiple <= iMaxWireLength
        AddLine("0")
        iMultiple = iMultiple + 1
    endwhile

    // ------------------------------------------------------------------
    // Step 2: Sieve via Euclid's formula.
    //   Outer loop: iOuterM from 2 while 2*iOuterM*(iOuterM+1) <= iMaxWireLength.
    //   Inner loop: iInnerN from 1 to iOuterM - 1.
    //     Require (iOuterM + iInnerN) odd and gcd = 1.
    //     Break inner loop early when iPrimitivePerimeter > iMaxWireLength.
    //   For each valid primitive (iOuterM, iInnerN), increment
    //     hits[iMultiple * iPrimitivePerimeter] for iMultiple = 1, 2, ...
    // ------------------------------------------------------------------
    iOuterM = 2
    while (2 * iOuterM * (iOuterM + 1)) <= iMaxWireLength
        iInnerN = 1
        while iInnerN < iOuterM
            if ((iOuterM + iInnerN) mod 2) == 1
                iGcdValue = FNIntegerGetGcd(iOuterM, iInnerN)
                if iGcdValue == 1
                    iPrimitivePerimeter = 2 * iOuterM * (iOuterM + iInnerN)
                    if iPrimitivePerimeter > iMaxWireLength
                        iInnerN = iOuterM       // break inner loop
                    else
                        iMultiple = 1
                        while (iMultiple * iPrimitivePerimeter) <= iMaxWireLength
                            PROCHitsBufferIncrement(iHitsBufferID,
                                iMultiple * iPrimitivePerimeter)
                            iMultiple = iMultiple + 1
                        endwhile
                    endif
                endif
            endif
            iInnerN = iInnerN + 1
        endwhile
        iOuterM = iOuterM + 1
    endwhile

    // ------------------------------------------------------------------
    // Step 3: Count perimeters with exactly one solution.
    // ------------------------------------------------------------------
    iTotalAnswer = 0
    iMultiple = 1
    while iMultiple <= iMaxWireLength
        if FNIntegerGetHitsBufferRead(iHitsBufferID, iMultiple) == 1
            iTotalAnswer = iTotalAnswer + 1
        endif
        iMultiple = iMultiple + 1
    endwhile

    // ------------------------------------------------------------------
    // Step 4: Write result to a new buffer and display via Message().
    // ------------------------------------------------------------------
    iResultBufferID = CreateTempBuffer()
    GotoBufferID(iResultBufferID)
    BegFile()
    AddLine("Project Euler Problem 75 - Singular Integer Right Triangles")
    AddLine("------------------------------------------------------------")
    AddLine("Given : L <= 1,500,000")
    AddLine("Find  : how many values of L allow exactly ONE integer-sided")
    AddLine("        right angle triangle?")
    AddLine("")
    sResultLine = "Answer: " + Str(iTotalAnswer)
    AddLine(sResultLine)
    AddLine("")
    AddLine("Method : Euclid's formula for primitive Pythagorean triples")
    AddLine("  a = mValue^2 - nValue^2")
    AddLine("  b = 2 * mValue * nValue")
    AddLine("  c = mValue^2 + nValue^2")
    AddLine("  Conditions: mValue > nValue, gcd = 1, (mValue + nValue) odd")
    AddLine("  Primitive perimeter = 2 * mValue * (mValue + nValue)")
    AddLine("  Increment hits[kValue * perimeter] for all valid kValue")
    AddLine("  Count L where hits[L] == 1")
    AddLine("")
    AddLine("Storage: buffer-as-array (SAL has no integer arrays)")
    AddLine("  Line (L+1) in iHitsBufferID stores the integer hits[L]")

    AbandonFile(iHitsBufferID)

    sResultLine = "Euler 075  Answer: " + Str(iTotalAnswer)
    Message(sResultLine)
end
