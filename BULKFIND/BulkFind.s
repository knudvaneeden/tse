/*
  Macro           BulkFind
  Author          Carlo.Hogeveen@xs4all.nl
  Version         v1.0.1 - 3 Feb 2020
  Compatibility   Windows TSE Pro v4.0 upwards,
                  Linux TSE Pro v4.41.24 upwards.

  This tool searches for a list of search terms in a list of files or in all
  open files.

  Input
    Default files to search: All opened files except the current file.
    Default terms to search for: The lines in the current file.
    Default search options: "i".
  Output
    Default output: A new buffer.
    Default output format: HELP (TSE's built-in Help format).

  You can change the defaults by optionally providing these macro parameters
    in=<name of file containing a list of files to search in>
    for=<name of file containg the list of search terms>
    opt=<the search options>
    out=<name of file to write the results to>
    fmt=<the output's initial display format>
  Where
    Parameters must be separated by spaces.
    Unless specified otherwise parameters are case-insentitive.
    It is strongly advised but not mandatory that file names have full paths.
    Quotes are optional for parameters containing no spaces.
    The "for" file may only have one search term per line; leading and trailing
    spaces are stripped unless the search term is quoted with either quote.
    Only these five TSE search options are allowed: "^iwx$".
    The default search options are "i"; an explicit "opt=" turns "i" off.
    Output display formats are "HELP" (default), "FINDS" and "TEXT".
    The HELP format displays the results in a browse mode like TSE's
    built-in Help with each found string nicely hilited.
    The FINDS format displays the results in a browse mode like TSE's
    built-in "View Finds" you get after a TSE search with the "v" option.
    Escaping the HELP and FINDS browse modes or selecting a line with <Enter>
    goes to the TEXT display mode, which here stands for the full editor.

  If the CmdLineParameter macro is installed, then BulkFind will accept the
  above parameters too after the " -p " command line option.
  See the documentation of CmdLineParameter for more.

  EXAMPLES PREMIS
  Let us find out if any of the 2943 male first names from
    http://www.cs.cmu.edu/Groups/AI/util/areas/nlp/corpora/names/male.txt
  occur in any TSE macro source files.

  EXAMPLE METHOD 1
  Open all TSE macro source files with
    -a <insert your TSE folder>\mac\*.s*
  Then open a new empty file and copy the names from the above link into it.
  Then run this command from the Macro Execute menu:
    BulkFind opt=iw

  EXAMPLE METHOD 2
  Open all TSE macro source files with
    -a <insert your TSE folder>\mac\*.s*
  Copy (the content of) the above male.txt file to "C:\male.txt".
  Then run this command from the Macro Execute menu:
    BulkFind for=c:\male.txt opt=iw fmt=text

  TODO
    MUST
    SHOULD
    COULD
    WONT

  HISTORY
  v0.1 - 18 Jan 2020
    Initial beta release. Enough works to be already useful.
  v0.2 - 20 Jan 2020
    Documented that the "out=<outputfile>" parameter does not work yet.
  v0.3 - 25 Jan 2020
    Made the "out=<outputfile>" parameter work.
    If the "in" and "for" file were not opened before BulkFind,
    then they are no longer open after BulkFind.
    Implemented the "fmt=finds" parameter.
    In the default output "HELP" display mode the multiple result lines for
    multiple search results in the same line are now merged into one line.
    Improved the afterwards cursor positioning.
    Fixed some very minor bugs.
    Improved the documentation.
  v0.4 - 26 Jan 2020
    Reduced memory usage and increased search capability by only temporarily
    loading unloaded files.
  v0.5 - 27 Jan 2020
    Fixed message line flashing.
    Fixed duplicate lines.
    Made BulkFind compatible with Linux TSE Pro v4.41.20 upwards.
    Fred H Olson reported that under Linux BulkFind does not understand "~/".
      Found out that Linux TSE does understand "~/" for some high-level TSE
      commands, but not (yet?) for these five low-level TSE commands:
        FileExists()
        FindFirstFile()
        fOpen()
        InsertFile()
        LoadBuffer()
      "Fixed" it by only for Linux replacing any of these low-level TSE
      commands that BulkFind was using with a high-level TSE command.
  v1.0 - 2 Feb 2020
    No more bug reports and no more plans for new features.
    Tweaked the documentation a bit and moved the tool out of the Beta section.
  v1.0.1 - 3 Feb 2020
    Fix specific to Linux:
      Semware fixed the above five low-level TSE commands in TSE Pro v4.41.24.
      I fixed BulkFind to no longer use work-arounds for these commands.
      BulkFind now requires TSE Pro v4.41.24 upwards for Linux.
*/





// Compatibility restrictions and mitigations

#ifdef LINUX
  #define WIN32 TRUE

  #ifdef EDITOR_VERSION
  #else
    Editor Version is older than TSE 3.0. You need at least Linux TSE v4.41.24.
  #endif

  #if EDITOR_VERSION < 4000h
    Editor Version is older than TSE 4.0. You need at least Linux TSE v4.41.24.
  #endif

  #if EDITOR_VERSION < 4200h
    Editor Version is older than TSE 4.2. You need at least Linux TSE v4.41.24.
  #endif

  #if EDITOR_VERSION < 4400h
    Editor Version is older than TSE 4.4. You need at least Linux TSE v4.41.24.
  #endif
#else
  #ifdef WIN32
  #else
    16-bit versions of TSE are not supported. You need at least Windows TSE v4.0.
  #endif

  #ifdef EDITOR_VERSION
  #else
    Editor Version is older than TSE 3.0. You need at least Windows TSE v4.0.
  #endif

  #if EDITOR_VERSION < 4000h
    Editor Version is older than TSE 4.0. You need at least Windows TSE v4.0.
  #endif
#endif



#ifdef LINUX
  /*
    compare_versions()  v2.0

    This proc compares two version strings version1 and version2, and returns
    -1, 0 or 1 if version1 is smaller, equal, or greater than/to version2.

    For the comparison a version string is split into parts:
    - Explicitly by separating parts by a period.
    - Implicitly:
      - Any uninterrupted sequence of digits is a "number part".
      - Any uninterrupted sequence of other characters is a "string part".

    Spaces are mostly ignored. They are only significant:
    - Between two digits they signify that the digits belong to different parts.
    - Between two "other characters" they belong to the same string part.

    If the first version part is a single "v" or "V" then it is ignored.

    Two version strings are compared by comparing their respective version parts
    from left to right.

    Two number parts are compared numerically, e.g: "1" < "2" < "11" < "012".

    Any other combination of version parts is case-insensitively compared as
    strings, e.g: "12" < "one" < "three" < "two", or "a" < "B" < "c" < "d".

    Examples: See the included unit tests further on.

    v2.0
      Out in the wild there is an unversioned version of compare_versions(),
      that is more restricted in what version formats it can recognize,
      there here versioning of compare_versions() starts at v2.0.
  */

  // compare_versions_standardize() is a helper proc for compare_versions().

  string proc compare_versions_standardize(string p_version)
    integer char_nr                  = 0
    string  n_version [MAXSTRINGLEN] = Trim(p_version)

    // Replace any spaces between digits by one period. Needs two StrReplace()s.
    n_version = StrReplace('{[0-9]} #{[0-9]}', n_version, '\1.\2', 'x')
    n_version = StrReplace('{[0-9]} #{[0-9]}', n_version, '\1.\2', 'x')

    // Remove any spaces before and after digits.
    n_version = StrReplace(' #{[0-9]}', n_version, '\1', 'x')
    n_version = StrReplace('{[0-9]} #', n_version, '\1', 'x')

    // Remove any spaces before and after periods.
    n_version = StrReplace(' #{\.}', n_version, '\1', 'x')
    n_version = StrReplace('{\.} #', n_version, '\1', 'x')

    // Separate version parts by periods if they aren't yet.
    char_nr = 1
    while char_nr < Length(n_version)
      case n_version[char_nr:1]
        when '.'
          NoOp()
        when '0' .. '9'
          if not (n_version[char_nr+1:1] in '0' .. '9', '.')
            n_version = n_version[1:char_nr] + '.' + n_version[char_nr+1:MAXSTRINGLEN]
          endif
        otherwise
          if (n_version[char_nr+1:1] in '0' .. '9')
            n_version = n_version[1:char_nr] + '.' + n_version[char_nr+1:MAXSTRINGLEN]
          endif
      endcase
      char_nr = char_nr + 1
    endwhile
    // Remove a leading 'v' if it is by itself, i.e not part of a non-numeric string.
    if  (n_version[1:2] in 'v.', 'V.')
      n_version = n_version[3:MAXSTRINGLEN]
    endif
    return(n_version)
  end compare_versions_standardize

  integer proc compare_versions(string version1, string version2)
    integer result                 = 0
    string  v1_part [MAXSTRINGLEN] = ''
    string  v1_str  [MAXSTRINGLEN] = ''
    string  v2_part [MAXSTRINGLEN] = ''
    string  v2_str  [MAXSTRINGLEN] = ''
    integer v_num_parts            = 0
    integer v_part_nr              = 0
    v1_str      = compare_versions_standardize(version1)
    v2_str      = compare_versions_standardize(version2)
    v_num_parts = Max(NumTokens(v1_str, '.'), NumTokens(v2_str, '.'))
    repeat
      v_part_nr = v_part_nr + 1
      v1_part   = Trim(GetToken(v1_str, '.', v_part_nr))
      v2_part   = Trim(GetToken(v2_str, '.', v_part_nr))
      if  v1_part == ''
      and isDigit(v2_part)
        v1_part = '0'
      endif
      if v2_part == ''
      and isDigit(v1_part)
        v2_part = '0'
      endif
      if  isDigit(v1_part)
      and isDigit(v2_part)
        if     Val(v1_part) < Val(v2_part)
          result = -1
        elseif Val(v1_part) > Val(v2_part)
          result =  1
        endif
      else
        result = CmpiStr(v1_part, v2_part)
      endif
    until result    <> 0
       or v_part_nr >= v_num_parts
    return(result)
  end compare_versions

  /*

  // Unit tests for compare_versions().
  proc Main()
    if not (compare_versions(''         , ''           ) ==  0) Warn('Test  1 failed.') endif
    if not (compare_versions('.'        , ''           ) ==  0) Warn('Test  2 failed.') endif
    if not (compare_versions('0.0'      , ''           ) ==  0) Warn('Test  3 failed.') endif
    if not (compare_versions('v0.0'     , ''           ) ==  0) Warn('Test  4 failed.') endif
    if not (compare_versions(' v 0 . 0 ', ''           ) ==  0) Warn('Test  5 failed.') endif
    if not (compare_versions(' v 0 . 0 ', 'V0.0'       ) ==  0) Warn('Test  6 failed.') endif
    if not (compare_versions(' v 0 . 0 ', 'V.0'        ) ==  0) Warn('Test  7 failed.') endif
    if not (compare_versions(' v 0 . 0 ', 'V.'         ) ==  0) Warn('Test  8 failed.') endif
    if not (compare_versions('v 1 2'    , 'v1.2'       ) ==  0) Warn('Test  9 failed.') endif
    if not (compare_versions('v a b'    , 'a b'        ) ==  1) Warn('Test 10 failed.') endif
    if not (compare_versions('a b'      , 'v a b'      ) == -1) Warn('Test 11 failed.') endif
    if not (compare_versions('1'        , '3'          ) == -1) Warn('Test 12 failed.') endif
    if not (compare_versions('2'        , '2'          ) ==  0) Warn('Test 13 failed.') endif
    if not (compare_versions('3'        , '1'          ) ==  1) Warn('Test 14 failed.') endif
    if not (compare_versions('1.1'      , '1.01'       ) ==  0) Warn('Test 15 failed.') endif
    if not (compare_versions('1.0'      , '1'          ) ==  0) Warn('Test 16 failed.') endif
    if not (compare_versions('1.1'      , '1'          ) ==  1) Warn('Test 17 failed.') endif
    if not (compare_versions('1.2'      , '2.1'        ) == -1) Warn('Test 18 failed.') endif
    if not (compare_versions('1.20'     , '1.3'        ) ==  1) Warn('Test 19 failed.') endif
    if not (compare_versions('1.2.3.4'  , '01.02.03.04') ==  0) Warn('Test 10 failed.') endif
    if not (compare_versions('1.2.3.4'  , '1.2.4.3'    ) == -1) Warn('Test 21 failed.') endif
    if not (compare_versions('.1'       , '0.1'        ) ==  0) Warn('Test 22 failed.') endif
    if not (compare_versions('..1'      , '0.0.1'      ) ==  0) Warn('Test 23 failed.') endif
    if not (compare_versions('1.'       , '1.0'        ) ==  0) Warn('Test 24 failed.') endif
    if not (compare_versions('1..'      , '1.0.00.000' ) ==  0) Warn('Test 25 failed.') endif
    if not (compare_versions('1.0.00.00', '1..'        ) ==  0) Warn('Test 26 failed.') endif
    if not (compare_versions('1'        , '1 0 00 000' ) ==  0) Warn('Test 27 failed.') endif
    if not (compare_versions('1 0 00 00', '1'          ) ==  0) Warn('Test 28 failed.') endif
    if not (compare_versions('1a'       , '1a'         ) ==  0) Warn('Test 29 failed.') endif
    if not (compare_versions('1 a'      , '1 a'        ) ==  0) Warn('Test 30 failed.') endif
    if not (compare_versions('1.a'      , '1a'         ) ==  0) Warn('Test 31 failed.') endif
    if not (compare_versions(' v 1 . a ', '1a'         ) ==  0) Warn('Test 32 failed.') endif
    if not (compare_versions(' v . 1 a ', '1a'         ) ==  0) Warn('Test 33 failed.') endif
    if not (compare_versions('1a'       , '1b'         ) == -1) Warn('Test 34 failed.') endif
    if not (compare_versions('1b'       , '1a'         ) ==  1) Warn('Test 35 failed.') endif
    if not (compare_versions('v4.00'    , 'v4.00a'     ) == -1) Warn('Test 36 failed.') endif
    if not (compare_versions('v4.00a'   , 'v4.00e'     ) == -1) Warn('Test 37 failed.') endif
    if not (compare_versions('v4.00'    , 'v4.41.10'   ) == -1) Warn('Test 38 failed.') endif
    if not (compare_versions('v4.00e'   , 'v4.41.10'   ) == -1) Warn('Test 39 failed.') endif
    if not (compare_versions('v4.20'    , 'v4.41.10'   ) == -1) Warn('Test 40 failed.') endif
    if not (compare_versions('v4.40'    , 'v4.41.10'   ) == -1) Warn('Test 41 failed.') endif
    if not (compare_versions('v4.40a'   , 'v4.41.10'   ) == -1) Warn('Test 42 failed.') endif
    if not (compare_versions('v4.41.00' , 'v4.41.10'   ) == -1) Warn('Test 43 failed.') endif
    if not (compare_versions('v4.41.01' , 'v4.41.10'   ) == -1) Warn('Test 44 failed.') endif
    if not (compare_versions('one'      , 'two'        ) == -1) Warn('Test 45 failed.') endif
    if not (compare_versions('two'      , 'three'      ) ==  1) Warn('Test 46 failed.') endif
    if not (compare_versions('the first', 'the second' ) == -1) Warn('Test 47 failed.') endif
    if not (compare_versions('the third', 'the fourth' ) ==  1) Warn('Test 48 failed.') endif
    if not (compare_versions('a'        , 'a'          ) ==  0) Warn('Test 49 failed.') endif
    if not (compare_versions('a'        , 'ab'         ) == -1) Warn('Test 50 failed.') endif
    if not (compare_versions('ab'       , 'abc'        ) == -1) Warn('Test 51 failed.') endif
    if not (compare_versions('abc'      , 'ab'         ) ==  1) Warn('Test 52 failed.') endif
    if not (compare_versions('a'        , 'B'          ) == -1) Warn('Test 53 failed.') endif
    if not (compare_versions('B'        , 'c'          ) == -1) Warn('Test 54 failed.') endif
    Warn('The end.')
    PurgeMacro(SplitPath(CurrMacroFilename(), _NAME_))
  end Main

  */
#endif



// End of compatibility restrictions and mitigations





// Global constants
string ALLOWED_SEARCH_OPTIONS        [5] = 'iwx^$'
string CMDLINE_MACRO_NAME [MAXSTRINGLEN] = 'CmdLineParameter'

string HELP_BOLD_OPEN_TAG     [3] = '®B¯'
string HELP_BOLD_CLOSE_TAG    [4] = '®/B¯'

string HELP_INFO_OPEN_TAG     [4] = '®LI¯'
string HELP_INFO_CLOSE_TAG    [4] = '®/L¯'

string HELP_ITALICS_OPEN_TAG  [3] = '®I¯'
string HELP_ITALICS_CLOSE_TAG [4] = '®/I¯'

string HELP_LINK_OPEN_TAG     [3] = '®L¯'
string HELP_LINK_CLOSE_TAG    [4] = '®/L¯'



// Global variables
string  file_close_tag     [MAXSTRINGLEN] = ''
string  file_open_tag      [MAXSTRINGLEN] = ''
string  my_macro_name      [MAXSTRINGLEN] = ''
integer pre_finds_display_mode            = 0
string  string_close_tag   [MAXSTRINGLEN] = ''
string  string_open_tag    [MAXSTRINGLEN] = ''
integer tmp_result_id                     = 0
integer tmp_search_id                     = 0



// Local code
string proc unquote(string s)
  string result [MAXSTRINGLEN] = s
  if (result[1:1] in '"', "'")
  and result[1:1] == result[1:Length(result)]
    result = SubStr(result, 2, Length(result) -2)
  endif
  return(result)
end unquote

/*
  The following function determines the minimum amount of characters that a
  given regular expression can match. For the practical purpose that they are
  valid matches too, "^" and "$" are pretended to have length 1.
  The purpose of this procedure is, to be able to beforehand avoid searching
  for an empty string, which is logically pointless because it always succeeds
  (with one exception: past the end of the last line).
  Searching for an empty string in a loop makes it infinate and hangs a macro.
  Properly applied, using this procedure can avoid that.
*/
integer proc minimum_regexp_length(string s)
  integer addition           = 0
  integer i                  = 0
  integer NEXT_TIME          = 2
  integer orred_addition     = 0
  integer prev_addition      = 0
  integer prev_i             = 0
  integer result             = 0
  integer tag_level          = 0
  integer THIS_TIME          = 1
  integer use_orred_addition = FALSE
  // For each character.
  for i = 1 to Length(s)
    // Ignore this zero-length "character".
    if Lower(SubStr(s,i,2)) == "\c"
      i = i + 1
    else
      // Skip index for all these cases so they will be counted as one
      // character.
      case SubStr(s,i,1)
        when "["
          while i < Length(s)
          and   SubStr(s,i,1) <> "]"
            i = i + 1
          endwhile
        when "\"
          i = i + 1
          case Lower(SubStr(s,i,1))
            when "x"
              i = i + 2
            when "d", "o"
              i = i + 3
          endcase
      endcase
      // Now start counting.
      if use_orred_addition == NEXT_TIME
         use_orred_addition =  THIS_TIME
      endif
      // Count a literal character as one:
      if SubStr(s,i-1,1) == "\" // (Using the robustness of SubStr!)
        addition = 1
      // Count a tagged string as the length of its subexpression:
      elseif SubStr(s,i,1) == "{"
        prev_i = i
        tag_level = 1
        while i < Length(s)
        and   (tag_level <> 0 or SubStr(s,i,1) <> "}")
          i = i + 1
          if SubStr(s,i,1) == "{"
            tag_level = tag_level + 1
          elseif SubStr(s,i,1) == "}"
            tag_level = tag_level - 1
          endif
        endwhile
        addition = minimum_regexp_length(SubStr(s,prev_i+1,i-prev_i-1))
      // For a "previous character or tagged string may occur zero
      // times" operator: since it was already counted, subtract it.
      elseif SubStr(s,i,1) in "*", "@", "?"
        addition = -1 * Abs(prev_addition)
      // This is a tough one: the "or" operator.
      // For now subtract the length of the previous character or
      // tagged string, but remember doing so, because you might have
      // to add it again instead of the length of the character or
      // tagged string after the "or" operator.
      elseif SubStr(s,i,1) == "|"
        addition           = -1 * Abs(prev_addition)
        orred_addition     = Abs(prev_addition)
        use_orred_addition = NEXT_TIME
      else
      // Count ordinary characters as 1 character.
        addition = 1
      endif
      if use_orred_addition == THIS_TIME
        if orred_addition < addition
          addition = orred_addition
        endif
        use_orred_addition = FALSE
      endif
      result        = result + addition
      prev_addition = addition
    endif
  endfor
  return(result)
end minimum_regexp_length

/*
  This file_exists() proc avoids an obscure bug in FileExists().

  The bug exists in TSE versions up to and including TSE Pro v4.4:
    If the following file exists in the current folder
      "file1.txt file2.txt"
    then when assessing the not-existing file '"file1.txt" "file2.txt"'
    FileExists() erroneously returns that it exists.
    It does not matter if "file1.txt" and "file2.txt" exist.
*/
integer proc file_exists(string file_name)
  integer result = FALSE
  integer handle = -1
  handle = FindFirstFile(file_name, -1)
  if handle <> -1
    result = FFAttribute()
    FindFileClose(handle)
  endif
  return(result)
end file_exists

integer proc edit_this_file(string file_name)
  // Using this proc instead of EditThisFile() because of its non-existence
  // in TSE v4.0 and its bug in TSE v4.2 and v4.4.
  // This proc is a place holder: It is not well thought out yet.
  integer file_attributes = 0
  integer file_id         = 0
  file_attributes = file_exists(file_name)
  if file_attributes & _DIRECTORY_
    if Query(MsgLevel) <> _NONE_
      Warn('Folder instead of file: ', file_name)
    endif
  else
    #if EDITOR_VERSION >= 4200h
      file_id = EditThisFile(file_name, _DONT_PROMPT_)
    #else
      file_id = EditFile(QuotePath(file_name), _DONT_PROMPT_)
    #endif
  endif
  return(file_id)
end edit_this_file

integer proc search_current_file(string  file_name,
                                 integer for_id,
                                 string  permanent_search_options,
                                 integer out_id)
  integer curr_line                  = 0
  integer curr_pos                   = 0
  integer cur_id                     = GetBufferId()
  integer file_has_search_results    = FALSE
  string  found_text  [MAXSTRINGLEN] = ''
  integer is_found                   = FALSE
  integer line_number_length         = Length(Str(NumLines())) + 1
  integer ok                         = TRUE
  integer old_ilba                   = 0
  integer old_MsgLevel               = 0
  string  search_options         [6] = '' // [Length(ALLOWED_SEARCH_OPTIONS) + 1]
  string  search_term [MAXSTRINGLEN] = ''
  string  text        [MAXSTRINGLEN] = ''
  PushPosition()
  GotoBufferId(tmp_result_id)
  EmptyBuffer()
  GotoBufferId(for_id)
  BegFile()
  repeat
    search_term = unquote(Trim(GetText(1, MAXSTRINGLEN)))
    if search_term <> ''
      GotoBufferId(cur_id)
      search_options = permanent_search_options + 'g'
      is_found       = lFind(search_term, search_options)
      search_options = permanent_search_options + '+'
      while is_found
        file_has_search_results = TRUE
        found_text              = GetFoundText()
        text                    = GetText(1, MAXSTRINGLEN)
        curr_line               = CurrLine()
        curr_pos                = CurrPos()
        GotoBufferId(tmp_result_id)
        AddLine(Format(curr_line:line_number_length, ':';
                       text[1 : curr_pos - 1],
                       string_open_tag,
                       found_text,
                       string_close_tag,
                       text[curr_pos + Length(found_text) : MAXSTRINGLEN]))
        GotoBufferId(cur_id)
        is_found = lFind(search_term, search_options)
      endwhile
      GotoBufferId(for_id)
    endif
  until not ok
     or not Down()
  if  ok
  and file_has_search_results
    GotoBufferId(tmp_result_id)
    MarkColumn(1, 2, NumLines(), line_number_length)
    old_MsgLevel = Set(MsgLevel, _NONE_)
    ExecMacro('sort')
    Set(MsgLevel, old_MsgLevel)
    MarkLine(1, NumLines())
    Copy()
    GotoBufferId(out_id)
    AddLine(Format(file_open_tag, 'File: ', file_name, file_close_tag))
    old_ilba = Set(InsertLineBlocksAbove, FALSE)
    Paste()
    Set(InsertLineBlocksAbove, old_ilba)
    UnMarkBlock()
    EndFile()
    BegLine()
  endif
  PopPosition()
  return(ok)
end search_current_file

integer proc search_listed_files(integer in_id,
                                 integer for_id,
                                 string  search_options,
                                 integer out_id)
  integer file_counter             = 0
  string  file_name [MAXSTRINGLEN] = ''
  integer ok                       = TRUE
  GotoBufferId(in_id)
  BegFile()
  repeat
    file_counter = file_counter + 1
    KeyPressed()
    Message('BulkFind'; (file_counter * 100) / NumLines(); '% ... ')
    KeyPressed()
    file_name = Trim(GetText(1, MAXSTRINGLEN))
    if file_exists(file_name)
      GotoBufferId(tmp_search_id)
      if LoadBuffer(file_name)
        ok = search_current_file(file_name, for_id, search_options, out_id)
      else
        Warn('Load error for "', file_name, '".')
        ok = FALSE
      endif
    endif
    GotoBufferId(in_id)
  until not ok
     or not Down()
  return(ok)
end search_listed_files

integer proc search_all_normal_buffers(integer for_id,
                                       string  search_options,
                                       integer out_id)
  integer file_counter  = 0
  integer ok            = TRUE
  integer old_MsgLevel  = 0
  integer unload_id     = 0
  GotoBufferId(for_id)
  NextFile(_DONT_LOAD_)
  while ok
  and   GetBufferId() <> for_id
    if GetBufferId() <> out_id
      if Query(BufferFlags) & _LOADED_
        unload_id = 0
      else
        unload_id = GetBufferId()
        PrevFile(_DONT_LOAD_)
        // Suppress the loading the file message.
        old_MsgLevel = Set(MsgLevel, _NONE_)
        NextFile()
        Set(MsgLevel, old_MsgLevel)
      endif
      file_counter = file_counter + 1
      KeyPressed()
      Message('BulkFind'; (file_counter * 100) / NumFiles(); '% ... ')
      KeyPressed()
      ok = search_current_file(CurrFilename(), for_id, search_options, out_id)
      if unload_id
        UnloadBuffer(unload_id)
      endif
    endif
    NextFile(_DONT_LOAD_)
  endwhile
  return(ok)
end search_all_normal_buffers

Keydef BrowseKeys
  <CursorUp>        Up()
  <CursorDown>      Down()
  <PgUp>            PageUp()
  <PgDn>            PageDown()
  <Home>            BegFile()
  <end>             EndFile()

  <GreyCursorUp>    Up()
  <GreyCursorDown>  Down()
  <GreyPgUp>        PageUp()
  <GreyPgDn>        PageDown()
  <GreyHome>        BegFile()
  <GreyEnd>         EndFile()

  <Enter>           EndProcess()
  <GreyEnter>       EndProcess()
  <Escape>          EndProcess()

  <HelpLine> '          Press {Escape} or {Enter} to exit the HELP-like browse mode          '
end BrowseKeys

proc display_help()
  integer old_ShowHelpLine   = Set(ShowHelpLine  , ON)
  integer old_ShowMainMenu   = Set(ShowMainMenu  , OFF)
  integer old_ShowStatusLine = Set(ShowStatusLine, OFF)
  integer old_DisplayMode    = DisplayMode(_DISPLAY_HELP_)
  if Enable(BrowseKeys, _EXCLUSIVE_)
    Process()
    Disable(BrowseKeys)
  endif
  Set(ShowHelpLine  , old_ShowHelpLine  )
  Set(ShowMainMenu  , old_ShowMainMenu  )
  Set(ShowStatusLine, old_ShowStatusLine)
      DisplayMode   ( old_DisplayMode   )
  lReplace(HELP_BOLD_OPEN_TAG    , '', 'gn')
  lReplace(HELP_BOLD_CLOSE_TAG   , '', 'gn')
  lReplace(HELP_INFO_OPEN_TAG    , '', 'gn')
  lReplace(HELP_INFO_CLOSE_TAG   , '', 'gn')
  lReplace(HELP_ITALICS_OPEN_TAG , '', 'gn')
  lReplace(HELP_ITALICS_CLOSE_TAG, '', 'gn')
  lReplace(HELP_LINK_OPEN_TAG    , '', 'gn')
  lReplace(HELP_LINK_CLOSE_TAG   , '', 'gn')
  ScrollToCenter()
end display_help

proc finds_list_startup()
  pre_finds_display_mode = DisplayMode(_DISPLAY_FINDS_)
  ListFooter(" Press {Escape} or {Enter} to exit the FINDS-like browse mode ")
  UnHook(finds_list_startup)
end finds_list_startup

proc finds_list_cleanup()
  DisplayMode(pre_finds_display_mode)
  UnHook(finds_list_cleanup)
end finds_list_cleanup

proc display_finds()
  Hook(_LIST_STARTUP_, finds_list_startup)
  Hook(_LIST_CLEANUP_, finds_list_cleanup)
  List('BulkFinds', LongestLineInBuffer())
  ScrollToCenter()
end display_finds

proc remove_duplicate_lines()
  string  curr_line_pos_1_11 [11] = ''
  integer old_CurrLine            = CurrLine()
  string  prev_line_pos_1_11 [11] = ''
  BegFile()
  prev_line_pos_1_11 = GetText(1, 11)
  while Down()
    curr_line_pos_1_11 = GetText(1, 11)
    if curr_line_pos_1_11 == prev_line_pos_1_11
      KillLine()
      Up()
      if CurrLine() < old_CurrLine
        old_CurrLine = old_CurrLine - 1
      endif
    else
      prev_line_pos_1_11 = curr_line_pos_1_11
    endif
  endwhile
  GotoLine(old_CurrLine)
end remove_duplicate_lines

proc merge_double_help_lines()
  // Assumption:
  //   We are already in the output file, the lines of which were generated
  //   in the Help Format.
  integer close_tag_length  = Length(string_close_tag)
  integer curr_line_number  = 0
  integer curr_pos          = 0
  integer open_tag_length   = Length(string_open_tag)
  integer prev_line_number  = 0
  integer prev_pos          = 0
  integer tags_merged       = FALSE
  BegFile()
  curr_line_number = Val(GetToken(GetText(1, MAXSTRINGLEN), ':', 1))
  while Down()
    prev_line_number = curr_line_number
    curr_line_number = Val(GetToken(GetText(1, MAXSTRINGLEN), ':', 1))
    if  curr_line_number == prev_line_number
    and curr_line_number <> 0
      // Method:
      //   Merge the current line's format codes into the previous line's
      //   format codes and delete the current line.
      // Note:
      //   At any moment the previous line will be at least as long as the
      //   current line.
      // Example:
      //   Line 1: Gandalf is ®L¯old®/L¯ and wise.
      //   Line 2: Gandalf is old and ®L¯wise®/L¯.
      //   Merged: Gandalf is ®L¯old®/L¯ and ®L¯wise®/L¯.
      prev_pos    = 1
      curr_pos    = 1
      tags_merged = FALSE
      BegLine()
      while CurrChar(curr_pos) <> _AT_EOL_
        Up()
        if GetText(prev_pos, open_tag_length) == string_open_tag
          prev_pos = prev_pos + open_tag_length
        elseif GetText(prev_pos, close_tag_length) == string_close_tag
          prev_pos = prev_pos + close_tag_length
        endif
        Down()
        if GetText(curr_pos, open_tag_length) == string_open_tag
          Up()
          GotoPos(prev_pos)
          InsertText(string_open_tag, _INSERT_)
          prev_pos = prev_pos + open_tag_length - 1
          Down()
          curr_pos = curr_pos + open_tag_length - 1
          tags_merged = TRUE
        elseif GetText(curr_pos, close_tag_length) == string_close_tag
          Up()
          GotoPos(prev_pos)
          InsertText(string_close_tag, _INSERT_)
          prev_pos = prev_pos + close_tag_length - 1
          Down()
          curr_pos = curr_pos + close_tag_length - 1
          tags_merged = TRUE
        endif
        prev_pos = prev_pos + 1
        curr_pos = curr_pos + 1
      endwhile
      if tags_merged
        KillLine()
        Up()
      endif
    endif
  endwhile
  BegFile()
end merge_double_help_lines

string proc get_next_macro_parameter(string macro_cmd_line, var integer p)
  integer closing_quote_pos    = 0
  integer closing_space_pos    = 0
  string  first_value_char [1] = ''
  string  par   [MAXSTRINGLEN] = ''
  integer par_end_pos          = 0
  while macro_cmd_line[p] == ' '
    p = p + 1
  endwhile
  par         = macro_cmd_line[p : MAXSTRINGLEN]
  par_end_pos = Pos('=', par)
  if par_end_pos
    par_end_pos = par_end_pos + 1
    first_value_char = par[par_end_pos]
    case first_value_char
      when ' ', ''
        par_end_pos = par_end_pos - 1
      when '"', "'"
        closing_quote_pos =
          Pos(first_value_char, par[par_end_pos + 1 : MAXSTRINGLEN])
        if closing_quote_pos
          par_end_pos = par_end_pos + closing_quote_pos
        else
          par_end_pos = Length(par)
        endif
      otherwise
        closing_space_pos = Pos(' ', par[par_end_pos : MAXSTRINGLEN])
        if closing_space_pos
          par_end_pos = par_end_pos + closing_space_pos - 2
        else
          par_end_pos = Length(par)
        endif
    endcase
    par = par[1 : par_end_pos]
    p   = p + par_end_pos
  else
    p = Length(macro_cmd_line) + 1
  endif
  return(par)
end get_next_macro_parameter

integer proc get_parameters(var string search_in,
                            var string search_for,
                            var string search_opt,
                            var string search_out,
                            var string search_fmt)
  integer i                             = 0
  string  macro_cmd_line [MAXSTRINGLEN] = ''
  integer macro_cmd_line_pos            = 0
  integer ok                            = TRUE
  string  par            [MAXSTRINGLEN] = ''
  string  par_name       [MAXSTRINGLEN] = ''
  string  var_name       [MAXSTRINGLEN] = ''
  search_in  = ''
  search_for = ''
  search_opt = ''
  search_out = ''
  search_fmt = ''
  macro_cmd_line = Trim(Query(MacroCmdLine))
  if macro_cmd_line <> ''
    macro_cmd_line_pos = 1
    repeat
      par = get_next_macro_parameter(macro_cmd_line, macro_cmd_line_pos)
      if par <> ''
        par_name = Lower(GetToken(par, '=', 1))
        case par_name
          when 'in'
            search_in  = GetToken(par, '=', 2)
          when 'for'
            search_for = GetToken(par, '=', 2)
          when 'opt'
            search_opt = GetToken(par, '=', 2)
            // The user explicitly set OPT to ''. We change that to ' '
            // to disable setting OPT to its default 'i' setting later on.
            search_opt = iif(search_opt == '', ' ', search_opt)
          when 'out'
            search_out = GetToken(par, '=', 2)
          when 'fmt'
            search_fmt = GetToken(par, '=', 2)
          otherwise
            Warn('Illegal parameter name "', par_name, '"')
            ok = FALSE
        endcase
      endif
    until par == ''
    /*
    search_in = get_macro_parameter(macro_cmd_line, 'in')
    search_for= get_macro_parameter(macro_cmd_line, 'for')
    search_opt= get_macro_parameter(macro_cmd_line, 'opt')
    search_out= get_macro_parameter(macro_cmd_line, 'out')
    search_out= get_macro_parameter(macro_cmd_line, 'fmt')
    */
  else
    // Get any CmdLineParameter's command line parameters for this macro.
    // The global variable name is "CmdLineParameter:<MyMacroName>:<n>".
    i = 0
    repeat
      var_name = Format(CMDLINE_MACRO_NAME, ':', my_macro_name, ':', i)
      par      = GetGlobalStr(var_name)
      if par <> ''
        DelGlobalVar(var_name) // Process dos parameters only once.
        par_name = Lower(GetToken(par, '=', 1))
        case par_name
          when 'in'
            search_in  = GetToken(par, '=', 2)
          when 'for'
            search_for = GetToken(par, '=', 2)
          when 'opt'
            search_opt = GetToken(par, '=', 2)
            // The user explicitly set OPT to ''. We change that to ' '
            // to disable setting OPT to its default 'i' setting later on.
            search_opt = iif(search_opt == '', ' ', search_opt)
          when 'out'
            search_out = GetToken(par, '=', 2)
          when 'fmt'
            search_fmt = GetToken(par, '=', 2)
          otherwise
            Warn('Illegal parameter name "', par_name, '"')
            ok = FALSE
        endcase
      endif
    until par == ''
  endif
  return(ok)
end get_parameters

proc uniquefy_temp_buffer_name(string identifying_name_part)
  integer i               = 2
  string  uniquefier [11] = ''
  while    i < MAXINT
  and  not ChangeCurrFilename(Format(my_macro_name,
                                     ':',
                                     identifying_name_part,
                                     uniquefier),
                              _DONT_PROMPT_|_DONT_EXPAND_|_OVERWRITE_)
    uniquefier = ':' + Str(i)
    i          = i   + 1
  endwhile
end uniquefy_temp_buffer_name

proc WhenLoaded()
  integer org_id   = GetBufferId()
  my_macro_name    = SplitPath(CurrMacroFilename(), _NAME_)
  tmp_search_id    = CreateTempBuffer()
  uniquefy_temp_buffer_name('TempSearchBuffer')
  tmp_result_id    = CreateTempBuffer()
  uniquefy_temp_buffer_name('TempResultBuffer')
  GotoBufferId(org_id)
end WhenLoaded

proc Main()
  integer for_id                     = 0
  integer for_file_is_temporary      = FALSE
  integer i                          = 0
  integer in_id                      = 0
  integer ok                         = TRUE
  integer old_UndoMode               = TRUE
  integer out_id                     = 0
  string  search_fmt  [MAXSTRINGLEN] = ''
  string  search_for  [MAXSTRINGLEN] = ''
  string  search_in   [MAXSTRINGLEN] = ''
  string  search_opt  [MAXSTRINGLEN] = ''
  string  search_out  [MAXSTRINGLEN] = ''
  string  search_term [MAXSTRINGLEN] = ''
   //
   PushPosition()
   PushBlock()
  IF ( NumLines() > 100 )
   EndFile()
   UpDateDisplay() // IF WaitForKeyPressed( 0 ) ENDIF // Activate if using a loop
   IF NOT YesNo( "Are you sure that the current file loaded contains all the search lines that you want to search in all the other files?" ) == 1
    PopBlock()
    PopPosition()
    RETURN()
   ENDIF
  ENDIF
  PopBlock()
  PopPosition()
  //
  #ifdef LINUX
    if compare_versions(VersionStr(), 'v4.41.24') < 0
      Warn('In Linux this version of BulkFind requires TSE Pro v4.41.24 upwards.')
      ok = FALSE
    endif
  #endif
  if ok
    ok = get_parameters(search_in, search_for, search_opt, search_out,
                        search_fmt)
  endif
  if ok
    if search_in <> ''
      if file_exists(search_in)
        in_id = edit_this_file(search_in)
        if not in_id
          Warn('Error opening "in" file: ', search_in)
          ok = FALSE
        endif
      else
        Warn('The "in" file does not exist: ', search_in)
        ok = FALSE
      endif
    endif
  endif
  if ok
    if search_for == ''
      for_id = GetBufferId()
    else
      if file_exists(search_for)
        for_id = edit_this_file(search_for)
        if for_id
          for_file_is_temporary = TRUE
        else
          Warn('File open error: ', search_for)
          ok = FALSE
        endif
      else
        Warn('The "for" file does not exist: ', search_for)
        ok = FALSE
      endif
    endif
  endif
  if ok
    if search_opt == ' '
      search_opt = ''
    elseif Trim(search_opt) == ''
      search_opt = 'i'
    else
      i = 1
      while ok
      and   i <= Length(search_opt)
        if Pos(Lower(search_opt[i]), ALLOWED_SEARCH_OPTIONS)
          i = i + 1
        else
          Warn('Illegal search option "', search_opt[i],
               '" in search options "', search_opt, '".')
          ok = FALSE
        endif
      endwhile
    endif
  endif
  if  ok
  and Pos('x', Lower(search_opt))
    GotoBufferId(for_id)
    PushPosition()
    BegFile()
    repeat
      search_term = unquote(Trim(GetText(1 , MAXSTRINGLEN)))
      if  search_term <> ''
      and minimum_regexp_length(search_term) == 0
        Warn('Illegal regular expression "', search_term,
             '" because it matches an empty string.')
        ok = FALSE
      endif
    until not ok
       or not Down()
    if ok
      PopPosition()
    else
      KillPosition()
    endif
  endif
  if ok
    if search_out == ''
      out_id = NewFile()
    else
      out_id = edit_this_file(search_out)
      if not out_id
        Warn('Open error: ', search_out)
        ok = FALSE
      endif
    endif
    if out_id
      old_UndoMode = UndoMode(OFF)
    endif
  endif
  if ok
    if not (Lower(search_fmt) in 'finds', 'text')
      if (Lower(search_fmt) in 'help', '')
        file_open_tag    = HELP_ITALICS_OPEN_TAG
        file_close_tag   = HELP_ITALICS_CLOSE_TAG
        string_open_tag  = HELP_LINK_OPEN_TAG
        string_close_tag = HELP_LINK_CLOSE_TAG
      else
        Warn('Illegal search format "', search_fmt, '".')
        ok = FALSE
      endif
    endif
  endif
  if ok
    GotoBufferId(for_id)
    PushPosition()
    if in_id
      ok = search_listed_files(in_id, for_id, search_opt, out_id)
    else
      ok = search_all_normal_buffers(for_id, search_opt, out_id)
    endif
    if ok
      PopPosition()
    else
      KillPosition()
    endif
  endif
  if ok
    GotoBufferId(out_id)
    BegFile()
    case Lower(search_fmt)
      when 'help', ''
        merge_double_help_lines()
        display_help()
      when 'finds'
        remove_duplicate_lines()
        display_finds()
      otherwise
        remove_duplicate_lines()
    endcase
    FileChanged(FALSE)
    UndoMode(old_UndoMode)
  endif
  if ok
    if in_id
      AbandonFile(in_id)
    endif
    if  for_file_is_temporary
    and for_id
      AbandonFile(for_id)
    endif
  endif
  PurgeMacro(my_macro_name)
end Main

