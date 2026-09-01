// =================================================================
// =    File: CamelCaps.inc
// =  Author: Reed Truitt
// =    Date: 2004.Feb.21       
// = Purpose: m_WordLeft() and m_WordRight() 
// = Installation: add to .ui and burnin,
// =   change key assignments for
// =   <Ctrl CursorLeft> and <Ctrl CursorRight>
// =================================================================

#ifndef WIN32
integer proc isAlpha(string strChar)
  case strChar
    when "A".."Z", "a".."z"
      return (TRUE)
  endcase
  return (FALSE)
end

integer proc isUpper(string strChar)
  case strChar
    when "A".."Z"
      return (TRUE)
  endcase
  return (FALSE)
end

integer proc isLower(string strChar)
  case strChar
    when "a".."z"
      return (TRUE)
  endcase
  return (FALSE)
end

integer proc isDigit(string strChar)
  case strChar
    when "0".."9"
      return (TRUE)
  endcase
  return (FALSE)
end
#endif

proc m_WordRight()
  string strLeftChar[1], strRightChar[1], strChrSet[32]

  strChrset = Set(WordSet, ChrSet("0-9A-Za-z")) // save and set WordSet         
  PushPosition()
  if (isWord())                         // for CamelCaps
    loop
      strLeftChar = Chr(CurrChar())
      if (not NextChar())
        PopPosition()
        Message("There is no word to the right.")
        Alarm()
        Set(WordSet, strChrSet)         // restore WordSet
        return()
      endif
      strRightChar = Chr(CurrChar())

      if ((not isUpper(strLeftChar) and isUpper(strRightChar)) or // (!U)(U)
          (not isAlpha(strLeftChar) and isLower(strRightChar)) or // (!A)(L)
          (not isDigit(strLeftChar) and isDigit(strRightChar)))   // (!D)(D)
        break
      endif
    endloop
  else                                  // as normal except EOL
    while (not isWord())
      if (not NextChar())
        PopPosition()
        Message("There is no word to the right.")
        Alarm()
        Set(WordSet, strChrSet)         // restore WordSet
        return()
      endif
    endwhile
  endif
  KillPosition()
  Set(WordSet, strChrSet)               // restore WordSet
end

proc m_WordLeft()
  string strLeftChar[1], strRightChar[1], strChrSet[32]
  integer intLine = CurrLine(), intCol = CurrCol()

  strChrset = Set(WordSet, ChrSet("0-9A-Za-z")) // save and set WordSet         
  if (CurrLine() == 1 and CurrCol() == 1)
    Message("There is no word to the left.")
    Alarm()                             
    Set(WordSet, strChrSet)             // restore WordSet
    return()
  endif

  PushPosition()
  while (PrevChar())
    if (isWord())
      BegWord()
      break
    endif
  endwhile
  if (CurrLine() == 1 and CurrCol() == 1 and not isWord())
    PopPosition()                       // hit BOF without finding word
    Message("There is no word to the left.")
    Alarm()
    Set(WordSet, strChrSet)             // restore WordSet
    return()
  endif
  KillPosition()                        // we're where we need to be
  if (Length(GetWord()) == 1)           // no more processing needed
    Set(WordSet, strChrSet)             // restore WordSet
    return()
  endif

  loop                                  // now the messy CamelCaps part
    PushPosition()
    loop
      strLeftChar = Chr(CurrChar())
      if (not NextChar())               // must be a file without any Words
        PopPosition()
        Set(WordSet, strChrSet)         // restore WordSet
        return()
      endif
      strRightChar = Chr(CurrChar())

      if ((not isUpper(strLeftChar) and isUpper(strRightChar)) or // (!U)(U)
          (not isAlpha(strLeftChar) and isLower(strRightChar)) or // (!A)(L)
          (not isDigit(strLeftChar) and isDigit(strRightChar)))   // (!D)(D)
        break
      endif
    endloop
    if ((CurrLine() == intLine and CurrCol() >= intCol) or CurrLine() > intLine)
      PopPosition()
      Set(WordSet, strChrSet)           // restore WordSet
      return()
    endif
    KillPosition()
  endloop
  Set(WordSet, strChrSet)               // restore WordSet
end
