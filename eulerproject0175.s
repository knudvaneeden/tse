// Project Euler - Problem 175
// Fractions and Sum of Powers of Two
//
// Define f(0)=1 and f(n) to be the number of ways to write n as a sum of
// powers of 2 where no power occurs more than twice.
// Find the Shortened Binary Expansion of the smallest n for which
// f(n)/f(n-1) = 123456789/987654321.
//
// Key insight (recurrences):
//   f(2k+1) = f(k)              => n odd  -> bit=1, new ratio p/(q-p)
//   f(2k)   = f(k) + f(k-1)    => n even -> bit=0, new ratio (p-q)/q
//
// Building n's binary LSB-first via subtraction:
//   while (p,q) != (1,1):
//     p < q  -> append 1, q -= p
//     p > q  -> append 0, p -= q
//   append MSB=1 at the end.
//
// Accelerated (Euclidean-style) to avoid O(p+q) iterations:
//   p < q, rem = q mod p, run = q div p:
//     rem != 0: store 'run' ones, set q=rem, continue
//     rem == 0: store 'run' ones (already absorbs the MSB=1), done
//   p > q, rem = p mod q, run = p div q:
//     rem != 0: store 'run' zeros, set p=rem, continue
//     rem == 0: store 'run-1' zeros then MSB=1 (different type), done
//   p == q == 1: store MSB=1, done
//
// Runs collected LSB-first then reversed to give MSB-first SBE.
//
// Verified: 13/17 -> SBE 4,3,1 -> n=241=11110001 binary (correct).
// Answer:   123456789/987654321 -> SBE 1,13717420,8
//
// <version>1.0.0.0.2</version>
//
// History:
//   1.0.0.0.1  2025-03-23  Initial version. Wrong answer: mishandled MSB
//                           merging in the terminating run cases.
//                           Created by Claude Sonnet 4.6 (Anthropic).
//   1.0.0.0.2  2025-03-23  Fixed terminating-run MSB logic:
//                           - ones-run rem=0: MSB=1 merges in, append 'run'.
//                           - zeros-run rem=0: MSB=1 is new entry, append
//                             'run-1' zeros then '1' separately.
//                           Created by Claude Sonnet 4.6 (Anthropic).

// ============================================================
// Proc: ComputeGcd
//   Standard iterative Euclidean GCD for positive integers.
// ============================================================
integer proc ComputeGcd( integer aI, integer bI )
    integer tmpI = 0
    //
    while bI <> 0
        tmpI = aI mod bI
        aI   = bI
        bI   = tmpI
    endwhile
    return( aI )
end

// ============================================================
// Proc: AppendToBuffer
//   Moves to the given buffer, goes to end, appends a new line.
// ============================================================
proc AppendToBuffer( integer bufIdI, string lineS )
    GotoBufferId( bufIdI )
    EndFile()
    AddLine( lineS )
end

// ============================================================
// Proc: Main
// ============================================================
proc Main()
    integer pI       = 0    // working numerator
    integer qI       = 0    // working denominator
    integer gcdI     = 0    // GCD for fraction reduction
    integer remI     = 0    // remainder in Euclidean step
    integer runI     = 0    // quotient (run length) in Euclidean step
    integer sbeIdI   = 0    // buffer id: SBE runs, LSB-first, one per line
    integer nLinesI  = 0    // number of lines in SBE buffer
    integer idxI     = 0    // reverse-traversal index
    integer doneI    = 0    // loop-exit flag
    string  runS[20]   = "" // one run length as string
    string  resultS[255] = ""// final comma-separated SBE answer
    //
    // ----------------------------------------------------------
    // Step 1: Reduce fraction 123456789 / 987654321 by GCD
    //   GCD = 9, giving 13717421 / 109739369
    // ----------------------------------------------------------
    pI   = 123456789
    qI   = 987654321
    gcdI = ComputeGcd( pI, qI )
    pI   = pI / gcdI
    qI   = qI / gcdI
    //
    // ----------------------------------------------------------
    // Step 2: Build SBE run lengths (LSB-first) using the
    //         accelerated Euclidean subtraction algorithm.
    // ----------------------------------------------------------
    sbeIdI = CreateTempBuffer()
    doneI  = FALSE
    //
    while doneI == FALSE
        //
        if ( pI == 1 ) and ( qI == 1 )
            // Base case: store MSB=1 and finish
            AppendToBuffer( sbeIdI, "1" )
            doneI = TRUE
            //
        elseif pI < qI
            // Bit=1 run: floor(q/p) ones
            runI = qI / pI
            remI = qI mod pI
            if remI == 0
                // Terminating ones-run: MSB=1 merges into this run
                // (p must be 1 here since gcd=1 and rem=0 implies p|q,
                //  combined with (p,q) coprime => p=1)
                AppendToBuffer( sbeIdI, Str( runI ) )
                doneI = TRUE
            else
                AppendToBuffer( sbeIdI, Str( runI ) )
                qI = remI
            endif
            //
        else
            // pI > qI, bit=0 run: floor(p/q) zeros
            runI = pI / qI
            remI = pI mod qI
            if remI == 0
                // Terminating zeros-run: the MSB=1 is a DIFFERENT bit type
                // so it must be stored as a separate entry.
                // run-1 zeros (stop before reaching p=q), then MSB=1.
                if runI > 1
                    AppendToBuffer( sbeIdI, Str( runI - 1 ) )
                endif
                AppendToBuffer( sbeIdI, "1" )
                doneI = TRUE
            else
                AppendToBuffer( sbeIdI, Str( runI ) )
                pI = remI
            endif
            //
        endif
        //
    endwhile
    //
    // ----------------------------------------------------------
    // Step 3: Read buffer BACKWARDS (reverses LSB->MSB order)
    //         to build the comma-separated MSB-first SBE string.
    // ----------------------------------------------------------
    GotoBufferId( sbeIdI )
    nLinesI = NumLines()
    //
    resultS = ""
    idxI    = nLinesI
    while idxI >= 1
        GotoLine( idxI )
        BegLine()
        runS = GetText( 1, CurrLineLen() )
        if Length( resultS ) == 0
            resultS = runS
        else
            resultS = resultS + "," + runS
        endif
        idxI = idxI - 1
    endwhile
    //
    // ----------------------------------------------------------
    // Step 4: Output the result
    // ----------------------------------------------------------
    CopyToWinClip( resultS )
    //
    Warn( "Project Euler 175" + Chr(13) +
          "Shortened Binary Expansion of smallest n" + Chr(13) +
          "where f(n)/f(n-1) = 123456789/987654321:" + Chr(13) +
          Chr(13) +
          resultS )
    //
    CopyToWinClip( resultS )
    //
    AbandonFile( sbeIdI )
end
