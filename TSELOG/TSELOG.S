/* These additions to TSE.S cause the editor to maintain a log file,
   called C:\E.LOG in this version, which contains a single line for
   each file loaded for editing. The single line contains, for example:

   Saturday, 19 June 1993 @ 19:49:38__d:\temp\tselog.txt

   the elements of which are self-evident.

   Add the procedure below to TSE.S prior to proc Main(), add the single
   line at the end to proc Main() and compile/burn-in TSE.S to your
   version of E.EXE. (SC -B UI\TSE if you have the conventiuonal
   directories in use.)

*/


/************************************************************************
   Procedure LogIt, version 1.0, Sunday, 6 June 1993.

   This procedure writes the current day of the week, the date and the
   time into a file called E.LOG in the root directory of drive C,
   whenever a file is first edited.
**************************************************************************/

Proc LogIt()

     string Dow   [17] = "Day of week error",
            Mon   [11] = "Month error",
            CurFN [70] = ""

     integer M, D, Y, W

     GetDate(M, D, Y, W)

     case W

          when 1 Dow="Sunday"
          when 2 Dow="Monday"
          when 3 Dow="Tuesday"
          when 4 Dow="Wednesday"
          when 5 Dow="Thursday"
          when 6 Dow="Friday"
          when 7 Dow="Saturday"

     endcase

     case M

          when  1 Mon=" January "
          when  2 Mon=" February "
          when  3 Mon=" March "
          when  4 Mon=" April "
          when  5 Mon=" May "
          when  6 Mon=" June "
          when  7 Mon=" July "
          when  8 Mon=" August "
          when  9 Mon=" September "
          when 10 Mon=" October "
          when 11 Mon=" November "
          when 12 Mon=" December "

     endcase
     CurFN = CurrFilename()
     EditFile("c:\e.log")
     EndFile()
     BegLine()
     AddLine((Format(Dow, ", ", D, Mon, Y, " @ ", GetTimeStr(), "__",
                                           CurFN)))
     SaveAndQuitFile()
     EditFile(CurFN)

end LogIt


/***************************************************************************
 Add the following line to proc Main() in TSE.S. Note: proc Main() as
 supplied is empty.
 ***************************************************************************/
proc main()
     hook(_on_first_edit_, LogIt)   // Log to file C:\E.LOG on 1st edit
end
