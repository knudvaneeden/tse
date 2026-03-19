// Project Euler - Problem 127: abc-hits
// <version>1.0.0.0.2</version>
//
// The radical of n, rad(n), is the product of the distinct prime factors of n.
// A triplet (a, b, c) is an abc-hit if:
//   GCD(a,b) = GCD(a,c) = GCD(b,c) = 1  (pairwise coprime)
//   a < b,  a + b = c
//   rad(a * b * c) < c
// Find the sum of c for all abc-hits with c < 120000.
// Answer: 18407904
//
// Strategy:
//   1. Sieve rad(n) for all n < LIMIT into gRadBufI  (line n+1 = rad(n)).
//   2. Build gSortedBufI: one line per a in 1..LIMIT-1, formatted as
//      "RRRRRR AAAAAA" (rad zero-padded 6 digits, space, a zero-padded 6 digits).
//      Sort this buffer lexicographically => sorted by rad(a) ascending.
//   3. Outer loop over c.  For each c, walk gSortedBufI in order.
//      Since rad(a) is non-decreasing, we can break as soon as
//      rad(a) * rad(c) >= c  (all later entries also fail the rad test).
//      We also need a <= c/2  (so b = c-a >= a, keeping a < b).
//      For valid (a, b=c-a): check gcd(a,b)==1, gcd(a,c)==1, rad(b) test.

// ---------------------------------------------------------------------------
// Constants
// ---------------------------------------------------------------------------
constant LIMIT  = 120000

// ---------------------------------------------------------------------------
// Globals
// ---------------------------------------------------------------------------
integer gRadBufI    = 0   // line n+1  = rad(n),  n = 0..LIMIT-1
integer gSortedBufI = 0   // line i    = Format(rad(a):6:"0")+" "+Format(a:6:"0")
                           // sorted ascending by rad(a)

// ---------------------------------------------------------------------------
// FORWARD declarations
// ---------------------------------------------------------------------------
forward integer proc FNGcdI( integer aI, integer bI )

// ---------------------------------------------------------------------------
// FNGcdI  --  iterative GCD
// ---------------------------------------------------------------------------
integer proc FNGcdI( integer aI, integer bI )
    integer tI = 0
    //
    while bI <> 0
        tI = bI
        bI = aI mod bI
        aI = tI
    endwhile
    return( aI )
end

// ---------------------------------------------------------------------------
// BuildRadSieve
//   Fill gRadBufI: line n+1 = rad(n) for n = 0..LIMIT-1.
//   Sieve: initialise all to 1; for each prime p multiply all multiples by p.
// ---------------------------------------------------------------------------
proc BuildRadSieve()
    integer nI   = 0
    integer kI   = 0
    integer radI = 0
    //
    gRadBufI = CreateTempBuffer()
    GotoBufferId( gRadBufI )
    BegFile()
    // Line 1 = placeholder for n=0
    AddLine( "1" )
    nI = 1
    while nI < LIMIT
        AddLine( "1" )
        nI = nI + 1
    endwhile
    //
    // For each p: if rad[p]==1 it is prime; multiply rad[multiples] by p
    nI = 2
    while nI < LIMIT
        GotoBufferId( gRadBufI )
        GotoLine( nI + 1 )
        radI = Val( GetText( 1, CurrLineLen() ) )
        if radI == 1
            kI = nI
            while kI < LIMIT
                GotoBufferId( gRadBufI )
                GotoLine( kI + 1 )
                radI = Val( GetText( 1, CurrLineLen() ) )
                BegLine()
                KillToEOL()
                InsertText( Str( radI * nI ) )
                kI = kI + nI
            endwhile
        endif
        nI = nI + 1
    endwhile
end

// ---------------------------------------------------------------------------
// BuildSortedBuf
//   Build gSortedBufI with one line per a = 1..LIMIT-1:
//     Format(rad(a):6:"0") + " " + Format(a:6:"0")
//   Then Sort() the buffer => ascending by rad(a), ties broken by a.
// ---------------------------------------------------------------------------
proc BuildSortedBuf()
    integer aI   = 0
    integer radI = 0
    //
    gSortedBufI = CreateTempBuffer()
    GotoBufferId( gSortedBufI )
    BegFile()
    //
    aI = 1
    while aI < LIMIT
        // Look up rad(a)
        GotoBufferId( gRadBufI )
        GotoLine( aI + 1 )
        radI = Val( GetText( 1, CurrLineLen() ) )
        //
        GotoBufferId( gSortedBufI )
        AddLine( Format( radI:6:"0" ) + " " + Format( aI:6:"0" ) )
        aI = aI + 1
    endwhile
    //
    // Sort the buffer: lexicographic = numeric because of zero-padding
    GotoBufferId( gSortedBufI )
    BegFile()
    MarkLine()
    EndFile()
    MarkLine()
    Sort()
    UnMarkBlock()
end

// ---------------------------------------------------------------------------
// Main
// ---------------------------------------------------------------------------
proc Main()
    integer cI      = 0
    integer aI      = 0
    integer bI      = 0
    integer radcI   = 0
    integer radaI   = 0
    integer radbI   = 0
    integer halfCI  = 0
    integer sumI    = 0
    integer nLinesI = 0
    integer lineI   = 0
    string  lineS[20]  = ""
    string  resS[20]   = ""
    //
    Message( "Building rad sieve..." )
    BuildRadSieve()
    //
    Message( "Building sorted-by-rad table..." )
    BuildSortedBuf()
    //
    Message( "Searching for abc-hits..." )
    //
    GotoBufferId( gSortedBufI )
    nLinesI = NumLines()
    //
    cI = 3
    while cI < LIMIT
        //
        // Look up rad(c)
        GotoBufferId( gRadBufI )
        GotoLine( cI + 1 )
        radcI = Val( GetText( 1, CurrLineLen() ) )
        //
        // Quick reject: need rad(c) < c
        if radcI < cI
            //
            halfCI = cI / 2    // require a <= halfCI so that a < b = c-a
            //
            // Walk sorted-by-rad buffer; break as soon as rad(a)*rad(c) >= c
            lineI = 1
            while lineI <= nLinesI
                GotoBufferId( gSortedBufI )
                GotoLine( lineI )
                lineS = GetText( 1, 13 )        // "RRRRRR AAAAAA"
                radaI = Val( SubStr( lineS, 1, 6 ) )
                aI    = Val( SubStr( lineS, 8, 6 ) )
                //
                // Break: rad(a) is non-decreasing in sorted order,
                // so once rad(a)*rad(c) >= c all further entries also fail
                if radaI * radcI >= cI
                    lineI = nLinesI + 1         // force exit
                else
                    // Need a < b, i.e. a < c-a, i.e. a < c/2
                    if aI <= halfCI
                        bI = cI - aI
                        //
                        if FNGcdI( aI, bI ) == 1
                            if FNGcdI( aI, cI ) == 1
                                // Look up rad(b)
                                GotoBufferId( gRadBufI )
                                GotoLine( bI + 1 )
                                radbI = Val( GetText( 1, CurrLineLen() ) )
                                //
                                // Overflow-safe product check:
                                // Need rad(a)*rad(b)*rad(c) < c.
                                // Let P = rad(a)*rad(c); from break condition P < c < 120000.
                                // radbI can be large so avoid radbI*P directly.
                                // rad(b)*P < c  <=>  rad(b) <= (c-1)/P  (integer, exact)
                                if radbI <= ( cI - 1 ) / ( radaI * radcI )
                                    sumI = sumI + cI
                                endif
                            endif
                        endif
                    endif
                    lineI = lineI + 1
                endif
            endwhile
            //
        endif
        //
        cI = cI + 1
    endwhile
    //
    AbandonFile( gRadBufI )
    AbandonFile( gSortedBufI )
    //
    resS = Str( sumI )
    CopyToWinClip( resS )
    Warn( "P127 abc-hits  sum of c = ", resS )
end
