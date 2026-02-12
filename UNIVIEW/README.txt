Created by Carlo Hogeveen (http://ecarlo.nl/tse)

===

1. -To install

     1. -Take the file uniview_knud.zip

     2. -And unzip it in any arbitrary directory

     3. -Then run the file zipinstalluniview.bat

     4. -That will create a new file uniview_knud.zip
         in that directory

     5. -Unzip that latest file in a new arbitrary directory

     6. -Then run the file

          Uniview_main.mac

2. -The .ini file is the local file 'uniview.ini'
    (thus not using tse.ini)

===

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
