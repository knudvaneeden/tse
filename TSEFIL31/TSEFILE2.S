/****************************************************************************\

    TSEFile2.S

    Help screens and menu system for file manager

    Version         v3.10/28.04.95
    Copyright       (c) 1994,95 by DiK

    History

    v3.10/28.04.95  extended version (file compare)

\****************************************************************************/

/****************************************************************************\
  ú Constants and variables
\****************************************************************************/

#include ["tsefile.src"]

/****************************************************************************\
  ú Constant strings
\****************************************************************************/

string  TC_ALL[]    = Chr(TC_DIR) + Chr(TC_NODIR)

/****************************************************************************\
  ú Global variables
\****************************************************************************/

integer h_mask                      // history id (file masks)

/****************************************************************************\
  ú Library calls
 
    þ Call              no argument call
    þ CallInt           switch only call
    þ CallSrc           source only call
    þ CallSrcInt        source & switch call
\****************************************************************************/

proc Call( string mac )
    ExecMacro("TF_"+mac)
    Set(Key,-1)
end

proc CallInt( string mac, integer int )
    SetGlobalInt(switch,int)
    Call(mac)
end

proc CallSrc( string mac, string src )
    SetGlobalStr(source,src)
    Call(mac)
end

proc CallSrcInt( string mac, string src, integer int )
    SetGlobalInt(switch,int)
    SetGlobalStr(source,src)
    Call(mac)
end

/****************************************************************************\
  ú Menu functions

    þ OnOff             invert boolean value
        ù SIO   refname
    þ OnOffStr          show boolean value
        ù SIN   refname
    þ SetConfirm        set confirm level and clear key
        ù SOUT  confirm
    þ SortFiles         sort file list
        ù SOUT  sfield
    þ SortOrderStr      toggle sort flag within menu
        ù SIO   sorder
    þ SetTagMark        set file tagging mask
        ù OUT   target      tagging mask
        ù GIN   h_msak      history id
    þ SetListMask       set file display mask
        ù SIO   l/rmask
    þ SetDrives         set configured drives
        ù SIO   drives
    þ SetDevice         set printer output port
        ù SIO   device
    þ SetPrtIni         set printer initialization string
        ù SIO   prtini
\****************************************************************************/

proc OnOff( string refname )
    SetGlobalInt(refname, not GetGlobalInt(refname))
end

string proc OnOffStr( string refname )
    return (iif(GetGlobalInt(refname), "On", "Off"))
end

proc SetConfirm()
    Set(Key,0)
    SetGlobalInt(confirm,MenuOption())
end

proc SortFiles()
    SetGlobalInt(sfield,MenuOption())
    CallSrc("ExecChain","S")
end

string proc SortOrderStr()
    return (iif( GetGlobalInt(sorder) == _DEFAULT_, "Ascending", "Descending" ))
end

proc SortOrder()
    integer order = GetGlobalInt(sorder)

    if order == _DEFAULT_
        order = _DESCENDING_
    else
        order = _DEFAULT_
    endif
    SetGlobalInt(sorder,order)
end

proc SetTagMark()
    string mask[40] = ""

    if Ask("Enter mask for filenames to mark:",mask,h_mask)
        SetGlobalStr(target,mask)
        CallSrc("ExecChain","M")
    endif
end

proc SetListMask( integer leftlist )
    string refmask[12], mask[40]

    if leftlist
        refmask = lmask
    else
        refmask = rmask
    endif

    mask = GetGlobalStr(refmask)
    if Ask("Enter file mask:",mask,h_mask)
        if Length(mask) == 0
            mask = "*.*"
        endif
        SetGlobalStr(refmask,mask)
        CallSrc("ExecChain","L")
    endif
end

proc SetDrives()
    string drvs[40] = GetGlobalStr(drives)

    if Ask("Enter drives:",drvs)
        if Length(drvs) == 0
            drvs = "c"
        endif
        SetGlobalStr(drives,drvs)
        CallSrc("ExecChain","T")
    endif
end

proc SetDevice()
    string port[48] = GetGlobalStr(device)

    if Ask("Default printer output port:",port)
        SetGlobalStr(device,port)
    endif
end

proc SetPrtIni()
    string init[60] = GetGlobalStr(prtini)

    if Ask("Printer initialization string:",init)
        SetGlobalStr(prtini,init)
    endif
end

/****************************************************************************\
  ú Menus

    þ FileMenu
        þ ViewMenu
        þ FindMenu
        þ GrepMenu
    þ DirMenu
        þ TreeMenu
    þ ArcMenu
    þ DescMenu
    þ MarkMenu
    þ SetupMenu
        þ SortMenu
        þ VideoMenu
        þ PrintMenu
        þ ConfirmMenu
        þ OptionMenu
    þ HelpMenu
    þ MainMenu
\****************************************************************************/

menu ViewMenu()
    history

    "&Launch...",
        Call("LaunchThis"),,
        "Execute current file or start the associated application"
    "",,    Divide
    "Browse &Hex...",
        CallInt("BrowseThis",BF_HEX),,
        "View a hex listing of the current file"
    "Browse &Text...",
        CallInt("BrowseThis",BF_TEXT),,
        "View current file, goto current directory or start macro"
    "",,    Divide
    "&Edit",
        CallInt("ForAll",FM_EDIT),,
        "Load current or marked file(s)"
    "Edit && &Quit",
        CallInt("ForAll",FM_EDIT|FM_QUIT),,
        "Load current or marked file(s) and quit file manager"
end

menu FindMenu()
    history

    "&Current...",
        CallInt("FindFile",FF_CURR),,
        "Search files in current directory only"
    "&Local...",
        CallInt("FindFile",FF_TREE),,
        "Search files in current directory and subdirectories"
    "&Drive...",
        CallInt("FindFile",FF_DISK),,
        "Search files on entire disk"
    "&Global...",
        CallInt("FindFile",FF_GLOB),,
        "Search files on all drives"
end

menu GrepMenu()
    history

    "&Current...",
        CallInt("FindFile",FF_CURR|FF_GREP),,
        "Search text in current directory only"
    "&Local...",
        CallInt("FindFile",FF_TREE|FF_GREP),,
        "Search text in current directory and subdirectories"
    "&Drive...",
        CallInt("FindFile",FF_DISK|FF_GREP),,
        "Search text on entire disk"
    "&Global...",
        CallInt("FindFile",FF_GLOB|FF_GREP),,
        "Search text on all drives"
end

menu FileMenu()
    history

    "Du&plicate...",
        CallInt("ForAll",FM_DUP),,
        "Copy current or marked file(s) (prompts for new name)"
    "&Rename...",
        CallInt("ForAll",FM_REN),,
        "Rename current or marked file(s) (prompts for new name)"
    "&Copy",
        CallInt("ForAll",FM_COPY),,
        "Copy current or marked file(s) to other (inactive) directory"
    "&Move",
        CallInt("ForAll",FM_MOVE),,
        "Move current or marked file(s) to other (inactive) directory"
    "De&lete",
        CallInt("ForAll",FM_DEL),,
        "Delete current or marked file(s)"
    "C&ompare",
        CallInt("ForAll",FM_COMP),,
        "Compare current or marked file(s)"
    "",,    Divide
    "&View          ",
        ViewMenu(),
        DontClose,
        "View or edit current file"
    "&Find          ",
        FindMenu(),
        DontClose,
        "Search files"
    "&Grep          ",
        GrepMenu(),
        DontClose,
        "Search text in files"
    "",,    Divide
    "&TSEComp",
        Call("TseComp"),,
        "Compare current file using TSEComp (prompts for second filename)"
    "&Dos-Shell",
        Call("DosShell"),,
        "Execute a dos shell"
    "",,    Divide
    "&Quit",
        CallInt("Terminate",TRUE),,
        "Quit file manager"
    "Q&uit To Current",
        CallInt("Terminate",FALSE),,
        "Quit file manager and do not restore directory"
end

menu TreeMenu()
    history

    "&Local",
        CallInt("TreeCmd",TC_SUB),,
        "Display the tree structure below the current directory"
    "&Global",
        CallInt("TreeCmd",TC_TREE),,
        "Display the tree structure of all drives"
    "",,    Divide
    "&Refresh Global Trees",
        CallInt("TreeCmd",TC_NEW),,
        "Update the tree structure of all drives"
end

menu DirMenu()
    history

    "&Drive...",
        Call("ChangeDrv"),,
        "Go to the specified drive"
    "List &Trees    ",
        TreeMenu(),
        DontClose,
        "Display tree structures"
    "",,    Divide
    "&Make...",
        Call("CreateDir"),,
        "Create a new directory immediately below the active one"
    "R&emove",
        Call("RemoveDir"),,
        "Remove an empty directory"
    "&Return",
        Call("RestoreDir"),,
        "Return to the directory which was active at startup"
    "&Change...",
        Call("ChangeDir"),,
        "Display another directory (prompts for name)"
    "",,    Divide
    "&Print",
        Call("PrintDir"),,
        "Output directory listing to printer or file"
    "&Info...",
        Call("DirInfo"),,
        "Display information about the current directory"
    "&Subtree Info...",
        Call("GetTreeStats"),,
        "Display information about the tree structure below the current directory"
    "",,    Divide
    "Re&fresh",
        Call("Refresh"),,
        "Update directory listings"
end

menu DescMenu()
    history

    "&Edit...",
        CallInt("EditDesc",FALSE),,
        "Edit description in a prompt box (up to 254 characters)"
    "Edit &Inline...",
        CallInt("EditDesc",TRUE),,
        "Edit description in place (up to 36 characters)"
    "",,    Divide
    "&Set All...",
        CallInt("SetAllDesc",TRUE),,
        "Set the descriptions of all directory entries"
    "Set All &Marked...",
        CallInt("SetAllDesc",FALSE),,
        "Set the descriptions of all marked directory entries"
    "",,    Divide
    "Collect &Garbage...",
        Call("CheckDesc"),,
        "Check for descriptions of files that do not exist"
    "",,    Divide
    "Sa&ve Descriptions",
        Call("SaveDesc"),,
        "Save the file descriptions manually"
end

menu MarkMenu()
    history

    "Mark &All",
        CallSrcInt("TagFiles",TC_ALL,TM_ON),,
        "Mark all files and directories"
    "&Unmark All",
        CallSrcInt("TagFiles",TC_ALL,TM_OFF),,
        "Remove all marks"
    "&Toggle All",
        CallSrcInt("TagFiles",TC_ALL,TM_TOGGLE),,
        "Toggle all marks"
    "",,    Divide
    "Mark &Files",
        CallSrcInt("TagFiles",Chr(TC_NODIR),TM_ON),,
        "Mark all files"
    "Mark &Directories",
        CallSrcInt("TagFiles",Chr(TC_DIR),TM_ON),,
        "Mark all directories"
    "",,    Divide
    "&Set Marks...",
        SetTagMark(),
        CloseAllAfter,
        "Set marks according to file specification"
end

menu SortMenu()
    history = GetGlobalInt(sfield)
    command = SortFiles()

    "&Name",,,
        "Sort files by name"
    "&Ext",,,
        "Sort files by extension"
    "&Size",,,
        "Sort files by size"
    "&Time",,,
        "Sort files by time"
    "&Desc",,,
        "Sort files by description"
    "&Mark",,,
        "Move marked files to the top of the listing"
end

menu VideoMenu()
    history = Query(CurrVideoMode)
    command = CallInt("VideoMode",MenuOption())

    "&25-Lines",,,
        "Standard text mode"
    "2&8-Lines",,,
        "Enhanced vga mode (vga only)"
    "&43-Lines",,,
        "Small ega fonts (ega and vga)"
    "&50-Lines",,,
        "Small vga fonts (vga only)"
end

menu PrintMenu()
    "&Output Port...",
        SetDevice(),
        DontClose,
        "Default printer output port (may be a filename)"
    "&Printer Setup...",
        SetPrtIni(),
        DontClose,
        "Control sequence used to initalize printer"
end

menu ConfirmMenu()
    history = GetGlobalInt(confirm)
    command = SetConfirm()

    "&Never",,
        CloseBefore,
        "Delete or overwrite files without warnings"
    "&Delete",,
        CloseBefore,
        "Warn only when deleting files"
    "&Overwrite",,
        CloseBefore,
        "Warn only when overwriting files"
    "&Allways",,
        CloseBefore,
        "Allways warn when files are being destroyed"
end

menu OptionMenu()
    history

    "&Warnings  "
        [MenuStr(ConfirmMenu,GetGlobalInt(confirm)):9],
        ConfirmMenu(),
        DontClose,
        "Display warnings before deleting or overwriting files"
    "&Use Descriptions"
        [OnOffStr(describe):3],
        OnOff(describe),
        DontClose,
        "Read and write 4dos compatible description files"
    "&Prompt Descr. Saves "
        [OnOffStr(savedsc):3],
        OnOff(savedsc),
        DontClose,
        "Prompt before saving description files on disk"
    "&Save Changed Files"
        [OnOffStr(inisave):3],
        OnOff(inisave),
        DontClose,
        "Save all changed files before using file manager"
    "Prompt On &Exit"
        [OnOffStr(quitmsg):3],
        OnOff(quitmsg),
        DontClose,
        "Prompt before terminating file manager"
    "&Restore Directory"
        [OnOffStr(restore):3],
        OnOff(restore),
        DontClose,
        "On exit, restore the directory which was active at startup"
    "&Autosave Options"
        [OnOffStr(autosave):3],
        OnOff(autosave),
        DontClose,
        "Automatically save options on exit"
end

menu SetupMenu()
    history

    "&Left List"
        [GetGlobalStr(lmask):8],
        SetListMask(TRUE),
        CloseAllAfter,
        "Files to be displayed in the left directory listing"
    "&Right List"
        [GetGlobalStr(rmask):8],
        SetListMask(FALSE),
        CloseAllAfter,
        "Files to be displayed in the right directory listing"
    "&Drives"
        [GetGlobalStr(drives):8],
        SetDrives(),
        CloseAllAfter,
        "Drives, for which tree information should be stored"
    "",,    Divide
    "&Sort Field"
        [MenuStr(SortMenu,GetGlobalInt(sfield)):4],
        SortMenu(),
        DontClose,
        "Sort field for directory listings (name, ext...)"
    "Sort &Order"
        [SortOrderStr():10],
        SortOrder(),
        DontClose,
        "Sort order of directories (ascending or descending)"
    "",,    Divide
    "V&ideo Mode            ",
        VideoMenu(),
        DontClose,
        "Choose the number of lines displayed at the screen"
    "&Associations          ",
        Call("AssocList"),,
        "View and edit the list of extensions associtated with an application"
    "&Printer Setup         ",
        PrintMenu(),
        DontClose,
        "Setup printer port and initialization"
    "&More Options          ",
        OptionMenu(),
        DontClose,
        "Setup basic behaviour of file manager"
    "",,    Divide
    "Sa&ve Options",
        CallInt("SaveConfig",TRUE),,
        "Save options now"
end

menu HelpMenu()
    history

    "&Help",
        Call("MainHelp"),,
        "Display help on key bindings"
    "",,    Divide
    "&About...",
        Call("AboutBox"),,
        "Display copyright info"
end

menubar MainMenu()
    history

    "&File",            FileMenu()
    "&Directory",       DirMenu()
    "Descr&ibe",        DescMenu()
    "&Mark",            MarkMenu()
    "&Options",         SetupMenu()
    "&Help",            HelpMenu()
end

/****************************************************************************\
  ú main help screen
\****************************************************************************/

helpdef MainHelp
    title = "Help on File Manager"
    x = 5
    y = 3
    width = 70
    height = 19

    ""
    " General remarks"
    " ---------------"
    ""
    " Additional Help"
    "   All the various pick and browsing lists have their own special"
    "   help screen, which is accessed by pressing the F1 key."
    ""
    " Speed Search"
    "   Pressing a normal key (0-9 or a-z) will position the file list at"
    "   the next file beginning with this character. Upper case letters"
    "   search backwards."
    ""
    " Marking Files"
    "   The SetMark command (MarkMenu) accepts character ranges. E.g.,"
    "   [a-f]*.* would mark all files beginning with a character in the"
    "   range of a to f."
    ""
    " Finding Files and Text"
    "   The entire current drive or only part of it can be searched for"
    "   files (find) and text (grep). The search result is shown in a"
    "   pick list, which allows various operations on these files."
    ""
    " Browsing"
    "   The action taking when Enter is pressed, depends on the current"
    "   file and its extension."
    "       ù directory           their contents will be listed"
    "       ù mac                 file manager terminates and"
    "                             the macro is loaded and executed"
    "       ù btm,bat,com,exe     the command is executed in a dos shell"
    "                             (btm are 4dos batch-to-memory files)"
    "       ù association         the application is executed with"
    "                             the current file as an argument"
    "       ù otherwise           the file is browsed in text mode"
    "   Associations connect file extensions with an application. Thus"
    "   loading a file and its application is reduced to one keystroke."
    ""
    " File Descriptions"
    "   TSEFile reads and writes 4dos compatible descriptions files."
    "   The descriptions are only visible, if the current window is"
    "   zoomed. The file descriptions can be edited, deleted and moved"
    "   in a variety of ways (c.f. key bindings). All file and tree"
    "   management operations also handle the file descriptions, e.g.,"
    "   when a file is copied, its description is copied along with it."
    "   NB: description editing works only, if the window is zoomed."
    ""
    " Drag & Drop"
    "   Marked files can be dragged using the mouse. The files are"
    "   either copied or moved depending on the state of the Ctrl key."
    "   The dragging box indicates the operation and the number of"
    "   files affected. The operation starts only, if the indicator"
    "   box is visible, when the mouse key is released."
    ""
    " Duplicating and Renaming Files"
    "   These commands (F7 and F8) accept file paths, thus duplicating"
    "   and renaming across directories is possible. Furthermore it is"
    "   possible to rename directories."
    ""
    " Copying Files and Directories"
    "   The file management commands (copy, move and delete) now also"
    "   work with directories. In other words, if, e.g., a directory"
    "   is copied, all the files and subdirectories within it are"
    "   copied along with it. Deleting and moving directories always"
    "   pops up a warning box to minimize on accidents."
    ""
    " Directories and Trees"
    "   TSEFile maintains a list of all the directories of the drives,"
    "   which are configured for tree management. All operations on"
    "   directories are immediately reflected in this list. It may be"
    "   used to view the tree structure of a drive and to quickly go"
    "   to another directory, by just typing a few characters."
    ""
    " Options"
    "   The program options can be saved on disk. The next time the"
    "   file manager is loaded, the saved options will be restored and"
    "   immediately be available."
    ""
    ""
    " Key bindings and menu commands"
    " ------------------------------"
    ""
    " Help"
    "   F1              Alt-H H     this help"
    "   -               Alt-H I     info on file manager"
    ""
    " Windows"
    "   F12             -           zoom/unzoom window"
    "   Shift F12       -           switch list"
    "   Tab             -           switch list"
    ""
    " Movement"
    "   0..9,a..z,A..Z  -           speed search"
    "   Up/Down         -           move up/down one line"
    "   PgUp/Down       -           move up/down one page"
    "   Home/End        -           goto beginning/end of list"
    "   Ctrl-F/L        -           goto first/last marked file"
    "   Ctrl-N/P        -           goto next/previous marked file"
    "   Ctrl-R          -           repeat find within list boxes"
    ""
    " Marking files"
    "   Grey+           -           mark current file"
    "   Grey-           -           unmark current file"
    "   Spacebar        -           toggle mark of current files"
    "   Grey*           Alt-M A     mark all list entries"
    "   Grey/           Alt-M U     unmark all list entries"
    "   GreyEnter       Alt-M T     toggle marks of all entries"
    "   -               Alt-M F     mark all files"
    "   -               Alt-M D     mark all directories"
    "   -               Alt-M S     set marks according to expression"
    ""
    " File descriptions"
    "   Alt BackSpace   -           undo last edit or delete"
    "   Ctrl Del        -           delete current description"
    "   Shift Del       -           delete and move to clipboard"
    "   Ctrl Ins        -           copy current line to clipboard"
    "   Shift Ins       -           paste clipboard to current line"
    "   F2              Alt-I I     edit description (inline)"
    "   Shift F2        Alt-I E     edit description (prompt)"
    "   -               Alt-I S     set descriptions of all entries"
    "   -               Alt-I M     set descriptions of marked entries"
    "   -               Alt-I V     save descriptions to file"
    "   -               Alt-I G     check descriptions for garbage"
    ""
    " Searching and browsing files"
    "   Enter           -           browse current file in default mode"
    "   Shift Enter     Alt-F V H   browse current file in hex mode"
    "   -               Alt-F V T   browse current file in text mode"
    "   Ctrl Enter      Alt-F V L   launch current file"
    "   -               Alt-F F C   search files within current directory"
    "   -               Alt-F F L   search files within subtree"
    "   -               Alt-F F D   search files on entire drive"
    "   -               Alt-F F G   search files on all drives"
    "   -               Alt-F G C   search text within current directory"
    "   -               Alt-F G L   search text within subtree"
    "   -               Alt-F G D   search text on entire drive"
    "   -               Alt-F G G   search text on all drives"
    ""
    " File and subtree management"
    "   Del             Alt-F L     delete files and subtrees"
    "   F7              Alt-F R     rename files and directories"
    "   F8              Alt-F P     copy files (prompts for new names)"
    "   Ctrl-C          Alt-F C     copy files and trees to other window"
    "   Ctrl-M          Alt-F M     move files and trees to other window"
    "   Ctrl-O          Alt-F O     compare files and trees"
    ""
    " Directories and trees"
    "   Ins             Alt-D M     add a new directory"
    "   -               Alt-D E     remove an empty directory"
    "   F6              Alt-D C     change current directory"
    "   Shift F6        Alt-D D     change current drive"
    "   -               Alt-D R     return to startup directory"
    "   -               Alt-D I     show info about current directory"
    "   -               Alt-D S     show info about subtree"
    "   -               Alt-D P     print directory listing"
    "   F5              Alt-D F     refresh directory listings"
    "   F9              Alt-D T L   show subtree of current directory"
    "   Shift F9        Alt-D T G   show all directories of all drives"
    "   -               Alt-D T R   read directory information"
    ""
    " Options and setup"
    "   -               Alt-O L     file mask for left window"
    "   -               Alt-O R     file mask for right window"
    "   -               Alt-O D     drives for tree information"
    "   -               Alt-O S     sort field for both windows"
    "   -               Alt-O O     sort order"
    "   -               Alt-O I     video mode"
    "   -               Alt-O A     view and edit association list"
    "   -               Alt-O P O   output port for printing (may be file)"
    "   -               Alt-O P P   initialization string for printer"
    "   -               Alt-O M W   warning level for file deletion"
    "   -               Alt-O M U   use 4dos compatible descriptions"
    "   -               Alt-O M P   prompt before saving descriptions"
    "   -               Alt-O M S   on startup, save changed files"
    "   -               Alt-O M E   on exit, prompt"
    "   -               Alt-O M R   on exit, restore startup directory"
    "   -               Alt-O M A   on exit, save configuration"
    "   -               Alt-O V     save options in configuration file"
    ""
    " Miscellaneous"
    "   F10             -           activate menu"
    "   F4              Alt-F T     compare current file using TSEComp"
    "   F3              Alt-F V E   load files"
    "   Shift F3        Alt-F V Q   load files and return to editor"
    "   Escape          Alt-F Q     return to editor"
    "   Shift Escape    Alt-F U     return and do not restore directory"
    "   -               Alt-F D     run a dos shell"
    ""
    " Mouse"
    "   Left Click Statusline       activate menu"
    "   Left Click                  toggle mark"
    "   Shift Left Click            extend markings"
    "   Left Drag                   move marked files"
    "   Ctrl Left Drag              copy marked files"
    "   Shift Left Drag             extend markings and move marked files"
    "   Ctrl Shift Left Drag        extend markings and copy marked files"
    "   Right Click                 browse current file or directory"
    ""
    " Prompt (blue) boxes"
    "   Enter, Left Button, Y       accept"
    "   Escape, Right Button, N     cancel"
    ""
    " Error (red) boxes"
    "   Ctrl C                      break"
    "   AnyOtherKey                 continue"
    ""
end

/****************************************************************************\
  ú help on browsing (normal)
\****************************************************************************/

helpdef BrowseHelp
    title = "Help on File Browsing"
    x = 10
    y = 6
    width = 60
    height = 11

    ""
    " This window shows a file in a read only environment."
    ""
    " Escape        close the file"
    " Enter         close the file"
    ""
    " CursorKeys    move"
    ""
    " Ctrl-R        repeat last search"
    " AnyOtherKey   incremental search"
    ""
end

/****************************************************************************\
  ú help on browsing (after grep)
\****************************************************************************/

helpdef GrepHelp
    title = "Help on File Browsing"
    x = 10
    y = 4
    width = 60
    height = 16

    ""
    " This window shows a file in a read only environment."
    ""
    " Moreover, you can compress the file, to show a list of"
    " the lines which match the grep expression. Expanding"
    " the file from this list will reload it and position the"
    " cursor at the highlighted line."
    ""
    " Escape        close the file"
    " Enter         compress/expand the file"
    ""
    " CursorKeys    move"
    ""
    " Ctrl-R        repeat last search"
    " AnyOtherKey   incremental search"
    ""
end

/****************************************************************************\
  ú help on list of found files
\****************************************************************************/

helpdef FindHelp
    title = "Help on List of Found Files"
    x = 10
    y = 3
    width = 60
    height = 18

    ""
    " This list shows the files which have been found during"
    " a file find or grep. The following tasks can be directly"
    " executed from within the list."
    ""
    " Escape        close the list"
    " Enter         browse the current file"
    " Ctrl Enter    launch the current file"
    " F10           show menu with additional functions"
    ""
    " CursorKeys    move"
    ""
    " Ctrl-R        repeat last search"
    " AnyOtherKey   incremental search"
    ""
    " The menu provides the following functions."
    ""
    " Load File     loads the marked file into the editor"
    " Copy          copies the marked file into the active dir"
    " Copy All      copies all files into the active directory"
    " Delete        deletes the marked file"
    " Delete All    deletes all found files"
    " Change Dir    activates the directory of the marked file"
    " Save List     saves the list of found files on disk"
    ""
end

/****************************************************************************\
  ú help on tree listings
\****************************************************************************/

helpdef TreeHelp
    title = "Help on Tree Listings"
    x = 10
    y = 3
    width = 60
    height = 19

    ""
    " The contents of this list depends on the command used to"
    " access it. If local or global tree was used, it shows"
    " either the subtree of the current directory or a sorted"
    " list of all directories of all drives. If change directory"
    " or compress was used, it shows all directories that match"
    " the specified search string."
    ""
    " Escape        close the list"
    " Enter         go to the highlighted directory"
    ""
    " Alt-C         compress the list (search directories)"
    " Alt-E         expand the list (show all directories)"
    ""
    " CursorKeys    move"
    ""
    " Ctrl-R        repeat last search"
    " AnyOtherKey   incremental search"
    ""
end

/****************************************************************************\
  ú help on launch list
\****************************************************************************/

helpdef LaunchHelp
    title = "Help on File Associations"
    x = 10
    y = 6
    width = 60
    height = 12

    ""
    " This list shows the currently defined file associations."
    " An association is a file extension connected with an"
    " application. If you browse the file by pressing <Enter>,"
    " it will not be shown as a text listing, but the associated"
    " application will be launched with the file as an argument."
    ""
    " Escape        close the list"
    " Enter         edit the current association"
    " Del           delete the current association"
    " Ins           insert a new association"
    ""
    " The edit menu provides the following functions."
    ""
    " Extension     the extension to associate with an app."
    " Command       the command to launch the application"
    " Options       add. options (appended after filename)"
    " Archive       special setup for archiver output"
    " After Call    what to do after the command has finished"
    " Acc. & Close  store the current settings"
    ""
end

/****************************************************************************\
  ú help on tee'd output listing
\****************************************************************************/

helpdef TeeOutHelp
    title = "Help on Command Output"
    x = 10
    y = 6
    width = 60
    height = 11

    ""
    " This window shows the output of the executed command."
    ""
    " Escape        close the list"
    " Enter         close the list"
    ""
    " CursorKeys    move"
    ""
    " Ctrl-R        repeat last search"
    " AnyOtherKey   incremental search"
    ""
end

/****************************************************************************\
  ú help on archive listings
\****************************************************************************/

helpdef ArcListHelp
    title = "Help on Archive Listings"
    x = 10
    y = 3
    width = 60
    height = 17

    ""
    " This window shows the contents of the current archive."
    " Archived files can be viewed, marked and extracted."
    " The target directory for extraction is always the"
    " current directory."
    ""
    " Escape        close the list"
    " Enter         browse current file"
    " SpaceBar      mark/unmark current file"
    " Alt-E         extract current or marked files"
    " Alt-A         extract all files"
    ""
    " CursorKeys    move"
    ""
    " Ctrl-R        repeat last search"
    " AnyOtherKey   incremental search"
    ""
end

/****************************************************************************\
  ú help on compare
\****************************************************************************/

helpdef  CompareHelp
    title = "Help on Compare"
    x = 10
    y = 7
    width = 60
    height = 8

    ""
    " This windows shows the result of the last file compare."
    ""
    " Escape        close"
    " Enter         close"
    ""
    " CursorKeys    move"
    ""
end

/****************************************************************************\
  ú wrapper routine
\****************************************************************************/

proc ExecHelp( integer id )
    integer mba, mta

    mba = Set(MenuBorderAttr,CC_PROMPT)
    mta = Set(MenuTextAttr,CC_PROMPT)
    case id
        when 1  QuickHelp(MainHelp)
        when 2  QuickHelp(BrowseHelp)
        when 3  QuickHelp(GrepHelp)
        when 4  QuickHelp(FindHelp)
        when 5  QuickHelp(TreeHelp)
        when 6  QuickHelp(LaunchHelp)
        when 7  QuickHelp(TeeOutHelp)
        when 8  QuickHelp(ArcListHelp)
        when 9  QuickHelp(CompareHelp)
    endcase
    Set(MenuBorderAttr,mba)
    Set(MenuTextAttr,mta)
end

/****************************************************************************\
  ú public functions
 
    þ TF_Menu           the menu system
        ù IO    ******      depends on command called
    þ TF_MainHelp       main help screen
    þ TF_BrowseHelp     help on browsing (normal)
    þ TF_GrepHelp       help on browsing (after grep)
    þ TF_FindHelp       help on list of found files
    þ TF_TreeHelp       help on tree listings
    þ TF_LaunchHelp     help on association list
    þ TF_TeeOutHelp     help on tee'd output listing
    þ TF_ArcListHelp    help on archive listings
    þ TF_AboutBox       show copyright info
\****************************************************************************/

public proc TF_Menu()
    MainMenu()
end

public proc TF_MainHelp()
    ExecHelp(1)
end

public proc TF_BrowseHelp()
    ExecHelp(2)
end

public proc TF_GrepHelp()
    ExecHelp(3)
end

public proc TF_FindHelp()
    ExecHelp(4)
end

public proc TF_TreeHelp()
    ExecHelp(5)
end

public proc TF_LaunchHelp()
    ExecHelp(6)
end

public proc TF_TeeOutHelp()
    ExecHelp(7)
end

public proc TF_ArcListHelp()
    ExecHelp(8)
end

public proc TF_DiffListHelp()
    ExecHelp(9)
end

public proc TF_AboutBox()
    if PopWinOpen(16,8,65,16,1,"About File Manager",CC_PROMPT)
        Set(Cursor,OFF)
        Set(Attr,CC_PROMPT)
        ClrScr()
        VGotoXY(6,4)
        PutStr(banner)
        GetKey()
        PopWinClose()
    endif
    Set(Cursor,OFF)
end

/****************************************************************************\
  ú Entry and exit code

    þ WhenLoaded
        ù IN    target      code for checking caller
        ù GOUT  h_mask      history number
    þ WhenPurged
        ù GIN   h_mask      history number
\****************************************************************************/

proc WhenLoaded()
    string msg[40] = "TSEFile2 can only be executed by TSEFile"

    // check for caller

    if GetGlobalStr(target) <> target
        Alarm()
        if PopWinOpen(16,8,65,16,1,"Error",CC_ERROR)
            Set(Cursor,OFF)
            Set(Attr,CC_ERROR)
            ClrScr()
            VGotoXY((50-Length(msg))/2, 4)
            PutStr(msg)
            GetKey()
            PopWinClose()
        endif
        Set(Cursor,ON)
        PurgeMacro(CurrMacroFilename())
    endif

    // get history list

    h_mask = GetFreeHistory()
    AddHistoryStr("*.*",h_mask)
end

proc WhenPurged()

    // remove history list

    DelHistory(h_mask)
end

