// ============================================================
// eulerproject0174PerplexityComputer.s
//
// Project Euler - Problem 174
// "Hollow Square Laminae II"
//
// Square lamina: outer side o, inner hole side i,
// o > i >= 1, o and i same parity (so border = (o-i)/2 >= 1).
// t = o^2 - i^2. Count laminae per t <= 1,000,000.
// t is type L(n) if exactly n laminae produce it.
// Answer = Sum of N(n) for n = 1..10
//
// Key insight: same parity of o and i means a=o-i and b=o+i
// are BOTH EVEN. So we sieve a=2,4,6,... b=a+2,a+4,...
//
// Version  : 1.2
// Author   : Perplexity AI (powered by Claude Sonnet 4.6)
// Date     : 2026-03-23
//
// History:
//   1.0  2026-03-22  Perplexity AI  Initial version
//   1.1  2026-03-23  Perplexity AI  Removed CONSTANT and
//                                   INTEGER arrays; buffer sieve
//   1.2  2026-03-23  Perplexity AI  Fixed parity: a and b must
//                                   both be even (not just same
//                                   parity). N(15)=832 confirmed.
// ============================================================

STRING PROC IntToStr(INTEGER n)
    STRING s[20] = ""
    INTEGER neg = FALSE
    INTEGER digit = 0
    IF n < 0
        neg = TRUE
        n = -n
    ENDIF
    IF n == 0
        RETURN("0")
    ENDIF
    WHILE n > 0
        digit = n MOD 10
        s = Chr(digit + Asc("0")) + s
        n = n / 10
    ENDWHILE
    IF neg
        s = "-" + s
    ENDIF
    RETURN(s)
END

PROC Main()
    INTEGER LIMIT   = 1000000
    INTEGER aVal    = 0
    INTEGER bVal    = 0
    INTEGER tVal    = 0
    INTEGER lineNr  = 0
    INTEGER curCnt  = 0
    INTEGER nVal    = 0
    INTEGER answer  = 0
    INTEGER Ncnt1   = 0
    INTEGER Ncnt2   = 0
    INTEGER Ncnt3   = 0
    INTEGER Ncnt4   = 0
    INTEGER Ncnt5   = 0
    INTEGER Ncnt6   = 0
    INTEGER Ncnt7   = 0
    INTEGER Ncnt8   = 0
    INTEGER Ncnt9   = 0
    INTEGER Ncnt10  = 0
    STRING  sAnswer[20] = ""
    INTEGER bufId   = 0

    // Create scratch buffer with LIMIT lines, each "0"
    bufId = CreateTempBuffer()
    GotoBufferId(bufId)

    tVal = 0
    WHILE tVal < LIMIT
        AddLine("0")
        tVal = tVal + 1
    ENDWHILE

    // Sieve: a even from 2, b even from a+2 step 2
    // while a*b <= LIMIT
    // Both a and b even ensures o=(a+b)/2 and i=(b-a)/2 are integers
    // with o and i having the same parity (both integers, border >= 1)
    aVal = 2
    WHILE aVal * (aVal + 2) <= LIMIT
        bVal = aVal + 2
        WHILE TRUE
            tVal = aVal * bVal
            IF tVal > LIMIT
                BREAK
            ENDIF
            GotoLine(tVal)
            curCnt = Val(GetText(1, CurrLineLen()))
            BegLine()
            DelLine()
            InsertLine(IntToStr(curCnt + 1))
            bVal = bVal + 2
        ENDWHILE
        aVal = aVal + 2
    ENDWHILE

    // Scan all lines, accumulate N(1)..N(10)
    BegFile()
    lineNr = 1
    WHILE lineNr <= LIMIT
        nVal = Val(GetText(1, CurrLineLen()))
        CASE nVal
            WHEN 1   Ncnt1  = Ncnt1  + 1
            WHEN 2   Ncnt2  = Ncnt2  + 1
            WHEN 3   Ncnt3  = Ncnt3  + 1
            WHEN 4   Ncnt4  = Ncnt4  + 1
            WHEN 5   Ncnt5  = Ncnt5  + 1
            WHEN 6   Ncnt6  = Ncnt6  + 1
            WHEN 7   Ncnt7  = Ncnt7  + 1
            WHEN 8   Ncnt8  = Ncnt8  + 1
            WHEN 9   Ncnt9  = Ncnt9  + 1
            WHEN 10  Ncnt10 = Ncnt10 + 1
        ENDCASE
        Down()
        lineNr = lineNr + 1
    ENDWHILE

    answer = Ncnt1 + Ncnt2 + Ncnt3 + Ncnt4 + Ncnt5
           + Ncnt6 + Ncnt7 + Ncnt8 + Ncnt9 + Ncnt10

    AbandonFile(bufId)

    sAnswer = IntToStr(answer)

    CopyToWinClip(sAnswer)

    Warn("Project Euler Problem 174 - Answer: " + sAnswer)

    CopyToWinClip(sAnswer)

END

