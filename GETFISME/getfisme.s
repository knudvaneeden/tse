FORWARD INTEGER PROC FNBlockGetBufferMemorySizeCurrentI()
FORWARD INTEGER PROC FNFileGetBufferMemorySizeCurrentI()
FORWARD PROC Main()


// --- MAIN --- //

PROC Main()
 Warn( "Total bytes used in this buffer", " ", "=", " ", FNFileGetBufferMemorySizeCurrentI() ) // gives e.g. 12345 bytes as filesize on memory
END

<F12> Main()

// --- LIBRARY --- //

// library: file: get: size: buffer: memory: current <description></description> <version control></version control> <version>1.0.0.0.5</version> <version control></version control> (filenamemacro=getfisme\getfisme.s) [<Program>] [<Research>] [kn, ri, sa, 05-09-2026 18:24:30]
INTEGER PROC FNFileGetBufferMemorySizeCurrentI()
 // e.g. PROC Main()
 // e.g.  Warn( "Total bytes used in this buffer", " ", "=", " ", FNFileGetBufferMemorySizeCurrentI() ) // gives e.g. 12345 bytes as filesize on memory
 // e.g. END
 // e.g.
 // e.g. <F12> Main()
 //
 INTEGER I = 0
 //
 PushPosition()
 PushBlock()
 //
 MarkAll()
 //
 I = FNBlockGetBufferMemorySizeCurrentI()
 //
 PopBlock()
 PopPosition()
 //
 RETURN( I )
 //
END

// library: block: get: size: memory: current <description></description> <version control></version control> <version>1.0.0.0.12</version> <version control></version control> (filenamemacro=getblsme.s) [<Program>] [<Research>] [kn, ri, sa, 05-09-2026 18:29:07]
INTEGER PROC FNBlockGetBufferMemorySizeCurrentI()
 // e.g. PROC Main()
 // e.g.  Warn( FNBlockGetBufferMemorySizeCurrentI() ) // gives e.g. 12345 bytes as blocksize in memory
 // e.g. END
 // e.g.
 // e.g. <F12> Main()
 //
 INTEGER I = 0
 INTEGER minI = Query( blockBegLine )
 INTEGER maxI = Query( blockEndLine )
 //
 INTEGER blockSizeI = 0
 //
 IF ( NOT ( IsBlockInCurrFile() ) ) Warn( "Please mark a block" ) RETURN( -1 ) ENDIF // return from the current procedure if no block is marked
 //
 PushPosition()
 PushBlock()
 //
 GotoBlockBegin()
 //
 FOR I = minI to maxI
  //
  blockSizeI = blockSizeI + CurrLineLen() + 2 // always 2 (invisible) characters at the end of the line, ASCII 10 (line feed) and ASCII 13 (carriage return)
  //
  Down()
  //
 ENDFOR
 //
 PopBlock()
 PopPosition()
 //
 RETURN( blockSizeI )
 //
END
