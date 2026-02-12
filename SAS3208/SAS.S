/***********************     SPLIT and SCROLL MACRO     ******************
/**************************************************************************
Macro      : Split and Scroll Windows
Version    : 3.2
Date       : 20.07.98
Environment: TSE Pro/32 v2.8
Author     : Alex S Wilson  [ alex.s.wilson@btinternet.com ]
Function   : Opens windows for each file open and allows simultaneous
           : scrolling in all windows. See help and SAS.doc for details.
Operation  : F11 calls main menu. See help and SAS.doc for details.
Information: Version details, Whats New etc. See SAS.doc

/************************ END of MAIN Comment Area ************************/

/**** Set Macro Defaults **************************************************/

string MAuthor[] = "Alex S Wilson  [ alex.s.wilson@btinternet.com ]"
string MTitle[30] = "Split and Scroll Macro  "
string MName[8] = "SAS "                // Macro Name
string MVersion [6] = "3.2"             // Macro Version
string MBuild[4] = ".08"                // Macro Build
string MDate[10] = "20.07.98"           // Macro Date
string MStatus[20] ="Released"          // Macro Status
string MEnvironment[20] = "TSE/32 v2.8" // Macro Environment
string MHlpDocName[12] = "SAS"          // Macro Help/Document File Prefix
string MHlpExt[4] = ".hlp"              // File extension for help file
string MDocExt[4] = ".txt"              // File extension for document file


/**** Define and Set Constants and Variables ******************************/

string ScrollKeyStatusText[3]     // Text for scroll key status
string SplitText[10]              // Text for Split Type
string Section[6] = "SAS"         // Section name in TSE.ini
string SplitLoadText[3]           // Yes or No
string ScrollType[6]              // Type of Scrolling
string MenuTypeText[6]            // Type of Menu
string HlpDocFile[12]             // Help or Document filename
string ScrollLinesResetText[3]    // Text for Scroll Resume
string KeyStr[20]                 // KeyPressed string
string MenuCloseText[3]           // Text for menu close flag
string SaveOnExitText[3]          // Text for save settings on Exit

integer maxfiles                  // Set maximum files to split windows
integer minfiles                  // Set minimum files to split windows
integer ScrollSpeed               // Intialise Scroll Speed time
integer MaxScrollSpeed = 20       // Set maximum scroll Speed time
integer SplitType                 // Initialise Split Type, 1 = Horizontal
integer ScrollKeyStatus           // Initialise Scroll key status 1 = ON, 0 = OFF
integer Abort = 0                 // Set Abort Flag, 0 = No
integer SplitOnLoad               // Initialise Split on load
integer DirectFlag                // Scroll Direction Flag
integer ScrollCheck               // Check to halt Autoscroll
integer ScrollLines               // Scroll Line counter
integer MaxScrollLines            // Maximum lines to scroll
integer MenuType                  // Initialise Menu Type, 1 = Bar, 0 = Single
integer ScrollLinesReset          // Initialise Scroll Resume
integer SLResetMenuFlag           // Menu flag ScrollLinesReset
integer HlpDocMenuFlag1           // Menu flag for help file if it exists
integer HlpDocMenuFlag2           // Menu flag for document file if it exists
integer MenuCloseOption           // Initialise Menu Close option
integer MenuCloseFlag             // Menu Close Flag
integer SaveSetOnExit             // Save Settings on Exit flag

/**** Define and Set Common Messages *************************************/

String

       SASMsg0[] = " Press Any Key to Continue ",
       SASMsg1[] = " : Loaded þ F11 for Menu. ",
       SASMsg2[] = " : Too many files to split. SAS Maximum files : ",
       SASMsg3[] = " : Auto Scroll stopped by user. ",
       SASMsg4[] = " : Scroll Keys : ",
       SASMsg5[] = " : Enter Auto Scroll Speed setting between 1 and 20.",
       SASMsg6[] = " : Scroll Speed setting : ",
       SASMsg7[] = " : Split Type : ",
       SASMsg8[] = " : Auto Scroll : PAUSED ",
       SASMsg9[] = " : Enter maximum files to split.",
       SASMsg10[] = " : Maximum files to split : ",
       SASMsg11[] = " : Split when Loaded : ",
       SASMsg12[] = " : Current settings saved.",
       SASMsg13[] = " : Scroll mode set to : ",
       SASMsg14[] = " : Scroll lines/pages setting reached. ",
       SASMsg15[] = " : Enter number of lines/pages to scroll.",
       SASMsg16[] = " : Number of lines/pages to scroll : ",
       SASMsg17[] = " : Scrolling : ",
       SASMsg18[] = " : Menu mode set to ",
       SASMsg19[] = " : Minimum files to split : ",
       SASMsg20[] = " not installed or found in TSEPath.",
       SASMsg21[] = " : Enter minimum files to split.",
       SASMsg22[] = " : Too few files to split. SAS Minimum files : ",
       SASMsg23[] = " : Horizontal Page Scroll not available, using Scroll type.",
       SASMsg24[] = " : Scroll Lines Reset : ",
       SASMsg25[] = " Maximum files outwith range or less than Minimum files. Maximum files unchanged",
       SASMsg26[] = " Minimum files outwith range or greater than Maximum files. Minimum files unchanged",
       SASMsg27[] = " : Scroll speed set to : ",
       SASMsg28[] = " : Menu Close option set to : ",
       SASMsg29[] = " : Save Settings on Exit set to : "



/**** File Includes *******************************************************/



/**** Forward Declarations ************************************************/

forward KeyDef SASKeysScroll
forward KeyDef SASMenuBarKeys
forward KeyDef SASMenuSingleKeys

forward proc SplitWindows()
forward proc ScrollCurrentAuto(integer DirectFlag)
forward proc AutoScrollAll(integer DirectFlag)
forward proc MPVInfo()
forward proc SetMenuType()
forward proc SetMenuFlags()
forward proc WindowResize()
forward proc SaveIniSettings()


forward Menu SASMenu()
forward Menu SASMenuBar()
forward Menu ScrollTypeMenu()

/**** Define About Window  ***********************************************/

proc About()

    PopWinOpen(15,8,65,25, 4, "About", Color (Black ON White))
    Set(Attr, Color(Red ON White))
    WindowFooter(SASMsg0)
    ClrScr()
    Writeline('')
    Writeline('             ',MTitle )
    Writeline('')
    Set(Attr, Color(Blue ON White))
    Writeline('           Name:        ', MName)
    Writeline('           Version:     ', MVersion,MBuild )
    Writeline('           Environment: ',MEnvironment)
    Writeline('           Status:      ',MStatus)
    Writeline('')
    Writeline(' Thank you for using the ', Mtitle)
    Writeline('')
    Set(Attr, Color(Red on White))
    Writeline('')
    Writeline(' ',MAuthor)
    Writeline('')

    if Getkey() == <Spacebar>
        PopWinClose()
               MPVInfo()
    else
        PopWinClose()
    endif

end

/********** SAS Debug Information ****************************************************/

proc MPVInfo()  // Macro Parameter and Variable Information

    integer nf = Numfiles()

    PopWinOpen(15,6,65,32, 4, "Additional Information", Color (Black ON White))
    Set(Attr, Color(Blue ON White))
    WindowFooter(SASMsg0)
    ClrScr()
    Writeline('')
    Writeline(" Build:             ", MBuild)
    Writeline(" Date:              ", MDate)
    Writeline(" menutype:          ", menutype ," ",  menutypetext)
    Writeline(" splittype:         ", splittype ," ", splittext)
    Writeline(" scrolltype:        ", scrolltype)
    Writeline(" maxscrolllines:    ", maxscrolllines)
    Writeline(" scrollkeystatus:   ", scrollkeystatus)
    Writeline(" ScrollSpeed:       ", ScrollSpeed)
    Writeline(" Number of files:   ", nf)
    Writeline(" Number of Windows  ", numwindows())
    Writeline(" maxfiles:          ", maxfiles)
    Writeline(" minfiles:          ", minfiles)
    Writeline(" splitonload:       ", splitonload)
    Writeline(" Direction Flag:    ", DirectFlag)
    Writeline(" Abort Flag:        ", Abort)
    Writeline(" ScrollLinesReset:  ", ScrollLinesReset)
    Writeline(" SLResetMenuFlag:   ", SLResetMenuFlag)
    Writeline(" Help File Flag:    ", HlpDocMenuFlag1)
    Writeline(" Doc File Flag:     ", HlpDocMenuFlag2)
    Writeline(" Screen Rows:       ", Query(Screenrows))
    Writeline(" Screen Cols:       ", Query(Screencols))
    Writeline(" Menu Close:        ", MenuCloseOption)
    Writeline(" Save On Exit:      ", SaveSetOnExit)

    GetKey()
    PopWinClose()

 end

proc ViewDoc(integer ext)   // Used to view help or document file.

        SetMenuFlags()

        if ext == 1
                HlpDocFile = MHlpDocName + MHlpExt
        elseif ext == 2
                HlpDocFile = MHlpDocName + MDocExt
        endif

        if FileExists(SearchPath (HlpDocFile, (Query(TSEPath))))

                CreateBuffer("doc.tmp")
                InsertFile(SearchPath (HlpDocFile, (Query(TSEPath))))
                LList(MName + "Information",78,20,_ENABLE_HSCROLL_)
                AbandonFile()
                Message("")

        else
                Message(MName + MVersion + " : " + HlpDocFile + SASMsg20)
                Return()
        endif
end

/**** SAS Configuration **************************************************/
/*************************************************************************/

proc ReadIniSettings()  // Read the startup settings from ini file.

     ScrollSpeed  = GetProfileInt(section,"ScrollSpeed",5)

     ScrollType  = GetProfileStr(section,"scrolltype","Roll")

     MaxScrollLines = GetProfileInt(section, "maxscrolllines",0)

     ScrollKeyStatus = GetProfileInt(section, "ScrollKeyStatus",1)

     If ScrollKeyStatus  == 1                   // Set Scroll key Status
                Enable(SASKeysScroll)           // text.
                ScrollKeyStatusText = "ON"
        elseif ScrollKeyStatus == 0
                Disable(SASKeysScroll)
                ScrollKeyStatusText = "OFF"
     endif

     SplitType = GetProfileInt(section, "SplitType",1)

     If SplitType == 1
                SplitText = "Horizontal"
        elseif SplitType == 0
                SplitText = "Vertical"
        endif

     maxfiles = GetProfileInt(section, "maxfiles",2)
     minfiles = GetProfileInt(section, "minfiles",1)

     SplitOnLoad = GetProfileInt(section, "SplitOnLoad", 1)

         If SplitOnLoad == 1
                SplitLoadText = "Yes"
                Hook(_ON_FILE_LOAD_, SplitWindows)
        elseif
                SplitOnLoad == 0
                SplitLoadText = "No"
                UnHook(SplitWindows)    // May not be needed
         endif

     MenuType = GetProfileInt(section, "menutype", 1)

         if MenuType == 1

                Disable(SASMenuSingleKeys)
                Enable(SASMenuBarKeys)
                MenuTypeText = "Bar"
           else
                Disable(SASMenuBarKeys)
                Enable(SASMenuSingleKeys)
                MenuTypeText = "Single"
         endif

     ScrollLinesReset = GetProfileInt(section, "scrolllinesreset", 1)

        If ScrollLinesReset == 1
                ScrollLinesResetText = "Yes"

        else
                ScrollLinesResetText = "No"
        endif

     MenuCloseOption = GetProfileInt(section, "menucloseoption", 0)

        if MenuCloseOption == 1
                MenuCloseText = "Yes"
        elseif MenuCloseOption == 0
                MenuCloseText = "No"
        endif
     SaveSetOnExit = GetProfileInt(section, "savesetonexit", 0)

        If SaveSetOnExit == 1
                SaveOnExitText = "Yes"
                Hook(_ON_ABANDON_EDITOR_, SaveIniSettings)
        elseif SaveSetOnExit == 0
                SaveOnExitText = "No"
                UnHook(SaveIniSettings)
        endif

                Message(MName, MVersion, SASMsg29, SaveOnExitText)

      SetMenuFlags()  //Set the menu flags based on startup Options


end ReadIniSettings

/**** SaveConfigFile ******************************************************/

proc SaveIniSettings() // Save current parameters to startup configuration

        WriteProfileStr(section,"version", MVersion)
        WriteProfileStr(section,"build", MBuild)
        WriteProfileStr(section,"date", Mdate)
        WriteProfileInt(section,"menutype", menutype)
        WriteProfileInt(section,"splittype", splittype)
        WriteProfileStr(section,"scrolltype", scrolltype)
        WriteProfileInt(section,"maxscrolllines", maxscrolllines)
        WriteProfileInt(section,"scrollkeystatus", scrollkeystatus)
        WriteProfileInt(section,"ScrollSpeed", ScrollSpeed)
        WriteProfileInt(section,"maxfiles",maxfiles)
        WriteProfileInt(section,"minfiles",minfiles)
        WriteProfileInt(section,"splitonload", splitonload)
        WriteProfileInt(section,"ScrollLinesReset", scrolllinesreset)
        WriteProfileInt(section,"menucloseoption", menucloseoption)
        WriteProfileInt(section,"savesetonexit", savesetonexit)


        Message(MName + MVersion + SASMsg12)

end SaveIniSettings

proc SaveSettingsOnExit()  // Toggle Save Settings on Exit

        If SaveSetOnExit == 1
                SaveSetOnExit = 0
                SaveOnExitText = "No"
                UnHook(SaveIniSettings)
        else
                SaveSetOnExit = 1
                SaveOnExitText = "Yes"
                Hook(_ON_ABANDON_EDITOR_, SaveIniSettings)
        endif

                WriteProfileInt(section,"savesetonexit", savesetonexit) //Save change

                Message(MName, MVersion, SASMsg29, SaveOnExitText)
end




proc NumRead( VAR integer n)    //Reads value for Scroll Speed etc.

    string s[3] = str(n)
        n = iif(Read(s), val(s), n)
    return()

end NumRead

proc MaxNumFileset()    // Sets the maximum number of files to split.

        integer orgmaxfiles
        orgmaxfiles = maxfiles

        Message(MName, MVersion, SASMsg9)


                NumRead(maxfiles)


                if maxfiles > 9 or maxfiles < 1 or maxfiles < minfiles
                        Warn(SASMsg25)
                        maxfiles = orgmaxfiles
                endif

        Message(MName, MVersion, SASMsg10, maxfiles)

end


proc MinNumFilesSet()  // Sets the minimum number of files to split.

        integer orgminfiles
        orgminfiles = minfiles


        Message(MName, MVersion, SASMsg21)

                NumRead(minfiles)

                if minfiles  > maxfiles or minfiles < 1
                        Warn(SASMsg26)
                        minfiles = orgminfiles

                endif

        Message(MName, MVersion, SASMsg19, minfiles)

end

/**** Split Windows Procedures ********************************************/
/**************************************************************************/

proc SplitWindows()     // Split Windows procedure

integer f = NumFiles()  // Initialise f for count

if NumWindows() == 1

   if f > maxfiles
        Message(MName , MVersion , SASMsg2 , maxfiles)
        Return()

        elseif f < minfiles

        Message(MName , MVersion , SASMsg22 , minfiles)
        Return()

  endif

        While f >= minfiles and f <= maxfiles     // Check No Windows

         UpDateDisplay(_ALL_WINDOWS_REFRESH_)   // Update Video

         If SplitType == 1                      // Split Window
                HWindow()
         else
                VWindow()
         endif
         f = f - 1

   endwhile

        if NumWindows() > 2
                WindowResize()
        endif

        else
        OneWindow()                             // UnSplit windows
endif
        GotoWindow(1)

end

proc WindowResize()

        integer wcount

        for wcount = 1 to NumFiles()

        if SplitType == 1

                ResizeWindow(_Up_,(Query(screenrows)/Numfiles()))  // Horizontal

        elseif SplitType == 0

                ResizeWindow(_Left_,(Query(screencols)/NumFiles())) //Vertical
        endif

         UpdateDisplay(_ALL_WINDOWS_REFRESH_)

         NextWindow()

        endfor

end

proc ConfigSplitOnLoad()  // SplitWindows when macro is loaded.

        If SplitOnLoad == 1
                SplitOnLoad = 0
                SplitLoadText = "No"
                UnHook(SplitWindows)
        else
                SplitOnLoad = 1
                SplitLoadText = "Yes"
                Hook(_ON_FILE_LOAD_, SplitWindows)
        endif

                WriteProfileInt(section,"splitonload", splitonload) //Save change

        Message(MName, MVersion, SASMsg11, SplitLoadText)
end

proc ConfigSplitType()  // Set Window Split type, H or V.

        If SplitType == 1
                SplitType = 0
                SplitText = "Vertical"
        else
                SplitType = 1
                SplitText = "Horizontal"
        endif

                Message(MName, MVersion, SASMsg7, SplitText)
end


/**** Scroll Windows Procedures *******************************************/
/**************************************************************************/

proc ScrollTypeSelect(integer ScrollTypeOption)

        if ScrollTypeOption == 1
                ScrollType = "Roll"
           elseif ScrollTypeOption == 2
                ScrollType = "Scroll"
           elseif ScrollTypeOption == 3
                ScrollType = "Page"
        endif

        Message(MName, MVersion, SASMsg13, ScrollType)
end

proc SetScrollLines()

        Message(MName, MVersion, SASMsg15)

                NumRead(MaxScrollLines)
                SetMenuFlags()

        Message(MName, MVersion, SASMsg16, MaxScrollLines)

end

proc SetScrollLinesReset()

        If ScrollLinesReset == 1
                ScrollLinesReset = 0
                ScrollLinesResetText = "No"

        else
                ScrollLinesReset = 1
                ScrollLinesResetText = "Yes"
        endif

        Message(MName, MVersion, SASMsg24, ScrollLinesResetText)
end

proc Scroll(integer DirectFlag)  //0=down, 1=up, 2=right, 3=left,

        if DirectFlag == 1
            if ScrollType == "Roll"
                Rollup()
                elseif ScrollType == "Scroll"
                        ScrollUp()
                        elseif ScrollType == "Page"
                                PageUp()
            endif
            ScrollCheck = Up()

        elseif DirectFlag == 0
            if ScrollType == "Roll"
                RollDown()
                elseif ScrollType == "Scroll"
                        ScrollDown()
                        elseif ScrollType == "Page"
                                PageDown()
            endif
            ScrollCheck = Down()
        endif

        if DirectFlag == 2
            if ScrollType == "Roll"
                RollRight()
                elseif ScrollType == "Scroll"
                        ScrollRight()
                        elseif ScrollType == "Page"
                                Warn(MName + MVersion + SASMsg23)
                                ScrollType = "Scroll"
            endif
            ScrollCheck = Right()

        elseif DirectFlag == 3
            if ScrollType == "Roll"
                RollLeft()
                elseif ScrollType == "Scroll"
                        ScrollLeft()
                        elseif ScrollType == "Page"
                               Warn(MName + MVersion + SASMsg23)
                               ScrollType = "Scroll"

            endif
            ScrollCheck = Left()
        endif

end


proc ScrollAll(integer DirectFlag)    // Scroll Windows down  - Key Scroll
        integer wn, wn1

        wn1 = WindowId()
                Scroll(DirectFlag)
                while TRUE
                        NextWindow()
                        wn = WindowId()
                        if wn == wn1
                                break
                        endif
                Scroll(DirectFlag)
                endwhile

end ScrollAll

/**** AutoScroll Procedures ***********************************************/

proc ScrollSetSpeed()   // Used to set scroll speed for ScrollSpeed()

        Message(MName, MVersion, SASMsg5)

                NumRead(ScrollSpeed)

                if ScrollSpeed > MaxScrollSpeed or ScrollSpeed  < 1
                        ScrollSpeed = 5
                endif

        Message(MName, MVersion, SASMsg6, ScrollSpeed)
end

integer proc ScrollCtrlCheck() //Checks for scroll Abort or Pause
                                //and maxlines reached.


        KeyStr = Keyname (Keypressed() and Getkey())
        MouseStatus()
        if Query(MouseKey) <> 0          // Check for Mousekey to pause scrolling.

                Message(MName , MVersion , SASMsg8 )
                WaitForMouseEvent(_MOUSE_RELEASE_)

                Abort = 0               // Preserve Abort Flag

        elseif KeyStr == "-"

                if ScrollSpeed > 1
                        ScrollSpeed = ScrollSpeed - 1
                        Message(MName + MVersion + SASMsg27 , ScrollSpeed)
                endif

        elseif KeyStr == "+" or KeyStr == "="

                if ScrollSpeed < MaxScrollSpeed
                        ScrollSpeed = ScrollSpeed + 1
                        Message(MName + MVersion + SASMsg27 , ScrollSpeed)
                endif

        elseif KeyStr == "Escape"
                Message(MName , MVersion , SASMsg3 )
                if ScrollLinesReset             // Check reset menu option
                        ScrollLines = 0         //Reset the scrollines counter
                endif
                Abort = 1                       // Set Abort Flag

        elseif MaxScrollLines > 0               // Checks for max lines/pages

                if ScrollLines == MaxScrollLines
                        Message(MName , MVersion , SASMsg14 )
                        ScrollLines = 0         // Reset scrollLines counter
                        Abort = 1               // Set Abort Flag

                else
                        ScrollLines = ScrollLines + 1

                        Message(MName , MVersion , SASMsg17, ScrollLines )
                endif
        endif
        return(Abort)

end

Proc ScrollCurrentAuto(integer DirectFlag)         //Auto Scroll Current Window Up

    Repeat

        if ScrollCtrlCheck()
                Abort = 0   // Resets Abort Flag
                Return()
        endif
                Scroll(DirectFlag)
                Delay(MaxScrollspeed/ScrollSpeed)
                UpdateDisplay(_ALL_WINDOWS_REFRESH_)

     Until not ScrollCheck

end

proc AutoScrollAll(integer DirectFlag)        // Auto Scroll All Windows down

        integer wn, wn1
        wn1 = WindowId()
        Repeat

                Scroll(DirectFlag)

                while TRUE
                        NextWindow()
                        wn = WindowId()
                        if wn == wn1
                           break
                        endif
                        Scroll(DirectFlag)
                endwhile

                if ScrollCtrlCheck()
                        Abort = 0
                        Return()
                endif
                        Delay(MaxScrollSpeed/ScrollSpeed)
                        UpdateDisplay(_ALL_WINDOWS_REFRESH_)

        Until not ScrollCheck

end AutoScrollAll


proc ToggleScrollKeys()         // Set Scroll Keys ON or OFF

        if ScrollKeyStatus == 1

                Disable(SASKeysScroll)
                ScrollKeyStatus = 0
                ScrollKeyStatusText = "OFF"


        elseif ScrollKeyStatus == 0

                Enable(SASKeysScroll)
                ScrollKeyStatus = 1
                ScrollKeyStatusText = "ON"

        endif

        Message(MName , MVersion , SASMsg4 , ScrollKeyStatusText )

end

proc Switchfiles()          // Switch between windows or files.

        if Numwindows() == 1
                NextFile()
        else
                NextWindow()
        endif

end


/**** Define keys, Controls and Menus *************************************/

keydef SASKeysScroll    // Scroll Keys


  <Shift CursorLeft>    ScrollAll(3)
  <Shift CursorRight>   ScrollAll(2)
  <Shift CursorUp>      ScrollAll(1)
  <Shift CursorDown>    ScrollAll(0)
  <Ctrl CursorLeft>     ScrollCurrentAuto(3)
  <Ctrl CursorRight>    ScrollCurrentAuto(2)
  <Ctrl CursorUp>       ScrollCurrentAuto(1)
  <Ctrl CursorDown>     ScrollCurrentAuto(0)
  <CtrlAlt CursorLeft>  AutoScrollAll(3)
  <CtrlAlt CursorRight> AutoScrollAll(2)
  <Ctrl PgUp>           AutoScrollAll(1)
  <Ctrl PgDn>           AutoScrollAll(0)

end

keydef SASKeysControl   // Control Keys


  <CtrlAlt S>            SplitWindows()
  <CtrlAlt H>            ViewDoc(1)
  <CtrlAlt K>            ToggleScrollKeys()
  <CtrlAlt M>            SetMenuType()
  <Shift TAB>            SwitchFiles()
  <Alt N>                SwitchFiles()

end

Keydef SASMenuBarKeys

  <F11>            SASMenuBar()

end

Keydef SASMenuSingleKeys

  <F11>            SASMenu()

end

/**** Define Menus ********************************************************/
/**************************************************************************/

proc SetMenuFlags()    // Sets the Menu Flags

       if MaxScrollLines <> 0          // Set ScrollLinesReset Flag
             SLResetMenuFlag = _MF_DONT_CLOSE_
          else
             SLResetMenuFlag = _MF_GRAYED_
       endif

                                       // Search for help file
        if FileExists(SearchPath (MHlpDocName + MHlpExt, (Query(TSEPath))))
                HlpDocMenuFlag1 = _MF_CLOSE_BEFORE_
           else
                HlpDocMenuFlag1 = _MF_GRAYED_
        endif
                                       // Search for Document file
       if FileExists(SearchPath (MHlpDocName + MDocExt, (Query(TSEPath))))
                HlpDocMenuFlag2 = _MF_CLOSE_BEFORE_
           else
                HlpDocMenuFlag2 = _MF_GRAYED_
        endif

      if MenuCloseOption == 1          //
             MenuCloseFlag = _MF_CLOSE_AFTER_
          else
             MenuCloseFlag = _MF_DONT_CLOSE_
       endif

end


proc SetMenuType()       // Toggle between Bar and Single

        If MenuType == 1
                MenuType = 0
                MenuTypeText = "Single"

                Disable(SASMenuBarKeys)
                Enable(SASMenuSingleKeys)
           else
                MenuType = 1
                MenuTypeText = "Bar"
                Disable(SASMenuSingleKeys)
                Enable(SASMenuBarKeys)
        endif

        SetMenuFlags()

        Message(MName, MVersion, SASMsg18, MenuTypeText)

end

proc SetMenuClose()

        if MenuCloseOption == 1
                MenuCloseOption = 0
                MenuCloseText = "No"
        else
                MenuCloseOption = 1
                MenuCloseText = "Yes"
        endif

        Message(MName, MVersion, SASMsg28, MenuCloseText)

        SetMenuFlags()
end


/**** Define Individual Menus **********************************************/


Menu FileMenu()

  "Sa&ve Current Settings"                       , SaveIniSettings(),,
  "Save the current SAS settings to ini file for startup."
  "Save Settings On &Exit" [SaveOnExitText:3]    , SaveSettingsOnExit(),MenuCloseFlag,
  "Save macro settings at time of exiting the editor"
  "Menu M&ode"  [MenuTypeText:6]                , SetMenuType(),,
  "Set menu type to Bar or Single"
  "Menu &Close" [MenuCloseText:3]               , SetMenuClose(),,
  "Close menu on toggle options"

end

Menu WindowMenu()

  "&Split / Un-Split          <CtrlAlt S>"   , SplitWindows(),,
  "Toggle the splitting of Windows ON or OFF."

  "Split &Type" [SplitText:10]                , ConfigSplitType(), MenuCloseFlag,
  "Toggle between Horizontal or Vertical splitting for windows."
  "Ma&ximum files to split"[Maxfiles:2]       , MaxNumFileset(), _MF_DONT_CLOSE_,
  "Set the maximum number of files to split."
  "&Minimum files to split"[minfiles:2]       , MinNumFilesSet(), _MF_DONT_CLOSE_,
  "Set the minimum number of files to split."
  "Split when &Loaded"[SplitLoadText:3]       , ConfigSplitOnLoad(), MenuCloseFlag,
  "Split windows when macro is Loaded?"
  "Switch Windows/&Files      <Alt N>"        , SwitchFiles(),,
  "Switch between windows or files. (Shift TAB) can also be used."


end

Menu ScrollMenu()

  "Sc&roll Type "[ScrollType:6]                , ScrollTypeMenu(),_MF_DONT_CLOSE_,
  "Set scroll type to roll or scroll."

  "Scroll L&ines/Pages   "[MaxScrollLines:3]  , SetScrollLines(), _MF_DONT_CLOSE_,
  "Set number lines/pages to scroll before stopping.  0 for continuous to EOF."

  "Reset Scroll Lines on Abort" [ScrollLinesResetText:3] , SetScrollLinesReset(), SLResetMenuFlag,
  "Resets the scroll lines counter on user Abort"

end

Menu KeyScrollMenu()  //called by bar and single menu

  "Scroll &up                 <Shift >"      , ScrollAll(1),,
  "Scroll all the windows Up manually."

  "Scroll &down               <Shift >"      , ScrollAll(0),,
  "Scroll all the windows Down manually."

  "Scroll &right              <Shift >"      , ScrollAll(2),,
  "Scroll all the windows to Right manually."

  "Scroll &left               <Shift >"      , ScrollAll(3),,
  "Scroll all the windows to Left manually."


end

Menu AutoScrollMenu()  //called by bar and single menu

  "Set AutoScroll &Speed"[ScrollSpeed:2]      , ScrollSetSpeed(), _MF_DONT_CLOSE_,
  "Adjust the speed of autoscrolling.(slowest = 1)"

  "Current Window U&p         <Ctrl  >"      , ScrollCurrentAuto(1),,
  "AutoScroll the current window up - hands free."

  "Current Window Dow&n       <Ctrl  >"      , ScrollCurrentAuto(0),,
  "AutoScroll the current window down - hands free."

  "Current Window &Right      <Ctrl  >"      , ScrollCurrentAuto(2),,
  "AutoScroll the current window to right - hands free."

  "Current Window &Left       <Ctrl  >"      , ScrollCurrentAuto(3),,
  "AutoScroll the current window to left - hands free."

  "All Windows Up            <Ctrl PgUp>"     , AutoScrollAll(1),,
  "AutoScroll all windows up - hands free."

  "All Windows Down          <Ctrl PgDn>"     , AutoScrollAll(0),,
  "AutoScroll all windows down - hands free."

  "All Windows Right         <Ctrl Alt  >"    , AutoScrollAll(2),,
  "AutoScroll all windows to right - hands free."

  "All Windows Left          <Ctrl Alt  >"    , AutoScrollAll(3),,
  "AutoScroll all windows to left  - hands free."

end

Menu KeyMenu()

  "Scroll &keys <CtrlAlt K>" [ScrollKeyStatusText:3] , ToggleScrollKeys(), MenuCloseFlag,
  "Toggle Scroll Keys ON or OFF."

end

Menu HelpMenu()

  "&Help                      <CtrlAlt H>"    , ViewDoc(1), HlpDocMenuFlag1
  "View Macro &Document"                      , ViewDoc(2), HlpDocMenuFlag2
  "&About" [MName+ MVersion:12]               , About()

end

/**** Define Menu Bar ******************************************************/

MenuBar SASMenuBar()

history

"&File"         , FileMenu()
"&Windows"      , WindowMenu()
"&Scroll"       , ScrollMenu()
"&KeyScroll"    , KeyScrollMenu()
"&AutoScroll"   , AutoScrollMenu()
"Ke&ys"         , KeyMenu()
"&Help"         , HelpMenu()

end

/**** Define Single Menu **************************************************/

Menu SASMenu()         // Single Menu
  Title = "Split And Scroll Menu"
  x = 20
  y = 5
  history

  "Windows",,_MF_DIVIDE_
  "&Split / Un-Split          <CtrlAlt S>"   , SplitWindows(),,
  "Toggle the splitting of Windows ON or OFF."

  "Split &Type" [SplitText:10]                , ConfigSplitType(), MenuCloseFlag,
  "Toggle between Horizontal or Vertical splitting for windows."
  "Ma&ximum files to split"[Maxfiles:2]       , MaxNumFileset(), _MF_DONT_CLOSE_,
  "Set the maximum number of files to split."
  "&Minimum files to split"[minfiles:2]       , MinNumFilesSet(), _MF_DONT_CLOSE_,
  "Set the minimum number of files to split."
  "Split when &Loaded"[SplitLoadText:3]       , ConfigSplitOnLoad(), _MF_DONT_CLOSE_,
  "Split windows when macro is Loaded?"
  "Switch Windows/&Files          <Alt N>"    , SwitchFiles(),,
  "Switch between windows or files. (Shift TAB) can also be used."

  "Scrolling",,_MF_DIVIDE_
  "Sc&roll Type"[ScrollType:6]                , ScrollTypeMenu(),_MF_DONT_CLOSE_,
  "Set scroll type to roll or scroll."

  "Scroll L&ines/Pages   "[MaxScrollLines:3]  , SetScrollLines(), _MF_DONT_CLOSE_,
  "Set number lines/pages to scroll before stopping.  0 for continuous to EOF."

  "Reset Scroll Lines on Abort" [ScrollLinesResetText:3] , SetScrollLinesReset(), SLResetMenuFlag,
  "Resets the scroll lines counter on user Abort"

  "Key Scroll",,_MF_DIVIDE_
  "Ke&y Scroll Options "                        , KeyScrollMenu(), _MF_DONT_CLOSE_,
  "Key Scroll Options Menu"

  "Auto Scroll",,_MF_DIVIDE_
  "A&uto Scroll Options "                       , AutoScrollMenu(), _MF_DONT_CLOSE_,
  "Auto Scroll Options Menu"

  "Keys",,_MF_DIVIDE_
  "Scroll &keys <CtrlAlt K>" [ScrollKeyStatusText:3] , ToggleScrollKeys(), MenuCloseFlag,
  "Toggle Scroll Keys ON or OFF."

  "General",,_MF_DIVIDE_
  "Sa&ve Current Settings"                       , SaveIniSettings(),,
  "Save the current SAS settings to ini file for startup."
  "Save Settings On &Exit" [SaveOnExitText:3]    , SaveSettingsOnExit(),MenuCloseFlag,
  "Save macro settings at time of exiting the editor"
  "Menu M&ode <CtrlAlt M>"  [MenuTypeText:6]                , SetMenuType(),,
  "Set menu type to Bar or Single"

  "&Help                      <CtrlAlt H>"    , ViewDoc(1), HlpDocMenuFlag1
  "&About" [MName+ MVersion+MBuild:12]               , About()

end  /* SASMenu */


Menu ScrollTypeMenu()   // Select Scroll mode.
  Title = "Scroll Type"
  history

  "Roll",ScrollTypeSelect(1),,
  "Set scroll type to RollUp() and RollDown()."
  "Scroll",ScrollTypeSelect(2),,
  "Set scroll type to ScrollUp() and ScrollDown()."
  "Page",ScrollTypeSelect(3),,
  "Set scroll type to PageUp() and PageDown(),"

end

proc Startup()                  // Called by Main and WhenLoaded

        set (Break,ON)          // Remove for release
        ReadIniSettings()       // Load startup parameters from tse.ini

        if SplitOnLoad == 1     // Split on Load?
                SplitWindows()  // Check No of files and split
                Hook(_ON_FILE_LOAD_, SplitWindows)
        endif



        Enable(SASKeysControl)  // Enable the control key assignments

        Message(MName , MVersion , SASMsg1 )

end

/**** MAIN PROCEDURE ******************************************************/
/**************************************************************************/

/*
proc Main()                   // Use either Main() or WhenLoaded()
        Startup()
end
*/

proc WhenLoaded()

        Startup()
end

proc WhenPurged()               // Restore Normal TSE key assignments

        Disable(SASKeysScroll)
        Disable(SASKeysControl)
        UnHook(SplitWindows)

end

