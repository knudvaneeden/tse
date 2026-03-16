// TSE/32
//
// EULERPROJECT0061.S
//
// Project Euler Problem 61
// Cyclical Figurate Numbers
//
// Find the sum of the only ordered set of six cyclic 4-digit numbers
// for which each polygonal type 3..8 occurs exactly once.
//
// Expected answer: 28684
//
// Notes:
// - Uses one temp buffer per polygonal type
// - Uses recursion with PushLocation()/PopLocation()
// - Anchors on octagonal numbers first to reduce branching

integer g_bid3
integer g_bid4
integer g_bid5
integer g_bid6
integer g_bid7
integer g_bid8

integer g_found
integer g_answer

integer g_chain0
integer g_chain1
integer g_chain2
integer g_chain3
integer g_chain4
integer g_chain5

integer g_usedMask


integer proc BidForType( integer t )
    if t == 3
        return( g_bid3 )
    endif
    if t == 4
        return( g_bid4 )
    endif
    if t == 5
        return( g_bid5 )
    endif
    if t == 6
        return( g_bid6 )
    endif
    if t == 7
        return( g_bid7 )
    endif
    return( g_bid8 )
end

integer proc BitForType( integer t )
    return( 1 shl ( t - 3 ) )
end

integer proc First2( integer v )
    return( v / 100 )
end

integer proc Last2( integer v )
    return( v mod 100 )
end

proc SetChain( integer depth, integer valueI )
    if depth == 0
        g_chain0 = valueI
    endif
    if depth == 1
        g_chain1 = valueI
    endif
    if depth == 2
        g_chain2 = valueI
    endif
    if depth == 3
        g_chain3 = valueI
    endif
    if depth == 4
        g_chain4 = valueI
    endif
    if depth == 5
        g_chain5 = valueI
    endif
end

proc GenPolygon( integer t, integer bid )
    integer nI
    integer vI
    integer loI

    GotoBufferId( bid )
    EmptyBuffer()

    nI = 1
    while TRUE
        if t == 3
            vI = nI * ( nI + 1 ) / 2
        elseif t == 4
            vI = nI * nI
        elseif t == 5
            vI = nI * ( 3 * nI - 1 ) / 2
        elseif t == 6
            vI = nI * ( 2 * nI - 1 )
        elseif t == 7
            vI = nI * ( 5 * nI - 3 ) / 2
        else
            vI = nI * ( 3 * nI - 2 )
        endif

        if vI > 9999
            break
        endif

        if vI >= 1000
            loI = vI mod 100
            if loI >= 10
                AddLine( Trim( Str( vI ) ) )
            endif
        endif

        nI = nI + 1
    endwhile
end

proc TryExtend( integer depth, integer tailLast2 )
    integer tI
    integer bidI
    integer nLinesI
    integer curLineI
    integer candidateI
    integer saveMaskI

    if g_found
        return()
    endif

    if depth == 6
        if Last2( g_chain5 ) == First2( g_chain0 )
            g_found = TRUE
            g_answer = g_chain0 + g_chain1 + g_chain2
            g_answer = g_answer + g_chain3 + g_chain4 + g_chain5
        endif
        return()
    endif

    tI = 3
    while tI <= 8
        if g_found
            break
        endif

        if ( g_usedMask & BitForType( tI ) ) == 0
            bidI = BidForType( tI )

            PushLocation()
            GotoBufferId( bidI )

            nLinesI = NumLines()
            BegFile()
            curLineI = 1

            while curLineI <= nLinesI
                if g_found
                    break
                endif

                candidateI = Val( GetText( 1, CurrLineLen() ) )

                if First2( candidateI ) == tailLast2
                    SetChain( depth, candidateI )

                    saveMaskI = g_usedMask
                    g_usedMask = g_usedMask | BitForType( tI )

                    TryExtend( depth + 1, Last2( candidateI ) )

                    g_usedMask = saveMaskI
                endif

                if curLineI < nLinesI
                    Down()
                endif
                curLineI = curLineI + 1
            endwhile

            PopLocation()
        endif

        tI = tI + 1
    endwhile
end

proc ShowResult()
    string resultS[255]
    integer clipBidI

    if g_found
        resultS = 'P61 Cyclical Figurate Numbers' + Chr( 13 )
        resultS = resultS + 'Chain: '
        resultS = resultS + Trim( Str( g_chain0 ) ) + ', '
        resultS = resultS + Trim( Str( g_chain1 ) ) + ', '
        resultS = resultS + Trim( Str( g_chain2 ) ) + ', '
        resultS = resultS + Trim( Str( g_chain3 ) ) + ', '
        resultS = resultS + Trim( Str( g_chain4 ) ) + ', '
        resultS = resultS + Trim( Str( g_chain5 ) )
        resultS = resultS + Chr( 13 ) + 'Sum = ' + Trim( Str( g_answer ) )

        Warn( resultS )

        clipBidI = CreateTempBuffer()
        GotoBufferId( clipBidI )
        InsertText( Trim( Str( g_answer ) ) )
        MarkLine( 1, 1 )
        CopyToWinClip()
        AbandonFile( clipBidI )
    else
        Warn( 'P61: No solution found.' )
    endif
end

proc Main()
    integer nOctI
    integer curLineI
    integer startNumI

    g_bid3 = CreateTempBuffer()
    g_bid4 = CreateTempBuffer()
    g_bid5 = CreateTempBuffer()
    g_bid6 = CreateTempBuffer()
    g_bid7 = CreateTempBuffer()
    g_bid8 = CreateTempBuffer()

    GenPolygon( 3, g_bid3 )
    GenPolygon( 4, g_bid4 )
    GenPolygon( 5, g_bid5 )
    GenPolygon( 6, g_bid6 )
    GenPolygon( 7, g_bid7 )
    GenPolygon( 8, g_bid8 )

    g_found = FALSE
    g_answer = 0

    GotoBufferId( g_bid8 )
    nOctI = NumLines()
    BegFile()
    curLineI = 1

    while curLineI <= nOctI
        if g_found
            break
        endif

        startNumI = Val( GetText( 1, CurrLineLen() ) )
        g_chain0 = startNumI
        g_usedMask = BitForType( 8 )

        TryExtend( 1, Last2( startNumI ) )

        if curLineI < nOctI
            Down()
        endif
        curLineI = curLineI + 1
    endwhile

    ShowResult()

    AbandonFile( g_bid3 )
    AbandonFile( g_bid4 )
    AbandonFile( g_bid5 )
    AbandonFile( g_bid6 )
    AbandonFile( g_bid7 )
    AbandonFile( g_bid8 )
end
