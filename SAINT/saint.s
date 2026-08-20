// saint.s
// Text-based SAINT symbolic integrator for The SemWare Editor (TSE) SAL
// Version: 1.0.0.1.63 FULL_COVERAGE
// Model: OpenAI GPT-5.6
//
// Native SAL implementation inspired by James Robert Slagle's SAINT.

// http://108.181.171.91/ddd.php?tseMacroS=c:/bbc/taal/saint.mac^%20-p^%20int^%20x^%20dx

// #DEFINE DEBUG 1
#DEFINE DEBUG 0
//
// #DEFINE TSEREMOTESERVER 1
#DEFINE TSEREMOTESERVER 0
//

INTEGER resultBufferGI = 0
INTEGER rulesBufferGI = 0
INTEGER ruleCountGI = 0
INTEGER debugStepGI = 0
STRING programNameGS[40] = ""
STRING programVersionGS[30] = ""

FORWARD PROC Main()
FORWARD PROC PROCDebug(STRING messageS)
FORWARD PROC PROCReason(STRING reasonS)
FORWARD PROC PROCWriteHeader(STRING inputS, STRING expressionS)
FORWARD PROC PROCBatchProcess(INTEGER origFileI, INTEGER resBufferI)
FORWARD STRING PROC FNRemoveSpacesS(STRING sourceS)
FORWARD INTEGER PROC FNIsDigitsB(STRING sourceS)
FORWARD INTEGER PROC FNIsSignedIntegerB(STRING sourceS)
FORWARD INTEGER PROC FNMatchingOuterParenthesesB(STRING sourceS)
FORWARD STRING PROC FNStripOuterParenthesesS(STRING sourceS)
FORWARD INTEGER PROC FNTopOperatorI(STRING sourceS, STRING operatorsS)
FORWARD INTEGER PROC FNContainsVariableB(STRING sourceS, STRING variableS)
FORWARD INTEGER PROC FNFunctionArgumentB(STRING sourceS, STRING functionS, VAR STRING argumentS)
FORWARD INTEGER PROC FNLinearCoefficientI(STRING argumentS, STRING variableS, VAR STRING coefficientS)
FORWARD STRING PROC FNDivideByCoefficientS(STRING numeratorS, STRING coefficientS)
FORWARD INTEGER PROC FNParseQuadraticB(STRING exprS, STRING varS, VAR STRING aS, VAR STRING bS, VAR STRING cS)
FORWARD STRING PROC FNExtractInputS(STRING inputS, VAR STRING variableS)
FORWARD INTEGER PROC FNMatchTemplateB(STRING patternS, STRING exprS, VAR STRING aS, VAR STRING bS, VAR STRING cS, VAR STRING dS, VAR STRING eS, VAR STRING mS, VAR STRING nS)
FORWARD STRING PROC FNReplaceTemplateS(STRING ansS, STRING aS, STRING bS, STRING cS, STRING dS, STRING eS, STRING mS, STRING nS)
FORWARD STRING PROC FNIntegrateCoreS(STRING expressionS, STRING variableS)
FORWARD STRING PROC FNIntegrateTermS(STRING expressionS, STRING variableS)
FORWARD STRING PROC FNIntegrateSpecialS(STRING expressionS, STRING variableS)
FORWARD STRING PROC FNIntegrateAdvancedFormsS(STRING expressionS)
FORWARD STRING PROC FNIntegrateS(STRING expressionS, STRING variableS)
FORWARD STRING PROC FNStringGetQueryCommandLineS( STRING fileNameMacroS )

PROC PROCDebug(STRING messageS)
    debugStepGI = debugStepGI + 1
    IF messageS == ""
    ENDIF
END

PROC PROCReason(STRING reasonS)
    INTEGER origBufferI = 0
    origBufferI = GetBufferId()
    ruleCountGI = ruleCountGI + 1
    GotoBufferId(resultBufferGI)
    EndFile()

 #IF TSEREMOTESERVER
   FWrite( _STDOUT_, " " + Str(ruleCountGI) + ". " + reasonS + " Result: " + " " )
 #ELSE
    AddLine("  " + Str(ruleCountGI) + ". " + reasonS)
    GotoBufferId(origBufferI)
 #ENDIF

END

STRING PROC FNRemoveSpacesS(STRING sourceS)
    STRING resultS[255] = ""
    STRING s[1] = ""
    INTEGER I = 0
    FOR I = 1 TO Length(sourceS)
        s = SubStr(sourceS, I, 1)
        IF s <> " "
            IF s <> Chr(9)
                resultS = resultS + s
            ENDIF
        ENDIF
    ENDFOR
    RETURN(resultS)
END

INTEGER PROC FNIsDigitsB(STRING sourceS)
    INTEGER I = 0
    STRING s[1] = ""
    IF Length(sourceS) == 0
        RETURN(FALSE)
    ENDIF
    FOR I = 1 TO Length(sourceS)
        s = SubStr(sourceS, I, 1)
        IF s < "0"
            RETURN(FALSE)
        ELSEIF s > "9"
            RETURN(FALSE)
        ENDIF
    ENDFOR
    RETURN(TRUE)
END

INTEGER PROC FNIsSignedIntegerB(STRING sourceS)
    STRING workS[255] = ""
    workS = sourceS
    IF SubStr(workS, 1, 1) == "-"
        workS = SubStr(workS, 2, 255)
    ENDIF
    RETURN(FNIsDigitsB(workS))
END

INTEGER PROC FNMatchingOuterParenthesesB(STRING sourceS)
    INTEGER depthI = 0
    INTEGER I = 0
    STRING s[1] = ""
    IF Length(sourceS) < 2
        RETURN(FALSE)
    ENDIF
    IF SubStr(sourceS, 1, 1) <> "("
        RETURN(FALSE)
    ENDIF
    IF SubStr(sourceS, Length(sourceS), 1) <> ")"
        RETURN(FALSE)
    ENDIF
    FOR I = 1 TO Length(sourceS)
        s = SubStr(sourceS, I, 1)
        IF s == "("
            depthI = depthI + 1
        ELSEIF s == ")"
            depthI = depthI - 1
            IF depthI == 0
                IF I < Length(sourceS)
                    RETURN(FALSE)
                ENDIF
            ENDIF
        ENDIF
    ENDFOR
    IF depthI == 0
        RETURN(TRUE)
    ENDIF
    RETURN(FALSE)
END

STRING PROC FNStripOuterParenthesesS(STRING sourceS)
    STRING workS[255] = ""
    INTEGER guardI = 0
    workS = sourceS
    WHILE FNMatchingOuterParenthesesB(workS)
        IF guardI > 128
            BREAK
        ENDIF
        guardI = guardI + 1
        workS = SubStr(workS, 2, Length(workS) - 2)
    ENDWHILE
    RETURN(workS)
END

INTEGER PROC FNTopOperatorI(STRING sourceS, STRING operatorsS)
    INTEGER depthI = 0
    INTEGER I = 0
    STRING s[1] = ""
    FOR I = Length(sourceS) DOWNTO 1
        s = SubStr(sourceS, I, 1)
        IF s == ")"
            depthI = depthI + 1
        ELSEIF s == "("
            depthI = depthI - 1
        ELSEIF depthI == 0
            IF Pos(s, operatorsS) > 0
                IF I > 1
                    RETURN(I)
                ENDIF
            ENDIF
        ENDIF
    ENDFOR
    RETURN(0)
END

INTEGER PROC FNContainsVariableB(STRING sourceS, STRING variableS)
    IF Pos(variableS, sourceS) > 0
        RETURN(TRUE)
    ENDIF
    RETURN(FALSE)
END

INTEGER PROC FNFunctionArgumentB(STRING sourceS, STRING functionS, VAR STRING argumentS)
    STRING prefixS[40] = ""
    argumentS = ""
    prefixS = functionS + "("
    IF SubStr(sourceS, 1, Length(prefixS)) == prefixS
        IF SubStr(sourceS, Length(sourceS), 1) == ")"
            argumentS = SubStr(sourceS, Length(prefixS) + 1, Length(sourceS) - Length(prefixS) - 1)
            RETURN(TRUE)
        ENDIF
    ENDIF
    RETURN(FALSE)
END

INTEGER PROC FNLinearCoefficientI(STRING argumentS, STRING variableS, VAR STRING coefficientS)
    STRING workS[255] = ""
    INTEGER starI = 0
    coefficientS = ""
    workS = FNStripOuterParenthesesS(argumentS)
    IF workS == variableS
        coefficientS = "1"
        RETURN(TRUE)
    ENDIF
    IF workS == ("-" + variableS)
        coefficientS = "-1"
        RETURN(TRUE)
    ENDIF
    starI = FNTopOperatorI(workS, "*")
    IF starI > 0
        IF SubStr(workS, starI + 1, 255) == variableS
            coefficientS = SubStr(workS, 1, starI - 1)
            IF FNContainsVariableB(coefficientS, variableS) == FALSE
                RETURN(TRUE)
            ENDIF
        ENDIF
    ENDIF
    RETURN(FALSE)
END

STRING PROC FNDivideByCoefficientS(STRING numeratorS, STRING coefficientS)
    IF coefficientS == "1"
        RETURN(numeratorS)
    ELSEIF coefficientS == "-1"
        RETURN("-(" + numeratorS + ")")
    ENDIF
    RETURN("(" + numeratorS + ") / (" + coefficientS + ")")
END

INTEGER PROC FNParseQuadraticB(STRING exprS, STRING varS, VAR STRING aS, VAR STRING bS, VAR STRING cS)
    STRING workS[255] = ""
    STRING termS[255] = ""
    STRING s[1] = ""
    STRING signS[1] = "+"
    STRING coeffS[255] = ""
    INTEGER I = 0
    INTEGER startI = 1
    INTEGER splitB = 0
    INTEGER atEndB = 0
    INTEGER depthI = 0
    INTEGER posI = 0

    aS = "0"
    bS = "0"
    cS = "0"

    workS = FNStripOuterParenthesesS(exprS)

    FOR I = 1 TO Length(workS) + 1
        IF I > Length(workS)
            atEndB = TRUE
        ELSE
            atEndB = FALSE
        ENDIF

        splitB = FALSE
        IF atEndB == FALSE
            s = SubStr(workS, I, 1)
            IF s == "("
                depthI = depthI + 1
            ELSEIF s == ")"
                depthI = depthI - 1
            ELSEIF depthI == 0
                IF I > startI
                    IF s == "+"
                        splitB = TRUE
                    ELSEIF s == "-"
                        splitB = TRUE
                    ENDIF
                ENDIF
            ENDIF
        ELSE
            splitB = TRUE
        ENDIF

        IF splitB
            termS = Trim(SubStr(workS, startI, I - startI))
            IF signS == "-"
                termS = "-" + termS
            ENDIF

            posI = Pos(varS + "^2", termS)
            IF posI > 0
                IF posI == 1
                    coeffS = "1"
                ELSE
                    coeffS = SubStr(termS, 1, posI - 1)
                    IF SubStr(coeffS, Length(coeffS), 1) == "*"
                        coeffS = SubStr(coeffS, 1, Length(coeffS) - 1)
                    ENDIF
                    IF coeffS == "-"
                        coeffS = "-1"
                    ENDIF
                    IF coeffS == "+"
                        coeffS = "1"
                    ENDIF
                ENDIF
                IF posI + Length(varS) + 1 < Length(termS)
                    coeffS = coeffS + SubStr(termS, posI + Length(varS) + 2, 255)
                ENDIF
                aS = coeffS
            ELSE
                posI = Pos(varS, termS)
                IF posI > 0
                    IF posI == 1
                        coeffS = "1"
                    ELSE
                        coeffS = SubStr(termS, 1, posI - 1)
                        IF SubStr(coeffS, Length(coeffS), 1) == "*"
                            coeffS = SubStr(coeffS, 1, Length(coeffS) - 1)
                        ENDIF
                        IF coeffS == "-"
                            coeffS = "-1"
                        ENDIF
                        IF coeffS == "+"
                            coeffS = "1"
                        ENDIF
                    ENDIF
                    IF posI + Length(varS) - 1 < Length(termS)
                        coeffS = coeffS + SubStr(termS, posI + Length(varS), 255)
                    ENDIF
                    bS = coeffS
                ELSE
                    IF cS == "0"
                        cS = termS
                    ELSE
                        IF SubStr(termS, 1, 1) == "-"
                            cS = cS + termS
                        ELSE
                            cS = cS + "+" + termS
                        ENDIF
                    ENDIF
                ENDIF
            ENDIF

            IF atEndB == FALSE
                signS = s
                startI = I + 1
            ENDIF
        ENDIF
    ENDFOR
    RETURN(TRUE)
END

STRING PROC FNExtractInputS(STRING inputS, VAR STRING variableS)
    STRING workS[255] = ""
    INTEGER dxI = 0
    variableS = ""
    workS = Lower(Trim(inputS))
    IF SubStr(workS, 1, 4) == "int "
        workS = SubStr(workS, 5, 255)
    ELSEIF SubStr(workS, 1, 3) == "int"
        workS = SubStr(workS, 4, 255)
    ELSE
        RETURN("")
    ENDIF
    workS = Trim(workS)
    dxI = Length(workS) - 1
    IF dxI < 2
        RETURN("")
    ENDIF
    IF SubStr(workS, dxI, 2) <> "dx"
        RETURN("")
    ENDIF
    variableS = "x"
    workS = Trim(SubStr(workS, 1, dxI - 1))
    RETURN(FNRemoveSpacesS(workS))
END

INTEGER PROC FNMatchTemplateB(STRING patternS, STRING exprS, VAR STRING aS, VAR STRING bS, VAR STRING cS, VAR STRING dS, VAR STRING eS, VAR STRING mS, VAR STRING nS)
    INTEGER patI = 1
    INTEGER expI = 1
    STRING pCharS[1] = ""
    STRING eCharS[1] = ""
    STRING varNameS[1] = ""
    STRING varValS[255] = ""
    STRING nextPCharS[1] = ""

    aS = ""
    bS = ""
    cS = ""
    dS = ""
    eS = ""
    mS = ""
    nS = ""

    WHILE (patI <= Length(patternS)) AND (expI <= Length(exprS))
        pCharS = SubStr(patternS, patI, 1)

        IF pCharS == "#"
            patI = patI + 1
            varNameS = SubStr(patternS, patI, 1)
            patI = patI + 1

            IF patI > Length(patternS)
                nextPCharS = ""
            ELSE
                nextPCharS = SubStr(patternS, patI, 1)
            ENDIF

            varValS = ""
            WHILE (expI <= Length(exprS))
                eCharS = SubStr(exprS, expI, 1)
                IF eCharS == nextPCharS
                    BREAK
                ENDIF
                varValS = varValS + eCharS
                expI = expI + 1
            ENDWHILE

            IF varNameS == "a"
                IF (aS <> "") AND (aS <> varValS) RETURN(FALSE) ENDIF
                aS = varValS
            ELSEIF varNameS == "b"
                IF (bS <> "") AND (bS <> varValS) RETURN(FALSE) ENDIF
                bS = varValS
            ELSEIF varNameS == "c"
                IF (cS <> "") AND (cS <> varValS) RETURN(FALSE) ENDIF
                cS = varValS
            ELSEIF varNameS == "d"
                IF (dS <> "") AND (dS <> varValS) RETURN(FALSE) ENDIF
                dS = varValS
            ELSEIF varNameS == "e"
                IF (eS <> "") AND (eS <> varValS) RETURN(FALSE) ENDIF
                eS = varValS
            ELSEIF varNameS == "m"
                IF (mS <> "") AND (mS <> varValS) RETURN(FALSE) ENDIF
                mS = varValS
            ELSEIF varNameS == "n"
                IF (nS <> "") AND (nS <> varValS) RETURN(FALSE) ENDIF
                nS = varValS
            ENDIF
        ELSE
            eCharS = SubStr(exprS, expI, 1)
            IF pCharS <> eCharS
                RETURN(FALSE)
            ENDIF
            patI = patI + 1
            expI = expI + 1
        ENDIF
    ENDWHILE

    IF (patI > Length(patternS)) AND (expI > Length(exprS))
        RETURN(TRUE)
    ENDIF

    RETURN(FALSE)
END

STRING PROC FNReplaceTemplateS(STRING ansS, STRING aS, STRING bS, STRING cS, STRING dS, STRING eS, STRING mS, STRING nS)
    STRING resultS[255] = ""
    INTEGER I = 1
    STRING s[1] = ""

    WHILE I <= Length(ansS)
        IF SubStr(ansS, I, 1) == "#"
            s = SubStr(ansS, I+1, 1)
            IF s == "a"
                resultS = resultS + aS
                I = I + 2
            ELSEIF s == "b"
                resultS = resultS + bS
                I = I + 2
            ELSEIF s == "c"
                resultS = resultS + cS
                I = I + 2
            ELSEIF s == "d"
                resultS = resultS + dS
                I = I + 2
            ELSEIF s == "e"
                resultS = resultS + eS
                I = I + 2
            ELSEIF s == "m"
                resultS = resultS + mS
                I = I + 2
            ELSEIF s == "n"
                resultS = resultS + nS
                I = I + 2
            ELSE
                resultS = resultS + "#"
                I = I + 1
            ENDIF
        ELSE
            resultS = resultS + SubStr(ansS, I, 1)
            I = I + 1
        ENDIF
    ENDWHILE
    RETURN(resultS)
END

STRING PROC FNIntegrateSpecialS(STRING expressionS, STRING variableS)
    STRING wS[255] = ""
    wS = FNStripOuterParenthesesS(expressionS)

    IF wS == ("exp(-" + variableS + "^2)")
        PROCReason("Liouville's theorem: Requires Error Function (erf).")
        RETURN("sqrt(pi)/2 * erf(" + variableS + ")")
    ENDIF
    IF wS == ("exp(" + variableS + "^2)")
        PROCReason("Liouville's theorem: Requires Imaginary Error Function (erfi).")
        RETURN("sqrt(pi)/2 * erfi(" + variableS + ")")
    ENDIF
    IF wS == ("sin(" + variableS + "^2)")
        PROCReason("Requires Fresnel Sine Integral (FresnelS).")
        RETURN("sqrt(pi/2) * FresnelS(sqrt(2/pi)*" + variableS + ")")
    ENDIF
    IF wS == ("cos(" + variableS + "^2)")
        PROCReason("Requires Fresnel Cosine Integral (FresnelC).")
        RETURN("sqrt(pi/2) * FresnelC(sqrt(2/pi)*" + variableS + ")")
    ENDIF
    IF wS == ("1/ln(" + variableS + ")")
        PROCReason("Requires Logarithmic Integral (Li).")
        RETURN("Li(" + variableS + ")")
    ENDIF
    IF wS == ("sin(" + variableS + ")/" + variableS)
        PROCReason("Requires Sine Integral (Si).")
        RETURN("Si(" + variableS + ")")
    ENDIF
    IF wS == ("cos(" + variableS + ")/" + variableS)
        PROCReason("Requires Cosine Integral (Ci).")
        RETURN("Ci(" + variableS + ")")
    ENDIF
    IF wS == ("exp(" + variableS + ")/" + variableS)
        PROCReason("Requires Exponential Integral (Ei).")
        RETURN("Ei(" + variableS + ")")
    ENDIF
    IF wS == ("exp(-" + variableS + ")/" + variableS)
        PROCReason("Requires Exponential Integral (Ei).")
        RETURN("-Ei(-" + variableS + ")")
    ENDIF
    IF wS == ("sin(exp(" + variableS + "))")
        PROCReason("Requires Sine Integral substitution.")
        RETURN("Si(exp(" + variableS + "))")
    ENDIF
    IF wS == ("cos(exp(" + variableS + "))")
        PROCReason("Requires Cosine Integral substitution.")
        RETURN("Ci(exp(" + variableS + "))")
    ENDIF
    IF wS == ("1/sqrt(1+sin(" + variableS + ")^2)")
        PROCReason("Requires Elliptic Integral of the First Kind.")
        RETURN("EllipticF(" + variableS + ", -1)")
    ENDIF
    IF wS == ("sqrt(1+sin(" + variableS + ")^2)")
        PROCReason("Requires Elliptic Integral of the Second Kind.")
        RETURN("EllipticE(" + variableS + ", -1)")
    ENDIF

    RETURN("")
END

STRING PROC FNIntegrateCoreS(STRING expressionS, STRING variableS)
    STRING workS[255] = ""
    STRING argumentS[255] = ""
    STRING coefficientS[255] = ""
    STRING exponentS[255] = ""
    STRING baseS[255] = ""
    STRING numS[255] = ""
    STRING denS[255] = ""
    STRING aS[255] = ""
    STRING bS[255] = ""
    STRING cS[255] = ""
    STRING dS[255] = ""
    STRING eS[255] = ""
    STRING fS[255] = ""
    STRING valAS[255] = ""
    STRING valBS[255] = ""
    STRING valCS[255] = ""
    STRING integralCS[255] = ""
    INTEGER operatorI = 0
    INTEGER exponentI = 0

    PROCDebug("entered FNIntegrateCoreS: " + expressionS)
    workS = FNStripOuterParenthesesS(expressionS)

    IF FNContainsVariableB(workS, variableS) == FALSE
        PROCReason("Used the constant-term rule.")
        RETURN(workS + " * " + variableS)
    ENDIF

    IF workS == variableS
        PROCReason("Used the power rule with exponent 1.")
        RETURN(variableS + "^2 / 2")
    ENDIF
    IF workS == ("1/" + variableS)
        PROCReason("Used the logarithmic rule for 1 / " + variableS + ".")
        RETURN("ln(abs(" + variableS + "))")
    ENDIF

    IF SubStr(workS, 1, 5) == "sqrt("
        IF SubStr(workS, Length(workS), 1) == ")"
            argumentS = SubStr(workS, 6, Length(workS) - 6)
            IF FNParseQuadraticB(argumentS, variableS, aS, bS, cS)
                IF aS == "0"
                    IF bS <> "0"
                        PROCReason("Used linear substitution on sqrt(" + argumentS + ").")
                        RETURN(FNDivideByCoefficientS("2/3 * (" + argumentS + ")^(3/2)", bS))
                    ENDIF
                ENDIF
            ENDIF
        ENDIF
    ENDIF

    IF SubStr(workS, 1, 7) == "1/sqrt("
        IF SubStr(workS, Length(workS), 1) == ")"
            argumentS = SubStr(workS, 8, Length(workS) - 8)
            IF FNParseQuadraticB(argumentS, variableS, aS, bS, cS)
                IF aS == "0"
                    IF bS <> "0"
                        PROCReason("Used linear substitution on 1 / sqrt(" + argumentS + ").")
                        RETURN(FNDivideByCoefficientS("2 * sqrt(" + argumentS + ")", bS))
                    ENDIF
                ENDIF
            ENDIF
        ENDIF
    ENDIF

    IF SubStr(workS, 1, Length(variableS) + 1) == (variableS + "^")
        exponentS = SubStr(workS, Length(variableS) + 2, 255)
        IF FNIsSignedIntegerB(exponentS)
            exponentI = Val(exponentS)
            IF exponentI == -1
                PROCReason("Used the logarithmic rule for exponent -1.")
                RETURN("ln(abs(" + variableS + "))")
            ENDIF
            PROCReason("Used the power rule.")
            RETURN(variableS + "^" + Str(exponentI + 1) + " / " + Str(exponentI + 1))
        ENDIF
        IF FNContainsVariableB(exponentS, variableS) == FALSE
            PROCReason("Used the symbolic power rule.")
            RETURN(variableS + "^(" + exponentS + "+1) / (" + exponentS + "+1)")
        ENDIF
    ENDIF

    IF FNFunctionArgumentB(workS, "exp", argumentS)
        IF FNLinearCoefficientI(argumentS, variableS, coefficientS)
            PROCReason("Used substitution on a linear exponential argument.")
            RETURN(FNDivideByCoefficientS("exp(" + argumentS + ")", coefficientS))
        ENDIF
    ENDIF
    IF FNFunctionArgumentB(workS, "sin", argumentS)
        IF FNLinearCoefficientI(argumentS, variableS, coefficientS)
            PROCReason("Used substitution on a linear sine argument.")
            RETURN(FNDivideByCoefficientS("-cos(" + argumentS + ")", coefficientS))
        ENDIF
    ENDIF
    IF FNFunctionArgumentB(workS, "cos", argumentS)
        IF FNLinearCoefficientI(argumentS, variableS, coefficientS)
            PROCReason("Used substitution on a linear cosine argument.")
            RETURN(FNDivideByCoefficientS("sin(" + argumentS + ")", coefficientS))
        ENDIF
    ENDIF

    operatorI = FNTopOperatorI(workS, "^")
    IF operatorI > 0
        baseS = SubStr(workS, 1, operatorI - 1)
        exponentS = SubStr(workS, operatorI + 1, 255)
        IF exponentS == variableS
            IF FNContainsVariableB(baseS, variableS) == FALSE
                PROCReason("Used the constant-base exponential rule.")
                RETURN(workS + " / ln(" + baseS + ")")
            ENDIF
        ENDIF
    ENDIF

    operatorI = FNTopOperatorI(workS, "/")
    IF operatorI > 0
        numS = SubStr(workS, 1, operatorI - 1)
        denS = SubStr(workS, operatorI + 1, 255)

        IF SubStr(denS, 1, 5) == "sqrt("
            IF SubStr(denS, Length(denS), 1) == ")"
                argumentS = SubStr(denS, 6, Length(denS) - 6)
                IF FNParseQuadraticB(numS, variableS, aS, bS, cS)
                    IF FNParseQuadraticB(argumentS, variableS, dS, eS, fS)
                        IF dS <> "0"
                            IF aS <> "0"
                                PROCReason("Used the Euler/Ostrogradsky substitution formula for (ax^2+bx+c)/sqrt(dx^2+ex+f).")
                                valAS = "(" + aS + ")/(2*(" + dS + "))"
                                valBS = "(4*(" + bS + ")*(" + dS + ")-3*(" + aS + ")*(" + eS + "))/(4*(" + dS + ")^2)"
                                valCS = "(" + cS + ")-(" + aS + ")*(" + fS + ")/(2*(" + dS + "))-(" + eS + ")*(4*(" + bS + ")*(" + dS + ")-3*(" + aS + ")*(" + eS + "))/(8*(" + dS + ")^2)"
                                integralCS = FNIntegrateS("1/sqrt(" + argumentS + ")", variableS)
                                IF integralCS == ""
                                    integralCS = "int(1/sqrt(" + argumentS + "))"
                                ENDIF
                                RETURN("((" + valAS + ")*" + variableS + "+(" + valBS + "))*sqrt(" + argumentS + ")+(" + valCS + ")*(" + integralCS + ")")
                            ELSEIF bS <> "0"
                                PROCReason("Used the Euler/Ostrogradsky substitution formula for (ax^2+bx+c)/sqrt(dx^2+ex+f).")
                                valAS = "(" + aS + ")/(2*(" + dS + "))"
                                valBS = "(4*(" + bS + ")*(" + dS + ")-3*(" + aS + ")*(" + eS + "))/(4*(" + dS + ")^2)"
                                valCS = "(" + cS + ")-(" + aS + ")*(" + fS + ")/(2*(" + dS + "))-(" + eS + ")*(4*(" + bS + ")*(" + dS + ")-3*(" + aS + ")*(" + eS + "))/(8*(" + dS + ")^2)"
                                integralCS = FNIntegrateS("1/sqrt(" + argumentS + ")", variableS)
                                IF integralCS == ""
                                    integralCS = "int(1/sqrt(" + argumentS + "))"
                                ENDIF
                                RETURN("((" + valAS + ")*" + variableS + "+(" + valBS + "))*sqrt(" + argumentS + ")+(" + valCS + ")*(" + integralCS + ")")
                            ENDIF
                        ENDIF
                    ENDIF
                ENDIF
            ENDIF
        ENDIF
    ENDIF

    IF SubStr(workS, 1, 7) == "1/sqrt("
        IF SubStr(workS, Length(workS), 1) == ")"
            argumentS = SubStr(workS, 8, Length(workS) - 8)
            IF SubStr(argumentS, 1, Length(variableS) + 2) == (variableS + "^2+")
                coefficientS = SubStr(argumentS, Length(variableS) + 3, 255)
                IF FNContainsVariableB(coefficientS, variableS) == FALSE
                    PROCReason("Used the standard integral for 1 / sqrt(x^2 + a^2).")
                    RETURN("ln(abs(" + variableS + " + sqrt(" + argumentS + ")))")
                ENDIF
            ENDIF
        ENDIF
    ENDIF

    IF SubStr(workS, 1, Length(variableS) + 4) == (variableS + "^2/(")
        IF SubStr(workS, Length(workS), 1) == ")"
            argumentS = SubStr(workS, Length(variableS) + 5, Length(workS) - Length(variableS) - 5)
            IF SubStr(argumentS, 1, Length(variableS) + 2) == (variableS + "^2+")
                coefficientS = SubStr(argumentS, Length(variableS) + 3, 255)
                IF FNContainsVariableB(coefficientS, variableS) == FALSE
                    PROCReason("Performed polynomial division on x^2 / (x^2 + a^2).")
                    RETURN(variableS + " - sqrt(" + coefficientS + ") * arctan(" + variableS + " / sqrt(" + coefficientS + "))")
                ENDIF
            ENDIF
        ENDIF
    ENDIF

    RETURN("")
END

STRING PROC FNIntegrateTermS(STRING expressionS, STRING variableS)
    STRING workS[255] = ""
    STRING leftS[255] = ""
    STRING rightS[255] = ""
    STRING answerS[255] = ""
    STRING s[1] = ""
    INTEGER depthI = 0
    INTEGER I = 0

    PROCDebug("entered FNIntegrateTermS: " + expressionS)
    workS = FNStripOuterParenthesesS(expressionS)

    FOR I = 1 TO Length(workS)
        s = SubStr(workS, I, 1)
        IF s == "("
            depthI = depthI + 1
        ELSEIF s == ")"
            depthI = depthI - 1
        ELSEIF depthI == 0
            IF s == "*"
                leftS = SubStr(workS, 1, I - 1)
                rightS = SubStr(workS, I + 1, 255)

                IF FNContainsVariableB(leftS, variableS) == FALSE
                    answerS = FNIntegrateTermS(rightS, variableS)
                    IF answerS <> ""
                        PROCReason("Moved the constant factor " + leftS + " outside the integral.")
                        RETURN(leftS + " * (" + answerS + ")")
                    ENDIF
                ENDIF

                IF FNContainsVariableB(rightS, variableS) == FALSE
                    answerS = FNIntegrateTermS(leftS, variableS)
                    IF answerS <> ""
                        PROCReason("Moved the constant factor " + rightS + " outside the integral.")
                        RETURN(rightS + " * (" + answerS + ")")
                    ENDIF
                ENDIF
            ENDIF
        ENDIF
    ENDFOR

    RETURN(FNIntegrateCoreS(workS, variableS))
END

STRING PROC FNIntegrateAdvancedFormsS(STRING expressionS)
    STRING wS[255] = ""
    STRING ansS[255] = ""
    STRING reasonS[255] = ""
    STRING lineS[255] = ""
    STRING restS[255] = ""
    STRING patternS[255] = ""
    STRING rawAnsS[255] = ""
    STRING aS[40] = ""
    STRING bS[40] = ""
    STRING cS[40] = ""
    STRING dS[40] = ""
    STRING eS[40] = ""
    STRING mS[40] = ""
    STRING nS[40] = ""
    INTEGER origBufferI = 0
    INTEGER pos1I = 0
    INTEGER pos2I = 0
    INTEGER I = 0

    wS = FNStripOuterParenthesesS(expressionS)

    origBufferI = GetBufferId()
    GotoBufferId(rulesBufferGI)
    BegFile()

    FOR I = 1 TO NumLines()
        lineS = GetText(1, 255)
        pos1I = Pos("|", lineS)
        IF pos1I > 0
            patternS = SubStr(lineS, 1, pos1I - 1)
            restS = SubStr(lineS, pos1I + 1, 255)
            pos2I = Pos("|", restS)
            IF pos2I > 0
                rawAnsS = SubStr(restS, 1, pos2I - 1)
                reasonS = SubStr(restS, pos2I + 1, 255)

                IF FNMatchTemplateB(patternS, wS, aS, bS, cS, dS, eS, mS, nS)
                    ansS = FNReplaceTemplateS(rawAnsS, aS, bS, cS, dS, eS, mS, nS)
                    PROCReason(reasonS)
                    GotoBufferId(origBufferI)
                    RETURN(ansS)
                ENDIF
            ENDIF
        ENDIF
        Down()
    ENDFOR
    GotoBufferId(origBufferI)
    RETURN("")
END

STRING PROC FNIntegrateS(STRING expressionS, STRING variableS)
    STRING workS[255] = ""
    STRING s[1] = ""
    STRING signS[1] = "+"
    STRING termS[255] = ""
    STRING answerS[255] = ""
    STRING resultS[255] = ""
    INTEGER depthI = 0
    INTEGER I = 0
    INTEGER startI = 1
    INTEGER termCountI = 0
    INTEGER atEndB = 0
    INTEGER splitB = 0

    PROCDebug("entered FNIntegrateS: " + expressionS)

    answerS = FNIntegrateSpecialS(expressionS, variableS)
    IF answerS <> ""
        RETURN(answerS)
    ENDIF

    answerS = FNIntegrateAdvancedFormsS(expressionS)
    IF answerS <> ""
        RETURN(answerS)
    ENDIF

    workS = FNStripOuterParenthesesS(expressionS)

    FOR I = 1 TO Length(workS) + 1
        IF I > Length(workS)
            atEndB = TRUE
        ELSE
            atEndB = FALSE
        ENDIF

        splitB = FALSE
        IF atEndB == FALSE
            s = SubStr(workS, I, 1)
            IF s == "("
                depthI = depthI + 1
            ELSEIF s == ")"
                depthI = depthI - 1
            ELSEIF depthI == 0
                IF I > startI
                    IF s == "+"
                        splitB = TRUE
                    ELSEIF s == "-"
                        splitB = TRUE
                    ENDIF
                ENDIF
            ENDIF
        ELSE
            splitB = TRUE
        ENDIF

        IF splitB
            termS = SubStr(workS, startI, I - startI)
            PROCDebug("integrating term: " + termS)
            answerS = FNIntegrateTermS(termS, variableS)
            IF answerS == ""
                RETURN("")
            ENDIF
            termCountI = termCountI + 1
            IF resultS == ""
                IF signS == "-"
                    resultS = "-(" + answerS + ")"
                ELSE
                    resultS = answerS
                ENDIF
            ELSE
                resultS = resultS + " " + signS + " " + answerS
            ENDIF
            IF atEndB == FALSE
                signS = s
                startI = I + 1
            ENDIF
        ENDIF
    ENDFOR
    IF termCountI > 1
        PROCReason("Applied linearity to top-level terms.")
    ENDIF
    RETURN(resultS)
END

PROC PROCWriteHeader(STRING inputS, STRING expressionS)
    GotoBufferId(resultBufferGI)
    EmptyBuffer()
    AddLine(programNameGS + " version " + programVersionGS)
    AddLine("Based on SAINT by James Robert Slagle")
    AddLine("")
    AddLine("Input:      " + inputS)
    AddLine("Normalized: int " + expressionS + " dx")
    AddLine("")
    AddLine("Reasoning:")
END

PROC PROCBatchProcess(INTEGER origFileI, INTEGER resBufferI)
    STRING lineS[255] = ""
    STRING expressionS[255] = ""
    STRING variableS[16] = ""
    STRING answerS[255] = ""

    GotoBufferId(resBufferI)
    EmptyBuffer()
    AddLine(programNameGS + " version " + programVersionGS + " (Batch Mode)")
    AddLine("Based on SAINT by James Robert Slagle")
    AddLine("======================================================================")

    GotoBufferId(origFileI)
    PushPosition()
    GotoBlockBegin()
    WHILE isCursorInBlock()
        lineS = Trim(GetText(1, 255))
        expressionS = FNExtractInputS(lineS, variableS)
        IF expressionS <> ""
            ruleCountGI = 0

            GotoBufferId(resBufferI)
            EndFile()
            AddLine("")
            AddLine("Input:      " + lineS)
            AddLine("Normalized: int " + expressionS + " dx")
            AddLine("Reasoning:")

            GotoBufferId(origFileI)
            answerS = FNIntegrateS(expressionS, variableS)

            GotoBufferId(resBufferI)
            EndFile()
            IF answerS == ""
                AddLine("Result: No solution method was found.")
                AddLine("Unevaluated: int " + expressionS + " dx")
            ELSE
                AddLine("Result: " + answerS + " + C")
            ENDIF
            AddLine("----------------------------------------------------------------------")

            GotoBufferId(origFileI)
        ENDIF
        IF NOT Down()
            BREAK
        ENDIF
        BegLine()
    ENDWHILE
    PopPosition()

    GotoBufferId(resBufferI)
    BegFile()
END

// library: string: get: query: command: line <description></description> <version control></version control> <version>1.0.0.0.5</version> <version control></version control> (filenamemacro=getstcmt.s) [<Program>] [<Research>] [kn, ri, sa, 21-06-2025 20:33:07]
STRING PROC FNStringGetQueryCommandLineS( STRING fileNameMacroS )
 // e.g. PROC Main()
 // e.g.  // STRING s1[255] = GetHistoryStr( _EDIT_HISTORY_, 1 ) // change this
 // e.g.  STRING s1[255] = "c:/bbc/taal/getstgmd.mac" // change this
 // e.g.  Warn( FNStringGetQueryCommandLineS( s1 ) ) // gives e.g. ...""
 // e.g. END
 // e.g.
 // e.g. <Ctrl F12> Main()
 //
 // ===
 //
 // Use case =
 //
 // ===
 //
 // ===
 //
 // Method =
 //
 // ===
 //
 // ===
 //
 // Example:
 //
 // Input:
 //
 /*
--- cut here: begin --------------------------------------------------
--- cut here: end ----------------------------------------------------
 */
 //
 // Output:
 //
 /*
--- cut here: begin --------------------------------------------------
--- cut here: end ----------------------------------------------------
 */
 //
 // ===
 //
 // e.g. // QuickHelp( HELPDEFFNStringGetQueryCommandLineS )
 // e.g. HELPDEF HELPDEFFNStringGetQueryCommandLineS
 // e.g.  title = "FNStringGetQueryCommandLineS( s1 ) help" // The help's caption
 // e.g.  x = 100 // Location
 // e.g.  y = 3 // Location
 // e.g.  //
 // e.g.  // The actual help text
 // e.g.  //
 // e.g.  "Usage:"
 // e.g.  "//"
 // e.g.  "1. Run this TSE macro"
 // e.g.  "2. Then press <CtrlAlt F1> to show this help."
 // e.g.  "3. Press <Shift Escape> to quit."
 // e.g.  "//"
 // e.g.  ""
 // e.g.  "Key: Definitions:"
 // e.g.  ""
 // e.g.  "<> = do something"
 // e.g. END
 //
 STRING s1[255] = ""
 STRING s2[255] = ""
 //
 // Warn( GetGlobalStr('CmdLineParameter:c:/bbc/taal/getstgmd.mac:1'); GetGlobalStr('CmdLineParameter:c:/bbc/taal/getstgmd.mac:2'); GetGlobalStr('CmdLineParameter:c:/bbc/taal/getstgmd.mac:3') )
 //
 // usual Query( DosCmdLine )
 //
 s1 = Query( DosCmdLine )
 s2 = GetToken( s1, " ", 1 ) // get the TSE macro name
 s1 = RightStr( s1, Length( s1 ) - Length( s2 ) ) // remove the TSE macro name in front in order to get the command line parameters after it
 //
 // s1 = StrReplace( "]", s1, "/", "" ) // use ] instead of \ in the expressions you pass as a parameter to the URL
 //
 // via autoload Query( DosCmdLine ) / thus CmdLineParameter.mac must be present in the 'AutoLoad' in that TSE (e.g. on the server
 //
 // Needs -p after the URL, then the parameters
 //
 // '+' must always be replaced manually in the URL (because '+' is seen as a space in the browser)
 //
 s1 = ""
 s1 = s1 + " " + GetGlobalStr( Format( "CmdLineParameter:", fileNameMacroS, ":1" ) )
 s1 = s1 + " " + GetGlobalStr( Format( "CmdLineParameter:", fileNameMacroS, ":2" ) )
 s1 = s1 + " " + GetGlobalStr( Format( "CmdLineParameter:", fileNameMacroS, ":3" ) )
 s1 = s1 + " " + GetGlobalStr( Format( "CmdLineParameter:", fileNameMacroS, ":4" ) )
 s1 = s1 + " " + GetGlobalStr( Format( "CmdLineParameter:", fileNameMacroS, ":5" ) )
 s1 = s1 + " " + GetGlobalStr( Format( "CmdLineParameter:", fileNameMacroS, ":6" ) )
 s1 = s1 + " " + GetGlobalStr( Format( "CmdLineParameter:", fileNameMacroS, ":7" ) )
 s1 = s1 + " " + GetGlobalStr( Format( "CmdLineParameter:", fileNameMacroS, ":8" ) )
 s1 = s1 + " " + GetGlobalStr( Format( "CmdLineParameter:", fileNameMacroS, ":9" ) )
 s1 = s1 + " " + GetGlobalStr( Format( "CmdLineParameter:", fileNameMacroS, ":10" ) )
 s1 = s1 + " " + GetGlobalStr( Format( "CmdLineParameter:", fileNameMacroS, ":11" ) )
 s1 = s1 + " " + GetGlobalStr( Format( "CmdLineParameter:", fileNameMacroS, ":12" ) )
 s1 = s1 + " " + GetGlobalStr( Format( "CmdLineParameter:", fileNameMacroS, ":13" ) )
 s1 = s1 + " " + GetGlobalStr( Format( "CmdLineParameter:", fileNameMacroS, ":14" ) )
 s1 = s1 + " " + GetGlobalStr( Format( "CmdLineParameter:", fileNameMacroS, ":15" ) )
 s1 = s1 + " " + GetGlobalStr( Format( "CmdLineParameter:", fileNameMacroS, ":16" ) )
 s1 = s1 + " " + GetGlobalStr( Format( "CmdLineParameter:", fileNameMacroS, ":17" ) )
 s1 = s1 + " " + GetGlobalStr( Format( "CmdLineParameter:", fileNameMacroS, ":18" ) )
 s1 = s1 + " " + GetGlobalStr( Format( "CmdLineParameter:", fileNameMacroS, ":19" ) )
 s1 = s1 + " " + GetGlobalStr( Format( "CmdLineParameter:", fileNameMacroS, ":20" ) )
 s1 = s1 + " " + GetGlobalStr( Format( "CmdLineParameter:", fileNameMacroS, ":21" ) )
 s1 = s1 + " " + GetGlobalStr( Format( "CmdLineParameter:", fileNameMacroS, ":22" ) )
 s1 = s1 + " " + GetGlobalStr( Format( "CmdLineParameter:", fileNameMacroS, ":23" ) )
 //
 RETURN( s1 )
 //
END

PROC Main()
    STRING inputS[255] = ""
    STRING expressionS[255] = ""
    STRING variableS[16] = ""
    STRING answerS[255] = ""
    STRING cmdLineS[255] = ""
    INTEGER origBufferI = 0

 STRING s[255] = ""
 // STRING s1[255] = GetHistoryStr( _EDIT_HISTORY_, 1 ) // change this
 STRING s1[255] = " " // change this
 //

    debugStepGI = 0
    PROCDebug("Main entered; compilation and macro loading succeeded")
    programNameGS = "SAINT text integrator"
    programVersionGS = "1.0.0.1.63 FULL_COVERAGE"

    origBufferI = GetBufferId()

    PushPosition()
    IF EditFile( "SAINT_Rules" )
     AbandonFile()
    ENDIF
    PopPosition()

    PushPosition()
    IF GetBufferId( "SAINT_Rules" ) == 0
     rulesBufferGI = CreateBuffer("SAINT_Rules")
    ENDIF
    PopPosition()

    IF rulesBufferGI == 0
        Warn("Could not create buffer for rules.")
        RETURN()
    ENDIF
    GotoBufferId(rulesBufferGI)
    EmptyBuffer()

    #IFDEF WIN32
     IF NOT ( LoadBuffer( "saint_rules.txt" ) > 0 )
       IF NOT LoadBuffer( AddTrailingSlash( CurrDir() ) + "saint\saint_rules.txt" )
       IF NOT LoadBuffer( "f:\bbc\taal\saint_rules.txt" )
        IF NOT LoadBuffer( "c:\bbc\taal\saint_rules.txt" )
         Warn( "could not load the file saint_rules.txt. Please check." )
         RETURN()
        ENDIF
       ENDIF
      ENDIF
     ENDIF
    #ENDIF

    #IFDEF LINUX
     IF NOT ( LoadBuffer( "./saint_rules.txt" ) > 0 )
      IF NOT LoadBuffer( AddTrailingSlash( CurrDir() ) + "saint/saint_rules.txt" )
       IF NOT LoadBuffer( "/mnt/c/temp/tse_linux/knud/saint_rules.txt" )
        IF NOT LoadBuffer( "/mnt/c/temp/tse_linux/knud/saint/saint_rules.txt" )
         Warn( "could not load the file saint_rules.txt. Please check." )
         RETURN()
        ENDIF
       ENDIF
      ENDIF
     ENDIF
    #ENDIF

    GotoBufferId(origBufferI)

 #IF TSEREMOTESERVER
  s1 = FNStringGetQueryCommandLineS( "c:/bbc/taal/saint.mac" )
  inputS = s1
 #ELSE

    IF isBlockInCurrFile()
        resultBufferGI = GetBufferId("SAINT_Result")
        IF resultBufferGI == 0
            resultBufferGI = CreateBuffer("SAINT_Result")
        ENDIF
        IF resultBufferGI == 0
            Warn("Could not create the SAINT result buffer.")
            AbandonFile(rulesBufferGI)
            RETURN()
        ENDIF

        PROCBatchProcess(origBufferI, resultBufferGI)

        AbandonFile(rulesBufferGI)
        PROCDebug("Main completed (batch mode)")
        RETURN()
    ENDIF

    cmdLineS = Trim(Query(MacroCmdLine))
    IF cmdLineS <> ""
        inputS = cmdLineS
    ELSE
        inputS = "int x * exp( 300 * x ) dx"
        PROCDebug("about to display the integral input prompt")
        IF Ask("SAINT integral (use: int ... dx):", inputS, _EDIT_HISTORY_) == FALSE
            AbandonFile(rulesBufferGI)
            RETURN()
        ENDIF
    ENDIF
   #ENDIF

    PROCDebug("input accepted: " + inputS)
    PROCDebug("about to parse the input")
    expressionS = FNExtractInputS(inputS, variableS)
    PROCDebug("input parsing returned: " + expressionS)

    IF expressionS == ""
        Warn("Invalid input. Use the form: int ... dx")
        AbandonFile(rulesBufferGI)
        RETURN()
    ENDIF

    PROCDebug("about to check/create the result buffer")
    resultBufferGI = GetBufferId("SAINT_Result")
    IF resultBufferGI == 0
        resultBufferGI = CreateBuffer("SAINT_Result")
    ENDIF
    IF resultBufferGI == 0
        Warn("Could not create the SAINT result buffer.")
        AbandonFile(rulesBufferGI)
        RETURN()
    ENDIF

    GotoBufferId(resultBufferGI)
    BufferType(_NORMAL_)
    ruleCountGI = 0

    PROCDebug("about to write the result header")
    PROCWriteHeader(inputS, expressionS)
    PROCDebug("about to call the integration engine")

    answerS = FNIntegrateS(expressionS, variableS)
    PROCDebug("integration engine returned: " + answerS)

    GotoBufferId(resultBufferGI)
    EndFile()
    AddLine("")

 #IF TSEREMOTESERVER
   IF answerS == ""
    answerS = "No solution method was found."
   ENDIF
   FWrite( _STDOUT_, answerS + " + C" )
   AbandonFile( resultBufferGI )
   AbandonEditor()
   Exit()
 #ELSE
  #IFDEF WIN32
    IF answerS == ""
        AddLine("Result: No solution method was found.")
        AddLine("Unevaluated: int " + expressionS + " dx")
    ELSE
    AddLine("Result: " + answerS + " + C")
    BegFile()
    AbandonFile(rulesBufferGI)
    PROCDebug("Main completed")
   ENDIF
  #ENDIF
  //
  #IFDEF LINUX
    IF answerS == ""
        AddLine("Result: No solution method was found.")
        AddLine("Unevaluated: int " + expressionS + " dx")
    ELSE
     AddLine("Result: " + answerS + " + C")
    BegFile()
    AbandonFile(rulesBufferGI)
    PROCDebug("Main completed")
   ENDIF
  #ENDIF
   //
 #ENDIF
 //
END
