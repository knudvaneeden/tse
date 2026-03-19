// TSE SAL program
// Project Euler Problem 112 - Bouncy Numbers
// Version 1.1

integer proc IsBouncy(integer numberIB)
    string digitsSB[32]
    integer idxIB
    integer lengthIB
    integer sawIncreaseIB
    integer sawDecreaseIB
    integer leftDigitIB
    integer rightDigitIB

    digitsSB      = Str(numberIB)
    lengthIB      = Length(digitsSB)
    sawIncreaseIB = FALSE
    sawDecreaseIB = FALSE

    for idxIB = 2 to lengthIB
        leftDigitIB  = Asc(SubStr(digitsSB, idxIB - 1, 1))
        rightDigitIB = Asc(SubStr(digitsSB, idxIB, 1))

        if rightDigitIB > leftDigitIB
            sawIncreaseIB = TRUE
        elseif rightDigitIB < leftDigitIB
            sawDecreaseIB = TRUE
        endif

        if sawIncreaseIB and sawDecreaseIB
            Return(TRUE)
        endif
    endfor

    Return(FALSE)
end

proc Main()
    integer currentNumberIM
    integer bouncyCountIM
    string answerSM[32]
    string messageSM[80]

    currentNumberIM = 0
    bouncyCountIM   = 0

    repeat
        currentNumberIM = currentNumberIM + 1

        if IsBouncy(currentNumberIM)
            bouncyCountIM = bouncyCountIM + 1
        endif
    until currentNumberIM >= 100 and bouncyCountIM * 100 == currentNumberIM * 99

    answerSM = Str(currentNumberIM)
    CopyToWinClip(answerSM)

    messageSM = "Project Euler 112 answer: " + answerSM
    Warn(messageSM)

    Return()
end
