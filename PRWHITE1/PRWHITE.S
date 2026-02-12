// PRWHITE.S  07/20/1993  07/20/1993
// by Richard Hendricks

// PRWHITE will print the file except for the text areas that are enclosed
// by the exclude marks, '[[[' and ']]]'

// The exclude marks can be anyplace on the line

proc MAIN()
  string exclude_mark_begin[10] = "\[\[\["
  string exclude_mark_end[10] = "\]\]\c\]"
  integer currID = GetBufferID()
  integer BegOrEnd = 1
  string work_file[255] = "þþ PRWHITE þþ"
  string device[30] = Query( PrintDevice )
  string copies[5]  = str( Query( PrintCopies ) )

  PushPosition()
  UnmarkBlock()
  BegFile()
  MarkLine()
  EndFile()
  MarkLine()
  EditFile( work_file )
  BegFile()
  EmptyBuffer()
  CopyBlock()
  UnmarkBlock()
  BegFile()
  LReplace( exclude_mark_begin+".@"+exclude_mark_end, "", "ixn" ) // remove all exclude blocks on the same line
  BegFile()
  while ( LFind( iif( BegOrEnd == 1, exclude_mark_begin, exclude_mark_end ), "ix" ) )
    if( BegOrEnd == 1 )
      UnmarkBlock()
      MarkStream()
      BegOrEnd = BegOrEnd * -1
    else
      DelBlock()
      BegOrEnd = BegOrEnd * -1
    endif
  endwhile

  if BegOrEnd == -1
     EndFile()
     DelBlock()
  endif
  BegFile()

  Ask( "Print to ..", device )
  Set( PrintDevice, device )

  Ask( "Number of copies..", copies )
  Set( PrintCopies, val( copies ) )

  PrintFile()

  AbandonFile()
  GotoBufferID( currID )
  PopPosition()

end MAIN
// end-of-file PRWHITE.S
