/*
  Macro           Huffman_Encode.inc
  Author          Carlo Hogeveen
  Website         ecarlo.nl/tse
  Compatibility   TSE Pro 4.0 upwards
  Version         v1.0   5 Apr 2021

  Documentation   See Huffman.txt.
*/



#ifndef DEBUG
  #define DEBUG FALSE
#endif



proc huffman_write_bits(integer target_id,
                        integer bits_in,
                        integer num_bits)
  integer i            = 0
  integer new_bit_mask = 256
  integer org_id       = GetBufferId()
  GotoBufferId(target_id)
  for i = 1 to num_bits
    new_bit_mask     = new_bit_mask     shr 1
    huffman_bits_mask = huffman_bits_mask shr 1
    if bits_in & new_bit_mask
      huffman_bits_buffer = huffman_bits_buffer | huffman_bits_mask
    endif
    if huffman_bits_mask == 1
      InsertText(Chr(huffman_bits_buffer), _INSERT_)
      huffman_bits_buffer = 0
      huffman_bits_mask   = 256
      if CurrPos() > 64
        AddLine()
        BegLine()
      endif
    endif
  endfor
  GotoBufferId(org_id)
end huffman_write_bits



integer proc huffman_build_encoding_tree(integer tree_id,
                                         string  chars,
                                         string  bit)
  integer i      = 0
  integer ok     = TRUE
  integer org_id = GetBufferId()
  GotoBufferId(tree_id)
  for i = 1 to Length(chars)
    if lFind(chars[i], '^g')
      GotoPos(3)
      InsertText(bit, _INSERT_)
    else
      Warn('Huffman_encode.inc programming error 1.')
      ok = FALSE
    endif
  endfor
  GotoBufferId(org_id)
  return(ok)
end huffman_build_encoding_tree



integer proc huffman_encode()
  string  bytes_string           [64] = ''
  integer c                           = 0
  string  chars        [MAXSTRINGLEN] = ''
  integer dictionary_id               = 0
  integer i                           = 0
  integer input_id                    = GetBufferId()
  string  leaf_pos     [MAXSTRINGLEN] = ''
  integer num_bits                    = 0
  integer num_chars                   = 0
  integer num_nodes                   = 0
  integer ok                          = TRUE
  integer old_MsgLevel                = Query(MsgLevel)
  integer output_id                   = 0
  integer show_all_messages           = (Query(MsgLevel) == _ALL_MESSAGES_)
  integer single_weights_id           = 0
  integer tree_id                     = 0
  string  tree_pos     [MAXSTRINGLEN] = ''
  integer weight                      = 0
  integer weights_id                  = 0

  if  show_all_messages
  and NumLines() >= 10000
    KeyPressed()
    Message('Huffman encoding ...')
    KeyPressed()
  endif

  /*
    Save the editor's state.
  */
  PushLocation()
  PushBlock()

  /*
    Create a binary output buffer and initialize it with 6 blank positions.
  */
  output_id = NewFile()
  BinaryMode(TRUE)
  SetUndoOff()
  // Reserve 6 positions for the number of tree nodes and input characters.
  AddLine(Format('':6:Chr(0)))
  GotoPos(7)

  /*
    Count the occurrences of characters in the input buffer
    into hash variables stored with the weights buffer.

    Counting in hash variables is faster than counting in buffer lines.
    Note that the input buffer and output buffer can be big, so optimizing
    their processing is important, but all the temporary buffers are tiny.
  */
  weights_id = CreateTempBuffer()
  #if DEBUG
    huffman_make_tmp_name('encode_weights')
  #endif

  GotoBufferId(input_id)
  BegFile()
  repeat
    c = CurrChar()
    if c == _AT_EOL_
      if  not BinaryMode()
      and CurrLine() <> NumLines()
        SetBufferInt(Chr(10), GetBufferInt(Chr(10), weights_id) + 1, weights_id)
        num_chars = num_chars + 1
      endif
    else
      SetBufferInt(Chr(c), GetBufferInt(Chr(c), weights_id) + 1, weights_id)
      num_chars = num_chars + 1
    endif
  until not NextChar()

  if num_chars < 0  // Error caused by integer overflow.
    Warn('ERROR: Buffer > 2 GB.')
    ok = FALSE
  endif

  /*
    Transfer the counted weights from the hash variables to a list in the
    weights buffer.

    Simultaneously initialize a corresponding tree buffer with only the
    characters that occurred.
  */
  if ok
    tree_id = CreateTempBuffer()
    #if DEBUG
      huffman_make_tmp_name('encode_tree')
    #endif

    for c = 0 to 255
      if GetBufferInt(Chr(c), weights_id)
        AddLine(Format(GetBufferInt(Chr(c), weights_id): 11; Chr(c)), weights_id)
        AddLine(Chr(c)                                              , tree_id   )
      endif
    endfor
  endif

  /*
    If debugging, then preserve the count of the single character weights
    in a single weights buffer, because the weights buffer will be used
    to accumulate weights for character groups.
  */
  #if DEBUG
    if ok
      single_weights_id = CreateTempBuffer()
      huffman_make_tmp_name('encode_single_weights')
      GotoBufferId(weights_id)
      MarkLine(1, NumLines())
      GotoBufferId(single_weights_id)
      CopyBlock()
    endif
  #else
    // Avoid compiler note.
    single_weights_id = single_weights_id
  #endif

  /*
    Use the Huffman algorithm to accumulate the weights of single and groups
    of characters, continuously lower weights first, to build a Huffman tree.

    This binary tree is represented as a buffer in which each line is a leaf
    node, represented by a character and its binary tree position, the latter
    represented by a string of zeros and ones.
  */
  if ok
    GotoBufferId(weights_id)
    if NumLines() > 1
      while ok
      and   NumLines() > 1
        MarkColumn(1, 1, NumLines(), 11)
        Set(MsgLevel, _WARNINGS_ONLY_)
        Sort()
        Set(MsgLevel, old_MsgLevel)
        UnMarkBlock()
        BegFile()
        weight = Val(GetText(1, 11))
        chars  = GetText(13, MAXSTRINGLEN)
        ok = huffman_build_encoding_tree(tree_id, chars, "0")
        if ok
          Down()
          weight = weight + Val(GetText(1, 11))
          chars  = GetText(13, MAXSTRINGLEN)
          ok = huffman_build_encoding_tree(tree_id, chars, "1")
          if ok
            KillLine()
            BegFile()
            InsertText(Format(weight:11), _OVERWRITE_)
            EndLine()
            InsertText(chars, _INSERT_)
          endif
        endif
      endwhile
    else
      Warn('ERROR: Cannot compress less than 2 different characters.')
      ok = FALSE
    endif
  endif

  /*
    Sort the tree on tree positions.
  */
  if ok
    GotoBufferId(tree_id)
    MarkColumn(1, 3, NumLines(), LongestLineInBuffer())
    Set(MsgLevel, _WARNINGS_ONLY_)
    Sort()
    Set(MsgLevel, old_MsgLevel)
    UnMarkBlock()
  endif

  /*
    Create a character-to-huffman-bits encoding dictionary from the tree.
  */
  if ok
    ok = huffman_tree_to_dictionary(tree_id, 'encode', dictionary_id)
  endif

  /*
    Initialize the global bit buffer before creating the output buffer.
  */
  huffman_bits_buffer = 0
  huffman_bits_mask   = 256

  /*
    Write the Huffman tree to the output buffer as a bit stream.
    This is the smallest way to include (a precursor to) the dictionary.

    The Huffman tree is conceptualized as a binary tree, where all nodes have a
    side-value ("0" = left, "1" = right) and end-nodes (leaves) also have
    an 8-bit character-value.
    The below algorithm uses the fact, that a right ("1") child node never
    exists without a left ("0") sibling node. This allows for omitting the "0"
    and "1" node side-values when writing the tree to the output.
    The algorith walks the sorted ("0" = left, "1" = right) tree depth-first,
    top-down and left-to-right ("0" to "1"), and in doing so:
    - When going down to another parent node it writes bits "10".
    - When adding a leaf node it writes bits "11" plus the 8 character bits.
      Its tree position remains the same: the node above the leaf node.
    - When going up a node it writes bit "0".
  */
  if ok
    // Walk the tree
    BegFile()
    repeat
      leaf_pos = GetText(3, MAXSTRINGLEN)
      while tree_pos <> leaf_pos[1: Length(tree_pos)]
        tree_pos = tree_pos[1: Length(tree_pos) - 1]
        huffman_write_bits(output_id, 00000000b, 1) // The single bit "0".
      endwhile
      while Length(tree_pos) + 1 < Length(leaf_pos)
        tree_pos   = tree_pos + leaf_pos[Length(tree_pos) + 1]
        huffman_write_bits(output_id, 10000000b, 2) // The 2 bits "10".
        num_nodes  = num_nodes + 1
      endwhile
      huffman_write_bits(output_id,   11000000b, 2) // The 2 bits "11".
      huffman_write_bits(output_id, CurrChar(1), 8) // The 8 character bits.
      num_nodes = num_nodes + 1
    until not Down()
  endif

  /*
    Write the now known number of tree nodes and number of input buffer
    characters to the reserved start positions of the output buffer.
  */
  if ok
    GotoBufferId(output_id)
    PushLocation()
    BegFile()
    InsertText(  Chr( num_nodes  /  256)
               + Chr( num_nodes mod 256)

               + Chr( num_chars               / 16777216)
               + Chr((num_chars mod 16777216) /    65536)
               + Chr((num_chars mod    65536) /      256)
               + Chr( num_chars mod      256            ),
               _OVERWRITE_)
    PopLocation()
  endif

  /*
    Append the input buffer to the output buffer.
  */
  if ok
    GotoBufferId(input_id)
    BegFile()
    if  show_all_messages
    and NumLines() >= 10000
      KeyPressed()
      Message('Huffman encoding 0 %')
      KeyPressed()
    endif
    repeat
      c = CurrChar()
      if c == _AT_EOL_
        if  show_all_messages
        and CurrLine() mod 10000 == 0
          KeyPressed()
          Message('Huffman encoding'; CurrLine() / (NumLines() / 100); '%')
          KeyPressed()
        endif
        if not BinaryMode()
        and CurrLine() <> NumLines()
          c = 10
        endif
      endif
      if c <> _AT_EOL_
        bytes_string = GetBufferStr(Chr(c) + 'Bytes', dictionary_id)
        bytes_string = huffman_hex_to_bytes(bytes_string)
        num_bits     = GetBufferInt(Chr(c) + 'NumBits', dictionary_id)
        for i = 1 to Length(bytes_string)
          huffman_write_bits(output_id,
                             Asc(bytes_string[i]),
                             iif(num_bits > 8, 8, num_bits))
          num_bits = num_bits - 8
        endfor
      endif
    until not ok
       or not NextChar()
  endif

  // Write any rest bits.
  if ok
    if huffman_bits_mask <> 256
      huffman_write_bits(output_id, 0, 8)
    endif
    if  show_all_messages
    and NumLines() >= 10000
      KeyPressed()
      Message('Huffman encoding 100 %')
      KeyPressed()
    endif
  endif

  /*
    End encoding with the editor in an appropriate state.
  */
  PopLocation()
  PopBlock()
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
    huffman_preserve_tmp_buffer(single_weights_id)
    huffman_preserve_tmp_buffer(weights_id)
  #else
    AbandonFile(dictionary_id)
    AbandonFile(tree_id)
    AbandonFile(weights_id)
  #endif

  return(ok)
end huffman_encode

