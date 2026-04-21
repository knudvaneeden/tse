/*
  Project Euler Problem 302 Solver
  Language: TSE SAL (The Semware Editor Professional)
  Created by: Google Gemini (Pro mode)
  Version: 14
*/

STRING maxLimitGS[255] = "1000000000000000000"
INTEGER totalAchillesGI = 0

// Fast Memory Prime Storage
INTEGER primesBufGI = 0
INTEGER totalPrimesGI = 0

/* --- Big Integer String Math Library --- */

integer proc FNcompareI(string aS, string bS)
    integer lenAI = Length(aS)
    integer lenBI = Length(bS)

    if (lenAI > lenBI)
        return(1)
    endif
    if (lenAI < lenBI)
        return(-1)
    endif
    if (aS == bS)
        return(0)
    endif
    if (aS > bS)
        return(1)
    endif
    return(-1)
end

string proc FNaddS(string aS, string bS)
    string resultS[255] = ""
    integer lenAI = Length(aS)
    integer lenBI = Length(bS)
    integer carryI = 0
    integer sumI = 0
    integer digitAI = 0
    integer digitBI = 0

    while (lenAI > 0 OR lenBI > 0 OR carryI > 0)
        digitAI = 0
        digitBI = 0
        if (lenAI > 0)
            digitAI = Asc(SubStr(aS, lenAI, 1)) - 48
            lenAI = lenAI - 1
        endif
        if (lenBI > 0)
            digitBI = Asc(SubStr(bS, lenBI, 1)) - 48
            lenBI = lenBI - 1
        endif

        sumI = digitAI + digitBI + carryI
        carryI = sumI / 10
        sumI = sumI MOD 10
        resultS = Chr(sumI + 48) + resultS
    endwhile

    if (resultS == "")
        resultS = "0"
    endif

    return(resultS)
end

string proc FNmultiplyS(string aS, string bS)
    string resultS[255] = "0"
    string tempS[255] = ""
    string zeroPadS[255] = ""
    integer lenAI = Length(aS)
    integer lenBI = Length(bS)
    integer iI = 0
    integer jI = 0
    integer carryI = 0
    integer productI = 0
    integer digitAI = 0
    integer digitBI = 0

    if (aS == "0" OR bS == "0")
        return("0")
    endif

    iI = lenBI
    while (iI > 0)
        digitBI = Asc(SubStr(bS, iI, 1)) - 48
        carryI = 0
        tempS = ""

        jI = lenAI
        while (jI > 0)
            digitAI = Asc(SubStr(aS, jI, 1)) - 48
            productI = (digitAI * digitBI) + carryI
            carryI = productI / 10
            productI = productI MOD 10
            tempS = Chr(productI + 48) + tempS
            jI = jI - 1
        endwhile

        if (carryI > 0)
            tempS = Chr(carryI + 48) + tempS
        endif

        tempS = tempS + zeroPadS
        resultS = FNaddS(resultS, tempS)
        zeroPadS = zeroPadS + "0"
        iI = iI - 1
    endwhile

    return(resultS)
end

integer proc FNgcdI(integer aI, integer bI)
    integer workAI = aI
    integer workBI = bI
    integer tempI = 0

    while (workBI > 0)
        tempI = workBI
        workBI = workAI MOD workBI
        workAI = tempI
    endwhile
    return(workAI)
end

/* --- Fast Prime Memory --- */

proc PROCgeneratePrimes()
    integer iI = 5
    integer addI = 2
    integer dI = 0
    integer isPrimeI = 0

    PushPosition()
    primesBufGI = CreateTempBuffer()
    GotoBufferId(primesBufGI)

    AddLine("2")
    AddLine("3")
    totalPrimesGI = 2

    // Cube root boundary required for 10^18 limits is ~630,000
    while (iI <= 630000)
        isPrimeI = TRUE
        if (iI MOD 3 == 0)
            isPrimeI = FALSE
        else
            dI = 5
            while (dI * dI <= iI)
                if (iI MOD dI == 0 OR iI MOD (dI + 2) == 0)
                    isPrimeI = FALSE
                    break
                endif
                dI = dI + 6
            endwhile
        endif

        if (isPrimeI)
            totalPrimesGI = totalPrimesGI + 1
            AddLine(Str(iI))
        endif

        iI = iI + addI
        addI = 6 - addI
    endwhile

    PopPosition()
end

/* --- Binary Searched Boundary Jumpers --- */

integer proc FNfindUpperIdxI(integer maxIdxI, string nS)
    integer lowI = 1
    integer highI = maxIdxI
    integer midI = 0
    integer bestI = 0
    string pS[25] = ""
    string p2S[50] = ""

    while (lowI <= highI)
        midI = lowI + ((highI - lowI) / 2)
        GotoLine(midI)
        pS = Trim(GetText(1, 255))
        p2S = FNmultiplyS(pS, pS)

        if (FNcompareI(FNmultiplyS(nS, p2S), maxLimitGS) <= 0)
            bestI = midI
            lowI = midI + 1
        else
            highI = midI - 1
        endif
    endwhile

    return(bestI)
end

integer proc FNfindMainStartIdxI(integer maxIdxI)
    integer lowI = 1
    integer highI = maxIdxI
    integer midI = 0
    integer bestI = 0
    string pS[25] = ""
    string p3S[50] = ""

    while (lowI <= highI)
        midI = lowI + ((highI - lowI) / 2)
        GotoLine(midI)
        pS = Trim(GetText(1, 255))
        p3S = FNmultiplyS(FNmultiplyS(pS, pS), pS)

        if (FNcompareI(FNmultiplyS(p3S, "4"), maxLimitGS) <= 0)
            bestI = midI
            lowI = midI + 1
        else
            highI = midI - 1
        endif
    endwhile

    return(bestI)
end

/* --- String Encoded Totient Array Handlers --- */

string proc FNaddPhiS(string phiS, integer qI, integer expI)
    string workPhiS[255] = phiS
    string searchS[25] = ""
    integer posI = 0
    integer endPosI = 0
    integer oldExpI = 0
    string prefixS[255] = ""
    string suffixS[255] = ""

    searchS = "," + Str(qI) + ":"
    posI = Pos(searchS, workPhiS)

    if (posI > 0)
        endPosI = Pos(",", SubStr(workPhiS, posI + Length(searchS), 255))
        if (endPosI > 0)
            endPosI = endPosI + posI + Length(searchS) - 1
            oldExpI = Val(SubStr(workPhiS, posI + Length(searchS), endPosI - (posI + Length(searchS))))
            prefixS = SubStr(workPhiS, 1, posI + Length(searchS) - 1)
            suffixS = SubStr(workPhiS, endPosI, 255)
            return(prefixS + Str(oldExpI + expI) + suffixS)
        endif
    endif

    if (workPhiS == "")
        workPhiS = ","
    endif

    return(workPhiS + Str(qI) + ":" + Str(expI) + ",")
end

string proc FNaddFactorsToPhiS(string phiS, integer inValI)
    integer dI = 2
    integer aI = 0
    integer workValI = inValI
    string newPhiS[255] = phiS

    if (workValI MOD 2 == 0)
        aI = 0
        while (workValI MOD 2 == 0)
            aI = aI + 1
            workValI = workValI / 2
        endwhile
        newPhiS = FNaddPhiS(newPhiS, 2, aI)
    endif

    dI = 3
    while (dI * dI <= workValI)
        if (workValI MOD dI == 0)
            aI = 0
            while (workValI MOD dI == 0)
                aI = aI + 1
                workValI = workValI / dI
            endwhile
            newPhiS = FNaddPhiS(newPhiS, dI, aI)
        endif
        dI = dI + 2
    endwhile

    if (workValI > 1)
        newPhiS = FNaddPhiS(newPhiS, workValI, 1)
    endif

    return(newPhiS)
end

integer proc FNhasOnesI(string phiS)
    if (Pos(":1,", phiS) > 0)
        return(TRUE)
    endif
    return(FALSE)
end

integer proc FNgetQmaxI(string phiS)
    integer maxQI = 0
    integer iI = 1
    integer lenI = Length(phiS)
    integer commaPosI = 0
    integer colonPosI = 0
    integer qI = 0
    integer eI = 0
    string subS[255] = ""

    while (iI < lenI)
        commaPosI = Pos(",", SubStr(phiS, iI + 1, 255))
        if (commaPosI == 0)
            break
        endif
        commaPosI = commaPosI + iI

        subS = SubStr(phiS, iI + 1, commaPosI - iI - 1)
        colonPosI = Pos(":", subS)
        if (colonPosI > 0)
            qI = Val(SubStr(subS, 1, colonPosI - 1))
            eI = Val(SubStr(subS, colonPosI + 1, 255))
            if (eI == 1 AND qI > maxQI)
                maxQI = qI
            endif
        endif
        iI = commaPosI
    endwhile

    return(maxQI)
end

integer proc FNgetPhiGcdI(string phiS)
    integer gcdI = 0
    integer iI = 1
    integer lenI = Length(phiS)
    integer commaPosI = 0
    integer colonPosI = 0
    integer eI = 0
    string subS[255] = ""

    while (iI < lenI)
        commaPosI = Pos(",", SubStr(phiS, iI + 1, 255))
        if (commaPosI == 0)
            break
        endif
        commaPosI = commaPosI + iI

        subS = SubStr(phiS, iI + 1, commaPosI - iI - 1)
        colonPosI = Pos(":", subS)
        if (colonPosI > 0)
            eI = Val(SubStr(subS, colonPosI + 1, 255))
            if (gcdI == 0)
                gcdI = eI
            else
                gcdI = FNgcdI(gcdI, eI)
            endif
            if (gcdI == 1)
                break
            endif
        endif
        iI = commaPosI
    endwhile

    return(gcdI)
end

integer proc FNisPresentI(string phiS, integer qI)
    string searchS[25] = ""
    searchS = "," + Str(qI) + ":"

    if (Pos(searchS, phiS) > 0)
        return(TRUE)
    endif
    return(FALSE)
end

/* --- Deep Prime Factorization Recursion --- */

proc PROCdfs(integer maxIdxI, string nS, integer gcdNI, integer numPrimesI, string phiS)
    integer qmaxI = 0
    integer hasOnesI = FALSE
    integer iI = 0
    integer lbI = 0
    integer pI = 0
    integer minEI = 0
    integer eI = 0
    integer presentI = 0
    integer phiGcdI = 0
    integer jumpIdxI = 0
    string workNS[255] = nS
    string workPhiS[255] = phiS
    string pS[25] = ""
    string p2S[50] = ""
    string pPowS[50] = ""
    string nTimesPpowS[50] = ""
    string nextPhiS[255] = ""
    string qmaxS[25] = ""
    string qmax2S[50] = ""

    hasOnesI = FNhasOnesI(workPhiS)

    if (hasOnesI)
        qmaxI = FNgetQmaxI(workPhiS)
        qmaxS = Str(qmaxI)
        qmax2S = FNmultiplyS(qmaxS, qmaxS)
        if (FNcompareI(FNmultiplyS(workNS, qmax2S), maxLimitGS) > 0)
            return()
        endif
        lbI = qmaxI
    else
        lbI = 2
    endif

    if (NOT hasOnesI AND numPrimesI >= 2 AND gcdNI == 1)
        phiGcdI = FNgetPhiGcdI(workPhiS)
        if (phiGcdI == 1)
            totalAchillesGI = totalAchillesGI + 1
        endif
    endif

    if (maxIdxI <= 0)
        return()
    endif

    if (FNcompareI(FNmultiplyS(workNS, "4"), maxLimitGS) > 0)
        return()
    endif

    // Binary search instantly jumps the upper bound without deep string iteration
    jumpIdxI = FNfindUpperIdxI(maxIdxI, workNS)
    iI = jumpIdxI

    while (iI >= 1)
        GotoLine(iI)
        pI = Val(Trim(GetText(1, 255)))

        if (pI < lbI)
            break
        endif

        pS = Str(pI)
        p2S = FNmultiplyS(pS, pS)

        presentI = FNisPresentI(workPhiS, pI)

        if (presentI)
            minEI = 2
            pPowS = p2S
        else
            minEI = 3
            pPowS = FNmultiplyS(p2S, pS)
        endif

        nTimesPpowS = FNmultiplyS(workNS, pPowS)

        if (FNcompareI(nTimesPpowS, maxLimitGS) <= 0)
            eI = minEI
            while (FNcompareI(nTimesPpowS, maxLimitGS) <= 0)

                nextPhiS = FNaddPhiS(workPhiS, pI, eI - 1)
                nextPhiS = FNaddFactorsToPhiS(nextPhiS, pI - 1)

                PROCdfs(iI - 1, nTimesPpowS, FNgcdI(gcdNI, eI), numPrimesI + 1, nextPhiS)

                pPowS = FNmultiplyS(pPowS, pS)
                eI = eI + 1
                nTimesPpowS = FNmultiplyS(workNS, pPowS)
            endwhile
        endif
        iI = iI - 1
    endwhile
end

/* --- Main Execution --- */

proc Main()
    string finalAnswerS[255] = ""
    string pS[25] = ""
    string p3S[50] = ""
    string pPowS[50] = ""
    string phiS[255] = ""
    integer idxI = 0
    integer jumpIdxI = 0
    integer pI = 0
    integer eI = 0

    PROCgeneratePrimes()

    // Establishing instantaneous context locking for all GotoLine binary searches
    GotoBufferId(primesBufGI)

    totalAchillesGI = 0

    // Jump starting index bounds instantly
    jumpIdxI = FNfindMainStartIdxI(totalPrimesGI)
    idxI = jumpIdxI

    while (idxI > 0)
        GotoLine(idxI)
        pI = Val(Trim(GetText(1, 255)))

        if (pI < 3)
            break
        endif

        pS = Str(pI)
        p3S = FNmultiplyS(FNmultiplyS(pS, pS), pS)

        eI = 3
        pPowS = p3S

        while (FNcompareI(FNmultiplyS(pPowS, "4"), maxLimitGS) <= 0)
            phiS = ","
            phiS = FNaddPhiS(phiS, pI, eI - 1)
            phiS = FNaddFactorsToPhiS(phiS, pI - 1)

            PROCdfs(idxI - 1, pPowS, eI, 1, phiS)

            pPowS = FNmultiplyS(pPowS, pS)
            eI = eI + 1
        endwhile

        idxI = idxI - 1
    endwhile

    AbandonFile(primesBufGI)

    finalAnswerS = Str(totalAchillesGI)

    CopyToWinClip(finalAnswerS)
    Warn(finalAnswerS)
    CopyToWinClip(finalAnswerS)
end
