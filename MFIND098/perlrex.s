
#include ['mfconst.si']

/*
    perlrex.s

    perlrex.s is a macro for translating from Perl's regular expression
    syntax into TSE's regular expression syntax

    It is designed as a plugin for mfind.s.

    To use this functionality in your own macros, see the PerlRex.si file

*/

#include ['setcache.si']
#include ['findprof.si']

#ifndef WIN32
#include ['profile.si']
#endif

#ifndef MAX_STRING
#define MAX_STRING 255
#endif

#include ['perlrex.si']

integer Settings_Loaded = 0
integer Settings_Serial = 0

proc LoadSettings()
    if (not Settings_Loaded) or NeedToReloadSettings(Settings_Serial)

        Settings_Serial = GetSettingsRefreshSerial()

        Word_Set           = GetProfileStr('perlrex','wordset', Word_Set, FindProfile())

        Settings_Loaded = 1
    endif
end

proc main ()
    string  find_text[MAX_STRING]     = GetGlobalStr('MFind::Find_Text')
    integer find_options              = opts2bits(GetGlobalStr('MFind::Find_Options'))
    string  new_find_text[MAX_STRING] = ''

    integer debug_mode     = FALSE

    if Length(Query(MacroCmdLine))
        find_text    = Query(MacroCmdLine)
        find_options = MF_OPTS_X
        debug_mode   = TRUE
    endif

    if find_options & MF_OPTS_X
        LoadSettings()

        new_find_text = PRex_to_TRex(find_text)

        if debug_mode
            if Length(new_find_text) + Length("from: [] to [] Press <Escape>") < Query(ScreenCols)
                warn("from: " + find_text)
                warn("to: "   + new_find_text)
            else
                warn("from: [" + find_text + "] to [" + new_find_text + "]")
            endif
        else
            SetGlobalStr('MFind::Find_Text', new_find_text)
        endif

    endif
end


