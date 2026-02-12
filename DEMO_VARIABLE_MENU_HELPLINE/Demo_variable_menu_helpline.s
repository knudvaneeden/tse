/*
  Macro           Demo_variable_menu_helpline
  Author          Carlo Hogeveen
  Website         eCarlo.nl/tse
  Compatibility   Windows TSE Pro v4.0 upwards
                  Linux TSE ? - v4.41.46 upwards
  Version         v1   22 Dec 2021


  SUMMARY
  According to TSE a menu helpline must be a constant string.
  This macro demonstrates a dirty solution to program a variable menu helpline.
  It works by determing where the menu helpline is physically located in memory
  and reading and modifying it.
  Instructions and helper procedures are provided to implement this.

  DISCLAIMER
  This is highly non-standard solution, and might fail at any time for reasons
  unknown with unknown repercussions.
  Use at your own risk!


  USAGE

  For each menu helpline that must become variable:

  Start by determining a unique string value,
  that will never have other matches in your compiled macro, and
  that is as long as the desired maximum length of the menu helpline.

  In your macro assign the value to a global string (from now referred to as
  <global reference string>), and to the menu helpline.

  Create a global integer (from now referrd to as <global menuline address>)
  that will contain the memory address of the menu helpline.

  Where you initialize your macro use
    get_helpline_address(string  <global reference string>,
                         integer <global helpline address>)
  to determine <global helpline address> based on <global reference string>'s
  value (and implicitly based on that the menu helpline must occur after
  <global reference string>'s position).

  When you have a <global helpline address>,
  then you can use
    string <current helpline> = get_helpline(integer <global helpline address>)
  and
    write_helpline(<global helpline address>, '<new helpline string>')
  to read and write that menu helpline.


  EXAMPLE

  The below macro implements a one option menu that just toggles its helpline.
*/

string  HELPLINE_1_REF_STR [MAXSTRINGLEN] = 'EXMXONYJJ8BKL9FOVAL5CGLGYV97LET4RN3OMNGOSCWMKHLR5TPMD94GMSYQH9WXSJYLXXMA9OMOOEPBXD2LHSUEWFJT1D90DIG631IKH860ROZ5GTOXP032ON23W7LMOV747D8RPB1M2X2OL2HCWXSUHL2VNU8WOVZDWNMC7ME3KIMZO1X9HLFGY0ESU80ZXOQ4C6W740QGG9YNET30EYRCU7XZDTYQFVIC9IPHB3BY73RTO7YLSLM9C4GS0LF'
integer helpline_1_menu_addr              = 0



// Start of variable menu helper functions

proc write_helpline(integer helpline_addr, string new_helpline)
  integer byte_addr        = helpline_addr
  integer max_helpline_len = PeekByte(AdjPtr(helpline_addr, -1))
  integer i                = 0
  if helpline_addr
    for i = 1 to Min(Length(new_helpline), max_helpline_len)
      PokeByte(byte_addr, Asc(new_helpline[i]))
      byte_addr = AdjPtr(byte_addr, 1)
    endfor
    for i = Length(new_helpline) + 1 to max_helpline_len
      PokeByte(byte_addr, 32) // Overwrite old content with trailing spaces.
      byte_addr = AdjPtr(byte_addr, 1)
    endfor
  endif
end write_helpline

string proc get_helpline(integer helpline_addr)
  integer byte_addr                   = helpline_addr
  string  cur_helpline [MAXSTRINGLEN] = ''
  integer helpline_len                = PeekByte(AdjPtr(helpline_addr, -1))
  integer i                           = 0
  if helpline_addr
    for i = 1 to helpline_len
      cur_helpline = cur_helpline + Chr(PeekByte(byte_addr))
      byte_addr    = AdjPtr(byte_addr, 1)
    endfor
  endif
  cur_helpline = RTrim(cur_helpline)
  return(cur_helpline)
end get_helpline

// This proc should not be called directly.
// It is a helper proc for the get_helpline_address proc.
integer proc get_helpline_address_match(integer mem_addr, var string target_str)
  integer byte_addr             = mem_addr
  integer i                     = 0
  integer matched               = TRUE
  string  mem_char         [1] = ''
  string  str_char          [1] = ''
  for i = 1 to Length(target_str)
    mem_char = Chr(PeekByte(byte_addr))
    str_char  = target_str[i]
    if mem_char == str_char
      byte_addr = AdjPtr(byte_addr, 1)
    else
      matched = FALSE
      break
    endif
  endfor
  return(matched)
end get_helpline_address_match

integer proc get_helpline_address(var string  helpline_search_str)
  integer i                  = 0
  integer menu_helpline_addr = 0
  integer search_addr        = 0
  search_addr = Addr(helpline_search_str) + Length(helpline_search_str)
  for i = 1 to 65536
    if get_helpline_address_match(search_addr, helpline_search_str)
      menu_helpline_addr = search_addr
      break
    else
      search_addr = AdjPtr(search_addr, 1)
    endif
  endfor
  return(menu_helpline_addr)
end get_helpline_address

// End of variable menu helper functions



proc toggle_helpline(integer menu_helpline_addr)
  if menu_helpline_addr
    if get_helpline(menu_helpline_addr) == 'Women are better!'
      write_helpline(menu_helpline_addr, 'Men are better!')
    else
      write_helpline(menu_helpline_addr, 'Women are better!')
    endif
  endif
end toggle_helpline

menu main_menu()
  title = 'Main menu'
  history
  'Toggle helpline ...',
    toggle_helpline(helpline_1_menu_addr),,
    'EXMXONYJJ8BKL9FOVAL5CGLGYV97LET4RN3OMNGOSCWMKHLR5TPMD94GMSYQH9WXSJYLXXMA9OMOOEPBXD2LHSUEWFJT1D90DIG631IKH860ROZ5GTOXP032ON23W7LMOV747D8RPB1M2X2OL2HCWXSUHL2VNU8WOVZDWNMC7ME3KIMZO1X9HLFGY0ESU80ZXOQ4C6W740QGG9YNET30EYRCU7XZDTYQFVIC9IPHB3BY73RTO7YLSLM9C4GS0LF'
end main_menu

proc Main()
  helpline_1_menu_addr = get_helpline_address(HELPLINE_1_REF_STR)
  toggle_helpline(helpline_1_menu_addr)
  repeat
    main_menu()
  until Query(Key) == <Escape>
  PurgeMacro(SplitPath(CurrMacroFilename(), _NAME_))
end Main

