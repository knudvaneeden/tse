/*
 * Project Euler - Problem 54: Poker Hands
 *
 * The file c:\temp\p054_poker.txt contains 1000 two-player poker hands.
 * Each line: 10 space-separated cards; first 5 = Player 1, last 5 = Player 2.
 * How many hands does Player 1 win?
 *
 * Answer: 376
 *
 * Card notation: 2-9, T=10, J=11, Q=12, K=13, A=14; suit H/C/D/S
 *
 * Hand ranks (0=lowest):
 *   0=High Card, 1=One Pair, 2=Two Pairs, 3=Three of a Kind,
 *   4=Straight, 5=Flush, 6=Full House, 7=Four of a Kind,
 *   8=Straight/Royal Flush
 *
 * Scoring: each hand -> "rank tb1 tb2 ..." string.
 * Tiebreakers: card values by (frequency desc, value desc).
 * Compare token-by-token to find winner.
 *
 * SAL constraints: no arrays, INTEGER and STRING only, max string 255 chars.
 * We use 5 explicit integer vars (g_s1..g_s5) for sorted card values.
 *
 * Prerequisite: download poker data to c:\temp\p054_poker.txt from:
 *   https://projecteuler.net/resources/documents/0054_poker.txt
 *
 * Version: 1.0.0.0
 */

string POKER_FILE[255] = "p054_poker.txt"

// -----------------------------------------------------------------------
// Card value: returns 2..14 from card string like "5H", "TC", "AD"
// -----------------------------------------------------------------------
integer proc CardVal(string card)
    string ch[2]
    ch = SubStr(card, 1, 1)
    case ch
        when "2" return(2)
        when "3" return(3)
        when "4" return(4)
        when "5" return(5)
        when "6" return(6)
        when "7" return(7)
        when "8" return(8)
        when "9" return(9)
        when "T" return(10)
        when "J" return(11)
        when "Q" return(12)
        when "K" return(13)
        when "A" return(14)
    endcase
    return(0)
end

// -----------------------------------------------------------------------
// Sort 5 card values ascending into globals g_s1..g_s5
// -----------------------------------------------------------------------
integer g_s1, g_s2, g_s3, g_s4, g_s5

proc Sort5(integer a1, integer a2, integer a3, integer a4, integer a5)
    integer tmp
    g_s1 = a1  g_s2 = a2  g_s3 = a3  g_s4 = a4  g_s5 = a5
    // Bubble sort ascending
    if g_s1 > g_s2  tmp=g_s1  g_s1=g_s2  g_s2=tmp  endif
    if g_s2 > g_s3  tmp=g_s2  g_s2=g_s3  g_s3=tmp  endif
    if g_s3 > g_s4  tmp=g_s3  g_s3=g_s4  g_s4=tmp  endif
    if g_s4 > g_s5  tmp=g_s4  g_s4=g_s5  g_s5=tmp  endif
    if g_s1 > g_s2  tmp=g_s1  g_s1=g_s2  g_s2=tmp  endif
    if g_s2 > g_s3  tmp=g_s2  g_s2=g_s3  g_s3=tmp  endif
    if g_s3 > g_s4  tmp=g_s3  g_s3=g_s4  g_s4=tmp  endif
    if g_s1 > g_s2  tmp=g_s1  g_s1=g_s2  g_s2=tmp  endif
    if g_s2 > g_s3  tmp=g_s2  g_s2=g_s3  g_s3=tmp  endif
    if g_s1 > g_s2  tmp=g_s1  g_s1=g_s2  g_s2=tmp  endif
end

// -----------------------------------------------------------------------
// Count occurrences of value x in g_s1..g_s5
// -----------------------------------------------------------------------
integer proc Count5(integer x)
    integer n
    n = 0
    if g_s1 == x  n = n + 1  endif
    if g_s2 == x  n = n + 1  endif
    if g_s3 == x  n = n + 1  endif
    if g_s4 == x  n = n + 1  endif
    if g_s5 == x  n = n + 1  endif
    return(n)
end

// -----------------------------------------------------------------------
// Score a hand whose sorted values are in g_s1..g_s5.
// isFlush = 1 if all same suit.
// Returns score as string "rank tb1 tb2 tb3 tb4 tb5" (space-separated).
// Tiebreakers: card values by (frequency desc, value desc).
// -----------------------------------------------------------------------
string proc HandScore(integer isFlush)
    integer rank
    integer c1, c2, c3, c4, c5
    integer nUnique
    integer isStraight
    integer tb1, tb2, tb3, tb4, tb5

    c1 = Count5(g_s1)
    c2 = Count5(g_s2)
    c3 = Count5(g_s3)
    c4 = Count5(g_s4)
    c5 = Count5(g_s5)

    // Count unique values
    nUnique = 1
    if g_s2 <> g_s1  nUnique = nUnique + 1  endif
    if g_s3 <> g_s2  nUnique = nUnique + 1  endif
    if g_s4 <> g_s3  nUnique = nUnique + 1  endif
    if g_s5 <> g_s4  nUnique = nUnique + 1  endif

    // Straight: 5 unique values and max-min == 4
    isStraight = 0
    if nUnique == 5 and (g_s5 - g_s1) == 4
        isStraight = 1
    endif

    // Determine hand rank
    rank = 0
    if nUnique == 5
        if isStraight and isFlush    rank = 8
        elseif isStraight            rank = 4
        elseif isFlush               rank = 5
        else                         rank = 0
        endif
    elseif nUnique == 4
        rank = 1
    elseif nUnique == 3
        if c1 == 3 or c2 == 3 or c3 == 3 or c4 == 3 or c5 == 3
            rank = 3
        else
            rank = 2
        endif
    else  // nUnique == 2
        if c1 == 4 or c2 == 4 or c3 == 4 or c4 == 4 or c5 == 4
            rank = 7
        else
            rank = 6
        endif
    endif

    // Build tiebreaker sequence (card values by freq desc, val desc).
    // g_s1..g_s5 sorted ascending; we derive tiebreakers by case.
    tb1 = 0  tb2 = 0  tb3 = 0  tb4 = 0  tb5 = 0

    case rank
        when 8, 4
            // Straight (flush): only highest card for tiebreak
            tb1 = g_s5

        when 5, 0
            // Flush / High Card: all 5 cards descending
            tb1 = g_s5  tb2 = g_s4  tb3 = g_s3  tb4 = g_s2  tb5 = g_s1

        when 7
            // Four of a Kind: quad value first, then kicker
            // Layouts: [k,q,q,q,q] (c5==4) or [q,q,q,q,k] (c1==4)
            if c5 == 4
                tb1 = g_s5  tb2 = g_s1
            else
                tb1 = g_s1  tb2 = g_s5
            endif

        when 6
            // Full House: triple value first, then pair value
            // Layouts: [t,t,t,p,p] (c1==3) or [p,p,t,t,t] (c5==3)
            if c1 == 3
                tb1 = g_s1  tb2 = g_s5
            else
                tb1 = g_s5  tb2 = g_s1
            endif

        when 3
            // Three of a Kind: triple value, then 2 kickers descending
            // Layouts: [t,t,t,k1,k2] or [k1,t,t,t,k2] or [k1,k2,t,t,t]
            if c1 == 3
                tb1 = g_s1  tb2 = g_s5  tb3 = g_s4
            elseif c3 == 3
                // middle triple: s=[k1,t,t,t,k2]
                tb1 = g_s3  tb2 = g_s5  tb3 = g_s1
            else
                // c5 == 3: s=[k1,k2,t,t,t]
                tb1 = g_s5  tb2 = g_s2  tb3 = g_s1
            endif

        when 2
            // Two Pairs: higher pair, lower pair, kicker
            // Layouts: [p,p,q,q,k] or [p,p,k,q,q] or [k,p,p,q,q]
            if g_s1 == g_s2 and g_s3 == g_s4
                // lower pair g_s1, higher pair g_s3, kicker g_s5
                tb1 = g_s3  tb2 = g_s1  tb3 = g_s5
            elseif g_s1 == g_s2 and g_s4 == g_s5
                // lower pair g_s1, higher pair g_s4, kicker g_s3
                tb1 = g_s4  tb2 = g_s1  tb3 = g_s3
            else
                // g_s2==g_s3 and g_s4==g_s5; lower pair g_s2, higher g_s4, kicker g_s1
                tb1 = g_s4  tb2 = g_s2  tb3 = g_s1
            endif

        when 1
            // One Pair: pair value, then 3 kickers descending
            // Layouts: [p,p,k1,k2,k3] or [k1,p,p,k2,k3]
            //          or [k1,k2,p,p,k3] or [k1,k2,k3,p,p]
            if g_s1 == g_s2
                tb1 = g_s1  tb2 = g_s5  tb3 = g_s4  tb4 = g_s3
            elseif g_s2 == g_s3
                tb1 = g_s2  tb2 = g_s5  tb3 = g_s4  tb4 = g_s1
            elseif g_s3 == g_s4
                tb1 = g_s3  tb2 = g_s5  tb3 = g_s2  tb4 = g_s1
            else
                // g_s4 == g_s5
                tb1 = g_s4  tb2 = g_s3  tb3 = g_s2  tb4 = g_s1
            endif

    endcase

    return(Str(rank)+" "+Str(tb1)+" "+Str(tb2)+" "+Str(tb3)+" "+Str(tb4)+" "+Str(tb5))
end

// -----------------------------------------------------------------------
// Compare two score strings token by token.
// Returns  1 if s1 > s2,  -1 if s1 < s2,  0 if equal.
// -----------------------------------------------------------------------
integer proc CompareScores(string s1, string s2)
    integer i, t1, t2
    string tok1[12], tok2[12]
    i = 1
    while i <= 6
        tok1 = GetToken(s1, " ", i)
        tok2 = GetToken(s2, " ", i)
        if Length(tok1) == 0 and Length(tok2) == 0
            return(0)
        endif
        t1 = Val(tok1)
        t2 = Val(tok2)
        if t1 > t2  return(1)  endif
        if t1 < t2  return(-1)  endif
        i = i + 1
    endwhile
    return(0)
end

// -----------------------------------------------------------------------
// Parse 5 cards from a line (tokens startTok..startTok+4),
// sort values, check flush, return score string.
// -----------------------------------------------------------------------
string proc ScoreLine(string line, integer startTok)
    string c1[3], c2[3], c3[3], c4[3], c5[3]
    integer isFlush
    c1 = GetToken(line, " ", startTok)
    c2 = GetToken(line, " ", startTok + 1)
    c3 = GetToken(line, " ", startTok + 2)
    c4 = GetToken(line, " ", startTok + 3)
    c5 = GetToken(line, " ", startTok + 4)
    isFlush = 0
    if SubStr(c1,2,1) == SubStr(c2,2,1) and
       SubStr(c2,2,1) == SubStr(c3,2,1) and
       SubStr(c3,2,1) == SubStr(c4,2,1) and
       SubStr(c4,2,1) == SubStr(c5,2,1)
        isFlush = 1
    endif
    Sort5(CardVal(c1), CardVal(c2), CardVal(c3), CardVal(c4), CardVal(c5))
    return(HandScore(isFlush))
end

// -----------------------------------------------------------------------
// Main
// -----------------------------------------------------------------------
proc main()
    integer pokerBuf
    integer wins1, lineCount
    string curLine[255]
    string score1[50], score2[50]
    string resultStr[20]

    if not FileExists(POKER_FILE)
        Warn("File not found: " + POKER_FILE +
             "  Download from: projecteuler.net/resources/documents/0054_poker.txt")
        return()
    endif

    pokerBuf = CreateTempBuffer()
    if not InsertFile(POKER_FILE)
        Warn("Could not insert file: " + POKER_FILE)
        AbandonFile(pokerBuf)
        return()
    endif

    wins1 = 0
    lineCount = 0

    BegFile()
    repeat
        curLine = GetText(1, CurrLineLen())
        if Length(Trim(curLine)) > 0
            lineCount = lineCount + 1
            score1 = ScoreLine(curLine, 1)
            score2 = ScoreLine(curLine, 6)
            if CompareScores(score1, score2) > 0
                wins1 = wins1 + 1
            endif
        endif
    until not Down()

    AbandonFile(pokerBuf)

    resultStr = Str(wins1)
    Warn("Project Euler #54 -- Player 1 wins " + resultStr +
         " hands (out of " + Str(lineCount) + ")")
    CopyToWinClip(resultStr)
end
