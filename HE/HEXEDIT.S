integer TLine, BLine, WRows, WLine, Buff1, Buff2, CLine, CCol, OLine
integer SRow, NLine, SLine, SChar, Hex, HCol, HRow, i, j, k
string HLine[47] = ""
string HAddr[11] = ""
string HStrg[8]  = ""
string HHigh[4]  = ""
string HLow[4]   = ""
string HChar[2]  = ""

Proc HexCol()
  HRow = (CLine - TLine) + 1
  HCol = ((CCol * 3) - 2) + 11
  VGotoXY(HCol,HRow)
  PutAttr(Color(Black on Cyan),2)
End

Proc HexScrn()
  GotoBufferId(Buff1)
  CLine = CurrLine()
  CCol  = CurrCol()
  If CLine < TLine
    GotoLine(CLine)
    TLine = CLine
    BLine = TLine + WRows - 1
    If BLine > NLine
      BLine = NLine
    EndIf
  EndIf
  If CLine > BLine
    GotoLine(CLine)
    BLine = CLine
    TLine = TLine + 1
  EndIf
  If TLine < 1
    TLine = 1
    BLine = TLine + WRows - 1
  EndIf
  Window(21,WLine,78,WRows+WLine)
  i = 0
  While i < WRows
    GotoBufferId(Buff1)
    i = i + 1
    If i == 1
      SRow  = TLine - 1
    EndIf
    SRow  = SRow + 1
    GotoLine(SRow)
    k = (CurrLine()-1)*16
    j = 0
    HLine = ""
    HAddr = ""
    While j < 16
      j = j + 1
      GotoColumn(j)
      HChar = Format(CurrChar():2:"0":16)
      If CurrChar() < 0
        j = 16
      Else
        If j == 1
          HLine = HLine + HChar
        Else
          HLine = HLine + " " + HChar
        EndIf
      EndIf
    EndWhile
    HStrg = Format(k:8:"0":16)
    HHigh = SubStr(HStrg,1,4)
    HLow  = SubStr(HStrg,5,4)
    HAddr = HHigh + " " + HLow + "  "
    Set(Attr,Color(BRIGHT White  On Blue))
    Write(HAddr)
    Set(Attr,Color(BRIGHT Cyan   On Black))
    WriteLine(HLine)
    If SRow == NLine
      i = WRows
    EndIf
  EndWhile
  GotoBufferID(Buff2)
  HexCol()
  GotoBufferId(Buff1)
  GotoLine(CLine)
  GotoColumn(CCol)
End

Proc HexOld()
  GotoBufferId(Buff1)
  HAddr = ""
  HLine = ""
  k = (OLine-1)*16
  GotoLine(OLine)
  j = 0
  While j < 16
    j = j + 1
    GotoColumn(j)
    HChar = Format(CurrChar():2:"0":16)
    If CurrChar() < 0
      j = 16
    Else
      If j == 1
        HLine = HLine + HChar
      Else
        HLine = HLine + " " + HChar
      EndIf
    EndIf
  EndWhile
  HStrg = Format(k:8:"0":16)
  HHigh = SubStr(HStrg,1,4)
  HLow  = SubStr(HStrg,5,4)
  HAddr = HHigh + " " + HLow + "  "
  HRow  = (OLine - TLine) + WLine
  VGotoXY(21,HRow)
  Set(Attr,Color(BRIGHT White On Blue))
  PutLine(HAddr,11)
  VGotoXY(32,HRow)
  Set(Attr,Color(BRIGHT Cyan On Black))
  PutLine(HLine,Length(HLine))
End

Proc HexNew()
  GotoBufferId(Buff1)
  HAddr = ""
  HLine = ""
  k = (CLine-1)*16
  GotoLine(CLine)
  j = 0
  While j < 16
    j = j + 1
    GotoColumn(j)
    HChar = Format(CurrChar():2:"0":16)
    If CurrChar() < 0
      j = 16
    Else
      If j == 1
        HLine = HLine + HChar
      Else
        HLine = HLine + " " + HChar
      EndIf
    EndIf
  EndWhile
  HStrg = Format(k:8:"0":16)
  HHigh = SubStr(HStrg,1,4)
  HLow  = SubStr(HStrg,5,4)
  HAddr = HHigh + " " + HLow + "  "
  HRow  = WhereY()
  VGotoXY(21,HRow)
  Set(Attr,Color(BRIGHT White On Blue))
  PutLine(HAddr,11)
  VGotoXY(32,HRow)
  Set(Attr,Color(BRIGHT Cyan On Black))
  PutLine(HLine,Length(HLine))
  HRow = (CLine - TLine) + WLine
  HCol = ((CCol * 3) - 2) + 31
  VGotoXY(HCol,HRow)
  PutAttr(Color(Black on Cyan),2)
  GotoBufferID(Buff1)
  GotoLine(CLine)
  GotoColumn(CCol)
End

Proc EditHex()
  HChar = ""
  HChar = Format(CurrChar():2:"0":16)
  HRow  = WhereY()
  HCol = ((CCol * 3) - 2) + 31
  Message("Enter Hex Value...")
  VGotoXY(HCol,HRow)
  Read(HChar,2)
  If HChar == "00"
    InsertText(Chr(0))
  Else
    i = Val(HChar,16)
    If i <> 0
      InsertText(Chr(i))
    Else
      Alarm()
      Message("Invalid hexadecimal input...")
    EndIf
  EndIf
  UpdateDisplay()
  HexScrn()
End

Proc FindHex()
  HStrg = "00000000"
  Message("Go to Hex Address: "+HStrg)
  VGotoXY(20,1)
  Read(HStrg,8)
  i = Val(HStrg,16)
  j = (i/16) + 1
  k = (i mod 16) + 1
  If j > NLine
    Alarm()
    Message("Invalid Hex Address...")
  Else
    GotoLine(j)
    GotoColumn(k)
    TLine = j
    BLine = Tline + WRows - 1
  EndIf
  UpdateDisplay()
  HexScrn()
End

Proc HexPgUp()
  If TLine > 1
    PageUp()
  EndIf
  UpdateDisplay()
  If TLine > 1
    BLine = Tline
    TLine = TLine - WRows + 1
  EndIf
  HexScrn()
End

Proc HexPgDn()
  If BLine < NLine
    PageDown()
  EndIf
  UpdateDisplay()
  If BLine < NLine
    TLine = BLine
    BLine = Tline + WRows - 1
    If BLine > NLine
      BLine = NLine
    EndIf
  EndIf
  HexScrn()
End

Proc HexDn()
  If CurrLine() < BLine
    OLine = CurrLine()
    Down()
    CLine = CurrLine()
    CCol  = CurrCol()
    UpdateDisplay()
    HexOld()
  EndIf
  HexNew()
End

Proc HexUp()
  If CurrLine() > TLine
    OLine = CurrLine()
    Up()
    CLine = CurrLine()
    CCol  = CurrCol()
    UpdateDisplay()
    HexOld()
  EndIf
  HexNew()
End

Proc HexLeft()
  If CurrCol() > 1
    Left()
    UpdateDisplay()
    CLine = CurrLine()
    CCol  = CurrCol()
    HexNew()
  Else
    If CurrLine() <> TLine
      GotoColumn(16)
    EndIf
    HexUp()
  EndIf
End

Proc HexRight()
  If CurrCol() < 16
    OLine = 0
    Right()
    If CurrChar() == _AT_EOL_
      Left()
    EndIf
    UpdateDisplay()
    CLine = CurrLine()
    CCol  = CurrCol()
    HexNew()
  Else
    GotoColumn(1)
    HexDn()
  EndIf
End

Proc ReFresh()
  HexScrn()
End

KeyDef HexKeys
  <PgUp>        HexPgUp()
  <PgDn>        HexPgDn()
  <CursorUp>    HexUp()
  <CursorDown>  HexDn()
  <CursorRight> HexRight()
  <CursorLeft>  HexLeft()
  <Alt E>       EditHex()
  <Alt G>       FindHex()
  <F5>          ReFresh()
  <HelpLine>    "{F1}-Help  {F5}-ReFresh  {F10}-Menu  {Alt H}-Toggle Hex  {Alt E}-Edit  {Alt G}-GoTo"
End

Proc HexOn()
  Enable(HexKeys)
  Buff1 = GetBufferId()
  NLine = NumLines()
  WLine = Query(WindowY1)
  WRows = Query(WindowRows)
  TLine = CurrLine()
  BLine = Tline + WRows - 1
  If Query(Insert)
    ToggleInsert()
  EndIf
  Buff2 = CreateBuffer("Hex",_HIDDEN_)
End

Proc HexOff()
  Disable(HexKeys)
  GotoBufferId(Buff1)
  SLine = CurrLine()
  SChar = CurrCol()
  GotoBufferID(Buff2)
  EmptyBuffer()
  CloseWindow()
  UpdateDisplay()
  AbandonFile(Buff2)
  GotoBufferId(Buff1)
  GotoLine(SLine)
  GotoColumn(SChar)
End

Proc HexMode()
  If Not Hex
    HexOn()
    Hex = 1
    HexScrn()
  Else
    HexOff()
    Hex = 0
  EndIf
End

<Alt H> HexMode()
