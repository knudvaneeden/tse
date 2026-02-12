/*
  Macro           Uniview
  Author          Carlo Hogeveen
  Website         eCarlo.nl/tse
  Compatibility   Windows GUI TSE 4.0 upwards
  Version         v1.0.1   31 Oct 2022


  TSE itself only knows 256 characters, 218 of which are displayable ANSI
  characters.

  Unicode 15.0 (13 September 2022) consists of 149,186 characters.

  This extension lets TSE display a text's Unicode characters.

  It does so if:
  - A supporting font is selected or TSE's 3D display options are OFF.
  - The character is not in the current line, or browse mode is ON.
  - No block or a line block is marked in the current file.
  - TSE's screen is not split into multiple windows.

  The extension only modifies the display of characters, never the actual text
  in the TSE editing buffer.


  INSTALLATION

  The Uniview extension requires the Unicode extension to be installed.
  The Unicode extension requires the Status  extension to be installed.
  You can find them at
    https://eCarlo.nl/tse/index.html#Status
    https://eCarlo.nl/tse/index.html#Unicode

  Copy this file "Uniview.s" to TSE's "mac" folder, and compile it there,
  for example by opening it there in TSE and applying the Macro -> Compile menu.

  Add its name "Uniview" to the Macro -> AutoLoad List menu.
  If the "CursorLine" extension is installed too, then "Uniview" must be placed
  higher than "CursorLine" in the Macro AutoLoad List menu.
  The order of Unicode vs Uniview in the list does not matter.
  Restart TSE.

  For best results I recommend to:
  - Select the Courier New font.
  - Set both of TSE's configuration 3D display options
    "Use 3D Characters" and "Use 3D Buttons" to OFF.
  - Save TSE's settings.
  - Restart TSE: a restart is necessary for these changes to have effect!


  CONFIGURATION

  I don't know how, but Uniview gains the functionality to display characters
  that are not in the current font, and in high quality at that, as well as
  the bility to combine Unicode's "combining" characters,
  if  (!) AT TSE'S START-UP (!)  :
  - Either both of TSE's configuration's display options
    "Use 3D Characters" and "Use 3D Buttons" are set to OFF.
  - Or the font is "Unifont" .
  This functionality does not change when changing the font or 3D display
  options *during* a TSE session.
  The Courier New font itself only supports about 2700 characters, so some
  behind the scenes magic augments Courier New with characters it does not
  support.
  On the other hand, if a 3D display option is ON at TSE's start-up, then
  Courier New will display an unsupported character as an empty square.

  About installing additional fonts or uninstalling fonts in Windows 10:
  - Note that TSE can only select monospace fonts.
    These are fonts where each character has the same width, as opposed to
    proportional fonts, which display characters with varying widths.
    For example, if you have a line of 10 "m" characters and one with 10 "i"
    characters, then a monospace font displays the lines with equal length,
    whereas a proportional font displays the "m" line longer than the "i" line.
  - There is a monospace version of the Unifont font at
      https://www.fontspace.com/unifont-font-f26370
    Upside:
    - It claims to support 65352 characters.
    Downsides:
    - It is a grainy font.
    - To make Uniview work with Unifont, I had to apply fixes that might have
      dependencies on my computer and that might not work on your computer.
    - In TSE versions up to and including 4.43:
      - Unifont's characters are displayed too small, and characters and lines
        have too great a distance from each other.
      - TSE itself only works if TSE's two 3D display options are ON.
        Them being OFF results in display errors that make TSE unworkable.
      - Uniview dispays a much larger font than TSE.
    - In TSE versions from 4.44 upwards:
      - Unifont's characters are displayed well-sized.
      - Lines still have a bit too much distance from each other, which is most
        noticeable when a text uses Unicode line drawing characters.
        It is unclear to me whether this is a TSE or Uniview bug.
  - You can install a (downloaded) font file ideally by dragging it to the
    "Start -> Settings -> Personalisation -> Fonts -> Drag and drop to install"
    panel, or otherwise by selecting/clicking on the file after making very
    sure it is not a sneaky executable file.
  - You can uninstall a font by selecting it in the same Windows 10 menu.
  - The number of installed versions of the font is shown as the number
    of "font faces".


  KNOWN UNIVIEW BUG

  Uniview does not properly restore the end of a redisplyed line that
  contains Unicode characters if all of these conditions apply:
  - The TSE version is older than 4.41.44 (18 Jan 2021).
  - The font is Unifont.
  - Both of the 3D display options "Use 3D Characters" and "Use 3D Buttons"
    are OFF.

  A simple work-around is to set at least one of the 3D display options to ON.


  KNOWN TSE BUG

  If both of TSE's configuration's display options "Use 3D Characters" and
  "Use 3D Buttons" are set to OFF, then TSE itself displays control characters,
  including character 127, too wide for Unifont and too thin for other fonts,
  respectively right-shifting and left-shifting the rest of the line, but not
  the cursor.
  This in combination with the Unicode extension's heavy use of character 127
  makes a current line hard to edit.

  The above TSE bug has a second TSE bug as a side effect.
  If a TSE menu is opened and closed over such a too thin or wide control
  character, then the closed menu randomly does not clean up a few menu
  characters.

  For the Courier New font Uniview works around the first TSE bug by
  redisplaying the current line with a non-TSE method.
  This might cause blinking when used in combination with the CursorLine
  extension, and it will cause the CursorLine extension to not work for a
  current line that contains character 127, but at least the cursor is
  positioned correctly in the cursor line again.

  For the Unifont font Uniview sets a different output driver at the start-up
  of TSE, which seems to solve both TSE bugs natively.



  TODO
    MUST
    - Final test for remaining bugs.
    SHOULD
    - None.
    COULD
    - Display non-ANSI characters for the current line too, and enable editing
      it by adjusting the cursor position for its left-shifted part.
      This should then be both a configurable and a toggable option.
    - Redisplay the current line elsewhere with characters instead of codes.
      This probably should be a separate extension, because this wish overlaps
      with and should replace an existing, inferior function in v2.5 of the
      Unicode extension.
    - Bug: When TSE's 3D display options are OFF, TSE displays character 127
      thinner with Courier New and wider with Unifont, shifting the rest of the
      line left and right, but not the cursor position, which makes editing
      such a line a pain.
      The bug has been reported to Semware, who had a try at it, but no
      solution. This might have to wait for Semware executing their plan to
      publish TSE's source code, which is why it is still on this todo list.
      Until then Uniview implements a work-around by redisplaying the current
      line (with the Unicode codepoints quoted by character 127) correctly.
      The work-around might cause the current line to blink, but at least it
      positions the line correctly under the cursor again.
    - Find out how TSE's 3D display options being OFF at TSE's start-up
      enables Uniview's use of Windows APIs to get a character from another
      font, if the current font (Courier New) does not have that character.
      The goal is to make Uniview reproduce this even if TSE's 3D display
      options are ON. This waits on Semware executing their plan to publish
      TSE's source code.
    WONT
    - Make Uniview work with split windows.




  B A C K G R O U N D   I N F O R M A T I O N


  ASCII / ANSI / UNICODE / FONT INTRO

  Computers encode characters as numbers.
  There are many standards for which number to use for which character.
  These are called character encodings.
  Software like an editor reads those numbers and shows them as characters.

  ASCII
  One of the oldest character encoding standards is ASCII.
  See TSE's incorrectly named "ASCII Chart" menu.
  Only the first 128 characters (numbers 0 - 127) are actually ASCII.
  The first 32 ASCII characters (0 - 31) are so-called "control characters",
  which in other applications are not used to display a character, so do not
  use them as displayable characters.
  The last 128 characters (128 - 255) are undefined in ASCII.

  OEM
  There are many, many, many OEM character encoding standards that extend ASCII
  with definitions for characters 128 - 255.
  Not surprisingly, because different languages need different characters.
  Each computer manufacturer could make up its own OEM standard for a language.
  This worked great for sharing files with same-language + same-computer-brand
  users, and worked horribly outside of each such select group.

  The Console version of TSE only supports an OEM character encoding.

  ANSI  (aka Windows-1252, aka CP-1252)
  ANSI is its unofficial name, used in practice because it is nice and short.
  This is a widely used standard that supports a broad range of languages that
  originated in western Europe:
    Afrikaans, Danish, Dutch, English, Finnish, French, German, Hungarian,
    Icelandic, Indonesian, Italian, Norwegian, Portuguese, Spanish, Swedish.
  While still limited in the world's context, ANSI removed a lot of borders and
  computer-brand dependencies for sharing text files.
  If you are using the GUI version of TSE with an ANSI compatible font like
  Courier New, then TSE interprets the characters numbered 32 - 255 as
  characters encoded with ANSI character encoding standard.
  For characters 32 - 127 ASCII and ANSI character encoding is the same.
  Which 218 characters are actuallly ANSI (aka Windows-1252) is show here:
    https://en.wikipedia.org/wiki/Windows-1252
    http://www.alanwood.net/demos/ansi.html
  Note that characters 0 - 31, 127, 129, 141, 143, 144 and 157 are officially
  not ANSI characters and not displayable.
  So, if you open a file with ASCII or ANSI encoded characters, then GUI TSE
  with font Courier New will show them correctly.

  Unicode

  As I write this, Unicode can encode more than 144,000 characters.
  There are actually 5 major Unicode encoding standards,
  namely UTF-8, UTF-16LE, UTF-16BE, UTF-32LE and UTF-32BE.
  None of them is "the" Unicode character encoding.
  The only thing they share is, that a Unicode character has an administrative
  character number, called a codepoint.

  Windows itself default uses UTF-16LE.
  Luckily Windows is natively still backwards compatible with ANSI, meaning
  that an ANSI application like TSE "sees" Windows' Unicode file system
  sneakily converted to ANSI characters where possible.
  On the web UTF-8 is the most used character encoding, for more than 99%.
  Only for UTF-8 are the first 128 character encodings the same as ASCII.

  So, if an unenhanced TSE opens a Unicode encoded file, then for UTF-8 it
  might show only a few garbage characters, and for the other Unicode character
  encodings it will show a lot of garbage.

  By adding the "Unicode" extension TSE can convert those Unicode-encoded
  characters that have an ANSI equivalent, and for other Unicode-encoded
  characters it will show their Unicode codepoint quoted by character 127
  (usually a square).
  The name of the character under the cursor it can show as a status.
  With the Unicode extension 218 ANSI-compatible Unicode characters are
  displayable in TSE.

  GUI TSE's default font "Courier New" has over 2700 characters,
  but TSE itself only uses the ANSI ones.

  The Uniview extension redisplays all non-ANSI characters on the screen
  based on their Unicode extension's quoted codepoints in the text using
  the current font.
  If the font does not support the requested character, then the font will
  display its font-dependent "default character".
  Because the displayed character is shorter than the quoted codepoint it
  replaces, Uniview will left-shift all characters to the right of it.
  Uniview only changes the display of characters, not the actual characters in
  TSE's edit buffer.
  So, using Uniview, over 2700 characters are displayable with TSE's default,
  high-quality Courier New font, and 65352 characters with the grainy Unifont
  font that is ugly in TSE <= 4.43.

  Uniview has two limitations to work around a problem it cannot solve.
  When Uniview replaces a quoted codepoint with one displayable character,
  on the screen the rest of the line is left-shifted.
  But the actual text in the TSE buffer is not left-shifted.
  That would make it hard to try to edit or block-mark left-shefted text.
  Uniview is therefore turned off completely when a non-line block is marked in
  the current buffer, and also for the current line if browse mode is off.



  TIP

  If you want to know which fonts are installed on your Windows system and
  which characters each installed font actually covers, then start the standard
  Windows application "Character Map", also known as "CharMap.exe".
  Type "CharMap" in the Windows' start-up menu or after <WindowsKey R>.
  In CharMap you can browse fonts and characters, and search on a character's
  name part.



  HISTORY

  v0.1   DEVELOPMENT   27 May 2022
    Just a demo of the technical concept of overwriting the screen's characters
    using Windows' TextOutW function.
    This is great, because TextOutW accepts Unicode as input, and will let us
    write any of the current font's characters, not just the ANSI ones.

  v0.2    DEVELOPMENT 2 Jun 2022
    Displays the current text's non-ANSI characters! Very buggily.
    However, it does indicate and show off the end goal.

  v0.3    BETA        3 Jun 2022
    As a very first beta version, it "works".

  v0.3.1  BETA        4 Jun 2022
    Fixed the claimed backwards compatibility with TSE GUI 4.2.

  v0.3.2  BETA        6 Jun 2022
    Documented my new find, that Unifont makes the TSE screen unworkable in a
    newly installed TSE 4.43. It does not in my customized TSE 4.43, and I have
    no clue why.

  v0.4     BETA       11 Jun 2022
    Made the extension backward compatible down to TSE 4.0.
    Did not fix any of the bugs yet.

  v0.4.1   BETA       14 Jun 2022
    One bug solved, many more to go.

  v0.5     BETA       19 Jun 2022
    Solved several bugs by rewriting the core algorithm: by separating
    concerns, each concern could be simplified.

    For one, the "trailing codes" bug is solved.

    Noteworthy for macro programmers:
    I tricked TSE into supplying Windows' TextOutW API with a string parameter
    that can be upto 1028 bytes long.

  v0.5.1   BETA       23 Jun 2022
    Updated the documentation and the test file.

  v0.6     BETA        1 Jul 2022
    For TSE <= 4.43 I "fixed" Uniview to work with Unifont on my computer
    if TSE's two 3D display configuration options are ON.
    TSE and Uniview still show Unifont with different character sizes,
    but the characters should now take up an equal amount of space.
    Because the Uniview fix is based on test results with dependencies on my
    computer, I am not sure wether the fix will work on other computers too.

  v0.6.1   BETA        2 Jul 2022
    Bug fixed: Uniview did not work with Unifont with window borders OFF.
    New known bug: Uniview did not work with Unifont with line numbers ON.

  v0.6.2   BETA        3 Jul 2022
    Bug fixed:
      Now also works with line numbers ON.
    Bug fixed:
      Finally implemented long stated block marking exception, with the
      refinement, that line blocks do not disable Uniview.
    Bug fixed:
      "Fixed" Uniview working incorrectly for split windows by disabling it
      completely for split windows.

  v0.7     BETA        Not published.
    On my computer Uniview now also works with the Unifont font in the not yet
    released TSE 4.44.
    There apparently is a difference between how TSE and Uniview display
    Unifont.
    Maybe some day, when Semware executes their plan to release TSE's source
    code, the reason for this difference can be found and fixed.
    For now I made Uniview's Unifont match TSE's Unifont as close as possible
    based on test results on my computer. That might (not) work on other
    computers.

  v0.7.1     BETA      4 Jul 2022
    Bug fixed:
      In a text line a Unicode "combining" character could cause the last
      character of the line to not be cleared when quoted codepoints are
      replaced by displayable characters.

  v0.7.2     BETA      6 Jul 2022
    TSE-bug worked-around:
      If TSE's 3D options are OFF, then a too thin character 127 left-shifts
      the rest of the line away from the cursor position.
      A too thin character 127 for example happens with the Courier New font.

  v0.7.3     BETA      7 Jul 2022
    Temporarily adapted to also be compatible with the preview version of TSE 4.45.
    Note: The preview version of TSE 4.45 disables Uniview's ability to show
    non-Courier New characters when the Courier New font is selected.   :-(

  v0.8       BETA      8 Jul 2022
    Added warnings for those font and settings changes that need a TSE restart.

  v0.8.1     BETA     10 Jul 2022
    Made a tiny improvement to the text of three messages,
    and reverted a change for a TSE change that will be reverted.

  v0.8.2     BETA     12 Jul 2022
    Tiny documentation improvements.

  v0.9       BETA     14 Jul 2022
    Fixed syntax-hiliting lines with non-ANSI characters, except for the
    current line and for the Unifont font.
    Unfortunately this introduced new display errors.

  v0.9.1     BETA     15 Jul 2022
    Fixed the new display errors introduced in v0.9.

  v0.9.2     BETA     16 Jul 2022
    Fixed syntax-hiliting a current line that containes non-ANSI characters.

  v0.9.3     BETA     17 Jul 2022
    Fixed an old bug that I never saw because I also use the CursorLine
    extension, but that hampered non-CursorLine users:
      A line containing non-ANSI characters was not redisplayed with quoted
      Unicode codepoints when it became the current line.

  v0.10      BETA     19 Jul 2022
    Fixed the last Unifont display errors.

  v1                  21 Jul 2022
    First non-beta release.
    Removed all debugging code.
    Tweaked the documentation.

  v1.0.1              31 Oct 2022
    Bug fix: At start-up it left a marked block open in a system buffer.

*/





// Start of compatibility restrictions and mitigations


#ifdef LINUX
  This extension is not Linux compatible.
#endif

#ifdef WIN32
#else
   16-bit versions of TSE are not supported. You need at least GUI TSE 4.0.
#endif

#ifdef EDITOR_VERSION
#else
   Editor Version is older than TSE 3.0. You need at least GUI TSE 4.0.
#endif

#if EDITOR_VERSION < 4000h
   Editor Version is older than TSE 4.0. You need at least GUI TSE 4.0.
#endif



#if EDITOR_VERSION < 4200h
  // TSE Pro versions < v4.2 o not have the predefined constants _FOREGROUND_
  // and _BACKGROUND_ yet, and TSE syntax does not allow us to define constants
  // starting with an underscore.
  #define FOREGROUND 1
  #define BACKGROUND 2

  // TSE Pro versions < v4.2 cannot use non-standard colors.
  // The hexadecimal values for TSE's standard colors:
  string       GetColorTableValue_colors [90] =
    '0 80 8000 8080 800000 800080 808000 C0C0C0 808080 FF FF00 FFFF FF0000 FF00FF FFFF00 FFFFFF'

  integer proc GetColorTableValue(integer tab_parameter, integer index)
    // TSE Pro versions < v4.2 cannot use different foreground and background
    // colors, so we ignore the tab parameter.
    integer rgb_color = tab_parameter // Dummy assignment to pacify the compiler
    rgb_color = Val(GetToken(GetColorTableValue_colors, ' ', index + 1), 16)
    return(rgb_color)
  end GetColorTableValue
#endif

// TSE 4.0 returns a compiler error for _FOREGROUND_ and _BACKGROUND_
// in a false #else branch, but in a false #if branch.
#if EDITOR_VERSION >= 4200h
  #define FOREGROUND _FOREGROUND_
  #define BACKGROUND _BACKGROUND_
#endif



#if EDITOR_VERSION < 4400h
  /*
    VersionStr()  v1.1

    This procedure implements TSE Pro 4.4 and above's VersionStr() command
    for lower versions of TSE.
    It returns a string containing TSE's version number in the same format
    as you see in the Help -> About menu, starting with the " v".

    Newer versions of TSE do not use the "v" any more, but they also do not
    use this pre-TSE v4.4 of VersionStr().

    Examples of relevant About lines:
      The SemWare Editor Professional v4.00e
      The SemWare Editor Professional/32 v4.00    [the console version]
      The SemWare Editor Professional v4.20
      The SemWare Editor Professional v4.40a

    v1.1 fixes recognition of the TSE Pro v4.0 console version.
  */
  string versionstr_value [maxstringlen] = ''

  proc versionstr_screen_scraper()
    string  attributes [maxstringlen] = ''
    string  characters [maxstringlen] = ''
    integer position                  = 0
    integer window_row                = 1
    while versionstr_value == ''
    and   window_row       <= query(windowrows)
      getstrattrxy(1, window_row, characters, attributes, maxstringlen)
      position = pos('The SemWare Editor Professional', characters)
      if position
        position = Pos(' v', characters)
        if position
          versionstr_value = substr(characters, position + 1, maxstringlen)
          versionstr_value = GetToken(versionstr_value, ' ', 1)
        endif
      endif
      window_row = window_row + 1
    endwhile
  end versionstr_screen_scraper

  string proc VersionStr()
    versionstr_value = ''
    Hook(_BEFORE_GETKEY_, versionstr_screen_scraper)
    pushkey(<enter>)
    pushkey(<enter>)
    BufferVideo()
    lversion()
    unbuffervideo()
    unhook(versionstr_screen_scraper)
    return(versionstr_value)
  end versionstr
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
    therefore versioning of compare_versions() starts at v2.0.
*/

// compare_versions_standardize() is a helper proc for compare_versions().

string proc compare_versions_standardize(string p_version)
  integer char_nr                  = 0
  string  n_version [maxstringlen] = trim(p_version)

  // Replace any spaces between digits by one period. Needs two StrReplace()s.
  n_version = strreplace('{[0-9]} #{[0-9]}', n_version, '\1.\2', 'x')
  n_version = strreplace('{[0-9]} #{[0-9]}', n_version, '\1.\2', 'x')

  // Remove any spaces before and after digits.
  n_version = strreplace(' #{[0-9]}', n_version, '\1', 'x')
  n_version = strreplace('{[0-9]} #', n_version, '\1', 'x')

  // Remove any spaces before and after periods.
  n_version = strreplace(' #{\.}', n_version, '\1', 'x')
  n_version = StrReplace('{\.} #', n_version, '\1', 'x')

  // Separate version parts by periods if they aren't yet.
  char_nr = 1
  while char_nr < Length(n_version)
    case n_version[char_nr:1]
      when '.'
        noop()
      when '0' .. '9'
        if not (n_version[char_nr+1:1] in '0' .. '9', '.')
          n_version = n_version[1:char_nr] + '.' + n_version[char_nr+1:maxstringlen]
        endif
      otherwise
        if (n_version[char_nr+1:1] in '0' .. '9')
          n_version = n_version[1:char_nr] + '.' + n_version[char_nr+1:maxstringlen]
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
  string  v1_part [maxstringlen] = ''
  string  v1_str  [maxstringlen] = ''
  string  v2_part [MAXSTRINGLEN] = ''
  string  v2_str  [maxstringlen] = ''
  integer v_num_parts            = 0
  integer v_part_nr              = 0
  v1_str      = compare_versions_standardize(version1)
  v2_str      = compare_versions_standardize(version2)
  v_num_parts = Max(NumTokens(v1_str, '.'), NumTokens(v2_str, '.'))
  repeat
    v_part_nr = v_part_nr + 1
    v1_part   = Trim(GetToken(v1_str, '.', v_part_nr))
    v2_part   = trim(gettoken(v2_str, '.', v_part_nr))
    if  v1_part == ''
    and isDigit(v2_part)
      v1_part = '0'
    endif
    if v2_part == ''
    and isdigit(v1_part)
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



// End of compatibility restrictions and mitigations.





Datadef combining_and_non_spacing_characters
  "300 301 302 303 304 305 306 307 308 309 30A 30B 30C 30D 30E 30F 310 311 312"
  "313 314 315 316 317 318 319 31A 31B 31C 31D 31E 31F 320 321 322 323 324 325"
  "326 327 328 329 32A 32B 32C 32D 32E 32F 330 331 332 333 334 335 336 337 338"
  "339 33A 33B 33C 33D 33E 33F 340 341 342 343 344 345 346 347 348 349 34A 34B"
  "34C 34D 34E 34F 350 351 352 353 354 355 356 357 358 359 35A 35B 35C 35D 35E"
  "35F 360 361 362 363 364 365 366 367 368 369 36A 36B 36C 36D 36E 36F 483 484"
  "485 486 487 488 489 7EB 7EC 7ED 7EE 7EF 7F0 7F1 7F2 7F3 C00 C04 D00 135D"
  "135E 135F 1A7F 1AB0 1AB1 1AB2 1AB3 1AB4 1AB5 1AB6 1AB7 1AB8 1AB9 1ABA 1ABB"
  "1ABC 1ABD 1ABE 1ABF 1AC0 1AC1 1AC2 1AC3 1AC4 1AC5 1AC6 1AC7 1AC8 1AC9 1ACA"
  "1ACB 1ACC 1ACD 1ACE 1B6B 1B6C 1B6D 1B6E 1B6F 1B70 1B71 1B72 1B73 1DC0 1DC1"
  "1DC2 1DC3 1DC4 1DC5 1DC6 1DC7 1DC8 1DC9 1DCA 1DCB 1DCC 1DCD 1DCE 1DCF 1DD0"
  "1DD1 1DD2 1DD3 1DD4 1DD5 1DD6 1DD7 1DD8 1DD9 1DDA 1DDB 1DDC 1DDD 1DDE 1DDF"
  "1DE0 1DE1 1DE2 1DE3 1DE4 1DE5 1DE6 1DE7 1DE8 1DE9 1DEA 1DEB 1DEC 1DED 1DEE"
  "1DEF 1DF0 1DF1 1DF2 1DF3 1DF4 1DF5 1DF6 1DF7 1DF8 1DF9 1DFA 1DFB 1DFC 1DFD"
  "1DFE 1DFF 20D0 20D1 20D2 20D3 20D4 20D5 20D6 20D7 20D8 20D9 20DA 20DB 20DC"
  "20DD 20DE 20DF 20E0 20E1 20E2 20E3 20E4 20E5 20E6 20E7 20E8 20E9 20EA 20EB"
  "20EC 20ED 20EE 20EF 20F0 2CEF 2CF0 2CF1 2DE0 2DE1 2DE2 2DE3 2DE4 2DE5 2DE6"
  "2DE7 2DE8 2DE9 2DEA 2DEB 2DEC 2DED 2DEE 2DEF 2DF0 2DF1 2DF2 2DF3 2DF4 2DF5"
  "2DF6 2DF7 2DF8 2DF9 2DFA 2DFB 2DFC 2DFD 2DFE 2DFF 3099 309A A66F A670 A671"
  "A672 A674 A675 A676 A677 A678 A679 A67A A67B A67C A67D A69E A69F A6F0 A6F1"
  "A8E0 A8E1 A8E2 A8E3 A8E4 A8E5 A8E6 A8E7 A8E8 A8E9 A8EA A8EB A8EC A8ED A8EE"
  "A8EF A8F0 A8F1 FE20 FE21 FE22 FE23 FE24 FE25 FE26 FE27 FE28 FE29 FE2A FE2B"
  "FE2C FE2D FE2E FE2F 101FD 10376 10377 10378 10379 1037A 10EAB 10EAC 10F46"
  "10F47 10F48 10F49 10F4A 10F4B 10F4C 10F4D 10F4E 10F4F 10F50 10F82 10F83"
  "10F84 10F85 11300 1133B 11366 11367 11368 11369 1136A 1136B 1136C 11370"
  "11371 11372 11373 11374 16AF0 16AF1 16AF2 16AF3 16AF4 1CF00 1CF01 1CF02"
  "1CF03 1CF04 1CF05 1CF06 1CF07 1CF08 1CF09 1CF0A 1CF0B 1CF0C 1CF0D 1CF0E"
  "1CF0F 1CF10 1CF11 1CF12 1CF13 1CF14 1CF15 1CF16 1CF17 1CF18 1CF19 1CF1A"
  "1CF1B 1CF1C 1CF1D 1CF1E 1CF1F 1CF20 1CF21 1CF22 1CF23 1CF24 1CF25 1CF26"
  "1CF27 1CF28 1CF29 1CF2A 1CF2B 1CF2C 1CF2D 1CF30 1CF31 1CF32 1CF33 1CF34"
  "1CF35 1CF36 1CF37 1CF38 1CF39 1CF3A 1CF3B 1CF3C 1CF3D 1CF3E 1CF3F 1CF40"
  "1CF41 1D165 1D166 1D167 1D168 1D169 1D16D 1D16E 1D16F 1D170 1D171 1D172"
  "1D17B 1D17C 1D17D 1D17E 1D17F 1D180 1D181 1D182 1D185 1D186 1D187 1D188"
  "1D189 1D18A 1D18B 1D1AA 1D1AB 1D1AC 1D1AD 1D242 1D243 1D244 1E000 1E001"
  "1E002 1E003 1E004 1E005 1E006 1E008 1E009 1E00A 1E00B 1E00C 1E00D 1E00E"
  "1E00F 1E010 1E011 1E012 1E013 1E014 1E015 1E016 1E017 1E018 1E01B 1E01C"
  "1E01D 1E01E 1E01F 1E020 1E021 1E023 1E024 1E026 1E027 1E028 1E029 1E02A"
  "1E8D0 1E8D1 1E8D2 1E8D3 1E8D4 1E8D5 1E8D6"
end combining_and_non_spacing_characters





// Global constants and semi-constants

#ifndef INTERNAL_VERSION
  #define INTERNAL_VERSION FALSE
#endif

// Numbers are left-justified (!) on position n * 5, 1 <= n <= 27.
// The four leading spaces are vital. This odd format facilitates a simple
// and fast search-and-retrieve algorithm.
string ANSI_CODEPOINTS [138] = '    8364 8218 402  8222 8230 8224 8225 ' +
                                   '710  8240 352  8249 338  381  8216 ' +
                                   '8217 8220 8221 8226 8211 8212 732  ' +
                                   '8482 353  8250 339  382  376 '
string ANSI_CODES      [138] = '    128  130  131  132  133  134  135  ' +
                                   '136  137  138  139  140  142  145  ' +
                                   '146  147  148  149  150  151  152  ' +
                                   '153  154  155  156  158  159 '

string  ANSI_DELETE                       [1] = Chr(127)
string  ANSI_NULL                         [1] = Chr(0)
integer FONT_COMBINES_CHARS_AND_FALLS_THROUGH = FALSE
integer IS_CHR_127_WRONGLY_SIZED              = FALSE
string  MACRO_NAME             [MAXSTRINGLEN] = ''
integer NO_CURSORLINE_EXTENSION               = TRUE
string  UTF16LE_DELETE                    [2] = Chr(0xA1) + Chr(0x25)
integer ZERO_LENGTH_CODEPOINTS_ID             = 0



// Constants from wingdi.h:

#define ANSI_CHARSET                0
#define DEFAULT_CHARSET             1

#define OUT_DEFAULT_PRECIS          0
#define OUT_STRING_PRECIS           1
#define OUT_CHARACTER_PRECIS        2
#define OUT_STROKE_PRECIS           3
#define OUT_TT_PRECIS               4
#define OUT_DEVICE_PRECIS           5
#define OUT_RASTER_PRECIS           6
#define OUT_TT_ONLY_PRECIS          7
#define OUT_OUTLINE_PRECIS          8
#define OUT_SCREEN_OUTLINE_PRECIS   9
#define OUT_PS_ONLY_PRECIS         10

#define CLIP_DEFAULT_PRECIS         0

#define DEFAULT_QUALITY             0
#define DRAFT_QUALITY               1
#define PROOF_QUALITY               2
#define NONANTIALIASED_QUALITY      3
#define ANTIALIASED_QUALITY         4
#define CLEARTYPE_QUALITY           5
#define CLEARTYPE_NATURAL_QUALITY   6

#define DEFAULT_PITCH               0
#define FIXED_PITCH                 1
#define VARIABLE_PITCH              2

#define FF_DONTCARE   (0 shl 4)  /* Don't care or don't know. */
#define FF_ROMAN      (1 shl 4)  /* Variable stroke width, serifed. */
                                 /* Times Roman, Century Schoolbook, etc. */
#define FF_SWISS      (2 shl 4)  /* Variable stroke width, sans-serifed. */
                                 /* Helvetica, Swiss, etc. */
#define FF_MODERN     (3 shl 4)  /* Constant stroke width, serifed or sans-serifed. */
                                 /* Pica, Elite, Courier, etc. */
#define FF_SCRIPT     (4 shl 4)  /* Cursive, etc. */
#define FF_DECORATIVE (5 shl 4)  /* Old English, etc. */





// Global variables

integer device_context_handle                   = FALSE
integer font_flags                              = 0
integer font_handle                             = FALSE
integer font_height                             = 0
string  font_name                [MAXSTRINGLEN] = ''
string  font_prev_name           [MAXSTRINGLEN] = ''
integer font_prev_size                          = 0
integer font_size                               = 0
integer font_width_for_CreateFont               = 0
integer font_width_for_TextOut                  = 0
integer font_width_from_tse                     = 0
integer prev_SpecialEffects                     = 0
integer textoutw_max_length                     = 257 * 4
string  textoutw_string                     [0] = '' // Only use length property
string  textoutw_string_1_257    [MAXSTRINGLEN] = '' // Reuse length + content
string  textoutw_string_258_514  [MAXSTRINGLEN] = '' // Reuse length + content
string  textoutw_string_515_771  [MAXSTRINGLEN] = '' // Reuse length + content
string  textoutw_string_772_1028 [MAXSTRINGLEN] = '' // Reuse length + content
integer window_needs_checking                   = FALSE



// Windows APIs

dll "<user32.dll>"
  integer proc GetDC(integer hWnd)
  integer proc ReleaseDC(integer hWnd, integer hDC)
end


dll "<gdi32.dll>"

  integer proc TextOutW(
    integer hdc,
    integer x,
    integer y,
    integer lpString,   // Type LPCWSTR.
    integer c)          // lpString's length in 16-bit characters.

    // An LPCWSTR is a 32-bit pointer to a constant string of UTF-16LE
    // characters, which MAY be null-terminated.

  integer proc CreateFontA(
    integer cHeight,
    integer cWidth,
    integer cEscapement,
    integer cOrientation,
    integer cWeight,
    integer bItalic,
    integer bUnderline,
    integer bStrikeOut,
    integer iCharSet,
    integer iOutPrecision,
    integer iClipPrecision,
    integer iQuality,
    integer iPitchAndFamily,
    string  pszFaceName:cstrval)

  integer proc SelectObject(
    integer hdc,
    integer h)

  integer proc DeleteObject(
    integer h)

  // The "colour" parameter has a BGR instead of an RGB format: 0x00bbggrr.

  integer proc SetBkColor(
    integer hdc,
    integer colour)

  integer proc SetTextColor(
    integer hdc,
    integer colour)

end



integer proc rgb_to_bgr(integer rgb)
  integer bgr   = 0
  integer blue  = 0
  integer green = 0
  integer red   = 0
  red   = rgb / 65536
  green = (rgb / 256) mod 256
  blue  = rgb mod 256
  bgr   = blue * 65536 + green * 256 + red
  return(bgr)
end rgb_to_bgr


proc set_windows_color(integer tse_color)
  integer tse_background_color   = 0
  integer tse_background_rgb     = 0
  integer tse_foreground_color   = 0
  integer tse_foreground_rgb     = 0
  integer windows_background_bgr = 0
  integer windows_foreground_bgr = 0

  tse_background_color   = tse_color  /  16
  tse_foreground_color   = tse_color mod 16
  tse_background_rgb     = GetColorTableValue(BACKGROUND, tse_background_color)
  tse_foreground_rgb     = GetColorTableValue(FOREGROUND, tse_foreground_color)
  windows_background_bgr = rgb_to_bgr(tse_background_rgb)
  windows_foreground_bgr = rgb_to_bgr(tse_foreground_rgb)

  SetBkColor  (device_context_handle, windows_background_bgr)
  SetTextColor(device_context_handle, windows_foreground_bgr)
end set_windows_color


/*
  About the wide_string_... functions in general:

    While the occasion for the wide string functions was preparing a parameter
    for the Windows TextOutW API, which does not need the wide string to be
    ended with two NULL bytes, I implemented that anyway to generalize the
    functions for broader future use.

    The functions can handle multiple wide strings concurrently.

    TSE's Length() function works on wide strings. Other TSE functions do not.

    For each wide string define a group of ordinary strings in order to create
    room in memory for the wide string.
    For a global group of strings pass the first string to the functions,
    for a local  group of strings pass the last  string to the functions.
    Global and local strings are stored in memory in the opposite order.

    You need to calculate the wide string's maximum usable memory yourself.
    It is the sum of the defined lengths of each ordinary string in its
    group, plus 2 for each ordinary string that is not the first one.
    ( Technical explanation: For all ordinary strings except the first one
      their internal 2 length bytes are reused for the content of the wide
      string too. )
    For example, if a wide string consists of a group of 3 ordinary global
    strings of length 10 each, the the wide string's maximum length is
      10 + (10 + 2) + (10 + 2) = 34

  wide_strings_id
    Do not do anthing with this variable yourself.
    It is a helper variable for use by the functions only.

  wide_string_init(first_string, max_string_length)
    sets the wide string's maximum length to protect against memory leaks,
    sets the wide string's length to 0,
    terminates the wide string it with two null bytes,
    and returns TRUE/FALSE to indicate whether everything went OK.

    Note that the string's length does not include the two closing NULL bytes,
    but that the internal use of the maximum string length does count them.

  wide_string_add(first_string, string_addition)
    Adds the string_addition to the wide string,
    sets the wide string's new length,
    terminates the wide string with two null bytes,
    and returns TRUE/FALSE to indicate whether everything went OK.
*/


integer wide_strings_id = 0


integer proc wide_string_init(var string  string_reference,
                                  integer string_max_length)
  integer length_address = Addr(string_reference)
  integer ok             = TRUE
  integer string_address = AdjPtr(length_address, 2)

  // Remember the string's max length across calls
  if not wide_strings_id
    PushLocation()
    wide_strings_id = CreateTempBuffer()
    PopLocation()
  endif
  SetBufferInt(Str(string_address), string_max_length, wide_strings_id)

  // Set the wide string's length to 0, which TSE's Length() function will return.
  string_reference = ''

  // Add two NULL bytes for those outside usages that need them.
  if string_max_length >= 2
    pokeword(string_address, 0)
  else
    ok = false
  endif
  return(ok)
end wide_string_init


integer proc wide_string_add(var string string_reference,
                                 string string_addition)
  integer byte_base_position = 0
  integer byte_counter       = 0
  integer length_address     = addr(string_reference)
  integer ok                 = true
  integer string_address     = adjptr(length_address, 2)
  integer string_max_length  = getbufferint(str(string_address), wide_strings_id)

  if Length(string_reference) + Length(string_addition) + 2 <= string_max_length
    byte_base_position = AdjPtr(string_address, Length(string_reference) - 1)
    for byte_counter = 1 to length(string_addition)
      pokebyte(adjptr(byte_base_position, byte_counter),
               asc(string_addition[byte_counter]))
    endfor

    // Set the wide string's new length (as seen by TSE's Length() function).
    PokeWord(AdjPtr(string_address, -2),
                    Length(string_reference) + Length(string_addition))

    // Add two NULL bytes for those outside usages that need them.
    PokeWord(AdjPtr(string_address, Length(string_reference)), 0)
  else
    ok = FALSE
  endif
  return(ok)
end wide_string_add



integer proc text_out_w(var string  string_reference,
                            integer window_col,
                            integer window_row)
  integer ok                     = TRUE
  integer string_length_address  = Addr(string_reference)
  integer string_content_address = AdjPtr(string_length_address, 2)

  ok = TextOutW(device_context_handle,
                font_width_for_TextOut * (window_col - 1),
                font_height            * (window_row - 1),
                string_content_address,
                Length(string_reference) / 2)

  // Bug: A sequence of TextOutW() commands causes some of them to skip doing
  //      anything, as if a currently issued one is cancelled if a next one is
  //      issued beffore the current one runs or finishes running.
  // Trick: A KeyPressed() between issuing TextOutW() commands causes the
  //        tiniest pause, which I assume allows the currently issued one to
  //        run and finish running before the next one is issued.
  KeyPressed()

  return(ok)
end text_out_w



/*
  Up to and including TSE 4.43, TSE has two problems with the Unifont font.

  The first one is displaying too small characters with too much space.
  I received a test version of TSE 4.44 in which this was improved upon.

  TSE's GetCharWidthHeight() usually returns a character width that we can use
  for as CreateFont's and TextOut's font width.
  For Unifont this does not work for CreateFont for any TSE version,
  and does not work for TextOut for TSE versions prior to 4.44.

  The below procedures provide Unifont work-around font_widths for the Windows
  APIs.

  These Unifont work-around procedures are based on values deduced from tests
  on my computer. I have no idea how well it will work on other computers.
*/

proc msg_font_size_error(integer font_size)
  MsgBox('Uniview does not know Unifont font size ' + Str(font_size),
         'This will cause display errors for lines with non-ANSI characters.')
end msg_font_size_error


proc tse_to_api_font_widths()
  font_width_for_CreateFont = font_width_from_tse
  font_width_for_TextOut    = font_width_from_tse
  if font_name == 'Unifont'
    if compare_versions(VersionStr(), '4.44') >= 0
      case font_size
        when  8  font_width_for_CreateFont =  11
        when  9  font_width_for_CreateFont =  11
        when 10  font_width_for_CreateFont =  13
        when 11  font_width_for_CreateFont =  14
        when 12  font_width_for_CreateFont =  15
        when 14  font_width_for_CreateFont =  18
        when 16  font_width_for_CreateFont =  20
        when 18  font_width_for_CreateFont =  22
        when 20  font_width_for_CreateFont =  25
        when 22  font_width_for_CreateFont =  27
        when 24  font_width_for_CreateFont =  29
        when 26  font_width_for_CreateFont =  33
        when 28  font_width_for_CreateFont =  34
        when 36  font_width_for_CreateFont =  44
        when 48  font_width_for_CreateFont =  58
        when 72  font_width_for_CreateFont =  88
        otherwise
          msg_font_size_error(font_size)
      endcase
    else
      case font_size
        when  8  font_width_for_CreateFont =  18  font_width_for_TextOut = 10
        when  9  font_width_for_CreateFont =  20  font_width_for_TextOut = 11
        when 10  font_width_for_CreateFont =  22  font_width_for_TextOut = 12
        when 11  font_width_for_CreateFont =  26  font_width_for_TextOut = 14
        when 12  font_width_for_CreateFont =  28  font_width_for_TextOut = 15
        when 14  font_width_for_CreateFont =  32  font_width_for_TextOut = 17
        when 16  font_width_for_CreateFont =  34  font_width_for_TextOut = 18
        when 18  font_width_for_CreateFont =  40  font_width_for_TextOut = 22
        when 20  font_width_for_CreateFont =  46  font_width_for_TextOut = 25
        when 22  font_width_for_CreateFont =  50  font_width_for_TextOut = 27
        when 24  font_width_for_CreateFont =  54  font_width_for_TextOut = 29
        when 26  font_width_for_CreateFont =  58  font_width_for_TextOut = 32
        when 28  font_width_for_CreateFont =  62  font_width_for_TextOut = 34
        when 36  font_width_for_CreateFont =  80  font_width_for_TextOut = 44
        when 48  font_width_for_CreateFont = 106  font_width_for_TextOut = 58
        when 72  font_width_for_CreateFont = 156  font_width_for_TextOut = 84
        otherwise
          msg_font_size_error(font_size)
      endcase
    endif
  endif
end tse_to_api_font_widths



proc codepoint_to_utf16be(integer codepoint, var string utf16be_char)
  integer high_6x          = 0
  integer high_surrogate   = 0
  integer low_10x          = 0
  integer low_surrogate    = 0
  integer uuuuu            = 0
  integer wwww             = 0
  if     codepoint <= 0xD7FF
  or (   codepoint >= 0xE000
     and codepoint <= 0xFFFF)
    utf16be_char = Chr(codepoint / 256) + Chr(codepoint mod 256)
  elseif codepoint >    0xFFFF
  and    codepoint <= 0x10FFFF
    low_10x =  codepoint &            1111111111b
    high_6x = (codepoint &      1111110000000000b) shr 10
    uuuuu   = (codepoint & 111110000000000000000b) shr 16
    wwww    = (uuuuu - 1                         ) shl  6

    high_surrogate = 1101100000000000b + wwww + high_6x
    low_surrogate  = 1101110000000000b +        low_10x

    utf16be_char = Chr(high_surrogate  /  256) +
                   Chr(high_surrogate mod 256) +
                   Chr( low_surrogate  /  256) +
                   Chr( low_surrogate mod 256)
  else
    // gigo()
    utf16be_char = ANSI_NULL + '?'
  endif
end codepoint_to_utf16be


proc codepoint_to_utf16le(integer codepoint, var string utf16le_char)
  string utf16be_char [4] = ''
  codepoint_to_utf16be(codepoint, utf16be_char)
  if Length(utf16be_char) == 2
    utf16le_char = utf16be_char[2:1] +
                   utf16be_char[1:1]
  else
    utf16le_char = utf16be_char[2:1] +
                   utf16be_char[1:1] +
                   utf16be_char[4:1] +
                   utf16be_char[3:1]
  endif
end codepoint_to_utf16le


proc ansi_to_codepoint(string ansi_char, var integer codepoint)
  integer byte      = 0
  if Length(ansi_char) == 1
    byte = Asc(ansi_char)
    case byte
      when 0 .. 127
        codepoint = byte
      when 160 .. 255
        codepoint = byte
      otherwise
        codepoint = Val(SubStr(ansi_codepoints,
                               Pos(' ' + Str(byte) + ' ',
                                   ansi_codes             ) + 1,
                               4))
        if codepoint == 0
          // gigo()
          codepoint = byte
        endif
    endcase
  elseif Length(ansi_char)                     >  1
  and           ansi_char[1:1]                 == Chr(127)
  and           ansi_char[Length(ansi_char):1] == Chr(127)
    codepoint = Val(ansi_char[2:Length(ansi_char) - 2], 16)
  else
    // gigo()
    codepoint = Asc(ansi_char)
  endif
end ansi_to_codepoint


integer proc has_a_display_length(string ansi_char)
  string  codepoint   [10] = ''
  string  old_WordSet [32] = ''
  integer result           = TRUE

  if FONT_COMBINES_CHARS_AND_FALLS_THROUGH
  or font_name == 'Unifont'
    old_WordSet = Set(WordSet, ChrSet('0-9A-Fa-f'))

    codepoint = ansi_char[2: Length(ansi_char) - 2] // Strip quotes.
    codepoint = Str(Val(codepoint, 16), 16)         // Strip leading zeros.

    PushLocation()
    GotoBufferId(ZERO_LENGTH_CODEPOINTS_ID)
    result = not lFind(codepoint, 'gw')
    PopLocation()

    Set(WordSet, old_WordSet)
  endif

  return(result)
end has_a_display_length



/*
  While it is probably not common, It is reasonable to take into account, that
  the width of someone's TSE editing window can exceed 127 ANSI characters.
  That makes it impossible to handle an ANSI to UTF-16LE conversion within a
  string, given that TSE's maximum string length is 255 bytes, and given that
  the conversion will typically double and can very theoretically quadruple the
  amount of bytes.

  TSE uses one string that contains the corresponding character colors for the
  whole window part of a line.
  TextOutW needs SetTextColor and SetBkColor to set each change in text color
  before it writes a string of same-colored characters to the screen.
  This requires this tool's capability to writing a line of text to the
  screen in in same-colored chunks at a time.

  We do not want the huge overhead of setting the color for each character and
  writing one character at a time to the screen.

  The folowing procedure handles that complexity during the conversion
  of ANSI to UTF-16LE.
  The tricky parts are:
  - The originating ANSI text might contain non-ANSI characters.
    One non-ANSI character is represented by a string of ANSI characters.
  - As each character is written to the screen as 2 or 4 bytes, the next screen
    writing position advances by only 1 displayed character.
  - Then there are Unicode "combining" characters, which depe3nding on context
    can add no length to the displayed characters.
*/

proc redisplay_non_ansi_line(string  ansi_text,
                             integer redisplay_start_from,
                             integer redisplay_number_of_chars,
                             string  ansi_attrs,
                             integer window_x1,
                             integer window_row)
  string  ansi_char                [8] = ''
  integer ansi_char_beg_pos            = 1
  integer ansi_char_end_pos            = 0
  integer attr_counter                 = 1
  integer codepoint                    = 0
  integer color_char_counter           = 0
  integer display_char_counter         = 0
  integer loop_char_counter            = 0
  integer tse_color                    = 0
  string  utf16le_attr             [1] = ''
  string  utf16le_char             [4] = ''
  string  utf16le_next_attr        [1] = ''
  integer window_col                   = window_x1

  wide_string_init(textoutw_string, textoutw_max_length)

  for loop_char_counter = 1 to Length(ansi_text)
    ansi_char = ansi_text[ansi_char_beg_pos]
    case ansi_char
      when ''
        ansi_char = ' '
      when ANSI_DELETE
        ansi_char_end_pos = ansi_char_beg_pos +
                            Pos(ANSI_DELETE,
                                ansi_text[ansi_char_beg_pos + 1: MAXSTRINGLEN])
        if Val(ansi_text[ansi_char_beg_pos + 1 .. ansi_char_end_pos - 1], 16) > 0
          ansi_char = ansi_text[ansi_char_beg_pos .. ansi_char_end_pos]
        endif
    endcase
    if loop_char_counter >= redisplay_start_from
      if has_a_display_length(ansi_char)
        display_char_counter = display_char_counter + 1
        color_char_counter   = color_char_counter   + 1
      else
        loop_char_counter    = loop_char_counter    - 1
      endif
      if display_char_counter <= redisplay_number_of_chars
        ansi_to_codepoint(ansi_char, codepoint)
        codepoint_to_utf16le(codepoint, utf16le_char)
        wide_string_add(textoutw_string, utf16le_char)
        utf16le_attr      = iif(ansi_attrs[attr_counter] == '',
                                utf16le_attr,
                                ansi_attrs[attr_counter])
        utf16le_next_attr = iif(ansi_attrs[attr_counter + 1] == '',
                                utf16le_next_attr,
                                ansi_attrs[attr_counter + 1])
        if utf16le_attr         <> utf16le_next_attr          // At end of color
        or display_char_counter == redisplay_number_of_chars  // At end of characters to display
        or loop_char_counter    == Length(ansi_text)          // At end of line       to display
          tse_color = Asc(utf16le_attr)
          set_windows_color(tse_color)
          text_out_w       (textoutw_string, window_col, window_row)
          wide_string_init (textoutw_string, textoutw_max_length)
          window_col         = window_col + color_char_counter
          color_char_counter = 0
        endif
      endif
      attr_counter = attr_counter + Length(ansi_char)
    endif
    ansi_char_beg_pos = ansi_char_beg_pos + Length(ansi_char)
  endfor
end redisplay_non_ansi_line


proc redisplay_ansi_line_by_uniview(string  ansi_text,
                                    string  ansi_attrs,
                                    integer window_col,
                                    integer window_row)
  integer codepoint        = 0
  integer i                = 0
  integer text_length      = Length(ansi_text)
  integer tse_color        = 0
  integer tse_next_color   = Asc(ansi_attrs[1])
  integer tse_prev_color   = -1                // A non-existing color.
  integer old_Cursor       = Set(Cursor, OFF)  // Smudges screen if on.
  integer color_col        = window_col
  string  utf16le_char [4] = ''

  wide_string_init(textoutw_string, textoutw_max_length)

  for i = 1 to text_length
    tse_color      = tse_next_color
    tse_next_color = iif(i == text_length, -1, Asc(ansi_attrs[i + 1]))

    if tse_color <> tse_prev_color
      set_windows_color(tse_color)
      tse_prev_color = tse_color
    endif

    if ansi_text[i] == ANSI_DELETE
      wide_string_add(textoutw_string, UTF16LE_DELETE)
    else
      ansi_to_codepoint(ansi_text[i], codepoint)
      codepoint_to_utf16le(codepoint, utf16le_char)
      wide_string_add(textoutw_string, utf16le_char)
    endif

    if tse_color <> tse_next_color
      text_out_w(textoutw_string, color_col, window_row)
      wide_string_init(textoutw_string, textoutw_max_length)
      color_col = window_col + i
    endif
  endfor

  Set(Cursor, old_Cursor)
end redisplay_ansi_line_by_uniview


proc redisplay_ansi_line_by_tse(string  ansi_text,
                                string  ansi_attrs,
                                integer window_col,
                                integer window_row)
  integer i                        = 0
  string  temp_text [MAXSTRINGLEN] = ''

  // PutStrAttrXY() is too smart for our purpose, because it only redraws
  // characters changed since its own display of them, unaware of TextOutW()'s
  // displayed characters needing to be overwritten.
  // So we need to trick TSE by redrawing its known displayed characters twice,
  // first to something else, and then back to the original text.
  for i = 1 to Length(ansi_text)
    if ansi_text[i] == '0'
      temp_text[i] = 'X'
    else
      temp_text[i] = '0'
    endif
  endfor

  PutStrAttrXY(window_col, window_row, temp_text, ansi_attrs)
  PutStrAttrXY(window_col, window_row, ansi_text, ansi_attrs)
end redisplay_ansi_line_by_tse


proc redisplay_window()
  string  ansi_attrs   [MAXSTRINGLEN] = ''
  string  ansi_text    [MAXSTRINGLEN] = ''
  integer browse_mode                 = BrowseMode()
  integer buffer_CurrLine             = 0
  integer buffer_line                 = 0
  integer curr_x_offset               = CurrXoffset()
  integer redisplay_start_from        = 0
  integer redisplay_number_of_chars   = 0
  integer window_cols                 = Query(WindowCols)
  integer window_row                  = 0
  integer window_rows                 = Query(WindowRows)
  integer window_x1                   = Query(WindowX1)
  integer window_y1                   = Query(WindowY1)

  if Query(SpecialEffects) <> prev_SpecialEffects
    // We need to give a warning when no 3D display options being On changes to
    // a 3D option being On, and vice versa.
    // The nots are a trick to change the compared values to 0 or 1,
    // which saves having to do a lot of subconditions.
    if not (Query(SpecialEffects) & (_USE_3D_CHARS_ | _USE_3D_BUTTONS_)) <>
       not ( prev_SpecialEffects  & (_USE_3D_CHARS_ | _USE_3D_BUTTONS_))
      if Query(Beep)
        Alarm()
      endif
      MsgBox('3D display options changed to [not] both being off',
             'Save TSE settings and restart TSE for the full effect.')
      // Sometimes this MsgBox is immediately followed by the next one.
      // To better visualize that this MsgBox closed before a next one opens,
      // there is a small delay between them.
      Delay(9)
    endif
    prev_SpecialEffects = Query(SpecialEffects)
  endif

  GetFont(font_name, font_size, font_flags)

  if font_name <> font_prev_name
  or font_size <> font_prev_size
    if  font_prev_name <> ''
    and font_prev_name <> font_name
    and ('Unifont' in font_name, font_prev_name)
      if Query(Beep)
        Alarm()
      endif
      MsgBox('Font changed from ' + font_prev_name + ' to ' + font_name,
             'Save TSE settings and restart TSE for the full effect.')
    endif
    if font_handle
      DeleteObject(font_handle)
    endif
    GetCharWidthHeight(font_width_from_tse, font_height)
    tse_to_api_font_widths()
    font_handle   = CreateFontA(font_height,
                                font_width_for_CreateFont,
                                0, 0, 0, 0, 0, 0,
                                // The other fields "0" values:
                                //    ANSI_CHARSET,
                                //    OUT_DEFAULT_PRECIS,
                                //    CLIP_DEFAULT_PRECIS,
                                //    DEFAULT_QUALITY,
                                //    DEFAULT_PITCH | FF_DONTCARE,
                                // Their used values:
                                      DEFAULT_CHARSET,
                                      OUT_DEFAULT_PRECIS,
                                      CLIP_DEFAULT_PRECIS,
                                      DEFAULT_QUALITY,
                                      DEFAULT_PITCH | FF_DONTCARE,
                                font_name)
    SelectObject(device_context_handle, font_handle)
    font_prev_name = font_name
    font_prev_size = font_size
  endif

  PushLocation()
  buffer_CurrLine = CurrLine()
  buffer_line     = CurrLine() - CurrRow() + 1 // The window's 1st buffer line.

  for window_row = window_y1 to window_y1 + window_rows - 1
    ansi_text  = ''
    ansi_attrs = ''
    GetStrAttrXY(window_x1, window_row, ansi_text, ansi_attrs, window_cols)
    if buffer_line <> buffer_CurrLine
    or browse_mode
      GotoLine(buffer_line)
      if CurrLineLen() <= MAXSTRINGLEN
        ansi_text                 = GetText(1, MAXSTRINGLEN)
        redisplay_start_from      = 1 + curr_x_offset
        redisplay_number_of_chars = Min(window_cols,
                                        Length(ansi_text[redisplay_start_from:
                                                         MAXSTRINGLEN]))
      else
        redisplay_start_from      = 1
        redisplay_number_of_chars = Length(ansi_text)
      endif
      if Pos(ANSI_DELETE, ansi_text)
        redisplay_non_ansi_line(ansi_text,
                                redisplay_start_from,
                                redisplay_number_of_chars,
                                ansi_attrs,
                                window_x1,
                                window_row)
      endif
    else
      if Pos(ANSI_DELETE, ansi_text)
        if  IS_CHR_127_WRONGLY_SIZED
        and font_name <> 'Unifont'
          redisplay_ansi_line_by_uniview(ansi_text, ansi_attrs, window_x1, window_row)
        else
          // Redisplay a cursor line with non-ANSI characters as ANSI only.
          // Ideally the CursorLine extension is present do do it for us,
          // but if not then we do it ourselves.
          if NO_CURSORLINE_EXTENSION
            redisplay_ansi_line_by_tse(ansi_text, ansi_attrs, window_x1, window_row)
          endif
        endif
      endif
    endif
    buffer_line = buffer_line + 1
  endfor
  PopLocation()
end redisplay_window


proc idle_display_non_ansi()
  if window_needs_checking
    if   NumWindows()        == 1
    and (isBlockInCurrFile() in FALSE, _LINE_)
      redisplay_window()
    endif
    window_needs_checking = FALSE
  endif
end idle_display_non_ansi


proc idle_init()
  integer tmp_id = 0
  UnHook(idle_init)
  NO_CURSORLINE_EXTENSION = not isMacroLoaded('CursorLine')
  if isMacroLoaded('Unicode')
    PushLocation()
    tmp_id = CreateTempBuffer()
    LoadBuffer(LoadDir() + 'tseload.dat', -1)
    if  lFind('CursorLine', '^gi$')
    and lFind('Uniview'   , '^i$' )
      if Query(Beep)
        Alarm()
      endif
      MsgBox('Macro Autoload List menu',
             'Uniview must occur higher than CursorLine.')
    endif
    PopLocation()
    AbandonFile(tmp_id)
  else
    Warn('ERROR: Uniview disabled: It requires the Unicode extension.')
    PurgeMacro(CurrMacroFilename())
  endif
end idle_init


proc after_command()
  window_needs_checking = TRUE
end after_command


proc WhenPurged()
  if font_handle
    DeleteObject(font_handle)
  endif
  if device_context_handle
    ReleaseDC(GetWinHandle(), device_context_handle)
  endif
  AbandonFile(ZERO_LENGTH_CODEPOINTS_ID)
end WhenPurged


proc WhenLoaded()
  string  startup_font_name [MAXSTRINGLEN] = ''
  integer startup_font_size                = 0
  integer startup_font_flags               = 0

  MACRO_NAME = SplitPath(CurrMacroFilename(), _NAME_)

  // For this functionality only TSE's start-up values matter!
  // Changing the font or 3D options during a TSE session does not change
  // the ability of non-Unifont fonts to combine characters and to use a
  // fall-through font for characters they not support themselves.
  GetFont(startup_font_name, startup_font_size, startup_font_flags)
  IS_CHR_127_WRONGLY_SIZED =
    not (Query(SpecialEffects) & (_USE_3D_CHARS_ | _USE_3D_BUTTONS_))
  FONT_COMBINES_CHARS_AND_FALLS_THROUGH =
    (IS_CHR_127_WRONGLY_SIZED or startup_font_name == 'Unifont')

  if isGUI()
    prev_SpecialEffects = Query(SpecialEffects)

    if startup_font_name == 'Unifont'
      // The SetOutputDriver() command was introduced after TSE 4.40 and
      // before the introduction of the INTERNAL_VERSION compiler directive
      // in TSE 4.41.44. So the least-bad thing we can do is test for the
      // existence of INTERNAL_VERSION before using SetOutputDriver().
      // We cannot use #ifdef here, because inside an #ifdef old TSE versions
      // still see and raise a compile error for _DRIVER_BMPFONT_.
      #if INTERNAL_VERSION
        SetOutputDriver(_DRIVER_BMPFONT_)
      #endif
    endif

    PushLocation()
    PushBlock()
    ZERO_LENGTH_CODEPOINTS_ID = CreateTempBuffer()
    ChangeCurrFilename(MACRO_NAME + ':zero_length_codepoints',
                       _DONT_PROMPT_|_DONT_EXPAND_|_OVERWRITE_)
    InsertData(combining_and_non_spacing_characters)
    PopLocation()
    PopBlock()


    device_context_handle = GetDC(GetWinHandle())

    Hook(_AFTER_COMMAND_    , after_command)
    Hook(_IDLE_             , idle_display_non_ansi)
    Hook(_IDLE_             , idle_init)
    Hook(_ON_ABANDON_EDITOR_, WhenPurged)
  else
    Warn('ERROR: Uniview requires the GUI version of TSE.')
    PurgeMacro(MACRO_NAME)
  endif
end WhenLoaded


proc Main()
  // Avoid the compiler's complaint about not using these strings.
  textoutw_string_1_257    = textoutw_string_1_257
  textoutw_string_258_514  = textoutw_string_258_514
  textoutw_string_515_771  = textoutw_string_515_771
  textoutw_string_772_1028 = textoutw_string_772_1028

  Warn('The Uniview extension has no executable functionality.')
end Main

