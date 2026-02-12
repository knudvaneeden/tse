//// HSK Read-Only macros - Message At Load
////
//// Written by:  Howard Kapustein
////
//// Description: Message at File Load for Read-Only macros by Howard Kapustein.
////
//// Recommended key bindings:  N/A
////
//// Last Update:
////    02/22/95 10:41 pm HSK0  Created (1.0)
////
//// Credits:
////    mMessageIfReadOnly() is based on TSE Jr. 2.x and 3.x behavior
////        when loading a read-only file, plus some encouragement
////        by Mike Brocious.
////
////
//// Permission is granted to SemWare to modify and distribute
//// this macro set with the SemWare Editor product.
////
//// Howard Kapustein, February 22, 1995
////
////
////
// Constants - Display
constant READONLY_DISPLAY_NOTHING = 0
constant READONLY_DISPLAY_MESSAGE = 1
constant READONLY_DISPLAY_WARNING = 2
////
// Global Variables
integer Setting_Alarm   = TRUE
integer Setting_Display = READONLY_DISPLAY_MESSAGE
////
// mMessageIfReadOnly() - Hook function, Display a message if the file is Read-Only
proc mMessageIfReadOnly()

    // Display the message?
    if Setting_Display <> READONLY_DISPLAY_NOTHING

        // Is the file marked as Read-Only?
        if FindFirst( CurrFilename(), ffblk, ffALLNV ) AND
           ( ffAttr(ffblk) & ffRDONLY )

            // Sound the alarm?
            if Setting_Alarm
                Alarm()
            endif

            // Display the message (w/optional pause)
            case Setting_Display
                when READONLY_DISPLAY_MESSAGE
                    Message( "File is READONLY" )
                when READONLY_DISPLAY_WARNING
                    Warn( "File is READONLY" )
                otherwise
                    Warn( "HSK Message If ReadOnly - Internal Error!" )
            endcase

        endif
    endif

end mMessageIfReadOnly
//
// WhenLoaded_MessageIfReadOnly() - Initial setup when the macro is loaded
proc WhenLoaded_MessageIfReadOnly()

    // Setup the hook to display the warning when the file's first viewed
    Hook( _ON_FIRST_EDIT_, mMessageIfReadOnly )

end
//
// WhenPurged_MessageIfReadOnly() - Cleanup when the macro is purged
proc WhenPurged_MessageIfReadOnly()

    // Remove the hook to display the warning when the file's first viewed
    UnHook( mMessageIfReadOnly )

end
//
//
proc mToggle_Setting_Alarm()
    Setting_Alarm = NOT Setting_Alarm
end
//
//
string proc DisplayLevelStr()
    case Setting_Display
        when READONLY_DISPLAY_NOTHING
            return( "Nothing" )
        when READONLY_DISPLAY_MESSAGE
            return( "Message" )
        when READONLY_DISPLAY_WARNING
            return( "Warning" )
    endcase
    return( "***ERROR***" )
end
//
//
proc mToggle_Setting_Display()
    case Setting_Display
        when READONLY_DISPLAY_NOTHING
            Setting_Display = READONLY_DISPLAY_MESSAGE
        when READONLY_DISPLAY_MESSAGE
            Setting_Display = READONLY_DISPLAY_WARNING
        when READONLY_DISPLAY_WARNING
            Setting_Display = READONLY_DISPLAY_NOTHING
    endcase
end
//
//
// mHskMessageIfReadOnlyMenu() - Display a menu of options
Menu mHskMessageIfReadOnlyMenu()
    History
    Title = 'Message If ReadOnly Menu'

    "&Alarm"   [OnOffStr( Setting_Alarm ):3] , mToggle_Setting_Alarm()   , DontClose
    "&Display" [DisplayLevelStr():7]         , mToggle_Setting_Display() , DontClose
end
