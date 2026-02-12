// QFRestore ¯1,22®
//***********************     SPLIT and SCROLL MACRO     ******************
/**************************************************************************
Macro   : Split and Scroll Windows
Version : See Macro Defaults
Date    : See Macro Defaults
Author  : Alex S Wilson  [ alex.wilson@almac.co.uk ]
Function: See SAS.doc
Operation : See SAS.doc
Version Details: See SAS.doc

/************************ END of MAIN Comment Area ************************/

/**** Set Macro Defaults **************************************************/

string MAuthor[] = "Alex S Wilson  [ alex.wilson@almac.co.uk ]"
string MTitle[30] = "Split and Scroll Macro  "
string MName[8] = "SAS "                // Macro Name
string MVersion [20] = "v2.2 "     // Macro Version
string MDate[10] = "26.06.95 "

/**** Define and Set Constants and Variables ******************************/

integer maxfiles = 2              // Set maximum files to split windows
integer scroll_time = 5           // Intialise Scroll delay time
integer slow_scroll_time = 20     // Set slowest scroll delay time

integer ScrollKeyStatus = 1       // Set Scroll key status 1 = ON
string ScrollKeyStatusText[3] = "ON"

integer SplitType = 1            // Set Split Type, 1 = Horizontal
string SplitText[10] = "Horizontal"

integer Abort = 0                // Set Abort Flag, 0 = No

/**** Define and Set Common Messages *************************************/

String

       SAStext1[] = " : Loaded þ F11 for Menu. ",
       SAStext2[] = " : Too many files to split. SAS Maximum files : ",
       SAStext3[] = " : Auto Scroll stopped by user. ",
       SAStext4[] = " : Scroll Keys : ",
       SAStext5[] = " : Enter Auto Scroll delay setting between 1 and 20.",
       SAStext6[] = " : Scroll Delay setting : ",
       SASText7[] = " : Split Type : ",
       SASText8[] = " : Auto Scroll : PAUSED "


/**** Forward Declarations ************************************************/

forward Menu SASMenu()


/**** Define Help Information  *******************************************/

helpdef SASHelp

  title = "SAS Help"            // The help's caption.
  height = 12
  x = 2                         // Position for help.
  y = 4

/****  Help Text  ****/

"Function:               Description"
"Keys                             "
"-------                 ----------- "
"Windows:"
"Ctrl Alt S              Toggle the Split Windows feature."
"Split Type              The windows may be split Horizontally or Vertically."
"                        This option toggles the setting."
" "
"Scrolling:              Manually controlled scrolling of Windows"
"Shift                  Scroll the text in the windows up simultaneously."
"Shift                  Scroll the text in the windows down simultaneously."
"  "
"AutoScrolling:          Hands Free scrolling of Windows."
"Ctrl                   Auto Scroll the text in the current window up."
"Ctrl                   Auto Scroll the text in the current window down."
"Ctrl PgUp               Auto Scroll the text in all windows up."
"Ctrl PgDn               Auto Scroll the text in all windows down."
" "
"Set AutoScroll Delay    Controls the speed of autoscrolling."
"                        The current setting is displayed in the menu."
"                        Changes are applicable to current editing session."
" "
"Scroll Keys             The keys assigned for scrolling may be toggled ON"
"                        or OFF. I have included this because Ctrl PgUp and"
"                        Ctrl PgDn have other useful standard file"
"                        navigation functions in TSE. The current status"
"                        of the keys is displayed in the menu."
" "
"Ctrl Alt H              Provides this help screen."
"  "
"About                   Tells you what you are using and how to contact me."
" "
"Other keys: "
" "
"Esc                     Stop AutoScrolling. (not available from Menu)"
" "
"Mouse Buttons           Pressing a mouse button when AutoScrolling will"
"                        pause the scrolling. While paused, pressing the"
"                        other mouse button will scroll the windows one"
"                        line at a time."
" "
"Menu items displaying [ ] show the current status for that option."
""
end


/**** Define About Window  ***********************************************/

proc About()

    PopWinOpen(15,3,65,12, 4, "About", Color(BRIGHT White ON White))
    Set(Attr, Color(BRIGHT White ON White))
    ClrScr()
    Writeline('')
    Writeline('             ',MTitle )
    Writeline('               ', MName , MVersion,'- ', MDate )
    Writeline('')
    Set(Attr, Color(Blue on White))
    Writeline(' Thank you for using the ', Mtitle)
    Set(Attr, Color(BRIGHT White on White))
    Writeline('')
    Writeline('    ',MAuthor)
    Writeline('')
    Set(Attr, Color(Black ON White))
    Write ('                 ','Press any key .. ')
    GetKey()
    PopWinClose()

 end


/****   Split Windows Procedures  *****************************************/
/**************************************************************************/

proc SplitWindows()     // Split Windows procedure

integer n = NumFiles()  // Initialise n for count

if NumWindows() == 1

   if n > maxfiles
        Message(MName , MVersion , SAStext2 , maxfiles)
        Return()
   endif

        While n > 1 & n <= maxfiles             // Check No Windows

         UpDateDisplay(_ALL_WINDOWS_REFRESH_)   // Update Video

         If SplitType == 1                      // Split Window
                HWindow()
         else
                VWindow()
         endif
         n = n - 1

   endwhile

        else
        OneWindow()                             // UnSplit windows

endif
        GotoWindow(1)

end


proc ConfigSplitType()  // Set Window Split type, H or V.


        If SplitType == 1
                SplitType = 0
                SplitText = "Vertical"
        else
                SplitType = 1
                SplitText = "Horizontal"
        endif

                Message(MName, MVersion, SAStext7, SplitText)
end

/****   Scroll Windows Procedures    **************************************/
/**************************************************************************/



proc ScrollAllDown()    // Scroll Windows down  - Key Scroll
        integer wn, wn1
        wn1 = WindowId()
                RollDown()
                while TRUE
                        NextWindow()
                        wn = WindowId()
                        if wn == wn1
                                break
                        endif
                RollDown()
                endwhile
end ScrollAllDown


proc ScrollAllUp()      // Scroll windows up  - Key Scroll

        integer wn, wn1
        wn1 = WindowId()
        RollUp()
        while TRUE
                NextWindow()
                wn = WindowId()
                if wn == wn1
                        break
                endif
                RollUp()
        endwhile
end ScrollAllUp

/**** AutoScroll Procedures ***********************************************/

proc NumRead( VAR integer n)    //Reads value for Scroll Delay etc.
    string s[2] = str(n)

    n = iif(Read(s), val(s), n)
    return()

end NumRead


proc ScrollSetDelay()   // Used to set scroll speed for ScrollDelay()

        Message(MName, MVersion, SAStext5)

                NumRead(scroll_time)

                if scroll_time > slow_scroll_time or scroll_time  < 1
                        scroll_time = 5
                endif

        Message(MName, MVersion, SASText6, Scroll_time)
end


proc ScrollDelay()      // Controls speed of scrolling

        Delay(scroll_time)

end

integer proc ScrollAbortCheck() //Checks for scroll Abort or Pause

        MouseStatus()
        if Query(MouseKey) <> 0
                GetKey()
                Message(MName , MVersion , SAStext8 )
                WaitForMouseEvent(_MOUSE_RELEASE_)
                Abort = 0       // Preserve Abort Flag

        elseif Keypressed() and Getkey() == <Escape>
                Message(MName , MVersion , SAStext3 )
                Abort = 1       // Set Abort Flag

        endif

end


Proc ScrollCurrUpAuto()         //Auto Scroll Current Window Up

    Repeat

        if ScrollAbortCheck()
                Abort = 0   // Resets Abort Flag
                Return()
        endif
                RollUp()
                ScrollDelay()
                UpdateDisplay(_ALL_WINDOWS_REFRESH_)
     Until not Up()

end

Proc ScrollCurrDownAuto()       //Auto Scroll Current Window Down

     Repeat

         if ScrollAbortCheck()
                Abort = 0
                Return()
         endif
                RollDown()
                ScrollDelay()
                UpdateDisplay(_ALL_WINDOWS_REFRESH_)

     Until not Down()

end


proc AutoScrollAllDown()        // Auto Scroll All Windows down
        integer wn, wn1
        wn1 = WindowId()
        EndWindow()
        RollDown()
                Repeat
                while TRUE
                        NextWindow()
                        wn = WindowId()
                        if wn == wn1
                           break
                        endif
                        RollDown()
                endwhile

        if ScrollAbortCheck()
                Abort = 0
                Return()
        endif
                ScrollDelay()
                UpdateDisplay(_ALL_WINDOWS_REFRESH_)

        Until not Down()

end AutoScrollAllDown


proc AutoScrollAllUp()          // Auto Scroll All Windows UP
        integer wn, wn1
        wn1 = WindowId()
                BegWindow()
                RollUp()
                        Repeat

                        while TRUE
                                NextWindow()
                                wn = WindowId()
                                if wn == wn1
                                        break
                                endif
                                RollUp()
                        endwhile

                if ScrollAbortCheck()
                        Abort = 0
                Return()
        endif
                ScrollDelay()
                UpdateDisplay(_ALL_WINDOWS_REFRESH_)

        Until not Up()

end AutoScrollAllUp


/**** Define keys, Controls and Menus *************************************/


keydef SASKeysScroll                        // Scroll Keys

  <Shift CursorDown>    ScrollAllDown()
  <Shift CursorUp>      ScrollAllUp()
  <Ctrl CursorDown>     ScrollCurrDownAuto()
  <Ctrl CursorUp>       ScrollCurrUpAuto()
  <Ctrl PgDn>           AutoScrollAllDown()
  <Ctrl PgUp>           AutoScrollAllUp()

end

keydef SASKeysControl                       // Control Keys

<CtrlAlt S>            SplitWindows()
<CtrlAlt H>            QuickHelp(SASHelp)
<F11>                  SASMenu()

end


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

                Message(MName , MVersion , SAStext4 , ScrollKeyStatusText )

end


/**** Define SAS menu *****/

Menu SASMenu()
  Title = "Split And Scroll Menu"
  x = 20
  y = 3
  history

  "Windows",,Divide
  "&Split / Un-Split          <CtrlAlt S>"    , SplitWindows(),,
  "Toggle the splitting of Windows ON or OFF."

  "Split &Type" [SplitText:10]                , ConfigSplitType(), DontClose,
  "Toggle between Horizontal or Vertical splitting for windows."

  "Key Scroll",,Divide
  "Scroll &up                 <Shift >"      , ScrollAllUp(),,
  "Scroll all the windows Up manually."

  "Scroll &down               <Shift >"      , ScrollAllDown(),,
  "Scroll all the windows Down manually."

  "Auto Scroll",,Divide
  "Current Window U&p         <Ctrl  >"      , ScrollCurrUpAuto(),,
  "AutoScroll the current window up - hands free."

  "Current Window Dow&n       <Ctrl  >"      , ScrollCurrDownAuto(),,
  "AutoScroll the current window down - hands free."

  "A&ll Windows Up            <Ctrl PgUp>"    , AutoScrollAllUp(),,
  "AutoScroll all windows up - hands free."

  "All &Windows Down          <Ctrl PgDn>"    , AutoScrollAllDown(),,
  "AutoScroll all windows down - hands free."

  "Set AutoScroll Dela&y"[scroll_time:2]      , ScrollSetDelay(), DontClose,
  "Adjust the speed of autoscrolling."

  "Keys",,Divide
  "Scroll &keys" [ScrollKeyStatusText:3] , ToggleScrollKeys(), DontClose,
  "Toggle Scroll Keys ON or OFF."

  "General",,Divide
  "&Help                      <CtrlAlt H>"    , QuickHelp(SASHelp)
  "&About" [MName+ MVersion:10]               , About()
end  /* SASMenu */


/**** MAIN PROCEDURE ******************************************************/
/**************************************************************************/

proc main()
        set (Break,ON)   // Remove for release

        SplitWindows()
        Enable(SASKeysControl)
        Enable(SASKeysScroll)
        Message(MName , MVersion , SAStext1 )

end
