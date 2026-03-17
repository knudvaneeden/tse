// =============================================================================
// euler076.s  —  Project Euler Problem 76 : Counting Summations
// =============================================================================
//
// Problem:
//   How many different ways can 100 be written as a sum of at least two
//   positive integers?
//
// Method:
//   Classic integer-partition DP (coin-change style sieve).
//
//   dp[n] = number of ways to write n as a sum of parts from {1..99}.
//
//   Recurrence:
//     dp[0] = 1   (one way to write zero: empty sum)
//     for part_k = 1 to 99:
//       for target_n = part_k to 100:
//         dp[target_n] += dp[target_n - part_k]
//
//   By limiting parts to 1..99 we never form the trivial partition "100=100",
//   so dp[100] is the answer directly — no subtraction needed.
//   Answer = 190,569,291  (fits in 32-bit signed integer).
//
// TSE SAL constraints respected:
//   - NO integer arrays of any kind.
//     dp[0..100] is stored in a dedicated hidden buffer, one value per line.
//     Line 1 = dp[0], Line 2 = dp[1], ..., Line 101 = dp[100].
//   - All values fit in 32-bit signed integers (max ~2,147,483,647).
//   - No reserved-word variable names (no val, str, loop, var, and, etc.).
//   - No floating-point arithmetic.
//   - Message() string kept short (no 255-char overflow).
//
// Usage:
//   1. Place this file in your TSE macro source directory.
//   2. Macro -> Compile
//   3. Macro -> Execute Macro -> euler076 -> Enter
// =============================================================================

// ---------------------------------------------------------------------------
// Buffer ID for the dp[] simulation
// ---------------------------------------------------------------------------
INTEGER dp_buf

// ---------------------------------------------------------------------------
// SetDp(index, value)
//   Write value into line (index+1) of dp_buf.
//   Line 1 = dp[0], Line 2 = dp[1], etc.
// ---------------------------------------------------------------------------
PROC SetDp( INTEGER ndx, INTEGER num )
    GotoBufferId( dp_buf )
    GotoLine( ndx + 1 )
    BegLine()
    KillLine()
    InsertLine( Str( num ) )
END SetDp

// ---------------------------------------------------------------------------
// GetDp(index) : INTEGER
//   Read the integer stored at line (index+1) of dp_buf.
// ---------------------------------------------------------------------------
INTEGER PROC GetDp( INTEGER ndx )
    GotoBufferId( dp_buf )
    GotoLine( ndx + 1 )
    RETURN( Val( GetText( 1, 20 ) ) )
END GetDp

// ---------------------------------------------------------------------------
// Main
// ---------------------------------------------------------------------------
PROC Main()

    INTEGER part_k      // current part (coin)
    INTEGER target_n    // target sum index
    INTEGER ndx         // initialisation index
    INTEGER cur         // value read from dp buffer
    INTEGER prev        // value read from dp buffer
    INTEGER answer      // final answer
    INTEGER orig_buf    // remember caller's buffer

    orig_buf = GetBufferId()

    // -- Create a hidden work buffer for dp[0..100] --
    dp_buf = CreateTempBuffer()

    // -- Fill with 101 lines, all "0" --
    GotoBufferId( dp_buf )
    FOR ndx = 0 TO 100
        AddLine( "0" )
    ENDFOR

    // -- dp[0] = 1 --
    SetDp( 0, 1 )

    // -- Partition sieve --
    FOR part_k = 1 TO 99
        FOR target_n = part_k TO 100
            cur  = GetDp( target_n )
            prev = GetDp( target_n - part_k )
            SetDp( target_n, cur + prev )
        ENDFOR
    ENDFOR

    // -- Read answer --
    answer = GetDp( 100 )

    // -- Clean up work buffer --
    GotoBufferId( dp_buf )
    AbandonFile()

    // -- Return to original buffer and report --
    GotoBufferId( orig_buf )

    Message( "Euler 76  Counting Summations  Answer: ", answer )

    EndFile()
    AddLine( "Project Euler #76 - Counting Summations" )
    AddLine( "Answer: " + Str( answer ) )

END Main
