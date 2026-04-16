/*
  =============================================================================
  TSE SAL Program: Project Euler Problem 283
  Version: 3
  Created by: Google Gemini (Pro Mode)

  Description:
  Calculates the sum of perimeters of all integer-sided triangles
  for which the ratio of Area to perimeter (A/p) is an integer m <= 1000.

  TSE SAL Rules Applied:
  - ALL variables initialized immediately after the function header.
  - Added FNBigModIntI to prevent fractional z-side truncation bugs.
  - Pure TSE SAL language.
  - Fully calculated, no hardcoding of the final answer.
  - No Python or external circumvention.
  - Big Integer string calculations for values exceeding 2^31 - 1.
  - camelCase for local variables; starting with lower case if > 1 character.
  - 'I' suffix for local integers, 'S' suffix for local strings.
  - 'GI' and 'GS' for global variables.
  - 'PROC' prefix for procedures.
  - 'FN' prefix for functions.
  - MOD used instead of '%'.
  - Parentheses used for RETURN().
  - No 'val' or 'pos' as variable names.
  - Warn() only at the end.
  - CopyToWinClip() before and after the final Warn().
  =============================================================================
*/

// Global Sum for the final answer
STRING globalSumGS[255] = "0"

// Global arrays implemented as distinct variables (max 20 prime factors)
INTEGER totalPrimeFactorsGI = 0

INTEGER primeFact1GI = 0, primeCount1GI = 0
INTEGER primeFact2GI = 0, primeCount2GI = 0
INTEGER primeFact3GI = 0, primeCount3GI = 0
INTEGER primeFact4GI = 0, primeCount4GI = 0
INTEGER primeFact5GI = 0, primeCount5GI = 0
INTEGER primeFact6GI = 0, primeCount6GI = 0
INTEGER primeFact7GI = 0, primeCount7GI = 0
INTEGER primeFact8GI = 0, primeCount8GI = 0
INTEGER primeFact9GI = 0, primeCount9GI = 0
INTEGER primeFact10GI = 0, primeCount10GI = 0
INTEGER primeFact11GI = 0, primeCount11GI = 0
INTEGER primeFact12GI = 0, primeCount12GI = 0
INTEGER primeFact13GI = 0, primeCount13GI = 0
INTEGER primeFact14GI = 0, primeCount14GI = 0
INTEGER primeFact15GI = 0, primeCount15GI = 0
INTEGER primeFact16GI = 0, primeCount16GI = 0
INTEGER primeFact17GI = 0, primeCount17GI = 0
INTEGER primeFact18GI = 0, primeCount18GI = 0
INTEGER primeFact19GI = 0, primeCount19GI = 0
INTEGER primeFact20GI = 0, primeCount20GI = 0

// Big Integer Addition
STRING PROC FNBigAddS(STRING aS, STRING bS)
    STRING resS[255] = ""
    INTEGER carryI = 0
    INTEGER sumI = 0
    INTEGER iI = 0
    INTEGER jI = 0

    iI = Length(aS)
    jI = Length(bS)

    WHILE iI > 0 OR jI > 0 OR carryI > 0
        sumI = carryI
        IF iI > 0
            sumI = sumI + Val(SubStr(aS, iI, 1))
            iI = iI - 1
        ENDIF
        IF jI > 0
            sumI = sumI + Val(SubStr(bS, jI, 1))
            jI = jI - 1
        ENDIF
        resS = Chr((sumI MOD 10) + 48) + resS
        carryI = sumI / 10
    ENDWHILE

    IF resS == ""
        resS = "0"
    ENDIF

    RETURN (resS)
END

// Big Integer Multiply by standard Integer
STRING PROC FNBigMulIntS(STRING aS, INTEGER bI)
    STRING resS[255] = ""
    INTEGER carryI = 0
    INTEGER valueI = 0
    INTEGER iI = 0

    IF aS == "0" OR bI == 0
        RETURN ("0")
    ENDIF

    iI = Length(aS)

    WHILE iI > 0 OR carryI > 0
        valueI = carryI
        IF iI > 0
            valueI = valueI + Val(SubStr(aS, iI, 1)) * bI
            iI = iI - 1
        ENDIF
        resS = Chr((valueI MOD 10) + 48) + resS
        carryI = valueI / 10
    ENDWHILE

    RETURN (resS)
END

// Big Integer Divide by standard Integer
STRING PROC FNBigDivIntS(STRING aS, INTEGER bI)
    STRING resS[255] = ""
    INTEGER remI = 0
    INTEGER iI = 1
    INTEGER qI = 0

    IF bI == 0 
        RETURN ("0") 
    ENDIF

    WHILE iI <= Length(aS)
        remI = remI * 10 + Val(SubStr(aS, iI, 1))
        qI = remI / bI
        IF resS <> "" OR qI > 0
            resS = resS + Str(qI)
        ENDIF
        remI = remI MOD bI
        iI = iI + 1
    ENDWHILE

    IF resS == ""
        resS = "0"
    ENDIF

    RETURN (resS)
END

// Big Integer Modulo by standard Integer
INTEGER PROC FNBigModIntI(STRING aS, INTEGER bI)
    INTEGER remI = 0
    INTEGER iI = 1

    IF bI == 0 
        RETURN (0) 
    ENDIF

    WHILE iI <= Length(aS)
        remI = (remI * 10 + Val(SubStr(aS, iI, 1))) MOD bI
        iI = iI + 1
    ENDWHILE

    RETURN (remI)
END

// Big Integer Compare (Returns 1 if a > b, -1 if a < b, 0 if equal)
INTEGER PROC FNBigCompareS(STRING aS, STRING bS)
    INTEGER lenAI = 0
    INTEGER lenBI = 0

    lenAI = Length(aS)
    lenBI = Length(bS)

    IF lenAI < lenBI 
        RETURN (-1) 
    ENDIF
    IF lenAI > lenBI 
        RETURN (1) 
    ENDIF
    IF aS < bS 
        RETURN (-1) 
    ENDIF
    IF aS > bS 
        RETURN (1) 
    ENDIF

    RETURN (0)
END

// Integer Square Root for Big Integers
INTEGER PROC FNISqrtI(STRING nS)
    INTEGER lowI = 1
    INTEGER highI = 8000000
    INTEGER midI = 0
    STRING midSqS[255] = ""

    WHILE lowI <= highI
        midI = lowI + (highI - lowI) / 2
        midSqS = FNBigMulIntS(Str(midI), midI)
        IF FNBigCompareS(midSqS, nS) == 0
            RETURN (midI)
        ENDIF
        IF FNBigCompareS(midSqS, nS) < 0
            lowI = midI + 1
        ELSE
            highI = midI - 1
        ENDIF
    ENDWHILE

    RETURN (highI)
END

// Simulated Arrays for Prime Factors
INTEGER PROC FNGetPrimeFactI(INTEGER idxI)
    CASE idxI
        WHEN 1 RETURN (primeFact1GI)
        WHEN 2 RETURN (primeFact2GI)
        WHEN 3 RETURN (primeFact3GI)
        WHEN 4 RETURN (primeFact4GI)
        WHEN 5 RETURN (primeFact5GI)
        WHEN 6 RETURN (primeFact6GI)
        WHEN 7 RETURN (primeFact7GI)
        WHEN 8 RETURN (primeFact8GI)
        WHEN 9 RETURN (primeFact9GI)
        WHEN 10 RETURN (primeFact10GI)
        WHEN 11 RETURN (primeFact11GI)
        WHEN 12 RETURN (primeFact12GI)
        WHEN 13 RETURN (primeFact13GI)
        WHEN 14 RETURN (primeFact14GI)
        WHEN 15 RETURN (primeFact15GI)
        WHEN 16 RETURN (primeFact16GI)
        WHEN 17 RETURN (primeFact17GI)
        WHEN 18 RETURN (primeFact18GI)
        WHEN 19 RETURN (primeFact19GI)
        WHEN 20 RETURN (primeFact20GI)
    ENDCASE
    RETURN (0)
END

INTEGER PROC FNGetPrimeCountI(INTEGER idxI)
    CASE idxI
        WHEN 1 RETURN (primeCount1GI)
        WHEN 2 RETURN (primeCount2GI)
        WHEN 3 RETURN (primeCount3GI)
        WHEN 4 RETURN (primeCount4GI)
        WHEN 5 RETURN (primeCount5GI)
        WHEN 6 RETURN (primeCount6GI)
        WHEN 7 RETURN (primeCount7GI)
        WHEN 8 RETURN (primeCount8GI)
        WHEN 9 RETURN (primeCount9GI)
        WHEN 10 RETURN (primeCount10GI)
        WHEN 11 RETURN (primeCount11GI)
        WHEN 12 RETURN (primeCount12GI)
        WHEN 13 RETURN (primeCount13GI)
        WHEN 14 RETURN (primeCount14GI)
        WHEN 15 RETURN (primeCount15GI)
        WHEN 16 RETURN (primeCount16GI)
        WHEN 17 RETURN (primeCount17GI)
        WHEN 18 RETURN (primeCount18GI)
        WHEN 19 RETURN (primeCount19GI)
        WHEN 20 RETURN (primeCount20GI)
    ENDCASE
    RETURN (0)
END

PROC PROCSetPrimeFact(INTEGER idxI, INTEGER primeValueI)
    CASE idxI
        WHEN 1 primeFact1GI = primeValueI
        WHEN 2 primeFact2GI = primeValueI
        WHEN 3 primeFact3GI = primeValueI
        WHEN 4 primeFact4GI = primeValueI
        WHEN 5 primeFact5GI = primeValueI
        WHEN 6 primeFact6GI = primeValueI
        WHEN 7 primeFact7GI = primeValueI
        WHEN 8 primeFact8GI = primeValueI
        WHEN 9 primeFact9GI = primeValueI
        WHEN 10 primeFact10GI = primeValueI
        WHEN 11 primeFact11GI = primeValueI
        WHEN 12 primeFact12GI = primeValueI
        WHEN 13 primeFact13GI = primeValueI
        WHEN 14 primeFact14GI = primeValueI
        WHEN 15 primeFact15GI = primeValueI
        WHEN 16 primeFact16GI = primeValueI
        WHEN 17 primeFact17GI = primeValueI
        WHEN 18 primeFact18GI = primeValueI
        WHEN 19 primeFact19GI = primeValueI
        WHEN 20 primeFact20GI = primeValueI
    ENDCASE
END

PROC PROCSetPrimeCount(INTEGER idxI, INTEGER countValueI)
    CASE idxI
        WHEN 1 primeCount1GI = countValueI
        WHEN 2 primeCount2GI = countValueI
        WHEN 3 primeCount3GI = countValueI
        WHEN 4 primeCount4GI = countValueI
        WHEN 5 primeCount5GI = countValueI
        WHEN 6 primeCount6GI = countValueI
        WHEN 7 primeCount7GI = countValueI
        WHEN 8 primeCount8GI = countValueI
        WHEN 9 primeCount9GI = countValueI
        WHEN 10 primeCount10GI = countValueI
        WHEN 11 primeCount11GI = countValueI
        WHEN 12 primeCount12GI = countValueI
        WHEN 13 primeCount13GI = countValueI
        WHEN 14 primeCount14GI = countValueI
        WHEN 15 primeCount15GI = countValueI
        WHEN 16 primeCount16GI = countValueI
        WHEN 17 primeCount17GI = countValueI
        WHEN 18 primeCount18GI = countValueI
        WHEN 19 primeCount19GI = countValueI
        WHEN 20 primeCount20GI = countValueI
    ENDCASE
END

PROC PROCAddPrimeFactor(INTEGER pI)
    INTEGER iI = 1
    INTEGER factI = 0

    WHILE iI <= totalPrimeFactorsGI
        factI = FNGetPrimeFactI(iI)
        IF factI == pI
            PROCSetPrimeCount(iI, FNGetPrimeCountI(iI) + 1)
            RETURN()
        ENDIF
        iI = iI + 1
    ENDWHILE

    totalPrimeFactorsGI = totalPrimeFactorsGI + 1
    PROCSetPrimeFact(totalPrimeFactorsGI, pI)
    PROCSetPrimeCount(totalPrimeFactorsGI, 1)
END

PROC PROCAddFactors(INTEGER nI)
    INTEGER dI = 2
    INTEGER stepI = 2

    WHILE (nI MOD dI) == 0
        PROCAddPrimeFactor(dI)
        nI = nI / dI
    ENDWHILE

    dI = 3

    WHILE (nI MOD dI) == 0
        PROCAddPrimeFactor(dI)
        nI = nI / dI
    ENDWHILE

    dI = 5
    stepI = 2

    WHILE (dI * dI) <= nI
        IF (nI MOD dI) == 0
            WHILE (nI MOD dI) == 0
                PROCAddPrimeFactor(dI)
                nI = nI / dI
            ENDWHILE
        ENDIF
        dI = dI + stepI
        stepI = 6 - stepI
    ENDWHILE

    IF nI > 1
        PROCAddPrimeFactor(nI)
    ENDIF
END

PROC PROCGenerateDivisors(INTEGER factorIndexI, INTEGER currentDivisorI, INTEGER uI, INTEGER targetModI, INTEGER usqI, INTEGER maxAI, STRING nStrS)
    INTEGER pFactI = 0
    INTEGER pCountI = 0
    INTEGER iI = 0
    INTEGER nextDivisorI = 0
    INTEGER maxMultI = 0
    STRING bS[255] = ""
    INTEGER vI = 0
    STRING wS[255] = ""
    STRING pS[255] = ""

    IF factorIndexI > totalPrimeFactorsGI
        IF currentDivisorI <= maxAI
            IF currentDivisorI >= (uI * uI - usqI)
                IF (currentDivisorI MOD uI) == targetModI
                    // Extracting the complementary divisor (N/D)
                    bS = FNBigDivIntS(nStrS, currentDivisorI)
                    // Ensuring z will be an integer before adding to the sum!
                    IF FNBigModIntI(bS, uI) == targetModI
                        vI = (currentDivisorI + usqI) / uI
                        wS = FNBigAddS(bS, Str(usqI))
                        wS = FNBigDivIntS(wS, uI)
                        pS = FNBigAddS(wS, Str(uI + vI))
                        pS = FNBigMulIntS(pS, 2)
                        globalSumGS = FNBigAddS(globalSumGS, pS)
                    ENDIF
                ENDIF
            ENDIF
        ENDIF
        RETURN()
    ENDIF

    pFactI = FNGetPrimeFactI(factorIndexI)
    pCountI = FNGetPrimeCountI(factorIndexI)
    iI = 0
    nextDivisorI = currentDivisorI

    WHILE iI <= pCountI
        PROCGenerateDivisors(factorIndexI + 1, nextDivisorI, uI, targetModI, usqI, maxAI, nStrS)
        iI = iI + 1
        IF iI <= pCountI
            maxMultI = maxAI / pFactI
            IF nextDivisorI > maxMultI
                BREAK
            ENDIF
            nextDivisorI = nextDivisorI * pFactI
        ENDIF
    ENDWHILE
END

PROC Main()
    INTEGER mI = 1
    INTEGER capUI = 0
    INTEGER usqI = 0
    INTEGER uI = 0
    STRING nStrS[255] = ""
    INTEGER maxAI = 0
    INTEGER targetModI = 0

    globalSumGS = "0"

    WHILE mI <= 1000
        capUI = 2 * mI
        usqI = capUI * capUI
        uI = 1

        WHILE (uI * uI) <= (3 * usqI)
            totalPrimeFactorsGI = 0

            PROCAddFactors(capUI)
            PROCAddFactors(capUI)
            PROCAddFactors(uI * uI + usqI)

            nStrS = FNBigMulIntS(Str(usqI), uI * uI + usqI)
            maxAI = FNISqrtI(nStrS)

            targetModI = uI - (usqI MOD uI)
            IF targetModI == uI
                targetModI = 0
            ENDIF

            PROCGenerateDivisors(1, 1, uI, targetModI, usqI, maxAI, nStrS)

            uI = uI + 1
        ENDWHILE
        mI = mI + 1
    ENDWHILE

    CopyToWinClip(globalSumGS)
    Warn("Final Answer: ", globalSumGS)
    CopyToWinClip(globalSumGS)
END
