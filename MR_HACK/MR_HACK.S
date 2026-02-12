/*************************************************************************
  Mr_Hack     Show value of current characters in many formats

  Author:     Robert Keith Elias,  with assistance from
               Ross Boyd
               Carlo Hogeveen

  Date:       2006/01/07

  Overview:

  This macro displays the offset and values of the current
  characters in a box in the following formats:

    Byte:          255   FF                 (Decimal Hex)
    Word:          65535 FFFF               (Decimal Hex)
    Int32:         [-]0123456789  0165ec15  (Decimal Hex)
    Binary:        11111111 11111111        (binary)

    Float:         [-]123456789.987654321
    Double:        [-]123456789.987654321
    HrMSc:         Hours:Minutes:Seconds
    Time_t:        Year-Month-Day Hours:Minutes:Seconds DayOfWeek
                   (1904-2038)
    MicroSoftDate: Year-Month-Day Hours:Minutes:Seconds DayOfWeek
                   (1904-2100)

  Keys:     (none)

  Usage notes:

  To invoke, simply load this macro.  To turn the feature off, purge
  this macro.
***********************************************************************/

/*Global variables and constants*/
CONSTANT  gcBxLeftMarg = 29, gcBxHght = 11, gcBxWdth = gcBxLeftMarg-2
INTEGER   gBxVert, gOldBxVert = -1

CONSTANT  gcOneHalf = 500000000      /* 28 significant bits */
CONSTANT  gcSecsPerDay = 86400       /* 60 * 60 * 24  */
CONSTANT  gcDaysPer4Yr = 1461        /* 4*365 + 1 leap day  */

STRING    gsNotAppl[4]   = "N/A "
STRING    gsTooBig[10]   = "Too Big   "
STRING    gsTooSmall[10] = "Too Small "
STRING    gsDays2MthNormal[54] = "xxx000 031 059 090 120 151 181 212 243 273 304 334 999"
STRING    gsDays2MthLeap[54]   = "xxx000 031 060 091 121 152 182 213 244 274 305 335 999"
STRING    gsDOWStrings[22]     = "xxFr Sa Su Mn Tu We Th"

INTEGER   gByteLngth
INTEGER   gSign32, gSign64, gInt8, gWrd16, gInt32, gDWord2

INTEGER   gDblWhole, gDbFrac

// INTEGER   gDeBg1=0,gDeBg2=0
// STRING    gsBug[20]

/**********************************************************************
 DoMSDate()
 converts doubles to dates.  The whole part is the number of
 days since Dec 31, 1899.  The fractional part contains the
 time_of_day as a fraction of the day period. (ex: 0.75 is
 18:00:00).  These dates are used internally in *.mdb and
 *.xls files and elsewhere I suppose.

 IMPORTANT: DoMSDate() uses global values from DoDouble()
 **********************************************************************/
STRING PROC DoMSDate()

  STRING  DOW[2]
  STRING  FracStrg[6]
  STRING  DateStrg[gcBxWdth-4] //26-4=22

  INTEGER WLeap, DaysSinceLeapY, YCnt, DaysSince1904, BaseYear=1904
  INTEGER DaysSinceJan1_000, IsLeap=FALSE
  INTEGER HighMthGuess, Days2MonthStart=999
  INTEGER TYears,TMnths,TDays,THrs,TMin,TSec

  // Nothing prior to 1904 or after 2100
  IF gDblWhole < gcDaysPer4Yr
     OR gDblWhole > gcDaysPer4Yr*50
     OR gByteLngth < 8
       RETURN(gsNotAppl)
  ENDIF

  // 1904 is an easier base year than 1900 (not a leap)
  DaysSince1904 = gDblWhole - gcDaysPer4Yr-1

  //Get # of days since last LeapYear
  DaysSinceLeapY = (DaysSince1904 MOD gcDaysPer4Yr)

  //Get most recent leap year number (A val less than 200)
  WLeap = (((DaysSince1904 - DaysSinceLeapY)/gcDaysPer4Yr)*4)

  //Find count of Days in this year (since Jan1) & Years since leap
  IF DaysSinceLeapY < 366
     IsLeap=TRUE
     TYears = WLeap
     DaysSinceJan1_000 = DaysSinceLeapY+1
  ELSE
     //Year 1 to 3
     YCnt = ((DaysSinceLeapY-366)/365)+1
     TYears = WLeap + YCnt
     DaysSinceJan1_000 = DaysSinceLeapY - YCnt*365
  ENDIF

  TYears = TYears + BaseYear

  //Find month and days in month
  HighMthGuess = (DaysSinceJan1_000/29)+2

  WHILE DaysSinceJan1_000 <= Days2MonthStart
    HighMthGuess = HighMthGuess-1
    IF IsLeap == TRUE
       Days2MonthStart = VAL(SUBSTR(gsDays2MthLeap, HighMthGuess*4, 3))
    ELSE
       Days2MonthStart = VAL(SUBSTR(gsDays2MthNormal, HighMthGuess*4, 3))
    ENDIF
  ENDWHILE

  TMnths = HighMthGuess
  TDays  = DaysSinceJan1_000 - Days2MonthStart

  // Multiply the double's fraction by (gcSecsPerDay/100)
  // to get the seconds in the day
  FracStrg = FORMAT(gDbFrac:09:"0")
  TSec = ((VAL(FracStrg) * 864)+5000)/10000

  THrs  =  TSec/3600
  TMin  = (TSec MOD 3600)/60
  TSec  =  TSec MOD 60

  // Get Day of Week: Jan 1 1904 was a Friday.
  DOW = SUBSTR(gsDOWStrings, ((DaysSince1904 MOD 7)+1)*3, 2)

  // Format OutPut
  DateStrg = FORMAT(TYears:04,"-",TMnths:02:"0","-",TDays:02:"0";THrs:02:"0",":",TMin:02:"0",":",TSec:02:"0";DOW:02)

  RETURN(DateStrg)
END

/**********************************************************************
 DoTime_t()
 reads the famous Unix/C time_t, which is the number of seconds since
 1970.  Note that in WindowsXP/2000 and after, many tools like
 HexWorkShop will assume that this time is GMT and give you a local time
 as the number of hours between you and Greenwich.  This code assumes
 that 0 is 1970/01/01-00:00:00.

 **********************************************************************/
STRING PROC DoTime_t()

  CONSTANT cOffsetto72   = 2*365*86400 /* First Leap Year (1972) */
  CONSTANT cSecOffsetto1904 = 17*gcDaysPer4Yr*gcSecsPerDay /* For Neg time */
  CONSTANT cDayOffsetto1904 = cSecOffsetto1904/gcSecsPerDay

  STRING  DateStrg[gcBxWdth-4] //26-4=22
  STRING  DOW[2]

  INTEGER WNumbAdjusted,YCnt
  INTEGER HighMthGuess=0, Days2MonthStart=999, DaysSinceJan1_000=0
  INTEGER DaysSinceBaseYear=0, DaysSinceLeapY=0, WLeap=0, BaseYear=1904
  INTEGER TYears,TMnths,TDays,THrs,TMin,TSec,IsLeap=FALSE

  // Overflow for dates prior to 1904
  IF gInt32 < (cOffsetto72 - cSecOffsetto1904)
     OR gByteLngth < 4
       RETURN(gsNotAppl)
  ENDIF

  //For high positive SECONDS use 1972 (Jan1) as base
  WNumbAdjusted = gInt32 - cOffsetto72

  // If 1972 SECONDS are negative then use 1904 as base
  //   because cannot easily get hours/minutes from a negative
  // _BUT_ for DAY count always use 1904 as base
  //   so that Year/month/day calcs are from a uniform offset
  IF WNumbAdjusted <= 0
    WNumbAdjusted = WNumbAdjusted + cSecOffsetto1904
    DaysSinceBaseYear = (WNumbAdjusted/gcSecsPerDay)
  ELSE
    DaysSinceBaseYear = (WNumbAdjusted/gcSecsPerDay) + cDayOffsetto1904
  ENDIF

  //Get # of days since last round time_t (Jan 1 of nearest LeapYear)
  DaysSinceLeapY = (DaysSinceBaseYear MOD gcDaysPer4Yr)

  //Get most recent leap year number (A val less than 132)
  WLeap = (((DaysSinceBaseYear - DaysSinceLeapY)/gcDaysPer4Yr)*4)

  //Find count of Days in this year (since Jan1) & Years since leap
  IF DaysSinceLeapY < 366
     IsLeap=TRUE
     TYears = WLeap
     DaysSinceJan1_000 = DaysSinceLeapY+1
  ELSE
     //Year 1 to 3
     YCnt = ((DaysSinceLeapY-366)/365)+1
     TYears = WLeap + YCnt
     DaysSinceJan1_000 = DaysSinceLeapY - YCnt*365
  ENDIF

  TYears = TYears+BaseYear

  //Find month and days in month
  HighMthGuess = (DaysSinceJan1_000/29)+2

  WHILE DaysSinceJan1_000 <= Days2MonthStart
    HighMthGuess = HighMthGuess-1

    IF IsLeap == TRUE
       Days2MonthStart = VAL(SUBSTR(gsDays2MthLeap, HighMthGuess*4, 3))
    ELSE
       Days2MonthStart = VAL(SUBSTR(gsDays2MthNormal, HighMthGuess*4, 3))
    ENDIF
  ENDWHILE

  TMnths = HighMthGuess
  TDays  = DaysSinceJan1_000 - Days2MonthStart

  // Get Hours/Minutes/Seconds
  TSec  =  WNumbAdjusted MOD gcSecsPerDay  //Seconds today
  THrs  =  TSec/3600
  TMin  = (TSec MOD 3600)/60
  TSec  =  TSec MOD 60

  // Get Day of Week: Jan 1 1904 was a Friday.
  DOW = SUBSTR(gsDOWStrings, ((DaysSinceBaseYear MOD 7)+1)*3, 2)

  // Format OutPut
  DateStrg = FORMAT(TYears:04,"-",TMnths:02:"0","-",TDays:02:"0";THrs:02:"0",":",TMin:02:"0",":",TSec:02:"0";DOW:02)

  RETURN(DateStrg)
END


/**********************************************************************
 DoDouble()
 extracts 64 bit doubles in the range 2^31 to 2^-31 (more or
 less) (If either the whole or fraction part would not fit in an
 int32 then I threw it out.)

 IMPORTANT: DoMSDate() takes global values created by DoDouble()
 **********************************************************************/
STRING PROC DoDouble()

  CONSTANT  cExp11Mask = 01111111111100000000000000000000b
  CONSTANT  cM11Mask1  = 00000000000011111111111111111111b
  CONSTANT  cM11Mask2  = 00000000000000000000001111111111b
  CONSTANT  cM11Mask3  = 00000000001111111111111111111111b

//  STRING   DoublStrg[gcBxWdth-7]

  INTEGER  FracBits=0, Fraction=0, Whole=0
  INTEGER  iCnt, exp=0, mnt1=0, mnt2=0

  IF gByteLngth < 8
     gDblWhole = 0
     gDbFrac   = 0
     RETURN(gsNotAppl)
  ENDIF

  IF (gInt32 == 0 AND gDWord2 == 0)
     gDblWhole = 0
     gDbFrac   = 0
     RETURN("0.000000000")
  ENDIF

  // Extract the exponent into an int32
  exp  = ((gDWord2 & cExp11Mask) SHR 20) - 1023

  // Extract the mantissa into two int32's
  mnt1 =  (gDWord2 & cM11Mask1) | (1 SHL 20)
  mnt1 =  (mnt1 SHL 10) | ((gInt32 SHR 22) & cM11Mask2) // 31 bits
  mnt2 =  (gInt32 & cM11Mask3) SHL 9                    // 22 others

  // Exclude values that will not fit into an int32
  IF (exp >  30)
     gDblWhole = 0
     gDbFrac   = 0
     RETURN(gsTooBig)
  ENDIF

  IF (exp < -08)
     gDblWhole = 0
     gDbFrac   = 0
     RETURN(gsTooSmall)
  ENDIF

  // Collect the whole number part
  Whole = IIF (exp < 0,0,mnt1 SHR 30-exp)

  // Collect as many of the fraction bits as possible into an int32
  IF (exp >= 0)
    FracBits = mnt1 & (MAXINT SHR exp) // knock out whole part
    FracBits = (FracBits SHL exp+1) | (mnt2 SHR 30-exp)
  ELSE
    FracBits = mnt1 SHR ABS(exp+1)     // pad the leading bits
  ENDIF

  // Convert fraction bits to a positive numerique value
  // that looks like the fractional value
  FOR iCnt = 30 DOWNTO 6
      IF (FracBits & (1 SHL iCnt)) > 0
         Fraction = Fraction + (gcOneHalf SHR 30-iCnt)
      ENDIF
  ENDFOR

  // Get the sign
  IF (gSign64) Whole = Whole*-1  ENDIF

  // Copy values to globals for use by DoMSDate()
  gDblWhole = Whole
  gDbFrac   = Fraction

  RETURN(FORMAT(Whole:09,".",Fraction:09:"0"))
END


/**********************************************************************
 DoFloat()
 extracts 32 bit floats in the range 2^31 to 2^-31 (more or
 less) (If either the whole or fraction part would not fit in an
 int32 then I threw it out.)
 **********************************************************************/
STRING PROC DoFloat()
  CONSTANT cMantMask = 00000000011111111111111111111111b
  CONSTANT cExp8Mask = 01111111100000000000000000000000b
  STRING   FloatStrg[gcBxWdth-7]
  INTEGER  iCnt,exp,mnt
  INTEGER  BaseXpn, FracBits, Fraction=0, Whole

  IF gByteLngth < 4 RETURN(gsNotAppl) ENDIF

  // If all bits 0 then we are done
  IF (gInt32 == 0) RETURN("0.000000000") ENDIF

  // Extract the exponent and the mantissa into int32's
  exp = ((gInt32 & cExp8Mask) SHR 23) - 127
  mnt =  (gInt32 & cMantMask) | (1 SHL 23)

  // Exclude values that will not fit into an int32
  IF (exp >  30) RETURN(gsTooBig)   ENDIF
  IF (exp < -08) RETURN(gsTooSmall) ENDIF

  // Collect the whole number part
  BaseXpn = 23-exp // count of bits in FracBits
  Whole = IIF((exp < 0),0,IIF(exp > 23,mnt SHL exp-23,mnt SHR BaseXpn))

  // Collect the fraction bits
  FracBits = IIF(exp < 23,mnt & (MAXINT SHR exp+8),0)

  // Convert fraction bits to a positive numerique value
  // that looks like the fractional value
  FOR iCnt = 1 TO BaseXpn
      IF (FracBits & (1 SHL iCnt-1)) > 0
         Fraction = Fraction + (gcOneHalf SHR BaseXpn-iCnt)
      ENDIF
  ENDFOR

  // Format the output
  IF (gSign32) Whole = Whole*-1  ENDIF

  FloatStrg = FORMAT(Whole:09,".",Fraction:09:"0")

  RETURN(FloatStrg)
END


/**********************************************************************
 ShowOffSet()
 displays the offset in a binary file.
 Code taken from HexOfs.s by Chris Antos
 **********************************************************************/
STRING PROC ShowOffSet()
  STRING  sOffSet[20]
  INTEGER OffSet, RghtMarg = BINARYMODE()

  IF RghtMarg >= CURRCOL()
    OffSet = ((CURRLINE()-1) * RghtMarg) + (CURRCOL()-1)
    sOffSet = FORMAT(OffSet:9,"d",STR(OffSet,16):8,"h")
  ELSE
    RETURN(gsNotAppl)
  ENDIF

  RETURN(sOffSet)
END


/**********************************************************************
 DoDayTime()
 reads the int32 as the number of seconds in the day and converts it
 to a time of day.
 **********************************************************************/
STRING PROC DoDayTime()

  STRING  TimeStrg[8] //26-4=22
  INTEGER THrs,TMin,TSec

  IF (gInt32 < 0 OR gInt32 >= gcSecsPerDay)
     OR gByteLngth < 4
       RETURN(gsNotAppl)
  ENDIF

  // Get Hours/Minutes/Seconds
  THrs  =  gInt32/3600
  TMin  = (gInt32 MOD 3600)/60
  TSec  =  gInt32 MOD 60

  // Format OutPut
  TimeStrg = FORMAT(THrs:02:"0",":",TMin:02:"0",":",TSec:02:"0")

  RETURN(TimeStrg)
END


/**********************************************************************
 Didn't need this, but kept it just in case for the future
 **********************************************************************/
/*
INTEGER PROC isLeapYear(INTEGER Year)
  return(( (Year MOD 4) AND (NOT(Year MOD 100) OR (Year MOD 400)) ))
END isLeapYear
*/


/**********************************************************************
 These are the 4 routines that output the int8/16/32 in binary
 decimal and hex formats.
 **********************************************************************/
STRING PROC Byte2Bits()
  IF gByteLngth > 1
     RETURN(INSSTR(" ",FORMAT(gWrd16:16:"0":2),9))
  ELSEIF gByteLngth == 1
     RETURN(FORMAT(gInt8:8:"0":2))
  ENDIF

  RETURN(gsNotAppl)
END

STRING PROC ShowInt8()
  IF gByteLngth < 1 RETURN(gsNotAppl) ENDIF
  RETURN(FORMAT(gInt8:08,"d";STR(gInt8,16):07,"h"))
END

STRING PROC ShowWrd16()
  IF gByteLngth < 2 RETURN(gsNotAppl) ENDIF
  RETURN(FORMAT(gWrd16:08;STR(gWrd16,16):08))
END

STRING PROC ShowInt32()
  IF gByteLngth < 4 RETURN(gsNotAppl) ENDIF
  RETURN(FORMAT(gInt32:11;STR(gInt32,16):08))
END

/**********************************************************************
 MakeGlobalNumbers()
 extracts the int8/16/32/64 values (at the current cursor
 position) into global variables for use by other routines.
 **********************************************************************/
PROC MakeGlobalNumbers(STRING Bytes_8)

  INTEGER iCnt

  gByteLngth = LENGTH(Bytes_8)
  IF gByteLngth < 1 RETURN() ENDIF

  IF gByteLngth == 8
    gSign64 = ASC(Bytes_8[8]) SHR 7
    FOR iCnt = gByteLngth DOWNTO 5
        gDWord2 = (gDWord2 SHL 8) | ASC(Bytes_8[iCnt])
    ENDFOR
  ELSE
    gDWord2 = 0
    gSign64 = 0
  ENDIF

  gInt8 = ASC(Bytes_8[1])
  IF gByteLngth >= 2
      gWrd16 = (ASC(Bytes_8[2]) SHL 8) | gInt8
  ENDIF

  IF gByteLngth >= 4
      gSign32 = ASC(Bytes_8[4]) SHR 7
      gInt32 = (ASC(Bytes_8[3]) SHL 16) | gWrd16
      gInt32 = (ASC(Bytes_8[4]) SHL 24) | gInt32
  ENDIF

END

/**********************************************************************
 PopDialogHelper() and PopDialog()
 where written by Ross Boyd.  I know NOTHING.
 **********************************************************************/
PROC PopDialogHelper()
  INTEGER ScrnVert = QUERY(ScreenRows)
  gBxVert = IIF(WHEREYABS() < ScrnVert-16, MAX(12,ScrnVert-(gcBxHght+3)),3)
  IF gBxVert <> gOldBxVert
    // Force erasure of previous dialog if it moves
    UPDATEDISPLAYFLAGS(_ALL_WINDOWS_REFRESH_)
    gOldBxVert = gBxVert
  ENDIF
END

/**********************************************************************
 PopDialog()
 Call the routines and update the screen.
 **********************************************************************/
PROC PopDialog()
  INTEGER  oldattr
  INTEGER  BxHorz

  oldattr = SET(Attr,31)

  BxHorz = MAX(2,QUERY(ScreenCols) - gcBxLeftMarg)

  WINDOW(BxHorz,gBxVert,BxHorz+gcBxWdth+1,gBxVert+gcBxHght+1)
  DRAWBOX(1,QUERY(Attr))
  WINDOW(BxHorz+1,gBxVert+1,BxHorz+gcBxWdth,gBxVert+gcBxHght)
  CLRSCR()

  MakeGlobalNumbers(GETTEXT(CURRPOS(),8))

  PUTSTRXY(01,gcBxHght-10,FORMAT("OffSt:"; ShowOffSet():20))
  PUTSTRXY(01,gcBxHght- 8,FORMAT("Byte :"; ShowInt8()  :20))
  PUTSTRXY(01,gcBxHght- 7,FORMAT("Wrd16:"; ShowWrd16() :20))
  PUTSTRXY(01,gcBxHght- 6,FORMAT("Int32:"; ShowInt32() :20))
  PUTSTRXY(01,gcBxHght- 5,FORMAT("Bits :"; Byte2Bits() :20))

  PUTSTRXY(01,gcBxHght- 4,FORMAT("Float:"; DoFloat()   :20))
  PUTSTRXY(01,gcBxHght- 3,FORMAT("Doubl:"; DoDouble()  :20))
  PUTSTRXY(01,gcBxHght- 2,FORMAT("HrMSc:"; DoDayTime() :20))
  PUTSTRXY(01,gcBxHght- 1,FORMAT("T_t:"  ; DoTime_t()  :22))
  PUTSTRXY(01,gcBxHght   ,FORMAT("MSD:"  ; DoMSDate()  :22))

// PUTSTRXY(01,gcBxHght- 2,FORMAT("Bug:"; gDeBg1:10; gDeBg2:10))
// PUTSTRXY(01,gcBxHght- 1,FORMAT("BgS:"; gsBug:21))

  FULLWINDOW()

  SET(attr,oldattr)
END

PROC WHENLOADED()
    HOOK(_PRE_UPDATE_ALL_WINDOWS_,  PopDialogHelper)
    HOOK(_POST_UPDATE_ALL_WINDOWS_, PopDialog)
//    HOOK(_AFTER_UPDATE_STATUSLINE_, PopDialog)
END
