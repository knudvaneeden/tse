/***********************************************************************

  Complete    Completes a partial word, or adds the next word.

  Author:     Andrew Bovett

  Version:    1.2

  Date:       4 May 1996

  Overview:

  This macro completes the word currently being typed by searching for
  words which start with the letters already typed. It is similar to the
  expand macro supplied with TSE version 2.5, but has the following
  differences:

  1.  The search for a matching word is done over multiple files:

      1.  A local expansions file (complete.tse in the current directory)
      2.  A global expansions file (complete.tse in the startup directory)
      3.  The current loaded file, from the current position backwards
      4.  The current loaded file, from the current position forwards
      5.  All loaded files

  2.  Searches may be case sensitive or case insensitive, depending on
      which key is pressed.

  3.  Rather than displaying a picklist if multiple files are found,
      successive choices are presented each time one of the complete keys
      is pressed, in a manner similar to the filename completion feature
      in the JP Software "4DOS" command shell. Another key "rewinds"
      through the options already presented, if the required expansion is
      overshot (it must be pressed before anything else is typed).

  4.  If one of the complete keys is pressed after a whole word, followed
      by a space, is typed, the macro will search for words which followed
      the word just typed. For example, "just <complete key>" would result
      in "just typed".

  Keys:

  This file currently contains the following key assignments:

        <CtrlAlt h>    Complete the word, case sensitive
        <Ctrl h>       Complete the word, ignoring case
        <Alt h>        Reverse the completion

  They may be reassigned by changing the definitions at the end of the file.

Change history:

    Version 1.2  1 Oct 2005  R. Boyd
        Fixed problem which occurs when a block is currently marked.
        Changed variable 'continue' to 'proceed' (reserved word clash)
        Tidied whenloaded procedure
        Changed default key assignments to emulate Semware's expand.s macro
        Replaces trailing wordset characters after completing the word.

    Version 1.1
        Various minor bug fixes

    Version 1.0     20 April 1996
        Initial version


************************************************************************/


/******************************************************************************
/*
/*      Global variables and constant definitions
/*
/*****************************************************************************/

// Constants and constant string expressions

CONSTANT STRING_SIZE = 80,
         LOCAL_EXP_FILE       = 1,
         MAIN_EXP_FILE        = 2,
         LOCAL_FILE_BACKWARDS = 3,
         LOCAL_FILE_FORWARDS  = 4,
         ALL_FILES            = 5

string   EXPAND_FILE[] = "complete.tse"

// Variables

integer  local_exp_id = 0,
         main_exp_id = 0,
         exp_history_buffer_id,
         last_line    = 1,
         last_col     = 1,
         last_file_id = 0,
         last_stage   = 0

string   last_expansion[ STRING_SIZE ] = "",
         last_abbrev[ STRING_SIZE ] = ""


/******************************************************************************
/*
/*      Procedure:      SearchFileForExpansion()
/*
/*      Description:    Search the current file for an expansion for
/*                      the passed abbreviation, starting at the current
/*                      position.
/*
/*****************************************************************************/

string proc SearchFileForExpansion( string abbrev, integer whole_word,
             integer direction, integer ignore_case_flag )
    integer  found = FALSE, found_abbrev
    string   expansion[ STRING_SIZE ]


    repeat
        if not found
            found = lFind( abbrev, iif( ignore_case_flag, "i", "" )
            + iif( direction == _FORWARD_, "", "b" )
            + iif( whole_word, "w", "" ) )
        else
            // If searching backwards for xx, TSE will find xxx only once,
            // starting at the second x. We want it to find the first x. This
            // may be "fixed" by moving to the end of each found word before
            // repeating the find.

            if direction <> _FORWARD_
                GotoPos( CurrPos() + Length( abbrev ) - 1 )
            endif

            found = lRepeatFind( direction )
        endif

        if left()
            found_abbrev = not isWord()
            right()
        else
            found_abbrev = TRUE
        endif

    until found_abbrev or not found

    if not found
        return( "" )
    endif

    expansion = GetWord()
    if whole_word and WordRight()
        expansion = expansion + " " + GetWord()
        WordLeft()
    endif

    return( expansion )
end


/******************************************************************************
/*
/*      Procedure:      FindExpansion()
/*
/*      Description:    Expand the passed abbreviation. Look in the
/*                      appropriate files in sequence. If a continuation,
/*                      skip the stages already done.
/*
/*****************************************************************************/

string proc FindExpansion( string abbrev, integer proceed,
             integer whole_word, integer ignore_case_flag )
    string   expansion[ STRING_SIZE ]
    integer  curr_buffer_id, chg_file_hook_state


    chg_file_hook_state = SetHookState( FALSE, _ON_CHANGING_FILES_ )
    curr_buffer_id      = GetBufferId()
    expansion           = ""


    // If this is a continuation, skip stages already completed.

    if proceed
        case last_stage
        when LOCAL_EXP_FILE
            goto LOCAL_EXP_FILE_SEARCH
        when MAIN_EXP_FILE
            goto MAIN_EXP_FILE_SEARCH
        when LOCAL_FILE_BACKWARDS
            goto LOCAL_FILE_BACKWARDS_SEARCH
        when LOCAL_FILE_FORWARDS
            goto LOCAL_FILE_FORWARDS_SEARCH
        when ALL_FILES
            goto ALL_FILES_SEARCH
        otherwise
            Warn( "Internal program error [1]: Contact A. Bovett" )
            halt
        endcase
    endif


    LOCAL_EXP_FILE_SEARCH:

    if GotoBufferId( local_exp_id )
        if proceed
            GotoLine( last_line )
            GotoColumn( last_col )
            NextChar()
        else
            BegFile()
        endif
        expansion  = SearchFileForExpansion( abbrev, whole_word, _FORWARD_, ignore_case_flag )
        proceed    = FALSE
        last_line  = CurrLine()
        last_col   = CurrCol()
        last_stage = LOCAL_EXP_FILE
    endif


    MAIN_EXP_FILE_SEARCH:

    if expansion == "" and GotoBufferId( main_exp_id )
        if proceed
            GotoLine( last_line )
            GotoColumn( last_col )
            NextChar()
        else
            BegFile()
        endif
        expansion = SearchFileForExpansion( abbrev, whole_word, _FORWARD_, ignore_case_flag )
        proceed    = FALSE
        last_line  = CurrLine()
        last_col   = CurrCol()
        last_stage = MAIN_EXP_FILE
    endif


    LOCAL_FILE_BACKWARDS_SEARCH:

    if expansion == "" and GotoBufferId( curr_buffer_id )
        PushPosition()
        if proceed
            GotoLine( last_line )
            GotoColumn( last_col )
        else
            WordLeft()
        endif
        if PrevChar()
            expansion = SearchFileForExpansion( abbrev, whole_word, _BACKWARD_, ignore_case_flag )
        endif
        proceed   = FALSE
        last_line = CurrLine()
        last_col  = CurrCol()
        PopPosition()
        last_stage = LOCAL_FILE_BACKWARDS
    endif


    LOCAL_FILE_FORWARDS_SEARCH:

    if expansion == ""
        GotoBufferId( curr_buffer_id )
        PushPosition()
        if proceed
            GotoLine( last_line )
            GotoColumn( last_col )
        endif
        if NextChar()
            expansion = SearchFileForExpansion( abbrev, whole_word, _FORWARD_, ignore_case_flag )
        endif
        proceed   = FALSE
        last_line = CurrLine()
        last_col  = CurrCol()
        PopPosition()
        last_stage = LOCAL_FILE_FORWARDS
    endif


    ALL_FILES_SEARCH:

    if expansion == ""
        if proceed
            GotoBufferId( last_file_id )
            PushPosition()
            GotoLine( last_line )
            GotoColumn( last_col )
            NextChar()
        else
            GotoBufferId( curr_buffer_id )
            NextFile()
            PushPosition()
            BegFile()
        endif
        repeat
            expansion = SearchFileForExpansion( abbrev, whole_word, _FORWARD_, ignore_case_flag )
            if expansion == ""
                PopPosition()
                NextFile()
                PushPosition()
                BegFile()
            endif
            last_file_id = GetBufferId()
        until expansion <> "" or last_file_id == curr_buffer_id

        proceed   = FALSE              // Just to be consistent - not used at present
        last_line = CurrLine()
        last_col  = CurrCol()
        PopPosition()
        last_stage = ALL_FILES
    endif


    SetHookState( chg_file_hook_state, _ON_CHANGING_FILES_ )
    GotoBufferId( curr_buffer_id )
    return( expansion )
end


/******************************************************************************
/*
/*      Procedure:      CompleteWord()
/*
/*      Description:    Main routine to expand the word to the left of the
/*                      cursor.
/*
/*****************************************************************************/

proc CompleteWord( integer ignore_case_flag )
    integer  whole_word              = FALSE,
             proceed                 = FALSE,
             whole_word_continuation = FALSE,
             curr_buffer_id,
             killcharflag = isWord()

    string   expansion[ STRING_SIZE ],
             abbrev[ STRING_SIZE ],
             prev_word[ STRING_SIZE ]


    PushBlock()

    // 21 Nov 96  RBoyd  Version 1.2 Fix - Need to unmark blocks.
    UnMarkBlock()
    // Get Word to expand

    PushPosition()
    MarkChar()
    if not isWord()                    // In case we are at the end of the word
        Left()
    endif
    BegWord()
    MarkChar()
    abbrev = Trim( GetMarkedText() )
    UnMarkBlock()
    prev_word = iif( WordLeft(), Trim( GetWord() ), "" )


    // Check there's something to expand

    if abbrev == "" and prev_word == ""
        message( "No word to expand" )
        PopPosition()
        PopBlock()
        return()
    endif

    // If there is no word, is this a whole word expansion?
    if abbrev == ""
        whole_word = TRUE
        abbrev     = prev_word

        // If there is a word, is this a repeat expansion?

    elseif abbrev == last_expansion
        proceed = TRUE
        abbrev  = last_abbrev

        // Is this a repeat expansion of a whole word?

    elseif Length( last_expansion ) - Pos( abbrev, last_expansion ) + 1
        == Length( abbrev ) and Pos( prev_word, last_expansion ) == 1
        whole_word              = TRUE
        proceed                 = TRUE
        whole_word_continuation = TRUE
        abbrev                  = prev_word
    endif
    PopPosition()

    // Clear the history buffer if this is a new search

    if not proceed
        EmptyBuffer( exp_history_buffer_id )
        InsertLine( abbrev + iif( whole_word, " ", "" ), exp_history_buffer_id )
    endif

    // Look for the expansion

    curr_buffer_id = GetBufferId()

    repeat
        GotoBufferId( curr_buffer_id )
        expansion = FindExpansion( abbrev, proceed, whole_word,
                 ignore_case_flag )
        last_abbrev = iif( proceed, last_abbrev, abbrev )
        proceed     = TRUE

        GotoBufferId( exp_history_buffer_id )
    until not lFind( expansion, "g^$" ) or expansion == ""

    // Save the expansion

    if expansion <> ""
        BegFile()
        InsertLine( expansion )
    endif

    // Put the expansion into the file in place of the abbreviation

    GotoBufferId( curr_buffer_id )

    if expansion <> ""
        while CurrPos() > CurrLineLen() + 1 // Ensure we don't delete EOL
            Left()
        endwhile

        MarkChar()                     // delete "abbreviation" to be
        WordLeft()                     //                  replaced
        if whole_word_continuation
            WordLeft()
        endif
        KillBlock()

        InsertText( expansion, _INSERT_ ) // Insert expansion

        // RBoyd: Clear out any trailing characters... so we replace the word (if any)
        if killcharflag
            while isWord() and DelChar()
            endwhile
        endif

        last_expansion = expansion
    else
        Message( "No expansion found" )
    endif

    PopBlock()

end


/******************************************************************************
/*
/*      Procedure:      ReverseComplete()
/*
/*      Description:    Reverse the last expansion (if possible)
/*
/*****************************************************************************/


proc ReverseComplete()
    integer  init_pos, start_of_expansion, curr_buffer
    string   replace_string[ STRING_SIZE ]


    curr_buffer        = GetBufferId()
    init_pos           = CurrPos()
    start_of_expansion = init_pos - Length( last_expansion )


    // Check we are still over the last expansion

    if GetText( start_of_expansion, Length( last_expansion ) ) == last_expansion

        // Check there is something to "undo"

        GotoBufferId( exp_history_buffer_id )
        if NumLines() > 1

            // Do the replace...

            BegFile()
            KillLine()
            replace_string = GetText( 1, CurrLineLen() )
            GotoBufferId( curr_buffer )
            GotoPos( start_of_expansion )
            MarkChar()
            GotoPos( init_pos )
            KillBlock()
            InsertText( replace_string, _INSERT_ )

            // Stored search position is no longer valid, so reset it

            last_line      = CurrLine()
            last_col       = CurrCol()
            last_stage     = LOCAL_EXP_FILE
            last_expansion = replace_string

        else
            GotoBufferId( curr_buffer )
            Message( "No previous expansions" )
        endif
    else
        Message( "Cursor must be over a previous expansion" )
    endif
end


/******************************************************************************
/*
/*      Procedure:      WhenLoaded()
/*
/*      Description:    Load the "complete.tse" files, if they exist.
/*                      Don't use EditFile as this stops the expansion
/*                      files from being edited interactively (the
/*                      buffer names conflict with the file to be
/*                      edited). Also create the history buffer used to
/*                      hold previous expansions
/*
/*****************************************************************************/

proc WhenLoaded()
    integer  curr_id       = GetBufferId()

    main_exp_id           = CreateTempBuffer()
    exp_history_buffer_id = CreateTempBuffer()
    local_exp_id          = CreateTempBuffer()

    if exp_history_buffer_id and local_exp_id and main_exp_id
        // local_exp_id is now the current buffer
        LoadBuffer( EXPAND_FILE )
        GotoBufferId( main_exp_id)
        LoadBuffer( LoadDir() + EXPAND_FILE )
    else
        PurgeMacro(CurrMacroFileName())
    endif

    GotoBufferId( curr_id )

end


/******************************************************************************
/*
/*      Procedure:      whenpurged
/*
/*      Description:    Clean up - remove the buffers created when the
/*                      macro was loaded.
/*
/*****************************************************************************/

proc WhenPurged()
    AbandonFile( local_exp_id )
    AbandonFile( main_exp_id )
    AbandonFile( exp_history_buffer_id )
end


/******************************************************************************
/*
/*      Key definitions. These may be edited as required
/*
/*****************************************************************************/
<CtrlAlt h>     CompleteWord( FALSE )  // Case sensitive
<Ctrl h>        CompleteWord( TRUE )   // Ignore case
<Alt h>         ReverseComplete()      // Step backwards through words


