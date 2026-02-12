/*
   This example file shows one way to redefine menus and keys
   in a controlable way without modifying TSE's own core files.

   Big reward: with a TSE update you don't have to compare two largely
   identical .ui files, but you simply compare this limited macro file
   to TSE's new .ui file.

   Installation: compile this macro, put it in your macro autoload list,
   and restart TSE.

   Uninstall: simply remove this macro from the autoload list, and you
   have Semware's menus and keys back.

   Note: This macro was tested with TSE 3.0 configured with a tse.ui file,
   and with TSE 4.2 with a win.ui file. This example is for the latter,
   but the only difference in this example is the name of the .ui file
   and the commented copies, which was 1 minute work.
   You might have to adapt this example to your own configuration to test it.
   This macro demonstrates the principle of how you may do that very easily.
*/



// Put forward definitions here of those menus and procs from the .ui file,
// that you will use in your menu and key redefinitions.

forward menu MyMainMenu()



// Put your key redefinitions here, because the first key definition is used.
<Escape> MyMainMenu()
<ctrlshift e> EditFile() // This key definition is shown in the new menu.



#include ["..\ui\win.ui"]



proc world_peace()
   MsgBox("World peace ignition button", "Press OK to start World Peace", _ok_)
   Alarm()
   Message("World Peace process started ... ")
   Delay(99)
end

menu MyUtilMenu()
    HISTORY

// (Added world peace process to my utilities)
    "Start World Peace ..." ,   world_peace()
// Copy the lines from the UtilMenu from your own .ui file here,
// changing them as needed:
// (In this case there are no changes, only the addition above)
    "Line Dra&wing" [OnOffStr(Query(LineDrawing)):3], Toggle(LineDrawing), OEMMenuFlags()
    "Li&ne Type  "         ,   LineTypeMenu()      ,   OEMMenuFlags()
    ""                          ,                   ,   Divide
    "&Sort"                 ,   ExecMacro("sort " + Str(sort_flags)), BrowseModeMenuFlags() | BlockMenuFlags()
    "Sort &Order"   [ShowSortFlag() : 10], ToggleSortFlag(_DESCENDING_), DontClose
    "&Case-Sensitive Sort" [OnOffStr((sort_flags & _IGNORE_CASE_) == 0):3], ToggleSortFlag(_IGNORE_CASE_), DontClose
    ""                          ,                   ,   Divide
    "S&pell Check  "       ,   ExecMacro("SpellChk")
    "&ASCII Chart..."       ,   mAsciiChart()
    "&Date/Time Stamp"      ,   mDateTimeStamp(), BrowseModeMenuFlags()
    "S&hell"                ,   Shell()
    "Captu&re OS Output"    ,   ExecMacro("Capture")
    "Potpo&urri..."         ,   ExecMacro("Potpourr")
    "Ca&lculator..."        ,   ExecMacro("expr")
    "Where &Is..."          ,   ExecMacro("where")
// End of copy.
end

menubar MyMainMenu()
// Copy the lines from the MainMenu from your own .ui file here,
// changing them as needed:
// (UtilMenu was changed to MyUtilMenu)
    "&File"    ,    FileMenu()
    "&Text"    ,    TextMenu()
    "&Search"  ,    SearchMenu()
    "&Block"   ,    BlockMenu()
    "&Clip"    ,    ClipMenu()
    "&Window"  ,    WindowMenu()
    "&Macro"   ,    MacroMenu()
    "&Print"   ,    PrintMenu()
    "&Util"    ,    MyUtilMenu()
    "&Options" ,    OptionsMenu()
    "&Help"    ,    HelpMenu()
// End of copy.
end

