/*
    eulerproject0120.s
    Project Euler Problem 120
    Version 1.0

    Finds:
      sum of r_max for 3 <= a <= 1000

    Mathematical result:
      For odd n,
        (a - 1)^n + (a + 1)^n mod a^2 = 2*a*n mod a^2

      Therefore:
        r_max = 2 * a * floor( (a - 1) / 2 )

      Equivalent closed forms:
        if a is odd  -> r_max = a * (a - 1)
        if a is even -> r_max = a * (a - 2)

    History:
      1.0  2026-03-19  Created by GPT-5.4 Thinking
*/

integer proc MaxRemainder( integer aI )
    if ( aI mod 2 ) == 0
        Return( aI * ( aI - 2 ) )
    else
        Return( aI * ( aI - 1 ) )
    endif
end

proc Main()
    integer aI
    integer totalI
    string resultS[40]

    totalI = 0

    for aI = 3 to 1000
        totalI = totalI + MaxRemainder( aI )
    endfor

    resultS = Str( totalI )
    CopyToWinClip( resultS )
    Warn( "Project Euler 120 answer: " + resultS )
end
