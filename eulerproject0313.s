// <version>1</version>
// Euler Project problem 313
// History:
// 1 - ChatGPT GPT-5.4 Thinking - initial pure TSE SAL version
//
// Mathematical reduction used by this program:
//
// For m >= n >= 2:
// - if m > n then S( m, n ) = 6 * m + 2 * n - 13
// - if m == n then S( m, m ) = 8 * m - 11
//
// For an odd prime p, p * p mod 8 == 1, therefore p * p cannot equal
// 8 * m - 11 because that is 5 mod 8.
// So only m > n can occur.
//
// Hence for p > 3 we need:
//   6 * m + 2 * n - 13 = p * p
//   3 * m + n = ( p * p + 13 ) / 2
//
// Counting integer solutions with m > n >= 2 gives exactly:
//   ( p * p - 1 ) / 24 unordered grids
// and therefore:
//   ( p * p - 1 ) / 12 ordered grids
//
// Because SAL is 32-bit only, this source never forms p * p directly.
// Instead it uses the factorization:
//
// if p mod 6 == 1:
//   ( p * p - 1 ) / 12 = ( ( p - 1 ) / 6 ) * ( ( p + 1 ) / 2 )
//
// if p mod 6 == 5:
//   ( p * p - 1 ) / 12 = ( ( p - 1 ) / 2 ) * ( ( p + 1 ) / 6 )
//
// Special case:
//   p == 3 gives exactly 2 ordered grids
//
// The running total is stored as a small base-10000 big integer.

#DEFINE LIMIT_P   1000000
#DEFINE BIG_BASE  10000
#DEFINE BIG_LIMBS 6

INTEGER gSum0GI = 0
INTEGER gSum1GI = 0
INTEGER gSum2GI = 0
INTEGER gSum3GI = 0
INTEGER gSum4GI = 0
INTEGER gSum5GI = 0

PROC PROCBigClear()
  gSum0GI = 0
  gSum1GI = 0
  gSum2GI = 0
  gSum3GI = 0
  gSum4GI = 0
  gSum5GI = 0
END

PROC PROCBigAddSmall( INTEGER addI )
  INTEGER carryI = 0
  gSum0GI = gSum0GI + addI
  carryI = gSum0GI / BIG_BASE
  gSum0GI = gSum0GI mod BIG_BASE
  gSum1GI = gSum1GI + carryI
  carryI = gSum1GI / BIG_BASE
  gSum1GI = gSum1GI mod BIG_BASE
  gSum2GI = gSum2GI + carryI
  carryI = gSum2GI / BIG_BASE
  gSum2GI = gSum2GI mod BIG_BASE
  gSum3GI = gSum3GI + carryI
  carryI = gSum3GI / BIG_BASE
  gSum3GI = gSum3GI mod BIG_BASE
  gSum4GI = gSum4GI + carryI
  carryI = gSum4GI / BIG_BASE
  gSum4GI = gSum4GI mod BIG_BASE
  gSum5GI = gSum5GI + carryI
  gSum5GI = gSum5GI mod BIG_BASE
END

PROC PROCBigAddProduct( INTEGER firstFactorI, INTEGER secondFactorI )
  INTEGER firstLowI  = 0
  INTEGER firstHighI = 0
  INTEGER secondLowI  = 0
  INTEGER secondHighI = 0
  INTEGER part0I = 0
  INTEGER part1I = 0
  INTEGER part2I = 0
  INTEGER part3I = 0
  INTEGER carryI = 0
  firstLowI   = firstFactorI mod BIG_BASE
  firstHighI  = firstFactorI / BIG_BASE
  secondLowI  = secondFactorI mod BIG_BASE
  secondHighI = secondFactorI / BIG_BASE
  part0I = firstLowI * secondLowI
  carryI = part0I / BIG_BASE
  part0I = part0I mod BIG_BASE
  part1I = firstLowI * secondHighI + firstHighI * secondLowI + carryI
  carryI = part1I / BIG_BASE
  part1I = part1I mod BIG_BASE
  part2I = firstHighI * secondHighI + carryI
  carryI = part2I / BIG_BASE
  part2I = part2I mod BIG_BASE
  part3I = carryI
  gSum0GI = gSum0GI + part0I
  carryI = gSum0GI / BIG_BASE
  gSum0GI = gSum0GI mod BIG_BASE
  gSum1GI = gSum1GI + part1I + carryI
  carryI = gSum1GI / BIG_BASE
  gSum1GI = gSum1GI mod BIG_BASE
  gSum2GI = gSum2GI + part2I + carryI
  carryI = gSum2GI / BIG_BASE
  gSum2GI = gSum2GI mod BIG_BASE
  gSum3GI = gSum3GI + part3I + carryI
  carryI = gSum3GI / BIG_BASE
  gSum3GI = gSum3GI mod BIG_BASE
  gSum4GI = gSum4GI + carryI
  carryI = gSum4GI / BIG_BASE
  gSum4GI = gSum4GI mod BIG_BASE
  gSum5GI = gSum5GI + carryI
  gSum5GI = gSum5GI mod BIG_BASE
END

STRING PROC FNBigToStringS()
  STRING answerS[255] = ""
  IF gSum5GI > 0
    answerS = Format( gSum5GI ) + Format( gSum4GI : 4 : "0" ) + Format( gSum3GI : 4 : "0" ) + Format( gSum2GI : 4 : "0" ) + Format( gSum1GI : 4 : "0" ) + Format( gSum0GI : 4 : "0" )
  ELSE
    IF gSum4GI > 0
      answerS = Format( gSum4GI ) + Format( gSum3GI : 4 : "0" ) + Format( gSum2GI : 4 : "0" ) + Format( gSum1GI : 4 : "0" ) + Format( gSum0GI : 4 : "0" )
    ELSE
      IF gSum3GI > 0
        answerS = Format( gSum3GI ) + Format( gSum2GI : 4 : "0" ) + Format( gSum1GI : 4 : "0" ) + Format( gSum0GI : 4 : "0" )
      ELSE
        IF gSum2GI > 0
          answerS = Format( gSum2GI ) + Format( gSum1GI : 4 : "0" ) + Format( gSum0GI : 4 : "0" )
        ELSE
          IF gSum1GI > 0
            answerS = Format( gSum1GI ) + Format( gSum0GI : 4 : "0" )
          ELSE
            answerS = Format( gSum0GI )
          ENDIF
        ENDIF
      ENDIF
    ENDIF
  ENDIF
  RETURN( answerS )
END

PROC PROCBuildSieve( INTEGER limitI, INTEGER sieveBufferI )
  INTEGER oddCountI  = 0
  INTEGER maxFactorI = 0
  INTEGER lineI      = 0
  INTEGER factorI    = 0
  INTEGER markI      = 0
  PushLocation()
  GotoBufferId( sieveBufferI )
  oddCountI = ( limitI + 1 ) / 2
  BegFile()
  KillToEol()
  InsertText( "0" )
  FOR lineI = 2 TO oddCountI
    AddLine( "1", sieveBufferI )
  ENDFOR
  maxFactorI = 1
  WHILE ( maxFactorI + 1 ) * ( maxFactorI + 1 ) < limitI
    maxFactorI = maxFactorI + 1
  ENDWHILE
  IF maxFactorI mod 2 == 0
    maxFactorI = maxFactorI - 1
  ENDIF
  FOR factorI = 3 TO maxFactorI BY 2
    lineI = ( factorI + 1 ) / 2
    GotoLine( lineI )
    IF GetText( 1, 1 ) == "1"
      FOR markI = factorI * factorI TO limitI - 1 BY factorI * 2
        lineI = ( markI + 1 ) / 2
        GotoLine( lineI )
        BegLine()
        KillToEol()
        InsertText( "0" )
      ENDFOR
    ENDIF
  ENDFOR
  PopLocation()
END

PROC Main()
  INTEGER sieveBufferI  = 0
  INTEGER pI            = 0
  INTEGER lineI         = 0
  INTEGER firstFactorI  = 0
  INTEGER secondFactorI = 0
  STRING answerS[255]   = ""
  PROCBigClear()
  sieveBufferI = CreateTempBuffer()
  PROCBuildSieve( LIMIT_P, sieveBufferI )
  PushLocation()
  GotoBufferId( sieveBufferI )
  FOR pI = 3 TO LIMIT_P - 1 BY 2
    lineI = ( pI + 1 ) / 2
    GotoLine( lineI )
    IF GetText( 1, 1 ) == "1"
      IF pI == 3
        PROCBigAddSmall( 2 )
      ELSE
        IF pI mod 6 == 1
          firstFactorI  = ( pI - 1 ) / 6
          secondFactorI = ( pI + 1 ) / 2
        ELSE
          firstFactorI  = ( pI - 1 ) / 2
          secondFactorI = ( pI + 1 ) / 6
        ENDIF
        PROCBigAddProduct( firstFactorI, secondFactorI )
      ENDIF
    ENDIF
  ENDFOR
  PopLocation()
  answerS = FNBigToStringS()
  CopyToWinClip( answerS )
  Warn( answerS )
  CopyToWinClip( answerS )
END
