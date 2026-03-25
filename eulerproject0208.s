/*
 * Project Euler - Problem 208: Robot Walks
 *
 * A robot makes 70 arcs of 72 degrees each (CW or CCW).
 * How many closed paths of 70 arcs return it to start?
 *
 * State: (dir, a[0..4]) where:
 *   CW from dir d  -> a[d] += 1, new_dir = (d+1) mod 5
 *   CCW from dir d -> a[(d+1) mod 5] += 1, new_dir = (d+4) mod 5
 * Closure: dir=0, all a[k]=14 (=70/5).
 * Each a[k] in 0..14. State count peaks ~29K states at step 40.
 * Big-integer values (answer ~3.3e17).
 * Two temp buffers; sort+merge each step.
 *
 * <version>1.0.0.0.2</version>
 * Created by: Claude (Anthropic)
 *
 * History:
 *   1.0.0.0.1 - Initial draft by Claude (Anthropic)
 *   1.0.0.0.2 - Corrected closure condition by Claude (Anthropic)
 */

// ---- Big Integer Addition (unsigned decimal strings) ----
string proc BigAdd(string aS, string bS)
    string resS[80]
    string padAS[64]
    string padBS[64]
    integer aLenI
    integer bLenI
    integer mLenI
    integer iI
    integer carryI
    integer dA
    integer dB
    integer sumI
    //
    resS   = ""
    aLenI  = Length(aS)
    bLenI  = Length(bS)
    mLenI  = aLenI
    if bLenI > mLenI
        mLenI = bLenI
    endif
    padAS = aS
    padBS = bS
    while Length(padAS) < mLenI
        padAS = "0" + padAS
    endwhile
    while Length(padBS) < mLenI
        padBS = "0" + padBS
    endwhile
    carryI = 0
    iI = mLenI
    while iI >= 1
        dA    = Asc(SubStr(padAS, iI, 1)) - 48
        dB    = Asc(SubStr(padBS, iI, 1)) - 48
        sumI  = dA + dB + carryI
        carryI = sumI / 10
        sumI  = sumI mod 10
        resS  = Chr(sumI + 48) + resS
        iI    = iI - 1
    endwhile
    if carryI > 0
        resS = Chr(carryI + 48) + resS
    endif
    return( resS )
end

// ---- Encode state to 11-char key ----
// Format: d(1) a0(2) a1(2) a2(2) a3(2) a4(2)  = 11 chars
string proc EncodeKey(integer dirI, integer a0I, integer a1I, integer a2I, integer a3I, integer a4I)
    string kS[16]
    kS = Chr(dirI + 48)
    kS = kS + Format(a0I:2:"0")
    kS = kS + Format(a1I:2:"0")
    kS = kS + Format(a2I:2:"0")
    kS = kS + Format(a3I:2:"0")
    kS = kS + Format(a4I:2:"0")
    return( kS )
end

// ---- Decode direction from key ----
integer proc DecodeDir(string kS)
    return( Asc(SubStr(kS, 1, 1)) - 48 )
end

// ---- Decode a[idxI] from key (idxI = 0..4) ----
integer proc DecodeA(string kS, integer idxI)
    integer posI
    posI = 2 + idxI * 2
    return( Val(SubStr(kS, posI, 2)) )
end

// ---- Merge-sum duplicate keys in sorted buffer ----
// Each line: "KKKKKKKKKKK VVV..."  (11-char key, space, big-int value)
proc MergeDuplicates(integer bufI)
    integer nLinesI
    integer iI
    integer writeLineI
    string  curLineS[255]
    string  prevKeyS[16]
    string  curKeyS[16]
    string  curValS[64]
    string  accValS[64]
    //
    GotoBufferId(bufI)
    nLinesI = NumLines()
    if nLinesI <= 1
        return()
    endif
    GotoLine(1)
    BegLine()
    curLineS = GetText(1, CurrLineLen())
    prevKeyS = SubStr(curLineS, 1, 11)
    accValS  = SubStr(curLineS, 13, 255)
    writeLineI = 1
    iI = 2
    while iI <= nLinesI
        GotoLine(iI)
        BegLine()
        curLineS = GetText(1, CurrLineLen())
        curKeyS  = SubStr(curLineS, 1, 11)
        curValS  = SubStr(curLineS, 13, 255)
        if curKeyS == prevKeyS
            accValS = BigAdd(accValS, curValS)
        else
            GotoLine(writeLineI)
            BegLine()
            KillToEol()
            InsertText(prevKeyS + " " + accValS)
            writeLineI = writeLineI + 1
            prevKeyS = curKeyS
            accValS  = curValS
        endif
        iI = iI + 1
    endwhile
    GotoLine(writeLineI)
    BegLine()
    KillToEol()
    InsertText(prevKeyS + " " + accValS)
    writeLineI = writeLineI + 1
    nLinesI = NumLines()
    while nLinesI >= writeLineI
        GotoLine(nLinesI)
        DelLine()
        nLinesI = nLinesI - 1
    endwhile
end

proc Main()
    integer curBufI
    integer nxtBufI
    integer stepI
    integer nLinesI
    integer lineI
    integer dirI
    integer a0I
    integer a1I
    integer a2I
    integer a3I
    integer a4I
    integer ndI
    integer na0
    integer na1
    integer na2
    integer na3
    integer na4
    integer targetAI
    string  lineS[255]
    string  keyS[16]
    string  valS[64]
    string  nKeyS[16]
    string  goalKeyS[16]
    string  ansS[64]
    //
    targetAI = 14
    curBufI = CreateTempBuffer()
    nxtBufI = CreateTempBuffer()
    //
    GotoBufferId(curBufI)
    AddLine(EncodeKey(0, 0, 0, 0, 0, 0) + " 1")
    //
    stepI = 1
    while stepI <= 70
        GotoBufferId(nxtBufI)
        EmptyBuffer()
        //
        GotoBufferId(curBufI)
        nLinesI = NumLines()
        lineI = 1
        while lineI <= nLinesI
            GotoLine(lineI)
            BegLine()
            lineS = GetText(1, CurrLineLen())
            keyS  = SubStr(lineS, 1, 11)
            valS  = SubStr(lineS, 13, 255)
            dirI  = DecodeDir(keyS)
            a0I   = DecodeA(keyS, 0)
            a1I   = DecodeA(keyS, 1)
            a2I   = DecodeA(keyS, 2)
            a3I   = DecodeA(keyS, 3)
            a4I   = DecodeA(keyS, 4)
            //
            // CW: a[dirI] += 1, new_dir = (dirI+1) mod 5
            ndI = (dirI + 1) mod 5
            na0 = a0I
            na1 = a1I
            na2 = a2I
            na3 = a3I
            na4 = a4I
            case dirI
                when 0
                    na0 = a0I + 1
                when 1
                    na1 = a1I + 1
                when 2
                    na2 = a2I + 1
                when 3
                    na3 = a3I + 1
                when 4
                    na4 = a4I + 1
            endcase
            if na0 <= targetAI and na1 <= targetAI and na2 <= targetAI and na3 <= targetAI and na4 <= targetAI
                nKeyS = EncodeKey(ndI, na0, na1, na2, na3, na4)
                GotoBufferId(nxtBufI)
                AddLine(nKeyS + " " + valS)
                GotoBufferId(curBufI)
            endif
            //
            // CCW: a[(dirI+1) mod 5] += 1, new_dir = (dirI+4) mod 5
            ndI = (dirI + 4) mod 5
            na0 = a0I
            na1 = a1I
            na2 = a2I
            na3 = a3I
            na4 = a4I
            case dirI
                when 0
                    na1 = a1I + 1
                when 1
                    na2 = a2I + 1
                when 2
                    na3 = a3I + 1
                when 3
                    na4 = a4I + 1
                when 4
                    na0 = a0I + 1
            endcase
            if na0 <= targetAI and na1 <= targetAI and na2 <= targetAI and na3 <= targetAI and na4 <= targetAI
                nKeyS = EncodeKey(ndI, na0, na1, na2, na3, na4)
                GotoBufferId(nxtBufI)
                AddLine(nKeyS + " " + valS)
                GotoBufferId(curBufI)
            endif
            //
            lineI = lineI + 1
        endwhile
        //
        // Sort next buffer and merge duplicate keys
        GotoBufferId(nxtBufI)
        BegFile()
        MarkLine()
        EndFile()
        MarkLine()
        ExecMacro("sort")
        UnMarkBlock()
        MergeDuplicates(nxtBufI)
        //
        // Copy nxtBuf -> curBuf
        GotoBufferId(curBufI)
        EmptyBuffer()
        GotoBufferId(nxtBufI)
        nLinesI = NumLines()
        lineI = 1
        while lineI <= nLinesI
            GotoLine(lineI)
            BegLine()
            lineS = GetText(1, CurrLineLen())
            GotoBufferId(curBufI)
            AddLine(lineS)
            GotoBufferId(nxtBufI)
            lineI = lineI + 1
        endwhile
        //
        stepI = stepI + 1
    endwhile
    //
    // Look up answer: dir=0, all a[k]=14
    ansS     = "0"
    goalKeyS = EncodeKey(0, 14, 14, 14, 14, 14)
    GotoBufferId(curBufI)
    nLinesI = NumLines()
    lineI = 1
    while lineI <= nLinesI
        GotoLine(lineI)
        BegLine()
        lineS = GetText(1, CurrLineLen())
        keyS  = SubStr(lineS, 1, 11)
        if keyS == goalKeyS
            ansS = SubStr(lineS, 13, 255)
        endif
        lineI = lineI + 1
    endwhile
    //
    CopyToWinClip(ansS)
    Warn("P208 Robot Walks" + Chr(13) + "Answer: " + ansS)
    CopyToWinClip(ansS)
end
