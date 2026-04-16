// Project Euler 290 //
// Digital Signature
// Pure TSE SAL
// Version 2
#DEFINE SIGNATURE   137
#DEFINE DIGIT_LIMIT 18
#DEFINE V_MIN       -116
#DEFINE V_MAX       116
#DEFINE V_COUNT     233
#DEFINE U_COUNT     137
#DEFINE LINE_OFFSET 1
#DEFINE BIG_BASE    1000000
#DEFINE HISTORY_LLM 1
INTEGER gWorkHighGI = 0
INTEGER gWorkMidGI  = 0
INTEGER gWorkLowGI  = 0
INTEGER PROC FNStateLineI( INTEGER uI, INTEGER vI )
  RETURN( uI * V_COUNT + ( vI - V_MIN ) + LINE_OFFSET )
END
INTEGER PROC FNDecimalDigitSumI( INTEGER numberI )
  INTEGER workI = numberI
  INTEGER sumI = 0
  WHILE ( workI > 0 )
    sumI = sumI + workI mod 10
    workI = workI / 10
  ENDWHILE
  RETURN( sumI )
END
STRING PROC FNBigToLineS( INTEGER highI, INTEGER midI, INTEGER lowI )
  STRING resultS[255] = ""
  resultS = Format( highI ) + "," + Format( midI ) + "," + Format( lowI )
  RETURN( resultS )
END
STRING PROC FNBigToDisplayS( INTEGER highI, INTEGER midI, INTEGER lowI )
  STRING resultS[255] = ""
  IF ( highI > 0 )
    resultS = Format( highI ) + Format( midI : 6 : "0" ) + Format( lowI : 6 : "0" )
  ELSE
    IF ( midI > 0 )
      resultS = Format( midI ) + Format( lowI : 6 : "0" )
    ELSE
      resultS = Format( lowI )
    ENDIF
  ENDIF
  RETURN( resultS )
END
PROC PROCResetWork()
  gWorkHighGI = 0
  gWorkMidGI  = 0
  gWorkLowGI  = 0
END
PROC PROCAddLineToWork( STRING countS )
  INTEGER parsedHighI = 0
  INTEGER parsedMidI = 0
  INTEGER parsedLowI = 0
  parsedHighI = Val( GetToken( countS, ",", 1 ) )
  parsedMidI  = Val( GetToken( countS, ",", 2 ) )
  parsedLowI  = Val( GetToken( countS, ",", 3 ) )
  gWorkLowGI  = gWorkLowGI + parsedLowI
  gWorkMidGI  = gWorkMidGI + parsedMidI
  gWorkHighGI = gWorkHighGI + parsedHighI
  IF ( gWorkLowGI >= BIG_BASE )
    gWorkMidGI = gWorkMidGI + gWorkLowGI / BIG_BASE
    gWorkLowGI = gWorkLowGI mod BIG_BASE
  ENDIF
  IF ( gWorkMidGI >= BIG_BASE )
    gWorkHighGI = gWorkHighGI + gWorkMidGI / BIG_BASE
    gWorkMidGI  = gWorkMidGI mod BIG_BASE
  ENDIF
END
PROC Main()
  INTEGER prevBufferI = 0
  INTEGER currBufferI = 0
  INTEGER digitsLeftI = 0
  INTEGER uI = 0
  INTEGER vI = 0
  INTEGER digitI = 0
  INTEGER baseCountI = 0
  INTEGER productI = 0
  INTEGER nextUI = 0
  INTEGER nextVI = 0
  INTEGER sourceLineI = 0
  STRING countS[255] = ""
  STRING resultS[255] = ""
  STRING finalAnswerS[255] = ""
  PushLocation()
  AddHistoryStr( "ChatGPT Euler 290", HISTORY_LLM )
  prevBufferI = CreateTempBuffer()
  FOR uI = 0 TO U_COUNT - 1
    FOR vI = V_MIN TO V_MAX
      baseCountI = 0
      FOR digitI = 0 TO 9
        IF ( FNDecimalDigitSumI( SIGNATURE * digitI + uI ) + vI == digitI )
          baseCountI = baseCountI + 1
        ENDIF
      ENDFOR
      resultS = "0,0," + Format( baseCountI )
      AddLine( resultS, prevBufferI )
    ENDFOR
  ENDFOR
  FOR digitsLeftI = 2 TO DIGIT_LIMIT
    currBufferI = CreateTempBuffer()
    FOR uI = 0 TO U_COUNT - 1
      FOR vI = V_MIN TO V_MAX
        PROCResetWork()
        GotoBufferId( prevBufferI )
        FOR digitI = 0 TO 9
          productI = SIGNATURE * digitI + uI
          nextUI   = productI / 10
          nextVI   = productI mod 10 + vI - digitI
          IF ( nextVI >= V_MIN AND nextVI <= V_MAX )
            sourceLineI = FNStateLineI( nextUI, nextVI )
            GotoLine( sourceLineI )
            countS = GetText( 1, CurrLineLen() )
            PROCAddLineToWork( countS )
          ENDIF
        ENDFOR
        resultS = FNBigToLineS( gWorkHighGI, gWorkMidGI, gWorkLowGI )
        AddLine( resultS, currBufferI )
      ENDFOR
    ENDFOR
    GotoBufferId( prevBufferI )
    AbandonFile()
    prevBufferI = currBufferI
  ENDFOR
  GotoBufferId( prevBufferI )
  GotoLine( FNStateLineI( 0, 0 ) )
  countS = GetText( 1, CurrLineLen() )
  PROCResetWork()
  PROCAddLineToWork( countS )
  finalAnswerS = FNBigToDisplayS( gWorkHighGI, gWorkMidGI, gWorkLowGI )
  CopyToWinClip( finalAnswerS )
  Warn( finalAnswerS )
  CopyToWinClip( finalAnswerS )
  AbandonFile()
  PopLocation()
END
