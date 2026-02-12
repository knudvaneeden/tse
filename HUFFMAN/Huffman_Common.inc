/*
  Macro           Huffman_Common.inc
  Author          Carlo Hogeveen
  Website         ecarlo.nl/tse
  Compatibility   TSE Pro 4.0 upwards
  Version         v1.0   5 Apr 2021

  Documentation   See Huffman.txt.
*/



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
    ChangeCurrFilename(fqn, _DONT_PROMPT_|_DONT_EXPAND_|_OVERWRITE_)
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

