integer proc DivisorCount( integer valueI )

    integer countI
    integer primeI
    integer exponentI
    integer remainderI

    IF valueI <= 1
        RETURN( 1 )
    ENDIF

    countI     = 1
    remainderI = valueI

    exponentI = 0
    WHILE ( remainderI mod 2 ) == 0
        remainderI = remainderI / 2
        exponentI  = exponentI + 1
    ENDWHILE
    IF exponentI > 0
        countI = countI * ( exponentI + 1 )
    ENDIF

    primeI = 3
    WHILE ( primeI * primeI ) <= remainderI

        exponentI = 0
        WHILE ( remainderI mod primeI ) == 0
            remainderI = remainderI / primeI
            exponentI  = exponentI + 1
        ENDWHILE

        IF exponentI > 0
            countI = countI * ( exponentI + 1 )
        ENDIF

        primeI = primeI + 2
    ENDWHILE

    IF remainderI > 1
        countI = countI * 2
    ENDIF

    RETURN( countI )

end

integer proc TriangleDivisorCount( integer nI )

    integer part1I
    integer part2I

    IF ( nI mod 2 ) == 0
        part1I = nI / 2
        part2I = nI + 1
    ELSE
        part1I = nI
        part2I = ( nI + 1 ) / 2
    ENDIF

    RETURN( DivisorCount( part1I ) * DivisorCount( part2I ) )

end

integer proc TriangleNumber( integer nI )
    RETURN( ( nI * ( nI + 1 ) ) / 2 )
end

PROC Main()

    integer nI
    integer triangleI
    integer divisorCountI

    nI = 1

    WHILE TRUE
        divisorCountI = TriangleDivisorCount( nI )

        IF divisorCountI > 500
            triangleI = TriangleNumber( nI )
            Warn( "First triangle number with over 500 divisors:" )
            Warn( triangleI )
            Warn( "Number of divisors:" )
            Warn( divisorCountI )
            BREAK
        ENDIF

        nI = nI + 1
    ENDWHILE

END


