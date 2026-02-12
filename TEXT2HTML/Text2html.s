/*
  Macro           Text2html
  Author          Carlo Hogeveen
  Website         ecarlo.nl/tse
  Compatibility   Windows TSE Pro GUI v4.0 upwards with ANSI compatible font.
                  It partially works for other Windows TSE Pro v4 versions.
  Version         v1.2.3   31 Dec 2021


  This tool converts the current buffer's text to an unsaved HTML page
  including TSE's syntax highlighting for at most the first 255 characters
  of each line.

  Afterwards you can copy the <pre> element of the generated HTML page
  to create a syntax highlighted code snippet in a web page.

  After saving the HTML page to an HTML file and opening it in a web browser,
  you can also copy syntax highlighted text from the web browser into an email,
  provided your email client supports the necessary HTML formatting.

  Email receivers with email clients that do not support the necessary HTML
  formatting tend to still see the text, just not syntax highlighted.

  Email clients that supports Text2html's output:
    Outlook (*)
    iOS/iPadOS mail
    Pegasus (**)
    eM Client
    Thunderbird

  (*)
    When pasting Text2html's web browser output into an Outlook message,
    then invisibly under the hood Outlook formats the pasted text one way
    the first time, a different way the second time, and like the second time
    each next time.
    Both ways are valid.
    All email clients show the highlighted text the same way for both ways,
    with a note for Pegasus: see (**).

  (**)
    Pegasus might show a second in Outlook pasted text strangely wrapped.
    A solution is to right-click in the Pegasus message and select either
    "Reformat long lines" or "Wrap long lines".
    These are sticky options: they stay across messages.


  DON'T PANIC!

  In the Windows GUI version of TSE the tool might temporarily maximize TSE's
  window and/or decrease its font size. It will restore these when it is done.


  LIMITATIONS

  Syntax Highlighting Limitation

    The tool works by copying the syntax highlighting from TSE's screen.

    If there are lines longer than TSE's editings window's width, then in
    the GUI version of Windows TSE Pro v4.0 upwards the tool temporarily
    adjusts TSE's window size and/or font size in order to copy more of
    its syntax highlighting for up to 255 characters per line.

    In other TSE versions it does not, and there the copying of syntax
    highlighting is limited to TSE's editing window's width.

  Character Set Limitation

    The tool converts non-ASCII characters to HTML entities ("named
    characters") so that HTML understands them independent of the HTML
    page's character set.

    To do that the tool assumes that TSE's character set is ANSI compatible,
    which is true for the Windows GUI version of TSE Pro v4.0 upwards when it
    uses an ANSI compatible font like its default "Courier New" font.

    For other TSE versions and fonts non-ASCII characters are likely to be
    converted incorrectly, especially for TSE's Console version whatever its
    font.

    See TSE's "ASCII Chart" menu:
    Any characters from 128 upwards are not ASCII characters.


  INSTALLATION

  Copy this file to TSE's "mac" folder and compile it there,
  for example by opening it there in TSE and applying the Macro, Compile menu.


  USAGE

  If you do not use the Windows GUI version of TSE Pro v4.0 upwards with
  an ANSI compatible font and the text has lines longer than TSE's editing
  window's width in characters, then you might beforehand want to
    enlarge or maximize TSE's window,
    or decrease TSE's font size,
    or both.

  Before starting this tool you might want to select a different color scheme
  in TSE; one that better fits the target HTML page or email background color.
  You do no need to save TSE's settings for the new color scheme to work.

  Start this tool either
    by adding "Text2html" to the Potpourri menu, or
    by applying the menu Macro, Execute and entering "Text2html", or
    by assigning ExecMacro("Text2html") to a key.

  When executing the tool as a macro you can case-insensitively add "Style" or
  "Class" as a parameter to skip the corresponding question. For example:
    ExecMacro('Text2html Class')

  Default you get a question whether to generate "Style" or "Class" attributes
  in the HTML.

  If your target is an email or if you do not know how an HTML attribute works
  or if you want to color a snippet independently of other generated snippets,
  then slect the default: "Style".

  "Class" is for example handy when you generate multiple code snippets for the
  same HTML page and you want the option to afterwards manipulate the colors of
  all of them from a single common stylesheet.

  Be aware of the following:
  The style sheet attributes are references to TSE color references,
  not references to colors directly and not references to syntax.
  The tool is a TSE-aware sceen scaper, not a syntax scraper.
  And because TSE has its own layer of color references, this means you need to
  use the same TSE color scheme when generating multiple code snippets.

  In both cases the tool generates an unsaved HTML page.

  When your target is your own HTML page
    Copy the "<pre> ... </pre>" element from the generated HTML page to your
    own HTML page.
    If you chose "Class", then you also once need to copy (the contents of)
    the <style> ... </style> element from the generated HTML page
    into the <head> ... </head> element of your own HTML page.

  When your target is an email
    Save the generated HTML page, open it in a web browser, and copy and paste
    text from the web browser into an email that supports HTML.
    (This was tested with Outlook.)


  EXAMPLE

  See
    https://ecarlo.nl/tse/files/TSE_Pro_v4.4_Undocumented_Features.html

  for how the tool was used with Class attributes to create uniformly
  highlighted code snippets throughout the document.


  TODO
    MUST
      None.
    SHOULD
      Make the tool Linux compatible.
    COULD
      Make the automatic adjustment of window and font size optional.
      Make copying of syntax highlighting optional.
      Make converting non-ASCII characters optional.
    WONT
      None.


  HISTORY

  v0.1     26 Aug 2021
    Only syntax highlights keywords.

  v0.2     27 Aug 2021
    Enhanced the documentation and code structure.

  v0.3     28 Aug 2021
    Supports all syntax highlighting by copying it from TSE's screen.
    Line parts longer than the editing window's width are not highlighted.

  v0.4     29 Aug 2021
    With limitations supports the copying of syntax highlighting for lines that
    are longer than the editing window's width, up to 255 characters.

  v1       30 Aug 2021
    The first release with all the basic functionality I intended, and with no
    known errors.

  v1.1      9 Sep 2021
    Instead of using HTML color names that approximate TSE colors,
    the generated HTML now uses the exact same hexadecimal color values
    as TSE itself uses.

  v1.2     10 Sep 2021
    Added a choice whether to generate "style attributes" or "class attributes
    with a stylesheet" for the HTML colors.

  v1.2.1   11 Sep 2021
    Added a tiny EXAMPLE paragraph to the documentation.

  v1.2.2   25 Dec 2021
    Fixed: The generated HTML contained two opening <div> elements
    instead of an opening <div> and a closing </div>.

  v1.2.3   31 Dec 2021
    Fixed: Now also works if TSE is configured to color the cursor line
    differently than other text lines.
*/





// Start of compatibility restrictions and mitigations



/*
  When compiled with a TSE version below TSE 4.0 the compiler reports
  a syntax error and hilights the first applicable line below.

  There is a beta Linux version of TSE that is not bug-free and in which some
  significant features do not work, but all its Linux versions are above
  TSE 4.0, and they all are 32-bits which is what WIN32 actually signifies.
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



// Note: Bug avoided: TSE < 4.2 would raise an error for using #else here.
#if EDITOR_VERSION < 4200h
  #define FORE_GROUND 1
  #define BACK_GROUND 2
#endif
#if EDITOR_VERSION >= 4200h
  #define FORE_GROUND _FOREGROUND_
  #define BACK_GROUND _BACKGROUND_
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



#if EDITOR_VERSION < 4200h
  // TSE Pro versions < v4.2 cannot use non-standard colors.
  // These are the hexadecimal values for TSE's standard colors.
  string       GetColorTableValue_colors [90] =
    '0 80 8000 8080 800000 800080 808000 C0C0C0 808080 FF FF00 FFFF FF0000 FF00FF FFFF00 FFFFFF'

  integer proc GetColorTableValue(integer tab, integer index)
    // TSE Pro versions < v4.2 cannot use different foreground and background
    // colors, so we ignore the tab parameter.
    integer rgb_color = tab // Dummy assignment to pacify the compiler
    rgb_color = Val(GetToken(GetColorTableValue_colors, ' ', index + 1), 16)
    return(rgb_color)
  end GetColorTableValue
#endif



// End of compatibility restrictions and mitigations.





// Start of Text2html implementation



// Global constants
#define CHANGE_CURR_FILENAME_OPTIONS _DONT_PROMPT_|_DONT_EXPAND_|_OVERWRITE_
#define ANTI_CRASH_DELAY 2

// Global semi-constants (initialized only once)
string MACRO_NAME [MAXSTRINGLEN] = ''

// Global variables
integer convert_non_ascii       = TRUE
integer copy_syntax_hiliting    = TRUE
integer did_decrease_font_size  = FALSE
integer did_maximize_tse_window = FALSE
integer old_font_size           = 0
integer old_window_cols         = 0
integer old_window_rows         = 0
integer old_window_style        = 0


// Start of external Windows function

#if WIN32

  #define SWP_NOSIZE          0x0001
  #define SWP_NOMOVE          0x0002
  #define SWP_NOZORDER        0x0004
  #define SWP_NOREDRAW        0x0008
  #define SWP_NOACTIVATE      0x0010
  #define SWP_FRAMECHANGED    0x0020  /* The frame changed: send WM_NCCALCSIZE */
  #define SWP_SHOWWINDOW      0x0040
  #define SWP_HIDEWINDOW      0x0080
  #define SWP_NOCOPYBITS      0x0100
  #define SWP_NOOWNERZORDER   0x0200  /* Don't do owner Z ordering */
  #define SWP_NOSENDCHANGING  0x0400  /* Don't send WM_WINDOWPOSCHANGING */

  #define SWP_DRAWFRAME       SWP_FRAMECHANGED
  #define SWP_NOREPOSITION    SWP_NOOWNERZORDER

  #define SWP_DEFERERASE      0x2000
  #define SWP_ASYNCWINDOWPOS  0x4000


  #define WM_SYSCOMMAND       0x0112
  #define SC_MINIMIZE         0xF020
  #define SC_MAXIMIZE         0xF030
  #define SC_RESTORE          0xF120

  #define GWL_STYLE           (-16)
  #define WS_CAPTION          0x00C00000      /* WS_BORDER | WS_DLGFRAME  */

  dll "<user32.dll>"
    integer proc SetWindowPos(
      integer handle, // Window handle
      integer place,  // HWND_TOP
      integer x,      // The new position of the left side of the window, in client coordinates.
      integer y,      // The new position of the top of the window, in client coordinates.
      integer cx,     // The new width of the window, in pixels.
      integer cy,     // The new height of the window, in pixels.
      integer flags   // SWP_NOSIZE
      ) : "SetWindowPos"
    integer proc IsMaximized(integer hwnd) : "IsZoomed"
    integer proc GetWindowLong(integer hwnd, integer index) : "GetWindowLongA"
    integer proc SendMessage(integer hwnd, integer msg, integer wparam, integer lparam) : "SendMessageA"
    integer proc SetWindowLong(integer hwnd, integer index, integer value) : "SetWindowLongA"
    integer proc UpdateWindow(integer hwnd)
  end
#endif

// End of external Windows function



string proc get_html_color(integer color_ground, integer color_index)
  string  html_color [MAXSTRINGLEN] = ''
  integer tse_color                 = 0

  /*
  Formerly this tool generated HTML color names, that were close approximations
  of TSE's standard colors.
  These color names were replaced by TSE's actually used RGB color values,
  both because these are exact conversion values, and because as of TSE v4.2
  the editor can deviate from its standard colors.

  case color_index                //  TSE Name
    when 0
      html_color = 'Black'        //  Black
    when 1
      html_color = 'MediumBlue'   //  Blue
    when 2
      html_color = 'ForestGreen'  //  Green
    when 3
      html_color = 'DarkCyan'     //  Cyan
    when 4
      html_color = 'DarkRed'      //  Red
    when 5
      html_color = 'Purple'       //  Magenta
    when 6
      html_color = 'Olive'        //  Yellow
    when 7
      html_color = 'LightGray'    //  White
    when 8
      html_color = 'Gray'         //  Bright/intense Black
    when 9
      html_color = 'Blue'         //  Bright/intense Blue
    when 10
      html_color = 'Lime'         //  Bright/intense Green
    when 11
      html_color = 'Cyan'         //  Bright/intense Cyan
    when 12
      html_color = 'Red'          //  Bright/intense Red
    when 13
      html_color = 'Magenta'      //  Bright/intense Magenta
    when 14
      html_color = 'Yellow'       //  Bright/intense Yellow
    when 15
      html_color = 'White'        //  Bright/intense White
  endcase
  */

  tse_color  = GetColorTableValue(color_ground, color_index)
  html_color = Upper(Format('#', tse_color: 6: '0': 16))

  return(html_color)
end get_html_color

integer proc copy_text_to_work_buffer()
  integer ok                           = TRUE
  string  tmp_dir       [MAXSTRINGLEN] = RemoveTrailingSlash(GetEnvStr('TMP'))
  string  work_filename [MAXSTRINGLEN] = ''

  if FileExists(tmp_dir) & _DIRECTORY_
    // For now we need to retain the file extension!
    work_filename = tmp_dir + '\Tse_' + MACRO_NAME + CurrExt()
    PushBlock()
    MarkLine(1, NumLines())
    NewFile()
    if GetBufferId(work_filename)
      AbandonFile(GetBufferId(work_filename))
    endif
    ChangeCurrFilename(work_filename, CHANGE_CURR_FILENAME_OPTIONS)
    CopyBlock()
    PopBlock()
  else
    Warn("Environment variable TMP does not contain a valid folder.")
    ok = FALSE
  endif
  return(ok)
end copy_text_to_work_buffer

string proc create_html_color_attribute(integer attribute_type,
                                        integer tse_color)
  string html_color_attribute [50] = ''
  if attribute_type == 2
    html_color_attribute =
      Format('class="tse_bg_', tse_color  /  16: 1: '0': 16,
                   ' tse_fg_', tse_color mod 16: 1: '0': 16,
             '"')
  else
    html_color_attribute =
      Format('style="background-color:',
             get_html_color(BACK_GROUND, tse_color  /  16),
             ';color:',
             get_html_color(FORE_GROUND, tse_color mod 16),
             ';"')
  endif
  return(html_color_attribute)
end create_html_color_attribute

proc wrap_text_in_html_page_tags(integer attribute_type, string pre_attribute)
  string  class_name_part [2] = ''
  string  attribute_name [16] = ''
  integer ground              = 0
  integer index               = 0
  BegFile()
  InsertLine('<!DOCTYPE html>')
  AddLine('<html>')
  AddLine('  <head>')

  if attribute_type == 2
    AddLine('    <style>')
    for ground = Min(FORE_GROUND, BACK_GROUND) to Max(FORE_GROUND, BACK_GROUND)
      if (ground in FORE_GROUND, BACK_GROUND)
        attribute_name  = iif(ground == FORE_GROUND, 'color', 'background-color')
        class_name_part = iif(ground == FORE_GROUND, 'fg'   , 'bg')
        for index = 0 to 15
          AddLine(Format('      .tse_',
                         class_name_part,
                         '_',
                         index: 1: '0': 16,
                         ' {',
                         attribute_name,
                         ': ',
                         get_html_color(ground, index),
                         ';}'))
        endfor
      endif
    endfor
    AddLine('    </style>')
  endif

  AddLine('  </head>')
  AddLine('  <body>')
  AddLine('    <div>')
  AddLine('<pre' + pre_attribute + '>')

  EndFile()
  AddLine('</pre>')
  AddLine('    </div>')
  AddLine('  </body>')
  AddLine('</html>')

  BegFile()
end wrap_text_in_html_page_tags

string proc convert_char(string source_char)
  string html_char [8] = source_char

  // Note that StrRepacle() is a slow command,
  // so it pays to avoid it when possible.

  // Convert HTML-overlapping characters to HTML entities (character names)
  if (html_char in '&', '<', '>')
    case html_char
     when '&'
       html_char = StrReplace('&', html_char, '&amp;', '')
     when '<'
       html_char = StrReplace('<', html_char, '&lt;' , '')
     when '>'
       html_char = StrReplace('>', html_char, '&gt;' , '')
    endcase
  endif

  // Convert non-ASCII characters (case sensitively!) to HTML entities
  if convert_non_ascii
    if Asc(html_char) >= 128
      case html_char
        when '€'
          html_char = StrReplace('€', html_char, '&euro;'  , '') // 128

                                                                 // 129 Not ANSI
        when '‚'
          html_char = StrReplace('‚', html_char, '&sbquo;' , '') // 130
        when 'ƒ'
          html_char = StrReplace('ƒ', html_char, '&fnof;'  , '') // 131
        when '„'
          html_char = StrReplace('„', html_char, '&bdquo;' , '') // 132
        when '…'
          html_char = StrReplace('…', html_char, '&hellip;', '') // 133
        when '†'
          html_char = StrReplace('†', html_char, '&dagger;', '') // 134
        when '‡'
          html_char = StrReplace('‡', html_char, '&Dagger;', '') // 135
        when 'ˆ'
          html_char = StrReplace('ˆ', html_char, '&circ;'  , '') // 136
        when '‰'
          html_char = StrReplace('‰', html_char, '&permil;', '') // 137
        when 'Š'
          html_char = StrReplace('Š', html_char, '&Scaron;', '') // 138
        when '‹'
          html_char = StrReplace('‹', html_char, '&lsaquo;', '') // 139
        when 'Œ'
          html_char = StrReplace('Œ', html_char, '&OElig;' , '') // 140

                                                                 // 141 Not ANSI
        when 'Ž'
          html_char = StrReplace('Ž', html_char, '&#x17d;' , '') // 142

                                                                 // 143 Not ANSI

                                                                 // 144 Not ANSI
        when '‘'
          html_char = StrReplace('‘', html_char, '&lsquo;' , '') // 145
        when '’'
          html_char = StrReplace('’', html_char, '&rsquo;' , '') // 146
        when '“'
          html_char = StrReplace('“', html_char, '&ldquo;' , '') // 147
        when '”'
          html_char = StrReplace('”', html_char, '&rdquo;' , '') // 148
        when '•'
          html_char = StrReplace('•', html_char, '&bull;'  , '') // 149
        when '–'
          html_char = StrReplace('–', html_char, '&ndash;' , '') // 150
        when '—'
          html_char = StrReplace('—', html_char, '&mdash;' , '') // 151
        when '˜'
          html_char = StrReplace('˜', html_char, '&tilde;' , '') // 152
        when '™'
          html_char = StrReplace('™', html_char, '&trade;' , '') // 153
        when 'š'
          html_char = StrReplace('š', html_char, '&scaron;', '') // 154
        when '›'
          html_char = StrReplace('›', html_char, '&rsaquo;', '') // 155
        when 'œ'
          html_char = StrReplace('œ', html_char, '&oelig;' , '') // 156

                                                                 // 157 Not ANSI
        when 'ž'
          html_char = StrReplace('ž', html_char, '&#x17e;' , '') // 158
        when 'Ÿ'
          html_char = StrReplace('Ÿ', html_char, '&Yuml;'  , '') // 159
        when ' '
          html_char = StrReplace(' ', html_char, '&nbsp;'  , '') // 160
        when '¡'
          html_char = StrReplace('¡', html_char, '&iexcl;' , '') // 161
        when '¢'
          html_char = StrReplace('¢', html_char, '&cent;'  , '') // 162
        when '£'
          html_char = StrReplace('£', html_char, '&pound;' , '') // 163
        when '¤'
          html_char = StrReplace('¤', html_char, '&curren;', '') // 164
        when '¥'
          html_char = StrReplace('¥', html_char, '&yen;'   , '') // 165
        when '¦'
          html_char = StrReplace('¦', html_char, '&brvbar;', '') // 166
        when '§'
          html_char = StrReplace('§', html_char, '&sect;'  , '') // 167
        when '¨'
          html_char = StrReplace('¨', html_char, '&uml;'   , '') // 168
        when '©'
          html_char = StrReplace('©', html_char, '&copy;'  , '') // 169
        when 'ª'
          html_char = StrReplace('ª', html_char, '&ordf;'  , '') // 170
        when '«'
          html_char = StrReplace('«', html_char, '&laquo;' , '') // 171
        when '¬'
          html_char = StrReplace('¬', html_char, '&not;'   , '') // 172
        when '­'
          html_char = StrReplace('­', html_char, '&shy;'   , '') // 173
        when '®'
          html_char = StrReplace('®', html_char, '&reg;'   , '') // 174
        when '¯'
          html_char = StrReplace('¯', html_char, '&macr;'  , '') // 175
        when '°'
          html_char = StrReplace('°', html_char, '&deg;'   , '') // 176
        when '±'
          html_char = StrReplace('±', html_char, '&plusmn;', '') // 177
        when '²'
          html_char = StrReplace('²', html_char, '&sup2;'  , '') // 178
        when '³'
          html_char = StrReplace('³', html_char, '&sup3;'  , '') // 179
        when '´'
          html_char = StrReplace('´', html_char, '&acute;' , '') // 180
        when 'µ'
          html_char = StrReplace('µ', html_char, '&micro;' , '') // 181
        when '¶'
          html_char = StrReplace('¶', html_char, '&para;'  , '') // 182
        when '·'
          html_char = StrReplace('·', html_char, '&middot;', '') // 183
        when '¸'
          html_char = StrReplace('¸', html_char, '&cedil;' , '') // 184
        when '¹'
          html_char = StrReplace('¹', html_char, '&sup1;'  , '') // 185
        when 'º'
          html_char = StrReplace('º', html_char, '&ordm;'  , '') // 186
        when '»'
          html_char = StrReplace('»', html_char, '&raquo;' , '') // 187
        when '¼'
          html_char = StrReplace('¼', html_char, '&frac14;', '') // 188
        when '½'
          html_char = StrReplace('½', html_char, '&frac12;', '') // 189
        when '¾'
          html_char = StrReplace('¾', html_char, '&frac34;', '') // 190
        when '¿'
          html_char = StrReplace('¿', html_char, '&iquest;', '') // 191
        when 'À'
          html_char = StrReplace('À', html_char, '&Agrave;', '') // 192
        when 'Á'
          html_char = StrReplace('Á', html_char, '&Aacute;', '') // 193
        when 'Â'
          html_char = StrReplace('Â', html_char, '&Acirc;' , '') // 194
        when 'Ã'
          html_char = StrReplace('Ã', html_char, '&Atilde;', '') // 195
        when 'Ä'
          html_char = StrReplace('Ä', html_char, '&Auml;'  , '') // 196
        when 'Å'
          html_char = StrReplace('Å', html_char, '&Aring;' , '') // 197
        when 'Æ'
          html_char = StrReplace('Æ', html_char, '&AElig;' , '') // 198
        when 'Ç'
          html_char = StrReplace('Ç', html_char, '&Ccedil;', '') // 199
        when 'È'
          html_char = StrReplace('È', html_char, '&Egrave;', '') // 200
        when 'É'
          html_char = StrReplace('É', html_char, '&Eacute;', '') // 201
        when 'Ê'
          html_char = StrReplace('Ê', html_char, '&Ecirc;' , '') // 202
        when 'Ë'
          html_char = StrReplace('Ë', html_char, '&Euml;'  , '') // 203
        when 'Ì'
          html_char = StrReplace('Ì', html_char, '&Igrave;', '') // 204
        when 'Í'
          html_char = StrReplace('Í', html_char, '&Iacute;', '') // 205
        when 'Î'
          html_char = StrReplace('Î', html_char, '&Icirc;' , '') // 206
        when 'Ï'
          html_char = StrReplace('Ï', html_char, '&Iuml;'  , '') // 207
        when 'Ð'
          html_char = StrReplace('Ð', html_char, '&ETH;'   , '') // 208
        when 'Ñ'
          html_char = StrReplace('Ñ', html_char, '&Ntilde;', '') // 209
        when 'Ò'
          html_char = StrReplace('Ò', html_char, '&Ograve;', '') // 210
        when 'Ó'
          html_char = StrReplace('Ó', html_char, '&Oacute;', '') // 211
        when 'Ô'
          html_char = StrReplace('Ô', html_char, '&Ocirc;' , '') // 212
        when 'Õ'
          html_char = StrReplace('Õ', html_char, '&Otilde;', '') // 213
        when 'Ö'
          html_char = StrReplace('Ö', html_char, '&Ouml;'  , '') // 214
        when '×'
          html_char = StrReplace('×', html_char, '&times;' , '') // 215
        when 'Ø'
          html_char = StrReplace('Ø', html_char, '&Oslash;', '') // 216
        when 'Ù'
          html_char = StrReplace('Ù', html_char, '&Ugrave;', '') // 217
        when 'Ú'
          html_char = StrReplace('Ú', html_char, '&Uacute;', '') // 218
        when 'Û'
          html_char = StrReplace('Û', html_char, '&Ucirc;' , '') // 219
        when 'Ü'
          html_char = StrReplace('Ü', html_char, '&Uuml;'  , '') // 220
        when 'Ý'
          html_char = StrReplace('Ý', html_char, '&Yacute;', '') // 221
        when 'Þ'
          html_char = StrReplace('Þ', html_char, '&THORN;' , '') // 222
        when 'ß'
          html_char = StrReplace('ß', html_char, '&szlig;' , '') // 223
        when 'à'
          html_char = StrReplace('à', html_char, '&agrave;', '') // 224
        when 'á'
          html_char = StrReplace('á', html_char, '&aacute;', '') // 225
        when 'â'
          html_char = StrReplace('â', html_char, '&acirc;' , '') // 226
        when 'ã'
          html_char = StrReplace('ã', html_char, '&atilde;', '') // 227
        when 'ä'
          html_char = StrReplace('ä', html_char, '&auml;'  , '') // 228
        when 'å'
          html_char = StrReplace('å', html_char, '&aring;' , '') // 229
        when 'æ'
          html_char = StrReplace('æ', html_char, '&aelig;' , '') // 230
        when 'ç'
          html_char = StrReplace('ç', html_char, '&ccedil;', '') // 231
        when 'è'
          html_char = StrReplace('è', html_char, '&egrave;', '') // 232
        when 'é'
          html_char = StrReplace('é', html_char, '&eacute;', '') // 233
        when 'ê'
          html_char = StrReplace('ê', html_char, '&ecirc;' , '') // 234
        when 'ë'
          html_char = StrReplace('ë', html_char, '&euml;'  , '') // 235
        when 'ì'
          html_char = StrReplace('ì', html_char, '&igrave;', '') // 236
        when 'í'
          html_char = StrReplace('í', html_char, '&iacute;', '') // 237
        when 'î'
          html_char = StrReplace('î', html_char, '&icirc;' , '') // 238
        when 'ï'
          html_char = StrReplace('ï', html_char, '&iuml;'  , '') // 239
        when 'ð'
          html_char = StrReplace('ð', html_char, '&eth;'   , '') // 240
        when 'ñ'
          html_char = StrReplace('ñ', html_char, '&ntilde;', '') // 241
        when 'ò'
          html_char = StrReplace('ò', html_char, '&ograve;', '') // 242
        when 'ó'
          html_char = StrReplace('ó', html_char, '&oacute;', '') // 243
        when 'ô'
          html_char = StrReplace('ô', html_char, '&ocirc;' , '') // 244
        when 'õ'
          html_char = StrReplace('õ', html_char, '&otilde;', '') // 245
        when 'ö'
          html_char = StrReplace('ö', html_char, '&ouml;'  , '') // 246
        when '÷'
          html_char = StrReplace('÷', html_char, '&divide;', '') // 247
        when 'ø'
          html_char = StrReplace('ø', html_char, '&oslash;', '') // 248
        when 'ù'
          html_char = StrReplace('ù', html_char, '&ugrave;', '') // 249
        when 'ú'
          html_char = StrReplace('ú', html_char, '&uacute;', '') // 250
        when 'û'
          html_char = StrReplace('û', html_char, '&ucirc;' , '') // 251
        when 'ü'
          html_char = StrReplace('ü', html_char, '&uuml;'  , '') // 252
        when 'ý'
          html_char = StrReplace('ý', html_char, '&yacute;', '') // 253
        when 'þ'
          html_char = StrReplace('þ', html_char, '&thorn;' , '') // 254
        when 'ÿ'
          html_char = StrReplace('ÿ', html_char, '&yuml;'  , '') // 255
      endcase
    endif
  endif
  return(html_char)
end convert_char

proc insert_converted_chars(string s)
  // Conversion to HTML entities of HTML-overlapping and non-ASCII characters.
  string  html_char   [8] = ''
  integer i               = 0
  string  source_char [1] = ''
  for i = 1 to Length(s)
    source_char = s[i]
    html_char   = convert_char(source_char)
    InsertText(html_char, _INSERT_)
  endfor
end insert_converted_chars

proc undo_maximize_tse_window()
  SendMessage(GetWinHandle(), WM_SYSCOMMAND, SC_RESTORE, 0)
  SetWindowLong(GetWinHandle(), GWL_STYLE, old_window_style)
  SetWindowPos(GetWinHandle(),0,0,0,0,0,SWP_NOMOVE|SWP_NOZORDER|SWP_NOSIZE|SWP_DRAWFRAME|SWP_SHOWWINDOW|SWP_NOCOPYBITS)
  SetVideoRowsCols(old_window_rows, old_window_cols)
  UpdateWindow(GetWinHandle())
  did_maximize_tse_window = FALSE
end undo_maximize_tse_window

proc restore_font_size()
  string  font_name [MAXSTRINGLEN] = ''
  integer font_size                = 0
  integer font_flags               = 0
  BegFile()
  Delay(ANTI_CRASH_DELAY)
  UpdateDisplay(_ALL_WINDOWS_REFRESH_)
  Delay(ANTI_CRASH_DELAY)
  font_size = old_font_size
  SetFont(font_name, font_size, font_flags)
  Delay(ANTI_CRASH_DELAY)
end restore_font_size

integer proc decrease_font_size()
  string  font_name [MAXSTRINGLEN] = ''
  integer font_size                = 0
  integer font_flags               = 0
  BegFile()
  Delay(ANTI_CRASH_DELAY)
  UpdateDisplay(_ALL_WINDOWS_REFRESH_)
  Delay(ANTI_CRASH_DELAY)
  GetFont(font_name, font_size, font_flags)
  old_font_size = font_size
  while font_size             > 1
  and   LongestLineInBuffer() > Query(WindowCols)
    font_size = font_size - 1
    Delay(ANTI_CRASH_DELAY)
    SetFont(font_name, font_size, font_flags)
    Delay(ANTI_CRASH_DELAY)
    UpdateDisplay(_ALL_WINDOWS_REFRESH_)
    did_decrease_font_size = TRUE
  endwhile
  Delay(ANTI_CRASH_DELAY)
  return(old_font_size)
end decrease_font_size

proc restore_tse_window()
  if did_decrease_font_size
    restore_font_size()
  endif
  if did_maximize_tse_window
    undo_maximize_tse_window()
  endif
end restore_tse_window

proc adjust_tse_window()
  #if WIN32
    if isGUI()
      if not IsMaximized(GetWinHandle())
        old_window_style = GetWindowLong(GetWinHandle(), GWL_STYLE)
        old_window_rows  = Query(ScreenRows)
        old_window_cols  = Query(ScreenCols)
        SetWindowLong(GetWinHandle(), GWL_STYLE, old_window_style & ~ WS_CAPTION)
        SendMessage(GetWinHandle(), WM_SYSCOMMAND, SC_MAXIMIZE, 0)
        did_maximize_tse_window = TRUE
      endif
      if LongestLineInBuffer() > Query(WindowCols)
        decrease_font_size()
      endif
    endif
  #endif
end adjust_tse_window

proc add_syntax_hiliting(integer attribute_type)
  integer color_attr                      = 0
  string  color_chars      [MAXSTRINGLEN] = ''
  integer color_first_column              = 0
  integer color_first_ns_column           = 0
  integer color_last_column               = 0
  string  color_ns_chars   [MAXSTRINGLEN] = ''
  string  html_color_attribute       [50] = ''
  string  line_attrs       [MAXSTRINGLEN] = ''
  string  line_chars       [MAXSTRINGLEN] = ''
  integer next_column_attr                = 0
  string  next_column_char [MAXSTRINGLEN] = ''
  integer old_CursorAttr                  = 0

  if NumLines()
    PushBlock()
    UnMarkBlock()
    old_CursorAttr = Set(CursorAttr, Query(TextAttr))
    if LongestLineInBuffer() > Query(WindowCols)
      adjust_tse_window()
    endif
    BegFile()
    repeat
      if CurrLineLen()
        BegLine()
        UpdateDisplay(_ALL_WINDOWS_REFRESH_) // Refresh syntax highlighting
        GetStrAttrXY(Query(WindowX1),
                     CurrRow() + Query(WindowY1) - 1,
                     line_chars,
                     line_attrs,
                     Min(CurrLineLen(), Query(WindowCols)))
        // We process a line backwards, so that inserting <span> tags around a
        // backwards discovored same-colored text part does not shift the yet
        // unprocessed text before it, keeping the preceding positions in our
        // stored line usable.
        color_last_column = Length(line_chars)
        while color_last_column > 0
          color_attr         = Asc(line_attrs[color_last_column])
          color_first_column =     color_last_column
          next_column_attr   = Asc(line_attrs[color_first_column - 1])
          next_column_char   =     line_chars[color_first_column - 1]
          while color_first_column > 0
          and   (  next_column_attr == color_attr
                or (   next_column_char == ' '  // Space with same background
                   and next_column_attr / 16 == color_attr / 16 ))
            color_first_column =     color_first_column            - 1
            next_column_attr   = Asc(line_attrs[color_first_column - 1])
            next_column_char   =     line_chars[color_first_column - 1]
          endwhile
          color_chars = line_chars[color_first_column .. color_last_column]
          if color_chars <> Format('':Length(color_chars):' ')  // All spaces
            // The following "start a <span> with a non-space" adjustment is
            // logically not necessary, but to us human readers of HTML code
            // " <span>same-colored string</span>" makes more sense than
            // "<span> same-colored string</span>".
            color_first_ns_column = color_first_column
            while line_chars[color_first_ns_column] == ' '
              color_first_ns_column = color_first_ns_column + 1
            endwhile
            color_ns_chars = line_chars[color_first_ns_column
                                         .. color_last_column]
            GotoColumn(color_first_ns_column)
            DelChar(Length(color_ns_chars))
            html_color_attribute = create_html_color_attribute(attribute_type,
                                                               color_attr)
            InsertText('<span ' + html_color_attribute + '>', _INSERT_)
            insert_converted_chars(color_ns_chars)
            InsertText('</span>', _INSERT_)
          endif
          color_last_column = color_first_column - 1
        endwhile
      endif
    until not Down()
    Set(CursorAttr, old_CursorAttr)
    PopBlock()
    if did_maximize_tse_window
    or did_decrease_font_size
      restore_tse_window()
    endif
  endif
end add_syntax_hiliting

proc Main()
  integer attribute_type                = 0
  string  html_filename  [MAXSTRINGLEN] = ''
  string  macro_cmd_line [MAXSTRINGLEN] = Lower(Trim(Query(MacroCmdLine)))
  string  pre_attribute  [MAXSTRINGLEN] = ''

  if     macro_cmd_line == 'style'
    attribute_type = 1
  elseif macro_cmd_line == 'class'
    attribute_type = 2
  else
    attribute_type =
      MsgBoxEx(
        'Select the attribute type to generate for colors',
        Format('Style: Generate just style attributes.',
               Chr(13),
               '       Recommended for mail and a single web page snippet.',
               Chr(13), Chr(13),
               'Class: Generate class attributes and a style sheet.',
               Chr(13),
               '       Recommended for a web page with many snippets',
               Chr(13),
               '       so colors are maintainable in one place.'),
        '[&Style]; [&Class]')
  endif

  if attribute_type
    if copy_text_to_work_buffer()
      if copy_syntax_hiliting
        add_syntax_hiliting(attribute_type)
        pre_attribute = ' ' + create_html_color_attribute(attribute_type,
                                                          Query(TextAttr))
      endif
      wrap_text_in_html_page_tags(attribute_type, pre_attribute)
      html_filename = SplitPath(CurrFilename(), _DRIVE_|_PATH_|_NAME_) + '.html'
      if GetBufferId(html_filename)
        AbandonFile(GetBufferId(html_filename))
      endif
      ChangeCurrFilename(html_filename, CHANGE_CURR_FILENAME_OPTIONS)
    endif
  endif

  PurgeMacro(MACRO_NAME)
end Main

// Two lines for testing the syntax highlighting of very long lines:
// 456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890
//      10        20        30        40        50        60        70        80        90       100       110       120       130       140       150       160       170       180       190       200       210       220       230       240       250       260       270

proc WhenLoaded()
  MACRO_NAME = SplitPath(CurrMacroFilename(), _NAME_)
end WhenLoaded

// End of Text2html implementation

