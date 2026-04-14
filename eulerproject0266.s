// ===
// Euler Project Problem 266: Pseudo Square Root
// --- Version 2
// --- Created by: Claude, Anthropic
// ---
// --- Algorithm: Meet-in-the-middle with hi/lo ln precision
// ---   42 primes below 190, split into two halves of 21
// ---   ln(p) stored as (hi,lo) pair = ln(p)*10^13 for 13-digit precision
// ---   Generate 2^21 subsets per half, sort, two-pointer scan
// ---   Compute product mod 10^16 from best bitmasks
// ===
//
// Forward declarations
//
forward proc FnInitPrimesAndLogs()
forward proc FnBuildHalf( integer halfIdxI )
forward proc FnSortBuf( integer bufIdI )
forward proc FnTwoPointerScan()
forward proc FnComputeProduct()
forward integer proc FnGetPrimeI( integer idxI )
forward integer proc FnGetLnHiI( integer idxI )
forward integer proc FnGetLnLoI( integer idxI )
forward proc FnParseSubsetLine( string lineS )
//
// Global variables
//
integer gPrimeBufI = 0
integer gBufAI = 0
integer gBufBI = 0
integer gOrigBufI = 0
integer gHalfI = 21
//
// Total ln sums
//
integer gTotalHiI = 0
integer gTotalLoI = 0
//
// Half ln target
//
integer gHalfHiI = 0
integer gHalfLoI = 0
//
// Best solution found
//
integer gBestHiI = 0
integer gBestLoI = 0
integer gBestMaskAI = 0
integer gBestMaskBI = 0
//
// Parsed subset line fields
//
integer gSubHiI = 0
integer gSubLoI = 0
integer gSubMaskI = 0
//
// Product result limbs (base 10000)
//
integer gR3I = 0
integer gR2I = 0
integer gR1I = 0
integer gR0I = 0
//
// Carry constant
//
integer gModLoI = 10000000
//
// ---------------------------------------------------------------
// FnGetPrimeI: get prime value at 1-based index in gPrimeBufI
// ---------------------------------------------------------------
//
integer proc FnGetPrimeI( integer idxI )
    integer saveBufI = 0
    string rawS[80] = ""
    string tokS[20] = ""
    //
    saveBufI = GetBufferId()
    GotoBufferId( gPrimeBufI )
    GotoLine( idxI )
    rawS = GetText( 1, CurrLineLen() )
    GotoBufferId( saveBufI )
    //
    tokS = GetToken( rawS, " ", 1 )
    return( Val( tokS ) )
end
//
// ---------------------------------------------------------------
// FnGetLnHiI: get lnHi at 1-based index
// ---------------------------------------------------------------
//
integer proc FnGetLnHiI( integer idxI )
    integer saveBufI = 0
    string rawS[80] = ""
    string tokS[20] = ""
    //
    saveBufI = GetBufferId()
    GotoBufferId( gPrimeBufI )
    GotoLine( idxI )
    rawS = GetText( 1, CurrLineLen() )
    GotoBufferId( saveBufI )
    //
    tokS = GetToken( rawS, " ", 2 )
    return( Val( tokS ) )
end
//
// ---------------------------------------------------------------
// FnGetLnLoI: get lnLo at 1-based index
// ---------------------------------------------------------------
//
integer proc FnGetLnLoI( integer idxI )
    integer saveBufI = 0
    string rawS[80] = ""
    string tokS[20] = ""
    //
    saveBufI = GetBufferId()
    GotoBufferId( gPrimeBufI )
    GotoLine( idxI )
    rawS = GetText( 1, CurrLineLen() )
    GotoBufferId( saveBufI )
    //
    tokS = GetToken( rawS, " ", 3 )
    return( Val( tokS ) )
end
//
// ---------------------------------------------------------------
// FnParseSubsetLine: parse "HHHHHHHHHLLLLLLL MMMMMMM"
//   Chars 1-9: sumHi, 10-16: sumLo, 18-24: mask
// ---------------------------------------------------------------
//
proc FnParseSubsetLine( string lineS )
    string partS[20] = ""
    //
    partS = SubStr( lineS, 1, 9 )
    gSubHiI = Val( partS )
    partS = SubStr( lineS, 10, 7 )
    gSubLoI = Val( partS )
    partS = SubStr( lineS, 18, 7 )
    gSubMaskI = Val( partS )
end
//
// ---------------------------------------------------------------
// FnInitPrimesAndLogs
// ---------------------------------------------------------------
//
proc FnInitPrimesAndLogs()
    integer saveBufI = 0
    integer lineI = 0
    integer tmpLoI = 0
    //
    saveBufI = GetBufferId()
    gPrimeBufI = CreateTempBuffer()
    //
    // Format: "prime lnHi lnLo" where ln(p)*10^13 = lnHi*10^7 + lnLo
    //
    AddLine( "2 693147 1805599" )
    AddLine( "3 1098612 2886681" )
    AddLine( "5 1609437 9124341" )
    AddLine( "7 1945910 1490553" )
    AddLine( "11 2397895 2727984" )
    AddLine( "13 2564949 3574615" )
    AddLine( "17 2833213 3440562" )
    AddLine( "19 2944438 9791664" )
    AddLine( "23 3135494 2159291" )
    AddLine( "29 3367295 8299865" )
    AddLine( "31 3433987 2044851" )
    AddLine( "37 3610917 9126442" )
    AddLine( "41 3713572 667043" )
    AddLine( "43 3761200 1156936" )
    AddLine( "47 3850147 6017101" )
    AddLine( "53 3970291 9135521" )
    AddLine( "59 4077537 4439057" )
    AddLine( "61 4110873 8641733" )
    AddLine( "67 4204692 6193910" )
    AddLine( "71 4262679 8770413" )
    AddLine( "73 4290459 4411484" )
    AddLine( "79 4369447 8524670" )
    AddLine( "83 4418840 6077966" )
    AddLine( "89 4488636 3697321" )
    AddLine( "97 4574710 9785034" )
    AddLine( "101 4615120 5168413" )
    AddLine( "103 4634728 9882296" )
    AddLine( "107 4672828 8344619" )
    AddLine( "109 4691347 8822291" )
    AddLine( "113 4727387 8187123" )
    AddLine( "127 4844187 864586" )
    AddLine( "131 4875197 3232012" )
    AddLine( "137 4919980 9258281" )
    AddLine( "139 4934473 9331307" )
    AddLine( "149 5003946 3059455" )
    AddLine( "151 5017279 8368149" )
    AddLine( "157 5056245 8053483" )
    AddLine( "163 5093750 2008068" )
    AddLine( "167 5117993 8124168" )
    AddLine( "173 5153291 5944978" )
    AddLine( "179 5187385 8058408" )
    AddLine( "181 5198497 312658" )
    //
    // Remove initial empty line
    //
    BegFile()
    if CurrLineLen() == 0
        DelLine()
    endif
    //
    // Compute total (hi, lo)
    //
    gTotalHiI = 0
    gTotalLoI = 0
    lineI = 1
    while lineI <= 42
        gTotalLoI = gTotalLoI + FnGetLnLoI( lineI )
        gTotalHiI = gTotalHiI + FnGetLnHiI( lineI )
        //
        // Normalize lo
        //
        if gTotalLoI >= gModLoI
            gTotalHiI = gTotalHiI + ( gTotalLoI / gModLoI )
            gTotalLoI = gTotalLoI mod gModLoI
        endif
        lineI = lineI + 1
    endwhile
    //
    // Compute half (hi, lo) = total / 2
    //
    tmpLoI = gTotalHiI mod 2
    gHalfHiI = gTotalHiI / 2
    gHalfLoI = ( tmpLoI * gModLoI + gTotalLoI ) / 2
    //
    GotoBufferId( saveBufI )
end
//
// ---------------------------------------------------------------
// FnBuildHalf: build 2^21 subset entries for one half
//   Line format: "HHHHHHHHHLLLLLLL MMMMMMM" (24 chars)
//   Chars 1-9: sumHi zero-padded
//   Chars 10-16: sumLo zero-padded
//   Char 17: space
//   Chars 18-24: mask zero-padded
// ---------------------------------------------------------------
//
proc FnBuildHalf( integer halfIdxI )
    integer saveBufI = 0
    integer targetBufI = 0
    integer primeStartI = 0
    integer iI = 0
    integer jI = 0
    integer nCurrI = 0
    string readLineS[40] = ""
    integer curHiI = 0
    integer curLoI = 0
    integer curMaskI = 0
    integer newHiI = 0
    integer newLoI = 0
    integer newMaskI = 0
    integer thisHiI = 0
    integer thisLoI = 0
    string outLineS[40] = ""
    integer bitI = 0
    //
    saveBufI = GetBufferId()
    //
    if halfIdxI == 0
        gBufAI = CreateTempBuffer()
        targetBufI = gBufAI
        primeStartI = 1
    else
        gBufBI = CreateTempBuffer()
        targetBufI = gBufBI
        primeStartI = gHalfI + 1
    endif
    //
    GotoBufferId( targetBufI )
    //
    // Seed: empty subset (hi=0, lo=0, mask=0)
    //
    AddLine( Format( 0:9:"0" ) + Format( 0:7:"0" ) + " " + Format( 0:7:"0" ) )
    //
    BegFile()
    if CurrLineLen() == 0
        DelLine()
    endif
    //
    // For each of 21 primes, double the entries
    //
    iI = 0
    while iI < gHalfI
        //
        thisHiI = FnGetLnHiI( primeStartI + iI )
        thisLoI = FnGetLnLoI( primeStartI + iI )
        bitI = 1 shl iI
        //
        GotoBufferId( targetBufI )
        nCurrI = NumLines()
        //
        jI = 1
        while jI <= nCurrI
            //
            GotoLine( jI )
            readLineS = GetText( 1, CurrLineLen() )
            FnParseSubsetLine( readLineS )
            curHiI = gSubHiI
            curLoI = gSubLoI
            curMaskI = gSubMaskI
            //
            // Add prime's ln to subset sum
            //
            newLoI = curLoI + thisLoI
            newHiI = curHiI + thisHiI
            if newLoI >= gModLoI
                newLoI = newLoI - gModLoI
                newHiI = newHiI + 1
            endif
            newMaskI = curMaskI | bitI
            //
            outLineS = Format( newHiI:9:"0" ) + Format( newLoI:7:"0" ) + " " + Format( newMaskI:7:"0" )
            //
            EndFile()
            AddLine( outLineS )
            //
            jI = jI + 1
        endwhile
        //
        iI = iI + 1
    endwhile
    //
    GotoBufferId( saveBufI )
end
//
// ---------------------------------------------------------------
// FnSortBuf: sort buffer ascending
// ---------------------------------------------------------------
//
proc FnSortBuf( integer bufIdI )
    integer saveBufI = 0
    //
    saveBufI = GetBufferId()
    GotoBufferId( bufIdI )
    BegFile()
    MarkLine()
    EndFile()
    MarkLine()
    ExecMacro( "sort" )
    UnMarkBlock()
    GotoBufferId( saveBufI )
end
//
// ---------------------------------------------------------------
// FnTwoPointerScan: find max (hiA+hiB, loA+loB) <= (halfHi, halfLo)
// ---------------------------------------------------------------
//
proc FnTwoPointerScan()
    integer iAI = 0
    integer iBI = 0
    integer numAI = 0
    integer numBI = 0
    integer aHiI = 0
    integer aLoI = 0
    integer bHiI = 0
    integer bLoI = 0
    integer sumHiI = 0
    integer sumLoI = 0
    integer tooLargeB = 0
    integer isBetterB = 0
    string readS[40] = ""
    integer aMaskI = 0
    integer bMaskI = 0
    //
    gBestHiI = -1
    gBestLoI = 0
    gBestMaskAI = 0
    gBestMaskBI = 0
    //
    GotoBufferId( gBufAI )
    numAI = NumLines()
    GotoBufferId( gBufBI )
    numBI = NumLines()
    //
    iAI = 1
    iBI = numBI
    //
    while ( iAI <= numAI ) and ( iBI >= 1 )
        //
        // Read A
        //
        GotoBufferId( gBufAI )
        GotoLine( iAI )
        readS = GetText( 1, CurrLineLen() )
        FnParseSubsetLine( readS )
        aHiI = gSubHiI
        aLoI = gSubLoI
        aMaskI = gSubMaskI
        //
        // Read B
        //
        GotoBufferId( gBufBI )
        GotoLine( iBI )
        readS = GetText( 1, CurrLineLen() )
        FnParseSubsetLine( readS )
        bHiI = gSubHiI
        bLoI = gSubLoI
        bMaskI = gSubMaskI
        //
        // Compute sum with carry
        //
        sumLoI = aLoI + bLoI
        sumHiI = aHiI + bHiI
        if sumLoI >= gModLoI
            sumLoI = sumLoI - gModLoI
            sumHiI = sumHiI + 1
        endif
        //
        // Compare sum vs half: is sum > half?
        //
        tooLargeB = FALSE
        if sumHiI > gHalfHiI
            tooLargeB = TRUE
        elseif sumHiI == gHalfHiI
            if sumLoI > gHalfLoI
                tooLargeB = TRUE
            endif
        endif
        //
        if tooLargeB
            iBI = iBI - 1
        else
            //
            // Valid pair. Is it better than current best?
            //
            isBetterB = FALSE
            if sumHiI > gBestHiI
                isBetterB = TRUE
            elseif sumHiI == gBestHiI
                if sumLoI > gBestLoI
                    isBetterB = TRUE
                endif
            endif
            //
            if isBetterB
                gBestHiI = sumHiI
                gBestLoI = sumLoI
                gBestMaskAI = aMaskI
                gBestMaskBI = bMaskI
            endif
            //
            iAI = iAI + 1
        endif
    endwhile
end
//
// ---------------------------------------------------------------
// FnComputeProduct: multiply selected primes mod 10^16
//   4 limbs base 10000
// ---------------------------------------------------------------
//
proc FnComputeProduct()
    integer d3I = 0
    integer d2I = 0
    integer d1I = 0
    integer d0I = 0
    integer iI = 0
    integer primeI = 0
    integer maskI = 0
    integer tmpI = 0
    integer carryI = 0
    //
    d3I = 0
    d2I = 0
    d1I = 0
    d0I = 1
    //
    // Left half: bits of gBestMaskAI, primes 1..21
    //
    maskI = gBestMaskAI
    iI = 1
    while iI <= gHalfI
        //
        if ( maskI & 1 ) <> 0
            //
            primeI = FnGetPrimeI( iI )
            //
            carryI = 0
            //
            tmpI = ( d0I * primeI ) + carryI
            d0I = tmpI mod 10000
            carryI = tmpI / 10000
            //
            tmpI = ( d1I * primeI ) + carryI
            d1I = tmpI mod 10000
            carryI = tmpI / 10000
            //
            tmpI = ( d2I * primeI ) + carryI
            d2I = tmpI mod 10000
            carryI = tmpI / 10000
            //
            tmpI = ( d3I * primeI ) + carryI
            d3I = tmpI mod 10000
            //
        endif
        //
        maskI = maskI shr 1
        iI = iI + 1
    endwhile
    //
    // Right half: bits of gBestMaskBI, primes 22..42
    //
    maskI = gBestMaskBI
    iI = gHalfI + 1
    while iI <= 42
        //
        if ( maskI & 1 ) <> 0
            //
            primeI = FnGetPrimeI( iI )
            //
            carryI = 0
            //
            tmpI = ( d0I * primeI ) + carryI
            d0I = tmpI mod 10000
            carryI = tmpI / 10000
            //
            tmpI = ( d1I * primeI ) + carryI
            d1I = tmpI mod 10000
            carryI = tmpI / 10000
            //
            tmpI = ( d2I * primeI ) + carryI
            d2I = tmpI mod 10000
            carryI = tmpI / 10000
            //
            tmpI = ( d3I * primeI ) + carryI
            d3I = tmpI mod 10000
            //
        endif
        //
        maskI = maskI shr 1
        iI = iI + 1
    endwhile
    //
    gR3I = d3I
    gR2I = d2I
    gR1I = d1I
    gR0I = d0I
end
//
// ---------------------------------------------------------------
// proc Main
// ---------------------------------------------------------------
//
proc Main()
    string resultS[40] = ""
    //
    gOrigBufI = GetBufferId()
    //
    FnInitPrimesAndLogs()
    //
    FnBuildHalf( 0 )
    //
    FnBuildHalf( 1 )
    //
    FnSortBuf( gBufAI )
    FnSortBuf( gBufBI )
    //
    FnTwoPointerScan()
    //
    FnComputeProduct()
    //
    resultS = Format( gR3I:4:"0" ) + Format( gR2I:4:"0" ) + Format( gR1I:4:"0" ) + Format( gR0I:4:"0" )
    //
    while ( Length( resultS ) > 1 ) and ( SubStr( resultS, 1, 1 ) == "0" )
        resultS = SubStr( resultS, 2, Length( resultS ) - 1 )
    endwhile
    //
    GotoBufferId( gOrigBufI )
    AbandonFile( gPrimeBufI )
    AbandonFile( gBufAI )
    AbandonFile( gBufBI )
    //
    CopyToWinClip( resultS )
    Warn( resultS )
    CopyToWinClip( resultS )
end
