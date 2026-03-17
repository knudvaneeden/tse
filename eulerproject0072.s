/****************************************************************************
 *
 *  euler072.s
 *  TSE SAL macro  -  Project Euler Problem 72: Counting Fractions
 *
 *  Problem statement (https://projecteuler.net/problem=72):
 *    A reduced proper fraction n/d satisfies  n < d  and  HCF(n,d) = 1.
 *    How many such fractions exist for  d <= 1,000,000 ?
 *
 *  Mathematical insight:
 *    For a fixed denominator d, the count of valid numerators n equals
 *    Euler's totient  phi(d)  (integers 1..d-1 that are coprime to d).
 *    So the answer is:
 *        answer = SUM( phi(d) )   for d = 2, 3, ..., 1,000,000
 *
 *  Algorithm  -  Euler totient sieve  (O(N log log N)):
 *    1. Initialise  phi[i] = i  for i = 1..N.
 *    2. For i = 2..N:
 *         if phi[i] is still i  =>  i is prime (not yet touched by sieve).
 *         For every multiple  j = i, 2i, 3i, ...  <= N:
 *             phi[j]  =  phi[j]  -  phi[j] / i
 *         This applies the factor (1 - 1/p) for each prime p dividing j,
 *         which is Euler's product formula for phi.
 *    3. Sum phi[d] for d = 2..N.
 *
 *  SAL integer array strategy  -  hidden buffer:
 *    SAL has no native integer array type.  We emulate one with a hidden
 *    editor buffer where line number i holds the integer value phi[i]
 *    as a decimal string.  The buffer is created at the top of Euler072()
 *    before any helper proc references it, using PushPosition/PopPosition
 *    to protect the current editor state.  The buffer id is passed
 *    explicitly to every helper proc that needs it.
 *
 *  Overflow note:
 *    SAL integers are 32-bit signed (max ~2.147e9).
 *    The true answer is  303,963,552,391  which overflows 32 bits.
 *    We emulate a 64-bit accumulator with two 32-bit words:
 *        total  =  nSumHi * 1,000,000,000  +  nSumLo
 *
 *  How to run:
 *    Macro -> Load Macro File -> select this file
 *    Macro -> Execute Macro   -> type  Euler072  -> Enter
 *
 *  Expected answer:  303963552391
 *
 *****************************************************************************/

constant LIMIT   = 1000000
constant BILLION = 1000000000

// ---------------------------------------------------------------------------
// PhiGet( nBufId, i )
//   Return the integer stored on line i of the phi buffer.
// ---------------------------------------------------------------------------
integer proc PhiGet( integer nBufId, integer i )
    integer nOldId
    integer nVal
    //
    nOldId = GetBufferId()
    GotoBufferId( nBufId )
    GotoLine( i )
    nVal = Val( GetText( 1, CurrLineLen() ) )
    GotoBufferId( nOldId )
    //
    return( nVal )
end

// ---------------------------------------------------------------------------
// PhiSet( nBufId, i, nV )
//   Store the integer nV on line i of the phi buffer.
// ---------------------------------------------------------------------------
proc PhiSet( integer nBufId, integer i, integer nV )
    integer nOldId
    //
    nOldId = GetBufferId()
    GotoBufferId( nBufId )
    GotoLine( i )
    BegLine()
    KillToEol()
    InsertText( Str( nV ), _INSERT_ )
    GotoBufferId( nOldId )
end

// ---------------------------------------------------------------------------
// Euler072  -  main entry point
// ---------------------------------------------------------------------------
proc Euler072()

    integer nBufId
    integer i
    integer j
    integer nPv
    integer nJv
    integer nSumHi
    integer nSumLo
    string  sLoStr[9]
    string  sAnswer[30]

    // ------------------------------------------------------------------
    // Create the phi buffer FIRST, before any reference to it.
    // PushPosition/PopPosition protects the current file and cursor.
    // ------------------------------------------------------------------
    PushPosition()                          // 1
    nBufId = CreateTempBuffer()
    PopPosition()                           // 1

    // ------------------------------------------------------------------
    // Step 1: populate buffer  -  line i holds the value i  (phi[i] = i)
    // ------------------------------------------------------------------
    // Warn( "Euler072: step 1/3  initialising phi array..." ) // debug

    PushPosition()                          // 2
    GotoBufferId( nBufId )
    BegFile()
    for i = 1 to LIMIT
        AddLine( Str( i ) )
    endfor
    PopPosition()                           // 2

    // ------------------------------------------------------------------
    // Step 2: sieve
    // ------------------------------------------------------------------
    // Warn( "Euler072: step 2/3  sieving totients..." ) // debug

    for i = 2 to LIMIT
        nPv = PhiGet( nBufId, i )
        if nPv == i                         // i is prime
            j = i
            while j <= LIMIT
                nJv = PhiGet( nBufId, j )
                PhiSet( nBufId, j, nJv - nJv / i )
                j = j + i
            endwhile
        endif
    endfor

    // ------------------------------------------------------------------
    // Step 3: sum phi[d] for d = 2..LIMIT  (64-bit emulation)
    // ------------------------------------------------------------------
    // Warn( "Euler072: step 3/3  summing..." ) // debug

    nSumHi = 0
    nSumLo = 0

    for i = 2 to LIMIT
        nSumLo = nSumLo + PhiGet( nBufId, i )
        if nSumLo >= BILLION
            nSumLo = nSumLo - BILLION
            nSumHi = nSumHi + 1
        endif
    endfor

    // ------------------------------------------------------------------
    // Build and display answer
    // ------------------------------------------------------------------
    if nSumHi > 0
        // Zero-pad low part to exactly 9 digits  e.g. 552391 -> "000552391"
        sLoStr = Str( nSumLo )
        while Length( sLoStr ) < 9
            sLoStr = "0" + sLoStr
        endwhile
        sAnswer = Str( nSumHi ) + sLoStr
    else
        sAnswer = Str( nSumLo )
    endif

    CopyToWinClip( sAnswer )
    Warn( "Project Euler #72  |  Answer: " + sAnswer + "  (copied to clipboard)" )

    // ------------------------------------------------------------------
    // Clean up: abandon the temporary buffer
    // ------------------------------------------------------------------
    PushPosition()                          // 3
    GotoBufferId( nBufId )
    AbandonFile()
    PopPosition()                           // 3

end

// ---------------------------------------------------------------------------
// Main()  -  TSE entry point, called when macro is executed
// ---------------------------------------------------------------------------
proc Main()
    Euler072()
end

// ---------------------------------------------------------------------------
<Alt 7>   Euler072()
