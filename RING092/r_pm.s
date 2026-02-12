
/*

    R_PM - a plugin for the Ringlets system which shows
           Perl modules with their module name.

           For instance,

                c:\perl\lib\Foo\Bar.pm

           might appear as:

                [Foo::Bar]


*/


#define MAX_BUFFER_ID_WIDTH 12

#ifndef MAXSTRINGLEN
#define MAXSTRINGLEN 255
#endif

#include ['setcache.si']
#include ['findprof.si']

integer Settings_Loaded                        = 0
integer Settings_Serial                        = 0

string Module_Path[MAXSTRINGLEN] = ''
string Module_Path_Delim[1] = ';'
string Module_Path_Sep[1]   = '\'
integer Force_Load_Files    = 0

proc LoadProfileSettings()
    if (not Settings_Loaded) or NeedToReloadSettings(Settings_Serial)

        Settings_Serial = GetSettingsRefreshSerial()

        Module_Path       = GetProfileStr('ringlets_plugin_pm','module_path',       Module_Path,       FindProfile())
        Module_Path_Delim = GetProfileStr('ringlets_plugin_pm','module_path_delim', Module_Path_Delim, FindProfile())
        Module_Path_Sep   = GetProfileStr('ringlets_plugin_pm','module_path_sep',   Module_Path_Sep,   FindProfile())
        Force_Load_Files  = GetProfileInt('ringlets_plugin_pm','force_load_files',  Force_Load_Files,  FindProfile())

        Settings_Loaded = 1
    endif
end

string proc GetBufferPerlModuleNameCached()
    integer p
    integer s
    string  path_element[MAXSTRINGLEN]

    string  file_name[MAXSTRINGLEN]   = CurrFileName()
    string  module_name[MAXSTRINGLEN] = ''
    integer module_settings_serial    = GetBufferInt('Ringlets::r_pm::settings_serial')

    // Even the CurrExt macro won't help us here, because it
    // would always return .pl.  Thankfully, perl modules
    // *always* end in .pm!


    if CurrExt() <> '.pm'
        return('')
    endif

    if (Settings_Serial <= module_settings_serial) and Length(module_name)
        return(GetBufferStr('Ringlets::r_pm::module_name'))
    endif

    SetBufferInt('Ringlets::r_pm::settings_serial', Settings_Serial)

    // First try to resolve module name based on its filename
    if Length(file_name)
        for p = 1 to NumTokens(Module_Path, Module_Path_Delim)
            path_element = GetToken(Module_Path, Module_Path_Delim, p)

            if Lower(file_name[1:Length(path_element)]) == Lower(path_element)

                // Remove leading module path
                file_name = file_name[Length(path_element) + 2 .. Length(file_name)]

                // Remove drive and extension
                file_name = SplitPath(file_name, _PATH_|_NAME_)

                // Split into path elements, join with '::'

                module_name = ''
                for s = 1 to NumTokens(file_name, Module_Path_Sep)
                    module_name = module_name + GetToken(file_name, Module_Path_Sep, s)
                    if s < NumTokens(file_name, Module_Path_Sep)
                        module_name = module_name + '::'
                    endif
                endfor

                // We're done, so stop searching through the modules path
                break

            endif

        endfor

    endif

    // Next try searching for 'package Foo::Bar;' line
    if not Length(module_name)
        PushPosition()
        if Force_Load_Files and (not (Query(BufferFlags) & _LOADED_))
            // warn('force loading: ' + CurrFileName())
            EditFile(CurrFileName())
        endif
        if lFind('^package[\t ]#{.*}[\t ]@;[\t ]@$', 'xg')
            module_name = GetFoundText(1)
        endif
        PopPosition()
    else
        // warn('no need to search for module when we already know: ' + module_name)
    endif

    if not Length(module_name)
        module_name = SplitPath(file_name, _NAME_)
    endif

    if Length(module_name)
        module_name = '[' + module_name + ']'
    endif

    SetBufferStr('Ringlets::r_pm::module_name', module_name)

    return(module_name)
end

proc Main()
    string cmd[128] = Query(MacroCmdLine)
    string buffer_name[MAXSTRINGLEN] = Query(MacroCmdLine)
    integer temp_ids_buffer   = Val(GetToken(cmd, ' ', 1))
    integer temp_names_buffer = Val(GetToken(cmd, ' ', 2))

    LoadProfileSettings()

    if (temp_ids_buffer)
        repeat
            GotoBufferId(temp_names_buffer)

            if not CurrLineLen()
                GotoBufferId(temp_ids_buffer)
                if GotoBufferId(Val(GetText(1, MAX_BUFFER_ID_WIDTH)))
                    buffer_name = GetBufferPerlModuleNameCached()
                    GotoBufferId(temp_names_buffer)
                    BegLine()
                    InsertText(buffer_name, _OVERWRITE_)
                endif
            endif

            GotoBufferId(temp_names_buffer)
            Down()
            GotoBufferId(temp_ids_buffer)

        until not Down()
    endif
end



