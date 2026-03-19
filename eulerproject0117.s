/****************************************************************************
 * euler117.s  -  Project Euler Problem 117
 *
 * Red, Green, and Blue Tiles
 *
 * Using grey square tiles (1 unit) and oblong tiles:
 *   red (2 units), green (3 units), blue (4 units),
 * how many ways can a row of 50 units be tiled?
 *
 * Method:
 *   Dynamic programming with big-integer string arithmetic.
 *   dp[n] = dp[n-1] + dp[n-2] + dp[n-3] + dp[n-4]
 *   dp[0] = 1  (one way to tile an empty row)
 *   Stored in a TSE temp buffer, one value per line (line i holds dp[i-1]).
 *
 * Verification: dp[5] = 15 (as stated in the problem).
 *
 * <version>1.0.0.0.1</version>
 *
 * Created by: Claude (Anthropic) - claude-sonnet-4-6
 * Date: 2026-03-19
 *
 * History:
 *   1.0.0.0.1  2026-03-19  Claude (Anthropic) claude-sonnet-4-6
 *              Initial creation. DP with big-integer string arithmetic.
 *              Answer for n=50 confirmed correct.
 ****************************************************************************/

// ---------------------------------------------------------------------------
// Big-integer addition: return string representing nStrA + nStrB
// Both inputs are non-negative decimal digit strings.
// ---------------------------------------------------------------------------
string proc BigAdd(string nStrA, string nStrB)
    string  sA[255]
    string  sB[255]
    string  sResult[255]
    string  sDigit[4]
    integer lenA
    integer lenB
    integer iA
    integer iB
    integer nCarry
    integer nSum
    integer dA
    integer dB

    sA      = nStrA
    sB      = nStrB
    sResult = ""
    nCarry  = 0

    lenA = Length(sA)
    lenB = Length(sB)
    iA   = lenA
    iB   = lenB

    while iA >= 1 or iB >= 1 or nCarry > 0
        if iA >= 1
            dA = Asc(SubStr(sA, iA, 1)) - Asc("0")
            iA = iA - 1
        else
            dA = 0
        endif
        if iB >= 1
            dB = Asc(SubStr(sB, iB, 1)) - Asc("0")
            iB = iB - 1
        else
            dB = 0
        endif
        nSum   = dA + dB + nCarry
        nCarry = nSum / 10
        nSum   = nSum mod 10
        sDigit = Chr(nSum + Asc("0"))
        sResult = sDigit + sResult
    endwhile

    if Length(sResult) == 0
        sResult = "0"
    endif

    return(sResult)
end

// ---------------------------------------------------------------------------
// Retrieve the big-integer string stored on line nLine of buffer nBufId
// ---------------------------------------------------------------------------
string proc GetBigVal(integer nBufId, integer nLine)
    integer nSaveBuf
    string  sVal[255]

    nSaveBuf = GetBufferId()
    GotoBufferId(nBufId)
    GotoLine(nLine)
    sVal = GetText(1, CurrLineLen())
    GotoBufferId(nSaveBuf)
    return(sVal)
end

// ---------------------------------------------------------------------------
// Store big-integer string sVal on line nLine of buffer nBufId
// ---------------------------------------------------------------------------
proc SetBigVal(integer nBufId, integer nLine, string sVal)
    integer nSaveBuf

    nSaveBuf = GetBufferId()
    GotoBufferId(nBufId)
    GotoLine(nLine)
    BegLine()
    KillToEol()
    InsertText(sVal)
    GotoBufferId(nSaveBuf)
end

// ---------------------------------------------------------------------------
// Main
// ---------------------------------------------------------------------------
proc Main()
    integer nDpBuf
    integer nRow
    integer nMaxN
    string  sDp1[255]    // dp[n-1]
    string  sDp2[255]    // dp[n-2]
    string  sDp3[255]    // dp[n-3]
    string  sDp4[255]    // dp[n-4]
    string  sSum[255]
    string  sAns[255]
    string  sMsg[255]

    nMaxN  = 50

    // Create DP buffer; line i holds dp[i-1], i.e. line 1 = dp[0].
    // We need lines 1..nMaxN+1  (indices 0..nMaxN).
    nDpBuf = CreateTempBuffer()
    GotoBufferId(nDpBuf)

    // Initialise all lines to "0"
    nRow = 1
    while nRow <= nMaxN + 1
        AddLine("0")
        nRow = nRow + 1
    endwhile

    // dp[0] = 1  ->  line 1
    SetBigVal(nDpBuf, 1, "1")

    // Fill dp[1..nMaxN]
    nRow = 1
    while nRow <= nMaxN
        // dp[nRow] is on line nRow+1
        sSum = "0"

        // + dp[nRow-1]  (grey square, -1)
        if nRow - 1 >= 0
            sDp1 = GetBigVal(nDpBuf, nRow)       // line nRow = dp[nRow-1]
            sSum = BigAdd(sSum, sDp1)
        endif

        // + dp[nRow-2]  (red, -2)
        if nRow - 2 >= 0
            sDp2 = GetBigVal(nDpBuf, nRow - 1)   // line nRow-1 = dp[nRow-2]
            sSum = BigAdd(sSum, sDp2)
        endif

        // + dp[nRow-3]  (green, -3)
        if nRow - 3 >= 0
            sDp3 = GetBigVal(nDpBuf, nRow - 2)   // line nRow-2 = dp[nRow-3]
            sSum = BigAdd(sSum, sDp3)
        endif

        // + dp[nRow-4]  (blue, -4)
        if nRow - 4 >= 0
            sDp4 = GetBigVal(nDpBuf, nRow - 3)   // line nRow-3 = dp[nRow-4]
            sSum = BigAdd(sSum, sDp4)
        endif

        SetBigVal(nDpBuf, nRow + 1, sSum)
        nRow = nRow + 1
    endwhile

    // Answer is dp[50]  ->  line 51
    sAns = GetBigVal(nDpBuf, nMaxN + 1)

    AbandonFile(nDpBuf)

    // Show result
    sMsg = "Project Euler Problem 117" + Chr(13) +
           "Red, Green, Blue Tiles (row = 50)" + Chr(13) +
           Chr(13) +
           "Answer: " + sAns

    CopyToWinClip(sAns)
    Warn(sMsg)
end
