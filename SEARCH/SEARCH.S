
/*
 * This module will contain all of the GREP, and SearchReplace routines.
 * Currently there are no SearchReplace routines in this file.
 *
 * Currently I "include" this module into my default .S file.
 *
 * Version
 *
 *    1     Tony L. Burnett, 7-APR-93
 *          - Original.
 */

constant    LINE_NUM_WIDTH = 5,
            LIST_BOX_HEIGHT = 30

constant    USR_EXPR  = 0,
            FUNCTIONS = 1

/*
 * Note:  This string must begin with a space
 */

string SEARCH_FILES[] =
    " *.C *.H *.B36 *.R36 *.XF4 *.MAK *.INC *.HI *.IH *.MAC"

forward integer proc SuperSearch (string filespec)

forward integer proc FindInRing ()

forward integer proc ListAllOf (integer mode)

forward integer proc SearchCurrDir (string expr, string opts, string filespec)

forward integer proc SearchTheRing (string expr, string opts)

forward integer proc PutMatchesInBox (string expr, string opts,
    integer search_id, integer box_id, var integer MaxLineLen)

forward integer proc DisplayMatches (integer box_id, integer width)

forward integer proc OpenSelectedFile ()

forward integer proc SaveRing (var integer savefile_id)

forward integer proc RestoreRing (integer savefile_id)

/*
 * SuperSearch
 *
 *  This is identical to SearchCurrDir except the user can specify the expr
 *  the options and the filespec to search.
 */

integer proc SuperSearch (string filespec)
    string      expr[80] = "",
                opts[5] = "I",
                fs[80] = filespec

    if not Ask ("Enter expression to search on:", expr)
        return (FALSE)
    endif

    if not Ask ("Enter search options [IWXL]:", opts)
        return (FALSE)
    endif

    if not Ask ("Enter filespec to search:", fs)
        return (FALSE)
    endif

    if not SearchCurrDir (expr, opts, fs)
        return (FALSE)
    endif

    return (TRUE)
end


/*
 * FindInAll
 *
 *  List all occurances of a user specified string in every file in the
 *  file-ring.
 */

integer proc FindInRing ()
    string      expr[80] = "",
                opts[5] = ""

    if not Ask ("Enter expression to search on:", expr)
        return (FALSE)
    endif

    if not Ask ("Enter search options [IWXL]:", opts)
        return (FALSE)
    endif

    if not SearchTheRing (expr, opts)
        return (FALSE)
    endif

    return (TRUE)
end

/*
 * ListAllOf
 *
 *  List all occurances of function headers or a user specified string.
 *
 *  This function replaces mCompressView
 */

integer proc ListAllOf (integer mode)

    integer     choice,
                MaxWidth = 0,
                box_id,
                current_id

    string      expr[80] = "",
                opts[5] = ""

    current_id = GetBufferId ()
    expr = CurrFilename ()

    box_id = CreateTempBuffer ()
    AddLine ("FILE: " + expr)

    GotoBufferId (current_id)

    if mode == USR_EXPR
        if not ask ("String to list all occurrences of:", expr)
            return (FALSE)
        endif

        if Length (expr) == 0
            opts = "x"
            expr = "^[a-zA-Z_]"

        elseif not
            ask ("Search options [IWX] (Ignore-case Words reg-eXp):", opts)
            return (FALSE)

        endif
    else
        opts = "ix"

        case SplitPath(CurrFilename(), _EXT_)
            when ".c",".cpp"
                expr = "^[a-zA-Z_].*\(.*[~;]$"

            when ".b36"
                expr = "^[global\t ]*routine[\t ]*[a-zA-Z_\$].*=.*$"

            when ".xf4"
                expr = "^[\t ]*subroutine[\t ]*[a-zA-Z_\$].*\(.*\)$"

            when ".s"
                expr = "^{public #}?{{integer #}|{string #}}@proc +[a-zA-Z_]"

            otherwise
                Alarm ()
                Warn ("Extension not supported")
                return (FALSE)

        endcase
    endif

    PutMatchesInBox (expr, opts, current_id, box_id, MaxWidth)

    choice = DisplayMatches (box_id, MaxWidth)

    if choice > 0
        OpenSelectedFile ()
    endif

    AbandonFile (box_id)                // Remove tempbuffers

    return (TRUE)
end

/*
 * SearchCurrDir
 *
 * This routine will search all files which are part of SEARCH_FILES (plus
 * those already in the file-ring) for 'expr' using options 'opts'.  It
 * will only leave open those files which were open before the search
 * began.
 */

integer proc SearchCurrDir (string expr, string opts, string filespec)

    integer     save_id = 0,
                temp_id = 0,
                old_level

    string      tempfile[80]

    SaveRing (save_id)

    /*
     * This will append all files matching SEARCH_FILES to the file ring
     * and leave the current file active.
     */

    old_level = Set (MsgLevel, _NONE_)

    if not EditFile ("-a " + CurrFilename () + filespec)
        Alarm ()
        Warn ("ERROR: Editfile in SearchCurrDir.")
    endif

    Set (MsgLevel, old_level)

    /*
     * Now everything should be back the way it was before this function was
     * called except that several files may have been added to the file-ring.
     */

    SearchTheRing (expr, opts)

    tempfile = CurrFilename ()
    temp_id = GetBufferId ()
    GotoBufferId (save_id)
    Addline (tempfile)          // this will prevent restore ring from
                                // closing a new file which might have been
                                // opened in SearchTheRing
    BegFile ()
    GotoBufferId (temp_id)

    RestoreRing (save_id)       // return the file ring back to its
                                // initial status.

    AbandonFile (save_id)       // close the save_id buffer

    return (TRUE)

end

/*
 * SearchTheRing
 *
 *  This routine will search every file in the file ring for 'expr'
 *  using the search options provided in 'opts'.  It assumes that the
 *  calling function will restore everything (Position, BlockStatus,
 *  etc.).  In order to aid in restoring the initial file-ring only
 *  those files which were open at the time of the call will be opened
 *  in this routine.  The extra file which could be opened is the file
 *  in which a match was found.  This file could be one of the original
 *  opened files or a newly opened file.
 *
 *  This routine assumes that the current buffer is a _NORMAL_ buffer and
 *  is part of the file-ring.
 *
 *  RETURNS:
 *
 *      TRUE        if everything is OK
 *      FALSE       if it is not
 *
 */

integer proc SearchTheRing (string expr, string opts)

    integer     current_id,             // id of currently active buffer
                temp_id,
                box_id,
                MaxLineLen = 0,         // Length of longest line in box_id
                choice,
                i

    string      filename[80]

    i = NumFiles ()

    if i == 0
        return (FALSE)
    endif

    current_id = GetBufferId ()         // save the current buffer id because
                                        // CreateTempBuff will change it
    box_id = CreateTempBuffer ()        // this buffer will contain all of the
                                        // matches
    temp_id = CreateTempBuffer ()       // this buffer will be used to hold
                                        // files which were not orignally open
                                        // when the macro started.  This will
                                        // help preserve the initial file-ring

    GotoBufferId (current_id)

    while i
        current_id = GetBufferId ()
        filename = CurrFilename ()
        MaxLineLen = iif ((Length (filename) + 5) > MaxLineLen,
            Length (filename) + 5, MaxLineLen)

        /*
         * Add the current file name to the ListBox
         */

        GotoBufferId (box_id)
        AddLine ("FILE: " + filename)
        GotoBufferId (current_id)

        if NumLines () == 0             // numlines (0 = not loaded/empty file)
            /*
             * Load the unloaded file into the temp buffer.
             * This will help preserve the initial list of which files
             * were open at the time this function was called.
             */

            GotoBufferId (temp_id)
            EmptyBuffer ()
            InsertFile (filename)
            UnMarkBlock ()
            PutMatchesInBox (expr, opts, temp_id, box_id, MaxLineLen)
        else
            PutMatchesInBox (expr, opts, current_id, box_id, MaxLineLen)
        endif

        GotoBufferId (current_id)
        NextFile (_DONT_LOAD_)          // change files, but don't load it

        i = i - 1
    endwhile

    choice = DisplayMatches (box_id, MaxLineLen)

    if choice > 0
        OpenSelectedFile ()
    endif

    AbandonFile (box_id)                // Remove tempbuffers
    AbandonFile (temp_id)

    return (TRUE)
end

/*
 * PutMatchesInBox
 *
 *  This routine will place all matches of 'expr' using find options
 *  'opts' in the file 'current_id'.  Every line which contains a match
 *  will be placed in 'box_id' preceeded by its linenumber.  The linenumber
 *  field will be limited to 5 digits.  I hope no one ever has to edit a
 *  file with more than 99999 lines.
 *
 *  This code was stolen from mCompressView, more or less.
 *
 *  RETURNS:
 *
 *      TRUE        if everything is OK
 *      FALSE       if it is not
 */

integer proc PutMatchesInBox (string expr, string opts, integer search_id,
    integer box_id, var integer MaxLineLen)

    integer     MatchLineNo

    string      MatchLine[132]

    GotoBufferId (search_id)
    PushPosition ()
    BegFile ()

    if lFind (expr, opts)
        repeat
            MatchLine = GetText (1, sizeof (MatchLine))
            MatchLineNo = CurrLine ()

            if Length (MatchLine) > MaxLineLen
                MaxLineLen = Length (MatchLine)
            endif

            GotoBufferId (box_id)

            if not AddLine (
                Format (MatchLineNo:LINE_NUM_WIDTH, ':', MatchLine))
                return (FALSE)
            endif

            GotoBufferId (search_id)
            EndLine ()
        until not lRepeatFind ()

        PopPosition ()
        return (TRUE)
    endif

    PopPosition ()
    return (FALSE)

end

/*
 * DisplayMatches
 *
 *  This routine will display 'box_id' in a ListBox, and return the
 *  line number selected.
 *
 */

integer proc DisplayMatches (integer box_id, integer width)

    width = width + LINE_NUM_WIDTH + 1    // this is for the line numbers
    GotoBufferId (box_id)
    BegFile ()

    if width > Query (ScreenCols)
        width = Query (ScreenCols)
    endif

    return (lList ("Matches", width, LIST_BOX_HEIGHT, _ENABLE_SEARCH_))
end

/*
 * OpenSelectedFile
 *
 *  This routine will place the user in the file and line number selected.
 *  If the current line only contains a filename the user will be placed at
 *  the beginning of that file.
 *
 *  This routine assumes that the current line in the current buffer is the
 *  item selected by the user.
 */

integer proc OpenSelectedFile ()

    integer     line_no = 1

    string      filename[80],
                linenumber[LINE_NUM_WIDTH]

    linenumber = GetText (1, LINE_NUM_WIDTH)

    if linenumber <> "FILE:"
        /*
         * We are not on a filename line so compute the line number
         */

        line_no = Val (linenumber)
        lFind ("FILE: ", "b")
    endif

    filename = GetText (6, sizeof (filename))
    EditFile (filename)
    GotoLine (line_no)
    ScrollToRow (Query (WindowRows) / 2)
    BegLine ()

    return (TRUE)
end

/*
 * SaveFilename
 *
 *  This routine saves all files in the current file-ring into
 *  'savefile_id' which can be used to restore the ring back
 *  to its orignal condition.
 *
 *  RETURNS:
 *
 *      TRUE        if everything is OK
 *      FALSE       if it is not
 */

integer proc SaveRing (var integer savefile_id)

    integer     temp_id,                // used to save initial id
                first_id,
                i

    string      filename[80]

    temp_id = GetBufferId ()            // save current buffer
    first_id = temp_id                  // save first id

    savefile_id = CreateTempBuffer ()   // create a tempbuffer to place
                                        // filenames in.

    GotoBufferId (temp_id)

    i = Numfiles ()                     // Get the number of _NORMAL_ files

    if i == 0
        return (FALSE)
    endif

    while i
        temp_id = GetBufferId ()
        filename = CurrFilename ()      // Get current filename

        GotoBufferId (savefile_id)
        AddLine (filename)              // Save filename in savefile_id

        GotoBufferId (temp_id)          // We must return to temp_id in order
                                        // for NextFile to work properly.
        NextFile (_DONT_LOAD_)

        i = i - 1
    endwhile

    GotoBufferId (savefile_id)
    BegFile ()
    GotoBufferId (first_id)

    return (TRUE)

end

/*
 * RestoreRing
 *
 *  This routine will reload all the files which are listed in
 *  'savefile_id'.
 *
 *  RETURNS:
 *
 *      TRUE        if everything is OK
 *      FALSE       if it is not
 */

integer proc RestoreRing (integer savefile_id)

    integer     first_id,
                current_list,       // buffer containing a current list of
                                    // opened files
                i

    string      filename[80]


    first_id = GetBufferId ()
    current_list = CreateTempBuffer ()
    GotoBufferId (first_id)

    SaveRing (current_list)

    GotoBufferId (current_list)
    i = NumLines ()                 // Get the number of files in the current
                                    // list

    while i

        /*
         * Get a filename from the current_list
         */

        filename = GetText (1, sizeof (filename))
        GotoBufferId (savefile_id)

        /*
         * Is filename in savefile_id?
         */

        if lFind (filename, "^$G")

            /*
             * Yes, so delete the line in the current_list
             */

            GotoBufferId (current_list)
            DelLine ()
        else

            /*
             * No, skipover that filename so we can AbandonFile it later.
             */

            GotoBufferId (current_list)
            Down ()
        endif

        i = i - 1
    endwhile

    BegFile ()

    /*
     * Abandon every file listed in the current list
     */

    repeat
        AbandonFile (GetBufferId (GetText (1, sizeof (filename))))
    until not Down ()

    GotoBufferId (first_id)
    AbandonFile (current_list)
    return (TRUE)
end

/*
 * These are my default key assignments for these functions.
 */

<Shift F3>              FindInRing ()
<Ctrl F>                ListAllOf (FUNCTIONS)
<Ctrl G>                SearchCurrDir (GetWordAtCursor (), "G", SEARCH_FILES)
<Ctrl Q>                ListAllOf (USR_EXPR)
<Ctrl S>                SuperSearch (SEARCH_FILES)

