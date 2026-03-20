/*
  Euler Project 138
  Special Isosceles Triangles

  https://projecteuler.net/problem=138

  The valid leg lengths L satisfy:
      L(n) = 18 * L(n-1) - L(n-2)
  with:
      L(1) = 17
      L(2) = 305

  We need the sum of the first 12 values.

  Expected final answer:
      1118049290473932

  <version>1.0.0.0.1</version>
  Created by: ChatGPT GPT-5.4 Thinking
*/

string proc ReverseString( string inputS )
  string resultS[255] = ""
  integer indexI = 0
  //
  for indexI = Length( inputS ) downto 1
    resultS = resultS + SubStr( inputS, indexI, 1 )
  endfor
  //
  Return( resultS )
end

string proc TrimLeadingZeros( string inputS )
  string workS[255] = ""
  //
  workS = inputS
  //
  while Length( workS ) > 1 and SubStr( workS, 1, 1 ) == "0"
    workS = SubStr( workS, 2, Length( workS ) - 1 )
  endwhile
  //
  Return( workS )
end

integer proc CompareUnsignedStrings( string leftS, string rightS )
  string leftWorkS[255] = ""
  string rightWorkS[255] = ""
  integer indexI = 0
  //
  leftWorkS  = TrimLeadingZeros( leftS )
  rightWorkS = TrimLeadingZeros( rightS )
  //
  if Length( leftWorkS ) < Length( rightWorkS )
    Return( -1 )
  endif
  //
  if Length( leftWorkS ) > Length( rightWorkS )
    Return( 1 )
  endif
  //
  for indexI = 1 to Length( leftWorkS )
    if SubStr( leftWorkS, indexI, 1 ) < SubStr( rightWorkS, indexI, 1 )
      Return( -1 )
    endif
    //
    if SubStr( leftWorkS, indexI, 1 ) > SubStr( rightWorkS, indexI, 1 )
      Return( 1 )
    endif
  endfor
  //
  Return( 0 )
end

string proc AddUnsignedStrings( string leftS, string rightS )
  string leftWorkS[255] = ""
  string rightWorkS[255] = ""
  string resultRevS[255] = ""
  string resultS[255] = ""
  integer leftIndexI = 0
  integer rightIndexI = 0
  integer leftDigitI = 0
  integer rightDigitI = 0
  integer sumDigitI = 0
  integer carryI = 0
  //
  leftWorkS  = leftS
  rightWorkS = rightS
  leftIndexI  = Length( leftWorkS )
  rightIndexI = Length( rightWorkS )
  //
  while leftIndexI >= 1 or rightIndexI >= 1 or carryI > 0
    leftDigitI = 0
    rightDigitI = 0
    //
    if leftIndexI >= 1
      leftDigitI = Asc( SubStr( leftWorkS, leftIndexI, 1 ) ) - Asc( "0" )
      leftIndexI = leftIndexI - 1
    endif
    //
    if rightIndexI >= 1
      rightDigitI = Asc( SubStr( rightWorkS, rightIndexI, 1 ) ) - Asc( "0" )
      rightIndexI = rightIndexI - 1
    endif
    //
    sumDigitI = leftDigitI + rightDigitI + carryI
    carryI = sumDigitI / 10
    sumDigitI = sumDigitI mod 10
    resultRevS = resultRevS + Chr( Asc( "0" ) + sumDigitI )
  endwhile
  //
  resultS = ReverseString( resultRevS )
  resultS = TrimLeadingZeros( resultS )
  Return( resultS )
end

string proc SubtractUnsignedStrings( string leftS, string rightS )
  string leftWorkS[255] = ""
  string rightWorkS[255] = ""
  string resultRevS[255] = ""
  string resultS[255] = ""
  integer leftIndexI = 0
  integer rightIndexI = 0
  integer leftDigitI = 0
  integer rightDigitI = 0
  integer diffDigitI = 0
  integer borrowI = 0
  //
  leftWorkS  = TrimLeadingZeros( leftS )
  rightWorkS = TrimLeadingZeros( rightS )
  //
  leftIndexI  = Length( leftWorkS )
  rightIndexI = Length( rightWorkS )
  //
  while leftIndexI >= 1
    leftDigitI = Asc( SubStr( leftWorkS, leftIndexI, 1 ) ) - Asc( "0" )
    rightDigitI = 0
    //
    if rightIndexI >= 1
      rightDigitI = Asc( SubStr( rightWorkS, rightIndexI, 1 ) ) - Asc( "0" )
      rightIndexI = rightIndexI - 1
    endif
    //
    leftDigitI = leftDigitI - borrowI
    //
    if leftDigitI < rightDigitI
      leftDigitI = leftDigitI + 10
      borrowI = 1
    else
      borrowI = 0
    endif
    //
    diffDigitI = leftDigitI - rightDigitI
    resultRevS = resultRevS + Chr( Asc( "0" ) + diffDigitI )
    leftIndexI = leftIndexI - 1
  endwhile
  //
  resultS = ReverseString( resultRevS )
  resultS = TrimLeadingZeros( resultS )
  Return( resultS )
end

string proc MultiplyUnsignedStringBySmallInt( string inputS, integer factorI )
  string workS[255] = ""
  string resultRevS[255] = ""
  string resultS[255] = ""
  integer indexI = 0
  integer digitI = 0
  integer productI = 0
  integer carryI = 0
  //
  workS = TrimLeadingZeros( inputS )
  //
  if factorI == 0
    Return( "0" )
  endif
  //
  if factorI == 1
    Return( workS )
  endif
  //
  for indexI = Length( workS ) downto 1
    digitI = Asc( SubStr( workS, indexI, 1 ) ) - Asc( "0" )
    productI = digitI * factorI + carryI
    resultRevS = resultRevS + Chr( Asc( "0" ) + ( productI mod 10 ) )
    carryI = productI / 10
  endfor
  //
  while carryI > 0
    resultRevS = resultRevS + Chr( Asc( "0" ) + ( carryI mod 10 ) )
    carryI = carryI / 10
  endwhile
  //
  resultS = ReverseString( resultRevS )
  resultS = TrimLeadingZeros( resultS )
  Return( resultS )
end

string proc SolveEuler138()
  string previousLS[255] = "17"
  string currentLS[255]  = "305"
  string nextLS[255]     = ""
  string sumS[255]       = "322"
  string tempS[255]      = ""
  integer countI = 0
  //
  countI = 2
  //
  while countI < 12
    tempS = MultiplyUnsignedStringBySmallInt( currentLS, 18 )
    nextLS = SubtractUnsignedStrings( tempS, previousLS )
    sumS = AddUnsignedStrings( sumS, nextLS )
    previousLS = currentLS
    currentLS = nextLS
    countI = countI + 1
  endwhile
  //
  Return( sumS )
end

proc Main()
  string answerS[255] = ""
  string creatorHistoryS[255] = "ChatGPT GPT-5.4 Thinking"
  //
  answerS = SolveEuler138()
  //
  CopyToWinClip( answerS )
  Warn( answerS )
end
