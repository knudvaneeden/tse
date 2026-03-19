// Euler Problem 116 - Red, Green or Blue Tiles
// A row of 50 grey tiles; replace some with coloured oblongs of
// length 2 (red), 3 (green), or 4 (blue). Colours cannot be mixed.
// Count total ways (at least one coloured tile must be used).
//
// Method: DP recurrence for tile size t, row length n:
//   f(0)=1,  f(k)=1 for 1<=k<t
//   f(n) = f(n-1) + f(n-t)   for n >= t
// Subtract 1 (all-grey) from each colour result, then sum the three.
//
// Big-integer arithmetic needed (values exceed 32-bit range).
// Big-integers are stored as plain decimal digit strings.
//
// Buffer layout for CountWays: line (k+1) holds f(k), k=0..rowLen.
// After EmptyBuffer() the buffer has one empty line (line 1).
// f(0) is written onto that existing line 1 via BegLine+KillToEol+InsertText.
// All subsequent f(k) are appended with EndFile+AddLine.
//
// <version>1.0.0.0.1</version>

// ---------------------------------------------------------------------------
// BigAdd: return string sum of two decimal strings a and b
// ---------------------------------------------------------------------------
string proc BigAdd(string a, string b)
    string  result[255]
    string  digitStr[4]
    integer carry
    integer da
    integer db
    integer nSum
    integer lenA
    integer lenB
    integer i

    carry  = 0
    result = ""
    lenA   = Length(a)
    lenB   = Length(b)
    i      = 0
    while i < lenA or i < lenB or carry
        if i < lenA
            da = Asc(SubStr(a, lenA - i, 1)) - Asc("0")
        else
            da = 0
        endif
        if i < lenB
            db = Asc(SubStr(b, lenB - i, 1)) - Asc("0")
        else
            db = 0
        endif
        nSum     = da + db + carry
        carry    = nSum / 10
        nSum     = nSum mod 10
        digitStr = Chr(nSum + Asc("0"))
        result   = digitStr + result
        i        = i + 1
    endwhile
    if Length(result) == 0
        result = "0"
    endif
    return(result)
end

// ---------------------------------------------------------------------------
// BigSubOne: subtract 1 from a positive big-integer string (value >= 1)
// Implements right-to-left borrow propagation.
// ---------------------------------------------------------------------------
string proc BigSubOne(string a)
    string  s[255]
    string  ch[4]
    integer lenS
    integer borrow
    integer nIdx
    integer digit

    s      = a
    lenS   = Length(s)
    borrow = 1
    nIdx   = lenS
    while nIdx >= 1 and borrow
        ch    = SubStr(s, nIdx, 1)
        digit = Asc(ch) - Asc("0") - borrow
        if digit < 0
            digit  = digit + 10
            borrow = 1
        else
            borrow = 0
        endif
        s    = SubStr(s, 1, nIdx - 1) + Chr(digit + Asc("0")) + SubStr(s, nIdx + 1, lenS - nIdx)
        nIdx = nIdx - 1
    endwhile
    // Strip leading zero (result is never zero for our inputs)
    while Length(s) > 1 and SubStr(s, 1, 1) == "0"
        s = SubStr(s, 2, Length(s) - 1)
    endwhile
    return(s)
end

// ---------------------------------------------------------------------------
// CountWays: DP for a single tile size tileSize, row of length rowLen.
// Returns f(rowLen) as a big-integer string (includes all-grey case).
//
// Buffer layout: line (k+1) holds f(k), for k = 0..rowLen.
// After EmptyBuffer() line 1 is empty; f(0) is placed there via
// BegLine+KillToEol+InsertText. Subsequent lines use EndFile+AddLine.
// ---------------------------------------------------------------------------
string proc CountWays(integer tileSize, integer rowLen)
    integer dpBuf
    integer k
    string  prev1[255]
    string  prevT[255]
    string  fk[255]

    dpBuf = CreateTempBuffer()
    if dpBuf == 0
        return("0")
    endif
    GotoBufferId(dpBuf)
    EmptyBuffer()

    // k=0: f(0) = 1 -- write onto the existing empty line 1
    BegLine()
    KillToEol()
    InsertText("1")

    // k=1..rowLen
    k = 1
    while k <= rowLen
        if k < tileSize
            // f(k) = 1
            EndFile()
            AddLine("1")
        else
            // f(k) = f(k-1) + f(k-tileSize)
            // f(k-1)        is on line k     (= k-1+1)
            // f(k-tileSize) is on line k-tileSize+1
            GotoLine(k)
            prev1 = GetText(1, CurrLineLen())
            GotoLine(k - tileSize + 1)
            prevT = GetText(1, CurrLineLen())
            fk    = BigAdd(prev1, prevT)
            EndFile()
            AddLine(fk)
        endif
        k = k + 1
    endwhile

    // f(rowLen) is on line (rowLen + 1)
    GotoLine(rowLen + 1)
    fk = GetText(1, CurrLineLen())
    AbandonFile(dpBuf)
    return(fk)
end

// ---------------------------------------------------------------------------
// Main
// ---------------------------------------------------------------------------
proc Main()
    integer ROW_LEN
    string  waysRed[255]
    string  waysGreen[255]
    string  waysBlue[255]
    string  totalRed[255]
    string  totalGreen[255]
    string  totalBlue[255]
    string  answer[255]
    string  msg[255]

    ROW_LEN = 50

    // Compute f(50) for each tile size (result includes all-grey arrangement)
    waysRed   = CountWays(2, ROW_LEN)
    waysGreen = CountWays(3, ROW_LEN)
    waysBlue  = CountWays(4, ROW_LEN)

    // Subtract 1 from each (remove the all-grey arrangement)
    totalRed   = BigSubOne(waysRed)
    totalGreen = BigSubOne(waysGreen)
    totalBlue  = BigSubOne(waysBlue)

    // Sum the three colour totals
    answer = BigAdd(BigAdd(totalRed, totalGreen), totalBlue)

    msg = "PE116 - Red/Green/Blue Tiles (row=50)" + Chr(13)
        + "Red   (size 2): " + totalRed   + Chr(13)
        + "Green (size 3): " + totalGreen + Chr(13)
        + "Blue  (size 4): " + totalBlue  + Chr(13)
        + Chr(13)
        + "Answer: " + answer

    CopyToWinClip(answer)
    Warn(msg)
end
