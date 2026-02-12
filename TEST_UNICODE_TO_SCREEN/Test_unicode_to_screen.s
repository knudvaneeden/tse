/*
  Macro           Test_unicode_to_screen
  Author          Carlo Hogeveen
  Website         eCarlo.nl/tse
  Compatibility   Windows GUI TSE 4.2 upwards
  Version         1.2.1   30 Mar 2022

  This tool implements a proof of concept of writing Unicode characters to
  the TSE screen. TIts documentation describes the discovered capabilities
  and limitations, and speculates on their usage.

  Past attempts worked imperfectly, because I did not explicitly select a font,
  and default got a proportional font with a different character size.



  WHAT I LEARNED

  - All fonts support a limited amount of Unicode characters.

    - The Windows "CharMap" tool (just run it as an executable) shows which
      characters are part of a font, and if you know part of the character's
      Unicode name, then it lets you search for it.

    - TSE's default font "Courier New", as it appears to me:
      - Is a not-proportial font: All characters have the same width.
      - It includes characters for languages that have an alphabet, like Greek,
        Russian and Arabic, but not Chinese, Japanese and Korean,
      - It does not include emojis.
      - It does include math symbols and line and block drawing characters.
        ( Its drawing characters use Unicode character encoding, not OEM
          character encoding, so it cannot show OEM line and block drawings. )
      - It does not support Unicode's "combining" characters.
        E.g. an "e" folowed by a "combining ’" is shown as two characters "e’".

    - Other fonts
      - Microsoft docs state that Windows no longer supports Unicode-rich fonts.
      - I found the proportial Unicode-rich font "Arial Unicode MS" on 1
        Windows 10 pc, but not on another, so it was probably installed by a
        tool.
        - It includes a huge amount of Unicode characters, including for some
          non-alphabet languages, like Chinese, Japanese, and Korean.
        - Includes a "reduced to two colors" version of emojis.
        - It does support Unicode's "combining" characters.
          E.g. an "e" folowed by a "combining ’" is shown as one "é" character.
        Unfortunately, because it is not a standard Windows font, tools cannot
        default use it.
      - Proportial fonts have a variable charcter width.
        This is probably the reason TSE does not support it.

    - In a standard Windows 10 installation (25 March 2022), Courier New is
      the non-proportional font with the most Unicode characters.

  - About character width and height.
    TSE has a function that reveals its current font's character width and
    height.
    For GUI TSE's default Courier New font that means that this macro can write
    Unicode characters to the screen using character-size-based two-dimensional
    coordinates.
    This does not make sense for the "Arial Unicode MS" font, because its
    characters have a variable width.
    However, it does seem possible for "Arial Unicode MS" to size and position
    it vertically relative to TSE lines.

  - In its alternative way of writing characters to the screen it is possible
    to set the characters background and foreground colors to an RGB color
    value.


  USABILITY (speculative)

  - In GUI TSE using the Courier New font it should be doable to overwrite the
    text in the editing window with Unicode characters where appropriate,
    shifting the rest of the line to the left, because the several ANSI
    characters representing a Unicode character become one Unicode character.

  - But: The macro has no way of knowing which Unicode characters are not in
    the current font, so it will hide their ANSI representation with the font's
    "unknown character" character, which on my system is an empty square.

  - But: This is a problem when editing the current line, because the user
    deleting one Unicode character from the screen should result in deleting
    all its ANSI representation characters from the editing buffer.

  - In theory the above points could also apply to the Arial Unicode MS font,
    IF we do not care about showing the text with a proportional font.
    That is a big IF.

  - Possible solutions include fully implementing this, not implementing it for
    the current line [when not in browse mode], and not implementing it for the
    editing window at all.

  - A completely different and independent option would be, to show a Unicode
    copy of the current editing line at an "unused" location in TSE, e.g. the
    upper or lower main border line, or making a trade-off with the menu line.
    This could use the "Arial Unicode MS" font, which out of TSE's edit window
    context could be used with all its advantages.
    But it is not a standard Windows font, so it would have to be configured
    if it is present.

*/

#ifdef LINUX
  This macro is not Linux compatible
#endif

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

  integer proc SetBkColor(
    integer hdc,
    integer colour)

    // Color has RGB format: 0x00bbggrr. Note the reversed byte order.

  integer proc SetTextColor(
    integer hdc,
    integer colour)

end

integer device_context_handle = 0

string proc ascii_to_utf16le(string s)
  integer i                = 0
  string  r [MAXSTRINGLEN] = ''
  for i = 1 to Length(s)
    r = r + s[i: 1] + Chr(0)
  endfor
  return (r)
end ascii_to_utf16le

string proc utf16be_hexstr_to_utf16le_chrstr(string s)
  integer i                = 0
  integer l                = 0
  string  d [MAXSTRINGLEN] = '' // For debugging
  string  r [MAXSTRINGLEN] = ''
  d = d
  if Length(s) >= 2
    i = Length(s) - 1
    l = 2
  else
    i = 1
    l = Length(s)
  endif
  while l > 0
    r = r + Chr(Val(s[i:l], 16))
    d = Str(Asc(r[Length(r):l]), 16)
    i = i - 2
    if i < 0
      l = 0
    elseif i == 0
      i = 1
      l = 1
    endif
  endwhile
  return(r)
end utf16be_hexstr_to_utf16le_chrstr

proc WhenPurged()
  if isGUI()
    ReleaseDC(GetWinHandle(), device_context_handle)
  endif
end WhenPurged

proc Main()
  integer font_flags               = 0
  integer font_handle              = 0
  integer font_height              = 0
  string  font_name [MAXSTRINGLEN] = ''
  integer font_size                = 0
  integer font_width               = 0
  string  text      [MAXSTRINGLEN] = ''

  if isGUI()
    device_context_handle = GetDC(GetWinHandle())

    // The leading and trailing space are just for clarity.
    text = ascii_to_utf16le(' I ') +
           // utf16be_hexstr_to_utf16le_chrstr('2665') +  // Heart
           utf16be_hexstr_to_utf16le_chrstr('d83d') +  // Smiley part 1/2
           utf16be_hexstr_to_utf16le_chrstr('de02') +  // Smiley part 2/2
           ascii_to_utf16le(' TSE! ')

    GetFont(font_name, font_size, font_flags)
    GetCharWidthHeight(font_width, font_height)

    // Comment setting font_name or not to test Courier New or Arial Unicode MS.
    // Note that Arial Unicode MS does not default exist on Windows computers.
    // font_name = 'Arial Unicode MS'

    // It works counterproductively to request a width for a proportial font.
    if font_name == 'Arial Unicode MS'
      font_width = 0
    endif
    Message(font_name, ','; font_width, ','; font_height, '.')

    font_handle = CreateFontA(font_height,
                              font_width,
                              0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
                              font_name)

    SelectObject(device_context_handle, font_handle)

    SetTextColor(device_context_handle, 0x00ffffff)   // White text.
    SetBkColor  (device_context_handle, 0x00000000)   // Black background.

    TextOutw(device_context_handle,
             10 * font_width,
             10 * font_height,
             AdjPtr(Addr(text), 2),
             Length(text) / 2)

    // Make the screen narrower and test what happens for a longer line.
    text = ascii_to_utf16le('1234567890')
    text = text + text + text + text + text + text + text + text + text + text
    text = ascii_to_utf16le('.') + text

    TextOutw(device_context_handle,
             10 * font_width,
             11 * font_height,
             AdjPtr(Addr(text), 2),
             Length(text) / 2)

    text = ascii_to_utf16le(' Even in English resume should be spelled re') +
           utf16be_hexstr_to_utf16le_chrstr('0301') +  // A combining accent
           ascii_to_utf16le('sume') +
           utf16be_hexstr_to_utf16le_chrstr('0301') +  // A combining accent
           ascii_to_utf16le('. ')

    TextOutw(device_context_handle,
             10 * font_width,
             12 * font_height,
             AdjPtr(Addr(text), 2),
             Length(text) / 2)
  else
    Warn('ERROR: This is not a GUI version of TSE.')
  endif
  PurgeMacro(SplitPath(CurrMacroFilename(), _NAME_))
end Main

