/*---------------------------------------------------------------------*/
/*   Quote, v.1.1, October 22, 1994

Places a quote line at the begining of a BBS network message.

This macro was adapted by Mel Hulse based on a macro by Richard
Blackburn, SemWare Technical Support.

Because the names and subject can each be 25 characters long, It
is possible that the quote line could exceed 80 characters.  If
your name is very long, you may want to disable showing the
subject.

Sample header:

===========================================================================
 BBS: SEMWARE
Date: 10-11-91 (18:39)             Number: 305  COMPEASE
From: FROM NAME                    Refer#: 281
  To: TO NAME                       Recvd: YES
Subj: Standard Quote Macro           Conf: (15) RoadRNR
---------------------------------------------------------------------------

The intro quote line will look like:

On Wed. the 10th FROM NAME wrote TO NAME about "Standard Quote Macro":

This macro can be made to operate automagically by adding the
following within the OnFirstEdit() proc in your TSE.UI at the end
and deleting the key binding at the end of this file.

PROC OnFirstEdit()                  // add if not there

    If SplitPath(CurrFileName(), _NAME_|_EXT_) == "reply.msg" //lower case req'd
        PushPosition()              // save our cursor position
        Down()                      // go to second line of file
        If GetText(1,3) == "On "    // check to see if quote line already there
            Return()                // if so, quit
        Else                        // otherwise
            LoadMacro("Quote")      // get the macro
            ExecMacro("Quote")      // and execute it
        EndIf
        PopPosition()               // restore the cursor
    EndIf
End

#INCLUDE this file in your TSE.UI immediately following the
keybindings.

*/

/*  Day of the week macro using Zeller's Congruence.
    By Mel Hulse, April 10, 1993
*/

String PROC DayOfWeek(Integer Month, Integer Day, Integer Year)
    Integer DOW, Y1, Y2

    If Month < 3
        Month = Month + 10
        Year = Year - 1
    Else
        Month = Month - 2
    EndIf

    Y1 = (Year * 10) / 1000
    Y2 = Year Mod 100

    DOW =  1+((Day+(26*Month-1)/10)+Y2+(Y2/4)+(Y1/4)-(2*Y1)+49) Mod 7

    Case DOW mod 7
        When 1    Return("Sun.")
        When 2    Return("Mon.")
        When 3    Return("Tue.")
        When 4    Return("Wed.")
        When 5    Return("Thu.")
        When 6    Return("Fri.")
        Otherwise Return("Sat.")
    EndCase
    Return("Fake It Out!")
END


String Proc FormatDate(String Date)
/*
Convert the message MM-DD-YY date into quote format "Wednesday the 10th"
*/
    String  Suffix[2] = ""              // st, nd, rd, th

    Integer Day,
            Month,
            Year

    Month = Val(SubStr(Date,1,2))       // convert date components to integer
    Day   = Val(SubStr(Date,4,2))
    Year  = Val(SubStr(Date,7,2))

    If Year <= 90                       // expand 2-digit year
        Year = Year + 2000
    Else
        Year = Year + 1900
    EndIf

    Case Day
        When  1 Suffix = "st"
        When  2 Suffix = "nd"
        When  3 Suffix = "rd"
        When 21 Suffix = "st"
        When 22 Suffix = "nd"
        When 23 Suffix = "rd"
        When 31 Suffix = "st"
    Otherwise
               Suffix = "th"
    EndCase

    // return the date string to calling function
    // include call to StrDayOfWeek function
    Return(DayOfWeek(Month, Day, Year) + " the " + Str(Day) + suffix)
End FormatDate

PROC Quote()

string  From[25]     = "",          //  who the message is from
        To[25]       = "",          //  who the message is to
        Date[8]      = "",          //  from header
        Subject[25]  = ""           //  from header


// Get the header info or quit, if no a header in the file.
    BegFile()                       // goto begining of the file
    if (GetText(2, 2) <> "==" )     // if no equal signs assume no header
        PopPosition()
        Return()                    // no header, quit
    else
        lFind("Date:","^")          // move to date line
        Date = GetText(7, 14)       // get date field
        lFind("From:","^")          // move to "From:" line
        From = GetText( 7, 28 )     // get "from" field
        lFind("  To:","^")          // move to "To:" line
        To = GetText( 7, 28 )       // get "to" field
        lFind("Subj:","^")          // move to "Subj:" field
        Subject = GetText( 7, 28 )  // get "subject" field
        BegFile()                   // goto start of file
        DelLine( 7 )                // delete the header
        CReturn()                   // leave an empty line at the top
// Insert quote line in the message
        InsertLine('On ' + FormatDate(Date) +
                ' ' + RTrim(From) +
                ' wrote ' + RTrim(To) +
                ' about "' + RTrim(subject) +
                '"')
        Down(2)
    EndIf
END


<key>           Quote()             // don't use this if using OnFirstEdit()
