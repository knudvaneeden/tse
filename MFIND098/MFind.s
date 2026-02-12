
/*

    MFind - Enhanced replacement for the Find built-in

    v0.9.7 - Jun 19, 2002

    
    Copyright (c) 2002 - Michael Graham <magmac@occamstoothbrush.com>

    This program is Free Software - you may use it, modify it and
    distribute it under the the terms of the Perl Artistic License,
    which you may find at:

          http://www.perl.com/CPAN/doc/misc/license/Artistic

    In particular, note that you use this software at your own risk!

    The latest version of my TSE macros can be found at:

        http://www.occamstoothbrush.com/tsemac/



*/


#include ['mfconst.si']
#include ['tryexec.si']
#include ['setcache.si']
#include ['findprof.si']

#ifndef WIN32
#include ['profile.si']
#endif

string Find_Text[MAX_STRING]            = ""
string Replace_Text[MAX_STRING]         = ""
string Find_Options[16]                 = "I"
string Entered_Find_Text[MAX_STRING]    = ""
string Entered_Replace_Text[MAX_STRING] = ""
string Entered_Find_Options[16]         = "I"

integer First_Find        = 1
integer Repeat_Mode       = MF_ASK

integer Find_Start_Buffer    = 0
integer Left_Initial_Buffer  = 0
integer First_Find_In_Buffer = 1
integer Replace_No_Prompt    = 0
integer Find_Mode            = MF_FIND
integer Find_Global_Flag     = 0
integer Use_Sound            = 1
integer Auto_Block_Options   = 1
integer Show_Translated_Text = 1

string Next_File_Macro[128]      = ''
string Next_File_Macro_Args[128] = ''
string Prev_File_Macro[128]      = ''
string Prev_File_Macro_Args[128] = ''
string Find_Text_Translator_Plugins[255] = ''

integer Settings_Loaded = 0
integer Settings_Serial = 0

proc Debug(string msg)
    if 0
        Debug('')
    endif
    UpdateDisplay()
    Warn(msg)
end

proc LoadSettings()
    if (not Settings_Loaded) or NeedToReloadSettings(Settings_Serial)

        Settings_Serial = GetSettingsRefreshSerial()

        Next_File_Macro      = GetProfileStr('mfind','next_file_macro', Next_File_Macro, FindProfile()                   )
        Prev_File_Macro      = GetProfileStr('mfind','prev_file_macro', Prev_File_Macro, FindProfile()                   )
        Use_Sound            = GetProfileInt('mfind','use_sound'      , Query(Beep)                                      , FindProfile())
        Auto_Block_Options   = GetProfileInt('mfind','auto_block_options', Auto_Block_Options, FindProfile()             )
        Show_Translated_Text = GetProfileInt('mfind','show_translated_text_on_error', Show_Translated_Text, FindProfile())

        Find_Text_Translator_Plugins = GetProfileStr('mfind','find_text_translator_plugins', Find_Text_Translator_Plugins, FindProfile())

        Next_File_Macro_Args = GetToken(Next_File_Macro, ' ', 2)
        Next_File_Macro      = GetToken(Next_File_Macro, ' ', 1)
        Prev_File_Macro_Args = GetToken(Prev_File_Macro, ' ', 2)
        Prev_File_Macro      = GetToken(Prev_File_Macro, ' ', 1)

        Settings_Loaded = 1
    endif
end

// mAskForFindOptions() asks the user for find string, find options
// and replace string (if Find_Mode == M_REPLACE)
//
// It returns TRUE if the dialog was confirmed, FALSE if it was cancelled
//
// It puts the results in the following globals:
//     Find_Text            (the text to search for)
//     Replace_Text         (the text to replace)
//     Find_Options         (the find options requested)
//     Find_Start_Buffer    (which buffer we were in when the question
//                           was asked)
//

proc RunFindTextTranslatorMacro()
    integer i
    string plugin[MAX_STRING]
    integer find_bits = opts2bits(Find_Options)

    if not (find_bits & MF_OPTS_Z)
        if Length(Find_Text_Translator_Plugins)
            for i = 1 to NumTokens(Find_Text_Translator_Plugins, ",")
                plugin = Trim(GetToken(Find_Text_Translator_Plugins, " ", i))
                if isMacroLoaded(plugin) or LoadMacro(plugin)
                    if Find_Mode == MF_FIND
                        SetGlobalInt('MFind::Replace', FALSE)
                        SetGlobalStr('MFind::Replace_Text', '')
                    else
                        SetGlobalInt('MFind::Replace', TRUE)
                        SetGlobalStr('MFind::Replace_Text', Replace_Text)
                    endif
                    SetGlobalStr('MFind::Find_Text', Find_Text)
                    SetGlobalStr('MFind::Find_Options', Find_Options)

                    ExecMacro(plugin)

                    if Find_Mode == MF_FIND
                        Replace_Text = GetGlobalStr('MFind::Replace_Text')
                    endif

                    Find_Text    = GetGlobalStr('MFind::Find_Text')
                    Find_Options = GetGlobalStr('MFind::Find_Options')
                endif
            endfor
        endif
    endif
end

integer proc mAskForFindOptions()

    integer find_bits = 0
    integer in_block  = 0

    LoadSettings()

    // Add the 'global' option to Find_Options
    // if the Find_Global_Flag is set
    find_bits = opts2bits(Entered_Find_Options)
    if Find_Global_Flag
        find_bits = find_bits | MF_OPTS_G
    endif

    // Some other "intelligent guesses"
    // if enabled:

    if Auto_Block_Options

        if Query(BlockId) == GetBufferId()
            in_block = 1
        endif

        // * if there is no block, remove l if present or lg
        //   if both are present, or lgn if all three are present

        if not in_block
            if find_bits & MF_OPTS_L
                find_bits = find_bits & ~MF_OPTS_L
                if find_bits & MF_OPTS_G
                    find_bits = find_bits & ~MF_OPTS_G
                    find_bits = find_bits & ~MF_OPTS_N
                endif
            endif
        endif

        // * if the cursor is in a block,
        //   add lg unless l is present

        if in_block
            if not (find_bits & MF_OPTS_L)
                find_bits = find_bits | MF_OPTS_L
                find_bits = find_bits | MF_OPTS_G
            endif
        endif

    endif

    Entered_Find_Options = bits2opts(find_bits)

    Repeat_Mode = MF_ASK

    UpdateDisplay()
    if Find_Mode == MF_FIND
        if Ask ("Search For: ", Entered_Find_Text , _FIND_HISTORY_) and
           Ask ("Options [BWILWXA] (Back Global Local Ignore-case Local Words Reg-eXp All-files", Entered_Find_Options)
               // debug('this is our start buffer: ' + CurrFileName())
               Find_Start_Buffer    = GetBufferId()
               Left_Initial_Buffer  = 0
               First_Find_In_Buffer = 1

               Find_Text    = Entered_Find_Text
               Find_Options = Entered_Find_Options

               RunFindTextTranslatorMacro()

               // Extract the 'global' option into its own
               // variable, and remove it from Find_Options
               find_bits        = opts2bits(Find_Options)
               Find_Global_Flag = find_bits & MF_OPTS_G
               find_bits        = find_bits & ~MF_OPTS_G
               Find_Options     = bits2opts(find_bits)

               return(TRUE)
        endif
    else
        if Ask ("Search For: ", Entered_Find_Text , _FIND_HISTORY_) and
           Ask ("Replace with: ", Entered_Replace_Text , _REPLACE_HISTORY_) and
           Ask ("Options [BWILWXA] (Back Global Local Ignore-case Local Words Reg-eXp All-files", Entered_Find_Options)
               Find_Start_Buffer    = GetBufferId()
               Left_Initial_Buffer  = 0
               First_Find_In_Buffer = 1

               Find_Text    = Entered_Find_Text
               Replace_Text = Entered_Replace_Text
               Find_Options = Entered_Find_Options

               RunFindTextTranslatorMacro()

               // Extract the 'global' option into its own
               // variable, and remove it from Find_Options
               find_bits        = opts2bits(Find_Options)
               Find_Global_Flag = find_bits & MF_OPTS_G
               find_bits        = find_bits & ~MF_OPTS_G
               Find_Options     = bits2opts(find_bits)

               return(TRUE)
        endif
    endif

    return(FALSE)
end

integer proc ConfirmReplace(var integer no_prompt, var integer keep_replacing)
    integer replace_this_time
    integer keep_asking = 0

    no_prompt      = 0
    keep_replacing = 1

    Message(Str(CurrLine()) + ' ' + SplitPath(CurrFileName(), _NAME_|_EXT_) + " Replace? (Yes/No/Only/Rest/Quit): ")

    repeat
        keep_asking = 0
        case GetKey()
            when <y>
                replace_this_time = 1
            when <n>
                replace_this_time = 0
            when <o>
                replace_this_time = 1
                keep_replacing    = 0
            when <r>
                replace_this_time = 1
                no_prompt         = 1
            when <q>, <Escape>
                replace_this_time = 0
                keep_replacing    = 0
            otherwise
                keep_asking = 1
        endcase
    until not keep_asking

    Message("")

    return(replace_this_time)
end

proc Chirp()
    #if EDITOR_VERSION >= 0x4000
    if Use_Sound
        Sound(2000, 1)
        Sound(1000, 1)
    endif
    #else
    if Use_Sound
        Sound(2000)
        delay(1)
        NoSound()
        Sound(1000)
        delay(1)
        NoSound()
    endif
    #endif
end

proc mNextFile()
    if Length(Next_File_Macro)
        // warn("execing macro: " + Next_File_Macro + " " + Next_File_Macro_Args)
        TryExecMacro(Next_File_Macro, Next_File_Macro_Args)
    else
        // warn("just running NextFile()")
        NextFile()
    endif
end

proc mPrevFile()
    if Length(Prev_File_Macro)
        // warn("execing macro: " + Prev_File_Macro + " " + Prev_File_Macro_Args)
        TryExecMacro(Prev_File_Macro, Prev_File_Macro_Args)
    else
        // warn("just running PrevFile()")
        PrevFile()
    endif
end

integer proc mFindSearch()

    integer find_bits            = 0
    integer find_backwards       = 0
    integer find_all             = 0
    integer found                = 0
    integer replace_this_time    = 0
    integer num_replacements     = 0
    integer keep_replacing       = 0
    integer center_finds         = Query(CenterFinds)
    string extra_ops[2]          = ''

    integer saved_beep = Set(Beep, OFF)

    LoadSettings()

    find_bits         = opts2bits(Find_Options)
    find_backwards    = find_bits & MF_OPTS_B
    find_all          = find_bits & MF_OPTS_A
    Replace_No_Prompt = find_bits & MF_OPTS_N

    find_bits = find_bits & ~MF_OPTS_A
    find_bits = find_bits & ~MF_OPTS_N
    find_bits = find_bits & ~MF_OPTS_G
    Find_Options    = bits2opts(find_bits)

    while 1
        if find_all
            if Left_Initial_Buffer
                if Find_Start_Buffer == GetBufferId()
                    Chirp()

                    Find_Start_Buffer    = 0

                    // debug('reset first start in file ' + CurrFileName())
                    found = 0
                    break
                else
                    Warn("Find_Start_Buffer ("+Str(Find_Start_Buffer)+") <> GetBufferID() ("+Str(GetBufferID())+")")
                endif
            else
                Warn("haven't left initial buffer")
            endif
        endif

        if Repeat_Mode == MF_ASK
            extra_ops = ''
        elseif Repeat_Mode == MF_REPEAT
            if find_all and Left_Initial_Buffer and First_Find_In_Buffer
                extra_ops = 'g+'
                First_Find_In_Buffer = 0
            else
                extra_ops = '+'
            endif
        endif

        // Special handling for the global flag -
        // unless this is the first search, we don't
        // actually want to keep searching from
        // the beginning.

        if Find_Global_Flag and Repeat_Mode <> MF_REPEAT
            extra_ops = extra_ops + 'g'
        endif

        if Find_Mode == MF_FIND
            // Debug("(f) finding: " + Find_Text + "; " + Find_Options + extra_ops)
            found = Find(Find_Text, Find_Options + extra_ops)
            // Debug("(f) endfind")
        else // Replace

            if Replace_No_Prompt
                Set(CenterFinds,0)
            endif
            found = Find(Find_Text, Find_Options + extra_ops)
            // Debug("(r) endfind (found: "+str(found)+")")
            if found
                if not Replace_No_Prompt
                    UpdateDisplay()
                    replace_this_time = ConfirmReplace(Replace_No_Prompt, keep_replacing)
                endif
                // Warn(Format("rtt: ", replace_this_time, " rnp: ", Replace_No_Prompt, " kr: ", keep_replacing))

                if Replace_No_Prompt
                    keep_replacing = 1
                endif

                if Replace_No_Prompt or replace_this_time
                    // Mark the found text, then do one search

                    PushBlock()
                    MarkfoundText()
                    if lReplace(Find_Text, Replace_Text, Find_Options + extra_ops + '1lg')
                        num_replacements = num_replacements + 1
                    endif
                    PopBlock()
                endif
            endif
        endif

        Repeat_Mode = MF_REPEAT

        // Debug("found: " + str(found))

        if find_all
            if found
                // Debug("found!")
                if not keep_replacing
                    break
                endif
            else
                if find_backwards
                    mPrevFile()
                    First_Find_In_Buffer = 1
                else
                    mNextFile()
                    First_Find_In_Buffer = 1
                    // Debug("went to nextfile " + CurrFileName())
                endif

                if Find_Start_Buffer <> GetBufferId() or NumFiles() == 1
                    Left_Initial_Buffer = 1
                endif
            endif
        else

            if not found
                Chirp()
                break
            endif

            if not keep_replacing
                break
            endif

        endif

    endwhile

    if Find_Mode == MF_REPLACE
        message(Str(num_replacements) + " change(s) made")
        found = 2   // This stops the ask dialog
    else
        if not found
            if Show_Translated_Text
                message(Find_Text + " not found (x)")
            else
                message(Entered_Find_Text + " not found (x)")
            endif
        endif
    endif

    // UnHook(mFOnChangingFiles)

    Set(Beep, saved_beep)

    Find_Options = bits2opts(
        find_bits
        | iif(Replace_No_Prompt, MF_OPTS_N, 0)
        | iif(find_all,          MF_OPTS_A, 0)
    )

    Set(CenterFinds, center_finds)
    return(found)
end

proc WhenLoaded()
    LoadSettings()
end

proc Main()
    string  cmdline[128]   = Query(MacroCmdLine)
    string  on_opts[20]    = ''
    string  off_opts[20]   = ''
    string  abs_opts[20]   = ''
    string  parm[20]       = ''
    string  switch[2]      = ''

    integer on_bits        = 0
    integer off_bits       = 0
    integer find_bits      = 0

    integer i              = 0

    integer saved_break    = Set(Break, ON)

    for i = 1 to NumTokens(cmdline, ' ') + 1
        parm = Lower(GetToken(cmdline, ' ', i))
        if switch == ''
            switch = parm
        else
            case switch
                when '-a'
                    abs_opts = parm
                    switch = ''
                when '-1', '-y'
                    on_opts = parm
                    switch = ''
                when '-0', '-n'
                    off_opts = parm
                    switch = ''
                when '-f'
                    Find_Mode = MF_FIND
                    Repeat_Mode = MF_ASK
                    switch = parm
                when '-r'
                    Find_Mode = MF_REPLACE
                    Repeat_Mode = MF_ASK
                    switch = parm
                when '-g'
                    Repeat_Mode = MF_REPEAT
                    switch = parm
                when '-q'
                    Use_Sound = 0
                    switch = parm
                when '-s'
                    Use_Sound = 1
                    switch = parm
            endcase
        endif
    endfor

    if First_Find
        Find_Options = Query(FindOptions)
        First_Find = 0
    endif

    if Find_Text == ''
        Repeat_Mode = MF_ASK
    endif

    if abs_opts == ''
        abs_opts = Find_Options
    endif

    on_bits   = opts2bits(on_opts)
    off_bits  = opts2bits(off_opts)
    find_bits = opts2bits(abs_opts)
    find_bits = find_bits | on_bits
    find_bits = find_bits & ~ off_bits

    Find_Options = bits2opts(find_bits)

    if not Find_Start_Buffer
        Find_Start_Buffer = GetBufferId()
        // debug('no first buffer, so using this one: ' + CurrFileName())
        Left_Initial_Buffer  = 0
        First_Find_In_Buffer = 1
    endif

    if Repeat_Mode <> MF_ASK or mAskForFindOptions()

        while not mFindSearch()
            if not mAskForFindOptions()
                break
            endif
        endwhile

    endif

    Set(Break, saved_break)
end

/*

*/



