/******************************************************************************/
/* Macro      : DTMENU.S                                                      */
/* Programmer : Todd Fiske                                                    */
/*                                                                            */
/* Purpose    : Provide a menu for inserting a variety of date & time formats */
/*                                                                            */
/* Revision   : 10/04/1994 - first version                                    */
/* History                                                                    */
/*                                                                            */
/* Language   : SAL 1.0 (Pre-Release)                                         */
/*                                                                            */
/******************************************************************************/

/* ----------------------------------------------------------------------------

 This macro package contains these primary routines

    string proc DSTString(integer iMon, integer iDay, integer iDow)
    string proc DTFormat(string FormatString)
    proc DTUserDefined()
    menu DTMenu()

    <CtrlAlt D> DTMenu()

 -----------------------------------------------------------------------------

 I wrote this in response to a request I saw for a multi-format date menu. It
 started out simple, then I got carried away! =) I figured that instead of
 hardcoding a bunch of date formats like this:

    proc tfDate()
       integer iMonth, iDay, iYear, iDow
       GetDate(iMonth, iDay, iYear, iDow)
       InsertText(Format(iMonth:2:'0', '/', iDay :2:'0', '/', iYear :4, ' ' ))
    end

 that it would be more flexible to create a routine that could return *any*
 format based on an input format pattern, sort of like how WordPerfect defines
 its datecodes. The above method is faster, but there has to be one such
 routine per format desired, and changes need to be made in the source code and
 recompiled. The routine DTFormat() below takes a format string as input, and
 as such can handle different formats specified at runtime. Further, it could
 take strings read from a file and convert those into the desired formats.

 You'll find that the menu is a bit slow to draw (ie, you can see it draw
 rather than just pop up), since it actually converts each example as it opens.
 In practice, you might prefer to isolate two or three specific date formats
 and bind them to their own keys, and only use the menu when you want to
 experiment with other formats (using the User Defined option). For example:

    <ShiftAlt D>   DTFormat("p/l/t")   // normal date : 10/04/1994
    <ShiftAlt T>   DTFormat("c:f:h")   // normal time : 19:02:52
    <ShiftAlt C>   DTFormat("l-s-v")   // CIS date    : 04-Oct-94
    <ShiftAlt Y>   DTFormat("tpl")     // CYMD format : 19941004

 One last note, I sort of guessed at the TSE Jr. date format below. If anyone can
 tell me what the correct format is, I'll fix it.

 ---------------------------------------------------------------------------- */

/******************************************************************************/
/* DST String - return current timezone string - modify for your locality     */
/******************************************************************************/
string
   Standard[3] = "EST",
   Daylight[3] = "EDT"

string proc DSTString(integer iMon, integer iDay, integer iDow)
   integer isDST
   string  sWork[3] = ""

   // if on or after 1st Sunday of April and before last Sunday of October
   // then EDT, else EST

   if iMon == 4 // April
      // count backwards
      // if we hit a Sunday before coming to the beginning of the month
      // then EDT, else EST

      while (iDay > 0) and (iDow > 1)
         iDay = iDay - 1
         iDow = iDow - 1
      endwhile
      isDST = (iDow == 1)

   else
      if iMon == 10 // October
         // count forwards
         // if we hit a Sunday before coming to the end of the month
         // then EDT, else EST

         while (iDay < 32) and (iDow < 8)
            iDay = iDay + 1
            iDow = iDow + 1
         endwhile
         isDST = (iDow == 8)

      else // if between May and September inclusive, its daylight savings time
         isDST = (iMon >= 5) and (iMon <= 9)
      endif
   endif

   if isDST
      sWork = DayLight
   else
      sWork = Standard
   endif
   return(sWork)
end

/******************************************************************************/
/* DT Format - return a formatted date and time string                        */
/******************************************************************************/
string
   FullDays[]   = "Sunday    Monday    Tuesday   Wednesday Thursday  Friday    Saturday  ",
   FullMonths[] = "January   February  March     April     May       June      July      August    September October   November  December ",
   //              123456789-123456789-123456789-123456789-123456789-123456789-123456789-123456789-123456789-123456789-123456789-123456789-
   //                       1         2         3         4         5         6         7         8         9        10        11

   AbbrDays[]   = "Sun Mon Tue Wed Thu Fri Sat ",
   AbbrMonths[] = "Jan Feb Mar Apr May Jun Jul Aug Sep Oct Nov Dec "
   //              123456789-123456789-123456789-123456789-12345678
   //                       1         2         3         4

string proc DTFormat(string FormatString)
   integer
      iHours, iMins, iSecs, iHuns, iMonth, iDay,  iYear, iDow, iPos, iWork

   // initialize dtString, return value
   string
      dtString[255] = ""

   // get local time and date vars
   GetTime(iHours, iMins, iSecs, iHuns)
   GetDate(iMonth, iDay,  iYear, iDow)

   iPos = 1
   while (iPos <= length(FormatString)) // for each character in input string
      case lower(FormatString[iPos])
         // ---------- Hour formats
         when "a" //                                       12 0 pad
            iWork = iHours
            if iWork == 0
               iWork = 12
            elseif iWork > 12
               iWork = iWork - 12
            endif // else iWork okay as is, 1..12
            dtString = dtString + format(iWork:2:"0")
         when "b" //                                       12 no pad
            iWork = iHours
            if iWork == 0
               iWork = 12
            elseif iWork > 12
               iWork = iWork - 12
            endif // else iWork okay as is, 1..12
            dtString = dtString + trim(format(iWork:2))

         when "c" //                                       24 0 pad
            dtString = dtString + format(iHours:2:"0")
         when "d" //                                       24 no pad
            dtString = dtString + trim(format(iHours:2))

         when "e" //                                       am/pm
            dtString = dtString + iif(iHours >= 12, "pm", "am")

         // ---------- Minute formats
         when "f" //                                       0 pad
            dtString = dtString + format(iMins:2:"0")
         when "g" //                                       no pad
            dtString = dtString + trim(format(iMins:2))

         // ---------- Second formats
         when "h" //                                       0 pad
            dtString = dtString + format(iSecs:2:"0")
         when "i" //                                       no pad
            dtString = dtString + trim(format(iSecs:2))

         // ---------- Hundredth formats
         when "j" //                                       0 pad
            dtString = dtString + format(iHuns:2:"0")
         when "k" //                                       no pad
            dtString = dtString + trim(format(iHuns:2))

         // ---------- Day formats
         when "l" //                                       number 0 pad
            dtString = dtString + format(iDay:2:"0")
         when "m" //                                       number no pad
            dtString = dtString + trim(format(iDay:2))
         when "n" //                                       full name
            iWork = iDow * 10 - 9 // 1 * 10 - 9 = 1, 7 * 10 = 70 - 9 = 61
            dtString = dtString + trim(substr(FullDays, iWork, 9))
         when "o" //                                       abbrev
            iWork = iDow *  4 - 3 // 1 *  4 - 3 = 1, 7 *  4 = 28 - 3 = 25
            dtString = dtString + trim(substr(AbbrDays, iWork, 3))

         // ---------- Month formats
         when "p" //                                       number 0 pad
            dtString = dtString + format(iMonth:2:"0")
         when "q" //                                       number no pad
            dtString = dtString + trim(format(iMonth:2))
         when "r" //                                       full name
            iWork = iMonth * 10 - 9 // 1 * 10 - 9 = 1, 12 * 10 = 120 - 9 = 111
            dtString = dtString + trim(substr(FullMonths, iWork, 9))
         when "s" //                                       abbrev
            iWork = iMonth *  4 - 3 // 1 *  4 - 3 = 1, 12 *  4 = 48 - 3 = 45
            dtString = dtString + trim(substr(AbbrMonths, iWork, 3))

         // ---------- Year formats
         when "t" //                                       with century
            dtString = dtString + format(iYear:4)
         when "u" //                                       century only
            iWork = iYear / 100
            dtString = dtString + format(iWork:2)
         when "v" //                                       decade 0 pad
            iWork = iYear mod 100
            dtString = dtString + format(iWork:2:"0")
         when "w" //                                       decade no pad
            iWork = iYear mod 100
            dtString = dtString + trim(format(iWork:2))

         // ---------- Time zone
         when "x" //
            dtString = dtString + DSTString(iMonth, iDay, iDow)

         // ---------- Copy other puctuation and formatting as-is
         otherwise
            dtString = dtString + FormatString[iPos]

      endcase

      iPos = iPos + 1 //               point to next character
   endwhile

   return(DTString)
end

/******************************************************************************/
/* DT User Defined - a semi-TTY experimenting environment                     */
/******************************************************************************/
string
   UserDefined[80] = "n r m t, b:ge"  // Dayname Monthname 9 9999, 9:99pm

proc DTUserDefined()
   integer
      lRunning  = TRUE,
      lInsert   = FALSE,
      lDumpStr  = FALSE,
      iKey

   ClrScr()

   WriteLine("User-Defined Date/Time Format String Work-Area")
   WriteLine("")
   WriteLine("String : >", UserDefined, "<")
   WriteLine("Result : >", DTFormat(UserDefined), "<")
   WriteLine("")
   WriteLine("<Space> edit   <Enter>      accept, insert date      <Escape> exit")
   WriteLine("<F1>    help   <Ctrl Enter> accept, insert pattern")
   WriteLine("")

   while lRunning
      iKey = GetKey()
      case iKey
         when <F1> //                  help screen
            WriteLine("  ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿  ")
            WriteLine("  ³ a hour    12 0 pad  ³ l day     number 0 pad  ³ x timezone               ³  ")
            WriteLine("  ³ b         12 no pad ³ m         number no pad ³                          ³  ")
            WriteLine("  ³ c         24 0 pad  ³ n         full name     ³ `p/l/t ' = `10/04/1994 ' ³  ")
            WriteLine("  ³ d         24 no pad ³ o         abbrev        ³ `c:f:h ' = `17:41:41 '   ³  ")
            WriteLine("  ³ e         am/pm     ³                         ³                          ³  ")
            WriteLine("  ³                     ³ p month   number 0 pad  ³ Other punctuation and    ³  ")
            WriteLine("  ³ f minute  0 pad     ³ q         number no pad ³ formatting are copied    ³  ")
            WriteLine("  ³ g         no pad    ³ r         full name     ³ as is.                   ³  ")
            WriteLine("  ³                     ³ s         abbrev        ³                          ³  ")
            WriteLine("  ³ h second  0 pad     ³                         ³                          ³  ")
            WriteLine("  ³ i         no pad    ³ t year    with century  ³                          ³  ")
            WriteLine("  ³                     ³ u         century only  ³                          ³  ")
            WriteLine("  ³ j 100ths  0 pad     ³ v         decade 0 pad  ³                          ³  ")
            WriteLine("  ³ k         no pad    ³ w         decade no pad ³                          ³  ")
            WriteLine("  ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ  ")
            WriteLine("")
            WriteLine("<Space> edit   <Enter>      accept, insert date      <Escape> exit")
            WriteLine("<F1>    help   <Ctrl Enter> accept, insert pattern")
            WriteLine("")

         when <Ctrl Enter> //          dump format string at cursor pos
            lRunning = False
            lInsert  = TRUE
            lDumpStr = TRUE

         when <Enter> //               insert date string at cursor pos
            lRunning = FALSE
            lInsert  = TRUE

         when <Escape> //              exit without inserting any text
            lRunning = FALSE

         when <SpaceBar>
            if Read(UserDefined) //    edit format string
               WriteLine("")
               WriteLine("String : >", UserDefined, "<")
               WriteLine("Result : >", DTFormat(UserDefined), "<")
               WriteLine("")
            else //                    escaped from read
               WriteLine("") //        provide some visual feedback
               WriteLine("")
            endif
      endcase
   endwhile

   UpdateDisplay(_WINDOW_REFRESH_ | _STATUSLINE_REFRESH_)
   if lInsert
      if lDumpStr
         InsertText(UserDefined) //              insert format string
      else
         InsertText(DTFormat(UserDefined)) //    insert translated string
      endif
   endif
end

/******************************************************************************/
/* DT Menu                                                                    */
/******************************************************************************/
menu DTMenu()
   title = "Date/Time Menu"

   "&1 Date"             [DTFormat("q/l/t")           :35] , InsertText(DTFormat("q/l/t"))
   "&2 Time"             [DTFormat("c:f:h")           :35] , InsertText(DTFormat("n q/l/v"))
   "&2 Day Date (TSE Jr.)" [DTFormat("n q/l/v")         :35] , InsertText(DTFormat("n q/l/v"))
   "&3 Date Time"        [DTFormat("q/l/v c:f")       :35] , InsertText(DTFormat("q/l/v c:f"))
   "&4 Day Date Time"    [DTFormat("n q/l/v c:f:h")   :35] , InsertText(DTFormat("n q/l/v c:f:h"))
   "&5 CIS"              [DTFormat("l-s-v")           :35] , InsertText(DTFormat("l-s-v"))
   "&6 Unix"             [DTFormat("o, m s t c:f:h x"):35] , InsertText(DTFormat("o, m s t c:f:h x"))
   "&7 User-defined"     [DTFormat(UserDefined)       :35] , DTUserDefined()
end //                   ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
//                       These examples cause the menu to
//                       draw visibly. I think its worth
//                       it, but you can remove them to
//                       speed it up a little.

<CtrlAlt D> DTMenu()

/******************************************************************************/
/* EOF : DTMENU.S                                                             */
/******************************************************************************/

