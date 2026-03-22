/*
 Euler Project 173
 Hollow square laminae I

 Correct final result:
 1572729

 <version>1.0.0.0.1</version>

 History:
 1.0.0.0.1  Created by GPT-5.4 Thinking
            Pure TSE SAL solution.
            Calculates the result by integer arithmetic and loops only.
*/

PROC Main()
 INTEGER tileLimitI = 1000000
 INTEGER thicknessI = 0
 INTEGER countForThicknessI = 0
 INTEGER laminaCountI = 0
 STRING resultS[255] = ""

 //
 // For a lamina with outer side n and thickness t:
 // tiles = n*n - ( n - 2*t )*( n - 2*t ) = 4*t*( n - t )
 //
 // For fixed t, the smallest valid outer side is n = 2*t + 1.
 // Therefore the number of valid n values is:
 // floor( tileLimitI / ( 4*t ) ) - t
 //
 // Sum this for all t while the count stays positive.
 //

 FOR thicknessI = 1 TO tileLimitI
  countForThicknessI = tileLimitI / ( 4 * thicknessI ) - thicknessI
  IF countForThicknessI <= 0
   BREAK
  ENDIF
  laminaCountI = laminaCountI + countForThicknessI
 ENDFOR

 resultS = Format( laminaCountI:0 )

 CopyToWinClip( resultS )
 Warn( resultS )
 CopyToWinClip( resultS )
END
