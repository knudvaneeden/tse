/*
  Euler Project 223
  Almost Right-angled Triangles I
  version 1.0.0.0.5
  history:
    1.0.0.0.1  ChatGPT  GPT-5.4 Thinking  initial pure TSE SAL version
    1.0.0.0.2  ChatGPT  GPT-5.4 Thinking  fixed NumLines() usage
    1.0.0.0.3  ChatGPT  GPT-5.4 Thinking  fixed constant string parameter reassignment
    1.0.0.0.4  ChatGPT  GPT-5.4 Thinking  redesigned with fast tree generation
    1.0.0.0.5  ChatGPT  GPT-5.4 Thinking  removed recursion, added iterative stack
*/

FORWARD INTEGER PROC ProcCreateHiddenBufferI()
FORWARD INTEGER PROC ProcBufferNumLinesI( INTEGER bufferIdI )
FORWARD PROC ProcSetBufferLine( INTEGER bufferIdI, INTEGER lineNumberI, STRING textS )
FORWARD INTEGER PROC ProcGetBufferLineIntegerI( INTEGER bufferIdI, INTEGER lineNumberI )
FORWARD PROC ProcPushTriangle( INTEGER aI, INTEGER bI, INTEGER cI )
FORWARD INTEGER PROC ProcPopTriangleA()
FORWARD INTEGER PROC ProcPopTriangleB()
FORWARD INTEGER PROC ProcPopTriangleC()
FORWARD PROC ProcPushChild( INTEGER xI, INTEGER yI, INTEGER zI )
FORWARD PROC ProcMaybePushChildren( INTEGER aI, INTEGER bI, INTEGER cI )

INTEGER gLimitI = 25000000
INTEGER gCountI = 0
INTEGER gStackTopI = 0
INTEGER gStackABufferI = 0
INTEGER gStackBBufferI = 0
INTEGER gStackCBufferI = 0

INTEGER PROC ProcCreateHiddenBufferI()
  INTEGER bufferIdI = 0

  bufferIdI = CreateTempBuffer()
  IF bufferIdI
    PushLocation()
    GotoBufferId( bufferIdI )
    EmptyBuffer()
    PopLocation()
  ENDIF

  RETURN( bufferIdI )
END

INTEGER PROC ProcBufferNumLinesI( INTEGER bufferIdI )
  INTEGER lineCountI = 0

  PushLocation()
  GotoBufferId( bufferIdI )
  lineCountI = NumLines()
  PopLocation()

  RETURN( lineCountI )
END

PROC ProcSetBufferLine( INTEGER bufferIdI, INTEGER lineNumberI, STRING textS )
  INTEGER lineCountI = 0

  PushLocation()
  GotoBufferId( bufferIdI )
  lineCountI = NumLines()

  IF lineNumberI <= lineCountI
    GotoLine( lineNumberI )
    BegLine()
    KillToEol()
    InsertText( textS )
  ELSE
    EndFile()
    AddLine( textS )
  ENDIF

  PopLocation()
END

INTEGER PROC ProcGetBufferLineIntegerI( INTEGER bufferIdI, INTEGER lineNumberI )
  STRING textS[255] = ""

  PushLocation()
  GotoBufferId( bufferIdI )
  GotoLine( lineNumberI )
  textS = GetText( 1, 255 )
  PopLocation()

  RETURN( Val( textS ) )
END

PROC ProcPushTriangle( INTEGER aI, INTEGER bI, INTEGER cI )
  gStackTopI = gStackTopI + 1
  ProcSetBufferLine( gStackABufferI, gStackTopI, Format( aI ) )
  ProcSetBufferLine( gStackBBufferI, gStackTopI, Format( bI ) )
  ProcSetBufferLine( gStackCBufferI, gStackTopI, Format( cI ) )
END

INTEGER PROC ProcPopTriangleA()
  RETURN( ProcGetBufferLineIntegerI( gStackABufferI, gStackTopI ) )
END

INTEGER PROC ProcPopTriangleB()
  RETURN( ProcGetBufferLineIntegerI( gStackBBufferI, gStackTopI ) )
END

INTEGER PROC ProcPopTriangleC()
  INTEGER valueI = 0

  valueI = ProcGetBufferLineIntegerI( gStackCBufferI, gStackTopI )
  gStackTopI = gStackTopI - 1

  RETURN( valueI )
END

PROC ProcPushChild( INTEGER xI, INTEGER yI, INTEGER zI )
  INTEGER tempI = 0

  IF xI <= 0 OR yI <= 0 OR zI <= 0
    RETURN()
  ENDIF

  IF xI > yI
    tempI = xI
    xI = yI
    yI = tempI
  ENDIF

  IF xI + yI + zI > gLimitI
    RETURN()
  ENDIF

  ProcPushTriangle( xI, yI, zI )
END

PROC ProcMaybePushChildren( INTEGER aI, INTEGER bI, INTEGER cI )
  INTEGER xI = 0
  INTEGER yI = 0
  INTEGER zI = 0

  xI = aI - 2 * bI + 2 * cI
  yI = 2 * aI - bI + 2 * cI
  zI = 2 * aI - 2 * bI + 3 * cI
  ProcPushChild( xI, yI, zI )

  xI = aI + 2 * bI + 2 * cI
  yI = 2 * aI + bI + 2 * cI
  zI = 2 * aI + 2 * bI + 3 * cI
  ProcPushChild( xI, yI, zI )

  IF NOT( aI == bI )
    xI = -aI + 2 * bI + 2 * cI
    yI = -2 * aI + bI + 2 * cI
    zI = -2 * aI + 2 * bI + 3 * cI
    ProcPushChild( xI, yI, zI )
  ENDIF
END

PROC Main()
  INTEGER aI = 0
  INTEGER bI = 0
  INTEGER cI = 0
  INTEGER perimeterI = 0
  STRING resultS[255] = ""

  gStackABufferI = ProcCreateHiddenBufferI()
  gStackBBufferI = ProcCreateHiddenBufferI()
  gStackCBufferI = ProcCreateHiddenBufferI()

  gCountI = 0
  gStackTopI = 0

  ProcPushTriangle( 1, 1, 1 )
  ProcPushTriangle( 1, 2, 2 )

  WHILE gStackTopI > 0
    aI = ProcPopTriangleA()
    bI = ProcPopTriangleB()
    cI = ProcPopTriangleC()

    perimeterI = aI + bI + cI
    IF perimeterI <= gLimitI
      gCountI = gCountI + 1
      ProcMaybePushChildren( aI, bI, cI )
    ENDIF
  ENDWHILE

  resultS = Format( gCountI )

  CopyToWinClip( resultS )
  Warn( resultS )
  CopyToWinClip( resultS )

  AbandonFile( gStackABufferI )
  AbandonFile( gStackBBufferI )
  AbandonFile( gStackCBufferI )
END
