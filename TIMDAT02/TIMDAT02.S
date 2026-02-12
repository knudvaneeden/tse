//*************************************************************************
/************************  Start Comment Area *****************************

                     TSE 1.00a  September 21, 1993
                     ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
                     ³file:  timdat02.s  08/11/93 ³
                     ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

//*************************************************************************
orig file:  timedate.s by TAK derived from date() from SemWare and Mel Hulse.
//*************************************************************************

  TSE macros:  time(), date(), timedate(), fulldate(), timezone()
               fulltimedate(), time_ampm()

//*************************************************************************

All of the above macros are within this one source file and are  written
as PUBLIC macros.  Compile and then load this macro and then press CTRL-
X, RETURN to view the list of PUBLIC macros. PUBLIC macros can be a very
useful addition to TSE and I don't see many people using them.

This  TSE  macro  source  is  released to  the  public  domain  and  was
originally meant as an aid to me (i.e. \\\...tak) in developing some
expertise with the TSE macro language.  You are welcome to change it for
your own use. Have fun !!

//*************************************************************************
//      CHANGE/REVISION area in reverse order(i.e. last is first)
//*************************************************************************

  09/21/93:  Minor changes like adding 'hrs' timedate

  08/11/93:  General clean up of notes, remove sig3() #include, renamed
             file to timdat02.s for revision control, added notes and
             SETS for 12-hour or 24-hour TimeFormat.

  05/14/93:  Change 24-Hour to no colons i.e. 1800 not 18:00,  added proc
             fulltimedate() to include the time & date in one call,
             #included sig3()

  04/24/93:  Added procedure time_ampm() for 12-hour format

  04/16/93:  File:  timedate.s, timedate.zip uploaded to SemWare

  04-19-93:  TAK - added note under ASSUMPTIOMS about 12/24 time formats
  04-15-93:  TAK - expanded from fulldate only to 5 functions of time/date

All Changes above by:  Tom Klein, TAKnet Information Service; Fort Wayne, IN

  03-09-93: KAC - Rewritten, commented, and tested.
  02-14-93: Submitted by Mel Hulse

         ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
         ³Macros that InsertText in various timedate formats.³
         ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
                 time() = 1822
                 date() = 04/16/93
                 timedate() = 04/16/93  1822 hrs.
                 fulldate() = Friday - April 16, 1993
                 fulltimedate() = Friday - April 16, 1993 at 1822 hrs.
                 timezone() = 18:23 EST/CDT
                 time_ampm() = 3:15 pm

//*************************************************************************
//*************************************************************************

 ASSUMPTIONS:  The  cursor  should  be in the file where  you  wish  the
               function  to  begin.  The current insert mode  will  be
               used. ( i.e.  if currently in overwrite mode, the date
               will overwrite, otherwise the date will be inserted)

TimeFormat  (i.e.  12-hour or 24-hour)  can be set by adding one of  the
following lines to procedure that you wish to change. I use 4DOS and its
24-hour  format  so  it is not possible for me  to  easily  check  other
formats.  The  SETs below are correct and the 12-hour SET is used in the
'time_ampm()' procedure included in this file.

    Set(TimeFormat, 1)    //  (15:03:48) 24-hour
    Set(TimeFormat, 2)    //  ( 3:03:48) 12-hour

All of the macros included within this source file are PUBLIC macros and
as  such  are NOT bound to a key but are executed by name  or  selection
from  the  pull  down  PUBLIC macro list obtained  by  CTRL-X  and  then
pressing  RETURN to obtain the list of loaded macros.  If you  know  the
name of the public macro then CTRL-X <enter name in box>

e.g.  CTRL-X  fulltimedate,  will put the 'fulltimedate' at  the  cursor
      location. (Wednesday -  August 11, 1993 at 1953 hrs.)

e.g2. If you use the PUBLIC macro listing then you will see a list
      with the macro name that was loaded and underneath will be a
      listing of all of the macros.  You can select any one of the
      macros by moving the cursor or at the 'Execute macro:' box you
      could enter any one of the PUBLIC macro names.

  *************************************************************************/
//tak******************* END of Comment Area ******************************

//START

//   Set(DateSeparator, "-")  //  syntax error
//   Set(TimeFormat, 1)       //  (15:03:48) 24-hour
//   Set(TimeFormat, 2)       //  ( 3:03:48) 12-hour

       PUBLIC proc  FullDate()

           integer mon, day, year, dow
           string  month_name[9] = ''
           string  day_of_week[9]= ''

           GetDate(mon, day, year, dow)    // get current date

           case mon
               when  1 month_name = 'January'
               when  2 month_name = 'February'
               when  3 month_name = 'March'
               when  4 month_name = 'April'
               when  5 month_name = 'May'
               when  6 month_name = 'June'
               when  7 month_name = 'July'
               when  8 month_name = 'August'
               when  9 month_name = 'September'
               when 10 month_name = 'October'
               when 11 month_name = 'November'
               when 12 month_name = 'December'
           endcase

           case dow
               when  1 day_of_week = 'Sunday'
               when  2 day_of_week = 'Monday'
               when  3 day_of_week = 'Tuesday'
               when  4 day_of_week = 'Wednesday'
               when  5 day_of_week = 'Thursday'
               when  6 day_of_week = 'Friday'
               when  7 day_of_week = 'Saturday'
           endcase


    InsertText(Format(Day_of_Week,' -  ',Month_name,' ',day,', ',year))


end  // End of FullDate()

/************************************************************************/

PUBLIC proc  Time()

    string  time [5]
    time=GetTimeStr()
    time=substr(time,1,2)+substr(time,4,5)
    InsertText(time)

end  // time()

/**************************************************************************
Macro:  time_ampm()
Complete File:   a:\date2.s
Time only File:  a:\timeampm.s  4-24-93

Date: 04-22-93 (23:42)  From: MEL HULSE and Tom Klein Stripped Time()
                              and changed it from STRING proc to Public
                              by removing the SET commands and also
                              stripping leading zeroes from times less
                              than 10.

---------------------------------------------------------------------------
  This  procedure  sets the time format for the 12-hour  mode  for  4DOS
users that usually use the 24-hour format within 4DOS.
                                          ÚÄÄÄÄÄÄÄ¿
                      Time format will be ³7:41 pm³
                                          ÀÄÄÄÄÄÄÄÙ
**************************************************************************/

//*************************************************************************
//*************************************************************************

PUBLIC PROC Time_ampm()

    String  Time[8]
    Integer ITime=0

    Set(TimeFormat, 2)
    Time = GetTimeStr()

//  Below strips the leading zero for times less 10 am or pm

    ITime=val(substr(time,1,2))

      If ITime < 10
         time=substr(time,2,9)
      endif

//  MUST reset the format with the line below or times are incorrect.

    Set(TimeFormat, 1)          // Return to 24-hour default

    InsertText(time)

end  // time_ampm()

/************************************************************************/

PUBLIC proc  TimeZone()

    string  timezone[20]
    timezone=GetTimeStr()
    timezone=(Format (substr(timezone,1,5),' EST/CDT'))
    InsertText(timezone)

end  // timezone()

/************************************************************************/

PUBLIC proc  Date()

    string  date[10]
    date=GetDateStr()
    InsertText(date)

end  // date()

/************************************************************************/

PUBLIC proc  TimeDate()

      date()
      InsertText('  ')
      time()
      InsertText(' hrs.')

end  //  Timedate()

/************************************************************************/

PUBLIC proc FullTimeDate()

       FullDate()
       InsertText(' at ')
       time()
       InsertText(' hrs.')

end  // FullTimeDate()

/************************************************************************/
//                     ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//                     ³file:  timdat02.s  08/11/93 ³
//                     ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
/************************************************************************/

