/****************************************************************************
               Delete "Blank Lines" from the Current File
 ****************************************************************************/

/****************************************************************************
     I use the following macro's when editing large ascii files that
     I have moved from my Unix system to one of my Dos systems. These
     are usually reports that have been printed to disk, but now are
     going to be used in a different way, or just a portion of them
     needs to be included, so I often want to delete the blank spaces
     that were originally in the report. I do not assign them to any
     keystrokes, as I feel they are just a little to powerful for that.
     As I was looking at them to add comments I realized I could improve
     things here and there, and even combine them intro a single procedure,
     but one of my daughters just asked me to come out and play catch, so...

                                                mr jiggs
                                                director of computer services
                                               (Systems Overlord)
                                                FOTOBEAM/Brookside, Inc.
                                                260 Lexington Street
                                                Waltham, MA 02254
                                                Phone (617) 893-1600
                                                  Fax (617) 893-9951
                                                  BBS (617) 893-6812

 ****************************************************************************/

/*
   -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

     The following procedure displays a "Progress Bar" as a "Message" along
     the status line you have defined for messages, using the color scheme
     you have chosen.  It is called by the three variations of the "Purge"
     routine, which pass the appropriate values to it. I have assumed an 80
     character column video display, if you use otherwise adjust the values
     accordingly.

   -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
*/

proc UpdateStatusBar(integer Value_1, integer Value_2)
     string Bar_1[69]="€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€"
     string Bar_2[69]="∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞∞"
     message(" 0% [",SubStr(Bar_1,1, Value_1),SubStr(Bar_2,1, Value_2),"] 100%")
end



/*
   -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

     The following procedure deletes all the blank lines in a file, beginning
     with the first line in the file

   -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
*/

proc mDelBlankLines(integer Option_Number)           // The Macro Procedure name & passed option variable
     integer LinesSkipped                            // Variable used when deleting from cursor to end
     integer StartBlockAddress                       // Variable used when deleting a marked block
     integer EndBlockAddress                         // Variable used when deleting a marked block
     PushPosition()                                  // Initial position (to be returned to)
     Case Option_Number                              //"Passed Option Variable Test"
          When 1                                     // If the "Global" option was selected
               BegFile()                             // then go to the start of the file
          When 2                                     // If the "from Cursor" option was selected
               LinesSkipped=numlines()-currline()    // count the lines left in the file
               BegLine()                             // then go to the start of the line
          When 3                                     // If the "Block" option was selected
               If IsBlockInCurrFile() <> _LINE_      // test to see if there IS a block
                   Warn("A line block must be marked in current file")
                   Return ()                         // and Quit if there is NO block
               EndIf                                 // Exit the "Block" test
               StartBlockAddress=Query(BlockBegLine) // Otherwise find the block start
               EndBlockAddress=Query(BlockEndLine) - Query(BlockBegLine) // and the block end
               GotoBlockBegin()                      // and go to the beginning of the block
          OtherWise                                  // and if NONE of the options were selected (?)
               Return ()                             // quit the whole procedure (should NEVER happen)
     EndCase                                         // End of the "Passed Variable Test"

     While LFind("^[\d009\d032]*$","X")              // Start a "Regular Expression" search
           DelLine()                                 // Delete the blank line
           Case Option_Number                        //"Passed Option Variable Test"
                When 1                               // Display appropriate bar graph...
                     UpdateStatusBar((69*(100*currline()/numlines())/100),69-(69*(100*currline()/numlines())/100))
                When 2
                     UpdateStatusBar((69*(100*currline()/LinesSkipped)/100),69-(69*(100*currline()/LinesSkipped)/100))
                When 3
                     UpdateStatusBar((69*(100*(currline()-StartBlockAddress)/EndBlockAddress)/100), 69 - (69 * (100 * (currline()-StartBlockAddress) / EndBlockAddress)/100))
                OtherWise
                     Return()
           EndCase
     EndWhile
     Message("Blank line purge done")      // Tell you it's done...
     PopPosition()                         // and return to your original position
End                                        // then exit the procedure


/* -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

        The following is the modified "MacroMenu" to include these new
        procedures within a Sub-Heading of  "Search & Destroy",  which
        can be selected via the "Hot Keys" or the mouse

   -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
*/

Menu MacroMenu()
    Title = "Keyboard Macros"
    history

    "&Record"                       ,   RecordKeyMacro()
    "&Save..."                      ,   SaveKeyMacro()
    "Loa&d..."                      ,   LoadKeyMacro()
    "Run Scrap &Macro"              ,   ExecScrapMacro()
    "Pur&ge"                        ,   PurgeKeyMacro()
    "Search && Destroy"             , , Divide    // The New Section Title
    "&All Blank Lines"              ,   mDelBlankLines(1) // Option 1
    "&From Cursor to End of File"   ,   mDelBlankLines(2) // Option 2
    "&In Highlighted Block"         ,   mDelBlankLines(3) // Option 3
    "Compiled Macros"               , , Divide
    "&Execute..."                   ,   mMacMenu(1)
    "&Load..."                      ,   mMacMenu(2)
    "&Purge..."                     ,   mMacMenu(3)
    "&Compile"                      ,   mCompile()
end

/****************************************************************************
               Delete "Blank Lines" from the Current File
 ****************************************************************************/

/*
p.s. It didn't appear clear to me, but I found that if you want to delete a
     specific string in a file just use the "Replace" function and enter a
     NUL string (Alt+000 on the numeric keypad) as the replacement string.
     Maybe its mentioned somehow, or should be obvious, but I missed it.
     But if you want it "Macroed" simply add the following procedure and use
     the following MacroMenu...

*/
proc mDelSpecificItem()
     string SearchFor[255]=""
     string KillOps[7]=""
     string KillPrompt[73]="Options [BGLIWNX] (Back Global Local Ignore-case Words No-promp reg-Exp):"
     If Ask("Destroy: ", SearchFor)
        If   Ask(KillPrompt, KillOps)
             Replace(SearchFor, "", KillOps)
        Else
             return ()
        EndIf
     EndIf
End

Menu MacroMenu()
    Title = "Keyboard Macros"
    history

    "&Record"                       ,   RecordKeyMacro()
    "&Save..."                      ,   SaveKeyMacro()
    "Loa&d..."                      ,   LoadKeyMacro()
    "Run Scrap &Macro"              ,   ExecScrapMacro()
    "Pur&ge"                        ,   PurgeKeyMacro()
    "Search && Destroy"             , , Divide
    "&All Blank Lines"              ,   mDelBlankLines(1)
    "Blanks &From Cursor to End"    ,   mDelBlankLines(2)
    "Blanks &In Highlighted Block"  ,   mDelBlankLines(3)
    "&Kill Specific Item"           ,   mDelSpecificItem()
    "Compiled Macros"               , , Divide
    "&Execute..."                   ,   mMacMenu(1)
    "&Load..."                      ,   mMacMenu(2)
    "&Purge..."                     ,   mMacMenu(3)
    "&Compile"                      ,   mCompileTse()
    "&Telix Compile"                ,   mCompileSalt()
end

/****************************************************************************
                                  fin
 ****************************************************************************/

