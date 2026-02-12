/*
  Macro           Huffman_Decode.inc
  Author          Carlo Hogeveen
  Website         ecarlo.nl/tse
  Compatibility   TSE Pro 4.0 upwards
  Version         v1.0   5 Apr 2021

  Documentation   See Huffman.txt.
*/



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

