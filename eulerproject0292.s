// Problem 292 - Pythagorean Polygons
// <version>1</version>
// History: 1 - ChatGPT

#define TARGET_N      120
#define WIDTH_K       241
#define OFFSET_K      120
#define ORIGIN_KEY_K  29040
#define BIG_BASE_K    10000
#define BIG_BASE2_K   100000000

integer gDpBufferIdByPerimeterGI = 0
integer gDpBufferCountByPerimeterGI = 0
integer gGroupDxBufferGI = 0
integer gGroupDyBufferGI = 0
integer gGroupLenBufferGI = 0
integer gGroupCountGI = 0
integer gBig2GI = 0
integer gBig1GI = 0
integer gBig0GI = 0

integer proc FNCreateTempBufferSafeI()
 integer bufferI = 0
 PushLocation()
 bufferI = CreateTempBuffer()
 PopLocation()
 return( bufferI )
end

proc PROCAbandonBufferById( integer bufferI )
 PushLocation()
 GotoBufferId( bufferI )
 AbandonFile()
 PopLocation()
end

integer proc FNBufferLineIntI( integer bufferI, integer lineI )
 integer valueI = 0
 PushLocation()
 GotoBufferId( bufferI )
 GotoLine( lineI )
 valueI = Val( GetText( 1, 255 ) )
 PopLocation()
 return( valueI )
end

proc PROCSetBufferLineInt( integer bufferI, integer lineI, integer valueI )
 PushLocation()
 GotoBufferId( bufferI )
 GotoLine( lineI )
 BegLine()
 KillToEol()
 InsertText( Format( valueI ) )
 PopLocation()
end

string proc FNFormatDpLineS( integer keyI, integer countI )
 string lineS[255] = ""
 lineS = Format( keyI : 5 : "0" ) + " " + Format( countI : 5 : "0" )
 return( lineS )
end

string proc FNFormatAdditionLineS( integer perimeterI, integer keyI, integer countI )
 string lineS[255] = ""
 lineS = Format( perimeterI : 3 : "0" ) + " " + Format( keyI : 5 : "0" ) + " " + Format( countI : 5 : "0" )
 return( lineS )
end

integer proc FNGcdI( integer leftI, integer rightI )
 integer tempI = 0
 while rightI > 0
  tempI = leftI mod rightI
  leftI = rightI
  rightI = tempI
 endwhile
 return( leftI )
end

proc PROCAddGroup( integer dxI, integer dyI, integer lenI )
 AddLine( Format( dxI ), gGroupDxBufferGI )
 AddLine( Format( dyI ), gGroupDyBufferGI )
 AddLine( Format( lenI ), gGroupLenBufferGI )
 gGroupCountGI = gGroupCountGI + 1
end

proc PROCBuildGroups()
 integer mI = 0
 integer nI = 0
 integer mmI = 0
 integer aI = 0
 integer bI = 0
 integer cI = 0
 PROCAddGroup( 1, 0, 1 )
 PROCAddGroup( 0, 1, 1 )
 for mI = 2 to TARGET_N
  mmI = mI * mI
  for nI = 1 to mI - 1
   cI = mmI + nI * nI
   if cI <= TARGET_N
    if ( ( mI - nI ) mod 2 ) == 1
     if FNGcdI( mI, nI ) == 1
      aI = mmI - nI * nI
      bI = 2 * mI * nI
      PROCAddGroup(  aI,  bI, cI )
      PROCAddGroup( -aI,  bI, cI )
      PROCAddGroup(  bI,  aI, cI )
      PROCAddGroup( -bI,  aI, cI )
     endif
    endif
   endif
  endfor
 endfor
end

integer proc FNGetDpBufferIdI( integer perimeterI )
 return( FNBufferLineIntI( gDpBufferIdByPerimeterGI, perimeterI + 1 ) )
end

integer proc FNGetDpBufferCountI( integer perimeterI )
 return( FNBufferLineIntI( gDpBufferCountByPerimeterGI, perimeterI + 1 ) )
end

proc PROCSetDpBufferId( integer perimeterI, integer bufferI )
 PROCSetBufferLineInt( gDpBufferIdByPerimeterGI, perimeterI + 1, bufferI )
end

proc PROCSetDpBufferCount( integer perimeterI, integer countI )
 PROCSetBufferLineInt( gDpBufferCountByPerimeterGI, perimeterI + 1, countI )
end

proc PROCInitDp()
 integer perimeterI = 0
 integer bufferI = 0
 gDpBufferIdByPerimeterGI = FNCreateTempBufferSafeI()
 gDpBufferCountByPerimeterGI = FNCreateTempBufferSafeI()
 for perimeterI = 0 to TARGET_N
  bufferI = FNCreateTempBufferSafeI()
  AddLine( Format( bufferI ), gDpBufferIdByPerimeterGI )
  if perimeterI == 0
   AddLine( "1", gDpBufferCountByPerimeterGI )
   AddLine( FNFormatDpLineS( ORIGIN_KEY_K, 1 ), bufferI )
  else
   AddLine( "0", gDpBufferCountByPerimeterGI )
  endif
 endfor
end

proc PROCSortWholeBuffer( integer bufferI, integer lineCountI )
 if lineCountI > 1
  PushLocation()
  GotoBufferId( bufferI )
  MarkAll()
  ExecMacro( "sort" )
  PopLocation()
 endif
end

proc PROCMergeIntoPerimeter( integer perimeterI, integer segmentBufferI, integer segmentCountI )
 integer oldBufferI = 0
 integer oldCountI = 0
 integer newBufferI = 0
 integer newCountI = 0
 integer oldLineI = 1
 integer segmentLineI = 1
 integer oldKeyI = 0
 integer oldCountValueI = 0
 integer segmentKeyI = 0
 integer segmentCountValueI = 0
 oldBufferI = FNGetDpBufferIdI( perimeterI )
 oldCountI = FNGetDpBufferCountI( perimeterI )
 newBufferI = FNCreateTempBufferSafeI()
 PushLocation()
 while oldLineI <= oldCountI
  if segmentLineI > segmentCountI
   GotoBufferId( oldBufferI )
   GotoLine( oldLineI )
   AddLine( GetText( 1, 11 ), newBufferI )
   newCountI = newCountI + 1
   oldLineI = oldLineI + 1
  else
   if oldLineI > oldCountI
    GotoBufferId( segmentBufferI )
    GotoLine( segmentLineI )
    AddLine( GetText( 1, 11 ), newBufferI )
    newCountI = newCountI + 1
    segmentLineI = segmentLineI + 1
   else
    GotoBufferId( oldBufferI )
    GotoLine( oldLineI )
    oldKeyI = Val( GetText( 1, 5 ) )
    oldCountValueI = Val( GetText( 7, 5 ) )
    GotoBufferId( segmentBufferI )
    GotoLine( segmentLineI )
    segmentKeyI = Val( GetText( 1, 5 ) )
    segmentCountValueI = Val( GetText( 7, 5 ) )
    if oldKeyI < segmentKeyI
     AddLine( FNFormatDpLineS( oldKeyI, oldCountValueI ), newBufferI )
     newCountI = newCountI + 1
     oldLineI = oldLineI + 1
    else
     if segmentKeyI < oldKeyI
      AddLine( FNFormatDpLineS( segmentKeyI, segmentCountValueI ), newBufferI )
      newCountI = newCountI + 1
      segmentLineI = segmentLineI + 1
     else
      AddLine( FNFormatDpLineS( oldKeyI, oldCountValueI + segmentCountValueI ), newBufferI )
      newCountI = newCountI + 1
      oldLineI = oldLineI + 1
      segmentLineI = segmentLineI + 1
     endif
    endif
   endif
  endif
 endwhile
 while segmentLineI <= segmentCountI
  GotoBufferId( segmentBufferI )
  GotoLine( segmentLineI )
  AddLine( GetText( 1, 11 ), newBufferI )
  newCountI = newCountI + 1
  segmentLineI = segmentLineI + 1
 endwhile
 PopLocation()
 PROCSetDpBufferId( perimeterI, newBufferI )
 PROCSetDpBufferCount( perimeterI, newCountI )
 PROCAbandonBufferById( oldBufferI )
end

proc PROCProcessSortedAdditions( integer addBufferI )
 integer addLineCountI = 0
 integer lineI = 0
 integer currentDestI = 0
 integer currentKeyI = 0
 integer currentCountI = 0
 integer previousDestI = -1
 integer previousKeyI = 0
 integer previousCountI = 0
 integer segmentBufferI = 0
 integer segmentCountI = 0
 integer segmentDestI = -1
 PushLocation()
 GotoBufferId( addBufferI )
 addLineCountI = NumLines()
 if addLineCountI == 0
  PopLocation()
  return()
 endif
 segmentBufferI = FNCreateTempBufferSafeI()
 GotoLine( 1 )
 previousDestI = Val( GetText( 1, 3 ) )
 previousKeyI = Val( GetText( 5, 5 ) )
 previousCountI = Val( GetText( 11, 5 ) )
 for lineI = 2 to addLineCountI
  GotoLine( lineI )
  currentDestI = Val( GetText( 1, 3 ) )
  currentKeyI = Val( GetText( 5, 5 ) )
  currentCountI = Val( GetText( 11, 5 ) )
  if currentDestI == previousDestI
   if currentKeyI == previousKeyI
    previousCountI = previousCountI + currentCountI
   else
    if segmentDestI == -1
     segmentDestI = previousDestI
    endif
    if NOT( previousDestI == segmentDestI )
     PROCMergeIntoPerimeter( segmentDestI, segmentBufferI, segmentCountI )
     PROCAbandonBufferById( segmentBufferI )
     segmentBufferI = FNCreateTempBufferSafeI()
     segmentCountI = 0
     segmentDestI = previousDestI
    endif
    AddLine( FNFormatDpLineS( previousKeyI, previousCountI ), segmentBufferI )
    segmentCountI = segmentCountI + 1
    previousKeyI = currentKeyI
    previousCountI = currentCountI
   endif
  else
   if segmentDestI == -1
    segmentDestI = previousDestI
   endif
   if NOT( previousDestI == segmentDestI )
    PROCMergeIntoPerimeter( segmentDestI, segmentBufferI, segmentCountI )
    PROCAbandonBufferById( segmentBufferI )
    segmentBufferI = FNCreateTempBufferSafeI()
    segmentCountI = 0
    segmentDestI = previousDestI
   endif
   AddLine( FNFormatDpLineS( previousKeyI, previousCountI ), segmentBufferI )
   segmentCountI = segmentCountI + 1
   previousDestI = currentDestI
   previousKeyI = currentKeyI
   previousCountI = currentCountI
  endif
 endfor
 if segmentDestI == -1
  segmentDestI = previousDestI
 endif
 if NOT( previousDestI == segmentDestI )
  PROCMergeIntoPerimeter( segmentDestI, segmentBufferI, segmentCountI )
  PROCAbandonBufferById( segmentBufferI )
  segmentBufferI = FNCreateTempBufferSafeI()
  segmentCountI = 0
  segmentDestI = previousDestI
 endif
 AddLine( FNFormatDpLineS( previousKeyI, previousCountI ), segmentBufferI )
 segmentCountI = segmentCountI + 1
 PopLocation()
 if segmentCountI > 0
  PROCMergeIntoPerimeter( segmentDestI, segmentBufferI, segmentCountI )
 endif
 PROCAbandonBufferById( segmentBufferI )
end

proc PROCApplyGroup( integer dxI, integer dyI, integer lenI )
 integer addBufferI = 0
 integer scaleI = 0
 integer scaledLenI = 0
 integer deltaI = 0
 integer sourcePerimeterI = 0
 integer destPerimeterI = 0
 integer sourceBufferI = 0
 integer sourceLineCountI = 0
 integer sourceLineI = 0
 integer sourceKeyI = 0
 integer sourceCountI = 0
 addBufferI = FNCreateTempBufferSafeI()
 for scaleI = 1 to TARGET_N / lenI
  scaledLenI = scaleI * lenI
  deltaI = scaleI * ( dxI * WIDTH_K + dyI )
  for sourcePerimeterI = 0 to TARGET_N - scaledLenI
   sourceLineCountI = FNGetDpBufferCountI( sourcePerimeterI )
   if sourceLineCountI > 0
    destPerimeterI = sourcePerimeterI + scaledLenI
    sourceBufferI = FNGetDpBufferIdI( sourcePerimeterI )
    PushLocation()
    GotoBufferId( sourceBufferI )
    for sourceLineI = 1 to sourceLineCountI
     GotoLine( sourceLineI )
     sourceKeyI = Val( GetText( 1, 5 ) )
     sourceCountI = Val( GetText( 7, 5 ) )
     AddLine( FNFormatAdditionLineS( destPerimeterI, sourceKeyI + deltaI, sourceCountI ), addBufferI )
    endfor
    PopLocation()
   endif
  endfor
 endfor
 PushLocation()
 GotoBufferId( addBufferI )
 if NumLines() > 0
  PopLocation()
  PROCSortWholeBuffer( addBufferI, FNBufferLineIntI( addBufferI, 1 ) )
 else
  PopLocation()
 endif
 PushLocation()
 GotoBufferId( addBufferI )
 if NumLines() > 0
  PopLocation()
  PROCSortWholeBuffer( addBufferI, NumLines() )
  PROCProcessSortedAdditions( addBufferI )
 else
  PopLocation()
 endif
 PROCAbandonBufferById( addBufferI )
end

proc PROCBigReset()
 gBig2GI = 0
 gBig1GI = 0
 gBig0GI = 0
end

proc PROCBigAddProduct( integer leftI, integer rightI )
 integer leftHiI = 0
 integer leftLoI = 0
 integer rightHiI = 0
 integer rightLoI = 0
 integer part2I = 0
 integer part1I = 0
 integer part0I = 0
 integer carryI = 0
 leftHiI = leftI / BIG_BASE_K
 leftLoI = leftI mod BIG_BASE_K
 rightHiI = rightI / BIG_BASE_K
 rightLoI = rightI mod BIG_BASE_K
 part0I = leftLoI * rightLoI
 carryI = part0I / BIG_BASE_K
 part0I = part0I mod BIG_BASE_K
 part1I = leftHiI * rightLoI + leftLoI * rightHiI + carryI
 carryI = part1I / BIG_BASE_K
 part1I = part1I mod BIG_BASE_K
 part2I = leftHiI * rightHiI + carryI
 gBig0GI = gBig0GI + part0I
 if gBig0GI >= BIG_BASE_K
  gBig0GI = gBig0GI - BIG_BASE_K
  gBig1GI = gBig1GI + 1
 endif
 gBig1GI = gBig1GI + part1I
 if gBig1GI >= BIG_BASE_K
  gBig1GI = gBig1GI - BIG_BASE_K
  gBig2GI = gBig2GI + 1
 endif
 gBig2GI = gBig2GI + part2I
end

proc PROCBigSubtractSmall( integer valueI )
 integer part2I = 0
 integer remainI = 0
 integer part1I = 0
 integer part0I = 0
 part2I = valueI / BIG_BASE2_K
 remainI = valueI mod BIG_BASE2_K
 part1I = remainI / BIG_BASE_K
 part0I = remainI mod BIG_BASE_K
 if gBig0GI < part0I
  gBig0GI = gBig0GI + BIG_BASE_K
  gBig1GI = gBig1GI - 1
 endif
 gBig0GI = gBig0GI - part0I
 if gBig1GI < part1I
  gBig1GI = gBig1GI + BIG_BASE_K
  gBig2GI = gBig2GI - 1
 endif
 gBig1GI = gBig1GI - part1I
 gBig2GI = gBig2GI - part2I
end

string proc FNBigToStringS()
 string answerS[255] = ""
 if gBig2GI > 0
  answerS = Format( gBig2GI ) + Format( gBig1GI : 4 : "0" ) + Format( gBig0GI : 4 : "0" )
 else
  if gBig1GI > 0
   answerS = Format( gBig1GI ) + Format( gBig0GI : 4 : "0" )
  else
   answerS = Format( gBig0GI )
  endif
 endif
 return( answerS )
end

proc PROCAccumulatePair( integer leftPerimeterI, integer rightPerimeterI )
 integer leftBufferI = 0
 integer rightBufferI = 0
 integer leftCountI = 0
 integer rightCountI = 0
 integer leftLineI = 1
 integer rightLineI = 1
 integer leftKeyI = 0
 integer rightKeyI = 0
 integer leftValueI = 0
 integer rightValueI = 0
 leftBufferI = FNGetDpBufferIdI( leftPerimeterI )
 rightBufferI = FNGetDpBufferIdI( rightPerimeterI )
 leftCountI = FNGetDpBufferCountI( leftPerimeterI )
 rightCountI = FNGetDpBufferCountI( rightPerimeterI )
 PushLocation()
 while leftLineI <= leftCountI
  if rightLineI > rightCountI
   break
  endif
  GotoBufferId( leftBufferI )
  GotoLine( leftLineI )
  leftKeyI = Val( GetText( 1, 5 ) )
  leftValueI = Val( GetText( 7, 5 ) )
  GotoBufferId( rightBufferI )
  GotoLine( rightLineI )
  rightKeyI = Val( GetText( 1, 5 ) )
  rightValueI = Val( GetText( 7, 5 ) )
  if leftKeyI < rightKeyI
   leftLineI = leftLineI + 1
  else
   if rightKeyI < leftKeyI
    rightLineI = rightLineI + 1
   else
    PROCBigAddProduct( leftValueI, rightValueI )
    leftLineI = leftLineI + 1
    rightLineI = rightLineI + 1
   endif
  endif
 endwhile
 PopLocation()
end

string proc FNComputeAnswerS()
 integer groupIndexI = 0
 integer dxI = 0
 integer dyI = 0
 integer lenI = 0
 integer leftPerimeterI = 0
 integer rightPerimeterI = 0
 integer subtractI = 0
 string answerS[255] = ""
 PROCBuildGroups()
 PROCInitDp()
 for groupIndexI = 1 to gGroupCountGI
  dxI = FNBufferLineIntI( gGroupDxBufferGI, groupIndexI )
  dyI = FNBufferLineIntI( gGroupDyBufferGI, groupIndexI )
  lenI = FNBufferLineIntI( gGroupLenBufferGI, groupIndexI )
  PROCApplyGroup( dxI, dyI, lenI )
 endfor
 PROCBigReset()
 for leftPerimeterI = 0 to TARGET_N
  for rightPerimeterI = 0 to TARGET_N - leftPerimeterI
   if FNGetDpBufferCountI( leftPerimeterI ) > 0
    if FNGetDpBufferCountI( rightPerimeterI ) > 0
     PROCAccumulatePair( leftPerimeterI, rightPerimeterI )
    endif
   endif
  endfor
 endfor
 PROCBigSubtractSmall( 1 )
 subtractI = 0
 for groupIndexI = 1 to gGroupCountGI
  lenI = FNBufferLineIntI( gGroupLenBufferGI, groupIndexI )
  subtractI = subtractI + ( TARGET_N / ( 2 * lenI ) )
 endfor
 PROCBigSubtractSmall( subtractI )
 answerS = FNBigToStringS()
 return( answerS )
end

proc Main()
 string answerS[255] = ""
 gGroupDxBufferGI = FNCreateTempBufferSafeI()
 gGroupDyBufferGI = FNCreateTempBufferSafeI()
 gGroupLenBufferGI = FNCreateTempBufferSafeI()
 answerS = FNComputeAnswerS()
 CopyToWinClip( answerS )
 Warn( answerS )
 CopyToWinClip( answerS )
end
