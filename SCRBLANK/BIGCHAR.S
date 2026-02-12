/***************************************************************
 Program: bigchar.s
 Author : Bruce Riggins
 Date   : 02/19/94
 Purpose: Write big characters to the screen.

          Attr is set before entering this screen.

****************************************************************/

integer x,y

proc IncrementPos()
  y = y + 1
  vGotoXY(x,y)
end

integer proc WSpace()
  integer tx = WhereX(),
          ty = WhereY()


  y = ty

  PutStr("   ")                        IncrementPos()
  PutStr("   ")                        IncrementPos()
  PutStr("   ")                        IncrementPos()
  PutStr("   ")                        IncrementPos()
  PutStr("   ")                        IncrementPos()
  PutStr("   ")                        IncrementPos()
  PutStr("   ")                        IncrementPos()
  PutStr("   ")
  vGotoXY(tx,ty)

  return (2)
end

integer proc W1()
  integer tx = WhereX(),
          ty = WhereY()


  y = ty

  PutStr(" ллл   ")                    IncrementPos()
  PutStr("   л   ")                    IncrementPos()
  PutStr("   л   ")                    IncrementPos()
  PutStr("   л   ")                    IncrementPos()
  PutStr("   л   ")                    IncrementPos()
  PutStr("   л   ")                    IncrementPos()
  PutStr("   л   ")                    IncrementPos()
  PutStr(" ллллл ")
  vGotoXY(tx,ty)

  return (7)
end

integer proc W2()
  integer tx = WhereX(),
          ty = WhereY()


  y = ty

  PutStr(" ллллл ")                    IncrementPos()
  PutStr(" л   л ")                    IncrementPos()
  PutStr("     л ")                    IncrementPos()
  PutStr("    л  ")                    IncrementPos()
  PutStr("   л   ")                    IncrementPos()
  PutStr("  л    ")                    IncrementPos()
  PutStr(" л     ")                    IncrementPos()
  PutStr(" ллллл ")
  vGotoXY(tx,ty)

  return (7)
end

integer proc W3()
  integer tx = WhereX(),
          ty = WhereY()


  y = ty

  PutStr(" ллллл ")                    IncrementPos()
  PutStr("     л ")                    IncrementPos()
  PutStr("     л ")                    IncrementPos()
  PutStr("  лллл ")                    IncrementPos()
  PutStr("     л ")                    IncrementPos()
  PutStr("     л ")                    IncrementPos()
  PutStr("     л ")                    IncrementPos()
  PutStr(" ллллл ")
  vGotoXY(tx,ty)

  return (7)
end

integer proc W4()
  integer tx = WhereX(),
          ty = WhereY()


  y = ty

  PutStr(" л   л ")                    IncrementPos()
  PutStr(" л   л ")                    IncrementPos()
  PutStr(" л   л ")                    IncrementPos()
  PutStr(" ллллл ")                    IncrementPos()
  PutStr("     л ")                    IncrementPos()
  PutStr("     л ")                    IncrementPos()
  PutStr("     л ")                    IncrementPos()
  PutStr("     л ")
  vGotoXY(tx,ty)

  return (7)
end

integer proc W5()
  integer tx = WhereX(),
          ty = WhereY()


  y = ty

  PutStr(" ллллл ")                    IncrementPos()
  PutStr(" л     ")                    IncrementPos()
  PutStr(" л     ")                    IncrementPos()
  PutStr(" ллллл ")                    IncrementPos()
  PutStr("     л ")                    IncrementPos()
  PutStr("     л ")                    IncrementPos()
  PutStr("     л ")                    IncrementPos()
  PutStr(" ллллл ")
  vGotoXY(tx,ty)

  return (7)
end

integer proc W6()
  integer tx = WhereX(),
          ty = WhereY()


  y = ty

  PutStr(" ллллл ")                    IncrementPos()
  PutStr(" л     ")                    IncrementPos()
  PutStr(" л     ")                    IncrementPos()
  PutStr(" ллллл ")                    IncrementPos()
  PutStr(" л   л ")                    IncrementPos()
  PutStr(" л   л ")                    IncrementPos()
  PutStr(" л   л ")                    IncrementPos()
  PutStr(" ллллл ")
  vGotoXY(tx,ty)

  return (7)
end

integer proc W7()
  integer tx = WhereX(),
          ty = WhereY()


  y = ty

  PutStr(" ллллл ")                    IncrementPos()
  PutStr("     л ")                    IncrementPos()
  PutStr("     л ")                    IncrementPos()
  PutStr("     л ")                    IncrementPos()
  PutStr("     л ")                    IncrementPos()
  PutStr("     л ")                    IncrementPos()
  PutStr("     л ")                    IncrementPos()
  PutStr("     л ")
  vGotoXY(tx,ty)

  return (7)
end

integer proc W8()
  integer tx = WhereX(),
          ty = WhereY()


  y = ty

  PutStr(" ллллл ")                    IncrementPos()
  PutStr(" л   л ")                    IncrementPos()
  PutStr(" л   л ")                    IncrementPos()
  PutStr(" ллллл ")                    IncrementPos()
  PutStr(" л   л ")                    IncrementPos()
  PutStr(" л   л ")                    IncrementPos()
  PutStr(" л   л ")                    IncrementPos()
  PutStr(" ллллл ")
  vGotoXY(tx,ty)

  return (7)
end

integer proc W9()
  integer tx = WhereX(),
          ty = WhereY()


  y = ty

  PutStr(" ллллл ")                    IncrementPos()
  PutStr(" л   л ")                    IncrementPos()
  PutStr(" л   л ")                    IncrementPos()
  PutStr(" л   л ")                    IncrementPos()
  PutStr(" ллллл ")                    IncrementPos()
  PutStr("     л ")                    IncrementPos()
  PutStr("     л ")                    IncrementPos()
  PutStr("     л ")
  vGotoXY(tx,ty)

  return (7)
end

integer proc W0()
  integer tx = WhereX(),
          ty = WhereY()


  y = ty

  PutStr(" ллллл ")                    IncrementPos()
  PutStr(" л   л ")                    IncrementPos()
  PutStr(" л   л ")                    IncrementPos()
  PutStr(" л   л ")                    IncrementPos()
  PutStr(" л   л ")                    IncrementPos()
  PutStr(" л   л ")                    IncrementPos()
  PutStr(" л   л ")                    IncrementPos()
  PutStr(" ллллл ")
  vGotoXY(tx,ty)

  return (7)
end

integer proc WColon()
  integer tx = WhereX(),
          ty = WhereY()


  y = ty

  PutStr("   ")                        IncrementPos()
  PutStr("   ")                        IncrementPos()
  PutStr(" л ")                        IncrementPos()
  PutStr("   ")                        IncrementPos()
  PutStr("   ")                        IncrementPos()
  PutStr(" л ")                        IncrementPos()
  PutStr("   ")                        IncrementPos()
  PutStr("   ")
  vGotoXY(tx,ty)

  return (3)
end

integer proc WSa()
  integer tx = WhereX(),
          ty = WhereY()


  y = ty

  PutStr("       ")                    IncrementPos()
  PutStr("       ")                    IncrementPos()
  PutStr(" ллллл ")                    IncrementPos()
  PutStr("     л ")                    IncrementPos()
  PutStr(" ллллл ")                    IncrementPos()
  PutStr(" л   л ")                    IncrementPos()
  PutStr(" л   л ")                    IncrementPos()
  PutStr(" ллллл ")
  vGotoXY(tx,ty)

  return (7)
end

integer proc WSm()
  integer tx = WhereX(),
          ty = WhereY()


  y = ty

  PutStr("       ")                    IncrementPos()
  PutStr("       ")                    IncrementPos()
  PutStr(" ллллл ")                    IncrementPos()
  PutStr(" л л л ")                    IncrementPos()
  PutStr(" л л л ")                    IncrementPos()
  PutStr(" л л л ")                    IncrementPos()
  PutStr(" л л л ")                    IncrementPos()
  PutStr(" л л л ")
  vGotoXY(tx,ty)

  return (7)
end

integer proc WSp()
  integer tx = WhereX(),
          ty = WhereY()


  y = ty

  PutStr("       ")                    IncrementPos()
  PutStr("       ")                    IncrementPos()
  PutStr(" ллллл ")                    IncrementPos()
  PutStr(" л   л ")                    IncrementPos()
  PutStr(" л   л ")                    IncrementPos()
  PutStr(" л   л ")                    IncrementPos()
  PutStr(" ллллл ")                    IncrementPos()
  PutStr(" л     ")
  vGotoXY(tx,ty)

  return (7)
end


integer proc WriteChar(integer ch)
  integer w = 0
  // Set up window of appropriate size at current location

  // Write text in that window
  case ch
    when Asc(" ")
      w = WSpace()

    when Asc("1")
      w = W1()
    when Asc("2")
      w = W2()
    when Asc("3")
      w = W3()
    when Asc("4")
      w = W4()
    when Asc("5")
      w = W5()
    when Asc("6")
      w = W6()
    when Asc("7")
      w = W7()
    when Asc("8")
      w = W8()
    when Asc("9")
      w = W9()
    when Asc("0")
      w = W0()

    when Asc(":")
      w = WColon()


    when Asc("a")
      w = WSa()
    when Asc("m")
      w = WSm()
    when Asc("p")
      w = WSp()

  endcase

  return (w)
end

proc WriteBigStr(string s)
  integer i = 1

  x = WhereX()

  while i <= Length(s)
    x = x + WriteChar(Asc(s[i]))
    GotoXY(x, WhereY())
    i = i + 1
  endwhile

end

proc main()
  PushPosition()

  WriteBigStr(GetGlobalStr("BigStr"))

  PopPosition()
end


