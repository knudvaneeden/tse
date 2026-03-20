/*
  Euler Project 147 - Rectangles in Cross-hatched Grids
  Pure TSE SAL solution
  <version>1.0.0.0</version>

  History:
  1.0.0.0 - 2026-03-20 - Created by ChatGPT GPT-5.4 Thinking

  Notes:
  - Pure TSE SAL only
  - Integer arithmetic only
  - Final answer is shown with Warn()
  - Only the bare final answer is copied with CopyToWinClip()
*/

INTEGER PROC ProcTriangle( INTEGER numberI )
 INTEGER resultI = 0
 resultI = ( numberI * ( numberI + 1 ) ) / 2
 RETURN( resultI )
END

INTEGER PROC ProcCountUprightRectangles( INTEGER widthI, INTEGER heightI )
 INTEGER resultI = 0
 resultI = ProcTriangle( widthI ) * ProcTriangle( heightI )
 RETURN( resultI )
END

INTEGER PROC ProcCountDiagonalRectangles( INTEGER widthI, INTEGER heightI )
 INTEGER longerSideI = 0
 INTEGER shorterSideI = 0
 INTEGER temporaryI = 0
 INTEGER totalCountI = 0
 INTEGER iI = 0
 INTEGER jI = 0
 INTEGER parityI = 0
 INTEGER startXI = 0
 INTEGER startYI = 0
 INTEGER stopB = FALSE
 INTEGER maxHeightI = 0
 INTEGER currentWidthI = 0
 INTEGER currentXI = 0
 INTEGER currentYI = 0
 INTEGER currentHeightI = 0
 INTEGER endXI = 0
 INTEGER endYI = 0
 INTEGER limitReachedB = FALSE
 INTEGER doubledLongerSideI = 0
 INTEGER doubledShorterSideI = 0

 longerSideI  = widthI
 shorterSideI = heightI

 IF longerSideI < shorterSideI
  temporaryI   = longerSideI
  longerSideI  = shorterSideI
  shorterSideI = temporaryI
 ENDIF

 doubledLongerSideI  = 2 * longerSideI
 doubledShorterSideI = 2 * shorterSideI
 totalCountI = 0

 iI = 0
 WHILE iI < longerSideI
  jI = 0
  WHILE jI < shorterSideI
   parityI = 0
   WHILE parityI <= 1
    startXI = ( 2 * iI ) + 1 + parityI
    startYI = ( 2 * jI ) + 2 - parityI
    stopB = FALSE
    maxHeightI = 2147483647
    currentWidthI = 0

    WHILE stopB == FALSE
     currentXI = startXI + currentWidthI
     currentYI = startYI - currentWidthI

     IF currentYI <= 0
      stopB = TRUE
     ELSE
      currentHeightI = 0
      limitReachedB = FALSE

      WHILE currentHeightI < maxHeightI
       endXI = currentXI + currentHeightI
       endYI = currentYI + currentHeightI

       IF ( endXI >= doubledLongerSideI ) OR ( endYI >= doubledShorterSideI )
        IF maxHeightI > currentHeightI
         maxHeightI = currentHeightI
        ENDIF

        IF currentHeightI == 0
         stopB = TRUE
        ENDIF

        limitReachedB = TRUE
        currentHeightI = maxHeightI
       ELSE
        totalCountI = totalCountI + 1
        currentHeightI = currentHeightI + 1
       ENDIF
      ENDWHILE

      IF limitReachedB == FALSE
       currentWidthI = currentWidthI + 1
      ELSE
       IF stopB == FALSE
        currentWidthI = currentWidthI + 1
       ENDIF
      ENDIF
     ENDIF
    ENDWHILE

    parityI = parityI + 1
   ENDWHILE
   jI = jI + 1
  ENDWHILE
  iI = iI + 1
 ENDWHILE

 RETURN( totalCountI )
END

INTEGER PROC ProcSolveEuler147()
 INTEGER maxWidthI = 47
 INTEGER maxHeightI = 43
 INTEGER widthI = 0
 INTEGER heightI = 0
 INTEGER totalCountI = 0

 totalCountI = 0
 widthI = 1

 WHILE widthI <= maxWidthI
  heightI = 1
  WHILE heightI <= maxHeightI
   totalCountI = totalCountI + ProcCountUprightRectangles( widthI, heightI )
   totalCountI = totalCountI + ProcCountDiagonalRectangles( widthI, heightI )
   heightI = heightI + 1
  ENDWHILE
  widthI = widthI + 1
 ENDWHILE

 RETURN( totalCountI )
END

PROC Main()
 INTEGER answerI = 0
 STRING answerS[255] = ""

 answerI = ProcSolveEuler147()
 answerS = Format( answerI )

 CopyToWinClip( answerS )
 Warn( answerS )
END
