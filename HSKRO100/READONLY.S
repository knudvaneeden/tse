//// HSK Read-Only macros
////
//// Written by:  Howard Kapustein
////
//// Description: Read-Only macros by Howard Kapustein.
////
//// Recommended key bindings:  <CenterCursor>  mHskListOpenFiles()
////
//// Last Update:
////    02/22/95 10:41 pm HSK0  Created (1.0)
////
//// Credits:
////    mHskListOpenFiles() based on mListOpenFiles() in TSE.UI and
////        the buffer list display in Sage Professional Editor, plus
////        some encouragement by Mike Brocious.
////
////
//// Permission is granted to SemWare to modify and distribute
//// this macro set with the SemWare Editor product.
////
//// Howard Kapustein, February 22, 1995
////
////
////
#include ["readhlpr.s"]
//***SEEME***
#include ["readlist.s"]
#include ["readmsg.s"]
#include ["readstat.s"]
#include ["readmenu.s"]
//
//
// Global Variables
integer EnableStatusLineWhenLoaded  = TRUE
//
// WhenLoaded() - Initial setup when the macro is loaded
proc WhenLoaded()

    // Initialize the various sub-species of this macro
    WhenLoaded_MessageIfReadOnly()
    if EnableStatusLineWhenLoaded
        WhenLoaded_StatusLine()
    endif

end
//
// WhenPurged() - Cleanup when the macro is purged
proc WhenPurged()

    // Shutdown the various sub-species of this macro
    WhenPurged_StatusLine()
    WhenPurged_MessageIfReadOnly()

end
//
//
<CenterCursor>      mHskListOpenFiles()
