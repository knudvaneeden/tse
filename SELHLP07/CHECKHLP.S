
//*************************************************************************
/************************  Start Comment Area *****************************

ThisFile:  checkhlp.s      Started 10/14/94

Also read: selhlp07.rdm  ; Read Me file for additional information
           selhlp07.s    ; For an explanation of the source file

  This file is a small portion of the 'selhlp07.s' file and it is a
  quick check that a *.hlp file is correctly formated and quoted

                        ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
                        ³>> REVISION HISTORY << ³
                        ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

10/14/94:  Original contstructed from a portion of 'selhlp07.s'

  *************************************************************************/
//********************** END of Comment Area ******************************

//tak ** User Change ******************************************************
// Change the #include below to the name of the file that you are checking

#include "c:\tse2\help\orig_key.hlp"         //File to be Checked

menu SelectHelpMenu()

     Title = "  CheckHelp Test 10/14/94"
     History
     "",,Divide

     "Check &Help" ,             QuickHelp(Default_KeyAssignments)
     "",,Divide

end  SelectHelpMenu

<ALT F1>  SelectHelpMenu()

/*
<ALT F1>  SelectHelpMenu()     //For Testing only or as a StandAlone
                               //Put binding is in 'tse.key' if
                               //SelectHelpMenu() in placed in 'tse.s'
*/
