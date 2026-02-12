/////////////////////////////////////////////////////////////////////////////
// SELECT.S
//
// Selector v1.12       Chris Lee (chris@systech.ca)   December 20, 1997
//
// Displays a listbox of files in TSE ring.  Picking a file from the list box
// makes it current in TSE.
//
// Usage:
//      Add select.mac to the autoload list - upon loading TSE, the default
//      settings should give you a small list box bound to the upper right
//      corner of the TSE window (with all currently loaded files listed).
//      You should also see the icon change on the TSE window, with the same
//      icon in the notification area of the taskbar (beside the clock).
//
//      Look at configuration section below for more options
//
// Implementation Notes:
//      Select_Config must be called before anything else
//      Select_Redraw must be called after Select_AddFile or Select_RemoveFile
//      SELECT.DLL must be in current path
//      hopefully the behaviour is the same for Win95 as for NT4
//      Since the selector window doesn't have full access to the messages
//      received by TSE, we poll for selected changes in TSE idle times
//      Not 100% accurate, but it works!
//
//      To speed loading when using the PROJ macro, ensure that PROJ is loaded
//      before Select (PROJ should be above Select in the Autoload list)
//
//
// Configuration:
//     Available options:
//          c_fAlwaysOnTop      -selector stays on top of all windows
//          c_fSingleClick      -a single mouse click selects file
//          c_fNoClose          -selector can't be closed
//          c_fShrinkOnClick    -right mouse click on selector shrinks / expands
//          c_fShowNumFiles     -show number of files in caption bar
//          c_fAutoSize         -auto size height to fit number of files
//          c_fSmallFont        -use smaller font (Arial 8pt)
//          c_fNoSizing         -don't allow sizing (thinner border)
//          c_fNoDragging       -don't allow dragging / moving
//          c_fChangeIcon       -change TSE icon to windows logo
//          c_fAlternateIcon    -use alternate icon (from Semware FTP site)
//          c_fUseTaskBar       -show icon in system area of taskbar
//          c_fCloseTse         -close TSE when selector closed (disable c_fNoClose)
//      ÿ   c_fShrinkTse        -shrink TSE when selector shrunk
//
//      Window Position:
//          c_fPosAbsolute      -open window at given coordinates
//          c_fPosBindLeft      -bind window to left border of TSE
//          c_fPosBinfRight     -bind window to right border of TSE
//
//          c_fPosAsPercent     -all coordinates are percentages of screen
//
//          edit the DisplayText proc to customize what is displayed
//
//          set g_iNumInstances to the number of instances (of the selector)
//          that you want to limit.  A value of zero means unlimited.
//
// Features:
//
//      -incremental search - type first part of file to move there, ENTER/SPC
//       to select, ESC/BKSPC to reset search
//      -clicking on selector with middle mouse button (if you have one!)
//       activates the screen saver
//      -holding CTRL while selecting a file removes it from the ring via QuitFile()
//
// Wish List: (in no particular order)
//      -configurable sorting options (currently based on string1 < string2)
//      -list files off system tray icon for quick access
//
//  Send comments / suggestions to cslee@bc.sympatico.ca (or chris@systech.ca)
//
/////////////////////////////////////////////////////////////////////////////


/////////////////////////////////////////////////////////////////////////////
//
// History
//
// v1.12
//      -add: c_fCloseTse to close TSE when selector closed
//      -add: middle button click on tray icon now shrinks & expands selector
//            and shows it if hidden
//      -add: ability to limit number of instances of TSE with selector window
//      -add: c_fShrinkTse flag to shrink TSE with selector
//
//      -minor cleanup / documentation
//
//      -fix: now unhooks all hooked events on exit
//      -fix: problem where minimized / background TSE would not restore
//      -fix: autosize and shrink now take into account actual caption bar
//            size (via GetSystemMetrics).
//      -fix: autosize wasn't working if files changed while selector shrunk
//      -fix: added QuotePath to EditFile command (thanks to Kyle @ Semware)
//      -fix: moving of selector is now handled properly (moving selector
//            also moves TSE, when bound)
//
//
// v1.11
//      -added c_fUseTaskBar to show icon in task bar.  Right clicking on
//       icon hides / shows selector.  Left click brings TSE to front.
//      -selector window now shrinks to only the title bar
//      -c_fNoDragging now works. (best with c_fPosBindLeft/Right)
//      -fixed crash when loading single new file
//      -fixes to macro
//          -load PROJ before Select for faster loads
//          -ignore changing files event when exiting editor
//          -properly redisplay TSE when only one file loaded
//          -not display filename when single new file created
//      -added c_fAlternateIcon to load nicer TSE icon (from the TSE ftp site)
//
//
// v1.10
//      -major cleanup, added many new features:
//          c_fNoClose
//          c_fAlwaysOnTop
//          c_fSingleClick
//          c_fShrinkOnClick
//          c_fShowNumFiles
//          c_fAutoSize
//          c_fSmallFont
//          c_fNoSizing
//          c_fNoDragging (not fully implemented)
//          c_fChangeIcon
//
//      -added incremental search
//      -selector now stays with current file
//      -selector bound to TSE
//
// v1.00        October 16, 1997
//      -Initial Release
/////////////////////////////////////////////////////////////////////////////



/////////////////////////////////////////////////////////////////////////////
// CONFIGURATION CONFIGURATION CONFIGURATION CONFIGURATION CONFIGURATION
/////////////////////////////////////////////////////////////////////////////

// bitwise or any combination of below options into g_iConfigOptions
constant c_fAlwaysOnTop     = 0x0001    // selector stays above all windows
constant c_fSingleClick     = 0x0002    // single click selects file
constant c_fNoClose         = 0x0004    // don't allow selector to close
constant c_fShrinkOnClick   = 0x0008    // shrink selector on right click
constant c_fShowNumFiles    = 0x0010    // show number of files in caption bar
constant c_fAutoSize        = 0x0020    // adjust height to number of files
constant c_fSmallFont       = 0x0040    // use smaller font
constant c_fNoSizing        = 0x0080    // don't allow user to adjust size
constant c_fNoDragging      = 0x0100    // don't allow user to drag / move
constant c_fMidBtnScrnSvr   = 0x0200    // middle button activates screen saver
constant c_fChangeIcon      = 0x0400    // change TSE icon to Windows logo
constant c_fAlternateIcon   = 0x0800    // change TSE icon (alternate)
constant c_fUseTaskBar      = 0x1000    // use notification icon in taskbar
constant c_fCloseTse        = 0x2000    // close TSE when selector closed
constant c_fShrinkTSE       = 0x4000    // shrink TSE with selector

// choose a single position style (with optional modifier) - for g_iPositionOptions
constant c_fPosBindLeft     = 0x0001    // selector stays with left border of TSE
constant c_fPosBindRight    = 0x0002    // selector stays with right border of TSE
constant c_fPosAbsolute     = 0x0004    // selector floats where you specify

// modifier - all positions are percentages of screen dimensions
constant c_fPosAsPercent    = 0x1000

integer g_iConfigOptions = c_fAlwaysOnTop    |
                           c_fSingleClick    |
                           c_fShrinkOnClick  |
                           c_fShowNumFiles   |
                           c_fAutoSize       |
                           c_fSmallFont      |
                           c_fNoSizing       |
   //                        c_fNoDragging     |
                           c_fMidBtnScrnSvr  |
                           c_fChangeIcon     |
                           c_fAlternateIcon  |
                           c_fUseTaskBar     |
                           c_fCloseTse       |
                           c_fShrinkTSE

integer g_iPositionOptions = c_fPosBindRight

string g_SelectorTitle[ 255 ] = ""        // title of selector window

integer g_iNumInstances = 2

// customize to display filenames however you'd like.
string proc DisplayText( string fileName )
    return( Lower( SplitPath( fileName, _NAME_ | _EXT_ ) ))
end

/////////////////////////////////////////////////////////////////////////////
// END CONFIGURATION  END CONFIGURATION  END CONFIGURATION  END CONFIGURATION
/////////////////////////////////////////////////////////////////////////////



// map DLL exports to TSE procs
dll "select.dll"
    integer proc Select_Config( integer hwndParent,
                                string title:cstrval,
                                integer flags,
                                integer posFlags,
                                integer x,
                                integer top,
                                integer width,
                                integer height,
                                integer instances )

    integer proc Select_Init()
    integer proc Select_AddFile( string file:cstrval,
                                 integer bufId,
                                 integer fFileChanged )
    integer proc Select_RemoveFile( string file:cstrval, integer bufId )
    integer proc Select_OnIdle()
    proc Select_Redraw()
    proc Select_HiliteCurrentFile( string file:cstrval )
    integer proc Select_ExitTSE()
end

dll "<user32.dll>"
    integer proc SetForegroundWindow( integer hwnd )
end

forward proc Cleanup()

proc Sync()
    integer numberOfFiles
    integer redraw

    redraw = 0
    numberOfFiles = NumFiles()

    while numberOfFiles
        if 0 == Select_AddFile( DisplayText( CurrFileName() ), GetBufferId(), FileChanged() )
            redraw = 1
        endif
        NextFile( _DONT_LOAD_ )
        numberOfFiles = numberOfFiles - 1
    endWhile
    if redraw
        Select_Redraw()
    endif
end

proc OnIdle()
    integer bufId
    integer removeFile

    // note: Select_OnIdle returns 0 if no new selections have been made
    //                     returns the buffer id if a selection was made
    //                     returns the negative of the buffer id if file
    //                     is to be removed (QuitFile())
    removeFile = 0
    bufId =  Select_OnIdle()

    if bufId <> 0

        if bufId < 0
            removeFile = 1
            bufId = bufId * -1
        endif

        // don't change to current buffer unless we are removing the file
        // or it is the only file
        if( bufId == GetBufferId() )
            SetForegroundWindow( GetWinHandle() )
        endif

        if( bufId <> GetBufferId() or removeFile or NumFiles() == 1 )
            GotoBufferId( bufId )

            // fix (v1.12) - handle filenames & paths containing spaces
            EditFile( QuotePath(CurrFileName()) )

            ExecHook( _ON_CHANGING_FILES_ )
            UpdateDisplay( _DEFAULT_ )
            SetForegroundWindow( GetWinHandle() )

            if( removeFile )
                QuitFile()
                UpdateDisplay( _DEFAULT_ )
            endif

        endif
    endif

    if Select_ExitTSE()
        Exit()
    endif
end

proc OnFirstEdit()
    Sync()
end

proc OnFileQuit()
    if 1 <> Select_RemoveFile( DisplayText( CurrFileName() ), GetBufferId() )
        warn( "Selector: Unable to remove file: " + CurrFileName() )
    endif
    Select_Redraw()
end

proc OnChangingFiles()
    Select_HiliteCurrentFile( DisplayText( CurrFileName() ))
end

proc OnQuit()
    CleanUp()
end

// release all hooks
proc Cleanup()
    UnHook( OnIdle )
    UnHook( OnFirstEdit )
    UnHook( OnFileQuit )
    UnHook( OnChangingFiles )
    UnHook( OnQuit )
end



proc WhenLoaded()

    if not Select_Config( GetWinHandle(),      // window handle
                   g_SelectorTitle,
                   g_iConfigOptions,    // options
                   g_iPositionOptions,  // position type
                   0,
                   0,
                   80,
                   60,
                   g_iNumInstances )

        return()
    endif

    if not Select_Init()
        warn( "Unable to initialize selector" )
        return()
    endif

    Sync()
    OnChangingFiles()
    SetForegroundWindow( GetWinHandle() )
    Hook( _IDLE_ , OnIdle )
    Hook( _ON_FIRST_EDIT_, OnFirstEdit )
    Hook( _ON_FILE_QUIT_, OnFileQuit )
    Hook( _ON_CHANGING_FILES_, OnChangingFiles )
    Hook( _ON_ABANDON_EDITOR_, OnQuit )
end

proc WhenPurged()
    Cleanup()
end
