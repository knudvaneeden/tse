
/*


    PerlMod - TSE Support for Perl modules (view module docs, edit modules by name)

    See PerlMod.txt for usage.

    v0.9.3 - Jun 19, 2002

    
    Copyright (c) 2002 - Michael Graham <magmac@occamstoothbrush.com>

    This program is Free Software - you may use it, modify it and
    distribute it under the the terms of the Perl Artistic License,
    which you may find at:

          http://www.perl.com/CPAN/doc/misc/license/Artistic

    In particular, note that you use this software at your own risk!

    The latest version of my TSE macros can be found at:

        http://www.occamstoothbrush.com/tsemac/



*/


#ifndef MAXSTRINGLEN
#define MAXSTRINGLEN 255
#endif

#ifndef MAXPATH
#ifdef _MAXPATH_
#define MAXPATH _MAXPATH_
#else
#define MAXPATH MAXSTRINGLEN
#endif
#endif

constant ARGSTYLE_NAME         = 1
constant ARGSTYLE_NAME_SLASHES = 2
constant ARGSTYLE_FILENAME     = 3

integer Perlmod_History = 0
string Ask_Edit_Prompt[] = 'Edit Module'
string Ask_View_Prompt[] = 'View POD for Module'

string Default_View_Cmd_Format[] = 'start http://perldoc.com/cpan/$s.html'

string View_Cmd_Format[MAXPATH] = ''

string Module_Search_Path[MAXSTRINGLEN]       = ''
string Devel_Module_Search_Path[MAXSTRINGLEN] = ''

integer Settings_Loaded                       = 0
integer Settings_Serial                       = 0

integer View_Cmd_DOS_Flags = 0
string Default_DOS_Flags[] = '_DONT_CLEAR_|_RUN_DETACHED_|_START_HIDDEN_'

#ifndef WIN32
#include ["profile.si"]
#endif

#include ["findprof.si"]
#include ['setcache.si']

string proc AskForName(string text, string name)
    string n[MAXSTRINGLEN] = name
    if not Perlmod_History
        Perlmod_History = GetFreeHistory("perlmod:ask")
    endif
    if Ask(text, n, Perlmod_History)
        return(n)
    endif
    return('')
end

string proc GetNameAtCursor()
    string name[MAXSTRINGLEN] = ''

    PushPosition()
    PushBlock()

    repeat
        Left()
    until isWhite()
       or CurrChar() == Asc('"')
       or CurrChar() == Asc("'")
       or CurrCol() < 2

    if isWhite()
        Right()
    endif

    Mark(_INCLUSIVE_)

    repeat
        Right()
    until isWhite()
       or CurrChar() == Asc(";")
       or CurrChar() == Asc("'")
       or CurrChar() == Asc('"')
       or CurrChar() == Asc("(")
       or CurrPos() > CurrLineLen()

    if isWhite()
       or CurrChar() == Asc(";")
       or CurrChar() == Asc("'")
       or CurrChar() == Asc('"')
       or CurrChar() == Asc("(")
        Left()
    endif

    Mark(_INCLUSIVE_)

    name = GetMarkedText()

    PopPosition()
    PopBlock()

    return (trim(name))
end

string proc Colons2Slashes (string name, string slash)
    string coloned[MAXSTRINGLEN] = name
    string slashed[MAXPATH] = ''
    integer sep = 0

    while 1
        sep = Pos('::',coloned)
        if not sep
            break
        endif
        slashed = slashed + coloned[1..sep - 1]
        coloned = coloned [sep + 2:Length(coloned) - sep - 1]
    endwhile
    if coloned <> ""
        slashed = slashed + slash + coloned
    endif
    return(slashed)
end

string proc Colons2Forwardslashes (string name)
    return(Colons2Slashes(name, '/'))
end

string proc Colons2Backslashes (string name)
    return(Colons2Slashes(name, '\'))
end

integer proc ParseDOSFlags (string flag_string)
    integer p
    integer flags = 0
    integer in_win32 = 0

    #ifdef WIN32
    in_win32 = 1
    #endif

    for p = 1 to NumTokens(flag_string, '|')
        case Trim(GetToken(flag_string, '|', p))
            when '_DONT_CLEAR_'
                 flags = flags | _DONT_CLEAR_
            when '_DEFAULT_'
                 flags = flags | _DEFAULT_
            when '_DONT_PROMPT_'
                 flags = flags | _DONT_PROMPT_
            when '_DONT_CLEAR_'
                 flags = flags | _DONT_CLEAR_
            when '_TEE_OUTPUT_'
                 flags = flags | _TEE_OUTPUT_
            when '_RETURN_CODE_'
                 flags = flags | _RETURN_CODE_
            when '_RUN_DETACHED_'
                 flags = flags | _RUN_DETACHED_
            when '_START_HIDDEN_'
                 if in_win32
                     flags = flags | _START_HIDDEN_
                 endif
            when '_START_MAXIMIZED_'
                 if in_win32
                     flags = flags | _START_MAXIMIZED_
                 endif
            when '_START_MINIMIZED_'
                 if in_win32
                     flags = flags | _START_MINIMIZED_
                 endif
            otherwise
                Warn('unrecognized Dos Flag: ' + Trim(GetToken(flag_string, '|', p)))
        endcase
    endfor
    return(flags)
end

proc LoadSettings()
    if (not Settings_Loaded) or NeedToReloadSettings(Settings_Serial)
        Module_Search_Path       = GetProfileStr('PerlMod', 'module_search_path',       '', FindProfile())
        Devel_Module_Search_Path = GetProfileStr('PerlMod', 'devel_module_search_path', '', FindProfile())
        View_Cmd_Format          = GetProfileStr('PerlMod', 'viewcmd', Default_View_Cmd_Format, FindProfile())
        View_Cmd_DOS_Flags       = ParseDOSFlags( GetProfileStr('PerlMod','viewcmd_dos_flags', Default_DOS_Flags, FindProfile()))

        Settings_Loaded          = 1
    endif
end

string proc FindPerlModule(string module_name)
    string path[MAXPATH]
    string module_filename[MAXPATH] = Colons2BackSlashes(module_name)
    string devel_module_filename[MAXPATH]
    string found_filename[MAXPATH]
    integer p
    integer found_file = FALSE

    devel_module_filename = module_filename
                          + '\'
                          + GetToken(
                              module_filename,
                              '\',
                              NumTokens(module_filename, '\')
                          )
                          + '.pm'

    module_filename = module_filename + '.pm'

    if not Length(Module_Search_Path)
        warn('Module Search Path not defined!')
    else
        // Search Devel path first.  The rules here are slightly different
        // because the last element is doubled:
        //    Palm::Progect => w:\dev\Palm\Progect\Progect.pm

        if not found_file
            for p = 1 to NumTokens(Devel_Module_Search_Path,';')
                path  = AddTrailingSlash(Trim(GetToken(Devel_Module_Search_Path,';', p)))
                // Dupe the last element of module_name
                if FileExists(path + devel_module_filename)
                    found_filename = path + devel_module_filename
                    found_file = TRUE
                    break
                endif
            endfor
        endif

        if not found_file
            for p = 1 to NumTokens(Module_Search_Path,';')
                path  = AddTrailingSlash(Trim(GetToken(Module_Search_Path,';', p)))
                if FileExists(path + module_filename)
                    found_filename = path + module_filename
                    found_file = TRUE
                    break
                endif
            endfor
        endif
    endif
    return(found_filename)
end

proc EditModule(string module_name)
    string module_filename[MAXPATH] = FindPerlModule(module_name)

    if Length(module_name)
        if Length(module_filename)
            EditFile(module_filename)
        else
            Message('Module "' + module_name + '" not found')
        endif
    endif
end

string proc FormatViewCmd(string module_format, string module_name)
    string module_cmd[MAXPATH] = ''
    integer p
    integer escape_mode = FALSE

    // Replace parameters in command:
    // $n = module name (e.g. Foo::Bar)
    // $s = module name w. slashes (e.g. Foo/Bar)
    // $b = module name w. backslashes (e.g. Foo\Bar)
    // $f = full module filename (e.g. /path/to/modules/Foo/Bar.pm)
    // $$ = $

    for p = 1 to Length(module_format)
        if escape_mode == TRUE
            case Lower(module_format[p])
                when 'n'
                    module_cmd = module_cmd + module_name
                when 's'
                    module_cmd = module_cmd + Colons2Forwardslashes(module_name)
                when 'b'
                    module_cmd = module_cmd + Colons2Backslashes(module_name)
                when 'f'
                    module_cmd = module_cmd + FindPerlModule(module_name)
                when '$'
                    module_cmd = module_cmd + '$'
            endcase
            escape_mode = FALSE
        else
            case module_format[p]
                when '$'
                    escape_mode = TRUE
                otherwise
                    module_cmd = module_cmd + module_format[p]
            endcase
        endif
    endfor

    return(module_cmd)
end

proc ViewModulePod(string module_name)
    string module_cmd[MAXPATH]

    if Length(module_name)
        module_cmd = FormatViewCmd(View_Cmd_Format, module_name)
        if Length(module_cmd)
            Dos(module_cmd, View_Cmd_DOS_Flags)
        endif
    endif
end

proc AskViewModulePod()
    LoadSettings()
    ViewModulePod(AskForName(Ask_Edit_Prompt, GetNameAtCursor()))
end

proc AskEditModule()
    LoadSettings()
    EditModule(AskForName(Ask_Edit_Prompt, GetNameAtCursor()))
end

proc Main()
    string cmd[3]             = Query(MacroCmdLine)
    string name[MAXSTRINGLEN] = Query(MacroCmdLine)

    cmd  = trim(cmd)
    name = name[Length(cmd) + 2..Length(name)]

    if name == ""
        name = GetNameAtCursor()
    endif

    LoadSettings()

    case cmd
        when '-ae'
            EditModule(AskForName(Ask_Edit_Prompt, name))
        when '-av'
            ViewModulePod(AskForName(Ask_View_Prompt, name))
    endcase

    // if 0 warn(str(View_Cmd_Dos_Flags + ParseDosFlags(Default_Dos_Flags))) endif

end

<ctrl m><m> AskViewModulePod()
<ctrl m><n> AskEditModule()





