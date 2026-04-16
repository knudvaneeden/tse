// Project Euler Problem 288
// Version: 3
// History:
// Created by Google Gemini (Pro mode)
// Version 2: Attempted array simulation using buffers
// Version 3: Implemented Legendre's Formula. Bypassed arrays completely using O(1) space optimization.

INTEGER PROC FNMulModI(INTEGER aI, INTEGER bI, INTEGER mI)
    INTEGER resI = 0
    aI = aI MOD mI
    WHILE bI > 0
        IF (bI MOD 2) == 1
            resI = (resI + aI) MOD mI
        ENDIF
        aI = (aI * 2) MOD mI
        bI = bI / 2
    ENDWHILE
    RETURN (resI)
END

STRING PROC FNMultiplyS(STRING aS, INTEGER bI)
    STRING resultS[255] = ""
    INTEGER carryI = 0
    INTEGER indexI = 0
    INTEGER lengthI = Length(aS)
    INTEGER digitI = 0
    INTEGER prodI = 0

    IF aS == "0" OR bI == 0
        RETURN ("0")
    ENDIF

    FOR indexI = lengthI DOWNTO 1
        digitI = Val(SubStr(aS, indexI, 1))
        prodI = (digitI * bI) + carryI
        resultS = Str(prodI MOD 10) + resultS
        carryI = prodI / 10
    ENDFOR

    WHILE carryI > 0
        resultS = Str(carryI MOD 10) + resultS
        carryI = carryI / 10
    ENDWHILE

    RETURN (resultS)
END

STRING PROC FNAddIntegerS(STRING aS, INTEGER bI)
    STRING resultS[255] = ""
    INTEGER carryI = bI
    INTEGER indexI = 0
    INTEGER lengthI = Length(aS)
    INTEGER digitI = 0
    INTEGER sumI = 0

    IF aS == "0"
        RETURN (Str(bI))
    ENDIF

    FOR indexI = lengthI DOWNTO 1
        digitI = Val(SubStr(aS, indexI, 1))
        sumI = digitI + carryI
        resultS = Str(sumI MOD 10) + resultS
        carryI = sumI / 10
    ENDFOR

    WHILE carryI > 0
        resultS = Str(carryI MOD 10) + resultS
        carryI = carryI / 10
    ENDWHILE

    RETURN (resultS)
END

PROC Main()
    INTEGER sI = 290797
    INTEGER pI = 61
    INTEGER modI = 50515093
    INTEGER sumI = 0
    INTEGER loopI = 0
    INTEGER tI = 0

    INTEGER t1I = 0, t2I = 0, t3I = 0, t4I = 0, t5I = 0
    INTEGER t6I = 0, t7I = 0, t8I = 0, t9I = 0

    INTEGER a0I = 0, a1I = 0, a2I = 0, a3I = 0, a4I = 0
    INTEGER a5I = 0, a6I = 0, a7I = 0, a8I = 0, a9I = 0

    INTEGER d0I = 0, d1I = 0, d2I = 0, d3I = 0, d4I = 0
    INTEGER d5I = 0, d6I = 0, d7I = 0, d8I = 0, d9I = 0

    INTEGER carryI = 0
    STRING answerS[255] = ""

    // First 9 terms extracted out of the massive loop to bypass conditional IFs
    FOR loopI = 1 TO 9
        sI = FNMulModI(sI, sI, modI)
        tI = sI MOD pI
        sumI = sumI + tI
        
        IF loopI == 1
            t1I = tI
        ENDIF
        IF loopI == 2
            t2I = tI
        ENDIF
        IF loopI == 3
            t3I = tI
        ENDIF
        IF loopI == 4
            t4I = tI
        ENDIF
        IF loopI == 5
            t5I = tI
        ENDIF
        IF loopI == 6
            t6I = tI
        ENDIF
        IF loopI == 7
            t7I = tI
        ENDIF
        IF loopI == 8
            t8I = tI
        ENDIF
        IF loopI == 9
            t9I = tI
        ENDIF
    ENDFOR

    // Process the remainder of the 10 million terms
    FOR loopI = 10 TO 10000000
        sI = FNMulModI(sI, sI, modI)
        tI = sI MOD pI
        sumI = sumI + tI
    ENDFOR

    // a0I is the total sum of all T_n terms. Derive successive subsets.
    a0I = sumI
    a1I = a0I - t1I
    a2I = a1I - t2I
    a3I = a2I - t3I
    a4I = a3I - t4I
    a5I = a4I - t5I
    a6I = a5I - t6I
    a7I = a6I - t7I
    a8I = a7I - t8I
    a9I = a8I - t9I

    // Resolve base p carries to naturally calculate the digits
    d0I = a0I MOD pI
    carryI = a0I / pI

    a1I = a1I + carryI
    d1I = a1I MOD pI
    carryI = a1I / pI

    a2I = a2I + carryI
    d2I = a2I MOD pI
    carryI = a2I / pI

    a3I = a3I + carryI
    d3I = a3I MOD pI
    carryI = a3I / pI

    a4I = a4I + carryI
    d4I = a4I MOD pI
    carryI = a4I / pI

    a5I = a5I + carryI
    d5I = a5I MOD pI
    carryI = a5I / pI

    a6I = a6I + carryI
    d6I = a6I MOD pI
    carryI = a6I / pI

    a7I = a7I + carryI
    d7I = a7I MOD pI
    carryI = a7I / pI

    a8I = a8I + carryI
    d8I = a8I MOD pI
    carryI = a8I / pI

    a9I = a9I + carryI
    d9I = a9I MOD pI
    
    // The final carry is intentionally discarded here. 
    // This implicitly achieves the required result "MOD 61^10"!

    // Horner's Method evaluation strictly in Base 10 String Math
    answerS = Str(d9I)
    
    answerS = FNMultiplyS(answerS, pI)
    answerS = FNAddIntegerS(answerS, d8I)

    answerS = FNMultiplyS(answerS, pI)
    answerS = FNAddIntegerS(answerS, d7I)

    answerS = FNMultiplyS(answerS, pI)
    answerS = FNAddIntegerS(answerS, d6I)

    answerS = FNMultiplyS(answerS, pI)
    answerS = FNAddIntegerS(answerS, d5I)

    answerS = FNMultiplyS(answerS, pI)
    answerS = FNAddIntegerS(answerS, d4I)

    answerS = FNMultiplyS(answerS, pI)
    answerS = FNAddIntegerS(answerS, d3I)

    answerS = FNMultiplyS(answerS, pI)
    answerS = FNAddIntegerS(answerS, d2I)

    answerS = FNMultiplyS(answerS, pI)
    answerS = FNAddIntegerS(answerS, d1I)

    answerS = FNMultiplyS(answerS, pI)
    answerS = FNAddIntegerS(answerS, d0I)

    CopyToWinClip(answerS)
    Warn(answerS)
    CopyToWinClip(answerS)
END
