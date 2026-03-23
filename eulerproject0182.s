/*
 *  Project Euler 182
 *  RSA Encryption
 *
 *  Pure TSE SAL solution
 *
 *  Calculated result for Project Euler 182:
 *  399788195976
 *
 *  <version>1.0.0.0.0</version>
 *
 *  History:
 *  1.0.0.0.0  2026-03-24
 *             Created by GPT-5.4 Thinking
 *             Pure TSE SAL implementation.
 *             Fully calculates the answer.
 *             Uses only one final Warn() box.
 *             Uses two CopyToWinClip() calls: before and after Warn().
 */

#define P_VALUE          1009
#define Q_VALUE          3643
#define PHI_VALUE        3671136
#define CHUNK_BASE       1000000

integer gSumHighI = 0
integer gSumLowI  = 0

integer proc ProcGcd( integer aI, integer bI )
 integer tempI = 0
 while aI <> 0
  tempI = aI
  aI    = bI mod aI
  bI    = tempI
 endwhile
 Return( bI )
end

proc ProcResetLargeSum()
 gSumHighI = 0
 gSumLowI  = 0
end

proc ProcAddToLargeSum( integer addI )
 integer carryI = 0
 gSumLowI = gSumLowI + addI
 if gSumLowI >= CHUNK_BASE
  carryI   = gSumLowI / CHUNK_BASE
  gSumLowI = gSumLowI mod CHUNK_BASE
  gSumHighI = gSumHighI + carryI
 endif
end

string proc ProcLargeSumToString()
 string resultS[255] = ""
 if gSumHighI == 0
  resultS = Format( gSumLowI )
 else
  resultS = Format( gSumHighI ) + Format( gSumLowI:6:"0" )
 endif
 Return( resultS )
end

proc ProcMainCalculation()
 integer eI                = 0
 integer gcdPhiI           = 0
 integer gcdPI             = 0
 integer gcdQI             = 0
 integer unconcealedI      = 0
 integer bestUnconcealedI  = 2147483647
 //
 ProcResetLargeSum()
 for eI = 2 to PHI_VALUE - 1
  gcdPhiI = ProcGcd( eI, PHI_VALUE )
  if gcdPhiI == 1
   gcdPI = ProcGcd( eI - 1, P_VALUE - 1 )
   gcdQI = ProcGcd( eI - 1, Q_VALUE - 1 )
   unconcealedI = ( gcdPI + 1 ) * ( gcdQI + 1 )
   if unconcealedI < bestUnconcealedI
    bestUnconcealedI = unconcealedI
    ProcResetLargeSum()
    ProcAddToLargeSum( eI )
   else
    if unconcealedI == bestUnconcealedI
     ProcAddToLargeSum( eI )
    endif
   endif
  endif
 endfor
end

PROC Main()
 string resultS[255] = ""
 //
 ProcMainCalculation()
 resultS = ProcLargeSumToString()
 CopyToWinClip( resultS )
 Warn( resultS )
 CopyToWinClip( resultS )
END
