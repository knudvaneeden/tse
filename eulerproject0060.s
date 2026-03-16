// TSE/32
//
// Macro     eulerproject060.s
// Author    ChatGPT
// Date      16 March 2026
// Version   1.2
//
// Purpose:
//   Solve Project Euler problem 60 in The Semware Editor Professional SAL.
//
// Problem:
//   Find the lowest sum for a set of five primes for which any two primes
//   concatenate in any order to produce another prime.
//
// Notes:
//   - TSE is 32-bit.
//   - No SAL arrays are used.
//   - Temporary buffers are used to hold filtered prime candidates.
//   - Concatenations for the known minimal solution stay within 32-bit.
//
// Expected answer:
//   26033


integer proc Digits( integer n )
    integer d = 0
    if n <= 0
        return( 1 )
    endif
    while n > 0
        n = n / 10
        d = d + 1
    endwhile
    return( d )
end


integer proc Pow10( integer d )
    integer p = 1
    while d > 0
        p = p * 10
        d = d - 1
    endwhile
    return( p )
end


integer proc Concat2( integer a, integer b )
    return( a * Pow10( Digits( b ) ) + b )
end


integer proc IsPrimeFast( integer n )
    integer d

    if n < 2
        return( FALSE )
    endif

    if n == 2
        return( TRUE )
    endif

    if ( n mod 2 ) == 0
        return( FALSE )
    endif

    if n == 3
        return( TRUE )
    endif

    if ( n mod 3 ) == 0
        return( FALSE )
    endif

    d = 5
    while d * d <= n
        if ( n mod d ) == 0
            return( FALSE )
        endif
        if ( n mod ( d + 2 ) ) == 0
            return( FALSE )
        endif
        d = d + 6
    endwhile

    return( TRUE )
end


integer proc PairWorks( integer p1, integer p2 )
    integer c1
    integer c2

    if p1 == p2
        return( FALSE )
    endif

    if p1 <> 3
        if p2 <> 3
            if ( ( p1 + p2 ) mod 3 ) == 0
                return( FALSE )
            endif
        endif
    endif

    c1 = Concat2( p1, p2 )
    if not IsPrimeFast( c1 )
        return( FALSE )
    endif

    c2 = Concat2( p2, p1 )
    if not IsPrimeFast( c2 )
        return( FALSE )
    endif

    return( TRUE )
end


integer proc CurrLineInt()
    return( Val( GetText( 1, CurrLineLen() ) ) )
end


integer proc GotoBufferLine( integer bufferId, integer lineNo )
    integer i = 1

    GotoBufferId( bufferId )

    if NumLines() < 1
        return( FALSE )
    endif

    BegFile()

    while i < lineNo
        if not Down()
            return( FALSE )
        endif
        i = i + 1
    endwhile

    return( TRUE )
end


integer proc BuildPrimeBuffer( integer maxPrime )
    integer b
    integer n

    b = CreateTempBuffer()
    if b < 0
        Warn( "Could not create prime buffer" )
        return( -1 )
    endif

    GotoBufferId( b )
    EmptyBuffer()

    n = 3
    while n <= maxPrime
        if n <> 5
            if IsPrimeFast( n )
                AddLine( Str( n ) )
            endif
        endif
        n = n + 2
    endwhile

    BegFile()
    return( b )
end


integer proc BuildCompatibleBuffer( integer sourceB, integer startLine, integer fixedP )
    integer outB
    integer p
    integer i = 1

    outB = CreateTempBuffer()
    if outB < 0
        Warn( "Could not create temp buffer" )
        return( -1 )
    endif

    GotoBufferId( outB )
    EmptyBuffer()

    GotoBufferId( sourceB )
    if NumLines() < 1
        GotoBufferId( outB )
        return( outB )
    endif

    BegFile()

    while i < startLine
        if not Down()
            GotoBufferId( outB )
            return( outB )
        endif
        i = i + 1
    endwhile

    repeat
        p = CurrLineInt()
        if PairWorks( p, fixedP )
            GotoBufferId( outB )
            AddLine( Str( p ) )
            GotoBufferId( sourceB )
        endif
    until not Down()

    GotoBufferId( outB )
    if NumLines() > 0
        BegFile()
    endif
    return( outB )
end


proc KillIfValid( integer b )
    if b >= 0
        GotoBufferId( b )
        AbandonFile()
    endif
end


PROC Main()
    integer primeB = -1
    integer b1 = -1
    integer b2 = -1
    integer b3 = -1
    integer b4 = -1

    integer maxPrime = 10000

    integer line1
    integer line2
    integer line3
    integer line4

    integer p1
    integer p2
    integer p3
    integer p4
    integer p5

    integer sum5
    integer bestSum = 2147483647
    string bestSet[100] = ""

    primeB = BuildPrimeBuffer( maxPrime )
    if primeB < 0
        return()
    endif

    GotoBufferId( primeB )
    if NumLines() > 0
        BegFile()

        repeat
            line1 = CurrLine()
            p1 = CurrLineInt()

            if ( p1 * 5 ) < bestSum

                b1 = BuildCompatibleBuffer( primeB, line1 + 1, p1 )
                if b1 >= 0
                    GotoBufferId( b1 )

                    if NumLines() >= 4
                        BegFile()

                        repeat
                            line2 = CurrLine()
                            p2 = CurrLineInt()

                            if ( p1 + p2 * 4 ) < bestSum

                                b2 = BuildCompatibleBuffer( b1, line2 + 1, p2 )
                                if b2 >= 0
                                    GotoBufferId( b2 )

                                    if NumLines() >= 3
                                        BegFile()

                                        repeat
                                            line3 = CurrLine()
                                            p3 = CurrLineInt()

                                            if ( p1 + p2 + p3 * 3 ) < bestSum

                                                b3 = BuildCompatibleBuffer( b2, line3 + 1, p3 )
                                                if b3 >= 0
                                                    GotoBufferId( b3 )

                                                    if NumLines() >= 2
                                                        BegFile()

                                                        repeat
                                                            line4 = CurrLine()
                                                            p4 = CurrLineInt()

                                                            if ( p1 + p2 + p3 + p4 * 2 ) < bestSum

                                                                b4 = BuildCompatibleBuffer( b3, line4 + 1, p4 )
                                                                if b4 >= 0
                                                                    GotoBufferId( b4 )

                                                                    if NumLines() >= 1
                                                                        BegFile()

                                                                        repeat
                                                                            p5 = CurrLineInt()
                                                                            sum5 = p1 + p2 + p3 + p4 + p5

                                                                            if sum5 < bestSum
                                                                                bestSum = sum5
                                                                                bestSet =
                                                                                    Str( p1 ) + ", " +
                                                                                    Str( p2 ) + ", " +
                                                                                    Str( p3 ) + ", " +
                                                                                    Str( p4 ) + ", " +
                                                                                    Str( p5 )
                                                                            endif
                                                                        until not Down()
                                                                    endif

                                                                    KillIfValid( b4 )
                                                                    b4 = -1
                                                                endif
                                                            endif

                                                            GotoBufferLine( b3, line4 )
                                                        until not Down()
                                                    endif

                                                    KillIfValid( b3 )
                                                    b3 = -1
                                                endif
                                            endif

                                            GotoBufferLine( b2, line3 )
                                        until not Down()
                                    endif

                                    KillIfValid( b2 )
                                    b2 = -1
                                endif
                            endif

                            GotoBufferLine( b1, line2 )
                        until not Down()
                    endif

                    KillIfValid( b1 )
                    b1 = -1
                endif
            endif

            GotoBufferLine( primeB, line1 )
        until not Down()
    endif

    GotoBufferId( primeB )

    if bestSum < 2147483647
        Warn(
            "Project Euler 60 solved." + Chr( 13 ) +
            "Best set = " + bestSet + Chr( 13 ) +
            "Lowest sum = " + Str( bestSum )
        )
    else
        Warn(
            "No solution found up to maxPrime = " + Str( maxPrime ) + Chr( 13 ) +
            "Try increasing maxPrime."
        )
    endif

    KillIfValid( primeB )
END
