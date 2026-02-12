/*
  Macro           eHelp_Hlp2eHelp
  Author          Carlo Hogeveen
  Website         eCarlo.nl/tse
  Compatibility   TSE v4 upwards, all TSE variants
  Version         v0.2   15 Oct 2022


  DEVELOPMENT !!!
    This tool is part of a future application that will consist of a group of
    macros.
    The application is in development and far from finished.
    As a consequence, besides because of undiscovered errors, the risk of which
    is higher than for a finished product, this tool might also still be
    changed to serve a future need of the application.


  SUMMARY
    This tool generates a readable "tsehelp.ehelp" file from TSE's unreadable
    "tsehelp.hlp" and "compile.hlp" files.

    This tsehelp.ehelp file is NOT to be edited!
    It will be reinitialized if it is changed.
    It is not used by eHelp to show help, and only serves as a reference and
    example file for tsehelp_<user>.ehelp files.

    Like TSE's Help, the generated file is OEM character encoded.
    The Help's syntax codes is represented by HTML- or XML-like tags.
    The generated file is an as close as possible representation of the two
    source files, with the exception that it does not contain the Help's Index.


  INSTALLATION
    Just copy this file to TSE's "mac" directory, and compile it there, for
    instance by opening it there in TSE and applying the Macro Compile menu.


  USAGE
    Its intended use is as a helper-tool for the eHelp extension,
    but it can be (re)executed at any time as a stand-alone tool.
    It has no parameters or configuration because it does just one thing.
    It (over)writes a help\tsehelp.ehelp file to TSE's LoadDir() directory with
    a readable copy of the contents of the tsehelp.hlp en compile.hlp files.


  SYNTAX of .ehelp file

    A .ehelp file uses HTML/XML-like opening and closing tags to give meaning
    to what it encloses.
    It does that in a practical way though, only where useful, and not where
    practicality is better served by succinctness instead of verbosity.

    <EHELP> and </EHELP> tags enclose the whole file.

    <META> and </META> tags enclose information about the file.

    <FORMAT> and </FORMAT> tags enclose the file's format.
      If we ever regret the chosen format, then we can move on to a new format
      while easily being able to recognize the difference.

    Address format
      TSE's Help uses what is called "logical addresses".
      Logical addresses are not some cryptical id or number, but a name that
      has meaning, or a combination of such names.
      A name can contain spaces, cannot contain the characters ";" and "^",
      and cannot contain .ehelp tags.
      An address can be one of four things:
      - The name of a topic.
      - The name of a subtopic.
      - The names of a subtopic in a specific topic,
        formatted as "topic name;subtopic name".
      - A name to be redirected to an address.
        This name can be a new name or overrule an existing name.
        Redirection is typically used for:
        - Redirecting a bare subtopic name to a subtopic in a specific topic.
        - Redirecting a menu name to an adress.
          When you press F1 on a TSE menu, it starts TSE's Help with the name
          "parent menu name->menu name". Usually that is not an existing name,
          so it needs to be redirected.
          Menu trick:
            When two menu options have the same name but need different Help,
            like the two Copy names in TSE's Clip menu, then one of the menu
            options is defined with an extra invisible OEM character.

    <REDIRECTS> and </REDIRECTS> tags enclose the file's combined redirects.

    <REDIRECT> and </REDIRECT> tags enclose each redirect.
      "Redirect" is my term for a heavily used TSE Help feature.
      It tells the Help, that if it is looking for <name>, then it should look
      for <address> instead. The name and address are separated by "^".
      Redirects overrule existing names.
      For example, this redirect tells the Help to look for "and" in the topic
      "Statements" at the subtopic "and":
        <REDIRECT>and^Statements;and</REDIRECT>

    <TOPICS> and </TOPICS> enclose the file's combined topic descriptions.
      It contains pairs of TOPIC and TEXT tags.
      The pairing is defined by their order. There is no common parent tag.

    <TOPIC> and </TOPIC> enclose a topic's name.

    <TEXT> and </TEXT> enclose a topic's description.
      Between TEXT tags empty lines do matter.
      The description may contain these tags:
        BOLD
        ITALIC
        SUBTOPIC
        LINK
      Rules for these four tags:
        Opening and closing tags must occur in the same line.
        BOLD and ITALIC tags may not enclose each other.
        SUBTOPIC and LINK tags may not enclose other tags.

    <BOLD> and </BOLD> enclose "bold" text.
      The tags must occur in the same line.
      TSE's current Help cannot display bold characters, and uses a
      configurable color instead.

    <ITALIC> and </ITALIC> enclose "italic" text.
      The tags must occur in the same line.
      TSE's current Help cannot display italic characters, and uses a
      configurable color instead.

    <SUBTOPIC> and </SUBTOPIC> enclose a subtopic name.
      The tags must occur in the same line.
      The name is both displayed and usable as a name in an address.

    <LINK> and </LINK> enclose an adrress to jump to, and more.
      The tags must occur in the same line.
      There are three types of links:
      - When the address starts with "Info->" followed by a string, the Help
        only displays the string, and on selecting it pops up a window with the
        description for "Info->string".
      - When the link just contains another address, the Help displays the
        address, and on selecting it jumps to the address.
      - When the link contains an adress and a string separated by "^", the
        Help only displays the string, and when selecting it jumps to the
        address.


  BACKGROUND FACTS

    Topic Completeness
      The generated "tsehelp.ehelp" file is complete except for TSE's Index.
      TSE's Help's Index was left out because it is in itself already
      incomplete, and will be more incomplete once we create
      tsehelp_<user>.ehelp files with our own topics.

    Link Correctness
      Links in the generated file are correct, with one exception inherited
      from the Help: There are lots of not-addressed subtopics, i.e. they are
      not linked to. Not-addressed subtopics serve no functional purpose and in
      theory hamper Semware and now us in maintaining TSE's Help.
      To check link-correctness I created a tool Test_TSE_Help_Links.s, that
      examines links in the hidden raw Help file that Hlp2txt intermediately
      creates, and it shows their errors, warnings and notes.
      Only notes for not-addressed subtopics came up; 337 times (TSE Pro 4.42).
      You can find this tool and its full report on my website.

    InfoBoxes
      A few links in TSE's built-in Help do not jump to a topic, but show a
      small pop-up window, which TSE calls an InfoBox.
      These links have their own color in the "Help Colors" configuration menu.
      For example, in the Help topic for AbandonEditor(), when you select
      "INTEGER", you get an InfoBox explaining what an integer is.
      The content of such InfoBoxes are stored in topics called "Info->...",
      where "..." is the InfoBox phrase you selected.
      The Help's Index does not show these topics, but here is a trick to list
      them: Go to the Help, select "Search", "Search and View Topics", and
      search for "e". The result is a list of topics that includes the
      "Info->..." topics that contain the letter "e", which is all of them.
      The generated file includes these "Info->..." topics as ordinary topics,
      only recognizable by that their name starts with "Info->".

    Bold and Italic Help text
      TSE's built-in Help colors also include colors for bold and italic text.
      I strongly suspect that this is because the same text was used for both
      the built-in Help and the old printed manuals.
      In the "Help Colors" configuration menu, "bold" is called "highlighted",
      but if you press <F1> on its menu option, then you see it refer to
      "HelpBoldAttr".
      When generating TSE's Help as HTML with the Hlp2txt tool, that generated
      manual will show the bold and italic text from the Help as actually bold
      and italic text.


  COMPATIBILITY

  1 This tool is compatible with v4 upwards of the Console and GUI versions
    of Windows TSE, and with v4.41.12 upwards of the Linux version of TSE.

  2 TSE's Help system stil uses an OEM character set.

    A benefit of the used OEM character set is, that it supports "drawing
    characters". TSE's Help mostly uses OEM's line drawing characters, and
    sometimes a "shade" character for drawing a menu choice. TSE's mouse bars
    are drawn with OEM's "shade" characters.

    The downsides of OEM character sets are, that there are many of them,
    and that none of their their upper 128 characters are ANSI compatible,
    which makes them incompatible with most other tools.

    To view a generated help file properly, you need to do so with an OEM
    compatibel font like Terminal.

    I am considering giving eHelp the capability, that, when it is used as an
    extension, it can temporarily switch the font to Terminal when a .ehelp
    file is viewed.

    With OEM, compatibility problems exist in TSE, but they are limited.
    - The most notable is the character with byte code 249.
      Given the context in which it is used, its intended use probably comes
      from codepage 437 where it is defined as a bullet character.
      On my computer (because it's OEM I have to mention that) in TSE's
      "Table of Contents" help in the "Using Help" topic:
      - In a default TSE installation the character does not show!
      - If I set "Use 3D characters" to ON in TSE's Full Configuration menu,
        and "Save Current Settings" and restart TSE, then it shows as two upper
        dots.
    - Incompatibility problems might exist for line drawing:
      - It might not be an OEM problem, but a TSE program error.
      - It varies with TSE version.



  HISTORY

  v0.1   13 Oct 2022
    First released version.

*/





// Compatibility restrictions and mitigations



/*
  When compiled with a TSE version below TSE 4.0 the compiler reports
  a syntax error and hilights the first applicable line below.
*/

#ifdef LINUX
  #define WIN32 FALSE
  string SLASH [1] = '/'
#else
  string SLASH [1] = '\'
#endif

#ifdef WIN32
#else
   16-bit versions of TSE are not supported. You need at least TSE 4.0.
#endif

#ifdef EDITOR_VERSION
#else
   Editor Version is older than TSE 3.0. You need at least TSE 4.0.
#endif

#if EDITOR_VERSION < 4000h
   Editor Version is older than TSE 4.0. You need at least TSE 4.0.
#endif



/*
  In modern Windows versions the screen freezes and the mouse pointer turns
  "busy" when program is "busy".
  Some other programs suffer from this new Windows feature too.
  Unfortunatly this prevents a longer running macro from reporting its progress.
  Calling KeyPressed() inside a macro loop avoids this.
  On the other hand, in Linux KeyPressed() takes "long" and slows a macro down
  significantly, so we only call KeyPressed() where it is needed.
*/
proc anti_freeze()
  #if WIN32
    KeyPressed()
  #endif
end anti_freeze



#if EDITOR_VERSION < 4200h
  /*
    MkDir() 1.0

    This procedure implements the MkDir() command of TSE 4.2 upwards.
  */
  integer proc MkDir(string dir)
    Dos('MkDir ' + QuotePath(dir), _START_HIDDEN_)
    return(not DosIOResult())
  end MkDir
#endif



#if EDITOR_VERSION < 4400h
  /*
    StrReplace() 1.0

    If you have TSE Pro 4.0 or 4.2, then this proc almost completely implements
    the built-in StrReplace() function of TSE Pro 4.4.
    The StrReplace() function replaces a string (pattern) inside a string.
    It works for strings like the Replace() function does for files, so read
    the Help for the Replace() function for the usage of the options, but apply
    these differences while reading:
    - Where Replace() refers to "file" and "line", StrReplace() refers to
      "string".
    - The options "g" ("global", meaning "from the start of the string")
      and "n" ("no questions", meaning "do not ask for confirmation on
      replacements") are implicitly always active, and can therefore be omitted.
    Notable differences between the procedure below with TSE 4.4's built-in
    function are, that here the fourth parameter "options" is mandatory
    and that the fifth parameter "start position" does not exist.
  */
  integer strreplace_id = 0
  string proc StrReplace(string needle, string haystack, string replacer, string options)
    integer i                      = 0
    integer org_id                 = GetBufferId()
    string  result  [MAXSTRINGLEN] = haystack
    string  validated_options [20] = 'gn'
    for i = 1 to Length(options)
      if (Lower(SubStr(options, i, 1)) in '0'..'9', 'b', 'i','w', 'x', '^', '$')
        validated_options = validated_options + SubStr(options, i, 1)
      endif
    endfor
    if strreplace_id == 0
      strreplace_id = CreateTempBuffer()
    else
      GotoBufferId(strreplace_id)
      EmptyBuffer()
    endif
    InsertText(haystack, _INSERT_)
    lReplace(needle, replacer, validated_options)
    result = GetText(1, CurrLineLen())
    GotoBufferId(org_id)
    return(result)
  end StrReplace
#endif



#if EDITOR_VERSION < 4400h
  /*
    VersionStr()  v1.1

    This procedure implements TSE Pro 4.4 and above's VersionStr() command
    for lower versions of TSE.
    It returns a string containing TSE's version number in the same format
    as you see in the Help -> About menu, starting with the " v".

    Examples of relevant About lines:
      The SemWare Editor Professional v4.00e
      The SemWare Editor Professional/32 v4.00    [the console version]
      The SemWare Editor Professional v4.20
      The SemWare Editor Professional v4.40a

    v1.1 fixes recognition of the TSE Pro v4.0 console version.
  */
  string versionstr_value [MAXSTRINGLEN] = ''

  proc versionstr_screen_scraper()
    string  attributes [MAXSTRINGLEN] = ''
    string  characters [MAXSTRINGLEN] = ''
    integer position                  = 0
    integer window_row                = 1
    while versionstr_value == ''
    and   window_row       <= Query(WindowRows)
      GetStrAttrXY(1, window_row, characters, attributes, MAXSTRINGLEN)
      position = Pos('The SemWare Editor Professional', characters)
      if position
        position = Pos(' v', characters)
        if position
          versionstr_value = SubStr(characters, position + 1, MAXSTRINGLEN)
          versionstr_value = GetToken(versionstr_value, ' ', 1)
        endif
      endif
      window_row = window_row + 1
    endwhile
  end versionstr_screen_scraper

  string proc VersionStr()
    versionstr_value = ''
    Hook(_BEFORE_GETKEY_, versionstr_screen_scraper)
    PushKey(<Enter>)
    PushKey(<Enter>)
    BufferVideo()
    lVersion()
    UnBufferVideo()
    UnHook(versionstr_screen_scraper)
    return(versionstr_value)
  end VersionStr
#endif



// End of compatibility restrictions and mitigations





// Global constants and semi-constants

#define DEBUG FALSE

#define CCF_OPTIONS _DONT_PROMPT_|_DONT_EXPAND_|_OVERWRITE_

// The first topic must occur in tsehelp.hlp; the second in compile.hlp.
string HLP_INIT_TOPICS [52] = 'EditFile;compile.hlp|Compile Menu->Compile from list'

string HELP_FILE_FQN  [MAXSTRINGLEN] = ''
string HELP_FILE_PATH [MAXSTRINGLEN] = ''
string MACRO_NAME     [MAXSTRINGLEN] = ''

#define SYSTEM_HELP_HEADERS_ID  7
#define SYSTEM_HELP_TOPIC_ID    8
#define SYSTEM_HELP_CONTROL_ID  9
#define SYSTEM_HELP_INDEX_ID   10

// string BOLD_START              [3] = '®B¯'
// string BOLD_STOP               [4] = '®/B¯'
// string ITALIC_START            [3] = '®I¯'
// string ITALIC_STOP             [4] = '®/I¯'
// string LINK_MIDDLE_DUAL_PART   [2] = '}¯'
// string LINK_MIDDLE_DUAL_PART_X [3] = '\}¯'   // For use in regular expressions.
// string LINK_START_INFOBOX      [4] = '®LI¯'
// string LINK_START_DUAL_PART    [4] = '®L {'
// string LINK_START_DUAL_PART_X  [5] = '®L \{' // For use in regular expressions.
// string LINK_START_WYSIWYG      [3] = '®L¯'
// string LINK_STOP               [4] = '®/L¯'
// string SUBTOPIC_START          [3] = '®S¯'
// string SUBTOPIC_STOP           [4] = '®/S¯'
// string TOPIC_START             [3] = '®T¯'
// string TOPIC_STOP              [4] = '®/T¯'





// Global variables





// Local procedures

public proc HelpHelp()
  // Do nothing!
  // If a HelpHelp macro exists, then this public proc is overrules it being
  // called for the duration of this macro running.
end HelpHelp


integer proc create_temp_buffer(string suffix)
  integer id = GetBufferId(MACRO_NAME + ':' + suffix)
  if id
    GotoBufferId(id)
    EmptyBuffer()
  else
    id = CreateTempBuffer()
    ChangeCurrFilename(MACRO_NAME + ':' + suffix, CCF_OPTIONS)
  endif
  return(id)
end create_temp_buffer


/*
  Pre-conditions:
    We are in a buffer, in which only topic descriptions are generated.
    The name of a new topic, the description of which needs to be added.
  Post_conditions:
    We are in the same buffer.
    We are on the line immediately below which the new topic description can be
    added.
*/
proc position_topic_alphabetically(string help_topic)
  integer predecessor_found = FALSE
  integer successor_found   = FALSE

  EndFile()
  while not predecessor_found
  and   lFind('^<TOPIC>.#</TOPIC>$', 'bx' )
    case CmpiStr('<TOPIC>' + help_topic + '</TOPIC>', GetText(1, MAXSTRINGLEN))
      when -1
        successor_found = TRUE
      when  1
        predecessor_found = TRUE
    endcase
  endwhile

  if predecessor_found
    // We are positioned on the predecessor topic.
    if successor_found
      // Go to one line above the successor topic.
      EndLine()
      lFind('^<TOPIC>.#</TOPIC>$', '^$')
      Up()
    else
      // Go to the buffer's last line.
      EndFile()
    endif
  else
    if successor_found
      // We are positioned on the successor topic.
      // Go to the line just before it.
      if not Up()
        // The sucessor topic is the first topic.
        // Create a line just before it.
        InsertLine()
      endif
    else
      // We are in the initial empty buffer.
    endif
  endif
end position_topic_alphabetically


proc WhenLoaded()
  MACRO_NAME     = SplitPath(CurrMacroFilename(), _NAME_)
  HELP_FILE_PATH = LoadDir() + 'help'
  HELP_FILE_FQN  = HELP_FILE_PATH + SLASH + 'tsehelp.ehelp'
end WhenLoaded


proc Main()
  integer copied_help_headers_id        = 0
  string  help_address   [MAXSTRINGLEN] = ''
  string  help_header    [MAXSTRINGLEN] = ''
  integer help_file_id                  = 0
  string  help_topic     [MAXSTRINGLEN] = ''
  string  hlp_init_topic [MAXSTRINGLEN] = ''
  integer hlp_file_nr                   = 0
  string  hlp_file_name  [MAXSTRINGLEN] = ''
  integer index_id                      = 0
  integer ok                            = TRUE
  integer old_break                     = Set(break                , ON)
  integer old_DateFormat                = Set(DateFormat           , 6)
  integer old_DateSeparator             = Set(DateSeparator        , Asc('-'))
  integer old_InsertLineBlocksAbove     = Set(InsertLineBlocksAbove, FALSE)
  integer old_Insert                    = Set(Insert               , ON)
  integer old_RemoveTrailingWhite       = Set(RemoveTrailingWhite  , ON)
  integer old_UnMarkAfterPaste          = Set(UnMarkAfterPaste     , ON)
  integer org_id                        = GetBufferId()
  integer redirects_id                  = 0
  integer temp_id                       = 0
  integer topic_id                      = 0

  copied_help_headers_id = create_temp_buffer('HelpHeaders')
  help_file_id           = create_temp_buffer('Help')
  index_id               = create_temp_buffer('Index')
  redirects_id           = create_temp_buffer('Redirects')
  temp_id                = create_temp_buffer('Temp')
  topic_id               = create_temp_buffer('Topic')
  GotoBufferId(org_id)
  if not copied_help_headers_id
  or not help_file_id
  or not index_id
  or not redirects_id
  or not temp_id
  or not topic_id
    ok = FALSE
    Warn(MACRO_NAME, ': error creating temporary files in memory.')
  endif

  if ok
    BufferVideo()

    for hlp_file_nr = 1 to 2
      hlp_file_name  = iif(hlp_file_nr == 1, 'tsehelp.hlp', 'compile.hlp')
      hlp_init_topic = GetToken(HLP_INIT_TOPICS, ';', hlp_file_nr)

      // This action has the desired side-effect, that it initializes TSE's
      // Help's headers-buffer so that it contains all the headers for the
      // specific .hlp file that the topic is documented in.
      PushKey(<Escape>)
      Help(hlp_init_topic)

      GotoBufferId(SYSTEM_HELP_HEADERS_ID)
      MarkLine(1, NumLines())
      Copy()

      GotoBufferId(copied_help_headers_id)
      EmptyBuffer()
      Paste()
      BegFile()

      repeat
        help_header = Trim(GetText(8, MAXSTRINGLEN))

        anti_freeze()
        Message('Initializing tsehelp.ehelp:'; (CurrLine() * 100) / NumLines(),
                 '%'; 'help extracted from'; hlp_file_name; '...')
        anti_freeze()

        PushKey(<Escape>)
        PushKey(<Grey+>)
        if hlp_file_nr == 1
          Help(help_header)
        else
          Help(hlp_file_name + '|' + help_header)
        endif

        GotoBufferId(SYSTEM_HELP_CONTROL_ID)
        EndFile()
        if lFind('\.hlp\|\c', 'cgx')
          help_address = Trim(GetText(CurrPos(), MAXSTRINGLEN))
        else
          help_address = ''
        endif

        GotoBufferId(topic_id)
        EmptyBuffer()
        Paste()
        BegFile()
        help_topic = Trim(GetText(1, MAXSTRINGLEN))

        GotoBufferId(SYSTEM_HELP_TOPIC_ID)
        MarkLine(1, NumLines())
        Copy()

        if help_topic == ''
          // One topic right at the start is unretrievable.
        else
          if help_header <> help_address
            GotoBufferId(redirects_id)
            AddLine(Format('<REDIRECT>', help_header, '^', help_address,
                           '</REDIRECT>'))
          endif

          GotoBufferId(help_file_id)
          if lFind(Format('<TOPIC>', help_topic, '</TOPIC>'), '^g$')
            // Headers are for topics and subtopics. Because we are processing
            // headers, topics to insert can be found multiple times, and we
            // only need need to do it once for each topic.
          else
            position_topic_alphabetically(help_topic)
            AddLine(Format('<TOPIC>', help_topic, '</TOPIC>'))
            AddLine('<TEXT>')
            AddLine('</TEXT>')
            AddLine()
            AddLine()
            AddLine()
            Up(4)
            Paste()
          endif
        endif

        GotoBufferId(copied_help_headers_id)
      until not ok
        or not Down()
    endfor

    UnBufferVideo()
  endif

  if ok
    GotoBufferId(help_file_id)
    // The "[~®]" ensures that multiple syntax phrases on the same line are not
    // matched as one.
    // The order of replacements matters a lot.
    // Links and subtopics can occur within bold/italic tags; not the other way
    // around.
    // Bold italic text is not supported in the real world, nor in TSE's Help.
    // Semware sometimes uses empty bold tags in tables. I can see why, but do
    // not want to support this Semware-specific editing crutch going forward,
    // so I delete them.
    lReplace('®LI¯{[~®]#}®/L¯'           , '<INFO>\1</INFO>'        , 'gnx')
    lReplace('®L \{{[~®]#}\}¯{[~®]#}®/L¯', '<LINK>\1^\2</LINK>'     , 'gnx')
    lReplace('®L¯{[~®]#}®/L¯'            , '<LINK>\1</LINK>'        , 'gnx')
    lReplace('®S¯{[~®]#}®/S¯'            , '<SUBTOPIC>\1</SUBTOPIC>', 'gnx')
    lReplace('®B¯{[~®]#}®/B¯'            , '<BOLD>\1</BOLD>'        , 'gnx')
    lReplace('®I¯{[~®]#}®/I¯'            , '<ITALIC>\1</ITALIC>'    , 'gnx')
    lReplace('®B¯®/B¯'                   , ''                       , 'gnx')
    lReplace('®L¯®/L¯'                   , ''                       , 'gnx')

    BegFile()
    InsertLine()
    InsertLine()
    InsertLine('<TOPICS>')
    InsertLine()
    InsertLine()
    InsertLine()
    InsertLine()
    InsertLine()
    EndFile()
    AddLine('</TOPICS>')

    GotoBufferId(redirects_id)
    MarkLine(1, NumLines())
    ExecMacro('sort -i')
    Copy()

    GotoBufferId(help_file_id)
    BegFile()
    InsertLine('<REDIRECTS>')
    AddLine('</REDIRECTS>')
    Up()
    Paste()

    BegFile()
    InsertLine('<EHELP>')
    AddLine()
    AddLine('<META>')
    AddLine('  <FORMAT>1</FORMAT>')
    AddLine('  <DOC>')
    AddLine('    Do not modify this tsehelp.ehelp file!' )
    AddLine('    It is not used for showing help.' )
    AddLine('    It will be reinitilized if it was modified.' )
    AddLine('  </DOC>')
    AddLine('</META>')
    AddLine()
    AddLine()
    EndFile()
    AddLine('</EHELP>')
  endif

  if ok
    if not (FileExists(HELP_FILE_PATH) & _DIRECTORY_)
      MkDir(HELP_FILE_PATH)
    endif

    if not SaveAs(HELP_FILE_FQN, _DONT_PROMPT_|_OVERWRITE_)
      Warn(MACRO_NAME, ': error writing'; LoadDir(), 'help\tsehelp.ehelp')
      ok = FALSE
    endif
  endif

  if ok
    GotoBufferId(org_id)
    Message("")
  else
    Warn(MACRO_NAME; 'was aborted.')
  endif

  Set(break                , old_break)
  Set(DateFormat           , old_DateFormat)
  Set(DateSeparator        , old_DateSeparator)
  Set(InsertLineBlocksAbove, old_InsertLineBlocksAbove)
  Set(Insert               , old_Insert)
  Set(RemoveTrailingWhite  , old_RemoveTrailingWhite)
  Set(UnMarkAfterPaste     , old_UnMarkAfterPaste)
  UpdateDisplay(_ALL_WINDOWS_REFRESH_)
  PurgeMacro(MACRO_NAME)
end Main

// Just in case the user has redefined the standard <Grey+> key,
// the macro redefines it the standard way for the duration of its execution.
<Grey+> Copy()

