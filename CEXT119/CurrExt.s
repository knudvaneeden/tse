
/*

    CurrExt - Find out the real type of the current file

    See CurrExt.txt for usage.

    v1.1.9 - Jun 19, 2002

    
    Copyright (c) 2002 - Michael Graham <magmac@occamstoothbrush.com>

    This program is Free Software - you may use it, modify it and
    distribute it under the the terms of the Perl Artistic License,
    which you may find at:

          http://www.perl.com/CPAN/doc/misc/license/Artistic

    In particular, note that you use this software at your own risk!

    The latest version of my TSE macros can be found at:

        http://www.occamstoothbrush.com/tsemac/




*/

constant MAX_EXT_LENGTH     = 10
constant MAX_CMD_LINE       = 128
constant MAX_SHBANG_LENGTH  = 35

#ifndef MAX_PATH
#define MAX_PATH 255
#endif

integer Current_Buffer
integer CurrExt_Suspended
integer Always_Check_Shbang_Line
integer Loose_Definition_of_Shbang_Line
integer Return_Actual_Extension_When_Suspended
integer CurrExt_Debug_Mode

string  Current_Extension[MAX_EXT_LENGTH] = ''

string  Shbang_Match_Options[10]         = ''

string  Source_Extension_Cache[255] = ''
string  Target_Extension_Cache[255] = ''
integer Settings_Serial             = 0
integer Force_Refresh_Settings      = 0

#ifndef WIN32
#include ["profile.si"]
#endif

#include ["setcache.si"]
#include ["FindProf.si"]

string proc mCalcCurrExt()
    // Look for extension equivalences:
    string curr_ext[MAX_EXT_LENGTH]    = SplitPath(CurrFilename(), _EXT_)
    string equiv[MAX_EXT_LENGTH]       = ''
    string found_equiv[MAX_EXT_LENGTH] = ''
    string shbang[MAX_SHBANG_LENGTH]   = ''

    curr_ext = curr_ext[2..Length(curr_ext)]

    // Look for Shbang matches first
    if Always_Check_Shbang_Line or curr_ext == ''
        PushPosition()
        BegFile()
        if Loose_Definition_of_Shbang_Line or GetText(1,2) == '#!'
            LoadProfileSection('Shbang_Aliases', FindProfile())

            PushBlock()

            MarkLine(1,1)
            while GetNextProfileItem(shbang, equiv)
                if lFind(shbang, 'lg' + Shbang_Match_Options)
                    found_equiv = trim(equiv)
                    break
                endif
            endwhile

            equiv = found_equiv

            PopBlock()

        endif
        PopPosition()
    endif

    if equiv == ''
        equiv = trim(GetProfileStr('Extension_Aliases',curr_ext,curr_ext,FindProfile()))
    endif

    if equiv <> ''
        equiv = '.' + equiv
    endif

    if CurrExt_Debug_Mode
        Warn("CurrExt: '" + equiv + "' [Filename: " + SplitPath(CurrFilename(),__NAME__|__EXT__) + "]")
    endif

    return(equiv)
end

string proc mCacheCurrExt()
    string curr_ext[MAX_EXT_LENGTH]    = CurrExt()
    string calc_ext[MAX_EXT_LENGTH]    = ""
    integer i

    curr_ext = curr_ext[2..Length(curr_ext)]
    curr_ext = Lower(curr_ext)

    if NeedToReloadSettings(Settings_Serial)
      or Length(Source_Extension_Cache) > 253
      or Length(Target_Extension_Cache) > 253
      or Force_Refresh_Settings
          // Warn("Resetting CurrExt Cache")
          Source_Extension_Cache = ""
          Target_Extension_Cache = ""
          Force_Refresh_Settings = 0
    endif

    if Pos(curr_ext + '|' , Source_Extension_Cache)
        for i = 1 to NumTokens(Source_Extension_Cache, "|")
            // Warn("found '" + GetToken(Source_Extension_Cache, "|", i) + "' as possible match for '"+curr_ext+"' in cache")
            if GetToken(Source_Extension_Cache, "|", i) == curr_ext
                // Warn("matched '" + GetToken(Target_Extension_Cache, "|", i) + "' from '"+curr_ext+"' in cache")
                if CurrExt_Debug_Mode
                    Warn("CurrExt: (from cache) '" + GetToken(Target_Extension_Cache, "|", i) + "' [Filename: " + SplitPath(CurrFilename(),__NAME__|__EXT__) + "]")
                endif
                return(GetToken(Target_Extension_Cache, "|", i))
            endif
        endfor
        // Warn("Something went wrong with the current extension cache - resetting...")
        Source_Extension_Cache = ""
        Target_Extension_Cache = ""
    else
        calc_ext = mCalcCurrExt()
        // Warn("adding '" + calc_ext + "' as match for '"+curr_ext+"' to cache")
        Source_Extension_Cache = Source_Extension_Cache + curr_ext + '|'
        Target_Extension_Cache = Target_Extension_Cache + calc_ext + '|'
    endif

    return(calc_ext)
end

proc RefreshExt ()
    if CurrExt_Suspended
        if Return_Actual_Extension_When_Suspended
            SetGlobalStr('CurrExt',CurrExt())
        else
            SetGlobalStr('CurrExt','')
        endif
    else
        if Current_Buffer <> GetBufferId()
            Current_Buffer    = GetBufferID()
            Current_Extension = mCacheCurrExt()
        endif
        SetGlobalStr('CurrExt', Current_Extension)
    endif
end

proc ForceRefreshExt ()
    if CurrExt_Suspended
        if Return_Actual_Extension_When_Suspended
            SetGlobalStr('CurrExt',CurrExt())
        else
            SetGlobalStr('CurrExt','')
        endif
    else
        Force_Refresh_Settings = 1
        Current_Buffer         = GetBufferID()
        Current_Extension      = mCacheCurrExt()
        SetGlobalStr('CurrExt', Current_Extension)
    endif
end

proc WhenLoaded ()
    Return_Actual_Extension_When_Suspended =
        GetProfileInt('CurrExt','Return_Actual_Extension_When_Suspended', 0, FindProfile())

    Always_Check_Shbang_Line =
        GetProfileInt('CurrExt','Always_Check_Shbang_Line', 0, FindProfile())

    Loose_Definition_of_Shbang_Line =
        GetProfileInt('CurrExt','Loose_Definition_of_Shbang_Line', 0, FindProfile())

    Shbang_Match_Options =
        GetProfileStr('CurrExt','Shbang_Match_Options', 'iw', FindProfile())

    if Lower(Shbang_Match_Options) == 'none'
        Shbang_Match_Options = ''
    endif

    Hook(_ON_CHANGING_FILES_, RefreshExt)
end

proc Main ()
    string cmd[2] = Lower(Query(MacroCmdLine))

	case cmd
    // Get current extension if buffer has changed
    when ""
        RefreshExt()

    // Force fetch of current extension even if buffer hasn't changed
    when "-f"
        ForceRefreshExt()

    // Suspend Macro
    when "-z"
        CurrExt_Suspended = 1

    // Resume Macro
    when "-r"
        CurrExt_Suspended = 0

    // Enter Debug Mode
    when "-d"
        CurrExt_Debug_Mode = 1

    // Normal Mode (Exit Debug Mode)
    when "-n"
        CurrExt_Debug_Mode = 0

    // Show Current Extension
    when "-v"
        ForceRefreshExt()
        Warn("Current Extension: '" + GetGlobalStr('CurrExt'))

    // Hook _ON_CHANGING_FILES_ handler
    when "-h"
        UnHook(RefreshExt)
        Hook(_ON_CHANGING_FILES_, RefreshExt)

    // Unhook _ON_CHANGING_FILES_ handler
    when "-u"
        UnHook(RefreshExt)

    endcase
    return()
end


