===

1. -To install

     1. -Take the file text2html_knud.zip

     2. -And unzip it in any arbitrary directory

     3. -Then run the file zipinstalltext2html.bat

     4. -That will create a new file text2html_knud.zip
         in that directory

     5. -Unzip that latest file in a new arbitrary directory

     6. -Then run the file

          text2html.mac

2. -The .ini file is the local file 'text2html.ini'
    (thus not using tse.ini)

===

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
