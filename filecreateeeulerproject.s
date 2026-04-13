PROC Main()
 //
 STRING s[255] = ""
 //
 INTEGER I = 0
 INTEGER minI = 269
 INTEGER maxI = minI
 // INTEGER maxI = minI + 1
 // INTEGER maxI = minI + 2
 //
 FOR I = minI TO maxI
  //
  EditFile( Format( "eulerproject", "0", I, ".s" ) )
  //
  IF ( YesNo( Format( I, ":", " ", "Claude?" ) )== 1 )
   s = "Claude"
  ENDIF
  //
  IF ( YesNo( Format( I, ":", " ", "ChatGPT?" ) )== 1 )
   s = "ChatGPT"
  ENDIF
  //
  IF ( YesNo( Format( I, ":", " ", "Google Gemini?" ) )== 1 )
   s = "Gemini"
  ENDIF
  //
  EditFile( Format( "eulerproject", "0", I, s, ".s" ) )
  //
 ENDFOR
 //
END
