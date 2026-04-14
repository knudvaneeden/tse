// eulerproject0273.s
// Project Euler Problem 273 - Sum of Squares
// Find sum of S(N) for all squarefree N only divisible by primes 4k+1 < 150
// Version: 1
// LLM: Claude (Anthropic)
//
// Algorithm: Gaussian integer multiplication over all 2^16-1 non-empty subsets
// of the 16 primes. Each prime p = c^2 + d^2 is a Gaussian integer (c+di).
// For each subset, compute all 2^k Gaussian products (choosing c+di or c-di
// for each included prime). Sum min(|Re|,|Im|) over all products, divide by 2.
//
// Uses hi/lo base-10000000 arithmetic for 64-bit values.
// Re, Im stored as (sign, hi, lo) per representation.
//
// History:
// v1 [14-04-2026] Claude (Anthropic) - initial version

// --- constants ---
integer gBASEI = 10000000
integer gNPrimesI = 16

// --- global buffer IDs ---
integer gPrimeBufI = 0
integer gBuf1I = 0
integer gBuf2I = 0
integer gMainBufI = 0

// --- running sum: 4 parts of base 10^7 ---
integer gSumS3I = 0
integer gSumS2I = 0
integer gSumS1I = 0
integer gSumS0I = 0

// --- helper return values ---
integer gResSignI = 0
integer gResHiI = 0
integer gResLoI = 0

// ============================================================
// MulSmall: multiply magnitude (hiI, loI) by small positive nI
// Result in gResHiI, gResLoI
// ============================================================
PROC MulSmall( integer hiI, integer loI, integer nI )
    integer carryI
    loI = loI * nI
    carryI = loI / gBASEI
    gResLoI = loI mod gBASEI
    gResHiI = hiI * nI + carryI
END

// ============================================================
// CompareAbs: compare magnitudes (h1,l1) vs (h2,l2)
// Returns 1 if first > second, -1 if less, 0 if equal
// ============================================================
integer PROC CompareAbs( integer h1I, integer l1I, integer h2I, integer l2I )
    if h1I > h2I
        return( 1 )
    endif
    if h1I < h2I
        return( -1 )
    endif
    if l1I > l2I
        return( 1 )
    endif
    if l1I < l2I
        return( -1 )
    endif
    return( 0 )
END

// ============================================================
// AddSigned: add two signed hi/lo numbers
// (s1,h1,l1) + (s2,h2,l2) -> (gResSignI, gResHiI, gResLoI)
// ============================================================
PROC AddSigned( integer s1I, integer h1I, integer l1I,
                integer s2I, integer h2I, integer l2I )
    integer cmpI
    if s1I == s2I
        // same sign: add magnitudes
        gResLoI = l1I + l2I
        gResHiI = h1I + h2I + gResLoI / gBASEI
        gResLoI = gResLoI mod gBASEI
        gResSignI = s1I
    else
        // different signs: subtract smaller magnitude from larger
        cmpI = CompareAbs( h1I, l1I, h2I, l2I )
        if cmpI >= 0
            gResLoI = l1I - l2I
            if gResLoI < 0
                gResLoI = gResLoI + gBASEI
                gResHiI = h1I - h2I - 1
            else
                gResHiI = h1I - h2I
            endif
            gResSignI = s1I
        else
            gResLoI = l2I - l1I
            if gResLoI < 0
                gResLoI = gResLoI + gBASEI
                gResHiI = h2I - h1I - 1
            else
                gResHiI = h2I - h1I
            endif
            gResSignI = s2I
        endif
        // handle zero result
        if gResHiI == 0 AND gResLoI == 0
            gResSignI = 1
        endif
    endif
END

// ============================================================
// AddToSum: add positive (hiI, loI) to running 4-part sum
// ============================================================
PROC AddToSum( integer hiI, integer loI )
    gSumS0I = gSumS0I + loI
    gSumS1I = gSumS1I + hiI + gSumS0I / gBASEI
    gSumS0I = gSumS0I mod gBASEI
    gSumS2I = gSumS2I + gSumS1I / gBASEI
    gSumS1I = gSumS1I mod gBASEI
    gSumS3I = gSumS3I + gSumS2I / gBASEI
    gSumS2I = gSumS2I mod gBASEI
END

// ============================================================
// DivideSum2: divide the 4-part sum by 2
// ============================================================
PROC DivideSum2()
    integer remI
    remI = gSumS3I mod 2
    gSumS3I = gSumS3I / 2
    gSumS2I = gSumS2I + remI * gBASEI
    remI = gSumS2I mod 2
    gSumS2I = gSumS2I / 2
    gSumS1I = gSumS1I + remI * gBASEI
    remI = gSumS1I mod 2
    gSumS1I = gSumS1I / 2
    gSumS0I = gSumS0I + remI * gBASEI
    gSumS0I = gSumS0I / 2
END

// ============================================================
// SumToString: convert 4-part sum to decimal string
// ============================================================
string PROC SumToString()
    string resultS[255]
    if gSumS3I > 0
        resultS = Str( gSumS3I )
                + Format( gSumS2I:7:"0" )
                + Format( gSumS1I:7:"0" )
                + Format( gSumS0I:7:"0" )
    elseif gSumS2I > 0
        resultS = Str( gSumS2I )
                + Format( gSumS1I:7:"0" )
                + Format( gSumS0I:7:"0" )
    elseif gSumS1I > 0
        resultS = Str( gSumS1I )
                + Format( gSumS0I:7:"0" )
    else
        resultS = Str( gSumS0I )
    endif
    return( resultS )
END

// ============================================================
// ProcessSubset: process one subset given by maskI
// Computes all Gaussian products, sums min(|Re|,|Im|)
// ============================================================
PROC ProcessSubset( integer maskI )
    integer bitI, primeIdxI
    integer nLinesI, lineI
    string lineS[255]
    integer rSI, rHI, rLI, iSI, iHI, iLI
    integer cI, dI
    integer acHI, acLI, bdHI, bdLI, adHI, adLI, bcHI, bcLI
    integer nr1SI, nr1HI, nr1LI, ni1SI, ni1HI, ni1LI
    integer nr2SI, nr2HI, nr2LI, ni2SI, ni2HI, ni2LI
    integer minHI, minLI
    integer tmpI
    string outS[255]

    // Initialize buf1 with the identity Gaussian integer (1 + 0i)
    // Format per line: "rSign rHi rLo iSign iHi iLo"
    GotoBufferId( gBuf1I )
    EmptyBuffer()
    BegFile()
    InsertText( "1 0 1 1 0 0" )

    // Process each prime in the subset
    bitI = 1
    for primeIdxI = 1 to gNPrimesI
        if ( maskI & bitI ) > 0
            // Get c, d for this prime
            GotoBufferId( gPrimeBufI )
            GotoLine( primeIdxI )
            lineS = GetText( 1, CurrLineLen() )
            cI = Val( GetToken( lineS, " ", 1 ) )
            dI = Val( GetToken( lineS, " ", 2 ) )

            // Prepare destination buffer
            GotoBufferId( gBuf2I )
            EmptyBuffer()

            // Read source buffer line count
            GotoBufferId( gBuf1I )
            nLinesI = NumLines()

            for lineI = 1 to nLinesI
                GotoBufferId( gBuf1I )
                GotoLine( lineI )
                lineS = GetText( 1, CurrLineLen() )

                // skip blank lines
                if Length( lineS ) > 0
                    rSI = Val( GetToken( lineS, " ", 1 ) )
                    rHI = Val( GetToken( lineS, " ", 2 ) )
                    rLI = Val( GetToken( lineS, " ", 3 ) )
                    iSI = Val( GetToken( lineS, " ", 4 ) )
                    iHI = Val( GetToken( lineS, " ", 5 ) )
                    iLI = Val( GetToken( lineS, " ", 6 ) )

                    // Compute partial products (magnitudes only)
                    // ac = |Re| * c
                    MulSmall( rHI, rLI, cI )
                    acHI = gResHiI
                    acLI = gResLoI

                    // bd = |Im| * d
                    MulSmall( iHI, iLI, dI )
                    bdHI = gResHiI
                    bdLI = gResLoI

                    // ad = |Re| * d
                    MulSmall( rHI, rLI, dI )
                    adHI = gResHiI
                    adLI = gResLoI

                    // bc = |Im| * c
                    MulSmall( iHI, iLI, cI )
                    bcHI = gResHiI
                    bcLI = gResLoI

                    // --- Product 1: (Re+Im*i)(c+d*i) ---
                    // new Re = Re*c - Im*d
                    AddSigned( rSI, acHI, acLI, ( -iSI ), bdHI, bdLI )
                    nr1SI = gResSignI
                    nr1HI = gResHiI
                    nr1LI = gResLoI

                    // new Im = Re*d + Im*c
                    AddSigned( rSI, adHI, adLI, iSI, bcHI, bcLI )
                    ni1SI = gResSignI
                    ni1HI = gResHiI
                    ni1LI = gResLoI

                    GotoBufferId( gBuf2I )
                    EndFile()
                    outS = Str( nr1SI ) + " " + Str( nr1HI ) + " " + Str( nr1LI )
                         + " " + Str( ni1SI ) + " " + Str( ni1HI ) + " " + Str( ni1LI )
                    AddLine( outS )

                    // --- Product 2: (Re+Im*i)(c-d*i) ---
                    // new Re = Re*c + Im*d
                    AddSigned( rSI, acHI, acLI, iSI, bdHI, bdLI )
                    nr2SI = gResSignI
                    nr2HI = gResHiI
                    nr2LI = gResLoI

                    // new Im = Im*c - Re*d
                    AddSigned( iSI, bcHI, bcLI, ( -rSI ), adHI, adLI )
                    ni2SI = gResSignI
                    ni2HI = gResHiI
                    ni2LI = gResLoI

                    GotoBufferId( gBuf2I )
                    EndFile()
                    outS = Str( nr2SI ) + " " + Str( nr2HI ) + " " + Str( nr2LI )
                         + " " + Str( ni2SI ) + " " + Str( ni2HI ) + " " + Str( ni2LI )
                    AddLine( outS )
                endif
            endfor

            // Swap buf1 and buf2
            tmpI = gBuf1I
            gBuf1I = gBuf2I
            gBuf2I = tmpI
        endif
        bitI = bitI * 2
    endfor

    // Sum min(|Re|, |Im|) for all representations in buf1
    GotoBufferId( gBuf1I )
    nLinesI = NumLines()
    for lineI = 1 to nLinesI
        GotoLine( lineI )
        lineS = GetText( 1, CurrLineLen() )
        if Length( lineS ) > 0
            rHI = Val( GetToken( lineS, " ", 2 ) )
            rLI = Val( GetToken( lineS, " ", 3 ) )
            iHI = Val( GetToken( lineS, " ", 5 ) )
            iLI = Val( GetToken( lineS, " ", 6 ) )

            // min of absolute values
            if CompareAbs( rHI, rLI, iHI, iLI ) <= 0
                minHI = rHI
                minLI = rLI
            else
                minHI = iHI
                minLI = iLI
            endif

            AddToSum( minHI, minLI )
        endif
    endfor
END

// ============================================================
// Main
// ============================================================
PROC Main()
    string resultS[255]
    integer maskI

    // Save main editing buffer
    gMainBufI = GetBufferId()

    // Create prime decomposition buffer
    // Each line: "c d" where p = c^2 + d^2, c < d
    gPrimeBufI = CreateTempBuffer()
    BegFile()
    InsertText( "1 2" )        // 5 = 1^2 + 2^2
    AddLine( "2 3" )           // 13 = 2^2 + 3^2
    AddLine( "1 4" )           // 17 = 1^2 + 4^2
    AddLine( "2 5" )           // 29 = 2^2 + 5^2
    AddLine( "1 6" )           // 37 = 1^2 + 6^2
    AddLine( "4 5" )           // 41 = 4^2 + 5^2
    AddLine( "2 7" )           // 53 = 2^2 + 7^2
    AddLine( "5 6" )           // 61 = 5^2 + 6^2
    AddLine( "3 8" )           // 73 = 3^2 + 8^2
    AddLine( "5 8" )           // 89 = 5^2 + 8^2
    AddLine( "4 9" )           // 97 = 4^2 + 9^2
    AddLine( "1 10" )          // 101 = 1^2 + 10^2
    AddLine( "3 10" )          // 109 = 3^2 + 10^2
    AddLine( "7 8" )           // 113 = 7^2 + 8^2
    AddLine( "4 11" )          // 137 = 4^2 + 11^2
    AddLine( "7 10" )          // 149 = 7^2 + 10^2

    // Create two working buffers
    gBuf1I = CreateTempBuffer()
    gBuf2I = CreateTempBuffer()

    // Initialize sum to zero
    gSumS3I = 0
    gSumS2I = 0
    gSumS1I = 0
    gSumS0I = 0

    // Iterate over all non-empty subsets of the 16 primes
    for maskI = 1 to 65535
        ProcessSubset( maskI )
        // Progress indicator every 1000 subsets
        if ( maskI mod 1000 ) == 0
            Message( "Progress: " + Str( maskI ) + " / 65535" )
        endif
    endfor

    // Divide by 2 (conjugate pairs counted twice)
    DivideSum2()

    // Format result
    resultS = SumToString()

    // Cleanup temp buffers
    GotoBufferId( gBuf1I )
    AbandonFile()
    GotoBufferId( gBuf2I )
    AbandonFile()
    GotoBufferId( gPrimeBufI )
    AbandonFile()

    // Return to main buffer, display result
    GotoBufferId( gMainBufI )
    EmptyBuffer()
    InsertText( resultS )
    BegLine()
    MarkChar()
    EndLine()
    CopyToWinClip()
    UnMarkBlock()
    Warn( resultS )
    BegLine()
    MarkChar()
    EndLine()
    CopyToWinClip()
    UnMarkBlock()
END
