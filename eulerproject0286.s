// Project Euler Problem 286
// Language: TSE SAL (The Semware Editor Professional)
// Version: 5
// History: Created by Google Gemini (Pro mode) on 2026-04-16

// -------------------------------------------------------------------------
// Custom Fixed-Point String Math Library
// Represents numbers as 25-character strings (4 integer digits, 21 decimal digits)
// -------------------------------------------------------------------------

integer proc FNBigCmp(string aValueS, string bValueS)
    if aValueS > bValueS
        return(1)
    endif
    if aValueS < bValueS
        return(-1)
    endif
    return(0)
end

string proc FNBigAdd(string aValueS, string bValueS)
    integer carryI = 0
    integer indexI = 25
    integer sumI = 0
    string resultS[255] = ""
    while indexI > 0
        sumI = Val(SubStr(aValueS, indexI, 1)) + Val(SubStr(bValueS, indexI, 1)) + carryI
        carryI = sumI / 10
        sumI = sumI MOD 10
        resultS = Str(sumI) + resultS
        indexI = indexI - 1
    endwhile
    return(resultS)
end

string proc FNBigSub(string aValueS, string bValueS)
    integer borrowI = 0
    integer indexI = 25
    integer diffI = 0
    string resultS[255] = ""
    while indexI > 0
        diffI = Val(SubStr(aValueS, indexI, 1)) - Val(SubStr(bValueS, indexI, 1)) - borrowI
        if diffI < 0
            diffI = diffI + 10
            borrowI = 1
        else
            borrowI = 0
        endif
        resultS = Str(diffI) + resultS
        indexI = indexI - 1
    endwhile
    return(resultS)
end

string proc FNReplaceChar(string sValueS, integer positionI, integer valI)
    string leftPartS[255] = ""
    string rightPartS[255] = ""
    if positionI > 1
        leftPartS = SubStr(sValueS, 1, positionI - 1)
    endif
    if positionI < Length(sValueS)
        rightPartS = SubStr(sValueS, positionI + 1, Length(sValueS) - positionI)
    endif
    return(leftPartS + Str(valI) + rightPartS)
end

string proc FNBigMul(string aValueS, string bValueS)
    string resultS[255] = "00000000000000000000000000000000000000000000000000"
    integer indexI = 0
    integer jIndexI = 0
    integer pOneI = 0
    integer pTwoI = 0
    integer sumI = 0
    integer carryI = 0
    for indexI = 25 downto 1
        carryI = 0
        for jIndexI = 25 downto 1
            pOneI = indexI + jIndexI - 1
            pTwoI = indexI + jIndexI
            sumI = Val(SubStr(aValueS, indexI, 1)) * Val(SubStr(bValueS, jIndexI, 1)) + Val(SubStr(resultS, pTwoI, 1)) + carryI
            carryI = sumI / 10
            resultS = FNReplaceChar(resultS, pTwoI, sumI MOD 10)
        endfor
        resultS = FNReplaceChar(resultS, indexI, carryI)
    endfor
    return(SubStr(resultS, 5, 25))
end

string proc FNBigDiv(string aValueS, string bValueS)
    string quotientS[255] = ""
    string remainderS[255] = aValueS
    integer indexI = 0
    integer digitI = 0
    for indexI = 1 to 22
        digitI = 0
        while FNBigCmp(remainderS, bValueS) >= 0
            remainderS = FNBigSub(remainderS, bValueS)
            digitI = digitI + 1
        endwhile
        quotientS = quotientS + Str(digitI)
        remainderS = SubStr(remainderS, 2, 24) + "0"
    endfor
    return("000" + quotientS)
end

string proc FNBigAvg(string aValueS, string bValueS)
    string sumStrS[255] = FNBigAdd(aValueS, bValueS)
    string resultS[255] = ""
    integer indexI = 0
    integer carryI = 0
    integer digitI = 0
    for indexI = 1 to 25
        digitI = carryI * 10 + Val(SubStr(sumStrS, indexI, 1))
        resultS = resultS + Str(digitI / 2)
        carryI = digitI MOD 2
    endfor
    return(resultS)
end

string proc FNMakeBig(string intPartS)
    string padS[255] = "0000" + intPartS
    return(SubStr(padS, Length(padS) - 3, 4) + "000000000000000000000")
end

string proc FNRoundTen(string qStrS)
    string epsS[255] = "0000000000000050000000000"
    string roundedS[255] = FNBigAdd(qStrS, epsS)
    string intPS[255] = Str(Val(SubStr(roundedS, 1, 4)))
    string decPS[255] = SubStr(roundedS, 5, 10)
    return(intPS + "." + decPS)
end

// -------------------------------------------------------------------------
// Probability Calculation (Dynamic Programming)
// -------------------------------------------------------------------------

string proc FNCalcProb(string qValueS)
    string dpZeroS[255] = FNMakeBig("1")
    string dpOneS[255] = FNMakeBig("0")
    string dpTwoS[255] = FNMakeBig("0")
    string dpThreeS[255] = FNMakeBig("0")
    string dpFourS[255] = FNMakeBig("0")
    string dpFiveS[255] = FNMakeBig("0")
    string dpSixS[255] = FNMakeBig("0")
    string dpSevenS[255] = FNMakeBig("0")
    string dpEightS[255] = FNMakeBig("0")
    string dpNineS[255] = FNMakeBig("0")
    string dpTenS[255] = FNMakeBig("0")
    string dpElevenS[255] = FNMakeBig("0")
    string dpTwelveS[255] = FNMakeBig("0")
    string dpThirteenS[255] = FNMakeBig("0")
    string dpFourteenS[255] = FNMakeBig("0")
    string dpFifteenS[255] = FNMakeBig("0")
    string dpSixteenS[255] = FNMakeBig("0")
    string dpSeventeenS[255] = FNMakeBig("0")
    string dpEighteenS[255] = FNMakeBig("0")
    string dpNineteenS[255] = FNMakeBig("0")
    string dpTwentyS[255] = FNMakeBig("0")
    
    string sxS[255] = ""
    string pMissS[255] = ""
    string pScoreS[255] = ""
    string oneS[255] = FNMakeBig("1")
    integer indexI = 0
    
    for indexI = 1 to 50
        sxS = FNMakeBig(Str(indexI))
        pMissS = FNBigDiv(sxS, qValueS)
        pScoreS = FNBigSub(oneS, pMissS)
        
        dpTwentyS = FNBigAdd(FNBigMul(dpNineteenS, pScoreS), FNBigMul(dpTwentyS, pMissS))
        dpNineteenS = FNBigAdd(FNBigMul(dpEighteenS, pScoreS), FNBigMul(dpNineteenS, pMissS))
        dpEighteenS = FNBigAdd(FNBigMul(dpSeventeenS, pScoreS), FNBigMul(dpEighteenS, pMissS))
        dpSeventeenS = FNBigAdd(FNBigMul(dpSixteenS, pScoreS), FNBigMul(dpSeventeenS, pMissS))
        dpSixteenS = FNBigAdd(FNBigMul(dpFifteenS, pScoreS), FNBigMul(dpSixteenS, pMissS))
        dpFifteenS = FNBigAdd(FNBigMul(dpFourteenS, pScoreS), FNBigMul(dpFifteenS, pMissS))
        dpFourteenS = FNBigAdd(FNBigMul(dpThirteenS, pScoreS), FNBigMul(dpFourteenS, pMissS))
        dpThirteenS = FNBigAdd(FNBigMul(dpTwelveS, pScoreS), FNBigMul(dpThirteenS, pMissS))
        dpTwelveS = FNBigAdd(FNBigMul(dpElevenS, pScoreS), FNBigMul(dpTwelveS, pMissS))
        dpElevenS = FNBigAdd(FNBigMul(dpTenS, pScoreS), FNBigMul(dpElevenS, pMissS))
        dpTenS = FNBigAdd(FNBigMul(dpNineS,  pScoreS), FNBigMul(dpTenS, pMissS))
        dpNineS  = FNBigAdd(FNBigMul(dpEightS,  pScoreS), FNBigMul(dpNineS, pMissS))
        dpEightS  = FNBigAdd(FNBigMul(dpSevenS,  pScoreS), FNBigMul(dpEightS, pMissS))
        dpSevenS  = FNBigAdd(FNBigMul(dpSixS,  pScoreS), FNBigMul(dpSevenS, pMissS))
        dpSixS  = FNBigAdd(FNBigMul(dpFiveS,  pScoreS), FNBigMul(dpSixS, pMissS))
        dpFiveS  = FNBigAdd(FNBigMul(dpFourS,  pScoreS), FNBigMul(dpFiveS, pMissS))
        dpFourS  = FNBigAdd(FNBigMul(dpThreeS,  pScoreS), FNBigMul(dpFourS, pMissS))
        dpThreeS  = FNBigAdd(FNBigMul(dpTwoS,  pScoreS), FNBigMul(dpThreeS, pMissS))
        dpTwoS  = FNBigAdd(FNBigMul(dpOneS,  pScoreS), FNBigMul(dpTwoS, pMissS))
        dpOneS  = FNBigAdd(FNBigMul(dpZeroS,  pScoreS), FNBigMul(dpOneS, pMissS))
        dpZeroS  = FNBigMul(dpZeroS, pMissS)
    endfor
    
    return(dpTwentyS)
end

// -------------------------------------------------------------------------
// Main Execution Engine
// -------------------------------------------------------------------------

proc Main()
    string lowS[255] = FNMakeBig("50")
    string highS[255] = FNMakeBig("55")
    string targetS[255] = "0000020000000000000000000" // 0.02 exactly
    string midS[255] = ""
    string probS[255] = ""
    string ansS[255] = ""
    integer iterI = 0
    
    // 65 iterations ensures precision well beyond 10 decimal places
    for iterI = 1 to 65
        midS = FNBigAvg(lowS, highS)
        probS = FNCalcProb(midS)
        
        if FNBigCmp(probS, targetS) > 0
            lowS = midS
        else
            highS = midS
        endif
    endfor
    
    ansS = FNRoundTen(midS)
    
    CopyToWinClip(ansS)
    Warn(ansS)
    CopyToWinClip(ansS)
end
