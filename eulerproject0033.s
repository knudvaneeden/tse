// Project Euler - Problem 33: Digit Cancelling Fractions
//
// The fraction 49/98 is a curious fraction: an inexperienced mathematician
// might cancel the 9s to get 4/8, which happens to be correct.
// Fractions like 30/50 = 3/5 are considered trivial (cancelled digit is 0).
// There are exactly four non-trivial two-digit examples < 1.
// Find the denominator of their product in lowest terms.
//
// Strategy:
//   For a two-digit fraction  (10a + c) / (10c + b)  = a/b  (cancel shared
//   digit c from numerator units and denominator tens position), we check all
//   four positional combinations where one digit of the numerator matches one
//   digit of the denominator, and the "reduced" fraction equals the original.
//
// Version: 1.0

integer proc GCD(integer a, integer b)
    integer r
    while b <> 0
        r = a mod b
        a = b
        b = r
    endwhile
    return( a )
end

proc Main()
    integer numer, denom       // two-digit numerator / denominator
    integer n1, n2             // digits of numerator  (n1=tens, n2=units)
    integer d1, d2             // digits of denominator (d1=tens, d2=units)
    integer rn, rd             // "reduced" numerator / denominator after cancel
    integer prodNumer          // running product numerator
    integer prodDenom          // running product denominator
    integer g                  // GCD for final reduction
    integer found              // count of curious fractions found
    string  resultStr[40]      // result string for display

    prodNumer = 1
    prodDenom = 1
    found     = 0

    for numer = 10 to 99
        for denom = numer + 1 to 99
            n1 = numer / 10       // tens digit of numerator
            n2 = numer mod 10     // units digit of numerator
            d1 = denom / 10       // tens digit of denominator
            d2 = denom mod 10     // units digit of denominator

            rn = 0
            rd = 0

            // Case 1: cancel units of numer with tens  of denom  => n2==d1
            //   fraction becomes n1/d2
            if n2 == d1 and d2 <> 0 and n1 <> 0
                rn = n1
                rd = d2
                if numer * rd == denom * rn
                    prodNumer = prodNumer * numer
                    prodDenom = prodDenom * denom
                    found = found + 1
                endif
            endif

            // Case 2: cancel tens  of numer with units of denom  => n1==d2
            //   fraction becomes n2/d1
            if n1 == d2 and d1 <> 0 and n2 <> 0
                rn = n2
                rd = d1
                if numer * rd == denom * rn
                    prodNumer = prodNumer * numer
                    prodDenom = prodDenom * denom
                    found = found + 1
                endif
            endif

            // Cases 3 and 4 (cancel same-position digits: tens/tens or
            // units/units) are excluded - they match trivial fractions like
            // 11/22, 12/24 etc. which are not the curious cross-cancellations
            // the problem is looking for.

        endfor
    endfor

    g = GCD(prodNumer, prodDenom)
    prodNumer = prodNumer / g
    prodDenom = prodDenom / g

    resultStr = Str(prodDenom)

    Warn("Project Euler #33 | Digit Cancelling Fractions" +
         Chr(13) + "Found " + Str(found) + " curious fractions." +
         Chr(13) + "Product in lowest terms: " +
         Str(prodNumer) + "/" + Str(prodDenom) +
         Chr(13) + "Answer (denominator) = " + resultStr)

    CopyToWinClip(resultStr)
end
