/*
 Euler Project 186
 Connectedness of a network

 Pure TSE SAL solution
 Version: 1.0.0.0.0

 Expected final calculated result:
 2325629

 History:
 1.0.0.0.0
 - Initial pure TSE SAL version
 - Created by ChatGPT GPT-5.4 Thinking
*/

#define MODULO_N               1000000
#define USER_COUNT             1000000
#define PM_NUMBER              524287
#define TARGET_COUNT           990000
#define PACK_WIDTH             7
#define PACK_PER_LINE          36
#define LAG_COUNT              55

integer gParentBufferI = 0
integer gSizeBufferI   = 0
integer gLagBufferI    = 0
integer gLagGeneratedI = 0
integer gLagWriteSlotI = 1

FORWARD integer proc ProcMin( integer aI, integer bI )
FORWARD string  proc ProcRepeatChar( string characterS, integer countI )
FORWARD string  proc ProcPackInteger( integer numberI )
FORWARD integer proc ProcStringToInteger( string numberS )
FORWARD integer proc ProcNormalizeModulo( integer numberI, integer moduloI )
FORWARD integer proc ProcMulModulo( integer aI, integer bI, integer moduloI )
FORWARD integer proc ProcSeedValue( integer kI )
FORWARD proc    ProcCreatePackedArrayBuffer( integer bufferI, integer itemCountI, integer modeI )
FORWARD integer proc ProcPackedGet( integer bufferI, integer indexI )
FORWARD proc    ProcPackedSet( integer bufferI, integer indexI, integer valueI )
FORWARD integer proc ProcLagGet( integer slotI )
FORWARD proc    ProcLagSet( integer slotI, integer valueI )
FORWARD integer proc ProcLagNext()
FORWARD integer proc ProcFindRoot( integer nodeI )
FORWARD integer proc ProcComponentSize( integer nodeI )
FORWARD proc    ProcUnionNodes( integer node1I, integer node2I )

integer proc ProcMin( integer aI, integer bI )
 integer resultI = 0
 if aI < bI
  resultI = aI
 else
  resultI = bI
 endif
 Return( resultI )
end

string proc ProcRepeatChar( string characterS, integer countI )
 string resultS[255] = ""
 integer iI = 0
 for iI = 1 to countI
  resultS = resultS + characterS
 endfor
 Return( resultS )
end

string proc ProcPackInteger( integer numberI )
 string resultS[255] = ""
 resultS = Format( numberI:PACK_WIDTH:"0" )
 Return( resultS )
end

integer proc ProcStringToInteger( string numberS )
 integer resultI = 0
 string workS[255] = ""
 workS = numberS
 resultI = Val( workS )
 Return( resultI )
end

integer proc ProcNormalizeModulo( integer numberI, integer moduloI )
 integer resultI = 0
 resultI = numberI mod moduloI
 while resultI < 0
  resultI = resultI + moduloI
 endwhile
 Return( resultI )
end

integer proc ProcMulModulo( integer aI, integer bI, integer moduloI )
 integer resultI = 0
 integer leftI = 0
 integer rightI = 0
 resultI = 0
 leftI  = ProcNormalizeModulo( aI, moduloI )
 rightI = bI
 while rightI > 0
  if ( rightI mod 2 ) == 1
   resultI = ProcNormalizeModulo( resultI + leftI, moduloI )
  endif
  leftI = ProcNormalizeModulo( leftI + leftI, moduloI )
  rightI = rightI shr 1
 endwhile
 Return( resultI )
end

integer proc ProcSeedValue( integer kI )
 integer cubeI = 0
 integer part1I = 0
 integer part2I = 0
 integer part3I = 0
 integer resultI = 0
 cubeI  = kI * kI * kI
 part1I = 100003
 part2I = ProcMulModulo( 200003, kI, MODULO_N )
 part3I = ProcMulModulo( 300007, cubeI, MODULO_N )
 resultI = ProcNormalizeModulo( part1I - part2I + part3I, MODULO_N )
 Return( resultI )
end

proc ProcCreatePackedArrayBuffer( integer bufferI, integer itemCountI, integer modeI )
 integer itemsDoneI = 0
 integer itemsThisLineI = 0
 integer currentIndexI = 0
 integer currentValueI = 0
 string lineS[255] = ""
 PushLocation()
 GotoBufferId( bufferI )
 EmptyBuffer()
 itemsDoneI = 0
 while itemsDoneI < itemCountI
  lineS = ""
  itemsThisLineI = ProcMin( PACK_PER_LINE, itemCountI - itemsDoneI )
  for currentIndexI = 0 to itemsThisLineI - 1
   if modeI == 0
    currentValueI = itemsDoneI + currentIndexI
   else
    currentValueI = 1
   endif
   lineS = lineS + ProcPackInteger( currentValueI )
  endfor
  if itemsThisLineI < PACK_PER_LINE
   lineS = lineS + ProcRepeatChar( "0", ( PACK_PER_LINE - itemsThisLineI ) * PACK_WIDTH )
  endif
  AddLine( lineS, bufferI )
  itemsDoneI = itemsDoneI + itemsThisLineI
 endwhile
 PopLocation()
end

integer proc ProcPackedGet( integer bufferI, integer indexI )
 integer lineNumberI = 0
 integer columnI = 0
 string lineS[255] = ""
 string valueS[255] = ""
 integer resultI = 0
 PushLocation()
 GotoBufferId( bufferI )
 lineNumberI = ( indexI / PACK_PER_LINE ) + 1
 columnI = ( indexI mod PACK_PER_LINE ) * PACK_WIDTH + 1
 GotoLine( lineNumberI )
 lineS = GetText( 1, CurrLineLen() )
 valueS = SubStr( lineS, columnI, PACK_WIDTH )
 resultI = ProcStringToInteger( valueS )
 PopLocation()
 Return( resultI )
end

proc ProcPackedSet( integer bufferI, integer indexI, integer valueI )
 integer lineNumberI = 0
 integer columnI = 0
 string lineS[255] = ""
 string leftS[255] = ""
 string rightS[255] = ""
 string valueS[255] = ""
 string newLineS[255] = ""
 PushLocation()
 GotoBufferId( bufferI )
 lineNumberI = ( indexI / PACK_PER_LINE ) + 1
 columnI = ( indexI mod PACK_PER_LINE ) * PACK_WIDTH + 1
 GotoLine( lineNumberI )
 lineS = GetText( 1, CurrLineLen() )
 if columnI > 1
  leftS = SubStr( lineS, 1, columnI - 1 )
 else
  leftS = ""
 endif
 if ( columnI + PACK_WIDTH ) <= CurrLineLen()
  rightS = SubStr( lineS, columnI + PACK_WIDTH, CurrLineLen() - ( columnI + PACK_WIDTH ) + 1 )
 else
  rightS = ""
 endif
 valueS = ProcPackInteger( valueI )
 newLineS = leftS + valueS + rightS
 BegLine()
 KillToEol()
 InsertText( newLineS )
 PopLocation()
end

integer proc ProcLagGet( integer slotI )
 integer resultI = 0
 PushLocation()
 GotoBufferId( gLagBufferI )
 GotoLine( slotI )
 resultI = ProcStringToInteger( GetText( 1, CurrLineLen() ) )
 PopLocation()
 Return( resultI )
end

proc ProcLagSet( integer slotI, integer valueI )
 PushLocation()
 GotoBufferId( gLagBufferI )
 GotoLine( slotI )
 BegLine()
 KillToEol()
 InsertText( ProcPackInteger( valueI ) )
 PopLocation()
end

integer proc ProcLagNext()
 integer resultI = 0
 integer old55I = 0
 integer old24I = 0
 integer slot24I = 0
 if gLagGeneratedI < LAG_COUNT
  resultI = ProcSeedValue( gLagGeneratedI + 1 )
  ProcLagSet( gLagGeneratedI + 1, resultI )
  gLagGeneratedI = gLagGeneratedI + 1
  if gLagGeneratedI == LAG_COUNT
   gLagWriteSlotI = 1
  endif
 else
  old55I = ProcLagGet( gLagWriteSlotI )
  slot24I = gLagWriteSlotI + 31
  while slot24I > LAG_COUNT
   slot24I = slot24I - LAG_COUNT
  endwhile
  old24I = ProcLagGet( slot24I )
  resultI = old55I + old24I
  if resultI >= MODULO_N
   resultI = resultI - MODULO_N
  endif
  ProcLagSet( gLagWriteSlotI, resultI )
  gLagWriteSlotI = gLagWriteSlotI + 1
  if gLagWriteSlotI > LAG_COUNT
   gLagWriteSlotI = 1
  endif
  gLagGeneratedI = gLagGeneratedI + 1
 endif
 Return( resultI )
end

integer proc ProcFindRoot( integer nodeI )
 integer currentI = 0
 integer parentI = 0
 integer grandParentI = 0
 currentI = nodeI
 while TRUE
  parentI = ProcPackedGet( gParentBufferI, currentI )
  if parentI == currentI
   Return( currentI )
  endif
  grandParentI = ProcPackedGet( gParentBufferI, parentI )
  ProcPackedSet( gParentBufferI, currentI, grandParentI )
  currentI = grandParentI
 endwhile
 Return( currentI )
end

integer proc ProcComponentSize( integer nodeI )
 integer rootI = 0
 integer resultI = 0
 rootI = ProcFindRoot( nodeI )
 resultI = ProcPackedGet( gSizeBufferI, rootI )
 Return( resultI )
end

proc ProcUnionNodes( integer node1I, integer node2I )
 integer root1I = 0
 integer root2I = 0
 integer size1I = 0
 integer size2I = 0
 integer newSizeI = 0
 root1I = ProcFindRoot( node1I )
 root2I = ProcFindRoot( node2I )
 if root1I == root2I
  Return()
 endif
 size1I = ProcPackedGet( gSizeBufferI, root1I )
 size2I = ProcPackedGet( gSizeBufferI, root2I )
 if size1I < size2I
  ProcPackedSet( gParentBufferI, root1I, root2I )
  newSizeI = size1I + size2I
  ProcPackedSet( gSizeBufferI, root2I, newSizeI )
 else
  ProcPackedSet( gParentBufferI, root2I, root1I )
  newSizeI = size1I + size2I
  ProcPackedSet( gSizeBufferI, root1I, newSizeI )
 endif
 Return()
end

PROC Main()
 integer recordNumberI = 0
 integer callerI = 0
 integer calledI = 0
 integer successfulCallsI = 0
 integer pmComponentSizeI = 0
 string resultS[255] = ""

 gParentBufferI = CreateTempBuffer()
 gSizeBufferI   = CreateTempBuffer()
 gLagBufferI    = CreateTempBuffer()

 ProcCreatePackedArrayBuffer( gParentBufferI, USER_COUNT, 0 )
 ProcCreatePackedArrayBuffer( gSizeBufferI,   USER_COUNT, 1 )

 PushLocation()
 GotoBufferId( gLagBufferI )
 EmptyBuffer()
 AddLine( "0000000", gLagBufferI )
 AddLine( "0000000", gLagBufferI )
 AddLine( "0000000", gLagBufferI )
 AddLine( "0000000", gLagBufferI )
 AddLine( "0000000", gLagBufferI )
 AddLine( "0000000", gLagBufferI )
 AddLine( "0000000", gLagBufferI )
 AddLine( "0000000", gLagBufferI )
 AddLine( "0000000", gLagBufferI )
 AddLine( "0000000", gLagBufferI )
 AddLine( "0000000", gLagBufferI )
 AddLine( "0000000", gLagBufferI )
 AddLine( "0000000", gLagBufferI )
 AddLine( "0000000", gLagBufferI )
 AddLine( "0000000", gLagBufferI )
 AddLine( "0000000", gLagBufferI )
 AddLine( "0000000", gLagBufferI )
 AddLine( "0000000", gLagBufferI )
 AddLine( "0000000", gLagBufferI )
 AddLine( "0000000", gLagBufferI )
 AddLine( "0000000", gLagBufferI )
 AddLine( "0000000", gLagBufferI )
 AddLine( "0000000", gLagBufferI )
 AddLine( "0000000", gLagBufferI )
 AddLine( "0000000", gLagBufferI )
 AddLine( "0000000", gLagBufferI )
 AddLine( "0000000", gLagBufferI )
 AddLine( "0000000", gLagBufferI )
 AddLine( "0000000", gLagBufferI )
 AddLine( "0000000", gLagBufferI )
 AddLine( "0000000", gLagBufferI )
 AddLine( "0000000", gLagBufferI )
 AddLine( "0000000", gLagBufferI )
 AddLine( "0000000", gLagBufferI )
 AddLine( "0000000", gLagBufferI )
 AddLine( "0000000", gLagBufferI )
 AddLine( "0000000", gLagBufferI )
 AddLine( "0000000", gLagBufferI )
 AddLine( "0000000", gLagBufferI )
 AddLine( "0000000", gLagBufferI )
 AddLine( "0000000", gLagBufferI )
 AddLine( "0000000", gLagBufferI )
 AddLine( "0000000", gLagBufferI )
 AddLine( "0000000", gLagBufferI )
 AddLine( "0000000", gLagBufferI )
 AddLine( "0000000", gLagBufferI )
 AddLine( "0000000", gLagBufferI )
 AddLine( "0000000", gLagBufferI )
 AddLine( "0000000", gLagBufferI )
 AddLine( "0000000", gLagBufferI )
 AddLine( "0000000", gLagBufferI )
 AddLine( "0000000", gLagBufferI )
 AddLine( "0000000", gLagBufferI )
 AddLine( "0000000", gLagBufferI )
 AddLine( "0000000", gLagBufferI )
 PopLocation()

 gLagGeneratedI = 0
 gLagWriteSlotI = 1

 successfulCallsI = 0
 pmComponentSizeI = 1

 while pmComponentSizeI < TARGET_COUNT
  callerI = ProcLagNext()
  calledI = ProcLagNext()
  recordNumberI = recordNumberI + 1
  if NOT ( callerI == calledI )
   successfulCallsI = successfulCallsI + 1
   ProcUnionNodes( callerI, calledI )
   pmComponentSizeI = ProcComponentSize( PM_NUMBER )
  endif
 endwhile

 resultS = Format( successfulCallsI )
 CopyToWinClip( resultS )
 Warn( resultS )
 CopyToWinClip( resultS )

 AbandonFile( gLagBufferI )
 AbandonFile( gSizeBufferI )
 AbandonFile( gParentBufferI )
END
