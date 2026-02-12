
/*
    Ringlets -


    Ringlets - Allow TSE to maintain more than one ring of files

    v0.9.2 - Jun 19, 2002

    
    Copyright (c) 2002 - Michael Graham <magmac@occamstoothbrush.com>

    This program is Free Software - you may use it, modify it and
    distribute it under the the terms of the Perl Artistic License,
    which you may find at:

          http://www.perl.com/CPAN/doc/misc/license/Artistic

    In particular, note that you use this software at your own risk!

    The latest version of my TSE macros can be found at:

        http://www.occamstoothbrush.com/tsemac/



*/


#define MAX_RING_ID_WIDTH              6
#define MAX_BUFFER_ID_WIDTH            12
#define MAX_RING_NAME_WIDTH            32
#define MAX_RING_EDITOR_SETTINGS_SIZE  64

#ifndef MAXSTRINGLEN
#define MAXSTRINGLEN 255
#endif

#define MAX_PLUGIN_SIZE                MAXSTRINGLEN
#define MAX_FILTER_SIZE                MAXSTRINGLEN
#define MAX_PROP_STRING_SIZE           MAXSTRINGLEN

#include ['buffutil.si']
#include ['setcache.si']
#include ['FindProf.si']
#include ['regex.si']

integer Current_Ring_ID             = 0
integer Last_Ring_ID                = 0

integer Ring_Names_Buffer           = 0
integer Ring_Editor_Settings_Buffer = 0
integer Ring_Properties_Buffer      = 0
integer Ring_Files_Buffer           = 0
integer Ring_Prompt_History         = 0
integer Filter_Buffer = 0

integer Max_Ring_ID                 = 0
integer Max_Unnamed_Ring_ID         = 0

integer Macro_Cleanup_Called        = 0

// Global variables - properties of the current ring
string  Ring_Prop_Name[MAX_RING_NAME_WIDTH]              = ''
string  Ring_Prop_Include_Filter[MAX_FILTER_SIZE]        = ''
string  Ring_Prop_Exclude_Filter[MAX_FILTER_SIZE]        = ''
string  Ring_Prop_Include_Filter_Regex[MAX_FILTER_SIZE]  = ''
string  Ring_Prop_Exclude_Filter_Regex[MAX_FILTER_SIZE]  = ''
string  Ring_Prop_Include_Filter_Simple[MAX_FILTER_SIZE] = ''
string  Ring_Prop_View_Plugins[MAX_PLUGIN_SIZE]          = ''
string  Ring_Prop_CWD[MAX_PLUGIN_SIZE]                   = ''
integer Ring_Prop_Flags                                  = 0

// Flag values for Ring_Prop_Flags
constant RP_SHOW_NAMES_ONLY        = 2
constant RP_VIEW_PLUGINS_ENABLED   = 4
constant RP_LOADED_FROM_PROFILE    = 16
constant RP_STEAL_FILTERED_FILES   = 32
constant RP_USE_CURREXT            = 64
constant RP_PERSIST_CWD            = 128
// constant RP_HIDE_WHEN_EMPTY        = 256

constant  RING_ID_ALL      = 1
constant  RING_ID_UNFILED  = 2

// Instant Filter variables and constants
string Instant_Filter_Include[MAXSTRINGLEN] = ''
string Instant_Filter_Exclude[MAXSTRINGLEN] = ''
integer Instant_Filter_Flags   = 0

constant IF_USE_CURREXT        = 1
constant IF_THIS_RING          = 2
constant IF_COPY               = 4

constant F_REMOVE_FROM_ORIGINAL_RING = 1

integer Settings_Loaded      = 0
integer Settings_Serial      = 0
integer Is_Currext_Available = FALSE

// The following are overridden by profile settings
integer Quit_Orphaned_Files                               = 1
integer Prompt_To_Quit_Orphaned_Files                     = 0
integer Show_Empty_Rings                                  = 1
integer Show_Names_Only                                   = 1
integer Enable_View_Plugins                               = 1
integer Split_To_Same_File                                = 1
integer Scroll_After_HWindow                              = 1
string  All_Buffers_Ring_Name[16]                         = '[ all ]'
string  Unfiled_Buffers_Ring_Name[16]                     = '[ unfiled ]'
string  Default_Ring_Prop_Include_Filter[MAX_FILTER_SIZE] = ''
string  Default_Ring_Prop_Exclude_Filter[MAX_FILTER_SIZE] = ''
string  Default_Ring_Prop_View_Plugins[MAX_PLUGIN_SIZE]   = ''
string  Default_Ring_Prop_String[MAX_PROP_STRING_SIZE]    = 'use_currext:1, names_only:1, enable_view_plugins:1'
string  Quit_File_Macro[MAX_PLUGIN_SIZE]                  = ''
string  Save_File_Macro[MAX_PLUGIN_SIZE]                  = ''
integer Default_Ring_Prop_Flags                           = 0

integer Default_Sort_Choice = _IGNORE_CASE_
integer Sort_Choice = 0

// Actions possible in the List Rings menu
constant LR_HELP                            = 1
constant LR_CHANGE_RING                     = 2
constant LR_CHANGE_RING_KEEPING_FILE        = 3
constant LR_RING_PROPERTIES                 = 4
constant LR_DEL_RING                        = 5
constant LR_MERGE_RING                      = 6
constant LR_COPY_RING                       = 7
constant LR_RENAME_RING                     = 8
constant LR_NEW_RING                        = 9
constant LR_MOVE_RING_UP                    = 10
constant LR_MOVE_RING_DOWN                  = 11
constant LR_TOGGLE_SHOW_EMPTY_RINGS         = 12
constant LR_TOGGLE_BUFFER_IN_RING           = 13
constant LR_TOGGLE_BUFFER_IN_RING_MOVE_DOWN = 14
constant LR_FILTER_ALL_BUFFERS              = 15
constant LR_CREATE_INSTANT_FILTER           = 16

// Actions possible in the List Buffers menu
constant LB_HELP                            = 1
constant LB_CHANGE_FILE                     = 2
constant LB_TOGGLE_FILE                     = 3
constant LB_TOGGLE_FILE_MOVE_DOWN           = 4
constant LB_SELECT_NONE                     = 5
constant LB_SELECT_ALL                      = 6
constant LB_SAVE_FILE                       = 7
constant LB_QUIT_FILE_THIS_RING             = 8
constant LB_QUIT_FILE_ALL_RINGS             = 9
constant LB_MOVE_FILE_UP                    = 10
constant LB_MOVE_FILE_DOWN                  = 11
constant LB_TOGGLE_NAME_ONLY                = 12
constant LB_TOGGLE_PLUGINS                  = 13
constant LB_ADD_BUFFERS_FROM_OTHER_RING     = 14
constant LB_CHANGE_RING                     = 15
constant LB_CHANGE_RING_TO_ALL              = 16
constant LB_FILTER_ALL_BUFFERS              = 17
constant LB_CURRENT_RING_PROPERTIES         = 18
constant LB_SORT_BUFFERS_IN_RING            = 19
constant LB_SORT_BUFFERS_IN_RING_MENU       = 20
constant LB_CREATE_INSTANT_FILTER           = 21

forward integer proc FindRingIDByName(string ring_name)
forward string proc FindRingNameByID (integer ring_id)
forward integer proc NewRing(string ring_name)
forward proc RenameRing(integer ring_id, string new_name)
forward proc mHWindow()
forward proc mVWindow()
forward proc NextFileInCurrentRing()
forward proc PrevFileInCurrentRing()
forward proc ListBuffers()
forward proc FilterAllBuffers()
forward integer proc ChangeToLastRing()
forward proc OnFirstEdit()

#include ['ringkeys.si']

/***********************************************************************
* Utility routines
***********************************************************************/

proc Debug (string msg)
    if 0
        Debug('')
    endif
    UpdateDisplay()
    Warn(msg)
end

proc Debug_LoadedInfo(integer buffer_id, string tag)
    if 0 Debug_LoadedInfo(0,'') endif
    PushPosition()
    GotoBufferId(buffer_id)
    warn(tag + ' file: ' + CurrFileName() +'('+Str(GetBufferId())+') loaded:' + Str(Query(BufferFlags) & _LOADED_))
    PopPosition()
end

integer proc TryLoadMacro (string macro_name)
    if isMacroLoaded(macro_name) or LoadMacro(macro_name)
        return(1)
    endif
    return(0)
end

/***********************************************************************
* Save and Quit via external macro, if supplied
***********************************************************************/
proc mSaveFile()
    UpdateDisplay()
    if Length(Save_File_Macro) and TryLoadMacro(Trim(GetToken(Save_File_Macro, ' ', 1)))
        ExecMacro(Save_File_Macro)
    else
        SaveFile()
    endif
end

proc mQuitFile()
    UpdateDisplay()
    if Length(Quit_File_Macro) and TryLoadMacro(Trim(GetToken(Quit_File_Macro, ' ', 1)))
        ExecMacro(Quit_File_Macro)
    else
        QuitFile()
    endif
end

/***********************************************************************
* GetNextRingID()
    Provide the next available unique ring id
***********************************************************************/
integer proc GetNextRingID ()
    Max_Ring_ID = Max_Ring_ID + 1
    return(Max_Ring_ID)
end

/***********************************************************************
* GetNextUnnamedRingName()
    Provide the next unique ring name such as "<unnamed ring #23>"
***********************************************************************/
string proc GetNextUnnamedRingName ()
    Max_Unnamed_Ring_ID = Max_Unnamed_Ring_ID + 1
    return('<unnamed ring #' + Str(Max_Unnamed_Ring_ID) + '>')
end

/***********************************************************************
* GetRingPromptHistory()
    creates Ring_Prompt_History, which is used in the prompts of
    PromptedRenameRing() and PromptedMergeRing()
***********************************************************************/

proc GetRingPromptHistory()
    if not Ring_Prompt_History
        Ring_Prompt_History = GetFreeHistory("ringlets:Ring_Prompt_History")
    endif
end

/***********************************************************************
* PackEditorSettings()
    Takes all the current editor settings and concatinates them
    into a string of pipe-delimited values
***********************************************************************/

string proc PackEditorSettings ()
    return(
        Str(GetBufferId())      + '|' +
        Str(CurrLine())         + '|' +
        Str(CurrRow())          + '|' +
        Str(CurrPos())          + '|' +
        Str(Query(Insert))      + '|' +
        Str(Query(AutoIndent))  + '|' +
        Str(Query(WordWrap))    + '|' +
        Str(Query(LeftMargin))  + '|' +
        Str(Query(RightMargin)) + '|' +
        Str(Query(TabType))     + '|' +
        Str(Query(TabWidth))    + '|' +
        Str(Query(ExpandTabs))  + '|' +
        Str(Query(EOLType))     + '|' +
        Str(Query(EOFType))
    )
end

/***********************************************************************
* UnpackEditorSettings()
    Takes a pipe delimited string of values, parses it,
    and sets the live editor settings for those values
***********************************************************************/

proc UnpackEditorSettings (string settings)
    GotoBufferId(    Val(GetToken(settings, '|', 1)))
    GotoLine(        Val(GetToken(settings, '|', 2)))
    ScrollToRow(     Val(GetToken(settings, '|', 3)))
    GotoPos(         Val(GetToken(settings, '|', 4)))
    Set(Insert,      Val(GetToken(settings, '|', 5)))
    Set(AutoIndent,  Val(GetToken(settings, '|', 6)))
    Set(WordWrap,    Val(GetToken(settings, '|', 7)))
    Set(LeftMargin,  Val(GetToken(settings, '|', 8)))
    Set(RightMargin, Val(GetToken(settings, '|', 9)))
    Set(TabType,     Val(GetToken(settings, '|', 10)))
    Set(TabWidth,    Val(GetToken(settings, '|', 11)))
    Set(ExpandTabs,  Val(GetToken(settings, '|', 12)))
    Set(EOLType,     Val(GetToken(settings, '|', 13)))
    Set(EOFType,     Val(GetToken(settings, '|', 14)))
end


forward proc ParseSettingsString(string settings_string)
forward proc PrepareRingProperties(integer ring_id)
forward proc SetRingPropertyFlag(integer which_flag, integer on_or_off)
forward proc CommitRingProperties(integer ring_id)

/***********************************************************************
* LoadProfileSettings()
    Retrieve settings from TSE.INI if they have not already been
    loaded, or if the system has indicated that they need to be
    reloaded
***********************************************************************/

proc LoadProfileSettings()
    string ring_name[MAX_RING_NAME_WIDTH] = ''
    string ring_properties[255]           = ''

    integer ring_id

    if (not Settings_Loaded) or NeedToReloadSettings(Settings_Serial)

        Settings_Serial = GetSettingsRefreshSerial()

        Default_Ring_Prop_Include_Filter = GetProfileStr('ringlets','default_include_filter',  Default_Ring_Prop_Include_Filter, FindProfile())
        Default_Ring_Prop_Exclude_Filter = GetProfileStr('ringlets','default_exclude_filter',  Default_Ring_Prop_Exclude_Filter, FindProfile())
        Default_Ring_Prop_View_Plugins   = GetProfileStr('ringlets','default_view_plugins',    Default_Ring_Prop_View_Plugins,   FindProfile())
        Default_Ring_Prop_String         = GetProfileStr('ringlets','default_ring_properties', Default_Ring_Prop_String,         FindProfile())
        Quit_File_Macro                  = GetProfileStr('ringlets','quitfile_macro',          Quit_File_Macro,                  FindProfile())
        Save_File_Macro                  = GetProfileStr('ringlets','savefile_macro',          Save_File_Macro,                  FindProfile())
        All_Buffers_Ring_Name            = GetProfileStr('ringlets','all_buffers_ring_name',   All_Buffers_Ring_Name,            FindProfile())
        Unfiled_Buffers_Ring_Name        = GetProfileStr('ringlets','unfiled_buffers_ring_name', Unfiled_Buffers_Ring_Name,      FindProfile())
        Quit_Orphaned_Files              = GetProfileInt('ringlets','quit_orphaned_files',     Quit_Orphaned_Files,              FindProfile())
        Prompt_To_Quit_Orphaned_Files    = GetProfileInt('ringlets','prompt_to_quit_orphaned_files', Prompt_To_Quit_Orphaned_Files, FindProfile())
        Show_Empty_Rings                 = GetProfileInt('ringlets','show_empty_rings',        Show_Empty_Rings,                 FindProfile())
        Show_Names_Only                  = GetProfileInt('ringlets','show_names_only',         Show_Names_Only,                  FindProfile())
        Enable_View_Plugins              = GetProfileInt('ringlets','enable_view_plugins',     Enable_View_Plugins,              FindProfile())
        Split_To_Same_File               = GetProfileInt('ringlets','split_to_same_file',      Split_To_Same_File,               FindProfile())
        Scroll_After_HWindow             = GetProfileInt('ringlets','scroll_after_hwindow',    Scroll_After_HWindow,             FindProfile())

        Ring_Prop_Flags = 0
        ParseSettingsString(Default_Ring_Prop_String)
        Default_Ring_Prop_Flags = Ring_Prop_Flags

        if LoadProfileSection('rings', FindProfile())
            while GetNextProfileItem(ring_name, ring_properties)
                if Length(ring_name)

                    ring_id = FindRingIDByName(ring_name)
                    if not ring_id
                        ring_id = NewRing(ring_name)
                    endif

                    PrepareRingProperties(ring_id)
                    ParseSettingsString(ring_properties)
                    SetRingPropertyFlag(RP_LOADED_FROM_PROFILE, 1)
                    CommitRingProperties(ring_id)
                endif

            endwhile
        endif

        Settings_Loaded = 1
    endif
end

/***********************************************************************
* SaveRingsToProfile()
    Saves the properties of any persistant rings to TSE.INI
***********************************************************************/

proc SaveRingsToProfile()
    integer ring_id
    string ring_name[MAX_RING_NAME_WIDTH]
    string ring_properties[MAXSTRINGLEN] = ''

    PushPosition()

    RemoveProfileSection('rings', FindProfile())
    GotoBufferId(Ring_Names_Buffer)
    BegFile()
    BegLine()
    repeat

        ring_properties = ''

        if lFind('^{.*}:{.*}$', 'x')
            ring_id   = Val(GetFoundText(1))
            ring_name = GetFoundText(2)

            PrepareRingProperties(ring_id)

            if Ring_Prop_Flags & RP_LOADED_FROM_PROFILE and ring_id > 2

                if Length(ring_properties)
                    ring_properties = ring_properties + ','
                endif

                // if Ring_Prop_Flags & RP_HIDE_WHEN_EMPTY
                //     ring_properties = ring_properties + 'hide:1,'
                // else
                //     ring_properties = ring_properties + 'hide:0,'
                // endif

                if Ring_Prop_Flags & RP_SHOW_NAMES_ONLY
                    ring_properties = ring_properties + 'names_only:1,'
                else
                    ring_properties = ring_properties + 'names_only:0,'
                endif

                if Ring_Prop_Flags & RP_VIEW_PLUGINS_ENABLED
                    ring_properties = ring_properties + 'enable_view_plugins:1,'
                else
                    ring_properties = ring_properties + 'enable_view_plugins:0,'
                endif


                if Ring_Prop_Flags & RP_USE_CURREXT
                    ring_properties = ring_properties + 'use_currext:1,'
                else
                    ring_properties = ring_properties + 'use_currext:0,'
                endif

                if Ring_Prop_Flags & RP_STEAL_FILTERED_FILES
                    ring_properties = ring_properties + 'steal:1,'
                else
                    ring_properties = ring_properties + 'steal:0,'
                endif

                if Ring_Prop_Flags & RP_PERSIST_CWD
                    ring_properties = ring_properties + 'persist_cwd:1,'
                else
                    ring_properties = ring_properties + 'persist_cwd:0,'
                endif

                if Length(Ring_Prop_Include_Filter)
                    ring_properties = ring_properties + 'include:' + Ring_Prop_Include_Filter + ','
                endif

                if Length(Ring_Prop_Exclude_Filter)
                    ring_properties = ring_properties + 'exclude:' + Ring_Prop_Exclude_Filter + ','
                endif

                if Length(Ring_Prop_View_Plugins)
                    ring_properties = ring_properties + 'view_plugins:' + Ring_Prop_View_Plugins + ','
                endif

                if (Ring_Prop_Flags & RP_PERSIST_CWD) and Length(Ring_Prop_CWD)
                    ring_properties = ring_properties + 'cwd:' + Ring_Prop_CWD + ','
                endif

                if ring_properties[Length(ring_properties)] == ','
                    ring_properties = ring_properties[1..Length(ring_properties) - 1]
                endif

                WriteProfileStr('rings', ring_name, ring_properties, FindProfile())

            endif
        endif

    until not Down()

    // Write Default Ring Properties
    WriteProfileStr('ringlets','default_include_filter',  Default_Ring_Prop_Include_Filter, FindProfile())
    WriteProfileStr('ringlets','default_exclude_filter',  Default_Ring_Prop_Exclude_Filter, FindProfile())
    WriteProfileStr('ringlets','default_view_plugins',    Default_Ring_Prop_View_Plugins,   FindProfile())
    WriteProfileStr('ringlets','default_ring_properties', Default_Ring_Prop_String,         FindProfile())

    PopPosition()
end

// Ring Properties

// Translate wildcards into regexes.  For instance:
//     *.txt   => .*\.txt
//     foo?bar => foo.bar
//
string proc WildcardToRegex(string wc)
    string filter[MAXSTRINGLEN] = wc

    filter = Trim(filter)
    Regex_Subst(filter, '\\', '\\\\', '')
    Regex_Subst(filter, '\.', '\\.', '')
    Regex_Subst(filter, '\*', '.*', '')
    Regex_Subst(filter, '\?', '.', '')

    // Filenames match case-insensitive
    return(Lower(filter))
end

// For speed, try to create a simple
// see if we can turn the filespec into a simple
// extension match.
//
//    We can do this if we match something like:
//         *.txt
//         .txt
//    etc.
//
string proc WildcardToSimpleFilter(string wc)
    string filter[MAXSTRINGLEN]

    if Regex_Match(wc, '\*{\.[a-z]#}', 'i')
      or Regex_Match(wc, '{\.[a-z]#}', 'i')
        filter = Regex_MatchText(1)
    endif

    return(filter)
end

proc PrepareDefaultRingProperties()
    Ring_Prop_Flags          = Default_Ring_Prop_Flags
    Ring_Prop_Include_Filter = Default_Ring_Prop_Include_Filter
    Ring_Prop_Exclude_Filter = Default_Ring_Prop_Exclude_Filter
    Ring_Prop_View_Plugins   = Default_Ring_Prop_View_Plugins
end

proc PrepareRingProperties(integer ring_id)
    integer start_field
    integer end_field

    PushPosition()
    if GotoBufferId(Ring_Properties_Buffer)
        if lFind(Format(ring_id:MAX_RING_ID_WIDTH), '^g')

            PushBlock()
            UnMarkBlock()

            BegLine()
            lFind(':','c')
            start_field = CurrPos() + 1
            lFind('|','c+')
            end_field = CurrPos() - 1
            if end_field >= start_field
                MarkColumn(CurrLine(), start_field, CurrLine(), end_field)
                Ring_Prop_Flags = Val(GetMarkedText())
            else
                Ring_Prop_Flags = 0
            endif

            UnMarkBlock()

            lFind('|','c')
            start_field = CurrPos() + 1
            lFind('|','c+')
            end_field = CurrPos() - 1
            if end_field >= start_field
                MarkColumn(CurrLine(), start_field, CurrLine(), end_field)
                Ring_Prop_Include_Filter = GetMarkedText()
            else
                Ring_Prop_Include_Filter = ''
            endif

            UnMarkBlock()

            lFind('|','c')
            start_field = CurrPos() + 1
            lFind('|','c+')
            end_field = CurrPos() - 1
            if end_field >= start_field
                MarkColumn(CurrLine(), start_field, CurrLine(), end_field)
                Ring_Prop_Include_Filter_Regex = GetMarkedText()
            else
                Ring_Prop_Include_Filter_Regex = ''
            endif

            UnMarkBlock()

            lFind('|','c')
            start_field = CurrPos() + 1
            lFind('|','c+')
            end_field = CurrPos() - 1
            if end_field >= start_field
                MarkColumn(CurrLine(), start_field, CurrLine(), end_field)
                Ring_Prop_Include_Filter_Simple = GetMarkedText()
            else
                Ring_Prop_Include_Filter_Simple = ''
            endif

            UnMarkBlock()

            start_field = CurrPos() + 1
            lFind('|','c+')
            end_field = CurrPos() - 1
            if end_field >= start_field
                MarkColumn(CurrLine(), start_field, CurrLine(), end_field)
                Ring_Prop_Exclude_Filter = GetMarkedText()
            else
                Ring_Prop_Exclude_Filter = ''
            endif

            UnMarkBlock()

            start_field = CurrPos() + 1
            lFind('|','c+')
            end_field = CurrPos() - 1
            if end_field >= start_field
                MarkColumn(CurrLine(), start_field, CurrLine(), end_field)
                Ring_Prop_Exclude_Filter_Regex = GetMarkedText()
            else
                Ring_Prop_Exclude_Filter_Regex = ''
            endif

            UnMarkBlock()

            start_field = CurrPos() + 1
            lFind('|','c+')
            end_field = CurrPos() - 1

            if end_field >= start_field
                MarkColumn(CurrLine(), start_field, CurrLine(), end_field)
                Ring_Prop_View_Plugins = GetMarkedText()
            else
                Ring_Prop_View_Plugins = ''
            endif

            UnMarkBlock()

            start_field = CurrPos() + 1
            end_field   = CurrLineLen()

            if end_field >= start_field
                MarkColumn(CurrLine(), start_field, CurrLine(), end_field)
                Ring_Prop_CWD = GetMarkedText()
            else
                Ring_Prop_CWD = ''
            endif

            PopBlock()

        else

            PrepareDefaultRingProperties()
        endif

        Ring_Prop_Include_Filter_Regex  = ''
        Ring_Prop_Include_Filter_Simple = ''
        Ring_Prop_Exclude_Filter_Regex  = ''

        if Length(Ring_Prop_Include_Filter)
            Ring_Prop_Include_Filter_Regex  = WildcardToRegex(Ring_Prop_Include_Filter)
            Ring_Prop_Include_Filter_Simple = WildcardToSimpleFilter(Ring_Prop_Include_Filter)
        endif

        if Length(Ring_Prop_Exclude_Filter)
            Ring_Prop_Exclude_Filter_Regex = WildcardToRegex(Ring_Prop_Exclude_Filter)
        endif

    endif
    PopPosition()

    Ring_Prop_Name                 = FindRingNameById(ring_id)
end

proc CommitDefaultRingProperties()
    Default_Ring_Prop_Flags          = Ring_Prop_Flags
    Default_Ring_Prop_Include_Filter = Ring_Prop_Include_Filter
    Default_Ring_Prop_Exclude_Filter = Ring_Prop_Exclude_Filter
    Default_Ring_Prop_View_Plugins   = Ring_Prop_View_Plugins
end

proc CommitRingProperties(integer ring_id)

    PushPosition()
    if GotoBufferId(Ring_Properties_Buffer)
        if lFind(Format(ring_id:MAX_RING_ID_WIDTH), '^g')
            GotoPos(MAX_RING_ID_WIDTH + 1)
            KillToEol()
        else
            EndFile()
            AddLine()
            BegLine()
            InsertText(Format(ring_id:MAX_RING_ID_WIDTH))
        endif

        InsertText(':')
        InsertText(Str(Ring_Prop_Flags))
        InsertText('|')
        InsertText(Ring_Prop_Include_Filter)
        InsertText('|')
        InsertText(Ring_Prop_Include_Filter_Regex)
        InsertText('|')
        InsertText(Ring_Prop_Include_Filter_Simple)
        InsertText('|')
        InsertText(Ring_Prop_Exclude_Filter)
        InsertText('|')
        InsertText(Ring_Prop_Exclude_Filter_Regex)
        InsertText('|')
        InsertText(Ring_Prop_View_Plugins)
        InsertText('|')
        InsertText(Ring_Prop_CWD)

    endif
    PopPosition()

    RenameRing(ring_id, Ring_Prop_Name)

end

proc SetRingPropertyFlag(integer which_flag, integer on_or_off)
    // Works with true/false (yes = 1, no = 0)
    // or menu values (Yes = 1, No = 2)

    if on_or_off == 1
        Ring_Prop_Flags = Ring_Prop_Flags | which_flag
    else
        Ring_Prop_Flags = Ring_Prop_Flags & ~which_flag
    endif

end

proc SetInstantFilterFlag(integer which_flag, integer on_or_off)
    // Works with true/false (yes = 1, no = 0)
    // or menu values (Yes = 1, No = 2)

    if on_or_off == 1
        Instant_Filter_Flags = Instant_Filter_Flags | which_flag
    else
        Instant_Filter_Flags = Instant_Filter_Flags & ~which_flag
    endif

end

proc ParseSettingsString(string passed_setting_string)
    integer t
    string  setting_string[MAXSTRINGLEN] = passed_setting_string
    string  prop_name[22]
    string  prop_value[255]

    // Fix a common typo: Replace all semi-colons with commas
    // if Pos(';', setting_string)
    //     for t = 1 to Length(setting_string)
    //         if setting_string[t] == ';'
    //             setting_string[t] = ','
    //         endif
    //     endfor
    // endif

    for t = 1 to NumTokens(setting_string, ',')
        // Token: include, exclude, plugins, hide, names_only, enable_plugins

        prop_value = GetToken(setting_string, ',', t)
        prop_name  = prop_value[1..Pos(':', prop_value)-1]
        prop_value = prop_value[Length(prop_name)+2..Length(prop_value)]

        prop_name  = Lower(Trim(prop_name))
        prop_value = Trim(prop_value)

        case prop_name
            when 'include'
                Ring_Prop_Include_Filter       = prop_value
            when 'exclude'
                Ring_Prop_Exclude_Filter       = prop_value
            when 'view_plugins'
                Ring_Prop_View_Plugins         = prop_value
            when 'cwd'
                Ring_Prop_CWD                  = prop_value
            when 'names_only'
                SetRingPropertyFlag(RP_SHOW_NAMES_ONLY, Val(prop_value))
            when 'enable_view_plugins'
                SetRingPropertyFlag(RP_VIEW_PLUGINS_ENABLED, Val(prop_value))
            when 'steal'
                SetRingPropertyFlag(RP_STEAL_FILTERED_FILES, Val(prop_value))
            when 'use_currext'
                SetRingPropertyFlag(RP_USE_CURREXT, Val(prop_value))
            when 'persist_cwd'
                SetRingPropertyFlag(RP_PERSIST_CWD, Val(prop_value))
            when ''
            otherwise
                Warn("Can't set unknown property: " + prop_name)
        endcase
    endfor
end

proc SetSortChoice(integer choice)
    case choice
        when 1 Sort_Choice = 0
        when 2 Sort_Choice = _IGNORE_CASE_
        when 3 Sort_Choice = _DESCENDING_
        when 4 Sort_Choice = _DESCENDING_ | _IGNORE_CASE_
    endcase
end

menu SortMenu()
    title   = 'Sort Buffers in List'
    command = SetSortChoice(MenuOption())
    "&Ascending, Case Sensitive"    , , CloseBefore
    "&Ascending, Case Insensitive"  , , CloseBefore
    "&Descending, Case Sensitive"   , , CloseBefore
    "&Descending, Case Insensitive" , , CloseBefore
end

menu NamesOnlyMenu()
    command = SetRingPropertyFlag(RP_SHOW_NAMES_ONLY, MenuOption())
    "&Yes" , , CloseBefore
    "&No"  , , CloseBefore
end

menu UseCurrExtMenu()
    command = SetRingPropertyFlag(RP_USE_CURREXT, MenuOption())
    "&Yes" , , CloseBefore
    "&No"  , , CloseBefore
end

menu StealFilteredFilesMenu()
    command = SetRingPropertyFlag(RP_STEAL_FILTERED_FILES, MenuOption())
    "&Yes" , , CloseBefore
    "&No"  , , CloseBefore
end

menu PersistCWDMenu()
    command = SetRingPropertyFlag(RP_PERSIST_CWD, MenuOption())
    "&Yes" , , CloseBefore
    "&No"  , , CloseBefore
end

menu PersistentMenu()
    command = SetRingPropertyFlag(RP_LOADED_FROM_PROFILE, MenuOption())
    "&Yes" , , CloseBefore
    "&No"  , , CloseBefore
end

proc ReadAndFilter(var string edit_string)
    integer p
    Read(edit_string)
    p = Pos('|',edit_string)
    while p
        edit_string = edit_string[1..p-1] + edit_string[p + 1..Length(edit_string)]
        p = Pos('|',edit_string)
    endwhile
end

menu ViewPluginsEnabledMenu()
    command = SetRingPropertyFlag(RP_VIEW_PLUGINS_ENABLED, MenuOption())
    "&Yes" , , CloseBefore
    "&No"  , , CloseBefore
end

menu RingPropertiesMenu()
    "&Name              " [Format(Ring_Prop_Name:-56):-56]
                        , ReadAndFilter(Ring_Prop_Name)
                        , _MF_DONT_CLOSE_
                        , "Set the Name of this Ring"

    "Show Na&mes Only   " [format(MenuStr(NamesOnlyMenu,
                           iif(Ring_Prop_Flags & RP_SHOW_NAMES_ONLY,1,2)):-3):-3]
                        , NamesOnlyMenu()
                        , _MF_DONT_CLOSE_
                        , "Default of whether buffer lists for this ring should show file name only"

    "Working &Directory " [Format(Ring_Prop_CWD:-56):-56]
                        , ReadAndFilter(Ring_Prop_CWD)
                        , _MF_DONT_CLOSE_
                        , "Current working directory for this ring"

    "Persist C&WD       " [Format(MenuStr(PersistCWDMenu,
                           iif(Ring_Prop_Flags & RP_PERSIST_CWD,1,2)):-3):-3]
                        , PersistCWDMenu()
                        , _MF_DONT_CLOSE_
                        , "Whether the Current working directory for this ring should be saved in TSE.INI"


    "&Include Filter    " [Format(Ring_Prop_Include_Filter:-56):-56]
                        , ReadAndFilter(Ring_Prop_Include_Filter)
                        , _MF_DONT_CLOSE_
                        , "List of filespecs (sep. by ;) to match loaded files for inclusion in this ring"

    "E&xclude Filter    " [Format(Ring_Prop_Exclude_Filter:-56):-56]
                        , ReadAndFilter(Ring_Prop_Exclude_Filter)
                        , _MF_DONT_CLOSE_
                        , "List of filespecs (sep. by ;) for exceptions to Include filter"

    "Use &CurrExt       " [format(MenuStr(UseCurrExtMenu,
                           iif(Ring_Prop_Flags & RP_USE_CURREXT,1,2)):-3):-3]
                        , UseCurrExtMenu()
                        , _MF_DONT_CLOSE_
                        , "Use CurrExt macro (if available) for a file's extension when matching filter"

    "&Steal Filtered    " [format(MenuStr(StealFilteredFilesMenu,
                           iif(Ring_Prop_Flags & RP_STEAL_FILTERED_FILES,1,2)):-3):-3]
                        , StealFilteredFilesMenu()
                        , _MF_DONT_CLOSE_
                        , "When a this ring's filter accepts a file, don't let other rings try."

    "&View Plugins      " [Format(Ring_Prop_View_Plugins:-56):-56]
                        , ReadAndFilter(Ring_Prop_View_Plugins)
                        , _MF_DONT_CLOSE_
                        , "List of macros (sep. by ;) to process buffer lists for this ring"

    "&Plugins Enabled   " [format(MenuStr(ViewPluginsEnabledMenu,
                           iif(Ring_Prop_Flags & RP_VIEW_PLUGINS_ENABLED,1,2)):-3):-3]
                        , ViewPluginsEnabledMenu()
                        , _MF_DONT_CLOSE_
                        , "Whether View plugins are enabled"

    "P&ersistent        " [format(MenuStr(PersistentMenu,
                           iif(Ring_Prop_Flags & RP_LOADED_FROM_PROFILE, 1,2)):-3):-3]
                        , PersistentMenu()
                        , _MF_DONT_CLOSE_
                        , "Whether the properties of this ring will be saved in TSE.INI"

end

// End Ring Properties

menu DefaultRingPropertiesMenu()
    "&Name              " [Format(Ring_Prop_Name:-56):-56]
                        , ReadAndFilter(Ring_Prop_Name)
                        , _MF_SKIP_|_MF_GRAYED_
                        , "Set the Name of this Ring"

    "&View Plugins      " [Format(Ring_Prop_View_Plugins:-56):-56]
                        , ReadAndFilter(Ring_Prop_View_Plugins)
                        , _MF_DONT_CLOSE_
                        , "List of macros (sep. by ;) to process buffer lists for this ring"


    "&Plugins Enabled   " [format(MenuStr(ViewPluginsEnabledMenu,
                           iif(Ring_Prop_Flags & RP_VIEW_PLUGINS_ENABLED,1,2)):-3):-3]
                        , ViewPluginsEnabledMenu()
                        , _MF_DONT_CLOSE_
                        , "Whether View plugins are enabled"

    "Show Na&mes Only   " [format(MenuStr(NamesOnlyMenu,
                           iif(Ring_Prop_Flags & RP_SHOW_NAMES_ONLY,1,2)):-3):-3]
                        , NamesOnlyMenu()
                        , _MF_DONT_CLOSE_
                        , "Default of whether buffer lists for this ring should show file name only"
end

// End Default Ring Properties


menu IF_UseCurrExtMenu()
    command = SetInstantFilterFlag(IF_USE_CURREXT, MenuOption())
    "&Yes" , , CloseBefore
    "&No"  , , CloseBefore
end

menu IF_ThisRingORAllRingsMenu()
    command = SetInstantFilterFlag(IF_THIS_RING, MenuOption())
    "&This Ring" , , CloseBefore
    "&All Rings" , , CloseBefore
end

menu IF_CopyOrMoveMenu()
    command = SetInstantFilterFlag(IF_COPY, MenuOption())
    "&Copy" , , CloseBefore
    "&Move" , , CloseBefore
end

menu InstantFilterMenu()
    "&Include Filter      " [Format(Instant_Filter_Include:-50):-50]
                          , ReadAndFilter(Instant_Filter_Include)
                          , _MF_DONT_CLOSE_
                          , "List of filespecs (sep. by ;) to match loaded files for inclusion in this ring"

    "E&xclude Filter      " [Format(Instant_Filter_Exclude:-50):-50]
                          , ReadAndFilter(Instant_Filter_Exclude)
                          , _MF_DONT_CLOSE_
                          , "List of filespecs (sep. by ;) for exceptions to Include filter"

    "Use &CurrExt         " [format(MenuStr(IF_UseCurrExtMenu,
                           iif(Instant_Filter_Flags & IF_USE_CURREXT,1,2)):-3):-3]
                          , IF_UseCurrExtMenu()
                          , _MF_DONT_CLOSE_
                          , "Use CurrExt macro (if available) for a file's extension when matching filter"

    "This &Ring/All Rings " [format(MenuStr(IF_ThisRingOrAllRingsMenu,
                           iif(Instant_Filter_Flags & IF_THIS_RING,1,2)):-9):-9]
                          , IF_ThisRingOrAllRingsMenu()
                          , _MF_DONT_CLOSE_
                          , "Filter files from this ring only, or filter all loaded files."

    "&Move or Copy        " [format(MenuStr(IF_CopyOrMoveMenu,
                           iif(Instant_Filter_Flags & IF_COPY,1,2)):-4):-4]
                          , IF_CopyOrMoveMenu()
                          , _MF_DONT_CLOSE_
                          , "Copy leaves a filtered file in its original ring.  Move removes it."
end



// Regexp Utils

string proc Regexp_Quote(string search_string)
    string quoted_string[255] = ''
    integer i

    for i = 1 to Length(search_string)
        case search_string[i]
            when 'a'..'z','A'..'Z','0'..'9'
                quoted_string = quoted_string + search_string[i]
            otherwise
                quoted_string = quoted_string + '\' + search_string[i]
        endcase
    endfor
    return(quoted_string)
end

// ring attributes

integer proc FindRingIDByName (string ring_name)
    integer ring_id = 0

    PushPosition()
    if GotoBufferId(Ring_Names_Buffer)
        if lFind(Format('^{','':MAX_RING_ID_WIDTH:'.','}:', Regexp_Quote(ring_name), '$'), 'gx')
            ring_id = Val(GetFoundText(1))
        endif
    endif
    PopPosition()

    return(ring_id)
end

string proc FindRingNameByID (integer ring_id)
    string ring_name[MAX_RING_NAME_WIDTH]

    PushPosition()
    if GotoBufferId(Ring_Names_Buffer)
        lFind(Format(ring_id:MAX_RING_ID_WIDTH, ':{.*}$'), '^gx')
        ring_name = GetFoundText(1)
    endif
    PopPosition()

    return(ring_name)
end

string proc FindRingEditorSettingsByID (integer ring_id)
    string ring_editor_settings[MAX_RING_EDITOR_SETTINGS_SIZE]

    PushPosition()
    if GotoBufferId(Ring_Editor_Settings_Buffer)
        lFind(Format(ring_id:MAX_RING_ID_WIDTH, ':{.*}$'), '^gx')
        ring_editor_settings = GetFoundText(1)
    endif
    PopPosition()

    return(ring_editor_settings)
end

proc SaveRingEditorSettings (integer ring_id)
    string current_settings[MAX_RING_EDITOR_SETTINGS_SIZE] = PackEditorSettings()

    PushPosition()
    if GotoBufferId(Ring_Editor_Settings_Buffer)
        if lFind(Format(ring_id:MAX_RING_ID_WIDTH), '^g')
            KillLine()
            InsertLine(Format(ring_id:MAX_RING_ID_WIDTH, ':', current_settings))
        endif
    endif
    PopPosition()
end



proc MoveRingUp(integer ring_id)
    integer ring_line
    PushPosition()
    GotoBufferId(Ring_Names_Buffer)
    if lFind(Format(ring_id:MAX_RING_ID_WIDTH), '^g')
        ring_line = CurrLine()
        MoveBufferLineUp(Ring_Names_Buffer, ring_line, 1)
        MoveBufferLineUp(Ring_Editor_Settings_Buffer, ring_line, 1)
    endif
    PopPosition()
end

proc MoveRingDown(integer ring_id)
    integer ring_line
    PushPosition()
    GotoBufferId(Ring_Names_Buffer)
    if lFind(Format(ring_id:MAX_RING_ID_WIDTH), '^g')
        ring_line = CurrLine()
        MoveBufferLineDown(Ring_Names_Buffer, ring_line, 1)
        MoveBufferLineDown(Ring_Editor_Settings_Buffer, ring_line, 1)
    endif
    PopPosition()
end

proc RenameRing(integer ring_id, string new_name)
    PushPosition()
    if GotoBufferId(Ring_Names_Buffer)
        if lFind(Format(ring_id:MAX_RING_ID_WIDTH), 'g^')
            GotoPos(MAX_RING_ID_WIDTH + 2)
            KillToEOL()
            InsertText(new_name)
        endif
    endif
    PopPosition()
end

forward integer proc ChangeRing(integer ring_id)

proc DeleteRing(integer ring_id, integer quit_orphans)
    integer buffer_id
    integer deleted_line
    integer new_current_ring_id

    PushPosition()

    if GotoBufferId(Ring_Names_Buffer)
        BegFile()
        BegLine()
        if lFind(Format(ring_id:MAX_RING_ID_WIDTH, ':'), '^')
            KillLine()
            if Current_Ring_ID == ring_id
                if lFind(Format('^{','':MAX_RING_ID_WIDTH:'.', '*}:'), 'x')
                    new_current_ring_id = Val(GetFoundText(1))
                elseif lFind(Format('^{','':MAX_RING_ID_WIDTH:'.', '*}:'), 'gx')
                    new_current_ring_id = Val(GetFoundText(1))
                else
                    new_current_ring_id = 0
                endif
            endif
        endif
    endif
    if GotoBufferId(Ring_Editor_Settings_Buffer)
        BegFile()
        BegLine()
        if lFind(Format(ring_id:MAX_RING_ID_WIDTH, ':'), '^')
            KillLine()
        endif
    endif
    if GotoBufferId(Ring_Properties_Buffer)
        BegFile()
        BegLine()
        if lFind(Format(ring_id:MAX_RING_ID_WIDTH, ':'), '^')
            KillLine()
        endif
    endif

    if GotoBufferId(Ring_Files_Buffer)
        BegFile()

        // We Need to unhook OnFirstEdit here, because
        // as soon as we quit a file that has never been
        // loaded, it will be loaded for the first time,
        // and at that point it will be placed into the
        // current ring, defeating its own deletion!
        //

        Unhook(OnFirstEdit)
        repeat
            deleted_line = 0
            if lFind(Format(ring_id:MAX_RING_ID_WIDTH, ':{.*}$'), '^xc')
                buffer_id = Val(GetFoundText(1))

                KillLine()
                deleted_line = 1
                if quit_orphans == 1
                    PushPosition()
                    if not lFind(Format('^{','':MAX_RING_ID_WIDTH:'.', '}:', buffer_id, '$'), 'xg')
                        if GotoBufferId(buffer_id)
                            UpdateDisplay()
                            mQuitFile()
                        endif
                    endif
                    PopPosition()
                endif
            endif
        until (not deleted_line) and (not Down())
        Hook(_ON_FIRST_EDIT_, OnFirstEdit)
    endif

    PopPosition()

    if new_current_ring_id
        ChangeRing(new_current_ring_id)
    else
        Current_Ring_Id = 0
    endif

end

string proc GetNextCopyRingName (string current_ring_name)
    integer p
    integer copy_num

    string base_name[MAX_RING_NAME_WIDTH]
    string new_name[MAX_RING_NAME_WIDTH]

    p = Pos('(copy', current_ring_name)

    if p
        base_name = RTrim(current_ring_name[1..p-1])
        copy_num  = Val(current_ring_name[p+6]) + 1
    else
        base_name = RTrim(current_ring_name)
        copy_num  = 0
    endif

    while copy_num < 100
        if copy_num
            new_name = base_name + ' (copy ' + Str(copy_num) + ')'
        else
            new_name = base_name + ' (copy)'
        endif
        if FindRingIDByName(new_name)
            copy_num = copy_num + 1
        else
            return(new_name)
        endif
    endwhile

    return('')
end

proc MergeRing (integer first_ring_id, integer second_ring_id)
    integer found
    integer buffer_id
    PushPosition()
    GotoBufferID(Ring_Files_Buffer)
    BegFile()
    BegLine()
    while lFind(Format(first_ring_id:MAX_RING_ID_WIDTH, ':{.*}$'), '^x')
        buffer_id = Val(GetFoundText(1))

        PushPosition()
        found = lFind(Format('^', second_ring_id:MAX_RING_ID_WIDTH, ':', buffer_id, '$'), 'gx')
        PopPosition()

        if not found
            AddLine(Format(second_ring_id:MAX_RING_ID_WIDTH,':',buffer_id))
        endif

    endwhile
    PopPosition()

end

forward integer proc NewRing(string ring_name)

integer proc CopyRing(integer ring_id)
    integer new_ring_id
    string new_ring_name[MAX_RING_NAME_WIDTH] = GetNextCopyRingName(FindRingNameByID(ring_id))

    if Length(new_ring_name)
        new_ring_id = NewRing(new_ring_name)

        MergeRing(ring_id, new_ring_id)

        // Copy Ring Editor Settings
        PushPosition()
        if GotoBufferId(Ring_Editor_Settings_Buffer)
            if lFind(Format(new_ring_id:MAX_RING_ID_WIDTH), '^g')
                KillLine()
                InsertLine(Format(new_ring_id:MAX_RING_ID_WIDTH, ':', FindRingEditorSettingsByID(ring_id)))
            endif
        endif
        PopPosition()

        // Copy Ring Properties
        PrepareRingProperties(ring_id)
        CommitRingProperties(new_ring_id)

        // Since Copying Properties included the name,
        // rename it back again
        RenameRing(new_ring_id, new_ring_name)
    endif
    return(new_ring_id)
end

// ring contents

proc AddBufferToRing (integer file_buffer_id, integer ring_id)
    PushPosition()
    if GotoBufferId(Ring_Files_Buffer)
        if not lFind(Format(ring_id:MAX_RING_ID_WIDTH,':',file_buffer_id), 'g^$')
            EndFile()
            AddLine(Format(ring_id:MAX_RING_ID_WIDTH,':',file_buffer_id))
        endif
    endif
    PopPosition()
end

proc RemoveBufferFromRing (integer file_buffer_id, integer ring_id)
    PushPosition()
    if GotoBufferId(Ring_Files_Buffer)
        if lFind(Format(ring_id:MAX_RING_ID_WIDTH,':',file_buffer_id), 'g^$')
            KillLine()
        endif
    endif
    PopPosition()
end


// Ring creation

integer proc NewRing (string ring_name)

    string  ring_editor_settings[64] = PackEditorSettings()
    integer ring_id                  = FindRingIDByName(ring_name)

    if not ring_id

        ring_id = GetNextRingID()

        PushPosition()

            if GotoBufferId(Ring_Names_Buffer)
                EndFile()
                AddLine(Format(ring_id:MAX_RING_ID_WIDTH, ':', ring_name))
            endif
            if GotoBufferId(Ring_Editor_Settings_Buffer)
                EndFile()
                AddLine(Format(ring_id:MAX_RING_ID_WIDTH, ':', ring_editor_settings))
            endif

            PrepareRingProperties(ring_id)
            CommitRingProperties(ring_id)

        PopPosition()

    endif

    return(ring_id)
end


// Navigation

integer proc ChangeToLastRing()
    if ChangeRing(Last_Ring_Id)
        Message('Changed to ring "'+FindRingNameByID(Current_Ring_ID)+'"')
        return(1)
    endif
    return(0)
end

integer proc ChangeRing (integer ring_id)
    string ring_editor_settings[MAX_RING_EDITOR_SETTINGS_SIZE]
    integer buffer_id

    PrepareRingProperties(Current_Ring_ID)
    Ring_Prop_CWD = CurrDir()
    SaveRingEditorSettings(Current_Ring_ID)
    CommitRingProperties(Current_Ring_ID)

    // Save old ring's position history, load new ring's history
    // ExecMacro('ringpos -s ' + Str(Current_Ring_ID))
    // ExecMacro('ringpos -l ' + Str(ring_id))

    ring_editor_settings = FindRingEditorSettingsByID(ring_id)
    if Length(ring_editor_settings)

        UnpackEditorSettings(ring_editor_settings)
        buffer_id = GetBufferId()
        PushPosition()
        GotoBufferId(Ring_Files_Buffer)
        if lFind(Format('^',ring_id:MAX_RING_ID_WIDTH,':',buffer_id,'$'), 'gx')
            PopPosition()
        else
            if lFind(Format('^',ring_id:MAX_RING_ID_WIDTH,':{.*}$'), 'gx')
                KillPosition()
                GotoBufferId(Val(GetFoundText(1)))
            else
                PopPosition()
            endif
        endif

        Last_Ring_Id = Current_Ring_Id

        Current_Ring_ID = ring_id

        PrepareRingProperties(ring_id)

        ChDir(Ring_Prop_CWD)

        return(1)
    endif
    return(0)
end

// Navigating to the next/prev file, whilst in the [unfiled]
// Ring presents a challenge.  We can't find the current buffer/ring
// combination in the Ring_Files_Buffer, because the unfiled buffers
// aren't stored there.  Nor can we just call NextFile()/PrevFile()
// (as with [all]).  So we have to build up the list of
// unfiled buffers, and move to the next or previous line in this list
//
integer proc BuildUnfiledIdsBuffer()
    integer ocf_hook_state = SetHookState(OFF, _ON_CHANGING_FILES_)
    integer buffer_id
    integer temp_buffer = CreateTempBuffer()
    if temp_buffer
        do NumFiles() times
            NextFile(_DONT_LOAD_)
            buffer_id  = GetBufferId()

            GotoBufferId(Ring_Files_Buffer)
            if not lFind(Format('^','.':MAX_RING_ID_WIDTH:'.',':',buffer_id,'$'),'gx')
                GotoBufferId(temp_buffer)
                AddLine(Str(buffer_id))
            endif

            GotoBufferId(buffer_id)
        enddo
    endif
    SetHookState(ocf_hook_state, _ON_CHANGING_FILES_)
    return(temp_buffer)
end

proc NextUnfiledFile()
    integer current_buffer_id = GetBufferId()
    integer temp_buffer = BuildUnfiledIdsBuffer()
    integer next_buffer_id
    if temp_buffer and GotoBufferId(temp_buffer)
        if lFind(Format('^',current_buffer_id,'$'), 'xg')
            // Get the id on the next line, unless we've hit bottom,
            // in which case get the id from the first line
            if Down()
                next_buffer_id = Val(GetText(1, CurrLineLen()))
            else
                BegFile()
                next_buffer_id = Val(GetText(1, CurrLineLen()))
            endif
        endif
    endif
    AbandonFile(temp_buffer)
    GotoBufferId(next_buffer_id)
end

proc PrevUnfiledFile()
    integer current_buffer_id = GetBufferId()
    integer temp_buffer = BuildUnfiledIdsBuffer()
    integer prev_buffer_id
    if temp_buffer and GotoBufferId(temp_buffer)
        if lFind(Format('^',current_buffer_id,'$'), 'xg')
            // Get the id on the preceding line, unless we've hit top,
            // in which case get the id from the last line
            if Up()
                prev_buffer_id = Val(GetText(1, CurrLineLen()))
            else
                EndFile()
                prev_buffer_id = Val(GetText(1, CurrLineLen()))
            endif
        endif
    endif
    AbandonFile(temp_buffer)
    GotoBufferId(prev_buffer_id)
end

proc NextFileInCurrentRing()
    integer current_buffer_id = GetBufferId()
    if Current_Ring_ID == 1
        NextFile()
    elseif Current_Ring_ID == 2
        NextUnfiledFile()
    else
        PushPosition()
        if GotoBufferID(Ring_Files_Buffer)
            if lFind(Format(Current_Ring_ID:MAX_RING_ID_WIDTH,':',current_buffer_id), 'g^$')
                if not Down()
                    BegFile()
                endif

                if lFind(Format(Current_Ring_ID:MAX_RING_ID_WIDTH,':{.*}$'), '^x')
                or lFind(Format(Current_Ring_ID:MAX_RING_ID_WIDTH,':{.*}$'), '^gx')

                    GotoBufferId(Val(GetFoundText(1)))

                    // Run any _ON_CHANGING_FILES_ hooks
                    PrevFile(_DONT_LOAD_)
                    NextFile()

                    KillPosition()
                    return()
                endif
            endif
        endif
        PopPosition()
    endif
end

proc PrevFileInCurrentRing()
    integer current_buffer_id = GetBufferId()
    if Current_Ring_ID == 1
        PrevFile()
    elseif Current_Ring_ID == 2
        PrevUnfiledFile()
    else
        PushPosition()
        if GotoBufferID(Ring_Files_Buffer)
            if lFind(Format(Current_Ring_ID:MAX_RING_ID_WIDTH,':',current_buffer_id), 'g^$')
                if CurrLine() == NumLines()
                    EndFile()
                    EndLine()
                endif
                if CurrLine() == 1
                    EndFile()
                    EndLine()
                    Right()
                endif

                if lFind(Format(Current_Ring_ID:MAX_RING_ID_WIDTH,':{.*}$'), '^xb')
                or (EndFile() and lFind(Format(Current_Ring_ID:MAX_RING_ID_WIDTH,':{.*}$'), '^xb'))

                    GotoBufferId(Val(GetFoundText(1)))

                    // Run any _ON_CHANGING_FILES_ hooks
                    PrevFile(_DONT_LOAD_)
                    NextFile()

                    KillPosition()
                    return()
                endif
            endif
        endif
        PopPosition()
    endif
end

proc ListRingsHelper()
    if Enable(ListRingsKeys)
        ListFooter(LR_FOOTER)
    endif
    Unhook(ListRingsHelper)
    BreakHookChain()
end

forward proc PromptedMergeRing(integer ring_id)
forward proc PromptedRenameRing(integer ring_id)
forward proc PromptedDeleteRing(integer ring_id)

proc ListRings(integer current_buffer_id)
    integer temp_names_buffer
    integer temp_ids_buffer
    integer ring_id
    integer list_action
    string  file_is_in_ring[1]
    string  ring_name[MAX_RING_NAME_WIDTH]
    integer current_ring_line      = 1
    integer selected_ring_id       = Current_Ring_ID
    integer ring_list_buffer_width = 56
    integer skip_ring
    integer next_selected_ring_id

    LoadProfileSettings()

    // If we were not passed an explicit current_buffer_id
    // then we assume we were called directly from a text
    // editing buffer.  In this case, use the current buffer id
    if not current_buffer_id
        current_buffer_id      = GetBufferID()
    endif

    PushPosition()

    temp_names_buffer = CreateTempBuffer()
    temp_ids_buffer   = CreateTempBuffer()

    if temp_names_buffer and temp_ids_buffer
        while 1
            EmptyBuffer(temp_names_buffer)
            EmptyBuffer(temp_ids_buffer)

            GotoBufferId(Ring_Names_Buffer)
            BegFile()

            repeat

                GotoBufferId(Ring_Names_Buffer)

                ring_id   = Val(GetText(1, MAX_RING_ID_WIDTH))
                ring_name = GetText(MAX_RING_ID_WIDTH+2, MAX_RING_NAME_WIDTH)

                GotoBufferId(Ring_Files_Buffer)
                if lFind(Format(ring_id:MAX_RING_ID_WIDTH, ':', current_buffer_id), '^$g')
                    file_is_in_ring = '+'
                else
                    file_is_in_ring = ' '
                endif

                skip_ring = 0
                if ring_id > 2 and not Show_Empty_Rings
                    if GotoBufferId(Ring_Files_Buffer)
                        if not lFind(Format('^',ring_id:MAX_RING_ID_WIDTH),'gx')
                            skip_ring = 1
                        endif
                    endif
                endif

                GotoBufferId(temp_names_buffer)

                if ring_id == selected_ring_id
                    current_ring_line = CurrLine()
                    if NumLines()
                        current_ring_line = current_ring_line + 1
                    endif
                endif

                if Length(ring_name) > ring_list_buffer_width
                    ring_list_buffer_width = Length(ring_name)
                endif

                if not skip_ring
                    AddLine(file_is_in_ring + ring_name)
                endif

                GotoBufferId(temp_ids_buffer)
                AddLine(Str(ring_id))

                GotoBufferId(Ring_Names_Buffer)

            until not Down()

            GotoBufferId(temp_names_buffer)

            GotoLine(current_ring_line)

            Hook(_LIST_STARTUP_, ListRingsHelper)

            list_action = List("Current Rings", ring_list_buffer_width)

            selected_ring_id = Val(GetTextFromBuffer(temp_ids_buffer, CurrLine(), 1, MAX_RING_ID_WIDTH))

            if not list_action
                break
            endif

            case list_action
                when LR_TOGGLE_BUFFER_IN_RING, LR_TOGGLE_BUFFER_IN_RING_MOVE_DOWN

                    // Don't allow toggling for special [ all files ] ring

                    if selected_ring_id > 0

                        if GetText(1, 1) == ' '
                            AddBufferToRing(current_buffer_id, selected_ring_id)
                        else
                            RemoveBufferFromRing(current_buffer_id, selected_ring_id)
                        endif
                    endif

                    if list_action == LR_TOGGLE_BUFFER_IN_RING_MOVE_DOWN
                        if not Down()
                            BegFile()
                        endif

                        selected_ring_id = Val(GetTextFromBuffer(Ring_Names_Buffer, CurrLine(), 1, MAX_RING_ID_WIDTH))

                    endif

                when LR_RING_PROPERTIES
                    if selected_ring_id > 2
                        PrepareRingProperties(selected_ring_id)
                        RingPropertiesMenu()
                        CommitRingProperties(selected_ring_id)
                    else
                        PrepareDefaultRingProperties()

                        if selected_ring_id == 1
                            Ring_Prop_Name = All_Buffers_Ring_Name
                        else
                            Ring_Prop_Name = Unfiled_Buffers_Ring_Name
                        endif

                        DefaultRingPropertiesMenu()
                        CommitDefaultRingProperties()
                    endif
                when LR_DEL_RING
                    if selected_ring_id > 2
                        // Find out what the next selected line should be
                        // so that after the delete the display doesn't get
                        // screwed up.  This should be the next line in the
                        // temp_ids_buffer, unless we're on the last line
                        // already, in which case it will be the previous line

                        if CurrLine() == NumLines()
                            next_selected_ring_id = Val(GetTextFromBuffer(temp_ids_buffer, CurrLine() - 1, 1, MAX_BUFFER_ID_WIDTH))
                        else
                            next_selected_ring_id = Val(GetTextFromBuffer(temp_ids_buffer, CurrLine() + 1, 1, MAX_BUFFER_ID_WIDTH))
                        endif

                        PromptedDeleteRing(selected_ring_id)

                        selected_ring_id = next_selected_ring_id
                    endif
                when LR_MERGE_RING
                    if selected_ring_id > 2
                        PromptedMergeRing(selected_ring_id)
                    endif
                when LR_COPY_RING
                    if selected_ring_id > 2
                        CopyRing(selected_ring_id)
                    endif
                when LR_MOVE_RING_UP
                    MoveRingUp(selected_ring_id)

                when LR_MOVE_RING_DOWN
                    MoveRingDown(selected_ring_id)

                when LR_RENAME_RING
                    PromptedRenameRing(selected_ring_id)

                when LR_NEW_RING
                    NewRing(GetNextUnnamedRingName())

                when LR_HELP
                    QuickHelp(ListRingsHelp)

                when LR_TOGGLE_SHOW_EMPTY_RINGS
                    Show_Empty_Rings = not Show_Empty_Rings

                when LR_CHANGE_RING, LR_CHANGE_RING_KEEPING_FILE

                    GotoBufferId(current_buffer_id)

                    ChangeRing(selected_ring_id)

                    if list_action == LR_CHANGE_RING_KEEPING_FILE
                        AddBufferToRing(current_buffer_id, selected_ring_id)
                        GotoBufferId(current_buffer_id)
                    endif

                    KillPosition()
                    AbandonFile(temp_names_buffer)
                    AbandonFile(temp_ids_buffer)
                    return()

                when LR_FILTER_ALL_BUFFERS
                    FilterAllBuffers()

            endcase
        endwhile

        AbandonFile(temp_names_buffer)
        AbandonFile(temp_ids_buffer)
    endif

    PopPosition()

end


integer proc PickRing(
    string  pickrings_title,
    integer initial_selected_ring_id,
    integer hide_special_rings,
    integer hide_empty_rings,
    integer hide_other_ring
)
    integer temp_ids_buffer
    integer temp_names_buffer
    integer ring_id
    integer current_buffer_line
    integer selected_ring_id
    integer ring_list_buffer_width = 56
    string  ring_name[MAX_RING_NAME_WIDTH]
    integer skip_ring

    PushPosition()

    temp_ids_buffer   = CreateTempBuffer()
    temp_names_buffer = CreateTempBuffer()

    GotoBufferId(Ring_Names_Buffer)
    BegFile()
    BegLine()

    if temp_ids_buffer and temp_names_buffer
        repeat

            GotoBufferId(Ring_Names_Buffer)

            ring_id   = Val(GetText(1, MAX_RING_ID_WIDTH))
            ring_name = GetText(MAX_RING_ID_WIDTH+2, MAX_RING_NAME_WIDTH)

            GotoBufferId(temp_ids_buffer)

            skip_ring = 0

            if hide_empty_rings and ring_id > 2
                if GotoBufferId(Ring_Files_Buffer)
                    if not lFind(Format('^',ring_id:MAX_RING_ID_WIDTH),'gx')
                        skip_ring = 1
                    endif
                endif
            endif

            if ring_id <= 2 and hide_special_rings
                skip_ring = 1
            endif

            if ring_id > 2 and hide_other_ring == ring_id
                skip_ring = 1
            endif

            if not skip_ring

                if ring_id == initial_selected_ring_id
                    current_buffer_line = CurrLine()
                    if NumLines()
                        current_buffer_line = current_buffer_line + 1
                    endif
                endif

                if Length(ring_name) > ring_list_buffer_width
                    ring_list_buffer_width = Length(ring_name)
                endif

                if not skip_ring
                    GotoBufferId(temp_names_buffer)
                    AddLine(ring_name)
                    GotoBufferId(temp_ids_buffer)
                    AddLine(Str(ring_id))
                endif

            endif

            GotoBufferId(Ring_Names_Buffer)

        until not Down()

        if not NumLines()
            PopPosition()
            AbandonFile(temp_ids_buffer)
            AbandonFile(temp_names_buffer)
            return(0)
        endif

        GotoBufferId(temp_names_buffer)
        GotoLine(current_buffer_line)

        if not List(pickrings_title, ring_list_buffer_width)
            PopPosition()
            AbandonFile(temp_ids_buffer)
            AbandonFile(temp_names_buffer)
            return(0)
        endif

        selected_ring_id = Val(GetTextFromBuffer(temp_ids_buffer, CurrLine(), 1, MAX_RING_ID_WIDTH))

    endif

    PopPosition()

    AbandonFile(temp_ids_buffer)
    AbandonFile(temp_names_buffer)

    return(selected_ring_id)
end


proc ExecViewPlugin(string plugin_name, integer ids_buffer, integer names_buffer)
    GotoBufferId(ids_buffer)
    BegFile()
    BegLine()
    GotoBufferId(names_buffer)
    BegFile()
    BegLine()

    if TryLoadMacro(plugin_name)
        ExecMacro(Format(plugin_name, ' ', ids_buffer, ' ', names_buffer))
    else
        Warn("Could not load view plugin name: " + plugin_name)
    endif
end



// This routine knows about the data structure used by PickBuffers,
// which is two parallel buffers, one with names and the other with ids.
//
// This routine does the following:
//
// * creates a third buffer with name and id in fixed width fields.
// * sorts this new buffer using Sort().
// * steps through this buffer in reverse order doing the following:
//     * take the buffer id (and the ring id)
//     * find the line containing this ring/buffer combo in the
//       global Ring_Files buffer
//     * move this line to the top of the Ring_Files buffer, using
//       MoveBufferLine()
//
// Because we move through the sorted buffer in reverse, and add these
// lines to the top of the Ring_Files buffer, they will end up in
// order there.
//
// The reason we are using this data structure directly is
// that PickBuffers may have transformed the names in the names buffer,
// and we want to sort on display names, not filenames

constant SORT_LIMIT = MAXSTRINGLEN - MAX_RING_ID_WIDTH
proc SortBufferList(integer ring_id, integer ids_buffer, integer names_buffer, integer sort_flags)
    integer sort_buffer = CreateTempBuffer()
    integer buffer_id
    string buffer_name[SORT_LIMIT]
    PushPosition()

    if sort_buffer

        // Merge the ids and names buffers into a single
        // name/id list that we can sort

        GotoBufferId(ids_buffer)
        BegFile()
        GotoBufferId(names_buffer)
        BegFile()
        do NumLines() times
            GotoBufferId(ids_buffer)
            buffer_id = Val(Trim(GetText(1, CurrLineLen())))
            Down()
            GotoBufferId(names_buffer)
            buffer_name = Trim(GetText(1, CurrLineLen()))
            Down()
            GotoBufferId(sort_buffer)

            // Put buffer_id on the SORT_LIMIT'th column
            AddLine(Format(buffer_name:-SORT_LIMIT, buffer_id))
        enddo

        // Mark all the lines in sort_buffer,
        // then sort it, using the flags we were provided

        GotoBufferId(sort_buffer)
        PushBlock()
        MarkLine(1, NumLines())
        BegFile()
        BegLine()
        Sort(sort_flags)
        BegFile()
        BegLine()
        PopBlock()

        EndFile()

        // Work through buffer list backwards, finding each id's line in the
        // Ring_Files_Buffer and moving that line to the top of Ring_Files_Buffer
        repeat
            buffer_id   = Val(GetText(SORT_LIMIT + 1, CurrLineLen() - SORT_LIMIT + 1))
            buffer_name = GetText(1, SORT_LIMIT)
            GotoBufferId(Ring_Files_Buffer)
            if lFind(Format('^',ring_id:MAX_RING_ID_WIDTH, ':', buffer_id , '$'), 'xg')
                MoveBufferLine(Ring_Files_Buffer, CurrLine(), 1)
            endif
            GotoBufferId(sort_buffer)
        until not Up()

        AbandonFile(sort_buffer)
    endif

    PopPosition()
end

proc ListBuffersHelper()
    if Enable(ListBuffersKeys)
        ListFooter(LB_FOOTER)
    endif
    Unhook(ListBuffersHelper)
    BreakHookChain()
end

proc PickBuffersHelper()
    if Enable(ListBuffersKeys)
        ListFooter(PB_FOOTER)
    endif
    Unhook(PickBuffersHelper)
    BreakHookChain()
end

forward integer proc CreateInstantFilter(integer from_ring_id)
integer proc PickBuffers(string list_title, integer ring_id, integer other_ring_id)
    integer temp_names_buffer
    integer temp_ids_buffer
    integer buffer_id
    integer selected_buffer_id = GetBufferId()
    integer initial_buffer_id  = GetBufferId()
    integer list_action
    string  buffer_name[MAXSTRINGLEN]
    string  view_plugins[128]
    string  file_highlighted[1]
    integer current_buffer_line      = 1
    integer buffer_list_buffer_width = 56
    integer ocf_hook_state
    integer ln
    integer p
    integer pick_ring_id
    integer next_selected_buffer_id

    LoadProfileSettings()

    PushPosition()

    temp_names_buffer = CreateTempBuffer()
    temp_ids_buffer   = CreateTempBuffer()

    if temp_names_buffer and temp_ids_buffer
        while 1

            if ring_id > 2
                PrepareRingProperties(ring_id)
            else
                PrepareDefaultRingProperties()
            endif

            view_plugins = Ring_Prop_View_Plugins

            EmptyBuffer(temp_ids_buffer)

            GotoBufferId(Ring_Files_Buffer)

            if ring_id == RING_ID_ALL
                ocf_hook_state = SetHookState(OFF, _ON_CHANGING_FILES_)

                do NumFiles() times
                    NextFile(_DONT_LOAD_)
                    buffer_id  = GetBufferId()
                    GotoBufferId(temp_ids_buffer)
                    AddLine(Str(buffer_id))
                    if buffer_id == selected_buffer_id
                        current_buffer_line = CurrLine()
                    endif
                    GotoBufferId(buffer_id)
                enddo
                SetHookState(ocf_hook_state, _ON_CHANGING_FILES_)

            elseif ring_id == RING_ID_UNFILED

                ocf_hook_state = SetHookState(OFF, _ON_CHANGING_FILES_)
                do NumFiles() times
                    NextFile(_DONT_LOAD_)
                    buffer_id  = GetBufferId()

                    GotoBufferId(Ring_Files_Buffer)
                    if not lFind(Format('^','.':MAX_RING_ID_WIDTH:'.',':',buffer_id,'$'),'gx')
                        GotoBufferId(temp_ids_buffer)
                        AddLine(Str(buffer_id))
                        if buffer_id == selected_buffer_id
                            current_buffer_line = CurrLine()
                        endif
                    endif

                    GotoBufferId(buffer_id)
                enddo
                SetHookState(ocf_hook_state, _ON_CHANGING_FILES_)

            else                            // Ordinary ring

                GotoBufferId(Ring_Files_Buffer)
                BegFile()
                BegLine()

                repeat

                    if lFind(Format('^', ring_id:MAX_RING_ID_WIDTH, ':{.*}$'), 'xc')
                        buffer_id = Val(GetFoundText(1))

                        if GotoBufferId(buffer_id)
                            GotoBufferId(temp_ids_buffer)
                            AddLine(Str(buffer_id))
                            if buffer_id == selected_buffer_id
                                current_buffer_line = CurrLine()
                            endif
                        else
                            // The buffer no longer exists,
                            // so remove it from the ring_files list

                            // These contortions are due to the fact that
                            // KillLine() moves the cursor down one line
                            // (unless, of course, it is already on the last line)
                            if (CurrLine() == NumLines()) and KillLine()
                                Up()
                            endif
                        endif

                    endif

                    GotoBufferId(Ring_Files_Buffer)

                until not Down()

            endif

            GotoBufferId(temp_ids_buffer)
            ln = NumLines()
            EmptyBuffer(temp_names_buffer)
            GotoBufferId(temp_names_buffer)
            for p = 1 to ln
                AddLine('')
            endfor

            if Enable_View_Plugins
                for p = 1 to NumTokens(view_plugins, ';')
                    ExecViewPlugin(Trim(GetToken(view_plugins, ';', p)), temp_ids_buffer, temp_names_buffer)
                endfor
            endif

            // Insert filename for buffers not handled by plugins

            GotoBufferId(temp_ids_buffer)
            BegFile()
            BegLine()

            GotoBufferId(temp_names_buffer)
            BegFile()
            BegLine()

            if NumLines()

                repeat

                    GotoBufferId(temp_names_buffer)

                    if not CurrLineLen()
                        GotoBufferId(temp_ids_buffer)
                        if GotoBufferId(Val(GetText(1, MAX_BUFFER_ID_WIDTH)))
                            if Show_Names_Only
                                buffer_name = SplitPath(CurrFileName(),_NAME_|_EXT_)
                            else
                                buffer_name = CurrFileName()
                            endif
                            GotoBufferId(temp_names_buffer)
                            BegLine()
                            InsertText(buffer_name, _OVERWRITE_)
                        endif
                    endif

                    buffer_list_buffer_width = Max(buffer_list_buffer_width, CurrLineLen())

                    GotoBufferId(temp_names_buffer)
                    Down()
                    GotoBufferId(temp_ids_buffer)

                until not Down()

                if other_ring_id

                    // Add '+' at start of line for buffers in other ring

                    GotoBufferId(temp_names_buffer)
                    BegFile()
                    BegLine()

                    GotoBufferId(temp_ids_buffer)
                    BegFile()
                    BegLine()

                    for ln = 1 to NumLines()
                        GotoBufferId(Ring_Files_Buffer)
                        file_highlighted = iif(
                            lFind(
                                Format(
                                    '^',other_ring_id:MAX_RING_ID_WIDTH, ':',
                                    Trim(GetTextFromBuffer(temp_ids_buffer, ln, 1, MAX_BUFFER_ID_WIDTH)),
                                    '$'
                                ),
                                'xg'
                            ),
                            '+',
                            ' '
                        )

                        GotoBufferId(temp_names_buffer)
                        BegLine()
                        InsertText(file_highlighted, _INSERT_)

                        GotoBufferId(temp_names_buffer)
                        Down()
                        GotoBufferId(temp_ids_buffer)

                    endfor

                else

                    // Add '*' at start of line for changed files

                    GotoBufferId(temp_names_buffer)
                    BegFile()
                    BegLine()

                    GotoBufferId(temp_ids_buffer)
                    BegFile()
                    BegLine()

                    repeat
                        GotoBufferId(Val(GetTextFromBuffer(temp_ids_buffer, CurrLine(), 1, 20)))
                        file_highlighted = iif(FileChanged(), '*', ' ')

                        GotoBufferId(temp_names_buffer)
                        BegLine()
                        InsertText(file_highlighted, _INSERT_)

                        GotoBufferId(temp_names_buffer)
                        Down()
                        GotoBufferId(temp_ids_buffer)

                    until not Down()

                endif

            endif
            GotoBufferId(temp_names_buffer)

            GotoLine(current_buffer_line)

            if other_ring_id
                Hook(_LIST_STARTUP_, PickBuffersHelper)
            else
                Hook(_LIST_STARTUP_, ListBuffersHelper)
            endif

            p = NumLines()
            list_action = List(iif(Length(list_title), list_title, Str(p) + ' Buffer(s) in Ring "' + FindRingNameByID(ring_id) + '"'), buffer_list_buffer_width)

            selected_buffer_id = Val(GetTextFromBuffer(temp_ids_buffer, CurrLine(), 1, MAX_BUFFER_ID_WIDTH))

            if not list_action
                break
            endif

            // Don't actually process the command if there are no
            // files!

            if not NumLines()
                selected_buffer_id = 0
            endif

            if other_ring_id
                case list_action
                    when LB_HELP
                        QuickHelp(ListBuffersHelpOtherRing)

                    when LB_CHANGE_FILE
                        if selected_buffer_id
                            AddBufferToRing(selected_buffer_id, other_ring_id)

                            KillPosition()
                            AbandonFile(temp_names_buffer)
                            AbandonFile(temp_ids_buffer)
                            return(selected_buffer_id)
                        endif

                    when LB_TOGGLE_FILE, LB_TOGGLE_FILE_MOVE_DOWN
                        if selected_buffer_id
                            if GetText(1, 1) == '+'
                                RemoveBufferFromRing(selected_buffer_id, other_ring_id)
                            else
                                AddBufferToRing(selected_buffer_id, other_ring_id)
                            endif

                            if list_action == LB_TOGGLE_FILE_MOVE_DOWN
                                if not Down()
                                    BegFile()
                                endif
                                selected_buffer_id = Val(GetTextFromBuffer(temp_ids_buffer, CurrLine(), 1, MAX_BUFFER_ID_WIDTH))
                            endif
                        endif

                    when LB_SELECT_NONE
                        GotoBufferID(temp_ids_buffer)
                        BegFile()
                        repeat
                            RemoveBufferFromRing(Val(GetText(1, MAX_BUFFER_ID_WIDTH)), other_ring_id)
                        until not Down()

                    when LB_SELECT_ALL
                        GotoBufferID(temp_ids_buffer)
                        BegFile()
                        repeat
                            AddBufferToRing(Val(GetText(1, MAX_BUFFER_ID_WIDTH)), other_ring_id)
                        until not Down()
                endcase

            else
                case list_action
                    when LB_HELP
                        QuickHelp(ListBuffersHelp)

                    when LB_CHANGE_FILE
                        if selected_buffer_id
                            GotoBufferId(selected_buffer_id)

                            // Run any _ON_CHANGING_FILES_ hooks
                            PrevFile(_DONT_LOAD_)
                            NextFile()

                            KillPosition()
                            AbandonFile(temp_names_buffer)
                            AbandonFile(temp_ids_buffer)
                            return(selected_buffer_id)
                        endif

                    when LB_SAVE_FILE
                        if selected_buffer_id
                            GotoBufferId(selected_buffer_id)
                            mSaveFile()
                        endif

                    when LB_QUIT_FILE_THIS_RING

                        if selected_buffer_id

                            // Find out what the next selected line should be
                            // so that after the delete the display doesn't get
                            // screwed up.  This should be the next line in the
                            // temp_ids_buffer, unless we're on the last line
                            // already, in which case it will be the previous line

                            if CurrLine() == NumLines()
                                next_selected_buffer_id = Val(GetTextFromBuffer(temp_ids_buffer, CurrLine() - 1, 1, MAX_BUFFER_ID_WIDTH))
                            else
                                next_selected_buffer_id = Val(GetTextFromBuffer(temp_ids_buffer, CurrLine() + 1, 1, MAX_BUFFER_ID_WIDTH))
                            endif

                            // We Need to unhook OnFirstEdit here, because
                            // as soon as we quit a file that has never been
                            // loaded, it will be loaded for the first time,
                            // and at that point it will be placed into the
                            // current ring, defeating its own deletion!
                            //

                            Unhook(OnFirstEdit)

                            if ring_id == RING_ID_ALL
                                if GotoBufferId(selected_buffer_id)
                                    mQuitFile()
                                    PushPosition()
                                    GotoBufferId(Ring_Files_Buffer)
                                    BegFile()
                                    BegLine()
                                    while lFind(Format('^','.':MAX_RING_ID_WIDTH:'.', ':', selected_buffer_id, '$'), 'gx')
                                        KillLine()
                                    endwhile
                                    PopPosition()
                                endif
                            elseif ring_id == RING_ID_UNFILED
                                if GotoBufferId(selected_buffer_id)
                                    mQuitFile()
                                endif
                            else
                                RemoveBufferFromRing(selected_buffer_id, ring_id)

                                if Quit_Orphaned_Files
                                    GotoBufferId(Ring_Files_Buffer)
                                    if not lFind(Format('^','.':MAX_RING_ID_WIDTH:'.', ':', selected_buffer_id, '$'), 'gx')
                                        if GotoBufferId(selected_buffer_id)
                                            if not Prompt_To_Quit_Orphaned_Files or YesNo("File is no longer in any rings.  Close it?")
                                                mQuitFile()
                                            endif
                                        endif
                                    endif
                                endif
                            endif

                            selected_buffer_id = next_selected_buffer_id
                            Hook(_ON_FIRST_EDIT_, OnFirstEdit)

                        endif

                    when LB_QUIT_FILE_ALL_RINGS
                        if selected_buffer_id
                            if GotoBufferId(selected_buffer_id)
                                mQuitFile()

                                GotoBufferId(Ring_Files_Buffer)
                                BegFile()
                                BegLine()
                                while lFind(Format('^','.':MAX_RING_ID_WIDTH:'.', ':', selected_buffer_id, '\c$'), 'x')
                                    KillLine()
                                endwhile

                            endif
                        endif

                    when LB_MOVE_FILE_UP
                        if selected_buffer_id
                            ln = -1
                            GotoBufferId(Ring_Files_Buffer)
                            BegFile()
                            BegLine()
                            while lFind(Format('^',ring_id:MAX_RING_ID_WIDTH, ':{.*}\c$'), 'x')
                                if Val(GetFoundText(1)) == selected_buffer_id
                                    MoveBufferLine(Ring_Files_Buffer, CurrLine(), ln)
                                    break
                                else
                                    ln = CurrLine()
                                endif
                            endwhile
                        endif
                    when LB_MOVE_FILE_DOWN
                        if selected_buffer_id
                            GotoBufferId(Ring_Files_Buffer)
                            ln = 1
                            EndFile()

                            // Have to add a line at the end of the file
                            // so that the backwards regex will be able
                            // to match on the last line.

                            AddLine()

                            EndLine()
                            while lFind(Format('^\c',ring_id:MAX_RING_ID_WIDTH, ':{.*}$'), 'bx')
                                if Val(GetFoundText(1)) == selected_buffer_id
                                    MoveBufferLine(Ring_Files_Buffer, CurrLine(), ln)
                                    break
                                else
                                    ln = CurrLine()
                                endif
                            endwhile

                            // Now have to remove the spurious line we added.
                            EndFile()
                            KillLine()
                        endif

                    when LB_ADD_BUFFERS_FROM_OTHER_RING
                        pick_ring_id = PickRing("Add files from other ring:", 1, 0, 1, ring_id)
                        selected_buffer_id = PickBuffers("Select Files", pick_ring_id, Current_Ring_ID)

                    when LB_CURRENT_RING_PROPERTIES
                        if Current_Ring_ID > 2
                            PrepareRingProperties(Current_Ring_ID)
                            RingPropertiesMenu()
                            CommitRingProperties(Current_Ring_ID)
                        else
                            PrepareDefaultRingProperties()
                            DefaultRingPropertiesMenu()
                            CommitDefaultRingProperties()
                        endif

                    when LB_SORT_BUFFERS_IN_RING
                        if selected_buffer_id
                            SortBufferList(Current_Ring_ID, temp_ids_buffer, temp_names_buffer, Default_Sort_Choice)
                        endif

                    when LB_SORT_BUFFERS_IN_RING_MENU
                        if selected_buffer_id
                            SortMenu()
                            SortBufferList(Current_Ring_ID, temp_ids_buffer, temp_names_buffer, Sort_Choice)
                        endif

                    when LB_CREATE_INSTANT_FILTER
                        Instant_Filter_Include = ''
                        Instant_Filter_Exclude = ''
                        Instant_Filter_Flags   = IF_USE_CURREXT | IF_COPY | IF_THIS_RING
                        InstantFilterMenu()
                        if Length(Instant_Filter_Include) or Length(Instant_Filter_Exclude)
                            ChangeRing(CreateInstantFilter(Current_Ring_Id))
                            ring_id = Current_Ring_ID
                        endif
                endcase

            endif
            // Common actions:
            case list_action
                    when LB_TOGGLE_NAME_ONLY
                        Show_Names_Only = not Show_Names_Only

                    when LB_TOGGLE_PLUGINS
                        Enable_View_Plugins = not Enable_View_Plugins

                    when LB_CHANGE_RING
                        ListRings(initial_buffer_id)
                        ring_id = Current_Ring_ID

                    when LB_CHANGE_RING_TO_ALL
                        ChangeRing(RING_ID_ALL)
                        ring_id = Current_Ring_ID

                    when LB_FILTER_ALL_BUFFERS
                        FilterAllBuffers()

            endcase
        endwhile

        AbandonFile(temp_names_buffer)
        AbandonFile(temp_ids_buffer)
    endif

    PopPosition()
    return(0)
end

proc ListBuffers()
    // ExecMacro('ringpos -z')  // Suspend
    PickBuffers('',Current_Ring_ID,0)
    // ExecMacro('ringpos -r')  // Resume
    // ExecMacro('ringpos -t')  // TrackPosition
end

proc PromptedDeleteRing(integer ring_id)
    integer quit_orphans = Quit_Orphaned_Files
    if Prompt_To_Quit_Orphaned_Files
        quit_orphans = YesNo("Quit Orphaned Files?")
    endif
    DeleteRing(ring_id, quit_orphans)
end

proc PromptedRenameRing(integer ring_id)
    string ring_name[MAX_RING_NAME_WIDTH] = FindRingNameByID(ring_id)

    while 1
        if Ask("Rename ring to:", ring_name, Ring_Prompt_History)
            if FindRingIDByName(ring_name)
                Message("Ring " + ring_name + " already exists")
            else
                RenameRing(ring_id, ring_name)
                break
            endif
        else
            break
        endif
    endwhile
end

proc PromptedMergeRing(integer ring_id)
    integer other_ring_id
    integer new_ring_id
    string merged_ring_name[MAX_RING_NAME_WIDTH]
    string ring_name[MAX_RING_NAME_WIDTH] = FindRingNameByID(ring_id)

    other_ring_id = PickRing("Merge " + ring_name + " with:", 1, 1, 0, ring_id)

    if other_ring_id
        merged_ring_name = ring_name + ' + ' + FindRingNameByID(other_ring_id)
        while 1
            if Ask("Merged Name: ", merged_ring_name, Ring_Prompt_History)
                new_ring_id = FindRingIDByName(merged_ring_name)
                if new_ring_id
                    if new_ring_id == ring_id or new_ring_id == other_ring_id
                        if YesNo("Replace " + merged_ring_name + "?") == 1
                            break
                        endif
                    else
                        Message("Can only merge into source, target or new ring")
                    endif
                else
                    new_ring_id = CopyRing(ring_id)
                    RenameRing(new_ring_id, merged_ring_name)
                    break
                endif
            else
                return()
            endif
        endwhile

        if new_ring_id == ring_id
            MergeRing(other_ring_id, ring_id)
        elseif new_ring_id == other_ring_id
            MergeRing(ring_id, other_ring_id)
        else
            MergeRing(other_ring_id, new_ring_id)
        endif

    endif

end

proc mHWindow()
    integer saved_hook_state = SetHookState(_ON_CHANGING_FILES_, OFF)

    // ExecMacro('ringpos -z') // Suspend
    HWindow()
    PrevFile()
    SetHookState(_ON_CHANGING_FILES_, saved_hook_state)
    // ExecMacro('ringpos -r') // Resume
    if Split_To_Same_File
        if Scroll_After_HWindow
            PageDown()
            ScrollDown()
            ScrollDown()
        endif
    else
        NextFileInCurrentRing()
    endif
end

proc mVWindow()
    integer saved_hook_state = SetHookState(_ON_CHANGING_FILES_, OFF)
    // ExecMacro('ringpos -z') // Suspend
    VWindow()
    PrevFile()
    SetHookState(_ON_CHANGING_FILES_, saved_hook_state)
    // ExecMacro('ringpos -r') // Resume
    if not Split_To_Same_File
        NextFileInCurrentRing()
    endif
end

proc Cleanup()
    if not Macro_Cleanup_Called
        Macro_Cleanup_Called = 1
        SaveRingsToProfile()
        AbandonFile(Ring_Names_Buffer)
        AbandonFile(Ring_Editor_Settings_Buffer)
        AbandonFile(Ring_Properties_Buffer)
        AbandonFile(Ring_Files_Buffer)
        AbandonFile(Filter_Buffer)
    endif
end

proc ClearFilterQueue()
    if Filter_Buffer
        EmptyBuffer(Filter_Buffer)
    endif
end

proc QueueFileForFiltering(integer buffer_id, integer from_ring_id)
    integer saved_buffer_id = GetBufferId()
    string filename[MAXSTRINGLEN]
    string ext_actual[MAXSTRINGLEN]
    string ext_currext[MAXSTRINGLEN]

    GotoBufferID(buffer_id)
    filename = SplitPath(CurrFileName(), _DRIVE_|_PATH_|_NAME_)

    ext_actual = CurrExt()

    if Is_Currext_Available and ExecMacro('Currext')
        ext_currext = GetGlobalStr('CurrExt')
    endif
    if not Length(ext_currext)
        ext_currext = ext_actual
    endif
    GotoBufferID(Filter_Buffer)

    filename    = Lower(filename)
    ext_actual  = Lower(ext_actual)
    ext_currext = Lower(ext_currext)

    AddLine(Format('0:', from_ring_id:MAX_RING_ID_WIDTH:'0',':',buffer_id:MAX_BUFFER_ID_WIDTH:'0',':0:',filename,ext_actual))
    AddLine(Format('0:', from_ring_id:MAX_RING_ID_WIDTH:'0',':',buffer_id:MAX_BUFFER_ID_WIDTH:'0',':1:',filename,ext_currext))

    GotoBufferId(saved_buffer_id)
end

proc QueueAllFilesForFiltering()
    integer saved_buffer_id = GetBufferId()
    integer buffer_id = 0
    string filename[MAXSTRINGLEN]
    string ext_actual[MAXSTRINGLEN]
    string ext_currext[MAXSTRINGLEN]

    // Sample code right out of docs for NumFiles() !!

    integer n  = NumFiles() + (BufferType() <> _NORMAL_)

    while n
        if BufferType() == _NORMAL_
            buffer_id = GetBufferId()

            GotoBufferID(buffer_id)

            filename = SplitPath(CurrFileName(), _DRIVE_|_PATH_|_NAME_)

            ext_actual = CurrExt()

            if Is_Currext_Available and ExecMacro('Currext')
                ext_currext = GetGlobalStr('CurrExt')
            endif
            if not Length(ext_currext)
                ext_currext = ext_actual
            endif
            GotoBufferID(Filter_Buffer)

            filename    = Lower(filename)
            ext_actual  = Lower(ext_actual)
            ext_currext = Lower(ext_currext)

            AddLine(Format('0:', '0':MAX_RING_ID_WIDTH:'0',':',buffer_id:MAX_BUFFER_ID_WIDTH:'0',':0:',filename,ext_actual))
            AddLine(Format('0:', '0':MAX_RING_ID_WIDTH:'0',':',buffer_id:MAX_BUFFER_ID_WIDTH:'0',':1:',filename,ext_currext))
        endif
        GotoBufferID(buffer_id)
        NextFile(_DONT_LOAD_)
        n = n - 1
    endwhile

    GotoBufferId(saved_buffer_id)
end

integer proc RunRingFiltersOnFilterQueue(integer ring_id, integer flag)
    integer stolen = FALSE
    string  filter[MAXSTRINGLEN]
    integer buffer_id
    integer killed_line
    integer original_ring_id
    integer any_matches = FALSE
    integer p

    PushPosition()
    PrepareRingProperties(ring_id)

    if Filter_Buffer
        // Clear the matches in the queue from
        // the last match, by replacing '1' with '0'
        // in the first column
        GotoBufferId(Filter_Buffer)
        lReplace('^1', '0', 'gnx')

        if Length(Ring_Prop_Include_Filter_Regex)
            for p = 1 to NumTokens(Ring_Prop_Include_Filter_Regex,';')
                filter = GetToken(Ring_Prop_Include_Filter_Regex, ';', p)

                if Ring_Prop_Flags & RP_USE_CURREXT
                    filter = '^[01]:[0-9]#:[0-9]#:1:' + filter + '$'
                else
                    filter = '^[01]:[0-9]#:[0-9]#:0:' + filter + '$'
                endif

                GotoBufferId(Filter_Buffer)

                BegFile()
                BegLine()

                // Debug('[INC] searching for : ' +filter)
                while lFind(filter, 'x')
                    BegLine()
                    // Debug('[INC] matched on : ' +filter)
                    InsertText('1', _OVERWRITE_)
                    any_matches = TRUE
                    Right() // so we don't get stuck on the same line
                endwhile
            endfor
        endif

        if Length(Ring_Prop_Exclude_Filter_Regex)
            for p = 1 to NumTokens(Ring_Prop_Exclude_Filter_Regex,';')
                filter = GetToken(Ring_Prop_Exclude_Filter_Regex, ';', p)

                if Ring_Prop_Flags & RP_USE_CURREXT
                    filter = '^[01]:[0-9]#:[0-9]#:1:' + filter + '$'
                else
                    filter = '^[01]:[0-9]#:[0-9]#:0:' + filter + '$'
                endif

                GotoBufferId(Filter_Buffer)

                BegFile()
                BegLine()
                // Debug('[EXC] searching for : ' +filter)
                while lFind(filter, 'x')
                    BegLine()
                    // Debug('[EXC] matched on : ' +filter)
                    InsertText('0', _OVERWRITE_)
                    any_matches = TRUE
                    Right() // so we don't get stuck on the same line
                endwhile
            endfor
        endif

        GotoBufferId(Filter_Buffer)

        BegFile()

        // 0:00000:00000:filename

        if any_matches
            repeat
                killed_line = 0
                if Val(GetText(1,1))
                    original_ring_id   = Val(GetText(3, MAX_RING_ID_WIDTH))
                    buffer_id          = Val(GetText(4 + MAX_RING_ID_WIDTH, MAX_BUFFER_ID_WIDTH))

                    // PushPosition()
                    // UpdateDisplay()
                    // GotoBufferId(buffer_id)
                    // Debug('Filtered: ' + CurrFileName() + ' to ' + FindRingNameByID(ring_id))
                    // PopPosition()

                    AddBufferToRing(buffer_id, ring_id)
                    if flag & F_REMOVE_FROM_ORIGINAL_RING
                        RemoveBufferFromRing(buffer_id, original_ring_id)
                    endif
                    if Ring_Prop_Flags & RP_STEAL_FILTERED_FILES
                        KillLine()
                        killed_line = 1
                        stolen = ring_id
                    endif
                endif
            until (not killed_line) and (not Down())
        endif
    else
        Warn('Filter_Buffer does not exist')
    endif

    PopPosition()

    return(stolen)
end

integer proc FilterBuffer(integer buffer_id)
    integer ring_id
    integer stolen = FALSE

    PushPosition()

    ClearFilterQueue()
    QueueFileForFiltering(buffer_id, 0)

    if GotoBufferId(Ring_Names_Buffer)
        BegFile()
        BegLine()

        while lFind(Format('^{','':MAX_RING_ID_WIDTH:'.','}:\c'), 'x')
            ring_id = Val(GetFoundText(1))
            stolen = RunRingFiltersOnFilterQueue(ring_id, 0)
            if stolen
                break
            endif
        endwhile
    endif

    ClearFilterQueue()

    PopPosition()
    return(stolen)
end

proc FilterAllBuffers()
    integer ring_id

    PushPosition()
    ClearFilterQueue()
    QueueAllFilesForFiltering()

    if GotoBufferId(Ring_Names_Buffer)
        BegFile()

        while lFind(Format('^{','':MAX_RING_ID_WIDTH:'.','}:\c'), 'x')
            ring_id = Val(GetFoundText(1))
            RunRingFiltersOnFilterQueue(ring_id, 0)
        endwhile
    endif

    ClearFilterQueue()
    PopPosition()

end

integer proc CreateInstantFilter(integer from_ring_id)
    integer buffer_id             = 0
    string ringname[MAXSTRINGLEN] = ''

    integer new_ring_id           = 0

    PushPosition()

    // Include only:
    //     <include>
    // Exclude only:
    //     Excluding <exclude>
    // Include and Exclude:
    // <include> excluding <exclude>

    if Length(Instant_Filter_Include) and Length(Instant_Filter_Exclude)
        ringname = Instant_Filter_Include + ' excl: ' + Instant_Filter_Exclude
    elseif Length(Instant_Filter_Include)
        ringname = Instant_Filter_Include
    elseif Length(Instant_Filter_Exclude)
        ringname = 'excl: ' + Instant_Filter_Exclude
    endif

    if (from_ring_id <> RING_ID_ALL) and (Instant_Filter_Flags & IF_THIS_RING)
        ringname = FindRingNameByID(from_ring_id) + ': ' + ringname
    endif

    new_ring_id = NewRing(ringname)

    Ring_Prop_Include_Filter = Instant_Filter_Include
    Ring_Prop_Exclude_Filter = Instant_Filter_Exclude
    Ring_Prop_Flags = 0

    if Instant_Filter_Flags & IF_USE_CURREXT
        Ring_Prop_Flags = Ring_Prop_Flags | RP_USE_CURREXT
    endif

    if not (Instant_Filter_Flags & IF_COPY)
        Ring_Prop_Flags = Ring_Prop_Flags | RP_STEAL_FILTERED_FILES
    endif

    CommitRingProperties(new_ring_id)

    ClearFilterQueue()

    if (Instant_Filter_Flags & IF_THIS_RING) and (from_ring_id <> RING_ID_ALL)
        if from_ring_id == RING_ID_UNFILED
            // UNFILED: Go through all files
            // if it is not in the Ring_Files_Buffer
            // then it is unfiled.
            do NumFiles() times
                NextFile(_DONT_LOAD_)
                buffer_id  = GetBufferId()

                GotoBufferId(Ring_Files_Buffer)
                if not lFind(Format('^','.':MAX_RING_ID_WIDTH:'.',':',buffer_id,'$'),'gx')
                    if GotoBufferId(buffer_id)
                        QueueFileForFiltering(buffer_id, 0)
                    endif
                endif

                GotoBufferId(buffer_id)
            enddo
        else
            // Ordinary buffer
            GotoBufferId(Ring_Files_Buffer)
            BegFile()

            repeat

                BegLine()
                if lFind(Format('^', from_ring_id:MAX_RING_ID_WIDTH, ':{.*}$'), 'gxc')
                    buffer_id = Val(GetFoundText(1))

                    if GotoBufferId(buffer_id)
                        QueueFileForFiltering(buffer_id, from_ring_id)
                    endif
                endif
            until not Down()
        endif
    else
        // Run filter on all files

        do NumFiles() times
            NextFile(_DONT_LOAD_)

            buffer_id  = GetBufferId()
            if GotoBufferId(buffer_id)
                QueueFileForFiltering(buffer_id, 0)
            endif
        enddo
    endif

    RunRingFiltersOnFilterQueue(new_ring_id, F_REMOVE_FROM_ORIGINAL_RING)

    ClearFilterQueue()

    PopPosition()

    return(new_ring_id)
end


proc OnFirstEdit()
    integer stolen = 0

    if BufferType(_NORMAL_)
        stolen = FilterBuffer(GetBufferId())

        if stolen

            // ChangeRing is not Position-Safe -
            // it will take us to the given ring,
            // to the most recent file in that ring.
            // We want to go to the newly edited file

            PushPosition()
            ChangeRing(stolen)
            PopPosition()
        else
            AddBufferToRing(GetBufferId(), Current_Ring_ID)
        endif
    endif
end

proc WhenLoaded()

    PushPosition()

    Ring_Names_Buffer           = CreateTempBuffer()
    Ring_Editor_Settings_Buffer = CreateTempBuffer()
    Ring_Properties_Buffer      = CreateTempBuffer()
    Ring_Files_Buffer           = CreateTempBuffer()
    Filter_Buffer               = CreateTempBuffer()

    PopPosition()

    if not Ring_Names_Buffer
        Warn("Could not create Ring_Names_Buffer")
    endif
    if not Ring_Editor_Settings_Buffer
        Warn("Could not create Ring_Editor_Settings_Buffer")
    endif
    if not Ring_Properties_Buffer
        Warn("Could not create Ring_Properties_Buffer")
    endif
    if not Ring_Files_Buffer
        Warn("Could not create Ring_Files_Buffer")
    endif

    if Ring_Names_Buffer
        NewRing(All_Buffers_Ring_Name)
        NewRing(Unfiled_Buffers_Ring_Name)
    endif

    GetRingPromptHistory()

    LoadProfileSettings()

    Current_Ring_ID = 1

    Is_Currext_Available = TryLoadMacro('CurrExt')

    // ExecMacro('ringpos -t') // TrackPosition
    Hook(_ON_EXIT_CALLED_, Cleanup)
    Hook(_ON_FIRST_EDIT_, OnFirstEdit)
end



proc WhenPurged()
     Cleanup()
end

proc Main()
    string cmd[2]
    string args[128]

    integer ring_id

    LoadProfileSettings()

    cmd  = SubStr(Query(MacroCmdLine), 1, 2)
    args = Trim(SubStr(Query(MacroCmdLine), 3, Length(Query(MacroCmdLine))))

    case cmd
        when "-c" // Create Ring
            if Length(args)
                NewRing(args)
            else
                Warn("usage: rings -n <ringname>")
            endif

        when "-n" // Next File In Ring
            NextFileInCurrentRing()

        when "-p" // Prev File In Ring
            PrevFileInCurrentRing()

        when "-r" // Change Ring
            if Length(args)
                ChangeRing(FindRingIdByName(Trim(args)))
            else
                Warn("usage: rings -r <ringname>")
            endif

        when "-R" // Change Ring, creating if necessary
            if Length(args)
                ring_id = FindRingIdByName(args)
                if not ring_id
                    ring_id = NewRing(args)
                endif
                ChangeRing(ring_id)
            else
                Warn("usage: rings -R <ringname>")
            endif
        when "-s" // Set Properties of Current Ring
            if Length(args)
                PrepareRingProperties(Current_Ring_ID)
                ParseSettingsString(args)
                CommitRingProperties(Current_Ring_ID)

            else
                Warn("usage: rings -s <settings>")
            endif

        when "-h" // HWindow
            HWindow()

        when "-v" // VWindow
            VWindow()

        when "-l" // List Current Ring
            Warn('Current Ring: ' + FindRingNameByID(Current_Ring_ID))

        when "-P" // Loading Project
            // Loading_Project = TRUE
            UnHook(OnFirstEdit)

        when "-F" // Finished Loading Project
            // Loading_Project = FALSE
            FilterAllBuffers()
            ClearFilterQueue()
            Hook(_ON_FIRST_EDIT_, OnFirstEdit)

        when "-a" // Add Buffer to Current Ring
            AddBufferToRing(Val(Trim(args)), Current_Ring_Id)

    endcase
end




