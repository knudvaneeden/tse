//// HSK Read-Only Status Line macros
////
//// Written by:  Howard Kapustein
////
//// Description: Read-Only Status Line macros by Howard Kapustein.
////
//// Recommended key bindings:  <CenterCursor>  mHskListOpenFiles()
////
//// Last Update:
////    02/22/95 10:41 pm HSK0  Created (1.0)
////
//// Credits:
////    HSK Status Line is based on a status line replacement macro by
////        Ray Asbury (great educational reading, thanks Ray), plus
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
// Global Variables
integer StatusLineIsEnabled     = FALSE
integer ReadOnlyTrackingBufferId
string  StatusLine_WorkBuffer[255]
string  StatusLineFilename[255]
integer Setting_ShortFilename   = FALSE
integer Setting_Attributes      = TRUE
integer Setting_CharAtCursor    = FALSE
////
// mHook_SaveFileAttributeInfo() - Hook function, Save file attributes when file is loaded
proc mHook_SaveFileAttributeInfo()

    // Local variable(s)
    Integer Attributes,
            SaveBufferId

    // Only save file info for 'normal' buffers
    if BufferType() <> _NORMAL_
        return()
    endif

    // Get the file's attributes
    if FindFirst( CurrFilename(), ffblk, ffALLNV )

        // File found, get the attributes
        Attributes = ffAttr( ffblk )

    else

        // File not found, assume no attributes
        Attributes = 0

    endif

    // Build the search pattern (in the 'work buffer')
    StatusLine_WorkBuffer = Format( ":HK:", CurrFilename(), ":HK:" )

    // Save the current buffer id
    SaveBufferId = GetBufferId()

    // Goto the 'tracking buffer'
    GotoBufferId( ReadOnlyTrackingBufferId )

    // Find the filename's info (if it already exists)
    if lFind( StatusLine_WorkBuffer, "GI" )

        // Found it! Remove the entry
        KillLine()

    endif

    // Restore our original location
    GotoBufferId( SaveBufferId )

    // Add the info
    InsertLine( Format( Attributes:4:"0":16,
                        " :HK:",
                        CurrFilename(),
                        ":HK:" ),
                ReadOnlyTrackingBufferId )

end
////
// mHook_DeleteFileAttributeInfo() - Hook function, Delete file attributes when file is unloaded
proc mHook_DeleteFileAttributeInfo()

    // Local variable(s)
    Integer SaveBufferId

    // Build the search pattern (in the 'work buffer')
    StatusLine_WorkBuffer = Format( ":HK:", CurrFilename(), ":HK:" )

    // Save the current buffer id
    SaveBufferId = GetBufferId()

    // Goto the 'tracking buffer'
    GotoBufferId( ReadOnlyTrackingBufferId )

    // Find the filename's info (if it already exists)
    if lFind( StatusLine_WorkBuffer, "GI" )

        // Found it! Delete the entry
        KillLine()

    endif

    // Restore our original location
    GotoBufferId( SaveBufferId )

end
////
// mGetCurrentFileAttributes() - Get the attributes for the current filename
integer proc mGetCurrentFileAttributes()

    // Local variable(s)
    Integer SaveBufferId,
            Attributes

    // Build the search pattern (in the 'work buffer')
    StatusLine_WorkBuffer = Format( ":HK:", CurrFilename(), ":HK:" )

    // Save the current buffer id
    SaveBufferId = GetBufferId()

    // Goto the 'tracking buffer'
    GotoBufferId( ReadOnlyTrackingBufferId )

    // Find the filename's info (if it already exists)
    if lFind( StatusLine_WorkBuffer, "GI" )

        // Found it! Grab the attributes
        Attributes = Val( GetText( 1, 5 ), 16 )

    else

        // Not found! Update the 'tracking buffer'
        //
        // NOTE: This should never occur, but if it does we'll just update
        //       the 'tracking buffer' right now. Please let me know if
        //       this happens and how to reproduce. Thanks... - HSK0
        Warn( "HSK StatusLine: Failed in mGetCurrentFileAttributes()" )
        mHook_SaveFileAttributeInfo()
        Attributes = 0

    endif

    // Restore our original location
    GotoBufferId( SaveBufferId )

    // Done
    return( Attributes )

end
////
// mBuildStatusLineFilename() - Build the filename to display on the status line
integer proc mBuildStatusLineFilename()

    // Local variable(s)
    integer Start

    // Determine the maximum length of the filename display
    integer MaxLength = Query( ScreenCols ) - 35
    if Setting_Attributes
        MaxLength = MaxLength - 4
    endif
    if Setting_CharAtCursor
        MaxLength = MaxLength - 8
    endif
    if Setting_Attributes AND Setting_CharAtCursor
        MaxLength = MaxLength - 1
    endif

    // Get the current filename
    StatusLineFilename = CurrFilename()

    // If we're not supposed to shorten it we're done
    if NOT Setting_ShortFilename
        return( FALSE )
    endif

    // If it fits we're done
    if ( Length( StatusLineFilename ) <= MaxLength )
        return( FALSE )
    endif

    // Shorten the filename for display
    StatusLine_WorkBuffer = StatusLineFilename
    StatusLineFilename = Format( SubStr( StatusLineFilename, 1, 3 ), "...\" )
    StatusLine_WorkBuffer = SubStr( StatusLine_WorkBuffer,
                                    4,
                                    (Length(StatusLine_WorkBuffer) - 3) )
    while Length(StatusLine_WorkBuffer) > ( maxLength - 7 )
        Start = Pos( "\", StatusLine_WorkBuffer )
        StatusLine_WorkBuffer = SubStr( StatusLine_WorkBuffer,
                                        ( Start + 1 ),
                                        ( Length(StatusLine_WorkBuffer) - Start ) )
    endwhile
    StatusLineFilename = Format( StatusLineFilename,
                                 StatusLine_WorkBuffer:-(MaxLength - 7):Chr(Query(StatusLineFillChar)) )

    // Done (it had to be shortened)
    return( TRUE )

end
////
// mHook_HskStatusLine() - Hook function, Display the status line
proc mHook_HskStatusLine()

    // Locale variables
    string StatusLineInfo[15] = ""
    integer SaveAttribute = Set( Attr, Query(StatusLineAttr) ),
            StatusLineRow = iif( Query(StatusLineAtTop), 1, Query(ScreenRows) ),
            Attrib,
            CharAtCursor

    // WARNING: Don't display our status line if the buffer's not 'Normal'!
    //
    // Problem 1: While active (w/full info), invoke a macro that
    //            performs its own display via Put..() and if we're
    //            called we could overwrite their own display. To
    //            reproduce, load/execute this macro followed by
    //            FL.S (by Richard Blackburn), which paints the
    //            entire display including the status line.
    //            Non-'Normal' buffers are typically used by macros.
    //
    // Problem 2: Same case, but mGetCurrentFileAttributes() tries
    //            to find the info for the current buffer which
    //            doesn't exist in the 'tracking buffer'.
    //
    // Solution: We're only active during 'Normal' buffers. Not perfect,
    //           but the best I can think of. Do you have a better idea?
    //
    if BufferType() <> _NORMAL_
        return()
    endif

    // Get the file attributes
    if Setting_Attributes

        // Setup the attribute display info
        Attrib = mGetCurrentFileAttributes()
        StatusLineInfo = StatusLineInfo + iif( Attrib & _READONLY_, "R", Chr( Query(StatusLineFillChar) ) )
        StatusLineInfo = StatusLineInfo + iif( Attrib & _ARCHIVE_,  "A", Chr( Query(StatusLineFillChar) ) )
        StatusLineInfo = StatusLineInfo + iif( Attrib & _SYSTEM_,   "S", Chr( Query(StatusLineFillChar) ) )
        StatusLineInfo = StatusLineInfo + iif( Attrib & _HIDDEN_,   "H", Chr( Query(StatusLineFillChar) ) )
        if Setting_CharAtCursor
            StatusLineInfo = StatusLineInfo + Chr( Query(StatusLineFillChar) )
        endif

    endif

    // Get character at cursor (if necessary)
    if Setting_CharAtCursor
        CharAtCursor = CurrChar()
        if ( CharAtCursor < 0 )
            StatusLineInfo = Format( StatusLineInfo,
                                     Chr( Query( StatusLineFillChar ) ),
                                     '<EOL>':-7:Chr( Query( StatusLineFillChar ) ) )
        else
            StatusLineInfo = Format( StatusLineInfo,
                                     Str( CharAtCursor, 16 ):2,
                                     'h,',
                                     CharAtCursor:3,
                                     'd' )
        endif
    endif

    // Display the filename (if necessary)
    mBuildStatusLineFilename()
    VGotoXY( 35, StatusLineRow )
    PutStr( StatusLineFilename )

    // Display the Attribute/Char@Cursor info (if necessary)
    if Setting_Attributes OR Setting_CharAtCursor
        VGotoXY( Query( ScreenCols ) - Length( StatusLineInfo ),
                 StatusLineRow )
        PutStr( StatusLineInfo )
    endif

    // Restore the (color/display) attribute
    Set( Attr, SaveAttribute )

end
////
// WhenLoaded_StatusLine() - Initial setup when the macro is loaded
proc WhenLoaded_StatusLine()

    // Local variable(s)
    integer SaveBufferId,
            StartWindowId

    // Do nothing if we're enabled
    if StatusLineIsEnabled
        return()
    endif

    // Save the current buffer id
    SaveBufferId = GetBufferId()

    // Create the 'Tracking Buffer'
    ReadOnlyTrackingBufferId = CreateTempBuffer()
    if NOT ReadOnlyTrackingBufferId
        Warn( "HSK StatusLine: Could not create tracking buffer, aborting...")
        GotoBufferId( SaveBufferId )
        PurgeMacro( CurrMacroFilename() )
        return()
    endif

    // Restore our original location
    GotoBufferId( SaveBufferId )

    // Setup the hook(s) to:
    //   - Detect/watch file load/unload
    //   - Display the status line
    if NOT Hook( _ON_FIRST_EDIT_, mHook_SaveFileAttributeInfo ) OR
       NOT Hook( _ON_FILE_SAVE_,  mHook_SaveFileAttributeInfo ) OR
       NOT Hook( _ON_FILE_QUIT_,  mHook_DeleteFileAttributeInfo ) OR
       NOT Hook( _AFTER_UPDATE_STATUSLINE_, mHook_HskStatusLine )
        Warn( "HSK StatusLine: Could not initialize hooks, aborting...")
        GotoBufferId( SaveBufferId )
        AbandonFile( ReadOnlyTrackingBufferId )
        PurgeMacro( CurrMacroFilename() )
        return()
    endif

//***SEEME***
    // Done...almost...
    //
    // Loading this macro hasn't done anything that would invoke
    // the 'Save...' hook so the display won't show any attributes
    // for buffers in windows currently displayed (if the 'display
    // attributes' setting is enabled, or if it's currently off
    // but is set on immediately after this macro is loaded).
    //
    // We'll 'fix' this by explicitly calling the 'Save...' hook right now...
    StartWindowId = WindowId()
    repeat

        // Update the info in the 'tracking buffer'
        // (Call the 'Save...' hook function to do the work)
        mHook_SaveFileAttributeInfo()

        // Advance to the next window
        NextWindow()

    until WindowId() == StartWindowId

    // Set the 'Enabled' flag
    StatusLineIsEnabled = TRUE

end
//
// WhenPurged_StatusLine() - Cleanup when the macro is purged
proc WhenPurged_StatusLine()

    // Do nothing if we're not enabled
    if NOT StatusLineIsEnabled
        return()
    endif

    // Remove the hook to display the status line
    UnHook( mHook_HskStatusLine )

    // Remove the hook(s) to detect/watch file load/unload
    UnHook( mHook_SaveFileAttributeInfo   )
    UnHook( mHook_DeleteFileAttributeInfo )

    // Blow away the 'tracking buffer'
    AbandonFile( ReadOnlyTrackingBufferId )

    // Clear the 'Enabled' flag
    StatusLineIsEnabled = FALSE

end
//
// mToggle_StatusLineIsEnabled() - Toggle the status line
proc mToggle_StatusLineIsEnabled()

    // 'Load' or 'Purge' the Status Line
    if StatusLineIsEnabled
        WhenPurged_StatusLine()
    else
        WhenLoaded_StatusLine()
    endif

end
//
// mToggle_Setting_ShortFilename() - Toggle this setting
proc mToggle_Setting_ShortFilename()
    Setting_ShortFilename = NOT Setting_ShortFilename
    Set( StatusLineFillChar, Query(StatusLineFillChar) )
end
//
//
// mRefreshFileInfo_Single() - Refresh info for the current buffer
proc mRefreshFileInfo_Current()

    // Is there a 'tracking buffer' to refresh?
    if NOT StatusLineIsEnabled
        Warn( "HSK StatusLine: Not enabled" )
        return()
    endif

    // Call the 'Save...' hook function
    mHook_SaveFileAttributeInfo()

end
//
// mRefreshFileInfo_All() - Refresh info for all files
proc mRefreshFileInfo_All()

    // Local variable(s)
    Integer StartBufferId

    // Is there a 'tracking buffer' to refresh?
    if NOT StatusLineIsEnabled
        Warn( "HSK StatusLine: Not enabled" )
        return()
    endif

    // Save the current buffer id
    StartBufferId = GetBufferId()

    // Update all buffers
    repeat

        // Update the info in the 'tracking buffer'
        // (Call the 'Save...' hook function to do the work)
        mHook_SaveFileAttributeInfo()

        // Advance to the next buffer
        NextFile( _DONT_LOAD_ )

    until GetBufferId() == StartBufferId

    // Call the 'Save...' hook function
    mHook_SaveFileAttributeInfo()

end
//
// mToggle_Setting_Attributes() - Toggle this setting
proc mToggle_Setting_Attributes()
    Setting_Attributes = NOT Setting_Attributes
    Set( StatusLineFillChar, Query(StatusLineFillChar) )
end
//
//
// mToggle_Setting_CharAtCursor() - Toggle this setting
proc mToggle_Setting_CharAtCursor()
    Setting_CharAtCursor = NOT Setting_CharAtCursor
    Set( StatusLineFillChar, Query(StatusLineFillChar) )
end
//
// mViewTrackingBuffer() - Debugging macro
proc mViewTrackingBuffer()

    // Local variable(s)
    Integer SaveBufferId

    // Is there a 'tracking buffer' to view?
    if NOT StatusLineIsEnabled
        Warn( "HSK StatusLine: Not enabled, no 'tracking buffer' to view" )
        return()
    endif

    // Save the current buffer id
    SaveBufferId = GetBufferId()

    // Goto the 'tracking buffer'
    GotoBufferId( ReadOnlyTrackingBufferId )

    // Save the current position
    PushPosition()

    // Display the 'tracking buffer' contents
    List( "ReadOnly Status Line - Internal Tracking Buffer", Query(ScreenCols) )

    // Restore the current position
    PopPosition()

    // Restore our original location
    GotoBufferId( SaveBufferId )

end
//
// HskStatusLineMenu() - Display a menu of options
Menu mHskStatusLineMenu()
    History
    Title = 'HSK Status Line Menu'

    "&Status Line"     [OnOffStr( StatusLineIsEnabled ):3]   , mToggle_StatusLineIsEnabled()   , DontClose
    "&Refresh Current Info"             , mRefreshFileInfo_Current()
    "Refresh &All Info"                 , mRefreshFileInfo_All()
    "Options" , , Divide
    "Short Path&name"  [OnOffStr( Setting_ShortFilename ):3] , mToggle_Setting_ShortFilename() , DontClose
    "&File Attributes" [OnOffStr( Setting_Attributes ):3]    , mToggle_Setting_Attributes()    , DontClose
    "&Char at Cursor"  [OnOffStr( Setting_CharAtCursor ):3]  , mToggle_Setting_CharAtCursor()  , DontClose
    "" , , Divide
    "&View Tracking Buffer"             , mViewTrackingBuffer()
end
