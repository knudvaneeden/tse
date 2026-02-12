/*
  Macro           Huffman_Decode.s
  Author          Carlo Hogeveen
  Website         ecarlo.nl/tse
  Compatibility   TSE Pro 4.0 upwards
  Version         v1.0   5 Apr 2021

  Documentation   See Huffman.txt.
*/

#Include ['Huffman_Common.inc']
#Include ['Huffman_Decode.inc']

proc Main()
  string output_mode [7] = Lower(Trim(Query(MacroCmdLine)))
  huffman_decode(output_mode == 'binary')
  PurgeMacro(SplitPath(CurrMacroFilename(), _NAME_))
end Main

