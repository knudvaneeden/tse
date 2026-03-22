// ===========================================================================
// Project Euler - Problem 157
// Base-10 Diophantine Reciprocal
// ===========================================================================
// Problem:
//   Consider the Diophantine equation 1/a + 1/b = p/10^n
//   with a, b, p, n positive integers and a <= b.
//   How many solutions has this equation for 1 <= n <= 9?
//
// Mathematical approach:
//   Let d = gcd(a,b), a = d*s, b = d*t with gcd(s,t)=1, s <= t.
//   Then p = 10^n*(s+t)/(d*s*t).
//   For p to be a positive integer: d*s*t | 10^n*(s+t).
//   Since gcd(s*t, s+t)=1 when gcd(s,t)=1:
//     => s*t must divide 10^n
//     => d must divide (10^n/(s*t)) * (s+t)
//   Number of valid d = number of divisors of Q = (10^n/(s*t)) * (s+t).
//   So for each n: sum over all (s,t) pairs with s<=t, gcd(s,t)=1, s*t|10^n
//   of NumDivisors(Q).
//
// For each n: enumerate all divisors of 10^n = 2^n * 5^n (as pairs (a2,a5)),
// then enumerate pairs (s,t) from this set with s<=t, gcd(s,t)=1.
//
// Version: 1.0.0.0.1
// History:
//   1.0.0.0.1 - 2026-03-22 - Claude Sonnet 4.6 (Anthropic) - Initial version
// ===========================================================================
//
// -----------------------------------------------------------------------
// GcdI: compute GCD of two integers using Euclidean algorithm
// -----------------------------------------------------------------------
integer proc GcdI( integer aI, integer bI )
    integer tmpI    = 0
    //
    while bI <> 0
        tmpI = bI
        bI   = aI mod bI
        aI   = tmpI
    endwhile
    return( aI )
end

// -----------------------------------------------------------------------
// NumDivisorsI: count number of positive divisors of n (n >= 1)
// Uses trial division; max trial factor sqrt(2e9) ~ 44721
// -----------------------------------------------------------------------
integer proc NumDivisorsI( integer nI )
    integer resultI = 1
    integer fI      = 2
    integer expI    = 0
    //
    if nI <= 1
        return( 1 )
    endif
    //
    // Trial divide by 2
    expI = 0
    while ( nI mod 2 ) == 0
        expI = expI + 1
        nI   = nI / 2
    endwhile
    if expI > 0
        resultI = resultI * ( expI + 1 )
    endif
    //
    // Trial divide by odd numbers from 3
    fI = 3
    while ( fI * fI ) <= nI
        expI = 0
        while ( nI mod fI ) == 0
            expI = expI + 1
            nI   = nI / fI
        endwhile
        if expI > 0
            resultI = resultI * ( expI + 1 )
        endif
        fI = fI + 2
    endwhile
    //
    // Remaining prime factor
    if nI > 1
        resultI = resultI * 2
    endif
    //
    return( resultI )
end

// -----------------------------------------------------------------------
// Main
// -----------------------------------------------------------------------
proc Main()
    integer nI       = 0    // exponent n (1..9)
    integer pow10I   = 0    // 10^n
    integer a2I      = 0    // exponent of 2 in s
    integer a5I      = 0    // exponent of 5 in s
    integer b2I      = 0    // exponent of 2 in t
    integer b5I      = 0    // exponent of 5 in t
    integer sI       = 0    // first element of pair
    integer tI       = 0    // second element of pair
    integer stI      = 0    // product s*t
    integer sumI     = 0    // running sum per n
    integer totalI   = 0    // grand total
    integer qI       = 0    // Q = (10^n/(s*t)) * (s+t)
    string  resS[20] = ""   // result string
    //
    totalI = 0
    //
    for nI = 1 to 9
        //
        // Compute pow10I = 10^n
        pow10I = 1
        do nI times
            pow10I = pow10I * 10
        enddo
        //
        sumI = 0
        //
        // Enumerate all pairs (s,t) with s<=t, gcd(s,t)=1, s*t | 10^n.
        // Since 10^n = 2^n * 5^n, s must be of form 2^a2 * 5^a5
        // and t of form 2^b2 * 5^b5, with gcd(s,t)=1.
        // gcd(s,t)=1 with both being {2,5}-smooth means:
        //   not (a2>0 and b2>0), and not (a5>0 and b5>0).
        // So s can have 2's OR 5's (or neither), t similarly,
        // but they cannot share a common prime.
        //
        // We enumerate:
        //   a2 in 0..n, a5 in 0..n, b2 in 0..n, b5 in 0..n
        //   with (a2==0 or b2==0) and (a5==0 or b5==0)
        //   and s*t | 10^n: since s=2^a2*5^a5 and t=2^b2*5^b5
        //     s*t = 2^(a2+b2)*5^(a5+b5) | 2^n*5^n
        //     so (a2+b2)<=n and (a5+b5)<=n
        //   and s <= t
        //
        for a2I = 0 to nI
            for a5I = 0 to nI
                for b2I = 0 to nI
                    for b5I = 0 to nI
                        // gcd(s,t)=1 condition: no shared primes
                        if ( a2I > 0 ) and ( b2I > 0 )
                            // skip: share prime 2
                        elseif ( a5I > 0 ) and ( b5I > 0 )
                            // skip: share prime 5
                        elseif ( a2I + b2I ) > nI
                            // s*t exceeds 2^n part
                        elseif ( a5I + b5I ) > nI
                            // s*t exceeds 5^n part
                        else
                            // Compute s and t
                            sI = 1
                            do a2I times
                                sI = sI * 2
                            enddo
                            do a5I times
                                sI = sI * 5
                            enddo
                            tI = 1
                            do b2I times
                                tI = tI * 2
                            enddo
                            do b5I times
                                tI = tI * 5
                            enddo
                            //
                            // Only process s <= t (avoid double-counting)
                            if sI <= tI
                                stI = sI * tI
                                qI  = ( pow10I / stI ) * ( sI + tI )
                                sumI = sumI + NumDivisorsI( qI )
                            endif
                        endif
                    endfor
                endfor
            endfor
        endfor
        //
        totalI = totalI + sumI
    endfor
    //
    resS = Str( totalI )
    //
    CopyToWinClip( resS )
    Warn( "Project Euler Problem 157" + Chr(13) +
          "Base-10 Diophantine Reciprocal" + Chr(13) +
          Chr(13) +
          "Total solutions for 1<=n<=9:" + Chr(13) +
          resS )
    CopyToWinClip( resS )
end
