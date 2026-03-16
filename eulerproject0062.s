// Project Euler - Problem 62: Cubic Permutations        v1.9
// Find the smallest cube for which exactly five permutations
// of its digits are also cubes.
// Answer: 127035954683
//
// Key fix in v1.9 (logic bug, not arithmetic):
//   Previous versions stopped as soon as any fingerprint count hit 5.
//   But a fingerprint could accumulate a 6th+ permutation later within
//   the same digit-length group -- meaning "count==5 so far" is not the
//   same as "count==exactly 5".
//   Fix: process cubes in digit-length groups. When the digit count of
//   n^3 increases, scan the completed group for fingerprints with count==5
//   and report the smallest cube among those. If none found, clear the map
//   and continue with the next group.
//
// Arithmetic: incremental cube via
//   (n+1)^3 = n^3 + 3*n^2 + 3*n + 1
//   (n+1)^2 = n^2 + 2*n   + 1
// Map: two parallel buffers g_fpBuf / g_datBuf, manual line scan.

// ---------------------------------------------------------------------------
// Reverse a string
// ---------------------------------------------------------------------------
string proc StrRev(string s)
    string  r[255]
    integer i, n
    n = Length(s)
    r = ""
    i = n
    while i >= 1
        r = r + SubStr(s, i, 1)
        i = i - 1
    endwhile
    return( r )
end

// ---------------------------------------------------------------------------
// Decimal string arithmetic
// ---------------------------------------------------------------------------
integer proc _DA(string s, integer p)
    return( Val(SubStr(s, p, 1)) )
end

string proc BigAdd(string a, string b)
    string  res[255]
    integer la, lb, i, carry, da, db, sm
    la    = Length(a)
    lb    = Length(b)
    res   = ""
    carry = 0
    i     = 0
    while i < la or i < lb or carry
        da = 0
        db = 0
        if i < la
            da = _DA(a, la - i)
        endif
        if i < lb
            db = _DA(b, lb - i)
        endif
        sm    = da + db + carry
        carry = sm / 10
        res   = res + Chr(48 + (sm mod 10))
        i     = i + 1
    endwhile
    if Length(res) == 0
        res = "0"
    endif
    return( StrRev(res) )
end

string proc BigMulSmall(string a, integer m)
    string  res[255]
    integer la, i, carry, prod, dg
    if m == 0
        return( "0" )
    endif
    la    = Length(a)
    res   = ""
    carry = 0
    i     = 0
    while i < la or carry
        prod  = carry
        if i < la
            prod = prod + _DA(a, la - i) * m
        endif
        carry = prod / 10
        dg    = prod mod 10
        res   = res + Chr(48 + dg)
        i     = i + 1
    endwhile
    if Length(res) == 0
        res = "0"
    endif
    return( StrRev(res) )
end

// ---------------------------------------------------------------------------
// Sort digits ascending -- canonical permutation fingerprint
// ---------------------------------------------------------------------------
string proc SortDigits(string s)
    string  arr[255]
    string  tmp[1]
    integer n, i, j
    arr = s
    n   = Length(arr)
    i   = 2
    while i <= n
        j = i
        while j > 1 and Asc(SubStr(arr, j-1, 1)) > Asc(SubStr(arr, j, 1))
            tmp = SubStr(arr, j-1, 1)
            arr = SubStr(arr, 1, j-2) + SubStr(arr, j, 1) + tmp + SubStr(arr, j+1, 255)
            j   = j - 1
        endwhile
        i = i + 1
    endwhile
    return( arr )
end

// ---------------------------------------------------------------------------
// Two-buffer map: g_fpBuf lines = fingerprint
//                 g_datBuf lines = "count|smallestCube"
// ---------------------------------------------------------------------------
integer g_fpBuf  = 0
integer g_datBuf = 0

integer proc FindFP(string fp)
    integer saved, result, nLines, cur
    string  line[255]
    saved  = GetBufferId()
    GotoBufferId(g_fpBuf)
    nLines = NumLines()
    result = 0
    if nLines > 0
        BegFile()
        cur = 1
        while cur <= nLines
            line = GetText(1, CurrLineLen())
            if line == fp
                result = cur
                cur    = nLines + 1
            else
                Down()
                cur = cur + 1
            endif
        endwhile
    endif
    GotoBufferId(saved)
    return( result )
end

proc MapAdd(string fp, string cubeStr)
    integer saved
    saved = GetBufferId()
    GotoBufferId(g_fpBuf)
    EndFile()
    AddLine(fp)
    GotoBufferId(g_datBuf)
    EndFile()
    AddLine("1|" + cubeStr)
    GotoBufferId(saved)
end

proc MapIncr(integer ln)
    integer saved, cnt
    string  rec[255]
    string  sm[255]
    saved = GetBufferId()
    GotoBufferId(g_datBuf)
    GotoLine(ln)
    rec = GetText(1, CurrLineLen())
    cnt = Val(GetToken(rec, "|", 1)) + 1
    sm  = GetToken(rec, "|", 2)
    BegLine()
    KillToEol()
    InsertText(Str(cnt) + "|" + sm, _INSERT_)
    GotoBufferId(saved)
end

// Scan datBuf for lines with count==5; return smallest cube string or ""
string proc FindExactlyFive()
    integer saved, nLines, cur, cnt
    string  rec[255]
    string  best[255]
    string  sm[255]
    saved  = GetBufferId()
    GotoBufferId(g_datBuf)
    nLines = NumLines()
    best   = ""
    if nLines > 0
        BegFile()
        cur = 1
        while cur <= nLines
            rec = GetText(1, CurrLineLen())
            cnt = Val(GetToken(rec, "|", 1))
            if cnt == 5
                sm = GetToken(rec, "|", 2)
                // Keep the numerically smallest: shorter string = smaller,
                // same length = lexicographic compare is correct for decimals
                if Length(best) == 0
                    best = sm
                elseif Length(sm) < Length(best)
                    best = sm
                elseif Length(sm) == Length(best) and sm < best
                    best = sm
                endif
            endif
            Down()
            cur = cur + 1
        endwhile
    endif
    GotoBufferId(saved)
    return( best )
end

proc MapClear()
    integer saved
    saved = GetBufferId()
    GotoBufferId(g_fpBuf)
    EmptyBuffer()
    GotoBufferId(g_datBuf)
    EmptyBuffer()
    GotoBufferId(saved)
end

// ---------------------------------------------------------------------------
// Main
// ---------------------------------------------------------------------------
proc Main()
    string  nStr[255]
    string  sqStr[255]
    string  cubeStr[255]
    string  fp[255]
    string  answer[255]
    integer n, ln, curLen, prevLen

    g_fpBuf  = CreateTempBuffer()
    g_datBuf = CreateTempBuffer()

    n       = 1
    nStr    = "1"
    sqStr   = "1"
    cubeStr = "1"
    answer  = ""
    prevLen = 1

    while not Length(answer)
        curLen = Length(cubeStr)

        // When digit length increases, the previous group is complete --
        // check it for exactly-5 entries, then clear and start fresh.
        if curLen > prevLen
            answer  = FindExactlyFive()
            prevLen = curLen
            if not Length(answer)
                MapClear()
            endif
        endif

        if not Length(answer)
            fp = SortDigits(cubeStr)
            ln = FindFP(fp)
            if ln == 0
                MapAdd(fp, cubeStr)
            else
                MapIncr(ln)
            endif

            // Advance n -> n+1
            cubeStr = BigAdd(cubeStr,
                        BigAdd(BigMulSmall(sqStr, 3),
                               BigAdd(BigMulSmall(nStr, 3), "1")))
            sqStr   = BigAdd(sqStr, BigAdd(BigMulSmall(nStr, 2), "1"))
            n       = n + 1
            nStr    = Str(n)
        endif
    endwhile

    AbandonFile(g_fpBuf)
    AbandonFile(g_datBuf)

    CopyToWinClip(answer)
    Warn("Project Euler #62 - Cubic Permutations" + Chr(13) +
         "Smallest cube with 5 cube-permutations:" + Chr(13) +
         answer + Chr(13) +
         "(copied to clipboard)")
end
