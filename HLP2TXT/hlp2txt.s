/*
  Macro           Hlp2txt
  Author          Carlo Hogeveen
  Website         eCarlo.nl/tse
  Version         3.0.3   17 Sep 2022
  Compatibility   Windows TSE v4       upwards,
                  Linux   TSE v4.41.12 upwards

  SUMMARY
    This tool generates a TSE manual from TSE's built-in Help system.
    It can generate HTML or plain text using UTF-8, ASCII or OEM character
    encoding.


  INSTALLATION
    Just copy this file to TSE's "mac" directory, and compile it there,
    for instance by opening it in TSE and using the Macro Compile menu.


  USE
    Just execute the macro, for instance with the Macro Execute menu
    in which you type its name "Hlp2txt".

    You can also add "Hlp2txt" to TSE's Potpourri menu and execute it from
    there.

    When you execute it, it gives elaborate explanations.
    When in doubt just select the default.


  BACKGROUND FACTS

    Topic Completeness
      The manual is "limited" to topics in the Help's index plus their
      referred-to topics.
      In practice this gives a full, self-contained manual.
      I created a tool Test_TSE_Help_Headers.s that showed there are three
      types of topics that are not themselves an indexed topic:
      - Typically menu help topics that are just links to topics that are in
        the index. There were more than I expected of these.
        For example, Help('BlockMenu->Capitalize'), which is not in the index,
        just jumps to Help('Marking and Manipulating a Block of Text'), which
        is in the index.
      - Typically menu help topics that do contain new text, but (I checked and
        judged) only state the obvious. There aren't many of these.
        For example, Help('Edit Key Macro') states:
          * ("Edit Key Macro" under Macro Menu)
            Allows you to edit any keyboard macros that are currently loaded.
      - Topics that state their subject is obsolete.
        For example, Help('AltBlockAttr') states "This variable is obsolete.".
      You can find this tool and its report on my website.

    Link Correctness
      Links in the generated manual are correct, with one exception inherited
      from the Help: There are lots of not-addressed subtopics, i.e. they are
      not linked to. Not-addressed subtopics serve no functional purpose and in
      theory hamper Semware in maintaining TSE's Help.
      To check link-correctness I created a tool Test_TSE_Help_Links.s, that
      examines links in the hidden raw Help file that Hlp2txt intermediately
      creates, and it shows their errors, warnings and notes.
      Only notes for not-addressed subtopics came up; 337 times (TSE Pro 4.42).
      You can find this tool and its full report on my website.

    InfoBoxes
      A few links in TSE's built-in Help do not jump to a topic, but show a
      small pop-up panel, which TSE calls an InfoBox.
      These links have their own color in the "Help Colors" configuration menu.
      For example, in the Help topic for AbandonEditor(), when you select
      "INTEGER", you get an InfoBox explaining what an integer is.
      The content of such InfoBoxes are stored in topics called "Info->...",
      where "..." is the InfoBox phrase you selected.
      The Help's Index does not show these topics, but here is a trick to list
      them: Go to the Help, select "Search", "Search and View Topics", and
      search for "e". The result is a list of topics that includes the
      "Info->..." topics that contain the letter "e", which is all of them.
      The generated manual includes these "Info->..." topics as ordinary
      topics, both in its index and its contents.
      Because it is a manual InfoBoxes are not shown as pop-ups.

    Bold and Italic Help text
      TSE's built-in Help colors also include colors for bold and italic text.
      I strongly suspect that this is because the same text was used for both
      the built-in Help and the old printed manuals.
      In the "Help Colors" configuration menu, "bold" is called "highlighted",
      but if you press <F1> on its menu option, then you see it refer to
      "HelpBoldAttr".
      When generating HTML, the generated manual will show the bold- and
      italic-colored text from the Help as actually bold and italic text
      instead.


  COMPATIBILITY

  1 This version of the tool has been modernized, and as of Hlp2txt v2.5 it is
    no longer compatible with TSE versions older than v4.0.

    The previous version, Hlp2txt v2.4.4, was compatible with TSE v2.6 upwards,
    provided the <Grey +> key still had its default Copy() definition.
    Hlp2txt v2.4.4 can still be found on Semware's website.

    No versions of this tool were ever compatible with the old 16-bits TSE Pro
    v2.5, because for that TSE version it cannot work because it ignores
    PushKey() commands inside the Help system.

  2 TSE's Help system stil uses an OEM character set.

    The benefit of an OEM character set can be, that in TSE it supports line
    drawing. TSE's Help uses line drawing.

    The downsides of OEM character sets are, that there are many of them,
    and that none of their their upper 128 characters are ANSI compatible,
    which makes them incompatible with most other tools.

    So if you want to generate a plain text manual, then for compatibility's
    sake my advice is to generate ASCII, in which line drawing is a tiny bit
    less pretty, but which is extremely compatible with other software.

    That said, you do have the option to let Hlp2txt generate a Plain Text help
    file with the OEM character set, and then view it in TSE with an OEM font
    like Terminal.

    So with OEM compatibility problems exist in TSE, but they are limited.
    - The most notable is the character with OEM byte code 249.
      Given the context in which it is used, its intended use probably comes
      from codepage 437 where it is defined as a bullet character.
      On my computer (because it's OEM I have to mention that) in TSE's
      "Table of Contents" help in the "Using Help" topic:
      - In a default TSE installation the character does not show!
      - If I set "Use 3D characters" to ON in TSE's Full Configuration menu,
        and "Save Current Settings" and restart TSE, then it shows as two upper
        dots.
    - A rare incompatibility problem exists for line drawing.
      For instance see TSE's Help topic "Drawing Lines in the Text".
      This Help topic will be shown with some errors in an OEM font if the
      configuration setting "Use 3D characters" is OFF.



  TODO
    MUST
    SHOULD
    COULD
    - Provide a better search function than the browser provides.
      Pro: It would be a nice exercise.
      Con: This document is likely to be replaced by a tool.
    WONT
    - Replace StrReplace() with FastStrReplace() where beneficial.
      This has no priority, because, as used in this macro, StrReplace()'s
      performance lag is a tiny fraction of the macro's overall performance.



  HISTORY

    1.0   Initial version. Plain text only.

    2.0   Adds the ability to also create an HTML file.
          Alas, some HTML links are still buggy.
          Txt and HTML: subtopics (which are described in main topics)
          cause multiple inserts of the main topics into the generated
          file: because this occurs frequently in TSE's Help system, the
          generated file is probably several times it's necessary size.

    2.0.1 Added a copyright notice on Sammy's request.
          Removed the screen flickering, thanks to Sammy.
          Made Hlp2txt recognize and handle subtopics,
          making the generated file about 5 times smaller.
          Removed updating the display while running, which makes each
          macro part a lot faster, but the new version has more parts,
          so the end result isn't faster after all.

          Intermediately released. No known bugs any more, but not pretty
          enough yet: There is no textual link in the index from subtopics
          to main topics. That is especially clumsy for the .txt version.
          Also, there are overlapping links.

    2.1   Solved overlapping hyperlinks in the HTML format.
          Added a main topic reference to subtopics in the index,
          this was a must for the text version.
          Added a copyright notice and intro-text to the text version too.
          Added rough TSE version recognition.

    2.2   Added a small header at subtopics and a procedure description
          above to add a Word user in converting the HTML file to a pretty
          printable format.

    2.2.1 Removed NUL characters for Netscape users.
          Thanks to John Kopp.

    2.2.2 Solved a bug for when TSE resides in a directory with a space in
          it's name.

    2.2.3 Solved a bug indexing and generating topics with long similar
          topic names, like the ones starting with "Summary of New/Enhanced
          features of The Semware Editor Professional ...". Only the first
          of such topics was generated. The solution came from John Kopp.
          I also used some of his suggestions for improving the code.

          for HTML files the number of generated hyperlinks from the text
          to the (sub)topics is reduced and smarter. Formerly hyperlinks
          were always generated, also when TSE words that are also English
          words were used in a normal English sentence. Now the macro does
          this smarter following some simple rules. For instance, you won't
          see every occurrence of "to", "in", "and" and many others
          hyperlinked in plain English sentences any more. Since a macro
          can't equal human intelligence in understanding text, there still
          are and always will be some superfluous hyperlinks. They are few,
          harmless, and at worst "not pretty".

    2.4   Added informational screens to increase user-friendliness.

          Added two new textformats to generate: Word and Generic.

          Added optionally calling Word or the browser afterwards.

    2.4.1 When saving a generated and user-modified Word file, Word still
          knows that it's originally an HTML file, despite the .doc
          extension. Changed the user instructions to compensate for this.

          Bug found which will not be solved. In TSE 3.0 and possibly other
          older versions of TSE the macro will not show its version
          information if it was started from the commandline with
          "e32 -eHlp2txt". This seems to be a problem in TSE's lVersion()
          command which is solved in later versions of TSE.

    2.4.2 Because ASCII files are probably viewed in an ANSI font,
          characters with a code below 32 or above 127 should be
          converted for the ASCII format too.

    2.4.3 Hlp2txt used to abort when the HelpHelp macro is present in TSE's
          "mac" directory, resulting in a Help file with just heading
          information. The HelpHelp macro mainly gets distributed with
          Chris Antos' GetHelp macro, and is often not deleted if a user
          uninstalls GetHelp.
          Hlp2txt now temporarily uninstalls HelpHelp, and aborts no more.

    2.4.4   31 Jul 2005
      For TSE 4.4 upwards Hlp2Txt can automatically determine TSE's
      correct version string, using the new VersionStr() function.

    v2.5   11 Sep 2019
      Fixed: If the user had their own <Grey +> key definition instead
      of SemWare's default one, then a mostly empty document was generated.
      Reindented the source code from tabsize 3 to 2.
      Reduced backwards compatibility to TSE Pro v4.0.
      Added automatically determining TSE Pro's version for v4.0 and v4.2 too.
      Added a selection screen to select the character code format to generate.
      Added capability to generate the file in the UTF-8 character code format.
      Fixed: Determining the TSE version did not work for the console version
      of TSE Pro v4.0.
      Removed the underlining from HTML links.
      Added compatibility with the beta version of Linux TSE.

    v2.5.1   25 Jan 2021
      A few tiny updates, mostly textual.

    v2.5.2   1 Feb 2021
      Changed HTML "name" attributes to "id" attributes.

      Changed id values to be URL-encoded values to be web-compatible.

      Made topic name headers in the text retain their parentheses.
      E.g. the description of AbandonFile() now starts with the
      header AbandonFile() instead of AbandonFile.

      Fixed menu drawing imperfections involving vertical lines and triangles.

      Documented better that this is not an official manual and that it has
      some minor imperfections.

      Some minor tweaks.

    v3.0.0.12   7 Mar 2022
      Finally found a way to access TSE's Help's underlying help formatting
      (which has been there since forever, so -1), and rewrote this tool
      to use that.
      This gained the following benefits for the generated manual:
      - The HTML manual now provides the same links as TSE's Help does,
        so there are no more superfluous and missing links.
      - The HTML manual now has bold and italic text where the Help uses colors
        for these.
      - The manual now includes the Help's InfoBoxes. Because it is a manual
        they are not shown as pop-ups but are included as "Info->..." topics,
        just like TSE's Help internally does.
      - The manual now also includes those not-indexed topics that are
        indirectly linked to from indexed topics.

      Additionally the HTML manual's Indexed is now prefaced with a
      letter-index for faster selection of a known topic.

      Because there is no indication of anyone using them, the options to
      generate the manual in a Word-supportive HTML format or in a
      linkless Generic HTML format is no longer available.
      You can still open the fully HTML formatted file in Word.

      Fixed: Hlp2txt no longer needs to temporarily rename a HelpHelp macro.

      Reduced: In Linux there now is a tiny period in which it is no longer
      possible to interrupt the running macro with <Escape>, because that
      requires TSE's KeyPressed() function, which is incredibly slow in Linux,
      and therefore in Linux is skipped during that tiny period.

    v3.0.1     7 Mar 2022
      Fixed: The generated HTML did not pass W3C's HTML validator
             https://validator.w3.org/

    v3.0.2     7 Mar 2022
      Fixed: Some links did not work any more because of a programming error
             that was introduced in Hlp2txt's beta v3.0.0.4.

    v3.0.2.1  11 Mar 2022
      Documentation tweaks.

    v3.0.3    17 Sep 2022
      Fixed incompatibility with TSE's '-i' command line option
      and the TSELOADDIR environment variable.

*/





/*

  T E C H N I C A L   I N F O

  TseHelp.raw
    Generating any format will also create a hidden buffer "Hlp2txt:RawHelp".
    The generated indeces differ minutely depending on whether HTML or plain
    text was generated.
    You can get at it with the "Hidden" tool from my website,
    or by setting DEBUG to TRUE in this macro source before compiling it
    which makes it available as the unsaved normal buffer "Help\TseHelp.raw".
    This raw-Help buffer is a reverse engineered, almost full version of the
    unprocessed Help content.
    - Why it is not completely full is described elsewhere.
    - Unprocessed means that its text is in OEM character encoding, and that
      the text contains the low-level Help formatting, that TSE uses to display
      and navigate the Help. Most of the formatting consists of text enclosed
      in opening and closing tags.

    Here is the low-level Help formatting that I currently know off.

      TAG   MEANING

      ®L¯   Opening tag for a WYSIWYG link. This tag left-encloses a phrase,
            that is both the link's display value and the address it points to.
            A WYSIWYG link can refer to a topic or subtopic.
      ®LI¯  Opening tag for an InfoBox link. This tag left-encloses a phrase,
            that is the link's display value and that has "Info->phrase" as the
            address it points to.
      ®L {  Opening tag for a dual-part link. This tag left-encloses the
            link's (optionally dual-part) address and display value.
      ;     Splits a dual-part address in a topic and a subtopic (address).
            Dual-part addresses only and optionally occur in dual-part links.
      }¯    Middle tag for a dual-part link.
            The left link part is a single-part or dual-part address.
            The right link part is the text that the link displayes.
      ®/L¯  Closing tag for all link types.
      ®T¯   Opening tag for a topic phrase. The phrase is both its displayed
            text and an address where links can refer to.
      ®/T¯  Closing tag for a topic phrase.
      ®S¯   Opening tag for a subtopic phrase. The phrase is both its displayed
            text and an address where links can refer to.
      ®/S¯  Closing tag for a subtopic phrase.
      ®B¯   Opening tag for "bold" text.
            In TSE's built-in Help "bold" is shown as a color.
            "Bold" is called "Highlighted" in TSE's "Help Colors" configuration
            menu. Pressing <F1> there shows "HelpBoldAttr".
      ®/B¯  Closing tag for "bold" text.
      ®I¯   Opening tag for "italic" text.
            In TSE's built-in Help "italic" is shown as a configured color.
      ®/I¯  Closing tag for "italic" text.

      Side note:
        ANSI shows the characters "®" and "¯" (as Unicode calls them) as
        "registered trade mark sign" and "spacing macron" (which looks like an
        "upperscore" to me).
        TSE's default OEM character set shows these two characters as
        "left-pointing double angle quotation mark" (two less-than signs) and
        "right-pointing double angle quotation mark" (two greater-than signs),
        which semantically makes more sense.
      Warning:
        Do not use Windows' copy/paste to copy this macro's source text between
        a GUI version of TSE and a Console version of TSE.
        Windows copy/paste tries to help by converting the above two characters
        to keep their letters the same, but TSE's Help requires that their
        character codes remain the same.

      Tag combinations
        Here are some combinations the Help actually uses:
          ®B¯®T¯ ... ®/T¯®/B¯
          ®B¯®S¯ ... ®/S¯®/B¯
          ®I¯®S¯ ... ®/S¯®/I¯
        No occurrences were found of this type of combination in the Help,
        but the generated manual uses them:
          ®B¯®T¯ ... ®/T¯ ... ®/B¯

      Dual-part links
        They adhere to one of these two formats:
          ®L {TopicOrSubtopic}¯DisplayValue®/L¯
          ®L {Topic;Subtopic}¯DisplayValue®/L¯
        Note that "®L {", "}¯" and "®/L¯" are delimiters that respectively
        enclose an address and a display value, and that ";" is the delimiter
        when an address is a dual-part address.
        A dual-part address addresses a specific topic's subtopic.
        Its use is necessary when addressing a subtopic that shares its address
        with a topic or other subtopic.
        Side note: "®L " never occurs without being followed by "{",
        and other link types do not use "{}" or dual-part addresses.

    Useless but cool display trick
      There is a useless but cool trick you can do with the raw Help buffer.
      If the raw Help buffer is the current buffer and you execute this TSE
      command
        DisplayMode(_DISPLAY_HELP_)
      then TSE will display the buffer like TSE's Help.
      This mode only changes the way the buffer is displayed.
      It does not implement links, it only colors them.
      You can give all editing commands, but odd things might happen if you
      edit a colored phrase or after it, because you are also editing help tags
      you cannot see.
      You can revert to TSE's normal view with the TSE command
        DisplayMode(_DISPLAY_TEXT_)
      One method to ad hoc execute TSE commands is to use the Execute macro
      from Semware's website.

*/





// Compatibility restriction and mitigations



/*
  When compiled with a TSE version below TSE 4.0 the compiler reports
  a syntax error and hilights the first applicable line below.
*/

#ifdef LINUX
  #define WIN32 FALSE
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
    therefore here versioning of compare_versions() starts at v2.0.
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



// End of compatibility restriction and mitigations





// Global constants

#define DEBUG FALSE

#define CCF_OPTIONS _DONT_PROMPT_|_DONT_EXPAND_|_OVERWRITE_

#ifdef LINUX
  integer CATCH_SKIPS = 100
  string  SLASH [1] = '/'
#else
  integer CATCH_SKIPS = 1
  string  SLASH [1] = '\'
#endif

string MY_MACRO_VERSION                       [5] = '3.0.3'
string UNICODE_MACRO_NAME                     [7] = 'Unicode' // Case-sensitive!
string UNICODE_UTF8_PLUS_BOM                  [9] = 'UTF-8+BOM'
string UNICODE_VARNAME_CHARACTER_CODE_FORMAT [19] = 'CharacterCodeFormat'

Datadef info1
  ""
  ""
  "Hlp2txt   -   convert Help system to text file"
  ""
  ""
  ""
  "This macro converts TSE's internal Help system into a text file"
  ""
  "based on TSE's Help Index."
  ""
  ""
  ""
  "The text file can be generated in several text formats."
  ""
  "The text file is created in TSE's 'Help' folder."
  ""
  ""
  ""
#ifdef LINUX
  "Press <Escape> at almost any time to abort Hlp2txt."
#else
  "Press <Escape> at any time to abort Hlp2txt."
#endif
end info1

Datadef info2
  "The next screen is the text format menu."
  ""
  "There you will have to choose the text format to be generated:"
  ""
  "PLAIN format is plain text, without any formatting or special codes."
  "It can be viewed with TSE."
  ""
  "HTML format is great for viewing the resulting document in a web browser."
  "Text is linked the same as in TSE's built-in Help."
end info2

Datadef info3
  "The next screen selects the character encoding."
  ""
  "You can just press ENTER to accept the suggested default."
  ""
  "Note that nowadays the GUI version of TSE defaults to ANSI for editing,"
  "but its Help system still uses an OEM character set."
  ""
  "Suggestions:"
  "Select UTF-8 if you selected the HTML format to be viewed in a web browser."
  "ASCII works almost as well there."
  "Select ASCII if you selected a PLAIN text format."
  "Only select OEM if you selected a PLAIN text format"
  "and either use the old Console version of TSE"
  "or if you changed your font to an OEM font like Terminal."
  ""
  "The Help system's OEM character encoding is converted to what you select."
  "Inconvertable characters are converted to an alternative character."
  ""
  "The next menu suggests a character encoding and lets you override it ..."
end info3

Datadef info4
  "The manual contains the topics from TSE's Help Index and those they refer to."
  "Indexed topics are therefore listed and described alphabetically,"
  "with added at the bottom a few topics that are indirectly referred to."
  "Menu-specific Help topics that are not also indexed topics are not included."
  "The manual probably contains all topics that formerly occurred"
  "in book form in The User's Guide and The Macro Reference Guide."
  "The generated manual's topic's contents are exactly the same as those "
  "of TSE's Help, which has not been significantly updated since TSE 4.4 (2005)."
end info4

#define SYSTEM_HELP_HEADERS_ID  7
#define SYSTEM_HELP_TOPIC_ID    8
#define SYSTEM_HELP_CONTROL_ID  9
#define SYSTEM_HELP_INDEX_ID   10

string FIELD_SEPARATOR         [1] = Chr(31)
string NULL                    [1] = Chr(0)

string BOLD_START              [3] = '®B¯'
string BOLD_STOP               [4] = '®/B¯'
string ITALIC_START            [3] = '®I¯'
string ITALIC_STOP             [4] = '®/I¯'
string LINK_MIDDLE_DUAL_PART   [2] = '}¯'
string LINK_MIDDLE_DUAL_PART_X [3] = '\}¯'   // For use in regular expressions.
string LINK_START_INFOBOX      [4] = '®LI¯'
string LINK_START_DUAL_PART    [4] = '®L {'
string LINK_START_DUAL_PART_X  [5] = '®L \{' // For use in regular expressions.
string LINK_START_WYSIWYG      [3] = '®L¯'
string LINK_STOP               [4] = '®/L¯'
string SUBTOPIC_START          [3] = '®S¯'
string SUBTOPIC_STOP           [4] = '®/S¯'
string TOPIC_START             [3] = '®T¯'
string TOPIC_STOP              [4] = '®/T¯'





// Global variables

string  my_macro_name  [MAXSTRINGLEN] = ''
string  charset                   [6] = ''
integer is_unicode_macro_loaded       = FALSE
string  textformat                [8] = ''



// Local procedures

integer proc info_screen(integer temp_id, integer info_number)
  integer result = TRUE
  Delay(9)
  PushPosition()
  PushBlock()
  GotoBufferId(temp_id)
  EmptyBuffer()
  case info_number
    when 1
      InsertData(info1)
    when 2
      InsertData(info2)
    when 3
      InsertData(info3)
    otherwise
      AddLine("Hlp2txt program error: illegal info_number")
  endcase
  lReplace("^","   ","gnx")
  EndFile()
  AddLine()
  AddLine()
  BegFile()
  InsertLine()
  InsertLine()
  result = List(
    "Hlp2txt Info Screen          Press ENTER to continu or Escape to abort",
    80)
  PopPosition()
  PopBlock()
  Delay(9)
  return(result)
end info_screen

public proc HelpHelp()
  // Do nothing!
  // If a HelpHelp macro exists, then this public proc is overrules it being
  // called for the duration of the Hlp2txt macro running.
end HelpHelp

/*
  Return TSE's original LoadDir() if LoadDir() has been redirected
  by TSE's "-i" commandline option or a TSELOADDIR environment variable.
*/
string proc original_LoadDir()
  return(SplitPath(LoadDir(TRUE), _DRIVE_|_PATH_))
end original_LoadDir

/*
  Centers the passed text for a line width of 80.
*/
string proc center(string s)
  return(Format('': (80 - Length(s))/2: ' ', s))
end center

integer proc create_temp_buffer(string suffix)
  integer id = GetBufferId(my_macro_name + ':' + suffix)
  if id
    GotoBufferId(id)
    EmptyBuffer()
  else
    id = CreateTempBuffer()
    ChangeCurrFilename(my_macro_name + ':' + suffix, CCF_OPTIONS)
  endif
  return(id)
end create_temp_buffer

integer proc is_OEM_font()
  string  font_name  [1] = ''
  integer font_pointsize = 0
  integer font_flags     = 0
  GetFont(font_name, font_pointsize, font_flags)
  return(font_flags & _FONT_OEM_)
end is_OEM_font

string proc de_regexp(string regexp)
  string result [255] = regexp
  integer i
  for i = 1 to Length(result)
    if Pos(result [i], ".^$|?[]-~*+@#{}\")
      result = Format(SubStr(result, 1, i - 1),
                      "\",
                      SubStr(result, i, 255))
      i = i + 1
    endif
  endfor
  return(result)
end de_regexp

string proc current_month_name()
  string month_names [85] =
    "January February March April May June July August September October November December"
  return(GetToken(month_names, " ", Val(GetToken(GetDateStr(), "-", 2))))
end current_month_name

proc choose_textformat(string chosen_textformat)
  textformat = chosen_textformat
end choose_textformat

menu textformat_menu()
  title = "Choose the textformat to generate"
  "&Plain     for viewing in TSE"                    ,choose_textformat("Plain"  ),,"Generate plain unformatted text for viewing in TSE"
  "&HTML      for viewing in web browser"            ,choose_textformat("HTML"   ),,"Generate thoroughly hyperlinked HTML to view in browser"
end textformat_menu

proc choose_charset(string chosen_charset)
  charset = chosen_charset
end choose_charset

menu charset_menu()
  title = "Convert the Help system's OEM character set to"
  "&UTF-8     Best for viewing HTML in web browser and documents in Word",choose_charset("UTF-8"),,"Best for viewing in modern systems like a web browser and Word"
  "&ASCII     Best for viewing Plain text in TSE (default)"              ,choose_charset("ASCII"),,"Best for viewing in TSE. To edit UTF-8 chars you need the Unicode macro."
  "&OEM       Best for viewing Plain text in a TSE that still uses OEM"  ,choose_charset("OEM"  ),,"Best for viewing in TSE if it's still configured to use an OEM font for editing."
end charset_menu

proc catch_user_escape(var integer ok)
  // This function allows the user to interrupt the tool by pressing <escape>.

  // In Linux we sometimes skip calling this proc, because a KeyPressed() takes
  // about 0.05 seconds there, which for a loop of 1276 indexed topics wastes
  // about 64 seconds, and catch_user_escape() is callable multiple times.
  // Also, the loops that need catch_user_escape() the most, are so much faster
  // in Linux than in Windows, that a user would have a hard time pressing
  // <Escape> in those loops anyway, so it is ok to skip it there.
  while KeyPressed()
    if GetKey() == <Escape>
      ok = FALSE
      // Skip excessive key presses, e.g. a user keeping <Escape> pressed.
      while KeyPressed()
        Message('User escaped!')
      endwhile
      Warn('User escaped!')
    endif
  endwhile
end catch_user_escape

/*
  The character conversion is limited to characters actually occurring in
  the Help text. The reason is that (in my opion) TSE itself already has
  problems with using an outdated OEM character set for its Help system.
  By looking at how an OEM character is actually used in the text, it can
  be determined what its function is. This way I could sometimes choose a
  more appropriate Unicode character for generating the Help file, than the
  OEM character that TSE itself is currently limited to using in its Help
  system.
  The most obvious example is the often occurring OEM character 249, that
  the Help system shows as some kind of quote, but an HTML filecan show as a
  bullet.
*/
string proc to_utf8(integer oem_char_code)
  string  result     [12] = ''
  string  utf8_char  [12] = ''
  integer i               = 0
  case oem_char_code
    when 007  utf8_char = 'E280A2 2022' // Bullet
    when 016  utf8_char = 'E296BA 25BA' // Black right-pointing pointer (Here this middle-sized triangle because it does not deform the menus)
    when 017  utf8_char = 'E29784 25C4' // Black left-pointing pointer  (Here this middle-sized triangle because it does not deform the menus)
    when 018  utf8_char = 'E28695 2195' // Up down arrow
    when 024  utf8_char = 'E28691 2191' // Upwards arrow
    when 025  utf8_char = 'E28693 2193' // Downwards arrow
    when 029  utf8_char = 'E28694 2194' // Left right arrow
    when 030  utf8_char = 'E296B2 25B2' // Black up-pointing triangle   (Here we can use the largest triangle)
    when 031  utf8_char = 'E296BC 25BC' // Black down-pointing triangle (Here we can use the largest triangle)
    when 174  utf8_char = 'C2AB   00AB' // Left-pointing double angle quotation mark
    when 177  utf8_char = 'E29692 2592' // Medium shade
    when 179  utf8_char = 'E29482 2502' // Box drawings light vertical
    when 180  utf8_char = 'E294A4 2524' // Box drawings light vertical and left
    when 183  utf8_char = 'E29596 2556' // Box drawings down double and left single
    when 184  utf8_char = 'E29595 2555' // Box drawings down single and left double
    when 187  utf8_char = 'E29597 2557' // Box drawings double down and left
    when 190  utf8_char = 'E2959B 255B' // Box drawings up single and left double
    when 191  utf8_char = 'E29490 2510' // Box drawings light down and left
    when 192  utf8_char = 'E29494 2514' // Box drawings light up and right
    when 193  utf8_char = 'E294B4 2534' // Box drawings light up and horizontal
    when 194  utf8_char = 'E294AC 252C' // Box drawings light down and horizontal
    when 195  utf8_char = 'E2949C 251C' // Box drawings light vertical and right
    when 196  utf8_char = 'E29480 2500' // Box drawings light horizontal
    when 197  utf8_char = 'E294BC 253C' // Box drawings light vertical and horizontal
    when 201  utf8_char = 'E29594 2554' // Box drawings double down and right
    when 205  utf8_char = 'E29590 2550' // Box drawings double horizontal
    when 212  utf8_char = 'E29598 2558' // Box drawings up single and right double
    when 213  utf8_char = 'E29592 2552' // Box drawings down single and right double
    when 214  utf8_char = 'E29593 2553' // Box drawings down double and right single
    when 217  utf8_char = 'E29498 2518' // Box drawings light up and left
    when 218  utf8_char = 'E2948C 250C' // Box drawings light down and right
    when 219  utf8_char = 'E29688 2588' // Full block
    when 221  utf8_char = 'E2968C 258C' // Left half block
    when 222  utf8_char = 'E29690 2590' // Right half block
    when 223  utf8_char = 'E29680 2580' // Upper HALF BLOCK
    when 249  utf8_char = 'E280A2 2022' // Bullet (just like OEM character 007)
//  when 249  utf8_char = 'C2A8   00A8' // Diaeresis (spacing)
//  when 249  utf8_char = 'DC85   0705' // Syriac horizontal colon
    when 254  utf8_char = 'E296AA 25AA' // Black small square (square bullet)
    otherwise utf8_char = 'C2BF   00BF' // Inverted question mark
  endcase
  if is_unicode_macro_loaded
    // Format char to quoted Unicode codepoint.
    utf8_char = GetToken(utf8_char, ' ', 2)
    result = Chr(127) + utf8_char + Chr(127)
  else
    // Format char to hardcoded bytes.
    utf8_char = GetToken(utf8_char, ' ', 1)
    for i = 1 to Length(utf8_char) by 2
      result = result + Chr(Val(SubStr(utf8_char, i, 2), 16))
    endfor
  endif
  return(result)
end to_utf8

string proc strip_parentheses(string topic)
  string result [255] = topic
  if topic[Length(topic) - 1: 2] == "()"
    result = topic[1: Length(topic) - 2]
  endif
  return(result)
end strip_parentheses

string proc strip_help_formatting(string s)
  string r [MAXSTRINGLEN] = s
  r = StrReplace(LINK_START_DUAL_PART_X + '.*' + LINK_MIDDLE_DUAL_PART_X
                 + '{.*}' + LINK_STOP,
                 r,
                 '\1',
                 'x')
  r = StrReplace(BOLD_START        , r, '', '')
  r = StrReplace(BOLD_STOP         , r, '', '')
  r = StrReplace(ITALIC_START      , r, '', '')
  r = StrReplace(ITALIC_STOP       , r, '', '')
  r = StrReplace(LINK_START_INFOBOX, r, '', '')
  r = StrReplace(LINK_START_WYSIWYG, r, '', '')
  r = StrReplace(LINK_STOP         , r, '', '')
  r = StrReplace(SUBTOPIC_START    , r, '', '')
  r = StrReplace(SUBTOPIC_STOP     , r, '', '')
  r = StrReplace(TOPIC_START       , r, '', '')
  r = StrReplace(TOPIC_STOP        , r, '', '')
  return(r)
end strip_help_formatting

proc delete_help_formatting()
  lReplace(LINK_START_DUAL_PART_X + '.*' + LINK_MIDDLE_DUAL_PART_X + '{.*}'
           + LINK_STOP,
           '\1',
           'gnx')

  lReplace(LINK_START_INFOBOX + '{.*}' + LINK_STOP, 'Info->\1', 'gnx')

  lReplace(BOLD_START        , '', 'gn')
  lReplace(BOLD_STOP         , '', 'gn')
  lReplace(ITALIC_START      , '', 'gn')
  lReplace(ITALIC_STOP       , '', 'gn')
  lReplace(LINK_START_WYSIWYG, '', 'gn')
  lReplace(LINK_STOP         , '', 'gn')
  lReplace(SUBTOPIC_START    , '', 'gn')
  lReplace(SUBTOPIC_STOP     , '', 'gn')
  lReplace(TOPIC_START       , '', 'gn')
  lReplace(TOPIC_STOP        , '', 'gn')
end delete_help_formatting

/*
  Convert_help_formatting() rough description:
    The help's bold and italic tags become HTML <strong> and <em> tags.

    Topic and subtopic names/phrases are also addresses or address parts.
    So the Help's (sub)topic tags mark the (sub)topic as an address, which
    in HTML we implement as a <span> tag with a class="(sub)topic" attribute
    and with an id attribute if a unique one is still available.
    ( The Help contains duplicate topics and subtopics, including subtopics
      that are not linked to. Except for the special case below, the Help also
      has no way of addressing duplicate (sub)topics, so in practice not
      generating an id for a duplicate should not become a missing link
      in HTML either.)

    The Help's link tags are implemented as an HTML anchor element with an href
    attribute pointing to the HTML id attribute of a (sub)topic.
    A special case is a Help link that points to a subtopic in a specific
    topic: for this they both become part of the HTML address, and an extra
    <span> element with an id attribute with the combined address is added to
    the subtopic.
*/
proc convert_help_formatting()
  string  address         [255] = ''
  integer doc_id                = GetBufferId()
  integer dual_part_address_id  = 0
  string  find_options      [2] = 'gx'
  integer html_ids_id           = 0
  string  main_topic      [255] = ''
  string  sub_topic       [255] = ''

  Message('Converting HELP formatting to HTML formatting ...')

  dual_part_address_id = create_temp_buffer('DualPartAddresses')
  html_ids_id          = create_temp_buffer('HtmlIds')

  GotoBufferId(doc_id)
  // Least-bad solution:
  // We have to convert the "<" and ">" in the help text to HTML entities
  // before we generate HTML tags,
  // even if this messes up our "Info->..." references,
  // which we then have to reverse further down.
  // The least-bad part is that we can contain the problem to this one proc.
  lReplace('<', '&lt;', 'gn')
  lReplace('>', '&gt;', 'gn')

  lReplace(BOLD_START  , '<strong>' , 'gn')
  lReplace(BOLD_STOP   , '</strong>', 'gn')
  lReplace(ITALIC_START, '<em>'     , 'gn')
  lReplace(ITALIC_STOP , '</em>'    , 'gn')

  // Infobox links are simple. They don't contain their "Info->" yet.
  lReplace(LINK_START_INFOBOX + '{.*}' + LINK_STOP,
           '<a href="#Info->\1">\1</a>',
           'gnx')

  // WYSIWYG links are relatively simple.
  // They only additionally need reversing of "&gt;" back to ">".
  find_options = 'gx'
  while lFind(LINK_START_WYSIWYG + '{.*}' + LINK_STOP, find_options)
    address = GetFoundText(1)
    address = StrReplace('&gt;', address, '>', '')
    lReplace(LINK_START_WYSIWYG + '{.*}' + LINK_STOP,
             '<a href="#' + address + '">\1</a>',
             'x1')
    find_options = 'x'
  endwhile

  //  Subtopic links are special:
  //  - There are dual-part links with dual-part addresses, that address a
  //    subtopic that is not unique across topics!
  //    This is solved by first creating a list of those dual-part link
  //    addresses and then prefixing each corresponding subtopic with a span
  //    element with an id containing the dual-part address.
  //  - Across topics there are duplicate subtopics.
  //    There are duplicate subtopics that are addressed by a single-part
  //    address.
  //    There are also subtopics with the same name/address as a topic.
  //    So in order to keep HTML ids unique, we only need to add a single-part
  //    address id to the first subtopic that has an unused (sub)topic address.
  //  In order to keep track of topics and (possibly id-less) subtopics
  //  we always add a class attribute to them in the generated HTML.

  // Make a list of dual-part addresses.
  find_options = 'gx'
  while lFind(LINK_START_DUAL_PART_X + '{.*}' + LINK_MIDDLE_DUAL_PART_X
              + '{.*}' + LINK_STOP,
              find_options)
    address = GetFoundText(1)
    if Pos(';', address)
      AddLine(address, dual_part_address_id)
    endif
    find_options = 'x+'
  endwhile

  // Replace dual-part Help links with HTML links for both types of addresses.
  lReplace(LINK_START_DUAL_PART_X + '{.*}' + LINK_MIDDLE_DUAL_PART_X
           + '{.*}' + LINK_STOP,
           '<a href="#\1">\2</a>',
           'gnx')

  // Prefix subtopics that are addressed by a dual-part Help address
  // with a span element with an id with a dual-part HTML address.
  find_options = 'gx'
  while lFind('{' + TOPIC_START + '}|{' + SUBTOPIC_START + '}', find_options)
    find_options = 'x+'
    if GetText(CurrPos(), Length(TOPIC_START)) == TOPIC_START
      if lFind(TOPIC_START + '{.*}' + TOPIC_STOP, 'x')
        main_topic = GetFoundText(1)
      endif
    else
      if lFind(SUBTOPIC_START + '{.*}' + SUBTOPIC_STOP, 'x')
        sub_topic = GetFoundText(1)
        GotoBufferId(dual_part_address_id)
        if lFind(main_topic + ';' + sub_topic, '^gi$')  // Case-insensitive!
          GotoBufferId(doc_id)
          InsertText('<span id="' + main_topic + ';' + sub_topic + '"></span>')
        else
          GotoBufferId(doc_id)
        endif
      endif
    endif
  endwhile

  //  Topics get replaced first, because they have priority on getting
  //  an HTML id, which in practice is necessary a lot.
  find_options = 'gx'
  while lFind(TOPIC_START + '{.*}' + TOPIC_STOP, find_options)
    address = GetFoundText(1)
    address = StrReplace('&gt;', address, '>', '')
    GotoBufferId(html_ids_id)
    if lFind(address, '^gi$')  // TSE's Help references are case-insensitive!
      GotoBufferId(doc_id)
      lReplace(TOPIC_START + '{.*}' + TOPIC_STOP,
               '<span class="topic">\1</span>',
               'cx1')
    else
      AddLine(address)
      GotoBufferId(doc_id)
      // When we later convert references, we rely on id being the last attribute.
      lReplace(TOPIC_START + '{.*}' + TOPIC_STOP,
               '<span class="topic" id="' + de_regexp(address) + '">\1</span>',
               'cx1')
    endif
    find_options = 'x'
  endwhile

  //  Subtopics still need a single-part address. Because there are subtopics
  //  with duplicate (sub)topic addresses only each first one with an unused
  //  address gets an HTML id attribute.
  find_options = 'gx'
  while lFind(SUBTOPIC_START + '{.*}' + SUBTOPIC_STOP, find_options)
    address = GetFoundText(1)
    address = StrReplace('&gt;', address, '>', '')
    GotoBufferId(html_ids_id)
    if lFind(address, '^gi$')
      GotoBufferId(doc_id)
      lReplace(SUBTOPIC_START + '{.*}' + SUBTOPIC_STOP,
               '<span class="subtopic">\1</span>',
               'cx1')
    else
      AddLine(address)
      GotoBufferId(doc_id)
      // When we later convert references, we rely on id being span's last HTML
      // attribute.
      lReplace(SUBTOPIC_START + '{.*}' + SUBTOPIC_STOP,
               '<span class="subtopic" id="' + de_regexp(address)
               + '">\1</span>',
               'cx1')
    endif
    find_options = 'x'
  endwhile
end convert_help_formatting

proc convert_character_encoding()
  string  utf8_character   [12] = ''
  integer i = 0
  if charset == 'ASCII'
    Message('Replacing OEM characters with ASCII characters ... ')
    Delay(1)
    // Replace left and right triangles by '<' and '>'.
    if textformat == 'Plain'
      lReplace('\d016', '>', 'gnx')
      lReplace('\d017', '<', 'gnx')
    else
      lReplace('\d016', '\&gt;', 'gnx')
      lReplace('\d017', '\&lt;', 'gnx')
    endif
    lReplace('\d030', '^', 'gnx')    // Replace up and down triangles
    lReplace('\d031', 'v', 'gnx')    // by '^' and 'v'.
    lReplace('\d024', '^', 'gnx')    // Replace up and down arrows
    lReplace('\d025', 'v', 'gnx')    // by '^' and 'v'.
    lReplace('\d179', '|', 'gnx')    // Draw vertical line.
    lReplace('\d196', '-', 'gnx')    // Draw horizontal line.
    lReplace('\d218', '+', 'gnx')    // Draw upper left corner.
    lReplace('\d192', '+', 'gnx')    // Draw lower left corner.
    lReplace('\d191', '+', 'gnx')    // Draw upper right corner.
    lReplace('\d217', '+', 'gnx')    // Draw lower right corner.
    lReplace('\d194', '+', 'gnx')    // Draw strait T shape.
    lReplace('\d195', '+', 'gnx')    // Draw left T shape.
    lReplace('\d180', '+', 'gnx')    // Draw right T shape.
    lReplace('\d193', '+', 'gnx')    // Draw inverted T shape.
    lReplace('\d249', '-', 'gnx')    // Double bullet.
    for i = 128 to 255               // Everything else above 127.
      lReplace('\d' + Str(i), '*', 'gnx')
    endfor
  elseif charset == 'UTF-8'
    Message('Replacing OEM characters with UTF-8 characters ... ')
    Delay(1)
    PushPosition()
    is_unicode_macro_loaded = isMacroLoaded(UNICODE_MACRO_NAME)
    BegFile()
    if is_unicode_macro_loaded
      SetBufferStr(  UNICODE_MACRO_NAME
                   + ':'
                   + UNICODE_VARNAME_CHARACTER_CODE_FORMAT,
                   UNICODE_UTF8_PLUS_BOM)
    else
      InsertText(Chr(239) + Chr(187) + Chr(191)) // Add UTF-8 BOM
    endif
    repeat
      if (CurrChar() in 1 .. 31, 128 .. 255)
        utf8_character = to_utf8(CurrChar())
        DelChar()
        InsertText(utf8_character)
        PrevChar()
      endif
    until not NextChar()
    PopPosition()
  elseif charset == 'OEM'
    NoOp()
  endif
end convert_character_encoding

string proc html_reference_format(string topic)
  integer i         = 1
  string  tag [255] = topic
  while i <= Length(tag)
    case tag[i]
      when Chr(0) .. Chr(32)
        tag[i] = '_'
      when "A" .. "Z"
        //  TSE's Help is case-insensitive and a few references occur in mixed
        //  case. HTML references are case-sensitive. A solultion is to convert
        //  all HTML references to lower case.
        tag[i] = Lower(tag[i])
      when "0" .. "9", "a" .. "z", "+", "-", ".", "_", "~", ";"
        //  The "%" is an exceptional character here.
        //  TSE's Help's "Info->..." topics are a pain, because ">" is an HTML
        //  character. As a work-around "Info->..." references are created as
        //  "info-%3e...". This works as long as "%" does not occur in a topic
        //  reference.
        i = i + 1
      otherwise
        tag = tag[1 : i-1] + "%" + Format(Asc(tag[i]):2:'0':16) + tag[i+1 : 255]
        i = i + 3
    endcase
  endwhile
  return(tag)
end html_reference_format

proc convert_href_and_id_characters()
  string s [MAXSTRINGLEN] = ''

  Message('Converting HTML href attributes ...')
  UnMarkBlock()
  BegFile()
  while lFind('href="\#\c{.*}">', 'x+')
    MarkFoundText(1)
    s = GetMarkedText()
    KillBlock()
    s = html_reference_format(s)
    InsertText(s)
  endwhile

  Message('Converting HTML id attributes ...')
  BegFile()
  while lFind('id="\c{.*}">', 'x+')
    MarkFoundText(1)
    s = GetMarkedText()
    KillBlock()
    s = html_reference_format(s)
    InsertText(s)
  endwhile
end convert_href_and_id_characters

proc WhenLoaded()
  my_macro_name = SplitPath(CurrMacroFilename(), _NAME_)

  LINK_MIDDLE_DUAL_PART = LINK_MIDDLE_DUAL_PART // Silence the compiler.
end WhenLoaded

proc Main()
  string  base_help_name   [10] = 'TseHelp'
  integer catch_opportunities   = 0
  string  find_options     [12] = ''
  integer help_id               = 0
  integer i                     = 0
  integer index_id              = 0
  string  link_address    [255] = ''
  string  link_type         [9] = ''
  string  main_topic      [255] = ''
  string  manual_filename [255] = ''
  integer manual_id             = 0
  integer missing_topics_id     = 0
  integer ok                    = TRUE
  integer old_break             = Set(break                , ON)
  integer old_dateformat        = Set(DateFormat           , 6)
  integer old_dateseparator     = Set(DateSeparator        , Asc('-'))
  integer old_ilba              = Set(InsertLineBlocksAbove, FALSE)
  integer old_Insert            = Set(Insert               , ON)
  integer old_rtw               = Set(RemoveTrailingWhite  , ON)
  integer old_uap               = Set(UnMarkAfterPaste     , ON)
  integer org_id                = GetBufferId()
  string  prev_main_topic [255] = ''
  string  s               [255] = ''
  string  sub_topic       [255] = ''
  integer temp_id               = 0
  integer topics_id             = 0
  string  tse_version     [255] = ''

  ClrScr()
  help_id           = create_temp_buffer('RawHelp')
  index_id          = create_temp_buffer('Index')
  missing_topics_id = create_temp_buffer('Missing')
  temp_id           = create_temp_buffer('Temp')
  topics_id         = create_temp_buffer('Topics')
  GotoBufferId(org_id)
  if not help_id
  or not index_id
  or not temp_id
  or not topics_id
    ok = FALSE
    Warn('Hlp2txt error creating temporary files in memory.')
  endif

  //  Lots of user interaction to inform the user about their choices and to
  //  let them make those choices.

  if ok
    ok = info_screen(temp_id, 1)
  endif

  if ok
    tse_version = VersionStr()
    ok = info_screen(temp_id, 2)
    if ok
      PushKey(<GreyCursorDown>)
      Set(X1, 10)
      Set(Y1, 10)
      textformat_menu()
      if textformat == ''
        ok = FALSE
      endif
    endif
  endif

  if ok
    case textformat
      when 'Plain'
        manual_filename = original_LoadDir() + 'help' + SLASH + base_help_name + '.txt'
      when 'HTML'
        manual_filename = original_LoadDir() + 'help' + SLASH + base_help_name + '.html'
      otherwise
        ok = FALSE
        Warn('Hlp2txt programming error: unknown textformat.')
    endcase
  endif

  if ok
    ok = info_screen(temp_id, 3)
  endif

  if ok
    if textformat == 'Plain'
      PushKey(<GreyCursorDown>)
      if is_OEM_font()
        PushKey(<GreyCursorDown>)
      endif
    endif

    PutStrAttrXY(10, 5, 'You chose text format "' + textformat + '".', '')
    PutStrAttrXY(10, 7, 'Your current TSE font is an ' +
                        iif(is_OEM_font(), 'OEM', 'ANSI') +
                        ' font.', '')
    Set(X1, 10)
    Set(Y1, 10)
    charset_menu()
    PutStrAttrXY(10, 5, Format('':MAXSTRINGLEN:' '), '')
    PutStrAttrXY(10, 7, Format('':MAXSTRINGLEN:' '), '')
    if charset == ''
      ok = FALSE
    endif
  endif

  // Create a new named normal buffer for the manual.
  if ok
    AbandonFile(GetBufferId(manual_filename))
    manual_id = CreateBuffer(manual_filename)
    if manual_id
      EmptyBuffer()
      UnMarkBlock()
    else
      ok = FALSE
      Warn('Cannot (re)create manual:'; manual_filename)
    endif
  endif

  if ok
    // Populate TSE's internal help headers and index
    // in SYSTEM_HELP_HEADERS_ID and SYSTEM_HELP_INDEX_ID.
    PushKey(<Escape>)
    Help('Index')

    // Copy the help-encoded index.
    GotoBufferId(SYSTEM_HELP_INDEX_ID)
    MarkLine(1, NumLines())

    GotoBufferId(index_id)
    EmptyBuffer()
    CopyBlock()
    UnMarkBlock()
    // Immediatly get rid of NULL characters at their only source.
    lReplace(NULL, '', 'gnx')

    // Position where in the help-encoded index InfoBox topics will be added.
    GotoBufferId(index_id)
    BegFile()
    lFind('--- I ---', 'g')
    Down(2)
    repeat
      s = strip_help_formatting(Trim(GetText(1, MAXSTRINGLEN)))
    until CmpiStr(s, 'Info->') == 1
       or not Down()
    Up()

    // Add WYSIWYG links for InfoBox topics to the help-encoded index.
    // Here in the index it needs to be WYSIWYG links instead of InfoBox links,
    // because the index needs to show their "Info->..." prefix.
    GotoBufferId(SYSTEM_HELP_HEADERS_ID)
    BegFile()
    while lFind('Info->', 'i+')
      AddLine(LINK_START_WYSIWYG + GetText(CurrPos(), MAXSTRINGLEN) + LINK_STOP,
              index_id)
    endwhile

    // Create an unformatted topics list.
    GotoBufferId(index_id)
    MarkLine(1, NumLines())

    GotoBufferId(topics_id)
    EmptyBuffer()
    CopyBlock()
    UnMarkBlock()
    delete_help_formatting()
    while lFind('---'  , '^g')
    or    lFind('^ *$' , 'gx')
      KillLine()
    endwhile

    // Prefix each topic's main topic as the first field in the topics list.
    //   When copy-pasting a topic's text from TSE's Help into an empty buffer,
    //   its main topic (without parentheses) is added as the first line.
    //   So by doing this for all topics from the Help Index,
    //   we can determine whether each is a main topic or a subtopic.
    //   E.g. copy-pasting from Help('Abs') this way gives "Abs"
    //   on the first line, so "Abs" is a main topic.
    //   E.g. copy-pasting from Help('for') this way gives "Statements",
    //   on the first line, so "for" is a subtopic of main topic "Statements".
    //   In this part we ignore the rest of the help text, because when
    //   getting it this way it does not contain help-formatting.
    GotoBufferId(topics_id)
    BufferVideo()
    BegFile()
    catch_user_escape(ok)
    repeat
      sub_topic = GetText(1, CurrLineLen())
      #ifndef LINUX
        catch_user_escape(ok)
      #endif
      PushKey(<Escape>)
      PushKey(<Grey+>)
      Help(strip_parentheses(sub_topic))

      GotoBufferId(temp_id)
      EmptyBuffer()
      Paste()
      main_topic = GetText(1, CurrLineLen())

      GotoBufferId(topics_id)
      BegLine()
      InsertText(main_topic + FIELD_SEPARATOR)
      Message("Determining main vs subtopics   ",
              CurrLine() * 100 / NumLines(), " % ")
    until not ok
      or not Down()
    UnBufferVideo()

    // Sort topics on their main topic
    MarkLine(1, NumLines())
    Sort(_IGNORE_CASE_)
    UnMarkBlock()
  endif

  //  Create a "raw" help-file consisting of these 4 parts:
  //    The Help's Table of Contents.
  //    An index of 26 letters into the Help's Index.
  //    The Help's Index, where
  //      subtopics get a line with their main topic, and
  //      the alphabetic divider lines get a topic address.
  //    The contents of all main topics from the index.
  if ok
    // Start by copying the Index.
    GotoBufferId(index_id)
    MarkLine(1, NumLines())

    GotoBufferId(help_id)
    EmptyBuffer()
    CopyBlock()
    UnMarkBlock()

    // Enhance the index with addresses for the divider lines
    // and with a main topic reference line below each indexed subtopic.
    BegFile()
    repeat
      case Trim(GetText(1, Length(BOLD_START + '---')))
        when ''
          NoOp()
        when BOLD_START + '---'
          if textformat <> "Plain"
            // Enhance the divider line by adding an address to the letter.
            GotoPos(Length(BOLD_START) + 1)
            if lFind('[A-Z]', 'cx')
              InsertText(TOPIC_START)
              Right()
              InsertText(TOPIC_STOP )
            endif
          endif
        otherwise
          // A topic or subtopic line in the index
          sub_topic = strip_help_formatting(Trim(GetText(1, MAXSTRINGLEN)))
          GotoBufferId(topics_id)
          if lFind(FIELD_SEPARATOR + sub_topic, 'gi$')
            main_topic = GetToken(GetText(1, CurrLineLen()), FIELD_SEPARATOR, 1)
          else
            main_topic = sub_topic
            Message('Hlp2txt programming error: subtopic "', sub_topic,
              '" has no match in determined topics.')
          endif
          GotoBufferId(help_id)
          if not EquiStr(strip_parentheses(sub_topic), main_topic)
            // Enhance subtopic by adding a reference line to the main topic.
            if textformat == "Plain"
              AddLine(Format("   See: ", main_topic))
            else
              AddLine(Format('   Subtopic of: ', LINK_START_WYSIWYG,
                             main_topic, LINK_STOP))
            endif
          endif
      endcase
    until not Down()

    // Before the Index add a 26 letter index into the Index.
    if textformat <> "Plain"
      BegFile()
      InsertLine()
      InsertLine()
      AddLine('ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿')
      AddLine('³ ³')
      GotoPos(3)
      for i = Asc('A') to Asc('Z')
        InsertText(LINK_START_WYSIWYG + Chr(i) + LINK_STOP + '  ')
      endfor
      Left()
      DelChar()
      AddLine('ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ')
      AddLine()
    endif

    // Add the Table of Contents before both indexes.
    BufferVideo()
    catch_user_escape(ok)
    PushKey(<Escape>)
    Help('Table of Contents')
    UnBufferVideo()

    GotoBufferId(SYSTEM_HELP_TOPIC_ID)
    MarkLine(1, NumLines())

    GotoBufferId(help_id)
    BegFile()
    InsertLine()
    InsertLine()
    InsertLine()
    InsertLine()
    CopyBlock()
    UnMarkBlock()

    // Generate the main topics
    GotoBufferId(topics_id)
    BegFile()
    BufferVideo()
    catch_user_escape(ok)
    repeat
      main_topic = GetToken(GetText(1, CurrLineLen()), FIELD_SEPARATOR, 1)
      sub_topic  = GetToken(GetText(1, CurrLineLen()), FIELD_SEPARATOR, 2)
      if main_topic <> prev_main_topic
        prev_main_topic = main_topic
        #ifndef LINUX
          catch_user_escape(ok)
        #endif
        PushKey(<Escape>)
        Help(main_topic)

        GotoBufferId(SYSTEM_HELP_TOPIC_ID)
        MarkLine(1, NumLines())

        GotoBufferId(help_id)
        EndFile()
        AddLine()
        AddLine()
        AddLine()
        AddLine()
        AddLine()
        BegLine()
        InsertText(BOLD_START + TOPIC_START + main_topic + TOPIC_STOP)
        if sub_topic[Length(sub_topic) - 1: 2] == '()'
          InsertText('()')
        endif
        InsertText(BOLD_STOP)
        BegLine()
        CopyBlock()
        UnMarkBlock()

        GotoBufferId(topics_id)
      endif

      Message("Generating main topics   ", CurrLine() * 100 / NumLines(), " % ")
    until not ok
      or not Down()
    UnBufferVideo()

    GotoBufferId(help_id)
    #if DEBUG
      ChangeCurrFilename(SplitPath(manual_filename, _DRIVE_|_PATH_|_NAME_)
                         + '.raw',
                         CCF_OPTIONS)
      BufferType(_NORMAL_)
    #endif
  endif

  // Find links to missing (sub)topics.
  // Practice showed that only a shallow search is needed.
  if ok
    catch_user_escape(ok)
    find_options = 'gx'
    while ok
    and   lFind('{' + LINK_START_WYSIWYG + '}|{' + LINK_START_INFOBOX  + '}|{'
                + LINK_START_DUAL_PART_X + '}', find_options)
      link_type = GetFoundText()
      if link_type == LINK_START_WYSIWYG
        if lFind(LINK_START_WYSIWYG + '{.*}' + LINK_STOP, 'x')
          link_address = GetFoundText(1)
          PushLocation()
          if not (  lFind(TOPIC_START    + link_address + TOPIC_STOP   , 'gi')
                 or lFind(SUBTOPIC_START + link_address + SUBTOPIC_STOP, 'gi'))
            AddLine(link_address, missing_topics_id)
          endif
          PopLocation()
        endif
      elseif link_type == LINK_START_DUAL_PART
        if lFind(LINK_START_DUAL_PART_X + '{.*}' + LINK_MIDDLE_DUAL_PART_X
                 + '{.*}' + LINK_STOP, 'x')
          link_address = GetFoundText(1)
          if Pos(';', link_address)
            link_address = GetToken(link_address, ';', 2)
          endif
          PushLocation()
          if not (  lFind(TOPIC_START    + link_address + TOPIC_STOP   , 'gi')
                 or lFind(SUBTOPIC_START + link_address + SUBTOPIC_STOP, 'gi'))
            AddLine(link_address, missing_topics_id)
          endif
          PopLocation()
        endif
      endif
      find_options = 'x+'
      catch_opportunities = catch_opportunities + 1
      if catch_opportunities mod CATCH_SKIPS == 0
        catch_user_escape(ok)
      endif
      Message('Searching in indexed topics for links to not-indexed topics   ',
              CurrLine() * 100 / NumLines(), ' %')
    endwhile
  endif

  if ok
    GotoBufferId(missing_topics_id)
    //  Delete duplicates.
    //  Note: I reuse variables "main_topic" and "prev_main_topic" here to keep
    //  the macro smaller, but it might be a subtopic. The difference does not
    //  matter here.
    if NumLines()
      MarkLine(1, NumLines())
      Sort(_IGNORE_CASE_)
      BegFile()
      prev_main_topic = GetText(1, MAXSTRINGLEN)
      while Down()
        main_topic = GetText(1, MAXSTRINGLEN)
        if EquiStr(main_topic, prev_main_topic)
          KillLine()
          Up()
          main_topic = GetText(1, MAXSTRINGLEN)
        endif
        prev_main_topic = main_topic
      endwhile
      Message('')
    endif

    // Add the content of the missing topics to end of the manual.
    BegFile()
    if  NumLines()
    and CurrLineLen()
      BufferVideo()
      repeat
        main_topic = GetText(1, MAXSTRINGLEN)
        catch_user_escape(ok)   // Very few, so also in Linux.
        PushKey(<Escape>)
        Help(main_topic)

        GotoBufferId(SYSTEM_HELP_TOPIC_ID)
        MarkLine(1, NumLines())

        GotoBufferId(help_id)
        EndFile()
        AddLine()
        AddLine()
        AddLine()
        AddLine()
        AddLine()
        BegLine()
        InsertText(BOLD_START + TOPIC_START + main_topic + TOPIC_STOP)
        //  if sub_topic[Length(sub_topic) - 1: 2] == '()'
        //    InsertText('()')
        //  endif
        InsertText(BOLD_STOP)
        BegLine()
        CopyBlock()
        UnMarkBlock()

        GotoBufferId(missing_topics_id)
        Message('Adding not-indexed topics to manual   ',
                CurrLine() * 100 / NumLines(), ' %')
      until not ok
         or not Down()
      UnBufferVideo()
    endif
  endif

  // Convert the help file to a plain text file or an HTML file.
  if ok
    GotoBufferId(help_id)
    MarkLine(1, NumLines())

    GotoBufferId(manual_id)
    EmptyBuffer()
    CopyBlock()
    UnMarkBlock()
    if textformat == "Plain"
      delete_help_formatting()
    else
      convert_help_formatting()
    endif
    convert_character_encoding()
    convert_href_and_id_characters()
  endif

  if ok
    BegFile()
    Message("Adding a title page ... ")
    Delay(1)
    if textformat == "Plain"
      InsertLine("")
      AddLine("")
      AddLine("")
      AddLine(center("The Semware Editor Professional"))
      AddLine(center(tse_version))
      AddLine(center("Generated Manual"))
      AddLine("")
      AddLine("")
      AddLine("")
      AddLine(center("Copyright by SemWare Corporation."))
      if compare_versions(tse_version, '4.42') < 0
        AddLine(center("All rights reserved worldwide."))
      else
        AddLine(center("See the liberal License Agreement near the bottom of this document."))
      endif
      AddLine("")
      AddLine("")
      AddLine("")
      AddLine(Format("This manual was generated on";
                     Val(GetToken(GetDateStr(), "-", 3));
                     current_month_name();
                     GetToken(GetDateStr(), "-", 1);
                     'at';
                     GetTimeStr();
                     "from TSE's"))
      AddLine(Format("interactive Help system using version";
                     MY_MACRO_VERSION;
                     'of the Hlp2txt macro'))
      AddLine(Format('from https://eCarlo.nl/tse.'))
      AddLine("")
      AddLine("")
      BegLine()
      InsertData('info4')
      GotoBlockEnd()
      UnMarkBlock()
      BegLine()
      AddLine("For versions after TSE Pro 4.4 you can find additional Help-type info")
      AddLine("in TSE's read.me file and in")
      AddLine("https://ecarlo.nl/tse/files/TSE_Pro_Undocumented_Features.html")
      AddLine("")
      AddLine("")
      AddLine("")
      AddLine("Visit https://semware.com and https://ecarlo.nl/tse for lots of TSE info,")
      AddLine("or to join the mailing lists at https://semware.com/html/newsgroup.php")
      AddLine("to exchange info with TSE users worldwide.")
      if compare_versions(tse_version, '4.40.43') >= 0
        AddLine("")
        AddLine("")
        AddLine("")
        AddLine("Note: The date time below is the last time Semware updated the Help.")
      endif
      AddLine("")
      AddLine("")
      AddLine("")
      AddLine("")
      AddLine("")
      AddLine("")
      AddLine("")
      AddLine("")
      AddLine("")
      AddLine("")
    else
      InsertLine("<!doctype html>")
      AddLine('<html lang="en">')
      AddLine("<head>")
      AddLine("  <title>Generated TSE Manual</title>")
      AddLine("  <style>")
      AddLine("    a {text-decoration: none;}")
      AddLine("    .center {text-align: center;}")
      AddLine("  </style>")
      AddLine("</head>")
      AddLine("<body>")
      AddLine('<h1 class="center">The Semware Editor Professional</h1>')
      AddLine('<h1 class="center">' + tse_version + "</h1>")
      AddLine('<h1 class="center">Generated Manual</h1>')
      AddLine('<p class="center">&copy; SemWare Corporation.</p>')
      if compare_versions(tse_version, '4.42') < 0
        AddLine('<p class="center">All rights reserved worldwide.</p>')
      else
        AddLine('<p class="center">See the liberal <a href="#license_agreement">License Agreement</a> for specifics.</p>')
      endif
      AddLine("<p>")
      AddLine(Format("This manual was generated on";
                     Val(GetToken(GetDateStr(), "-", 3));
                     current_month_name();
                     GetToken(GetDateStr(), "-", 1);
                     'at';
                     GetTimeStr();
                     "from TSE's interactive Help system using version";
                     MY_MACRO_VERSION))
      AddLine(Format('of the <a href="https://eCarlo.nl/tse#Hlp2txt" target="_blank">Hlp2txt</a> macro from <a href="https://eCarlo.nl/tse" target="_blank">eCarlo.nl/tse</a>.'))
      AddLine("</p>")
      AddLine("<p>")
      AddLine('')
      BegLine()
      InsertData('info4')
      GotoBlockEnd()
      UnMarkBlock()
      BegLine()
      AddLine("</p>")
      AddLine("<p>")
      AddLine("For versions after TSE Pro 4.4 you can find additional Help-type info")
      AddLine("in TSE's read.me file and in")
      AddLine('<a href="https://ecarlo.nl/tse/files/TSE_Pro_Undocumented_Features.html"')
      AddLine('   target="_blank">TSE Pro Undocumented Features</a>.')
      AddLine("</p>")
      AddLine("<p>")
      AddLine("This HTML manual was tested with the Windows versions of Chrome and Firefox.")
      AddLine("</p>")
      AddLine("<p>")
      AddLine('Visit <a href="https://semware.com" target="_blank">Semware.com</a>')
      AddLine('and <a href="https://ecarlo.nl/tse" target="_blank">eCarlo.nl/tse</a>')
      AddLine("for lots more TSE info, or to join the")
      AddLine('<a href="https://semware.com/html/newsgroup.php" target="_blank">mailing lists</a>')
      AddLine("to exchange info with TSE users worldwide.")
      AddLine("</p>")
      if compare_versions(tse_version, '4.40.43') >= 0
        AddLine("<p>")
        AddLine('Note: The date time below is the last time Semware updated the Help.')
        AddLine("</p>")
      endif
      AddLine("<pre>")
    endif
  endif

  if ok
    if textformat <> "Plain"
      EndFile()
      AddLine('</pre>')
      AddLine('</body>')
      AddLine('</html>')
    endif
  endif

  if ok
    BegFile()
    Message("Ready.")
  else
    Warn("Hlp2txt was aborted.")
  endif
  if ok
    if (   textformat == "HTML"
       and YesNo("Start the default .HTML browser?"     ) == 1)
      if SaveFile() // User might answer overwrite question with No.
        #if EDITOR_VERSION < 4400h
          Dos(CurrFilename(), _DONT_PROMPT_|_RUN_DETACHED_|_DONT_WAIT_)
        #else
          StartPgm(CurrFilename())
        #endif
      endif
    endif
  endif
  Set(break                , old_break)
  Set(DateFormat           , old_dateformat)
  Set(DateSeparator        , old_dateseparator)
  Set(InsertLineBlocksAbove, old_ilba)
  Set(Insert               , old_Insert)
  Set(RemoveTrailingWhite  , old_rtw)
  Set(UnMarkAfterPaste     , old_uap)
  UpdateDisplay(_ALL_WINDOWS_REFRESH_)
  PurgeMacro(my_macro_name)
  if  NumFiles() == 1
  and Lower(SubStr(CurrFilename(), 2, 7)) == "unnamed"
    AbandonEditor()
  endif
end Main

// Just in case the user has redefined the standard <Grey+> key,
// the macro redefines it the standard way for the duration of its execution.
<Grey+> Copy()

