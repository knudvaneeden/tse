//*************************************************************************
/************************  Start Comment Area *****************************

  ThisFile:  'selhlp07.s' for TSE 2.00 - This version for uploading

===========================================================================

  This TSE macro is provided as a *.s file for you to evaluate.  The
  macro has been assigned to <Alt F1> for debugging purposes and the end
  of this file.

  It will also function as an include file in your user interface source
  file and that is the way that I normally use this macro.

===========================================================================
  Also read: 'selhlp07.rdm' -  Read Me file for additional information
===========================================================================

  This is TSE QuickHelp() macro intended to add user defined help
  screens to the basic HELP system.  To select press <Alt F1> or change
  the default key to one of your choice.  To compile this macro will
  require *.hlp files with various help formats.  The files are listed
  below in the includes and are included within this zip.

  The macro includes the SemWare default key assignments and has the
  advantage over SemWare's in that Speed Search is enabled in the
  in the QuickHelp() and no search is possible in SemWares default key
  assignments.

  Use, abuse, or modify this macro to suit you own tastes.  \\\...tak

            ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
            ³TAK Information Exchange; Fort Wayne, Indiana ³
            ³    ÷÷  Friday; October 14 at 2059 hrs  ÷÷    ³
            ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
   InterNet: tom.klein@chrbbs.sccsi.com  OR tom.klein@lunatic.com


===========================================================================

                        ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
                        ³>> REVISION HISTORY << ³
                        ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

10/14/94:  Continued conversion from 'selhlp06.s'

09/23/94:  Remove the blocked sections of 'selhlp07' because they were
           rarely or never used.  Replaced them with SemWare's Default
           Key Assignments from 'tse.hlp' copied via <Grey +>

  *************************************************************************/
//********************** END of Comment Area ******************************

#include "tse2.hlp"         // QuickHelp text  'KeyAssignments_SemWare'
#include "keybind.hlp"      // QuickHelp text  'KeyAssignments'
#include "function.hlp"     // QuickHelp text for FUNCTION
#include "newmacro.hlp"     // QuickHelp text recent macros
#include "orig_key.hlp"     // Default KeyAssingments

menu SelectHelpMenu()

     Title = "  SelectHelpMenu 0.07 - 10/14/94"
     History
     "",,Divide

     "&TAK KeyAssignments and Unused Keys",  QuickHelp(KeyAssignments)
     "By &Function "               ,  QuickHelp(KeysByFunction)
     "&New Macro Keys"             ,  QuickHelp(NewMacroKeys)
//     "&Alternate Keys"             ,  QuickHelp(Alternate_Keys)
//     "&Control Keys"               ,  QuickHelp(Control_Keys)
     "",,Divide
     "SemWare's Original Info",,Divide
     "",,Divide
     "SemWare &Original 'tse.hlp'" ,  QuickHelp(KeyAssignments_SemWare)
     "&Default Key Bindings"       ,  QuickHelp(Default_KeyAssignments)
end  SelectHelpMenu

// /*

<ALT F1>  SelectHelpMenu()     //For Testing only or as a StandAlone
                               //Put binding is in 'tse.key' if
                               //SelectHelpMenu() in placed in 'tse.s'
// */


