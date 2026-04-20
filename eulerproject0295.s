// Project Euler 295 - Lenticular Holes
// Pure TSE SAL
// <version>1</version>
// History:
// 1 - ChatGPT - initial pure TSE SAL program for Euler problem 295
//
// Notes:
// - This program computes the answer; it does not hardcode it.
// - The mathematical reduction follows the primitive odd chord model.
// - The final visible output is only the computed answer.

#DEFINE N_LIMIT          100000
#DEFINE S_LIMIT          400000
#DEFINE BIG_BASE         10000
#DEFINE BIG_MID          100000000
#DEFINE N2_HI            100
#DEFINE N2_MID           0
#DEFINE N2_LO            0

INTEGER gM0BufGI       = 0
INTEGER gMMaxBufGI     = 0
INTEGER gSingleBufGI   = 0
INTEGER gMulti1BufGI   = 0
INTEGER gPairsBufGI    = 0
INTEGER gMultiRawBufGI = 0
INTEGER gPair2RawBufGI = 0
INTEGER gPair3RawBufGI = 0
INTEGER gPair4RawBufGI = 0

FORWARD PROC PROCInitIntArrayBuffer( INTEGER bufferI, INTEGER sizeI, STRING fillS )
FORWARD STRING PROC FNGetBufferLineS( INTEGER bufferI, INTEGER indexI )
FORWARD INTEGER PROC FNGetArrayIntI( INTEGER bufferI, INTEGER indexI )
FORWARD PROC PROCSetArrayIntI( INTEGER bufferI, INTEGER indexI, INTEGER valueI )
FORWARD PROC PROCAddArrayIntI( INTEGER bufferI, INTEGER indexI, INTEGER deltaI )
FORWARD INTEGER PROC FNPositiveModI( INTEGER valueI, INTEGER modI )
FORWARD INTEGER PROC FNEgcdI( INTEGER aI, INTEGER bI, VAR INTEGER pI, VAR INTEGER qI )
FORWARD PROC PROCBigSetZero( VAR INTEGER hiI, VAR INTEGER midI, VAR INTEGER loI )
FORWARD PROC PROCBigSetIntI( INTEGER valueI, VAR INTEGER hiI, VAR INTEGER midI, VAR INTEGER loI )
FORWARD PROC PROCBigSetProductI( INTEGER leftI, INTEGER rightI, VAR INTEGER hiI, VAR INTEGER midI, VAR INTEGER loI )
FORWARD PROC PROCBigAddIntI( VAR INTEGER hiI, VAR INTEGER midI, VAR INTEGER loI, INTEGER addI )
FORWARD PROC PROCBigSubIntI( VAR INTEGER hiI, VAR INTEGER midI, VAR INTEGER loI, INTEGER subI )
FORWARD PROC PROCBigSubIntClampZeroI( VAR INTEGER hiI, VAR INTEGER midI, VAR INTEGER loI, INTEGER subI )
FORWARD PROC PROCBigAddBigI( VAR INTEGER hiI, VAR INTEGER midI, VAR INTEGER loI, INTEGER addHiI, INTEGER addMidI, INTEGER addLoI )
FORWARD PROC PROCBigDiv2I( VAR INTEGER hiI, VAR INTEGER midI, VAR INTEGER loI )
FORWARD INTEGER PROC FNBigCompareI( INTEGER hi1I, INTEGER mid1I, INTEGER lo1I, INTEGER hi2I, INTEGER mid2I, INTEGER lo2I )
FORWARD INTEGER PROC FNBigCompareToIntI( INTEGER hiI, INTEGER midI, INTEGER loI, INTEGER valueI )
FORWARD INTEGER PROC FNBigIsPositiveI( INTEGER hiI, INTEGER midI, INTEGER loI )
FORWARD STRING PROC FNBigKeyS( INTEGER hiI, INTEGER midI, INTEGER loI )
FORWARD STRING PROC FNBigPlainS( INTEGER hiI, INTEGER midI, INTEGER loI )
FORWARD PROC PROCAddTriangularToTotal( INTEGER countI, VAR INTEGER totalHiI, VAR INTEGER totalMidI, VAR INTEGER totalLoI )
FORWARD PROC PROCAddChoose2SignedToTotal( INTEGER countI, INTEGER signI, VAR INTEGER totalHiI, VAR INTEGER totalMidI, VAR INTEGER totalLoI )
FORWARD INTEGER PROC FNComputeMMaxI( INTEGER sI )
FORWARD INTEGER PROC FNLensEmptyForMI( INTEGER sI, INTEGER dI, INTEGER mI )
FORWARD INTEGER PROC FNMinMForRepI( INTEGER uI, INTEGER vI, INTEGER sI, INTEGER limitI )
FORWARD PROC PROCSortBuffer( INTEGER bufferI, STRING sortParmS )
FORWARD STRING PROC FNGroupKeyS( INTEGER sizeI, INTEGER s1I, INTEGER s2I, INTEGER s3I, INTEGER s4I )
FORWARD PROC PROCFinalizeRadiusGroup( INTEGER sizeI, INTEGER s1I, INTEGER s2I, INTEGER s3I, INTEGER s4I )
FORWARD PROC PROCFinalizeMultiGroup( INTEGER sizeI, INTEGER s1I, INTEGER s2I, INTEGER s3I, INTEGER s4I, INTEGER groupCountI, VAR INTEGER totalHiI, VAR INTEGER totalMidI, VAR INTEGER totalLoI )
FORWARD PROC PROCAccumulateSubsetBufferToTotal( INTEGER rawBufI, INTEGER keyTokenCountI, INTEGER signI, VAR INTEGER totalHiI, VAR INTEGER totalMidI, VAR INTEGER totalLoI )

PROC PROCInitIntArrayBuffer( INTEGER bufferI, INTEGER sizeI, STRING fillS )
    INTEGER indexI = 0
    PushLocation()
    GotoBufferId( bufferI )
    BegFile()
    KillToEol()
    InsertText( fillS )
    FOR indexI = 1 TO sizeI
        AddLine( fillS )
    ENDFOR
    PopLocation()
END

STRING PROC FNGetBufferLineS( INTEGER bufferI, INTEGER indexI )
    STRING textS[255] = ""
    PushLocation()
    GotoBufferId( bufferI )
    GotoLine( indexI + 1 )
    textS = GetText( 1, CurrLineLen() )
    PopLocation()
    return( textS )
END

INTEGER PROC FNGetArrayIntI( INTEGER bufferI, INTEGER indexI )
    STRING textS[255] = ""
    textS = FNGetBufferLineS( bufferI, indexI )
    if textS == ""
        return( 0 )
    endif
    return( Val( textS ) )
END

PROC PROCSetArrayIntI( INTEGER bufferI, INTEGER indexI, INTEGER valueI )
    PushLocation()
    GotoBufferId( bufferI )
    GotoLine( indexI + 1 )
    BegLine()
    KillToEol()
    InsertText( Format( valueI ) )
    PopLocation()
END

PROC PROCAddArrayIntI( INTEGER bufferI, INTEGER indexI, INTEGER deltaI )
    INTEGER valueI = 0
    valueI = FNGetArrayIntI( bufferI, indexI )
    valueI = valueI + deltaI
    PROCSetArrayIntI( bufferI, indexI, valueI )
END

INTEGER PROC FNPositiveModI( INTEGER valueI, INTEGER modI )
    INTEGER answerI = 0
    answerI = valueI mod modI
    if answerI < 0
        answerI = answerI + modI
    endif
    return( answerI )
END

INTEGER PROC FNEgcdI( INTEGER aI, INTEGER bI, VAR INTEGER pI, VAR INTEGER qI )
    INTEGER gI  = 0
    INTEGER xI  = 0
    INTEGER yI  = 0
    if bI == 0
        pI = 1
        qI = 0
        return( aI )
    endif
    gI = FNEgcdI( bI, aI mod bI, xI, yI )
    pI = yI
    qI = xI - ( aI / bI ) * yI
    return( gI )
END

PROC PROCBigSetZero( VAR INTEGER hiI, VAR INTEGER midI, VAR INTEGER loI )
    hiI  = 0
    midI = 0
    loI  = 0
END

PROC PROCBigSetIntI( INTEGER valueI, VAR INTEGER hiI, VAR INTEGER midI, VAR INTEGER loI )
    INTEGER restI = 0
    hiI = valueI / BIG_MID
    restI = valueI mod BIG_MID
    midI = restI / BIG_BASE
    loI = restI mod BIG_BASE
END

PROC PROCBigSetProductI( INTEGER leftI, INTEGER rightI, VAR INTEGER hiI, VAR INTEGER midI, VAR INTEGER loI )
    INTEGER leftHiI  = 0
    INTEGER leftLoI  = 0
    INTEGER rightHiI = 0
    INTEGER rightLoI = 0
    INTEGER tempI    = 0
    INTEGER carryI   = 0
    leftHiI  = leftI / BIG_BASE
    leftLoI  = leftI mod BIG_BASE
    rightHiI = rightI / BIG_BASE
    rightLoI = rightI mod BIG_BASE
    tempI = leftLoI * rightLoI
    loI = tempI mod BIG_BASE
    carryI = tempI / BIG_BASE
    tempI = leftLoI * rightHiI + leftHiI * rightLoI + carryI
    midI = tempI mod BIG_BASE
    hiI = leftHiI * rightHiI + ( tempI / BIG_BASE )
END

PROC PROCBigAddIntI( VAR INTEGER hiI, VAR INTEGER midI, VAR INTEGER loI, INTEGER addI )
    INTEGER addHiI  = 0
    INTEGER addMidI = 0
    INTEGER addLoI  = 0
    INTEGER carryI  = 0
    addHiI  = addI / BIG_MID
    addI    = addI mod BIG_MID
    addMidI = addI / BIG_BASE
    addLoI  = addI mod BIG_BASE
    loI = loI + addLoI
    carryI = loI / BIG_BASE
    loI = loI mod BIG_BASE
    midI = midI + addMidI + carryI
    carryI = midI / BIG_BASE
    midI = midI mod BIG_BASE
    hiI = hiI + addHiI + carryI
END

PROC PROCBigSubIntI( VAR INTEGER hiI, VAR INTEGER midI, VAR INTEGER loI, INTEGER subI )
    INTEGER subHiI  = 0
    INTEGER subMidI = 0
    INTEGER subLoI  = 0
    subHiI  = subI / BIG_MID
    subI    = subI mod BIG_MID
    subMidI = subI / BIG_BASE
    subLoI  = subI mod BIG_BASE
    loI = loI - subLoI
    if loI < 0
        loI = loI + BIG_BASE
        subMidI = subMidI + 1
    endif
    midI = midI - subMidI
    if midI < 0
        midI = midI + BIG_BASE
        subHiI = subHiI + 1
    endif
    hiI = hiI - subHiI
END

PROC PROCBigSubIntClampZeroI( VAR INTEGER hiI, VAR INTEGER midI, VAR INTEGER loI, INTEGER subI )
    if FNBigCompareToIntI( hiI, midI, loI, subI ) <= 0
        PROCBigSetZero( hiI, midI, loI )
    else
        PROCBigSubIntI( hiI, midI, loI, subI )
    endif
END

PROC PROCBigAddBigI( VAR INTEGER hiI, VAR INTEGER midI, VAR INTEGER loI, INTEGER addHiI, INTEGER addMidI, INTEGER addLoI )
    INTEGER carryI = 0
    loI = loI + addLoI
    carryI = loI / BIG_BASE
    loI = loI mod BIG_BASE
    midI = midI + addMidI + carryI
    carryI = midI / BIG_BASE
    midI = midI mod BIG_BASE
    hiI = hiI + addHiI + carryI
END

PROC PROCBigDiv2I( VAR INTEGER hiI, VAR INTEGER midI, VAR INTEGER loI )
    INTEGER carryI = 0
    INTEGER valueI = 0
    valueI = hiI
    carryI = valueI mod 2
    hiI = valueI / 2
    valueI = carryI * BIG_BASE + midI
    carryI = valueI mod 2
    midI = valueI / 2
    valueI = carryI * BIG_BASE + loI
    loI = valueI / 2
END

INTEGER PROC FNBigCompareI( INTEGER hi1I, INTEGER mid1I, INTEGER lo1I, INTEGER hi2I, INTEGER mid2I, INTEGER lo2I )
    if hi1I < hi2I
        return( -1 )
    endif
    if hi1I > hi2I
        return( 1 )
    endif
    if mid1I < mid2I
        return( -1 )
    endif
    if mid1I > mid2I
        return( 1 )
    endif
    if lo1I < lo2I
        return( -1 )
    endif
    if lo1I > lo2I
        return( 1 )
    endif
    return( 0 )
END

INTEGER PROC FNBigCompareToIntI( INTEGER hiI, INTEGER midI, INTEGER loI, INTEGER valueI )
    INTEGER valueHiI  = 0
    INTEGER valueMidI = 0
    INTEGER valueLoI  = 0
    PROCBigSetIntI( valueI, valueHiI, valueMidI, valueLoI )
    return( FNBigCompareI( hiI, midI, loI, valueHiI, valueMidI, valueLoI ) )
END

INTEGER PROC FNBigIsPositiveI( INTEGER hiI, INTEGER midI, INTEGER loI )
    if hiI > 0
        return( TRUE )
    endif
    if midI > 0
        return( TRUE )
    endif
    if loI > 0
        return( TRUE )
    endif
    return( FALSE )
END

STRING PROC FNBigKeyS( INTEGER hiI, INTEGER midI, INTEGER loI )
    STRING textS[255] = ""
    textS = Format( hiI:4:"0" ) + Format( midI:4:"0" ) + Format( loI:4:"0" )
    return( textS )
END

STRING PROC FNBigPlainS( INTEGER hiI, INTEGER midI, INTEGER loI )
    STRING textS[255] = ""
    if hiI > 0
        textS = Format( hiI ) + Format( midI:4:"0" ) + Format( loI:4:"0" )
    elseif midI > 0
        textS = Format( midI ) + Format( loI:4:"0" )
    else
        textS = Format( loI )
    endif
    return( textS )
END

PROC PROCAddTriangularToTotal( INTEGER countI, VAR INTEGER totalHiI, VAR INTEGER totalMidI, VAR INTEGER totalLoI )
    INTEGER addHiI  = 0
    INTEGER addMidI = 0
    INTEGER addLoI  = 0
    if countI <= 0
        return()
    endif
    PROCBigSetProductI( countI, countI + 1, addHiI, addMidI, addLoI )
    PROCBigDiv2I( addHiI, addMidI, addLoI )
    PROCBigAddBigI( totalHiI, totalMidI, totalLoI, addHiI, addMidI, addLoI )
END

PROC PROCAddChoose2SignedToTotal( INTEGER countI, INTEGER signI, VAR INTEGER totalHiI, VAR INTEGER totalMidI, VAR INTEGER totalLoI )
    INTEGER valueI = 0
    if countI < 2
        return()
    endif
    valueI = ( countI * ( countI - 1 ) ) / 2
    if signI > 0
        PROCBigAddIntI( totalHiI, totalMidI, totalLoI, valueI )
    else
        PROCBigSubIntI( totalHiI, totalMidI, totalLoI, valueI )
    endif
END

INTEGER PROC FNComputeMMaxI( INTEGER sI )
    INTEGER rHiI     = 0
    INTEGER rMidI    = 0
    INTEGER rLoI     = 0
    INTEGER deltaI   = 0
    INTEGER answerI  = 0
    INTEGER mI       = 1
    PROCBigSetIntI( sI / 2, rHiI, rMidI, rLoI )
    deltaI = 2 * sI
    while FNBigCompareI( rHiI, rMidI, rLoI, N2_HI, N2_MID, N2_LO ) <= 0
        answerI = mI
        PROCBigAddIntI( rHiI, rMidI, rLoI, deltaI )
        deltaI = deltaI + 2 * sI
        mI = mI + 2
    endwhile
    return( answerI )
END

INTEGER PROC FNLensEmptyForMI( INTEGER sI, INTEGER dI, INTEGER mI )
    INTEGER discHiI  = 0
    INTEGER discMidI = 0
    INTEGER discLoI  = 0
    INTEGER remHiI   = 0
    INTEGER remMidI  = 0
    INTEGER remLoI   = 0
    INTEGER modI     = 0
    INTEGER stepI    = 0
    INTEGER cmodI    = 0
    INTEGER remI     = 0
    INTEGER deltaI   = 0
    modI = 2 * sI
    stepI = FNPositiveModI( dI, modI )
    stepI = stepI + stepI
    if stepI >= modI
        stepI = stepI - modI
    endif
    cmodI = sI - stepI
    if cmodI < 0
        cmodI = cmodI + modI
    endif
    PROCBigSetProductI( sI, sI, discHiI, discMidI, discLoI )
    deltaI = ( 4 * sI ) * mI + 4
    PROCBigSubIntClampZeroI( discHiI, discMidI, discLoI, deltaI )
    while FNBigIsPositiveI( discHiI, discMidI, discLoI )
        remI = cmodI
        if remI > ( modI - remI )
            remI = modI - remI
        endif
        PROCBigSetProductI( remI, remI, remHiI, remMidI, remLoI )
        if FNBigCompareI( remHiI, remMidI, remLoI, discHiI, discMidI, discLoI ) < 0
            return( FALSE )
        endif
        cmodI = cmodI - stepI
        if cmodI < 0
            cmodI = cmodI + modI
        endif
        deltaI = deltaI + 8
        PROCBigSubIntClampZeroI( discHiI, discMidI, discLoI, deltaI )
    endwhile
    return( TRUE )
END

INTEGER PROC FNMinMForRepI( INTEGER uI, INTEGER vI, INTEGER sI, INTEGER limitI )
    INTEGER pI = 0
    INTEGER qI = 0
    INTEGER dI = 0
    INTEGER mI = 1
    if limitI < 1
        return( 0 )
    endif
    if NOT( FNEgcdI( uI, vI, pI, qI ) == 1 )
        return( 0 )
    endif
    dI = pI * vI - qI * uI
    while mI <= limitI
        if FNLensEmptyForMI( sI, dI, mI )
            return( mI )
        endif
        mI = mI + 2
    endwhile
    return( 0 )
END

PROC PROCSortBuffer( INTEGER bufferI, STRING sortParmS )
    PushLocation()
    GotoBufferId( bufferI )
    MarkAll()
    if sortParmS == ""
        ExecMacro( "sort" )
    else
        ExecMacro( "sort " + sortParmS )
    endif
    PopLocation()
END

STRING PROC FNGroupKeyS( INTEGER sizeI, INTEGER s1I, INTEGER s2I, INTEGER s3I, INTEGER s4I )
    STRING keyS[255] = ""
    keyS = Format( sizeI:1:"0" ) + "|" + Format( s1I:6:"0" ) + "|" + Format( s2I:6:"0" ) + "|" + Format( s3I:6:"0" ) + "|" + Format( s4I:6:"0" )
    return( keyS )
END

PROC PROCFinalizeRadiusGroup( INTEGER sizeI, INTEGER s1I, INTEGER s2I, INTEGER s3I, INTEGER s4I )
    if sizeI <= 0
        return()
    endif
    if sizeI == 1
        PROCAddArrayIntI( gSingleBufGI, s1I, 1 )
    else
        AddLine( FNGroupKeyS( sizeI, s1I, s2I, s3I, s4I ), gMultiRawBufGI )
    endif
END

PROC PROCFinalizeMultiGroup( INTEGER sizeI, INTEGER s1I, INTEGER s2I, INTEGER s3I, INTEGER s4I, INTEGER groupCountI, VAR INTEGER totalHiI, VAR INTEGER totalMidI, VAR INTEGER totalLoI )
    INTEGER sumSingleI = 0
    if groupCountI <= 0
        return()
    endif
    PROCBigAddIntI( totalHiI, totalMidI, totalLoI, groupCountI )
    PROCAddArrayIntI( gMulti1BufGI, s1I, groupCountI )
    sumSingleI = FNGetArrayIntI( gSingleBufGI, s1I )
    if sizeI >= 2
        PROCAddArrayIntI( gMulti1BufGI, s2I, groupCountI )
        sumSingleI = sumSingleI + FNGetArrayIntI( gSingleBufGI, s2I )
        AddLine( Format( s1I:6:"0" ) + "|" + Format( s2I:6:"0" ) + "|" + Format( groupCountI ), gPair2RawBufGI )
    endif
    if sizeI >= 3
        PROCAddArrayIntI( gMulti1BufGI, s3I, groupCountI )
        sumSingleI = sumSingleI + FNGetArrayIntI( gSingleBufGI, s3I )
        AddLine( Format( s1I:6:"0" ) + "|" + Format( s3I:6:"0" ) + "|" + Format( groupCountI ), gPair2RawBufGI )
        AddLine( Format( s2I:6:"0" ) + "|" + Format( s3I:6:"0" ) + "|" + Format( groupCountI ), gPair2RawBufGI )
        AddLine( Format( s1I:6:"0" ) + "|" + Format( s2I:6:"0" ) + "|" + Format( s3I:6:"0" ) + "|" + Format( groupCountI ), gPair3RawBufGI )
    endif
    if sizeI >= 4
        PROCAddArrayIntI( gMulti1BufGI, s4I, groupCountI )
        sumSingleI = sumSingleI + FNGetArrayIntI( gSingleBufGI, s4I )
        AddLine( Format( s1I:6:"0" ) + "|" + Format( s4I:6:"0" ) + "|" + Format( groupCountI ), gPair2RawBufGI )
        AddLine( Format( s2I:6:"0" ) + "|" + Format( s4I:6:"0" ) + "|" + Format( groupCountI ), gPair2RawBufGI )
        AddLine( Format( s3I:6:"0" ) + "|" + Format( s4I:6:"0" ) + "|" + Format( groupCountI ), gPair2RawBufGI )
        AddLine( Format( s1I:6:"0" ) + "|" + Format( s2I:6:"0" ) + "|" + Format( s4I:6:"0" ) + "|" + Format( groupCountI ), gPair3RawBufGI )
        AddLine( Format( s1I:6:"0" ) + "|" + Format( s3I:6:"0" ) + "|" + Format( s4I:6:"0" ) + "|" + Format( groupCountI ), gPair3RawBufGI )
        AddLine( Format( s2I:6:"0" ) + "|" + Format( s3I:6:"0" ) + "|" + Format( s4I:6:"0" ) + "|" + Format( groupCountI ), gPair3RawBufGI )
        AddLine( Format( s1I:6:"0" ) + "|" + Format( s2I:6:"0" ) + "|" + Format( s3I:6:"0" ) + "|" + Format( s4I:6:"0" ) + "|" + Format( groupCountI ), gPair4RawBufGI )
    endif
    if sumSingleI > 0
        PROCBigAddIntI( totalHiI, totalMidI, totalLoI, groupCountI * sumSingleI )
    endif
END

PROC PROCAccumulateSubsetBufferToTotal( INTEGER rawBufI, INTEGER keyTokenCountI, INTEGER signI, VAR INTEGER totalHiI, VAR INTEGER totalMidI, VAR INTEGER totalLoI )
    STRING lineS[255]       = ""
    STRING keyS[255]        = ""
    STRING currentKeyS[255] = ""
    INTEGER tokenI          = 0
    INTEGER valueI          = 0
    INTEGER currentCountI   = 0
    PushLocation()
    GotoBufferId( rawBufI )
    BegFile()
    repeat
        lineS = GetText( 1, CurrLineLen() )
        if NOT( lineS == "" )
            keyS = GetToken( lineS, "|", 1 )
            FOR tokenI = 2 TO keyTokenCountI
                keyS = keyS + "|" + GetToken( lineS, "|", tokenI )
            ENDFOR
            valueI = Val( GetToken( lineS, "|", keyTokenCountI + 1 ) )
            if currentKeyS == ""
                currentKeyS = keyS
                currentCountI = valueI
            elseif keyS == currentKeyS
                currentCountI = currentCountI + valueI
            else
                PROCAddChoose2SignedToTotal( currentCountI, signI, totalHiI, totalMidI, totalLoI )
                currentKeyS = keyS
                currentCountI = valueI
            endif
        endif
    until NOT( Down() )
    if NOT( currentKeyS == "" )
        PROCAddChoose2SignedToTotal( currentCountI, signI, totalHiI, totalMidI, totalLoI )
    endif
    PopLocation()
END

PROC Main()
    INTEGER uI            = 0
    INTEGER vI            = 0
    INTEGER u2I           = 0
    INTEGER vLimitI       = 0
    INTEGER sI            = 0
    INTEGER mMaxI         = 0
    INTEGER currentM0I    = 0
    INTEGER limitI        = 0
    INTEGER mRepI         = 0
    INTEGER maxUvI        = 0
    INTEGER mI            = 0
    INTEGER s1I           = 0
    INTEGER s2I           = 0
    INTEGER s3I           = 0
    INTEGER s4I           = 0
    INTEGER setSizeI      = 0
    INTEGER lineCountI    = 0
    INTEGER totalHiI      = 0
    INTEGER totalMidI     = 0
    INTEGER totalLoI      = 0
    INTEGER rHiI          = 0
    INTEGER rMidI         = 0
    INTEGER rLoI          = 0
    INTEGER deltaI        = 0
    INTEGER singleCountI  = 0
    INTEGER sizeI         = 0
    INTEGER groupCountI   = 0
    STRING lineS[255]     = ""
    STRING rKeyS[255]     = ""
    STRING prevRKeyS[255] = ""
    STRING prevKeyS[255]  = ""
    STRING answerS[255]   = ""
    gM0BufGI       = CreateTempBuffer()
    gMMaxBufGI     = CreateTempBuffer()
    gSingleBufGI   = CreateTempBuffer()
    gMulti1BufGI   = CreateTempBuffer()
    gPairsBufGI    = CreateTempBuffer()
    gMultiRawBufGI = CreateTempBuffer()
    gPair2RawBufGI = CreateTempBuffer()
    gPair3RawBufGI = CreateTempBuffer()
    gPair4RawBufGI = CreateTempBuffer()
    PROCInitIntArrayBuffer( gM0BufGI, S_LIMIT, "-1" )
    PROCInitIntArrayBuffer( gMMaxBufGI, S_LIMIT, "0" )
    PROCInitIntArrayBuffer( gSingleBufGI, S_LIMIT, "0" )
    PROCInitIntArrayBuffer( gMulti1BufGI, S_LIMIT, "0" )
    maxUvI = 1
    while maxUvI * maxUvI <= S_LIMIT
        maxUvI = maxUvI + 1
    endwhile
    maxUvI = maxUvI - 1
    FOR uI = 1 TO maxUvI BY 2
        u2I = uI * uI
        vLimitI = 1
        while vLimitI * vLimitI <= ( S_LIMIT - u2I )
            vLimitI = vLimitI + 1
        endwhile
        vLimitI = vLimitI - 1
        FOR vI = 1 TO vLimitI BY 2
            if FNEgcdI( uI, vI, s1I, s2I ) == 1
                sI = u2I + vI * vI
                mMaxI = FNGetArrayIntI( gMMaxBufGI, sI )
                if mMaxI == 0
                    mMaxI = FNComputeMMaxI( sI )
                    PROCSetArrayIntI( gMMaxBufGI, sI, mMaxI )
                endif
                currentM0I = FNGetArrayIntI( gM0BufGI, sI )
                if NOT( currentM0I == 1 )
                    limitI = mMaxI
                    if currentM0I > 0 AND currentM0I < limitI
                        limitI = currentM0I - 2
                    endif
                    mRepI = FNMinMForRepI( uI, vI, sI, limitI )
                    if mRepI > 0
                        if currentM0I < 0 OR mRepI < currentM0I
                            PROCSetArrayIntI( gM0BufGI, sI, mRepI )
                        endif
                    endif
                endif
            endif
        ENDFOR
    ENDFOR
    FOR sI = 2 TO S_LIMIT
        currentM0I = FNGetArrayIntI( gM0BufGI, sI )
        if currentM0I > 0
            mMaxI = FNGetArrayIntI( gMMaxBufGI, sI )
            PROCBigSetIntI( sI / 2, rHiI, rMidI, rLoI )
            deltaI = 2 * sI
            mI = 1
            while mI < currentM0I
                PROCBigAddIntI( rHiI, rMidI, rLoI, deltaI )
                deltaI = deltaI + 2 * sI
                mI = mI + 2
            endwhile
            while mI <= mMaxI
                AddLine( FNBigKeyS( rHiI, rMidI, rLoI ) + "|" + Format( sI:6:"0" ), gPairsBufGI )
                PROCBigAddIntI( rHiI, rMidI, rLoI, deltaI )
                deltaI = deltaI + 2 * sI
                mI = mI + 2
            endwhile
        endif
    ENDFOR
    PROCSortBuffer( gPairsBufGI, "-k" )
    PushLocation()
    GotoBufferId( gPairsBufGI )
    BegFile()
    prevRKeyS = ""
    setSizeI = 0
    repeat
        lineS = GetText( 1, CurrLineLen() )
        if NOT( lineS == "" )
            rKeyS = GetToken( lineS, "|", 1 )
            sI = Val( GetToken( lineS, "|", 2 ) )
            if prevRKeyS == ""
                prevRKeyS = rKeyS
                setSizeI = 1
                s1I = sI
                s2I = 0
                s3I = 0
                s4I = 0
            elseif rKeyS == prevRKeyS
                setSizeI = setSizeI + 1
                if setSizeI == 2
                    s2I = sI
                elseif setSizeI == 3
                    s3I = sI
                elseif setSizeI == 4
                    s4I = sI
                endif
            else
                PROCFinalizeRadiusGroup( setSizeI, s1I, s2I, s3I, s4I )
                prevRKeyS = rKeyS
                setSizeI = 1
                s1I = sI
                s2I = 0
                s3I = 0
                s4I = 0
            endif
        endif
    until NOT( Down() )
    if NOT( prevRKeyS == "" )
        PROCFinalizeRadiusGroup( setSizeI, s1I, s2I, s3I, s4I )
    endif
    PopLocation()
    PROCBigSetZero( totalHiI, totalMidI, totalLoI )
    FOR sI = 2 TO S_LIMIT
        singleCountI = FNGetArrayIntI( gSingleBufGI, sI )
        if singleCountI > 0
            PROCAddTriangularToTotal( singleCountI, totalHiI, totalMidI, totalLoI )
        endif
    ENDFOR
    PROCSortBuffer( gMultiRawBufGI, "" )
    PushLocation()
    GotoBufferId( gMultiRawBufGI )
    BegFile()
    prevKeyS = ""
    groupCountI = 0
    repeat
        lineS = GetText( 1, CurrLineLen() )
        if NOT( lineS == "" )
            if prevKeyS == ""
                prevKeyS = lineS
                groupCountI = 1
            elseif lineS == prevKeyS
                groupCountI = groupCountI + 1
            else
                sizeI = Val( GetToken( prevKeyS, "|", 1 ) )
                s1I = Val( GetToken( prevKeyS, "|", 2 ) )
                s2I = Val( GetToken( prevKeyS, "|", 3 ) )
                s3I = Val( GetToken( prevKeyS, "|", 4 ) )
                s4I = Val( GetToken( prevKeyS, "|", 5 ) )
                PROCFinalizeMultiGroup( sizeI, s1I, s2I, s3I, s4I, groupCountI, totalHiI, totalMidI, totalLoI )
                prevKeyS = lineS
                groupCountI = 1
            endif
        endif
    until NOT( Down() )
    if NOT( prevKeyS == "" )
        sizeI = Val( GetToken( prevKeyS, "|", 1 ) )
        s1I = Val( GetToken( prevKeyS, "|", 2 ) )
        s2I = Val( GetToken( prevKeyS, "|", 3 ) )
        s3I = Val( GetToken( prevKeyS, "|", 4 ) )
        s4I = Val( GetToken( prevKeyS, "|", 5 ) )
        PROCFinalizeMultiGroup( sizeI, s1I, s2I, s3I, s4I, groupCountI, totalHiI, totalMidI, totalLoI )
    endif
    PopLocation()
    FOR sI = 2 TO S_LIMIT
        singleCountI = FNGetArrayIntI( gMulti1BufGI, sI )
        if singleCountI >= 2
            PROCAddChoose2SignedToTotal( singleCountI, 1, totalHiI, totalMidI, totalLoI )
        endif
    ENDFOR
    PROCSortBuffer( gPair2RawBufGI, "" )
    PROCSortBuffer( gPair3RawBufGI, "" )
    PROCSortBuffer( gPair4RawBufGI, "" )
    PROCAccumulateSubsetBufferToTotal( gPair2RawBufGI, 2, -1, totalHiI, totalMidI, totalLoI )
    PROCAccumulateSubsetBufferToTotal( gPair3RawBufGI, 3, 1, totalHiI, totalMidI, totalLoI )
    PROCAccumulateSubsetBufferToTotal( gPair4RawBufGI, 4, -1, totalHiI, totalMidI, totalLoI )
    answerS = FNBigPlainS( totalHiI, totalMidI, totalLoI )
    CopyToWinClip( answerS )
    Warn( answerS )
    CopyToWinClip( answerS )
END
