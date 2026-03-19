// TSE SAL program for Project Euler problem 126
// Finds the least value of n for which C(n) = 1000
// Created by GPT-5.4 Thinking
// <version>1.0.0.0.0</version>

string gVersionS[32]   = "1.0.0.0.0"
string gCreatedByS[64] = "GPT-5.4 Thinking"

//

INTEGER PROC LayerCubes( INTEGER aI, INTEGER bI, INTEGER cI, INTEGER layerIndexI )
  INTEGER resultI = 0
  //
  resultI = 2 * ( aI * bI + aI * cI + bI * cI )
  resultI = resultI + 4 * ( layerIndexI - 1 ) * ( aI + bI + cI )
  resultI = resultI + 4 * ( layerIndexI - 1 ) * ( layerIndexI - 2 )
  Return( resultI )
END

INTEGER PROC CountBufferCreate( INTEGER limitI )
  INTEGER bufferI = 0
  INTEGER indexI  = 0
  //
  bufferI = CreateTempBuffer()
  IF bufferI == 0
    Return( 0 )
  ENDIF
  //
  indexI = 1
  WHILE indexI <= limitI
    AddLine( "0", bufferI )
    indexI = indexI + 1
  ENDWHILE
  //
  Return( bufferI )
END

INTEGER PROC BufferLineIntegerGet( INTEGER bufferI, INTEGER lineNumberI )
  string valueS[64] = ""
  INTEGER valueI    = 0
  //
  GotoBufferId( bufferI )
  GotoLine( lineNumberI )
  valueS = Trim( GetText( 1, 63 ) )
  IF valueS == ""
    valueI = 0
  ELSE
    valueI = Val( valueS )
  ENDIF
  Return( valueI )
END

PROC BufferLineIntegerSet( INTEGER bufferI, INTEGER lineNumberI, INTEGER valueI )
  //
  GotoBufferId( bufferI )
  GotoLine( lineNumberI )
  BegLine()
  KillToEol()
  InsertText( Format( valueI ) )
END

PROC BufferLineIntegerIncrement( INTEGER bufferI, INTEGER lineNumberI )
  INTEGER valueI = 0
  //
  valueI = BufferLineIntegerGet( bufferI, lineNumberI )
  valueI = valueI + 1
  BufferLineIntegerSet( bufferI, lineNumberI, valueI )
END

INTEGER PROC FirstTargetCountSearch( INTEGER bufferI, INTEGER limitI, INTEGER targetCountI )
  INTEGER numberI = 0
  INTEGER countI  = 0
  //
  numberI = 1
  WHILE numberI <= limitI
    countI = BufferLineIntegerGet( bufferI, numberI )
    IF countI == targetCountI
      Return( numberI )
    ENDIF
    numberI = numberI + 1
  ENDWHILE
  //
  Return( 0 )
END

INTEGER PROC FormulaSelfTest()
  INTEGER okB = TRUE
  //
  IF LayerCubes( 3, 2, 1, 1 ) <> 22
    okB = FALSE
  ENDIF
  IF LayerCubes( 3, 2, 1, 2 ) <> 46
    okB = FALSE
  ENDIF
  IF LayerCubes( 3, 2, 1, 3 ) <> 78
    okB = FALSE
  ENDIF
  IF LayerCubes( 3, 2, 1, 4 ) <> 118
    okB = FALSE
  ENDIF
  //
  Return( okB )
END

INTEGER PROC Euler126Solve( INTEGER targetCountI )
  INTEGER limitI           = 20000
  INTEGER answerI          = 0
  INTEGER countBufferI     = 0
  INTEGER aI               = 0
  INTEGER bI               = 0
  INTEGER cI               = 0
  INTEGER firstLayerI      = 0
  INTEGER layerCubesI      = 0
  INTEGER incrementI       = 0
  INTEGER extraI           = 0
  INTEGER abLowerBoundI    = 0
  //
  WHILE TRUE
    countBufferI = CountBufferCreate( limitI )
    IF countBufferI == 0
      Return( -1 )
    ENDIF
    //
    aI = 1
    WHILE 4 * aI + 2 <= limitI
      bI = 1
      WHILE bI <= aI
        abLowerBoundI = 2 * ( aI * bI + aI + bI )
        IF abLowerBoundI > limitI
          bI = aI + 1
        ELSE
          cI = 1
          WHILE cI <= bI
            firstLayerI = 2 * ( aI * bI + aI * cI + bI * cI )
            IF firstLayerI > limitI
              cI = bI + 1
            ELSE
              layerCubesI = firstLayerI
              incrementI  = 4 * ( aI + bI + cI )
              extraI      = 0
              WHILE layerCubesI <= limitI
                BufferLineIntegerIncrement( countBufferI, layerCubesI )
                layerCubesI = layerCubesI + incrementI + extraI
                extraI = extraI + 8
              ENDWHILE
              cI = cI + 1
            ENDIF
          ENDWHILE
          bI = bI + 1
        ENDIF
      ENDWHILE
      aI = aI + 1
    ENDWHILE
    //
    answerI = FirstTargetCountSearch( countBufferI, limitI, targetCountI )
    IF answerI > 0
      AbandonFile( countBufferI )
      Return( answerI )
    ENDIF
    //
    AbandonFile( countBufferI )
    limitI = limitI + 10000
    IF limitI > 120000
      Return( -2 )
    ENDIF
  ENDWHILE
  //
  Return( 0 )
END

PROC Main()
  INTEGER originalBufferI = 0
  INTEGER answerI         = 0
  string answerS[64]      = ""
  string messageS[255]    = ""
  //
  originalBufferI = GetBufferId()
  //
  IF NOT FormulaSelfTest()
    Warn( "Euler 126 self-test failed." )
    Return()
  ENDIF
  //
  answerI = Euler126Solve( 1000 )
  //
  IF answerI == -1
    Warn( "Unable to create temp buffer." )
    Return()
  ENDIF
  //
  IF answerI == -2
    Warn( "Search limit exhausted before finding the answer." )
    Return()
  ENDIF
  //
  answerS = Format( answerI )
  CopyToWinClip( answerS )
  //
  messageS = "Project Euler 126 answer = " + answerS + Chr( 13 )
  messageS = messageS + "Version " + gVersionS + Chr( 13 )
  messageS = messageS + "Created by " + gCreatedByS
  Warn( messageS )
  //
  GotoBufferId( originalBufferI )
  Return()
END
