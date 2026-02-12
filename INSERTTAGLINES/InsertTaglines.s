/*
  Macro           InsertTaglines
  Author          Carlo.Hogeveen@xs4all.nl
  Compatibility   TSE Pro 3.0 upwards (Not tested)
  Version         1.0   -   21 Jan 2019

  This macro creates a new file from the current file, where every line
  containing a supplied regular expression is put before itself and
  before every next line that does not contain that regular expression.

  Afterwards you can use existing TSE functionality to search all lines in
  combination with their tag lines, or to sort the now ubiquitous tag lines
  on their columns.

  And after that you can remove the inserted tag lines with a column block
  to get the original file format back.

  For example, with regular expression "Animal:" this macro converts the file
    Animal: lion
    Legs: 4
    Species: mammal
    Animal: spider
    Legs: 8
    Species: insect
    Animal: shark
    Legs: 0
    Species: fish
  into the file
    Animal: lion   Animal: lion
    Animal: lion   Legs: 4
    Animal: lion   Species: mammal
    Animal: spider Animal: spider
    Animal: spider Legs: 8
    Animal: spider Species: insect
    Animal: shark  Animal: shark
    Animal: shark  Legs: 0
    Animal: shark  Species: fish
*/

proc Main()
  string  find_options          [4] = ''
  integer i                         = 0
  integer last_tagline_length       = 0
  integer longest_tagline_length    = 0
  string  macro_name [MAXSTRINGLEN] = SplitPath(CurrMacroFilename(), _NAME_)
  integer old_uap                   = Set(UnMarkAfterPaste, ON)
  string  regexp     [MAXSTRINGLEN] = ''
  Ask('Put lines containing this regular expression before lines without it:',
      regexp,
      GetFreeHistory(macro_name + ':history'))
  if regexp <> ''
    if lFind(regexp, 'gix')
      PushBlock()
      MarkLine(1, NumLines())
      Copy()
      NewFile()
      Paste()
      // First find the longest tag line length
      find_options = 'gix'
      while lFind(regexp, find_options)
        if CurrLineLen() > longest_tagline_length
          longest_tagline_length = CurrLineLen()
        endif
        find_options = 'ix+'
      endwhile
      // Now insert taglines before themselves and consecutive non-taglines
      lFind(regexp, 'gix')
      repeat
        if lFind(regexp, 'cgix')
          last_tagline_length = CurrLineLen()
          MarkColumn(CurrLine(), 1, CurrLine(), CurrLineLen())
          Copy()
        endif
        BegLine()
        Paste()
        GotoColumn(last_tagline_length + 1)
        // This for-loop is lengthy, but also works for taglines > 255.
        // The "+ 1" inserts an extra space after the tagline.
        for i = 1 to (longest_tagline_length - last_tagline_length + 1)
          InsertText(' ', _INSERT_)
        endfor
      until not Down()
      BegFile()
      PopBlock()
    else
      Message('"', regexp, '" not found')
    endif
  endif
  Set(UnMarkAfterPaste, old_uap)
  PurgeMacro(macro_name)
end Main

