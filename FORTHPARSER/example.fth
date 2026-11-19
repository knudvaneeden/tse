\ FORTH interpreter sample, version 1.0.0.0.5
: SQUARE DUP * ;
: CUBE DUP DUP * * ;
: ABS DUP 0 < IF -1 * THEN ;

." Square of 5: "
5 SQUARE .
." Cube of 3: "
3 CUBE .
." Absolute value of -8: "
-8 ABS .
." 3 + 4 = "
3 4 + .
." 5 is greater than 2: "
5 2 > IF ." yes" ELSE ." no" THEN
." Remaining stack: "
.S
