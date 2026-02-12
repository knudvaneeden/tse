//// HSK Read-Only macros - Menu
////
//// Written by:  Howard Kapustein
////
//// Description: Menu for Read-Only macros by Howard Kapustein.
////
//// Recommended key bindings:  <CtrlShift R>   mHskReadOnlyMenu()
////
//// Last Update:
////    02/22/95 10:41 pm HSK0  Created (1.0)
////
//// Credits:
////    None.
////
////
//// Permission is granted to SemWare to modify and distribute
//// this macro set with the SemWare Editor product.
////
//// Howard Kapustein, February 22, 1995
////
////
////
// HskReadOnlyMenu() - Display a menu of options
Menu mHskReadOnlyMenu()
    History
    Title = 'HSK ReadOnly Menu'

    "&List Open Files"          , mHskListOpenFiles()

    "Options"                   ,                               , Divide
    "&Buffer List          "   , mHskListOpenFilesMenu()       , DontClose
    "&Message If Read-Only "   , mHskMessageIfReadOnlyMenu()   , DontClose
    "&Status Line          "   , mHskStatusLineMenu()          , DontClose
end
//
//
// Key Bindings for testing
<CtrlShift R>           mHskReadOnlyMenu()
