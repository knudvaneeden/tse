// p031.s  - Project Euler Problem 31: Coin Sums
//
// In England the currency is made up of pound (GBP) and pence (p).
// There are eight coins in general circulation:
//   1p, 2p, 5p, 10p, 20p, 50p, 100p (GBP1), 200p (GBP2).
//
// How many different ways can GBP2 (200p) be made using any number of coins?
//
// Algorithm: Classic dynamic programming (coin-change counting).
//   ways[0] = 1  (one way to make 0p: use no coins)
//   ways[1..200] = 0  initially
//   For each coin denomination c:
//       For i = c to 200:
//           ways[i] += ways[i - c]
//   Answer = ways[200]
//
// SAL has no arrays, so we store the 201-element "ways" table in a
// temporary buffer: line N holds the integer value for ways[N].
//
// Version : 1.3

// ---------------------------------------------------------------------------
// Helper: read integer value stored on line n of the given buffer
// ---------------------------------------------------------------------------
integer proc GetWays(integer bufId, integer n)
    integer waysVal
    PushPosition()
    GotoBufferId(bufId)
    GotoLine(n + 1)         // line numbers are 1-based; index n -> line n+1
    waysVal = Val(GetText(1, CurrLineLen()))
    PopPosition()
    return(waysVal)
end

// ---------------------------------------------------------------------------
// Helper: write integer value to line n of the given buffer
// ---------------------------------------------------------------------------
proc SetWays(integer bufId, integer n, integer waysVal)
    PushPosition()
    GotoBufferId(bufId)
    GotoLine(n + 1)         // index n -> line n+1
    // Overwrite line content without deleting the line itself:
    // BegLine + DelToEol removes text but keeps the newline,
    // so all line numbers remain stable.
    BegLine()
    DelToEol()
    InsertText(Str(waysVal), _INSERT_)
    PopPosition()
end

// ---------------------------------------------------------------------------
// Main
// ---------------------------------------------------------------------------
proc Main()
    integer bufId
    integer coin
    integer i
    integer cur
    integer ways_i_minus_c
    integer result
    string  resultStr[20]

    // Eight UK coin denominations in pence
    // We will iterate over them by hand (no arrays in SAL)

    // Create temp buffer and initialise 201 lines: line 1 = "1", lines 2-201 = "0"
    bufId = CreateTempBuffer()
    GotoBufferId(bufId)
    EmptyBuffer()

    // Line 1  -> ways[0] = 1
    AddLine("1")
    // Lines 2..201 -> ways[1..200] = 0
    i = 1
    while i <= 200
        AddLine("0")
        i = i + 1
    endwhile

    // ----- DP update for each coin -----

    // coin = 1
    coin = 1
    i = coin
    while i <= 200
        cur           = GetWays(bufId, i)
        ways_i_minus_c = GetWays(bufId, i - coin)
        SetWays(bufId, i, cur + ways_i_minus_c)
        i = i + 1
    endwhile

    // coin = 2
    coin = 2
    i = coin
    while i <= 200
        cur           = GetWays(bufId, i)
        ways_i_minus_c = GetWays(bufId, i - coin)
        SetWays(bufId, i, cur + ways_i_minus_c)
        i = i + 1
    endwhile

    // coin = 5
    coin = 5
    i = coin
    while i <= 200
        cur           = GetWays(bufId, i)
        ways_i_minus_c = GetWays(bufId, i - coin)
        SetWays(bufId, i, cur + ways_i_minus_c)
        i = i + 1
    endwhile

    // coin = 10
    coin = 10
    i = coin
    while i <= 200
        cur           = GetWays(bufId, i)
        ways_i_minus_c = GetWays(bufId, i - coin)
        SetWays(bufId, i, cur + ways_i_minus_c)
        i = i + 1
    endwhile

    // coin = 20
    coin = 20
    i = coin
    while i <= 200
        cur           = GetWays(bufId, i)
        ways_i_minus_c = GetWays(bufId, i - coin)
        SetWays(bufId, i, cur + ways_i_minus_c)
        i = i + 1
    endwhile

    // coin = 50
    coin = 50
    i = coin
    while i <= 200
        cur           = GetWays(bufId, i)
        ways_i_minus_c = GetWays(bufId, i - coin)
        SetWays(bufId, i, cur + ways_i_minus_c)
        i = i + 1
    endwhile

    // coin = 100
    coin = 100
    i = coin
    while i <= 200
        cur           = GetWays(bufId, i)
        ways_i_minus_c = GetWays(bufId, i - coin)
        SetWays(bufId, i, cur + ways_i_minus_c)
        i = i + 1
    endwhile

    // coin = 200
    coin = 200
    i = coin
    while i <= 200
        cur           = GetWays(bufId, i)
        ways_i_minus_c = GetWays(bufId, i - coin)
        SetWays(bufId, i, cur + ways_i_minus_c)
        i = i + 1
    endwhile

    // ----- Read answer and report -----
    result    = GetWays(bufId, 200)
    resultStr = Str(result)

    AbandonFile(bufId)

    CopyToWinClip(resultStr)
    Warn("Project Euler #31 - Coin Sums", Chr(13),
         "Ways to make GBP2 (200p): ", resultStr, Chr(13),
         "(answer copied to clipboard)")
end
