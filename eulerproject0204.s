/*
 Euler Project 204
 Generalised Hamming Numbers
 Pure TSE SAL solution
 <version>1.0.0.0.1</version>
 History:
 1.0.0.0.1 - Created by ChatGPT GPT-5.4 Thinking
*/
integer proc procPrimeCount()
 integer primeCountI = 25
 Return( primeCountI )
end
//
integer proc procPrimeByIndex( integer indexI )
 integer primeI = 0
 CASE indexI
  WHEN 1
   primeI = 2
  WHEN 2
   primeI = 3
  WHEN 3
   primeI = 5
  WHEN 4
   primeI = 7
  WHEN 5
   primeI = 11
  WHEN 6
   primeI = 13
  WHEN 7
   primeI = 17
  WHEN 8
   primeI = 19
  WHEN 9
   primeI = 23
  WHEN 10
   primeI = 29
  WHEN 11
   primeI = 31
  WHEN 12
   primeI = 37
  WHEN 13
   primeI = 41
  WHEN 14
   primeI = 43
  WHEN 15
   primeI = 47
  WHEN 16
   primeI = 53
  WHEN 17
   primeI = 59
  WHEN 18
   primeI = 61
  WHEN 19
   primeI = 67
  WHEN 20
   primeI = 71
  WHEN 21
   primeI = 73
  WHEN 22
   primeI = 79
  WHEN 23
   primeI = 83
  WHEN 24
   primeI = 89
  WHEN 25
   primeI = 97
  OTHERWISE
   primeI = 0
 ENDCASE
 Return( primeI )
end
//
integer proc procCountHamming( integer indexI, integer currentNumberI, integer limitI )
 integer totalCountI = 0
 integer primeI      = 0
 integer nextNumberI = 0
 if indexI > procPrimeCount()
  Return( 1 )
 endif
 primeI = procPrimeByIndex( indexI )
 nextNumberI = currentNumberI
 while nextNumberI <= limitI
  totalCountI = totalCountI + procCountHamming( indexI + 1, nextNumberI, limitI )
  if nextNumberI > ( limitI / primeI )
   break
  endif
  nextNumberI = nextNumberI * primeI
 endwhile
 Return( totalCountI )
end
//
proc Main()
 integer limitI      = 1000000000
 integer resultI     = 0
 string  resultS[255] = ""
 //
 resultI = procCountHamming( 1, 1, limitI )
 resultS = Str( resultI )
 //
 CopyToWinClip( resultS )
 Warn( resultS )
 CopyToWinClip( resultS )
end
