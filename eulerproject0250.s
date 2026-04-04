/*
 eulerproject0250.s
 <version>2</version>
 HISTORY: Created by ChatGPT GPT-5.4 Thinking

 RULE CHECK APPLIED IN THIS SOURCE:
 1. Pure TSE SAL only.
 2. Full program supplied.
 3. RETURN() always uses parentheses.
 4. No variable named val or pos.
 5. Exactly one final Warn() box only.
 6. CopyToWinClip() before and after final Warn().
 7. Final Warn() shows only the answer.
 8. PROC Main() is the final proc in the file.
 9. No hard coded final answer.
10. String parameter declarations do NOT use [255].
11. String local variables use fixed sizes <= 255.
12. Uses integer-only modular exponentiation for i^i mod 250.
13. Uses decimal-string arithmetic modulo 10^16.
14. Uses temp buffers as SAL array replacements.
15. Version increased linearly at one place only.
*/

FORWARD INTEGER PROC ProcModPower( INTEGER baseI, INTEGER exponentI, INTEGER modulusI )
FORWARD STRING  PROC ProcPad16( STRING numberS )
FORWARD STRING  PROC ProcAdd16( STRING leftS, STRING rightS )
FORWARD STRING  PROC ProcSubOne16( STRING numberS )
FORWARD STRING  PROC ProcMul16( STRING leftS, STRING rightS )
FORWARD INTEGER PROC ProcCreatePolyBuffer()
FORWARD STRING  PROC ProcBufferRead( INTEGER bufferIdI, INTEGER lineI )
FORWARD PROC    ProcBufferWrite( INTEGER bufferIdI, INTEGER lineI, STRING valueS )
FORWARD PROC    ProcPolyZero( INTEGER bufferIdI )
FORWARD PROC    ProcPolyIdentity( INTEGER bufferIdI )
FORWARD PROC    ProcPolyCopy( INTEGER sourceBufferIdI, INTEGER targetBufferIdI )
FORWARD PROC    ProcPolyMultiply( INTEGER leftBufferIdI, INTEGER rightBufferIdI, INTEGER resultBufferIdI )
FORWARD PROC    ProcBuildRangePoly( INTEGER firstI, INTEGER lastI, INTEGER resultBufferIdI, INTEGER scratchBufferIdI )
FORWARD PROC    ProcPolyPower( INTEGER baseBufferIdI, INTEGER exponentI, INTEGER resultBufferIdI, INTEGER scratch1BufferIdI, INTEGER scratch2BufferIdI )

INTEGER PROC ProcModPower( INTEGER baseI, INTEGER exponentI, INTEGER modulusI )
 INTEGER answerI = 1
 INTEGER workBaseI = baseI mod modulusI
 INTEGER workExponentI = exponentI
 //
 WHILE workExponentI > 0
  IF workExponentI & 1
   answerI = ( answerI * workBaseI ) mod modulusI
  ENDIF
  workBaseI = ( workBaseI * workBaseI ) mod modulusI
  workExponentI = workExponentI shr 1
 ENDWHILE
 RETURN( answerI )
END

STRING PROC ProcPad16( STRING numberS )
 STRING workS[255] = numberS
 //
 WHILE Length( workS ) < 16
  workS = "0" + workS
 ENDWHILE
 IF Length( workS ) > 16
  workS = SubStr( workS, Length( workS ) - 15, 16 )
 ENDIF
 RETURN( workS )
END

STRING PROC ProcAdd16( STRING leftS, STRING rightS )
 STRING workLeftS[255] = ""
 STRING workRightS[255] = ""
 STRING answerS[255] = ""
 INTEGER carryI = 0
 INTEGER indexI = 0
 INTEGER leftChunkI = 0
 INTEGER rightChunkI = 0
 INTEGER sumChunkI = 0
 INTEGER digitChunkI = 0
 //
 workLeftS = ProcPad16( leftS )
 workRightS = ProcPad16( rightS )
 FOR indexI = 13 DOWNTO 1 BY 4
  leftChunkI = Val( SubStr( workLeftS, indexI, 4 ) )
  rightChunkI = Val( SubStr( workRightS, indexI, 4 ) )
  sumChunkI = leftChunkI + rightChunkI + carryI
  digitChunkI = sumChunkI mod 10000
  carryI = sumChunkI / 10000
  answerS = Format( digitChunkI:4:"0" ) + answerS
 ENDFOR
 answerS = SubStr( answerS, Length( answerS ) - 15, 16 )
 RETURN( answerS )
END

STRING PROC ProcSubOne16( STRING numberS )
 STRING workS[255] = ""
 STRING answerS[255] = ""
 INTEGER borrowI = 1
 INTEGER indexI = 0
 INTEGER chunkI = 0
 //
 workS = ProcPad16( numberS )
 FOR indexI = 13 DOWNTO 1 BY 4
  chunkI = Val( SubStr( workS, indexI, 4 ) ) - borrowI
  IF chunkI < 0
   chunkI = chunkI + 10000
   borrowI = 1
  ELSE
   borrowI = 0
  ENDIF
  answerS = Format( chunkI:4:"0" ) + answerS
 ENDFOR
 RETURN( answerS )
END

STRING PROC ProcMul16( STRING leftS, STRING rightS )
 STRING workLeftS[255] = ""
 STRING workRightS[255] = ""
 STRING answerS[255] = ""
 INTEGER a0I = 0
 INTEGER a1I = 0
 INTEGER a2I = 0
 INTEGER a3I = 0
 INTEGER b0I = 0
 INTEGER b1I = 0
 INTEGER b2I = 0
 INTEGER b3I = 0
 INTEGER carryI = 0
 INTEGER accumI = 0
 INTEGER d0I = 0
 INTEGER d1I = 0
 INTEGER d2I = 0
 INTEGER d3I = 0
 //
 workLeftS = ProcPad16( leftS )
 workRightS = ProcPad16( rightS )
 a3I = Val( SubStr( workLeftS,  1, 4 ) )
 a2I = Val( SubStr( workLeftS,  5, 4 ) )
 a1I = Val( SubStr( workLeftS,  9, 4 ) )
 a0I = Val( SubStr( workLeftS, 13, 4 ) )
 b3I = Val( SubStr( workRightS,  1, 4 ) )
 b2I = Val( SubStr( workRightS,  5, 4 ) )
 b1I = Val( SubStr( workRightS,  9, 4 ) )
 b0I = Val( SubStr( workRightS, 13, 4 ) )
 //
 accumI = a0I * b0I
 d0I = accumI mod 10000
 carryI = accumI / 10000
 //
 accumI = carryI + a1I * b0I + a0I * b1I
 d1I = accumI mod 10000
 carryI = accumI / 10000
 //
 accumI = carryI + a2I * b0I + a1I * b1I + a0I * b2I
 d2I = accumI mod 10000
 carryI = accumI / 10000
 //
 accumI = carryI + a3I * b0I + a2I * b1I + a1I * b2I + a0I * b3I
 d3I = accumI mod 10000
 //
 answerS = Format( d3I:4:"0" ) + Format( d2I:4:"0" ) + Format( d1I:4:"0" ) + Format( d0I:4:"0" )
 RETURN( answerS )
END

INTEGER PROC ProcCreatePolyBuffer()
 INTEGER bufferIdI = 0
 INTEGER lineI = 0
 //
 bufferIdI = CreateTempBuffer()
 FOR lineI = 1 TO 250
  AddLine( "0000000000000000", bufferIdI )
 ENDFOR
 RETURN( bufferIdI )
END

STRING PROC ProcBufferRead( INTEGER bufferIdI, INTEGER lineI )
 STRING answerS[255] = ""
 //
 PushLocation()
 GotoBufferId( bufferIdI )
 GotoLine( lineI )
 answerS = GetText( 1, 16 )
 PopLocation()
 RETURN( answerS )
END

PROC ProcBufferWrite( INTEGER bufferIdI, INTEGER lineI, STRING valueS )
 STRING workS[255] = ""
 //
 workS = ProcPad16( valueS )
 PushLocation()
 GotoBufferId( bufferIdI )
 GotoLine( lineI )
 BegLine()
 KillToEol()
 InsertText( workS )
 PopLocation()
END

PROC ProcPolyZero( INTEGER bufferIdI )
 INTEGER lineI = 0
 //
 FOR lineI = 1 TO 250
  ProcBufferWrite( bufferIdI, lineI, "0000000000000000" )
 ENDFOR
END

PROC ProcPolyIdentity( INTEGER bufferIdI )
 //
 ProcPolyZero( bufferIdI )
 ProcBufferWrite( bufferIdI, 1, "0000000000000001" )
END

PROC ProcPolyCopy( INTEGER sourceBufferIdI, INTEGER targetBufferIdI )
 INTEGER lineI = 0
 STRING valueS[255] = ""
 //
 FOR lineI = 1 TO 250
  valueS = ProcBufferRead( sourceBufferIdI, lineI )
  ProcBufferWrite( targetBufferIdI, lineI, valueS )
 ENDFOR
END

PROC ProcPolyMultiply( INTEGER leftBufferIdI, INTEGER rightBufferIdI, INTEGER resultBufferIdI )
 INTEGER leftIndexI = 0
 INTEGER rightIndexI = 0
 INTEGER targetIndexI = 0
 STRING leftS[255] = ""
 STRING rightS[255] = ""
 STRING oldS[255] = ""
 STRING productS[255] = ""
 STRING sumS[255] = ""
 //
 ProcPolyZero( resultBufferIdI )
 FOR leftIndexI = 0 TO 249
  leftS = ProcBufferRead( leftBufferIdI, leftIndexI + 1 )
  IF NOT ( leftS == "0000000000000000" )
   FOR rightIndexI = 0 TO 249
    rightS = ProcBufferRead( rightBufferIdI, rightIndexI + 1 )
    IF NOT ( rightS == "0000000000000000" )
     targetIndexI = ( leftIndexI + rightIndexI ) mod 250
     oldS = ProcBufferRead( resultBufferIdI, targetIndexI + 1 )
     productS = ProcMul16( leftS, rightS )
     sumS = ProcAdd16( oldS, productS )
     ProcBufferWrite( resultBufferIdI, targetIndexI + 1, sumS )
    ENDIF
   ENDFOR
  ENDIF
 ENDFOR
END

PROC ProcBuildRangePoly( INTEGER firstI, INTEGER lastI, INTEGER resultBufferIdI, INTEGER scratchBufferIdI )
 INTEGER numberI = 0
 INTEGER residueI = 0
 INTEGER lineI = 0
 INTEGER targetLineI = 0
 STRING currentS[255] = ""
 STRING shiftedS[255] = ""
 STRING oldS[255] = ""
 //
 ProcPolyIdentity( resultBufferIdI )
 FOR numberI = firstI TO lastI
  residueI = ProcModPower( numberI, numberI, 250 )
  ProcPolyZero( scratchBufferIdI )
  FOR lineI = 0 TO 249
   currentS = ProcBufferRead( resultBufferIdI, lineI + 1 )
   oldS = ProcBufferRead( scratchBufferIdI, lineI + 1 )
   ProcBufferWrite( scratchBufferIdI, lineI + 1, ProcAdd16( oldS, currentS ) )
   targetLineI = ( lineI + residueI ) mod 250
   shiftedS = ProcBufferRead( scratchBufferIdI, targetLineI + 1 )
   ProcBufferWrite( scratchBufferIdI, targetLineI + 1, ProcAdd16( shiftedS, currentS ) )
  ENDFOR
  ProcPolyCopy( scratchBufferIdI, resultBufferIdI )
 ENDFOR
END

PROC ProcPolyPower( INTEGER baseBufferIdI, INTEGER exponentI, INTEGER resultBufferIdI, INTEGER scratch1BufferIdI, INTEGER scratch2BufferIdI )
 INTEGER workExponentI = exponentI
 //
 ProcPolyIdentity( resultBufferIdI )
 ProcPolyCopy( baseBufferIdI, scratch2BufferIdI )
 WHILE workExponentI > 0
  IF workExponentI & 1
   ProcPolyMultiply( resultBufferIdI, scratch2BufferIdI, scratch1BufferIdI )
   ProcPolyCopy( scratch1BufferIdI, resultBufferIdI )
  ENDIF
  workExponentI = workExponentI shr 1
  IF workExponentI > 0
   ProcPolyMultiply( scratch2BufferIdI, scratch2BufferIdI, scratch1BufferIdI )
   ProcPolyCopy( scratch1BufferIdI, scratch2BufferIdI )
  ENDIF
 ENDWHILE
END

PROC Main()
 INTEGER blockBufferI = 0
 INTEGER tailBufferI = 0
 INTEGER powerBufferI = 0
 INTEGER finalBufferI = 0
 INTEGER scratch1BufferI = 0
 INTEGER scratch2BufferI = 0
 STRING answerS[255] = ""
 //
 blockBufferI = ProcCreatePolyBuffer()
 tailBufferI = ProcCreatePolyBuffer()
 powerBufferI = ProcCreatePolyBuffer()
 finalBufferI = ProcCreatePolyBuffer()
 scratch1BufferI = ProcCreatePolyBuffer()
 scratch2BufferI = ProcCreatePolyBuffer()
 //
 ProcBuildRangePoly( 1, 500, blockBufferI, scratch1BufferI )
 ProcBuildRangePoly( 1, 250, tailBufferI, scratch1BufferI )
 ProcPolyPower( blockBufferI, 500, powerBufferI, scratch1BufferI, scratch2BufferI )
 ProcPolyMultiply( powerBufferI, tailBufferI, finalBufferI )
 answerS = ProcBufferRead( finalBufferI, 1 )
 answerS = ProcSubOne16( answerS )
 CopyToWinClip( answerS )
 Warn( answerS )
 CopyToWinClip( answerS )
 //
 AbandonFile( blockBufferI )
 AbandonFile( tailBufferI )
 AbandonFile( powerBufferI )
 AbandonFile( finalBufferI )
 AbandonFile( scratch1BufferI )
 AbandonFile( scratch2BufferI )
END
