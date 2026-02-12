/*
  Macro           SynCase
  Author          Carlo Hogeveen
  Website         eCarlo.nl/tse
  Compatibility   Windows and Linux TSE v4.41.19 upwards
  Version         7.0.1   19 Apr 2022


  INTRO

    Out of the box this TSE extension sets the keywords of TSE's macro language
    to their default Upper, lower, and CamelCase based on TSE's syntax hiliting
    configuration.

    You can enable this for SAL, and configure this for other languages.
    For either you can set non-keyword casing to UPPER or lower case.


  DISCLAIMER 1

    This TSE extension might contain unknown errors and damage your files and
    anything depending on those files.

    Use this TSE extension at your own risk or not at all.


  DISCLAIMER 2

    If you ever set one of TSE's "SyntaxHilite mapping Set" configuration
    options for "Ignore Case" to "On", then setting it back "Off" again will
    not work, and any case-sensitive syntax hiliting definitions are lost.

    This is a TSE design flaw. See this extension's Help for more info.

    SAL is an exception to this irreversability, in that this extension's
    configuration menu can "Set SAL to default case ..." again.

    Note: I have noticed that newer TSE versions do not even come with
          cased SAL syntax hiliting any more.


  QUICK INSTALL

    If your TSE version is lower than TSE v4.41.19, then do not install this
    file, but install the included SynCaseOld instead.

    Otherwise put this file and its auxiliary files in TSE's "mac" folder, open
    this file in TSE, and compile and execute it using the Macro, Compile menu.

    The first time SynCase is run after installing it you get the question:
      "Do you want automatic UPPER/lower/CamelCase for TSE macros?"
    Select "Yes", "OK" the Message, "Escape" the menu, and restart TSE.

    Later you can repeat this choice by executing "SynCase" as a macro and
    selecting "Set SAL to default case ...".


  DETAILED DESCRIPTION

    See: TSE menu -> Macro -> Execute "SynCase" -> Help.


  MAJOR VERSION CHANGE

    In version 7 SynCase's core functionality was rewritten to fix bugs,
    increase performance and accuracy, and extend capabilities.

    However, one capability was downgraded:
      SynCase v7 is no longer compatible with TSE versions before v4.41.19,
      which was released 14 December 2019.
      SynCase v7 increases its performance and accuracy by using TSE v4.41.19's
      new built-in CurrLineMultiLineDelimiterType() function.
      This function cannot be easily and efficiently emulated for older
      versions of TSE.
      Therefore SynCaseOld, which is a v6 version of of SynCase, is available
      for TSE v4 through v.4.41.18.

    Changes for users:
    - Increased performance and accuracy.
    - SynCase now uses all relevant syntax highlighting definitions:
      - Delimiters are now cased too, as if they were keywords.
        For example, in Windows batch scripts "rem" is a to-end-of-line
        delimiter, which can now be cased.
      - SynCase now recognizes quotes and escaped quotes.
        - It fixes Syncase not working after "/*" occurs in a quoted string.
        - It will no longer case a word after an escaped quote when such word
          is therefore still inside the quoted string.
      - SynCase now recognizes the Starting Column of a to-end-of-line
        delimiter.
        For example, in traditional COBOL a "*" character is only a
        to-end-of-line delimiter if it occurs on position 7, which can be
        configured in TSE's syntax hiliting. Using this, SynCase can now not
        case a COBOL comment line, and now does case words after a "*" in
        a COBOL "compute" statement.

    Technical changes:
    - Reindented this macro's source code from tab size 3 to 2.
    - To make SynCase debuggable it needed to be smaller, so two huge blocks
      of text (Sal definitions and Help text) were moved from datadefs to
      external files. The files are compressed, both to make them smaller and
      to prevent a user from arbitrarily changing their "factory" content.
    - Rewrote SynCase's core code, instigated by now using TSE v4.41.19's more
      efficient and accurate built-in CurrLineMultiLineDelimiterType() function.


  HISTORY
    6.0.0     11 jul 2017
      Re-release after major rewrite.
    6.0.1     19 Nov 2018
      Updated the isAutoLoaded() procedure to perform a tiny bit better
      with older TSE versions.

    7.0.0.0 BETA   28 Apr 2021
    - Reindented this macro's source code from tab size 3 to 2.
    - To make SynCase debuggable it needed to be smaller, so I moved two large
      blocks of text (Sal definitions and Help text) from datadefs to external
      files. I compressed the files, both to make them smaller and to prevent
      a user from arbitrarily changing their "factory" content.
    - Fixed Syncase not working after "/*" occurs in a quoted string.
      The technically efficient solution was to completely rewrite this macro's
      syntax_case_the_current_line() proc to use TSE v4.41.19's (14 Dec 2019)
      new, built-in CurrLineMultiLineDelimiterType() function.
    - Delimiters are now cased too, as if they were keywords.
    - SynCase now recognizes escaped quotes.
    - SynCase now recognizes a Starting Column for a to-end-of-line delimiter.
    - Tried to make SynCase compatible with the new sal.syn in TSE v4.41.45
      which wants to support "<" in Sal's syntax hiliting WordSet,
      but Sal.syn, syncfg.si an syncfg2.si are broken in TSE v4.41.45,
      so there is no way to test this until TSE is fixed.

    7.0.0.1 BETA   22 Jan 2022
      Semware fixed syncfg2 in v4.41.46, so I can pick this up again.
      Fixed major bugs in recognizing keywords and non-keywords.

    7.0.0.2 BETA   22 Jan 2022
      Removed superfluous code.

    7.0.0.3 BETA   23 Jan 2022
      Added new SAL keywords to SynCase.def.
      Made SynCase's built-in Help show as a buffer instead of a list.

    7.0.0.4        17 Feb 2022
      Did some final tweaks before release.

    7.0.1          19 Apr 2022
      Bug fix for a reported error, caused by SynCase sloppily using EditFile()
      to create a temporary file, which caused other macros' _ON_CHANGING_FILES_
      hook to be called for the temporary file, which caused havoc.
*/





// Start of compatibility restrictions and mitigations.

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

#if EDITOR_VERSION < 4400h
  /*
    isAutoLoaded() 1.0

    This procedure implements TSE 4.4's isAutoLoaded() function for older TSE
    versions. This procedure differs in that here no parameter is allowed,
    so it can only examine the currently running macro's autoload status.
  */
  integer autoload_id           = 0
  string  file_name_chrset [44] = "- !#$%&'()+,.0-9;=@A-Z[]^_`a-z{}~\d127-\d255"
  integer proc isAutoLoaded()
    string  autoload_name [255] = ''
    string  old_wordset    [32] = Set(WordSet, ChrSet(file_name_chrset))
    integer org_id              = GetBufferId()
    integer result              = FALSE
    if autoload_id
      GotoBufferId(autoload_id)
    else
      autoload_name = SplitPath(CurrMacroFilename(), _NAME_) + ':isAutoLoaded'
      autoload_id   = GetBufferId(autoload_name)
      if autoload_id
        GotoBufferId(autoload_id)
      else
        autoload_id = CreateTempBuffer()
        ChangeCurrFilename(autoload_name, CHANGE_CURR_FILENAME_OPTIONS)
      endif
    endif
    LoadBuffer(LoadDir() + 'tseload.dat')
    result = lFind(SplitPath(CurrMacroFilename(), _NAME_), "giw")
    Set(WordSet, old_wordset)
    GotoBufferId(org_id)
    return(result)
  end isAutoLoaded
#endif


// End of compatibility restrictions and mitigations.





// Start of copied Huffman_Common.inc v1.0.


#ifndef DEBUG
  #define DEBUG FALSE
#endif


#if DEBUG
  /*
    This proc is intended for a typically nameless temporary file.

    It gives the current file a name that:
    - Starts with the macro drive, path and name.
    - If the suffix parameter is not empty,
      then has a suffix "_" plus the suffix parameter.
    - Has a suffix "*" followed by a number that makes the fully qualified name
      unique among TSE buffers and on disk. To do this numbers are tried out
      starting at 1.
    - Has a '.tmp' extension.
  */
  proc huffman_make_tmp_name(string suffix)
    string  fqn [MAXSTRINGLEN] = ''
    integer i                  = 1
    fqn = SplitPath(CurrMacroFilename(), _DRIVE_|_PATH_|_NAME_)
    if suffix <> ''
      fqn = fqn + '_' + suffix
    endif
    fqn = fqn + '*'
    while i < 10000
    and   (  GetBufferId(fqn + Str(i) + '.tmp')
          or FileExists (fqn + Str(i) + '.tmp'))
      i = i + 1
    endwhile
    fqn = fqn + Str(i) + '.tmp'
    ChangeCurrFilename(fqn, CHANGE_CURR_FILENAME_OPTIONS)
  end huffman_make_tmp_name

  proc huffman_preserve_tmp_buffer(integer tmp_id)
    integer org_id = GetBufferId()
    if tmp_id
      GotoBufferId(tmp_id)
      BufferType(_NORMAL_)
      BinaryMode(TRUE)
      FileChanged(FALSE)
      BrowseMode(TRUE)
      GotoBufferId(org_id)
    endif
  end huffman_preserve_tmp_buffer
#endif


/*
  These two global variables implement an 8-bit bit-buffer, that is used across
  calls to huffman_read_bits() and huffman_write_bits().
*/
integer huffman_bits_buffer
integer huffman_bits_mask


string proc huffman_bits_to_bytes(string bits_string)
  integer num_bits           = Length(bits_string)
  integer bits_buffer        = 0
  integer bits_mask          = 256
  string  bytes_string  [32] = ''
  integer i                  = 0
  if bits_string == '0011001101'
    i = i
  endif
  for i = 1 to num_bits
    bits_mask = bits_mask shr 1
    if bits_string[i] == '1'
      bits_buffer = bits_buffer | bits_mask
    endif
    if i mod 8 == 0
    or i == num_bits
      bytes_string = bytes_string + Chr(bits_buffer)
      bits_buffer   = 0
      bits_mask     = 256
    endif
  endfor
  return(bytes_string)
end huffman_bits_to_bytes


string proc huffman_bytes_to_hex(string bytes_string)
  string  hex_codes [MAXSTRINGLEN] = ''
  integer i                        = 0
  for i = 1 to Length(bytes_string)
    hex_codes = hex_codes + Format(Asc(bytes_string[i]): 2: '0': 16)
  endfor
  return(hex_codes)
end huffman_bytes_to_hex


string proc huffman_hex_to_bytes(string hex_codes)
  string  bytes_string [128] = ''
  integer i                  = 0
  for i = 1 to Length(hex_codes) by 2
    bytes_string = bytes_string + Chr(Val(hex_codes[i: 2], 16))
  endfor
  return(bytes_string)
end huffman_hex_to_bytes


integer proc huffman_tree_to_dictionary(    integer tree_id,
                                            string  tree_type,
                                        var integer dictionary_id)
  /*
    Create a character-to-huffman-bits encoding-dictionary from the tree.
  */
  string  bits_string [MAXSTRINGLEN] = ''
  string  bytes_string          [32] = ''
  integer c                          = 0
  integer ok                         = TRUE
  dictionary_id = CreateTempBuffer()
  BinaryMode(TRUE)
  #if DEBUG
    huffman_make_tmp_name(tree_type + '_dictionary')
  #endif

  GotoBufferId(tree_id)
  BegFile()
  repeat
    if GetText(3 + MAXSTRINGLEN, 1) == ''
      c            = CurrChar(1)
      bits_string  = GetText(3, MAXSTRINGLEN)
      bytes_string = huffman_bits_to_bytes(bits_string)
      case tree_type
        when 'encode'
          SetBufferStr(Chr(c) + 'Bytes',
                       huffman_bytes_to_hex(bytes_string),
                       dictionary_id)
          SetBufferInt(Chr(c) + 'NumBits',
                       Length(bits_string),
                       dictionary_id)
        when 'decode'
          SetBufferStr(Chr(Length(bits_string)) + bytes_string,
                       huffman_bytes_to_hex(Chr(c)),
                       dictionary_id)
        otherwise
          Warn('Huffman_common.inc programming error 1.')
          ok = FALSE
      endcase
      #if DEBUG
        AddLine(Format(Chr(c);
                       Length(bits_string):3;
                       bytes_string:-4;
                       bits_string),
                dictionary_id)
      #endif
    else
      Warn('ERROR: Tree too deep.')
      ok = FALSE
    endif
  until not ok
     or not Down()
  return(ok)
end huffman_tree_to_dictionary


// End of copied Huffman_Common.inc v1.0.





// Start of copied Huffman_Decode.inc v1.0.


#ifndef DEBUG
  #define DEBUG FALSE
#endif


integer proc huffman_read_bits(    integer source_id,
                                   integer num_bits,
                               var integer bits_buffer_out)
  integer bits_mask_out  = 256
  integer i              = 0
  integer start_of_file  = iif(huffman_bits_mask, FALSE, TRUE)
  integer ok             = TRUE
  integer org_id         = GetBufferId()
  bits_buffer_out = 0
  while ok
  and   i < num_bits
    i = i + 1
    huffman_bits_mask = huffman_bits_mask shr 1
    if huffman_bits_mask == 0
      huffman_bits_mask = 128
      GotoBufferId(source_id)
      repeat
        if start_of_file
          start_of_file = FALSE
        else
          ok = NextChar()
        endif
      until not ok
         or CurrChar() <> _AT_EOL_
      if ok
        huffman_bits_buffer = CurrChar()
      else
        Warn('ERROR: Trying to read more characters than available in encoded buffer.')
      endif
      GotoBufferId(org_id)
    endif
    if ok
      bits_mask_out = bits_mask_out shr 1   // Never more than 8 bits total.
      if huffman_bits_buffer & huffman_bits_mask
        bits_buffer_out = bits_buffer_out | bits_mask_out
      endif
    endif
  endwhile
  return(ok)
end huffman_read_bits


integer proc huffman_decode(integer output_binary_mode)
  integer bit                         = 0
  integer bits_buffer                 = 0
  integer bits_mask                   = 0
  string  bytes_string           [32] = ''
  integer c                           = 0
  integer counted_num_chars           = 0
  integer counted_num_nodes           = 0
  string  dictionary_key         [33] = ''
  string  dictionary_value        [2] = ''
  integer dictionary_id               = 0
  integer direction                   = 0
  integer expected_num_chars          = 0
  integer expected_num_nodes          = 0
  integer input_id                    = GetBufferId()
  integer lines_to_long_warning_given = FALSE
  integer loop_count                  = TRUE
  integer node_type                   = 0
  integer ok                          = TRUE
  integer output_id                   = 0
  integer prev_char_was_13            = FALSE
  integer read_num_bits               = 0
  integer show_all_messages           = (Query(MsgLevel) == _ALL_MESSAGES_)
  integer tree_id                     = 0
  integer tree_level                  = 0
  string  tree_pos     [MAXSTRINGLEN] = ''

  if  show_all_messages
  and NumLines() >= 10000
    KeyPressed()
    Message('Huffman decoding ...')
    KeyPressed()
  endif

  /*
    Save the editor's state.
  */
  PushLocation()

  /*
    Create and initialize an output buffer.
  */
  output_id = NewFile()
  BinaryMode(output_binary_mode)
  SetUndoOff()

  /*
    Get the input buffer's number of tree nodes and buffer characters.
  */
  GotoBufferId(input_id)
  BegFile()
  expected_num_nodes =   CurrChar(1) * 256      + CurrChar(2)
  expected_num_chars =   CurrChar(3) * 16777216 + CurrChar(4) * 65536
                       + CurrChar(5) * 256      + CurrChar(6)

  /*
    Initialize the global bit buffer before reading the bitstream-encoded tree
    from the input buffer.
  */
  huffman_bits_buffer = 0
  huffman_bits_mask   = 0

  /*
    Read the bitstream-encoded tree from the input buffer
    and write it to a plain text tree buffer.
  */
  tree_id = CreateTempBuffer()
  #if DEBUG
    huffman_make_tmp_name('decode_tree')
  #endif

  GotoBufferId(input_id)
  BegFile()
  GotoPos(7)
  while loop_count        < 10000
  and   counted_num_nodes < expected_num_nodes
    loop_count = loop_count + 1
    ok         = huffman_read_bits(input_id, 1, direction)
    if direction    // 1 is down towards the leaves, 0 is up towards the root.
      counted_num_nodes = counted_num_nodes + 1
      tree_pos = tree_pos + iif(GetBufferInt(Str(tree_level), tree_id), '1', '0')
      SetBufferInt(Str(tree_level), TRUE, tree_id)
      ok = huffman_read_bits(input_id, 1, node_type)
      if node_type  // 1 is a leaf node, 0 is a parent node.
        ok = huffman_read_bits(input_id, 8, c)
        AddLine(Format(Chr(c); tree_pos), tree_id)
        tree_pos = tree_pos[1: Length(tree_pos) - 1]
      else
        tree_level = tree_level + 1
      endif
    else
      tree_pos = tree_pos[1: Length(tree_pos) - 1]
      SetBufferInt(Str(tree_level), 0, tree_id)
      tree_level = tree_level - 1
    endif
  endwhile

  if loop_count == 10000
    Warn('ERROR: Too large dictionary.')
    ok = FALSE
  endif

  /*
    Create a huffman-bits-to-character decoding dictionary from the tree.
  */
  if ok
    ok = huffman_tree_to_dictionary(tree_id,
                                    'decode',
                                    dictionary_id)
  endif

  /*
    Decode the content-part of the input buffer to the output buffer.
  */
  if ok
    GotoBufferId(input_id)
    if  show_all_messages
    and NumLines() >= 10000
      KeyPressed()
      Message('Huffman decoding 0 %')
      KeyPressed()
    endif
    repeat  // Loop for each character
      bytes_string  = ''
      bits_mask     = 256
      bits_buffer   = 0
      read_num_bits = 0
      repeat  // Loop for each bit
        bits_mask = bits_mask shr 1
        if bits_mask == 0
          bytes_string = bytes_string + Chr(bits_buffer)
          bits_mask    = 128
          bits_buffer  = 0
        endif
        ok = huffman_read_bits(input_id, 1, bit)
        if bit
          bits_buffer = bits_buffer | bits_mask
        endif
        read_num_bits    = read_num_bits + 1
        dictionary_key   = Chr(read_num_bits) + bytes_string + Chr(bits_buffer)
        dictionary_value = GetBufferStr(dictionary_key, dictionary_id)
        if dictionary_value <> ''
          counted_num_chars = counted_num_chars + 1
          c = Asc(huffman_hex_to_bytes(dictionary_value))
          if c in 10, 13
            if  show_all_messages
            and CurrLine() mod 10000 == 0
              KeyPressed()
              Message('Huffman decoding'; CurrLine() / (NumLines() / 100); '%')
              KeyPressed()
            endif
          endif
          GotoBufferId(output_id)
          if output_binary_mode
            if CurrPos() > 64
              AddLine()
              BegLine()
            endif
            InsertText(Chr(c), _INSERT_)
          else
            if     c == 13
              AddLine()
              BegLine()
              prev_char_was_13 = TRUE
            elseif c == 10
              if not prev_char_was_13
                AddLine()
                BegLine()
              endif
              prev_char_was_13 = FALSE
            else
              if CurrPos() == MAXLINELEN
                InsertText(Chr(c), _INSERT_)
                AddLine()
                BegLine()
                if Query(MsgLevel) == _ALL_MESSAGES_
                and not lines_to_long_warning_given
                  Warn('Line(s) too long')  // ok remains TRUE.
                  lines_to_long_warning_given = TRUE
                endif
              else
                InsertText(Chr(c), _INSERT_)
              endif
              prev_char_was_13 = FALSE
            endif
          endif
          GotoBufferId(input_id)
        endif
      until not ok
         or read_num_bits > 256
         or dictionary_value <> ''
      if read_num_bits > 256
        Warn('ERROR: Bits to decode not recognized.')
        ok = FALSE
      endif
    until not ok
       or counted_num_chars >= expected_num_chars
  endif

  /*
    If we decoded the whole input buffer, then its cursor should be on the last
    character of the last line.
  */
  if ok
    GotoBufferId(input_id)
    if  show_all_messages
    and NumLines() >= 10000
      KeyPressed()
      Message('Huffman decoding 100 %')
      KeyPressed()
    endif
    if CurrLine()              <> NumLines()
    or CurrChar(CurrPos() + 1) <> _AT_EOL_
      Warn('ERROR: Decoding the input buffer was not completed.')
      ok = FALSE
    endif
  endif

  /*
    End decoding with the editor in an appropriate state.
  */
  PopLocation()
  if ok
    GotoBufferId(output_id)
    BegFile()
    SetUndoOn()
  else
    #if not DEBUG
      AbandonFile(output_id)
    #endif
  endif

  #if DEBUG
    huffman_preserve_tmp_buffer(dictionary_id)
    huffman_preserve_tmp_buffer(tree_id)
  #else
    AbandonFile(dictionary_id)
    AbandonFile(tree_id)
  #endif

  return(ok)
end huffman_decode


// End of copied Huffman_Decode.inc v1.0.




// SynCase global constants and variables

#define CHANGE_CURR_FILENAME_OPTIONS _DONT_PROMPT_|_DONT_EXPAND_|_OVERWRITE_
#define SPACE                        32

integer hlp_id                                 = 0
string  init_ext                          [29] = 'non eksisting file eksension'
integer keywords_id                            = 0
string  macro_name              [MAXSTRINGLEN] = ''
integer main_clockticks                        = 0
string  mapping_name            [MAXSTRINGLEN] = 'non eksisting syntaks name'
integer max_syn_name_len                       = 0
string  menu_mapping_name       [MAXSTRINGLEN] = ''
integer prev_BufferId                          = 0
string  prev_uncased_keyword    [MAXSTRINGLEN] = ''
integer prev_line                              = 0
integer prev_pos                               = 0
integer restart_main_menu                      = FALSE
integer syncase_id                             = 0
integer variables_id                           = 0
integer whenloaded_clockticks                  = 0

string  syncase_ext                       [255] = ''
string  keyword_casing                      [4] = ''
string  non_keyword_casing                  [6] = ''
string  syncase_WordSet                    [32] = ''
string  syncase_MultiLineDelimited1_from  [255] = ''
string  syncase_MultiLineDelimited1_to    [255] = ''
string  syncase_MultiLineDelimited2_from  [255] = ''
string  syncase_MultiLineDelimited2_to    [255] = ''
string  syncase_MultiLineDelimited3_from  [255] = ''
string  syncase_MultiLineDelimited3_to    [255] = ''
string  syncase_SingleLineDelimited1_from [255] = ''
string  syncase_SingleLineDelimited1_to   [255] = ''
string  syncase_SingleLineDelimited2_from [255] = ''
string  syncase_SingleLineDelimited2_to   [255] = ''
string  syncase_SingleLineDelimited3_from [255] = ''
string  syncase_SingleLineDelimited3_to   [255] = ''
string  syncase_TillEol1                  [255] = ''
string  syncase_TillEol2                  [255] = ''
string  syncase_TillEol3                  [255] = ''
integer syncase_TillEolstartcol1                = 0
integer syncase_TillEolstartcol2                = 0
integer syncase_TillEolstartcol3                = 0
string  syncase_Quote1                    [255] = ''
string  syncase_Quote2                    [255] = ''
string  syncase_Quote3                    [255] = ''
string  syncase_QuoteEscape1                [1] = ''
string  syncase_QuoteEscape2                [1] = ''
string  syncase_QuoteEscape3                [1] = ''


Keydef help_copy_key
  <Grey+> Copy()
end help_copy_key

string proc unformat(string bracketed)
  string result[255] = bracketed
  while SubStr(result, 1, 1)              in '(', ')', '.', ',', ':', ';'
    result = SubStr(result, 2, Length(result))
  endwhile
  while SubStr(result, Length(result), 1) in '(', ')', '.', ',', ':', ';'
    result = SubStr(result, 1, Length(result) - 1)
  endwhile
  return(result)
end unformat

proc SynCaseSal()
  integer def_id                      = 0
  string  def_word     [MAXSTRINGLEN] = ''
  integer hlp_tmp_id                  = 0
  string  hlp_word     [MAXSTRINGLEN] = ''
  integer ok                          = TRUE
  string  old_wordset            [32] = Query(WordSet)
  integer org_id                      = GetBufferId()
  string  sal_syn_file [MAXSTRINGLEN] = LoadDir() + 'synhi' + SLASH + 'sal.syn'
  integer sal_syn_id                  = 0
  integer sal_syn2_id                 = 0
  string  sal_txt_file [MAXSTRINGLEN] = LoadDir() + 'synhi' + SLASH + 'sal.txt'
  integer sal_txt_id                  = 0
  string  sal_txt_word [MAXSTRINGLEN] = ''
  PushBlock()
  if not FileExists(sal_syn_file)
    ok = FALSE
    Warn(macro_name, ' error: Cannot find file: ', sal_syn_file)
  endif
  if ok and GetBufferId(sal_syn_file)
    AbandonFile(GetBufferId(sal_syn_file))
  endif
  if ok and GetBufferId(SplitPath(sal_syn_file, _NAME_|_EXT_))
    AbandonFile(GetBufferId(SplitPath(sal_syn_file, _NAME_|_EXT_)))
  endif
  if ok and GetBufferId(sal_txt_file)
    AbandonFile(GetBufferId(sal_txt_file))
  endif
  if ok and GetBufferId(SplitPath(sal_txt_file, _NAME_|_EXT_))
    AbandonFile(GetBufferId(SplitPath(sal_txt_file, _NAME_|_EXT_)))
  endif
  if ok
    sal_syn_id = EditBuffer(sal_syn_file, _SYSTEM_, -2)
    if sal_syn_id
      ChangeCurrFilename('sal.syn', CHANGE_CURR_FILENAME_OPTIONS)
    else
      ok = FALSE
      Warn(macro_name, ' error: Cannot open file (in binary mode): ', sal_syn_file)
    endif
  endif
  if ok
    if Lower(SplitPath(CurrFilename(), _NAME_|_EXT_)) <> 'sal.syn'
    or BinaryMode() <> -2
      ok = FALSE
      Warn(macro_name, ' error: Loaded file wrong: ', sal_syn_file,
           ', BinaryMode=', BinaryMode(), ', CurrFileName=', CurrFilename(), '.')
    endif
  endif
  if ok
    ExecMacro('SynCfg2')
    if Lower(CurrFilename()) == 'sal.txt'
      sal_txt_id = GetBufferId()
    else
      ok = FALSE
      Warn(macro_name, ' error: Cannot convert sal.syn to sal.txt.')
    endif
  endif
  /*
    Set the syntaxhiliting variable "IgnoreCaseOfKeyWords" to FALSE.
  */
  if ok
    if lFind('IgnoreCaseOfKeyWords=', '^gi')
      lReplace('TRUE', 'FALSE', 'ci1')
    else
      ok = FALSE
      Warn(macro_name, ' error: Cannot Find IgnoreCaseOfKeyWords in sal.syn.')
    endif
  endif
  /*
    Set the syntax hiliting WordSet.
  */
  if  ok
  and lFind('WordSet=', '^gi')
    old_wordset = Set(WordSet, ChrSet(GetText(9, MAXSTRINGLEN)))
  endif
  /*
    Set keywords known to this macro to a fixed predefined casing.

    This gives us a solid basis.
    Firstly this reasonably ensures, that the about a quarter of all keywords,
    that are not defined as either a Help topic or a constant, are cased too.
    Secondly, while I currently do not know of any problem, past experience
    makes me consider the retrieving of keywords from Help topics a weak point.
    if that ever should fail, then this basis remains.
  */
  if ok
    def_id = CreateTempBuffer()
    if LoadBuffer(SplitPath(CurrMacroFilename(), _DRIVE_|_PATH_|_NAME_) + '.def', 64)
      if  huffman_decode(FALSE)
      and GetBufferId() <> def_id
        AbandonFile(def_id)
        def_id = GetBufferId()
        BegFile()
        repeat
          def_word = GetWord()
          if Length(def_word) > 0
            GotoBufferId(sal_txt_id)
            if lFind('[Keywords', '^gi')
              while lFind(def_word, 'iw')
                if          def_word <> GetWord()
                and EquiStr(def_word,   GetWord())
                  InsertText(def_word, _OVERWRITE_)
                else
                  Right(Max(1, Length(GetWord())))
                endif
              endwhile
            endif
            GotoBufferId(def_id)
          endif
        until not WordRight()
      else
        Warn(macro_name; 'error decoding .def file.')
        ok = FALSE
      endif
    else
      Warn(macro_name; 'error loading .data file.')
      ok = FALSE
    endif
    GotoBufferId(sal_txt_id)
    AbandonFile(def_id)
  endif
  /*
    Case keywords that are defined as a Help topic to their there defined case.

    This (re)cases keywords as defined in your specific (future?) TSE Version.
  */
  if ok
    if lFind('[KeyWords', '^gi')
      hlp_tmp_id = CreateTempBuffer()
      GotoBufferId(sal_txt_id)
      Enable(help_copy_key)
      BufferVideo()
      repeat
        sal_txt_word = GetWord()
        if  CurrPos()            > 1
        and Length(sal_txt_word) > 0
        and Upper(sal_txt_word) <> Lower(sal_txt_word)
        and (      (Lower(SubStr(sal_txt_word, 1, 1)) in 'a' .. 'z')
            or (          SubStr(sal_txt_word, 1, 1)  == '#'
               and (Lower(SubStr(sal_txt_word, 2, 1)) in 'a' .. 'z')))
          PushKey(<Escape>)
          PushKey(<Grey+>)
          Help(sal_txt_word)
          GotoBufferId(hlp_tmp_id)
          EmptyBuffer()
          Paste()
          UnMarkBlock()
          if not lFind("Topic '" + sal_txt_word + "' not found", "gi")
            lFind("[~ \d009]", "gx")
            hlp_word = unformat(GetWord())
            GotoBufferId(sal_txt_id)
            if          hlp_word <> sal_txt_word
            and EquiStr(hlp_word,   sal_txt_word)
              InsertText(hlp_word, _OVERWRITE_)
            endif
          else
            GotoBufferId(sal_txt_id)
          endif
        endif
        Message("Examining TSE's Help topics for casing for keywords   ",
                CurrLine() * 100 / NumLines(), ' %')
      until not WordRight()
      UnBufferVideo()
      Disable(help_copy_key)
      AbandonFile(hlp_tmp_id)
    else
      ok = FALSE
      Warn(macro_name, ' error: Cannot Find KeyWords[0-9] in sal.syn.')
    endif
  endif
  /*
    Define "break" as Lower case.

    SAL contains both the "Break()" function and the "break" statement.
    Syntax hiliting and casing can support only one hiliting and casing
    for both meanings.
    Only the break() function has a Help topic with the same name,
    so "break" would always become camel cased to "Break".
    However, research shows that the break statement is used way more
    than the break() function, so here we overrule the casing for this
    exceptional keyword to Lower case.
  */
  if ok
    if lFind('break', 'giw')
      InsertText('break', _OVERWRITE_)
    endif
  endif
  if ok
    // sal_txt_id is still the current file.
    AbandonFile(sal_syn_id)
    // Add a dummy line to negate an erroneous Undo() by SynCfg2 after the
    // conversion. The conversion goes OK, but afterwords undoing the last
    // change in the text is confusing when debugging.
    EndFile()
    AddLine()
    BegFile()
    Set(WordSet, old_wordset)
    ExecMacro('SynCfg2')
    if Lower(CurrFilename()) == 'sal.syn'
      sal_syn2_id = GetBufferId()
    else
      ok = FALSE
      Warn(macro_name, ' error: Cannot convert sal.txt to sal.syn.')
    endif
  endif
  if ok
    // warn('DEBUG 2:'; currfilename(); binarymode(); sal_syn_file)
    if not SaveAs(sal_syn_file, _OVERWRITE_|_DONT_PROMPT_)
      ok = FALSE
      Warn(macro_name, ' error: Cannot save: ', sal_syn_file)
    endif
  endif
  if ok
    GotoBufferId(org_id)
    UpdateDisplay()
    AbandonFile(sal_txt_id)
    AbandonFile(sal_syn2_id)
    Warn('DONE. Restart TSE for the new settings to take effect.',
         Chr(13), Chr(13),
         'The syntax hiliting keywords of the Semware Application Language (SAL)',
         Chr(13),
         'have been set to their default UPPER, lower, and CamelCase.')
  endif
  Set(WordSet, old_wordset)
  PopBlock()
  UpdateDisplay()
end SynCaseSal

integer proc end_line()
  integer old_RemoveTrailingWhite = Set(RemoveTrailingWhite, OFF)
  integer result                  = TRUE
  result = EndLine()
  Set(RemoveTrailingWhite, old_RemoveTrailingWhite)
  return(result)
end end_line



/*
  Assumption that should logically always be TRUE:
    for a given syntax the variables buffer and keywords buffer
    exist either both or neither.
  So we never have to do syncfg2 separately for variables and keywords.
*/
proc set_current_syntax()
  string  line               [MAXSTRINGLEN] = ''
  string  needed_mapping_name[MAXSTRINGLEN] = ''
  string  old_wordset                  [32] = Query(WordSet)
  integer org_id                            = GetBufferId()
  string  synfile_fqn        [MAXSTRINGLEN] = ''
  integer synfile_id                        = 0
  integer synfile_txt_id                    = 0
  string  value              [MAXSTRINGLEN] = ''
  string  variable           [MAXSTRINGLEN] = ''
  string  word               [MAXSTRINGLEN] = ''

  syncase_ext          = CurrExt()
  synfile_fqn          = GetSynFilename()
  needed_mapping_name  = SplitPath(synfile_fqn, _NAME_)
  if mapping_name <> needed_mapping_name
    mapping_name = needed_mapping_name
    variables_id = GetBufferId(macro_name + ':variables:' + mapping_name)
    keywords_id  = GetBufferId(macro_name + ':keywords:'  + mapping_name)
    if not variables_id
      variables_id = CreateBuffer(macro_name + ':variables:' + mapping_name, _SYSTEM_)
      keywords_id  = CreateBuffer(macro_name + ':keywords:'  + mapping_name, _SYSTEM_)
      if synfile_fqn <> ''

//      synfile_id = EditFile('-b-2 ' + QuotePath(synfile_fqn), _DONT_PROMPT_)
        synfile_id = EditBuffer(synfile_fqn, _SYSTEM_, -2)
        AbandonFile(GetBufferId(synfile_fqn))
        ChangeCurrFilename(synfile_fqn, CHANGE_CURR_FILENAME_OPTIONS)
        if  synfile_id
        and NumLines()
        and CurrFilename() == synfile_fqn

          PushBlock()   // Might be redundant, not 100% sure.
          ExecMacro("syncfg2")
          PopBlock()
          synfile_txt_id = GetBufferId()
          if synfile_txt_id <> synfile_id
            // Fill the variables buffer for the new mapping set.
            BegFile()
            repeat
              AddLine(GetText(1, MAXSTRINGLEN), variables_id)
            until not Down()
               or EquiStr(GetText(1, 9), '[keywords')
            /*
            // Set the current .syn file's syntax hiliting wordset.
            GotoBufferId(variables_id)
            if lFind('wordset=', '^gi')
              old_wordset = Set(WordSet, ChrSet(GetText(9, MAXSTRINGLEN)))
            endif
            */
            // No, set the wordset to anything except the space character.
            old_wordset = Set(WordSet, ChrSet('~ '))
            // Fill the keywords buffer for the current mapping Set.
            while WordRight()
              word = GetWord()
              if              word     <> ''
              and not EquiStr(word[1: 9], '[KeyWords')
                AddLine(word, keywords_id)
              endif
            endwhile
            Set(WordSet, old_wordset)
            GotoBufferId(synfile_id)
            AbandonFile(synfile_txt_id)
          endif
          GotoBufferId(org_id)
          AbandonFile(synfile_id)
        endif
      endif
      GotoBufferId(org_id)
    endif
    if variables_id
      // Set default variable values
      keyword_casing                   = 'off'
      non_keyword_casing               = 'none'
      syncase_WordSet                  = Query(WordSet)
      syncase_MultiLineDelimited1_from = ''
      syncase_MultiLineDelimited1_to   = ''
      syncase_MultiLineDelimited2_from = ''
      syncase_MultiLineDelimited2_to   = ''
      syncase_MultiLineDelimited3_from = ''
      syncase_MultiLineDelimited3_to   = ''
      syncase_SingleLineDelimited1_from= ''
      syncase_SingleLineDelimited1_to  = ''
      syncase_SingleLineDelimited2_from= ''
      syncase_SingleLineDelimited2_to  = ''
      syncase_SingleLineDelimited3_from= ''
      syncase_SingleLineDelimited3_to  = ''
      syncase_TillEol1                 = ''
      syncase_TillEol2                 = ''
      syncase_TillEol3                 = ''
      syncase_TillEolstartcol1         = 0
      syncase_TillEolstartcol2         = 0
      syncase_TillEolstartcol3         = 0
      syncase_Quote1                   = ''
      syncase_Quote2                   = ''
      syncase_Quote3                   = ''
      syncase_QuoteEscape1             = ''
      syncase_QuoteEscape2             = ''
      syncase_QuoteEscape3             = ''
      // Get variable values from syntax hiliting definitions.
      GotoBufferId(variables_id)
      BegFile()
      repeat
        line     = GetText(1, MAXSTRINGLEN)
        variable = GetToken(line, '=', 1)
        value    = GetToken(line, '=', 2)
        case Lower(variable)
          when Lower('WordSet'             ) syncase_WordSet                   =   ChrSet(value)
          when Lower('MultiLineDelimited1' ) syncase_MultiLineDelimited1_from  = GetToken(value, ' ', 1)
                                             syncase_MultiLineDelimited1_to    = GetToken(value, ' ', 2)
          when Lower('MultiLineDelimited2' ) syncase_MultiLineDelimited2_from  = GetToken(value, ' ', 1)
                                             syncase_MultiLineDelimited2_to    = GetToken(value, ' ', 2)
          when Lower('MultiLineDelimited3' ) syncase_MultiLineDelimited3_from  = GetToken(value, ' ', 1)
                                             syncase_MultiLineDelimited3_to    = GetToken(value, ' ', 2)
          when Lower('SingleLineDelimited1') syncase_SingleLineDelimited1_from = GetToken(value, ' ', 1)
                                             syncase_SingleLineDelimited1_to   = GetToken(value, ' ', 2)
          when Lower('SingleLineDelimited2') syncase_SingleLineDelimited2_from = GetToken(value, ' ', 1)
                                             syncase_SingleLineDelimited2_to   = GetToken(value, ' ', 2)
          when Lower('SingleLineDelimited3') syncase_SingleLineDelimited3_from = GetToken(value, ' ', 1)
                                             syncase_SingleLineDelimited3_to   = GetToken(value, ' ', 2)
          when Lower('TillEol1'            ) syncase_TillEol1                  =          value
          when Lower('TillEol2'            ) syncase_TillEol2                  =          value
          when Lower('TillEol3'            ) syncase_TillEol3                  =          value
          when Lower('TillEolstartcol1'    ) syncase_TillEolstartcol1          =      Val(value)
          when Lower('TillEolstartcol2'    ) syncase_TillEolstartcol2          =      Val(value)
          when Lower('TillEolstartcol3'    ) syncase_TillEolstartcol3          =      Val(value)
          when Lower('Quote1'              ) syncase_Quote1                    =          value
          when Lower('Quote2'              ) syncase_Quote2                    =          value
          when Lower('Quote3'              ) syncase_Quote3                    =          value
          when Lower('QuoteEscape1'        ) syncase_QuoteEscape1              =          value
          when Lower('QuoteEscape2'        ) syncase_QuoteEscape2              =          value
          when Lower('QuoteEscape3'        ) syncase_QuoteEscape3              =          value
        endcase
      until not Down()
      // Extend and overrule variable values from profile definitions.
      LoadProfileSection(macro_name + ':' + mapping_name)
      while GetNextProfileItem(variable, value)
        case Lower(variable)
          when Lower('keyword_casing'      ) keyword_casing                    = Lower   (value)
          when Lower('non_keyword_casing'  ) non_keyword_casing                = Lower   (value)
          // xx Why am I getting and overruling the following variables from
          //    the profile?
          when Lower('WordSet'             ) syncase_wordset                   =          value
          when Lower('MultiLineDelimited1' ) syncase_MultiLineDelimited1_from  = GetToken(value, ' ', 1)
                                             syncase_MultiLineDelimited1_to    = GetToken(value, ' ', 2)
          when Lower('MultiLineDelimited2' ) syncase_MultiLineDelimited2_from  = GetToken(value, ' ', 1)
                                             syncase_MultiLineDelimited2_to    = GetToken(value, ' ', 2)
          when Lower('MultiLineDelimited3' ) syncase_MultiLineDelimited3_from  = GetToken(value, ' ', 1)
                                             syncase_MultiLineDelimited3_to    = GetToken(value, ' ', 2)
          when Lower('SingleLineDelimited1') syncase_SingleLineDelimited1_from = GetToken(value, ' ', 1)
                                             syncase_SingleLineDelimited1_to   = GetToken(value, ' ', 2)
          when Lower('SingleLineDelimited2') syncase_SingleLineDelimited2_from = GetToken(value, ' ', 1)
                                             syncase_SingleLineDelimited2_to   = GetToken(value, ' ', 2)
          when Lower('SingleLineDelimited3') syncase_SingleLineDelimited3_from = GetToken(value, ' ', 1)
                                             syncase_SingleLineDelimited3_to   = GetToken(value, ' ', 2)
          when Lower('TillEol1'            ) syncase_TillEol1                  =          value
          when Lower('TillEol2'            ) syncase_TillEol2                  =          value
          when Lower('TillEol3'            ) syncase_TillEol3                  =          value
          when Lower('TillEolstartcol1'    ) syncase_TillEolstartcol1          =      Val(value)
          when Lower('TillEolstartcol2'    ) syncase_TillEolstartcol2          =      Val(value)
          when Lower('TillEolstartcol3'    ) syncase_TillEolstartcol3          =      Val(value)
          when Lower('Quote1'              ) syncase_Quote1                    =          value
          when Lower('Quote2'              ) syncase_Quote2                    =          value
          when Lower('Quote3'              ) syncase_Quote3                    =          value
          when Lower('QuoteEscape1'        ) syncase_QuoteEscape1              =          value
          when Lower('QuoteEscape2'        ) syncase_QuoteEscape2              =          value
          when Lower('QuoteEscape3'        ) syncase_QuoteEscape3              =          value
        endcase
      endwhile
    endif
  endif
  GotoBufferId(org_id)
  UpdateDisplay()
end set_current_syntax

/*
  The following is deduced from testing TSE's syntax hiliting.
  Parsing a line from left to right the syntax hiliter repeatedly tries to
  match the beginning of the unmatched part of the line to these types of
  strings in this order:
    Delimited - Hilited according to their delimiter type:
      A string as defined by its configered delimiter(s).
    Number - Hilited as a number:
      The largest possible string that matches a number according to the
      configured syntax hiliting number type.
    Keyword - Hilited according to the its Keywords group:
      The string that AND matches the largest matching predefined keyword
      AND either not ends with a hiliting-WordSet character or is not
      followed by a hiliting-WordSet character.
      So note, that once a matching largest keyword exists and it meets
      neither of the conditions, then no match for a shorter keyword is
      searched for.
    Bug - Wrongly highlited as text:
      A predefined keyword that is a single hiliting-WordSet character AND
      not a letter or digit AND occurs before a hiliting-WordSet character.
    Text - Hilited as text:
      Anything else.

  Examples of what strings are hilited as, assuming default SAL syntax
  hiliting and "-" being part of the hiliting Keyword WordSet:
    1b      A (binary) number.
    1a      One text.
    +1      A keyword and a number.
    -1      A bug and a number.
    1a+b    Text, a keyword and text.
    1a-b    One text.
    1-ab    A number, a bug and text.
    and or  A keyword, text and a keyword.
    andor   One text.
    Grey+   One keyword.
    Grey-   One keyword.
    Grey+a  A keyword and text.
    Grey-a  One text.

  This and more is documented at my "TSE Pro 4.4 Undocumented Features"
  web page at:
    https://ecarlo.nl/tse/files/TSE_Pro_v4.4_Undocumented_Features.html#SyntaxHilite%20Mode
*/

integer proc number_at_currpos()
  /*
    In principle SynCase follows TSE's syntax hiliting to determine what a
    keyword and a non-keyword are, and then cases keywords on their predefined
    form and non-keywords based on their directive (lower, upper, none).
    TSE hilites letters that are part of a number as a number, even if they
    form a keyword.
    So number hiliting overrules keyword hiliting.
    So SynCase should recognize numbers to not case keywords that are part of a
    number.
    It does not.
    Currently the cost of implementing all of TSE's configurable number
    syntaxes in SynCase outweighs the benefit of the unlikely situation of
    not casing a number's letters when they also (help) form a keyword.
    This proc exists and does nothing to clarify this implementation choice.
  */
  return(FALSE)
end number_at_currpos

integer proc string_at_currpos(string string_searched, var string string_found)
  integer found = FALSE
  if  string_searched <> ''
  and EquiStr(GetText(CurrPos(), Length(string_searched)), string_searched)
    found        = TRUE
    string_found = string_searched
  endif
  return(found)
end string_at_currpos

integer proc has_matching_starting_column(string to_eol_delimiter)
  integer result          = FALSE
  integer starting_column = 0
  case to_eol_delimiter
    when ''
      starting_column = 0
    when syncase_TillEol1
      starting_column = syncase_TillEolstartcol1
    when syncase_TillEol2
      starting_column = syncase_TillEolstartcol2
    when syncase_TillEol3
      starting_column = syncase_TillEolstartcol3
  endcase
  if starting_column == -1
    if CurrPos() == PosFirstNonWhite()
      result = TRUE
    endif
  elseif starting_column > 0
    if CurrPos() == starting_column
      result = TRUE
    endif
  else
    result = TRUE
  endif
  return(result)
end has_matching_starting_column

integer proc opening_delimiter_at_currpos(var string current_delimiter)
  integer found            = FALSE
  string  s [MAXSTRINGLEN] = ''
  if string_at_currpos(syncase_MultiLineDelimited1_from , s)
  or string_at_currpos(syncase_MultiLineDelimited2_from , s)
  or string_at_currpos(syncase_MultiLineDelimited3_from , s)
  or string_at_currpos(syncase_SingleLineDelimited1_from, s)
  or string_at_currpos(syncase_SingleLineDelimited2_from, s)
  or string_at_currpos(syncase_SingleLineDelimited3_from, s)
  or string_at_currpos(syncase_TillEol1                 , s)
  or string_at_currpos(syncase_TillEol2                 , s)
  or string_at_currpos(syncase_TillEol3                 , s)
  or string_at_currpos(syncase_Quote1                   , s)
  or string_at_currpos(syncase_Quote2                   , s)
  or string_at_currpos(syncase_Quote3                   , s)
    if not (s in syncase_TillEol1, syncase_TillEol2, syncase_TillEol3)
    or has_matching_starting_column(s)
      found             = TRUE
      current_delimiter = s
      if GetText(CurrPos(), Length(current_delimiter)) == current_delimiter
        Right(Length(current_delimiter))
      else
        // Delimiters are cased as if they were keywords.
        prev_uncased_keyword = GetText(CurrPos(), Length(current_delimiter))
        InsertText(current_delimiter, _OVERWRITE_)
      endif
      if (current_delimiter in syncase_TillEol1, syncase_TillEol2, syncase_TillEol3)
        end_line()
      endif
    endif
  endif
  return(found)
end opening_delimiter_at_currpos

integer proc closing_delimiter_at_currpos(var string current_delimiter)
  string  closing_delimiter [MAXSTRINGLEN] = ''
  string  escape_character             [1] = ''
  integer found                            = FALSE
  case current_delimiter
    when syncase_MultiLineDelimited1_from
      closing_delimiter = syncase_MultiLineDelimited1_to
    when syncase_MultiLineDelimited2_from
      closing_delimiter = syncase_MultiLineDelimited2_to
    when syncase_MultiLineDelimited3_from
      closing_delimiter = syncase_MultiLineDelimited3_to
    when syncase_SingleLineDelimited1_from
      closing_delimiter = syncase_SingleLineDelimited1_to
    when syncase_SingleLineDelimited2_from
      closing_delimiter = syncase_SingleLineDelimited2_to
    when syncase_SingleLineDelimited3_from
      closing_delimiter = syncase_SingleLineDelimited3_to
    when syncase_Quote1
      closing_delimiter = syncase_Quote1
      escape_character  = syncase_QuoteEscape1
    when syncase_Quote2
      closing_delimiter = syncase_Quote2
      escape_character  = syncase_QuoteEscape2
    when syncase_Quote3
      closing_delimiter = syncase_Quote3
      escape_character  = syncase_QuoteEscape3
  endcase

  if  closing_delimiter <> ''
  and (  escape_character == ''
      or GetText(CurrPos() - 1, 1) <> escape_character)
  and EquiStr(GetText(CurrPos(), Length(closing_delimiter)), closing_delimiter)
    current_delimiter = ''
    found             = TRUE
    if GetText(CurrPos(), Length(closing_delimiter)) == closing_delimiter
      Right(Length(closing_delimiter))
    else
      // Delimiters are cased as if they were keywords.
      prev_uncased_keyword = GetText(CurrPos(), Length(closing_delimiter))
      InsertText(closing_delimiter, _OVERWRITE_)
    endif
  endif
  return(found)
end closing_delimiter_at_currpos

integer proc keyword_at_CurrPos()
  integer found                  = FALSE
  string  keyword [MAXSTRINGLEN] = ''
  integer len                    = 0
  integer org_id                 = GetBufferId()
  string  s       [MAXSTRINGLEN] = ''
  if GetText(CurrPos(), 1) <> ' ' // Work around the GetToken() bug.
    s = GetToken(GetText(CurrPos(), MAXSTRINGLEN), ' ', 1)
  endif
  GotoBufferId(keywords_id)
  for len = Length(s) downto 1
    if lFind(s[1: len], '^gi$')
      if     len == Length(s)
      or not isWord(s[1: len + 1], syncase_WordSet)
        found   = TRUE
        keyword = GetText(1, MAXSTRINGLEN)
        break
      endif
    endif
  endfor
  GotoBufferId(org_id)
  if found
    if keyword == GetText(CurrPos(), Length(keyword))
      Right(Length(keyword))
    elseif EquiStr(keyword, GetText(CurrPos(), Length(keyword)))
      prev_uncased_keyword = GetText(CurrPos(), Length(keyword))
      InsertText(keyword, _OVERWRITE_)
    else
      Warn('SynCase programming error 1.')
      found = FALSE
    endif
  endif
  return(found)
end keyword_at_CurrPos

/*
  TSE bug: "-" is wrongly highlited as text:
    A predefined keyword that is a single hiliting-WordSet character AND
    not a letter or digit AND occurs before a hiliting-WordSet character.
    For example, in COBOL "-" is a keyword and can be part of but not start an
    identifier.
    The character needs to be in COBOL's syntax highlighting wordset.
    Unfortunately this makes TSE display the "-" in "-identifier" incorrectly,
    namely in a text color.

    SynCase does not seem to have the same problem casing a word preceded by
    "-", which makes sense given that it finds the keyword "-" first
*/

/* This code seems flawed and superfluous.

integer proc bug_at_currpos()
  integer found  = FALSE
  integer org_id = GetBufferId()
  string  s  [2] = ''
  if GetText(CurrPos(), 1) <> ' ' // Work around the GetToken() bug.
    s = GetToken(GetText(CurrPos(), MAXSTRINGLEN), ' ', 1)
  endif
  if  not (s in ' ', '')
  and not isAlphaNum(s[1])
  and isWord(s[2], syncase_WordSet)
    GotoBufferId(keywords_id)
    found = lFind(s[1], '^gi$')   // xx This seems wrong.
    GotoBufferId(org_id)
    if found
      Right()
    endif
  endif
  return(found)
end bug_at_currpos
*/

/*
  In the "anything else" SynCase is optionally interested in non-keywords.
*/
integer proc non_keyword_at_currpos()
  integer found                      = FALSE
  integer len                        = 0
  string  non_keyword [MAXSTRINGLEN] = ''
  string  s           [MAXSTRINGLEN] = ''
  if GetText(CurrPos(), 1) <> ' ' // Work around the GetToken() bug.
    s = GetToken(GetText(CurrPos(), MAXSTRINGLEN), ' ', 1)
    for len = Length(s) downto 1
      if isWord(s[1: len], syncase_WordSet)
        found       = TRUE
        non_keyword = s[1: len]
        if     non_keyword_casing == 'lower'
          non_keyword = Lower(non_keyword)
        elseif non_keyword_casing == 'upper'
          non_keyword = Upper(non_keyword)
        endif
        break
      endif
    endfor
    if found
      if GetText(CurrPos(), Length(non_keyword)) == non_keyword
        Right(Length(non_keyword))
      else
        InsertText  (non_keyword, _OVERWRITE_)
      endif
    endif
  endif
  return(found)
end non_keyword_at_currpos

proc syntax_case_the_current_line()
  string delimiter [MAXSTRINGLEN] = ''
  string old_WordSet         [32] = ''
  string word      [MAXSTRINGLEN] = ''
  if keyword_casing == 'on'
    PushPosition()

    // If the user types a non-keyword that starts with a keyword, then just
    // after typing the first non-keyword character we need to undo any casing
    // we did for that keyword. For example, given that "Max" is a TSE keyword,
    // typing "max_value" should not be cased to "Max_value".
    if  Length(prev_uncased_keyword) >= 1
    and GetBufferId() == prev_BufferId
    and CurrLine()    == prev_line
    and CurrPos()     == prev_pos + 1
      old_WordSet = Set(WordSet, syncase_WordSet)
      word        = GetWord(TRUE)
      if   Length(word)                     >= 2
      and EquiStr(word[1: Length(word) - 1] ,  prev_uncased_keyword)
      and         word[1: Length(word) - 1] <> prev_uncased_keyword
        PushLocation()
        WordLeft()
        if  EquiStr(GetText(CurrPos(), Length(prev_uncased_keyword)) ,  prev_uncased_keyword)
        and         GetText(CurrPos(), Length(prev_uncased_keyword)) <> prev_uncased_keyword
          InsertText(prev_uncased_keyword, _OVERWRITE_)
        endif
        PopLocation()
      endif
      Set(WordSet, old_WordSet)
    endif
    prev_uncased_keyword = ''
    prev_BufferId        = GetBufferId()
    prev_line            = CurrLine()
    prev_pos             = CurrPos()

    // CurrLineMultiLineDelimiterType() returns the type of multi-line
    // delimiter (1, 2, or 3) that is active at the end of the current line,
    // or 0 for none.
    if Up()
      //              COMPILE ERROR
      // If you get a compile error on the below statement,
      // then ideally you need to upgrade TSE to TSE v4.41.19 or higher,
      // but if you cannot, then you need to downgrade SynCase to SynCase v6.
      case CurrLineMultiLineDelimiterType()
        when 1
          delimiter = syncase_MultiLineDelimited1_from
        when 2
          delimiter = syncase_MultiLineDelimited2_from
        when 3
          delimiter = syncase_MultiLineDelimited3_from
      endcase
      Down()
    endif
    BegLine()
    while      CurrPos() < MAXLINELEN
    and   not (CurrChar() in _AT_EOL_, _BEYOND_EOL_)
      if delimiter == ''
        if number_at_currpos()
        or opening_delimiter_at_currpos(delimiter)
        or keyword_at_currpos()
//      or bug_at_currpos()
        or non_keyword_at_currpos()
          NoOp()
        else
          Right()
        endif
      else
        if closing_delimiter_at_currpos(delimiter)
          NoOp()
        else
          Right()
        endif
      endif
    endwhile
    PopPosition()
  endif
end syntax_case_the_current_line

proc syntax_case_current_file()
  if keyword_casing == 'on'
    Message("Syntax casing the current file ...")
    PushPosition()
    BegFile()
    repeat
      syntax_case_the_current_line()
    until not Down()
    PopPosition()
    Message("The current file is syntax cased.")
  else
    Message("Cannot Syntax Case a file with this extension")
  endif
end syntax_case_current_file

string proc menu_get_mapping_name()
  menu_mapping_name = iif(menu_mapping_name == '', mapping_name, menu_mapping_name)
  return(menu_mapping_name)
end menu_get_mapping_name

string proc menu_get_keyword_casing()
  string value [4] = ''
  menu_mapping_name = iif(menu_mapping_name == '', mapping_name, menu_mapping_name)
  value = Lower(GetProfileStr(macro_name + ':' + menu_mapping_name, 'keyword_casing', ''))
  if value <> 'on'
    value = 'off'
  endif
  return(value)
end menu_get_keyword_casing

integer proc get_menu_non_keyword_casing_flag()
  return(iif(menu_get_keyword_casing() == 'on', _MF_ENABLED_, _MF_GRAYED_|_MF_SKIP_))
end get_menu_non_keyword_casing_flag

integer proc get_syntax_case_current_file_flag()
  integer result = _MF_GRAYED_|_MF_SKIP_
  if  mapping_name <> ''
  and Lower(SplitPath(GetSynFilename(), _NAME_)) == mapping_name
    result = _MF_CLOSE_ALL_BEFORE_
  endif
  return(result)
end get_syntax_case_current_file_flag

integer proc get_keyword_casing_flag()
  menu_mapping_name = iif(menu_mapping_name == '', mapping_name, menu_mapping_name)
  return(iif(menu_mapping_name == '', _MF_GRAYED_|_MF_SKIP_, _MF_CLOSE_ALL_BEFORE_))
end get_keyword_casing_flag

integer proc get_menu_sal_flag()
  menu_mapping_name = iif(menu_mapping_name == '', mapping_name, menu_mapping_name)
  return(iif(menu_mapping_name == 'sal', _MF_CLOSE_ALL_BEFORE_, _MF_GRAYED_|_MF_SKIP_))
end get_menu_sal_flag

integer proc get_mappings_with_exts_list()
  integer bin_id                        = 0
  string  formatted_line [MAXSTRINGLEN] = ''
  integer i                             = 0
  integer num_syns                      = 0
  string  num_syns_string           [2] = ''
  string  synhi_extlist_signature  [18] = '®TSE SynhiExtList¯'
  string  syn_ext        [MAXSTRINGLEN] = ''
  string  syn_name       [MAXSTRINGLEN] = ''
  integer syn_pos                       = 0
  integer txt_id                        = CreateTempBuffer()
  max_syn_name_len = 0
  bin_id = EditBuffer(LoadDir() + 'tsesynhi.dat', _SYSTEM_, -2)
  if  bin_id
  and NumLines() >= 3
  and GetText(1, Length(synhi_extlist_signature)) == synhi_extlist_signature
  and CurrLineLen() == Length(synhi_extlist_signature) + 2
    num_syns_string = GetText(Length(synhi_extlist_signature) + 1, 2)
    num_syns = Asc(num_syns_string[2]) * 256 + Asc(num_syns_string[1])
    if num_syns > 0
      syn_pos = 1
      for i = 1 to num_syns
        GotoBufferId(bin_id)
        GotoLine(2)
        GotoPos(syn_pos)
        syn_name         = GetText(CurrPos() + 1, CurrChar())
        max_syn_name_len = Max(max_syn_name_len, Length(syn_name))
        syn_pos          = syn_pos + 1 + CurrChar()
        AddLine(syn_name + ':' , txt_id)
        GotoLine(i + 2)
        BegLine()
        while CurrChar() > 0
          syn_ext = GetText(CurrPos() + 1, CurrChar())
          GotoPos(CurrPos() + 1 + CurrChar())
          GotoBufferId(txt_id)
          EndLine()
          InsertText(' ' + QuotePath(syn_ext))
          GotoBufferId(bin_id)
        endwhile
      endfor
      GotoBufferId(txt_id)
      BegFile()
      repeat
        syn_name = GetToken(GetText(1, MAXSTRINGLEN), ':', 1)
        if Length(syn_name) > 0
          formatted_line = Format('   ',
                                  syn_name:-(max_syn_name_len),
                                  '   (',
                                  GetText(Pos(':',
                                              GetText(1, MAXSTRINGLEN))
                                          + 2,
                                          MAXSTRINGLEN),
                                  ')')
          BegLine()
          KillToEol()
          InsertText(formatted_line)
        endif
      until not Down()
      FileChanged(FALSE)
      BegFile()
    endif
  endif
  GotoBufferId(txt_id)
  AbandonFile(bin_id)
  return(txt_id)
end get_mappings_with_exts_list

proc menu_set_mapping_name()
  integer org_id = GetBufferId()
  integer lst_id = get_mappings_with_exts_list()
  menu_mapping_name = iif(menu_mapping_name == '', mapping_name, menu_mapping_name)
  lFind('   ' + menu_mapping_name + '   ', 'g^')
  ScrollToCenter()
  if List('Select a mapping set   (with its associated file extensions)', LongestLineInBuffer())
    menu_mapping_name = Trim(GetText(4, max_syn_name_len))
  endif
  GotoBufferId(org_id)
  AbandonFile(lst_id)
  restart_main_menu = TRUE
  PushKey(<CursorDown>)
  if get_syntax_case_current_file_flag() == _MF_CLOSE_ALL_BEFORE_
    PushKey(<CursorDown>)
  endif
end menu_set_mapping_name

proc menu_set_keyword_casing()
  string new_value [4] = menu_get_keyword_casing()
  menu_mapping_name = iif(menu_mapping_name == '', mapping_name, menu_mapping_name)
  if new_value == 'off'
    new_value = 'on'
  else
    new_value = 'off'
  endif
  WriteProfileStr(macro_name + ':' + menu_mapping_name, 'keyword_casing', new_value)
  if new_value == 'off'
    WriteProfileStr(macro_name + ':' + menu_mapping_name, 'non_keyword_casing', 'off')
  endif
  restart_main_menu = TRUE
  if get_syntax_case_current_file_flag() == _MF_CLOSE_ALL_BEFORE_
    PushKey(<CursorDown>)
  endif
  PushKey(<CursorDown>)
  PushKey(<CursorDown>)
end menu_set_keyword_casing

string proc menu_get_non_keyword_casing()
  string value [6] = ''
  menu_mapping_name = iif(menu_mapping_name == '', mapping_name, menu_mapping_name)
  value = Lower(GetProfileStr(macro_name + ':' + menu_mapping_name, 'non_keyword_casing', ''))
  if not (value in 'lower', 'upper')
    value = 'off'
  endif
  return(value)
end menu_get_non_keyword_casing

proc set_non_keyword_casing()
  string new_value [6] = 'off'
  case MenuOption()
    when 2
      new_value = 'lower'
    when 3
      new_value = 'upper'
  endcase
  WriteProfileStr(macro_name + ':' + menu_mapping_name, 'non_keyword_casing', new_value)
end set_non_keyword_casing

integer proc get_non_keyword_casing_history()
  integer result    = 1
  string  value [6] = menu_get_non_keyword_casing()
  case value
    when 'lower'
      result = 2
    when 'upper'
      result = 3
  endcase
  return(result)
end get_non_keyword_casing_history

menu menu_set_non_keyword_casing()
  history = get_non_keyword_casing_history()
  command = set_non_keyword_casing()

  '&Off', , _MF_CLOSE_AFTER_,
  'Do nothing with words that are not predefined keywords'

  '&Lower', , _MF_CLOSE_AFTER_,
  'Set all words that are not predefined keywords in lower case'

  '&Upper', , _MF_CLOSE_AFTER_,
  'Set all words that are not predefined keywords in upper case'

  '', , _MF_DIVIDE_

  '&Cancel', NoOp(), _MF_CLOSE_AFTER_,
  'Exit this menu'
end menu_set_non_keyword_casing

string proc menu_get_autoload_status()
  string result[4] = 'no'
  if isAutoLoaded()
    result = 'yes'
  endif
  return(result)
end menu_get_autoload_status

proc menu_set_autoload_status()
  if isAutoLoaded()
    DelAutoLoadMacro(macro_name)
  else
    AddAutoLoadMacro(macro_name)
  endif
end menu_set_autoload_status

proc get_menu_help()
  integer org_id = GetBufferId()
  integer tmp_id = 0
  if org_id <> hlp_id
    if not GotoBufferId(hlp_id)
      tmp_id = CreateTempBuffer()
      if LoadBuffer(SplitPath(CurrMacroFilename(), _DRIVE_|_PATH_|_NAME_) + '.hlp', 64)
        if  huffman_decode(FALSE)
        and GetBufferId() <> tmp_id
          hlp_id = GetBufferId()
          BegFile()
          ChangeCurrFilename('*** ' + macro_name + ' Help ***',
                             CHANGE_CURR_FILENAME_OPTIONS)
        else
          Warn(macro_name; ' error decoding .hlp file.')
          GotoBufferId(org_id)
        endif
      else
        Warn(macro_name; ' error loading .hlp file.')
        GotoBufferId(org_id)
      endif
      AbandonFile(tmp_id)
    endif
  endif
end get_menu_help

menu main_menu()
  title       = 'Syntax Case'
  x           = 5
  y           = 5

  'Actions:',, _MF_SKIP_

  '   &File   Case the whole current file',
  syntax_case_current_file(), get_syntax_case_current_file_flag(),
  'Set all known words in the whole current file in their predefined case'

  '   &Help',
  get_menu_help(), _MF_CLOSE_ALL_BEFORE_,
  'The detailed documentation'

  '',, _MF_DIVIDE_

  'Settings:',, _MF_SKIP_

  '   &For mapping set ' [menu_get_mapping_name():10],
  menu_set_mapping_name(), _MF_CLOSE_ALL_BEFORE_,
  'Use this mapping set, or select another one ...'

  '      &Keyword casing' [menu_get_keyword_casing():10],
  menu_set_keyword_casing(), get_keyword_casing_flag(),
  'Toggle the casing of keywords for this mapping set to ON or OFF'

  '      &Non-keyword casing' [menu_get_non_keyword_casing():10],
  menu_set_non_keyword_casing(), get_menu_non_keyword_casing_flag(),
  'For this mapping set: set the casing of non-keywords to LOWER, UPPER or OFF'

  '      &Set SAL to default case ...',
  SynCaseSal(), get_menu_sal_flag(),
  "Set SAL's synhi keywords to their default lower, UPPER and CamelCase ..."

  '   &AutoLoad' [menu_get_autoload_status():10],
  menu_set_autoload_status(), _MF_DONT_CLOSE_,
  'Toggle whether this macro should be AutoLoaded when TSE starts up'

  '',, _MF_DIVIDE_

  '&Escape', NoOp(), _MF_CLOSE_ALL_BEFORE_, 'Exit this menu'
end main_menu

proc do_main_menu()
  menu_mapping_name = ''
  repeat
    restart_main_menu = FALSE
    main_menu()
  until not restart_main_menu
end do_main_menu

proc after_command()
  if not BrowseMode()
    if CurrExt() <> syncase_ext
      set_current_syntax()
    endif
    syntax_case_the_current_line()
  endif
end after_command

proc check_out_of_box_installation()
  integer answer = 0
  if GetProfileStr(macro_name, 'out_of_the_box_installation', '') == ''
    Set(X1, 5)
    Set(Y1, 5)
    answer = YesNo('Do you want automatic UPPER/lower/CamelCase for TSE macros?')
    if answer
      WriteProfileStr(macro_name, 'out_of_the_box_installation',
                      iif(answer == 1, 'yes', 'no'))
      if answer == 1
        if not isAutoLoaded()
          AddAutoLoadMacro(macro_name)
        endif
        WriteProfileStr(macro_name + ':sal', 'keyword_casing', 'on')
        WriteProfileStr(macro_name + ':sal', 'non_keyword_casing', 'off')
        SynCaseSal()
      endif
    endif
  endif
end check_out_of_box_installation

proc WhenLoaded()
  macro_name            = SplitPath(CurrMacroFilename(), _NAME_)
  syncase_ext           = init_ext
  whenloaded_clockticks = GetClockTicks()
  check_out_of_box_installation()
  Hook(_AFTER_COMMAND_, after_command)
end WhenLoaded

proc WhenPurged()
  AbandonFile(syncase_id)
  AbandonFile(variables_id)
  AbandonFile(keywords_id)
  UnHook(after_command)
end WhenPurged

proc Main()
  main_clockticks = GetClockTicks()

  if CurrExt() <> syncase_ext
    set_current_syntax()
  endif
  do_main_menu()

  // If macro loaded and executed "at the same time", then it has just been
  // loaded to be executed once, so in that case purge [xx?] the macro.
  // Note: This is never true when debugging the macro.
  if main_clockticks - whenloaded_clockticks < 9
    PurgeMacro(macro_name)
  endif
end Main

