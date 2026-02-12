/*
  Macro           Huffman
  Author          Carlo Hogeveen
  Website         ecarlo.nl/tse
  Compatibility   TSE Pro 4.0 upwards
  Version         v1.0   5 Apr 2021

  Documentation   See Huffman.txt.
*/

proc Main()
  string  action                  [7] = ''
  integer i                           = 0
  integer org_id                      = GetBufferId()
  integer output_binary_mode          = FALSE
  for i = 1 to NumFileTokens(Query(MacroCmdLine))
    case Lower(GetFileToken(Query(MacroCmdLine), i))
      when 'encode'
        action = 'encode'
      when 'decode'
        action = 'decode'
      when 'test'
        action = 'test'
      when 'binary'
        output_binary_mode = TRUE
    endcase
  endfor
  case action
    when 'encode'
      ExecMacro('Huffman_Encode')
    when 'decode'
      ExecMacro('Huffman_Decode' + iif(output_binary_mode, ' binary', ''))
    when 'test', ''
      ExecMacro('Huffman_Encode')
      if GetBufferId() <> org_id
        org_id = GetBufferId()
        ExecMacro('Huffman_Decode')
      endif
    otherwise
      Warn('ERROR: Invalid parameter.')
  endcase
  PurgeMacro(SplitPath(CurrMacroFilename(), _NAME_))
end Main

