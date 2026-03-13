// TSE/32
//
// collatz14.s
//
// Project Euler Problem 14
// Longest Collatz Sequence
//
// Result:
//   Starting number under one million with the longest chain: 837799
//   Number of terms in that chain: 525
//
// Note:
//   TSE is 32 bits, but Collatz values for starts below one million can
//   rise above 32-bit signed integer range.
//   Therefore this program uses a two-part integer:
//     value = hi * BIGBASE + lo
//
// Version 1.0

integer BIGBASEGI    = 100000000
integer currentHiGI  = 0
integer currentLoGI  = 0

forward proc    SetBigFromInteger(integer nI)
forward integer proc BigIsOne()
forward integer proc BigIsEven()
forward proc    BigDiv2()
forward proc    BigMul3Add1()

PROC Main()
    integer startI     = 0
    integer chainLenI  = 0
    integer bestStartI = 1
    integer bestLenI   = 1

    bestStartI = 1
    bestLenI   = 1

    for startI = 1 to 999999
        SetBigFromInteger(startI)
        chainLenI = 1

        while not BigIsOne()
            if BigIsEven()
                BigDiv2()
            else
                BigMul3Add1()
            endif
            chainLenI = chainLenI + 1
        endwhile

        if chainLenI > bestLenI
            bestLenI   = chainLenI
            bestStartI = startI
        endif
    endfor

    Warn("Longest Collatz chain under one million starts at"; bestStartI)
    Warn("Number of terms in that chain is"; bestLenI)
END

proc SetBigFromInteger(integer nI)
    currentHiGI = nI / BIGBASEGI
    currentLoGI = nI mod BIGBASEGI
end

integer proc BigIsOne()
    if currentHiGI == 0 and currentLoGI == 1
        return(1)
    endif
    return(0)
end

integer proc BigIsEven()
    if currentLoGI mod 2 == 0
        return(1)
    endif
    return(0)
end

proc BigDiv2()
    integer carryI = 0

    carryI = currentHiGI mod 2
    currentHiGI = currentHiGI / 2

    if carryI == 0
        currentLoGI = currentLoGI / 2
    else
        currentLoGI = (currentLoGI + BIGBASEGI) / 2
    endif
end

proc BigMul3Add1()
    integer carryI = 0

    currentLoGI = currentLoGI * 3 + 1
    carryI = currentLoGI / BIGBASEGI
    currentLoGI = currentLoGI mod BIGBASEGI
    currentHiGI = currentHiGI * 3 + carryI
end
