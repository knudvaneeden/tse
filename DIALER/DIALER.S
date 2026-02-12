/****************************************************************************

           DIALER    Ver 1.1

           Aim and shoot telephone dialer.       Bob Fehrenbach

  Key Bindings:
           control shift z:  dial the number under the cursor
           alt shift z:      load a text file with your directory

   Description:

   This is a simple phone dialer without bells and whistles.  Place the
   cursor on a number and press the hot keys to dial the number. The
   cursor may be placed anywhere in the number.  If the number has seven
   digits or fewer, the number is dialed directly.  If the number has
   greater than seven digits, the program checks to see if it is preceeded
   by a "1".  If not, the "1" is added.  The number may contain embedded
   dashes which are ignored. If an invalid number is encountered, the
   program complains.   The program requires that a modem be installed.


   Installation:

   Copy dialer.s to your tse\mac directory.  You may want to edit some
   of the built in defaults at this time.

   The default com port is com2.  If your modem is on a different com
   port, edit the two dos() lines.

   If you are calling from a system which requires dialing a prefix for
   an outside line, the program makes provision for inserting a prefix.
   Comment out the prefix line if it is not needed.

   Conventional modem dialing and hang-up commands are used.  If you
   have an unusual modem, changes in these commands may be required.

   I keep all my phone numbers, addresses and various other miscellany
   in a text file, "phones.txt".  The program is currently set up to
   load this file by pressing alt shift z.  If your file has a different
   name, edit the "EditFile ()" line near the end of the program.

   After making the necessary changes, compile the file and add it to
   your autoload list.

   For comments or questions, I can be reached at:

   Internet:  bfehrenb@execpc.com
   Fidonet: 1:154/280

   I also occasionally read the tsepro mail list as well as the Fidonet
   TSE Jr. echo.

****************************************************************************/



   proc Dial()

   string phone_num [30]= ""              //Initialize number
   string this_num[1] = ""
   integer digit_count = 0                 //Initialize count
   integer error = 0


   while ((CurrCol() <> 1) and (not isWhite()))  //Find start of number
    left()
   endwhile
    if isWhite()       //If number is not at beginning of line,
    right()            //move to first digit
    endif

   while (not isWhite()) and (CurrChar() <> _AT_EOL_)    //Get the number

          while (Chr(CurrChar()) == "-")     //Skip over dashes
          right()
          endwhile

    this_num = Chr(CurrChar())

           if  ( this_num >= "0" and this_num <= "9")
           phone_num =  phone_num + this_num   //Assemble phone number
           digit_count = digit_count + 1       //Count digits
           else
           error = 1      //Non-numeric character encountered
           endif
    right()            //Go to next character and loop through again.

   endwhile

   if error == 1
    Message ("Not a valid phone number")
    return()           //Bail out if not valid
   endif
                       //Now check the number of digits.
                       //If this is a long distance number, make
                       //sure first digit is a "1"

   if (digit_count > 7) and (phone_num[1] <> "1")
    phone_num = "1" + phone_num
   endif

//   phone_num = "9," + phone_num    //Dialing prefix, if required.
                                     //Comment out if not needed.

                                     //Dial the number
   Dos ("echo ATDT" + phone_num + ">com2", _DONT_CLEAR_)

   Message ("Pick up receiver and press any key after number dials")
   getkey()                        //Wait for key press

   Dos ("echo ATH >com2", _DONT_CLEAR_)    //Hang up modem
   UpdateDisplay(_STATUSLINE_REFRESH_)     //Clean up display

end

   proc Load_Directory()                   //Load your phone book
    EditFile ("c:\docs\phones.txt")        //Edit path\filename for
end                                       // your system.

<ctrlshift z>    Dial()
<altshift z>     Load_Directory()
