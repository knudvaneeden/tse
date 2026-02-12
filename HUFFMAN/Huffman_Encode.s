/*
  Macro           Huffman_Encode.s
  Author          Carlo Hogeveen
  Website         ecarlo.nl/tse
  Compatibility   TSE Pro 4.0 upwards
  Version         v1.0   5 Apr 2021

  Documentation   See Huffman.txt.
*/

#Include ['Huffman_Common.inc']
#Include ['Huffman_Encode.inc']

proc Main()
  huffman_encode()
  PurgeMacro(SplitPath(CurrMacroFilename(), _NAME_))
end Main

