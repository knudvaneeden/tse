/*****************************************************************************
file:__DB_EDIT.s      TSE macro to edit  dBase databases             97/02/25

                    RELEASE 01  18 MAR 97  ver 01.54
                    RELEASE 02  05 MAR 97  ver 02.00

                        Author: G. GRAFTON COLE
                     Copyright (c) 1997, GRAFCO INC

  Be in a directory with dBase database and invoke TSE -l__dbedit.
  A picklist of the databases will be presented.

  Released to public domain 97/03/18

  97/03/23  Fix save file ^Z bug.                        Check_Record_Length()
            Add DOS command line entry.                  Open_DBF()
  97/03/26  take in to account fields >= 80 characters
            on 80 column displays and clean up code.     Mark_CurrentField()
            Still needs work.
  97/04/02  A fix for 80 col screen and fields > 80 cols Mark_CurrentField()

 *****************************************************************************
    This macro was hacked in much the same way as I envision Buerg's LIST was,
 starting from a fairly simple concept and continually adding more and more
 bells and whistles.  As a result, some of the structure is a bit convoluted.
 It basically loads a dBase database and allows free form editing.  The bells
 and whistles were added after working with a number of databases and wanting
 more control over and information about the database.  An assembly binary
 file using an indexed array would probably improve performace, but since
 this was a continuing work in progress, it was quicker to stay with editor
 functions.

    A very simple dBase editor macro (dbfEdit v1.2) was coded by Peter Birch
 and was available on the TSE BBS.  That macro gave birth to this one and
 the binary-decimal conversions are his.

   Up front caveats:  This macro was developed on a 200 MHZ Pentium with a
 21 inch monitor set for 100x50 resolution.  It has been run on slower systems
 with 80x25 resolutions and seems to work OK.  Heavy use is made of video
 functions and 'for' loops.  Some video flashing maybe evident on some systems.
 The bottom line - it works !

   An attempt was made to allow the user to changes most of those things that
 I always want to change with every new program.  Be aware that minor changes
 in the wrong place can severely affect the end result of the video functions.
 Example: A DataDef is used to place empty lines in the help window,  Using
          either AddLine() or InsertLine() does not work. I don't know why.

   The overall concept: Use binary file loading, load a dBase database,
 get the pertinent structure, strip the dBase header and reload the
 records with the appropriate line length in a window below a help window.

   The bells and whistles include building a formatted header with the field
 names and maintaining the proper position with scrolling.  Hi-liting the
 current cursor field and displaying the field type.  Confining the cursor to
 the database record length.   Display on screen help for important
 keybindings.  Trapping major editing errors that could corrupt the database
 if saved.

 97/03/29
   Ran into some databases with greater than 80 character fields.  Reworked
 Mark_CurrentField() to work with 80 column screens.  Also fixed some display
 bugs.

   I would appreciate getting any comments, suggestions,  and especially
 any codeing improvments.

   Thanks to George De Bruin for help and suggestions.

                            G. Grafton Cole

   email: 70042.2127@compuserve.com
   fax:   703-451-6312

 =============================================================================
 dBase database stuff:

  WARNING:   Do not change any line lengths in the database while editing

  uses code from: dbfEdit Version 1.2     Peter Birch     02/23/93

 struct DBF_HEADER  (load with se as -b32
   FIRST 32 BYTES -----------
     byte   1        signature;          03 = dBaseIII dbf, 83 = dbf+dbt
     byte   2        year                Date of last update. year = 1900 + year
     byte   3        month               Date of last update. month
     byte   4        day                 Date of last update. day
     ulong  5 - 8    last_rec;           number of database records
     uint   9 - 10   header_bytes;       Number of bytes in the header
     uint   11 -12   rec_size;           the length of each record (in bytes)
     byte            reserved1[ 3];      reserved bytes
     byte            reserved2[ 13];     reserved for local area network access info
     byte            reserved3[ 4];      reserved bytes
   FIELD ARRAY OF 32 BYTES PER FIELD --------
     pos   1 - 11     field name in ASCII
     pos   12         field type in ASCII, C, D, N, or L
     pos   13         ?
     pos   14         ?
     pos   15         ?
     pos   16         ?
     pos   17         field length in hex
     pos   18         number of decimals in hex or 0h
     pos   19         00h
     pos   20         01h field discriptor terminator
     field array terminator   0dh

     The database is terminated with a ^Z, 26h
  ***************************************************************************/

/*========================= Declarations ===================================*/

forward proc Show_Msage(string error, integer errortype)
forward proc Save_DBF()
forward integer proc Check_Record_Length()
forward proc Do_Exit()

constant REC_COUNT_OFFSET    =  5,    // dBase dbf header offsets
         HEADER_SIZE_OFFSET  =  9,
         RECORD_SIZE_OFFSET  = 11,
         WIN2_ROW1           =  7     // sets first data row of window 2

integer gDbworkID,         // buffer ID of dBase work file     Open_DBF()
        gWin1ID,           // buffer ID window 1               Split_Screen()
        gRecCount,         // dBase initial record count       Open_DBF()
        gRecLen,           // dBase fixed record length        Open_DBF()
        gFldRite,          // beginning of next dBase field    Mark_CurrField()
        gFldLeft           // end of previous dBase field      Mark_CurrField()

string
//    gPickList[255] = ".dbf",                            //       Current directory
  gPickList[255] = "e:\vk\fix\*.dbf",
  gDbaseFS[255]  = "",    // the dBase dbf file spec           Open_DBF()
  gDBworkFN[255] = "",    // the dBase work file (window 2)    Open_DBF()
  gFldPos[255]   = "0 ",  // field positions string            Get_FieldData()
  gFldTyps[255]  = "",    // field types string                Get_FieldData()
  gFldToks[255]  = "",    // field name replacement token str  Make_Header()

    // help strings for window 1                               Window1_Display()
  KeyBinding1[255] = "^S = left  1 field   "+
                     "ESC = Exit no save  ^N = Insert blank line",
  KeyBinding2[255] = "^F = right 1 field   ^KS = Save File"+
                     "      F5 Check database ",
  GeneralHelp[255] = "All other editor keys function normaly - F1 for help"

keydef dBfKeys
  <ctrl end>     Save_DBF()
  <ctrl k><s>    Save_DBF()
  <ctrl k><q>    Do_Exit()
  <escape>       Do_Exit()
  <ctrl f>       GotoColumn(gFldRite  + 1)   // field at a time
  <ctrl a>       GotoColumn(gFldLeft  - 1)   // field at a time
  <f5>           Check_Record_Length()
  <ctrl n>       EndLine() InsertLine()  Left() PressKey(32) BegLine()
end dBfKeys

datadef NODATA              // used to size the help window
  " "                       //   any data here will scroll off
  " "                       //   screen as the file is scrolled
  " "                       //   right or overwritten by Display_Header
                            //   Use Window1_Display()
end

//proc debug(string s) VgotoXYabs(1,4) PutLine(s, Length(s)) end

/*====================== Get_Short_Int ======================================
  called by:   Open_DBF
  passed:      position binary
  returns:     decimal
  returns to:  caller
  ==========================================================================*/
integer proc Get_Short_Int(integer nStart)
  integer i

    GotoColumn(nStart)
    i = CurrChar()
    Right()
    i = i + (CurrChar() shl 8)
    return(i)
end   Get_Short_Int

/*====================== Get_Long_Int =======================================
  called by:  Open_DBF
  passed:     position of binary
  returns:    decimal
  returns to: caller
  ==========================================================================*/
integer proc Get_Long_Int(integer nStart)
  integer i

    GotoColumn(nStart)
    i = CurrChar()
    Right()
    i = i + (CurrChar() shl 8)
    Right()
    i = i + (CurrChar() shl 16)
    Right()
    i = i + (CurrChar() shl 24)
    return(i)
end   Get_Long_Int

/*====================== Put_Long_Int =======================================
  called by:  Save_DBF
  passed:     position of binary and decimal
  returns:    nothing
  returns to: caller
  ==========================================================================*/
proc Put_Long_Int (integer nStart, integer NewValue)

    GotoColumn(nStart)
    InsertText(Chr((NewValue)        & 255), _OVERWRITE_)
    InsertText(Chr((NewValue shr  8) & 255), _OVERWRITE_)
    InsertText(Chr((NewValue shr 16) & 255), _OVERWRITE_)
    InsertText(Chr((NewValue shr 24) & 255), _OVERWRITE_)

end   Put_Long_Int

/*====================== Check_Record_Length ================================
    Checks each record for the proper length before saving the database.
    If there is an error, returns to editor at error line.  Only detects
      first of multiple errors, ie a save must be issued for each error.
    Always starts at the top of the file.

  called by:  Save_DBF
  calls:      nothing
  passed:     nothing
  returns:    error
  returns to: caller
  uses:       gRecLen
  ==========================================================================*/
integer proc Check_Record_Length()
  integer error  = FALSE,
          i      = 0,
          badEOF = FALSE

   PushPosition()                       // save current position
   GotoLine(1)                          // position
   GotoColumn(1)

   for i = 1 to NumLines()              // check each line
     GotoLine(i)
     EndLine()
     if Currcol() < gRecLen + 1         // EndLine is 1 chr > than gRecLen
        BegLine()
        if CurrChar() == 26  and NumLines() == CurrLine()   // ^Z at end of file
          goto NEXT                                         //   expected
        else
          badEOF = TRUE
          goto NEXT                     //   but user may goto end of file
        endif                           //   a hit return, so continue check

        Show_Msage("Line: " + Str(i) + " IS TOO SHORT", 1)
        error = TRUE
        PopPosition()                   // clear stack
        GotoLine(i)                     // goto error line
        ScrollToCenter()
        return(error)
     endif

     if CurrCol() > gRecLen + 1
        Show_Msage("Line: " + str(i) + "  IS TOO LONG", 1)
        error = TRUE
        PopPosition()                   // clear stack
        GotoLine(i)                     // goto error line
        ScrollToCenter()
        return(error)
     endif

     NEXT:
     if badEOF                          // lines beyond ^Z eof marker
        Show_Msage(" FATAL ERROR ", 3)
        badEOF = FALSE
        return(error)
     endif
   endfor

   Show_Msage("dBase OK to save",0)
   PopPosition()                        // to previous position
   return(error)
end  Check_Record_Length

/*====================== Save_DBF ===========================================
  If Check_Record_Length() returns 0 (errors), open a temp file in which the
     the work file is re-combined with the dBase header (with updated number
     of records).  Renames original dBase disk file to .BKK, renames the
     temp file to the original dBase disk file name, and returns to the
     work file.

  called by:   Key bindings in KeyDef
  calls:       Check_Record_Length()
  passed:      nothing
  returns:     nothing
  returns to:  work file
  uses:        gRecCount,  gDbworkID,  gdBaseFS, gDbaseFS, dBeditFN
  ==========================================================================*/
proc Save_DBF()
   integer  newRecCount,
            ID
   string CurrPath[255] = SplitPath(gDbaseFS, _DRIVE_|_PATH_),
          DbaseFN[255]  = SplitPath(gDbaseFS, _DRIVE_|_NAME_)

    if Check_Record_Length()
       Return()
    endif

    // get new record count
    EndFile()
    Left()
    newRecCount = CurrLine() - iif(CurrChar() == 26, 1, 0)  // -1 for ^Z


    BegFile()                                         // mark curr work file
    MarkStream()
    Endfile()
    MarkStream()

    EraseDiskFile(CurrPath + "$tmp.dbf")
    if Editfile("-b1000 "+ CurrPath +"$tmp.dbf")      // open temp file
       ID = GetBufferID()
       CopyBlock()                                    // copy curr work file
       BegFile()
       InsertFile(gDBworkFN + ".HDR")                 // put back dbase header

       if (newRecCount <> gRecCount)                  // if rec count changed
         Put_Long_Int(REC_COUNT_OFFSET, newRecCount)  // correct it
       endif
       SaveFile()                                     // save temp file

         // rename dBase disk file to .BKK, rename temp file to dBase disk file
       EraseDiskFile(DbaseFN + ".BKK")
       if RenameDiskFile(gDbaseFS, DbaseFN + ".BKK")
          if RenameDiskFile(CurrPath + "$tmp.dbf", gDbaseFS)
             Show_Msage("File is saved",0)
          else
             RenameDiskFile(DbaseFN + "BKK", DbaseFN + "DBF")
             Show_Msage("**** UNABLE TO SAVE FILE ****",0)
          endif
       else
          RenameDiskFile(DbaseFN + "BKK", DbaseFN + "DBF")
       endif

       GotoBufferId(gDbworkID)                          // return to work file
       AbandonFile(ID)                                  // release temp file
     endif

end  Save_DBF

/*====================== Show_Msage =========================================
   Opens an message window and displays message

  called by:
  calls:       nothing
  passed:      message and message type
  returns:     nothing
  returns to:  caller
  ==========================================================================*/
proc Show_Msage(string msage, integer msagtype)
  integer j = Query(attr),
          i = (Query(ScreenCols) - 50)/2   // center window on screen

    case msagtype
    when 0
      PopWinOpen(i,4,i+50,6,1,"",Color(black on white))
      ClrScr()
      Set(attr, Color(red on white))
      PutCtrStr(msage,1)
      WindowFooter(" Press and key to return ")
    when 1
      PopWinOpen(i,4,i+50,11,1,"Error",Color(black on white))
      ClrScr()
      Set(attr, Color(red on white))
      PutCtrStr(msage,1)
      Set(attr, Color(black on white))
      VGotoXY(1,3)
      WriteLine("This error will corrupt the database. You can not")
      WriteLine("save the database until the error is corrected")
      WriteLine("         Cursor will be on error line         ")
      WindowFooter(" Press and key to return ")
    when 2
      PopWinOpen(i,4,i+50,12,1,"Fatal Error",Color(black on white))
      ClrScr()
      Set(attr, Color(red on white))
      PutCtrStr("file: " + msage,1)
      Set(attr, Color(black on white))
      VGotoXY(1,3)
      PutCtrStr("This is not a dBase database file.  You must",2)
      PutCtrStr("be the directory with the database files",3)
      PutCtrStr("when you invoke this program",4)
      PutCtrStr("Database files end with a '.DBF' extension",5)
      WindowFooter(" {Press and key to exit} ")
    when 3
      PopWinOpen(i,4,i+50,12,1,"Fatal Error",Color(black on white))
      ClrScr()
      Set(attr, Color(red on white))
      PutCtrStr( msage,1)
      VGotoXY(1,3)
      PutCtrStr("The " + Chr(26) + " character marks the end",2)
      PutCtrStr("of the dBase file structure and MUST BE",3)
      PutCtrStr("the first and only character on the last",4)
      PutCtrStr("line.  NOTHING is permitted beyond it.",5)
      WindowFooter(" {Press and key to continue} ")
    endcase
    GetKey()
    PopWinClose()
    Set(attr, j)
end  Show_Msage

/*====================== Quit_Edit ==========================================
   If macro is invoked from DOS with errors, clean exit to DOS

  called by:   Open_DBF
  calls:
  passed:
  returns:
  returns to:  DOS
  ==========================================================================*/
proc Quit_Edit()

    If CurrFileName() == "[unnamed-1]"
      AbandonFile()
    endif
    PurgeMacro(CurrMacroFilename())
    halt
end

/*====================== Open_DBF ===========================================
  Attemps to open a binary file from a picklist. Checks for a dBase dbf file.
    Checks dbf file for proper header. Checks dbf file to see if it will
    fit into editor. On any error, exits this macro.

  called by:   Do_Process()
  calls:       Show_Msage(), Get_Long_Int(), Get_Short_Int()
  passed:
  returns:
  returns to:  caller
  def\uses:    gDbworkID, gDBworkFN, gRecCount, gRecLen, gPickList, gdBaseFS
  ==========================================================================*/
proc Open_DBF()
  integer  HeaderLen,
           cmd     = Pos("-L",Upper(Query(DOScmdLine))),
           i, km
  string   s0[100] = Upper(Query(DOScmdLine))

   // If invoked from DOS.  If filname is first and macro second, the macro
   //  never executes ????.  Macro MUST load first !!!!
   if cmd == 0 or GetToken(s0, " ",2) == ""
       gDbaseFS = PickFile(gPickList)
   elseif GetToken(s0[1:2], " ",1) == "-L"
       gDbaseFS = GetToken(s0, " ",2)
       if not Pos(".DBF",s0)
         gDbaseFS = gDbaseFS + ".DBF"
           // if no ext, editor loads the filename and then loads a second
           //   filename + the dbf ext.
           //   Abandonfile kills the first filename and on exit returns to DOS
         AbandonFile()
       endif
   endif

   if Length(gDbaseFS) == 0                             // ESC pressed
      Quit_Edit()
   elseif Upper(SplitPath(gDbaseFS,_EXT_)) <> ".DBF"    // if loaded from
      Show_Msage(Upper(gDbaseFS) ,2)                    //  picklist, unnecessary
      Quit_Edit()                                       //  if picklist(".dbf")
   endif

   EditFile("-b1000 " + gDbaseFS)

        // check signature byte for a valid database file
   if (CurrChar() <> 3 and CurrChar() <> 83)
      Show_Msage(Upper(CurrFilename()) ,2)
      AbandonFile()
      halt
   endif
        // check record length will fit into editor
    gRecLen = Get_Short_Int(RECORD_SIZE_OFFSET)
    if gRecLen > MaxLineLen
       Show_Msage("Record Length is too long for editor",0)
       AbandonFile()
       halt
    endif

    gRecCount  = Get_Long_Int(REC_COUNT_OFFSET)         // get record count

    HeaderLen  = Get_Short_Int(HEADER_SIZE_OFFSET)      // get header size
    PushBlock()
    GotoLine(1)                                         // mark database header
    GotoColumn(1)
    MarkStream()
    for i = HeaderLen downto 1001 by 1000
       Down()
    endfor
    GotoColumn(i)
    MarkStream()

          // save header for later retrevial
    gDBworkFN = Splitpath(gDbaseFS, _NAME_)
    SaveBlock(gDBworkFN + ".HDR", _OVERWRITE_)

          // create working file without header
    km = Set(KillMax, 0)                        // disable deletion buff
    DelBlock()                                  // get rid of header
    SaveAs(gDBworkFN + ".FLD", _OVERWRITE_)
    Set(KillMax, km)                            // enable deletion buff

          // replace current with working file
    BinaryMode(gRecLen)                          // set binary for record length
    ReplaceFile(gDBworkFN + ".FLD")
    gDbworkID = GetBufferID(CurrFileName())
    PopBlock()
end  Open_DBF

/*====================== Do_Exit ============================================
   Exit macro and all created files and cleanup

  called by:
  calls:      nothing
  passed:     nothing
  returns:    nothing
  returns to: invoking source
  uses:       gThisMacro, gDbworkID, gDbaseFS
  ==========================================================================*/
proc Do_Exit()
  string s[255] = SplitPath(gDbaseFS,_NAME_)

    EraseDiskFile(s + ".FLD")               // delete if any
    EraseDiskFile(s + ".HDR")
    OneWindow()                             // restore one window
    AbandonFile(gDbworkID)                  // abandon work file
    // if macro is invoked from the command line
    // with no filename, loads a file [unnamed-1] and the invokes macro
    If CurrFileName() == "[unnamed-1]"
      AbandonFile()
    endif
    Disable(dBFKeys)
    EndProcess()
    PurgeMacro(CurrMacroFilename())
end  Do_Exit

/*===================== MAKE_HEADER ========================================
    Makes up a formatted header string(s) for current dBase work file.

  call by:    Get_FieldData
  passed :
      NamStr: space delimited string containing the names of the dBase fields
      LenStr: space delimited string containing the length of the dBase fields
    referenced stings:
      FldNams1: string for formatted dBase field header up to 254 characters
      FldNams2: contains addition 254 characters of header if needed
  returns:    nothing
  returns to: caller
  def/uses:   gFldToks
  =========================================================================*/
proc Make_Header(string NamStr, string LenStr, var string FldNams1, var string FldNams2)
   integer fldL,                     // field length
           HD2 = False,              // second field header string needed
           i, j, k

   string TmpHeader[255] = "Ø ",     // temporary FldNams string
          fldN[255]      = "",       // current field name
          s[2]           = "à",      // single field name starting token
          st[50]         = ""        // temporary

    // vertical bars are used as field separators, thus the effective field
    // length must be one less that the actual field length since there is no
    // seperation between fields in a binary file and one bar must be in a field
    // data column
    // ie      |------ name -------|------- name ------|--
    // where   ==== field data ====----- field data ---======

    for i = 1 to NumTokens(NamStr, " ")

        fldN = GetToken(NamStr," ",i)         // field name
        fldL = Val(GetToken(LenStr," ",i))    // length of field
        j    = fldL - Length(fldN)            // white space

        if j <= 0//- 1                                   // Field > field length
           gFldToks = gFldToks + s + " = "+ fldN + " ³ " // build token string
           fldN = s                                      // assign token
           s = Chr(Asc(s)+1)                             // increment token

             //TOKEN special cases
           if fldL > 3
              j = fldL - 1
           elseif fldL == 3
              j = 2
           elseif fldL == 2
              j = 1
           else
              j = 0
           endif
        endif

        case j                                          // special cases
          when  0                                       // fldnam = fldlen
             TmpHeader = TmpHeader + fldN
          when  1                                       // fldnam 1 less fldlen
             TmpHeader = TmpHeader + fldN +  "Ø"
          when  2                                       // fldnam 2 less fldlen
             TmpHeader = TmpHeader + fldN + " Ø"
          when  3                                       // fldnam 3 less fldlen
             TmpHeader = TmpHeader + " " + fldN + " Ø"
        endcase

        st   = ""                                       // initialize
        if j > 3 and j mod 2 == 1                       // ODD FIELD LENGTHS
           k   = j/2 - 1                                //   space on either
           st = Format(st:k:"Í")                        //   side of fldnam
           TmpHeader = Rtrim(TmpHeader) + st + " " + fldN + " " + st +"Ø"
        endif

        if j > 3 and j mod 2 == 0                       // EVEN FIELD LENGTHS
           k   = (j-1)/2 - 1
           st  = Format(st:k:"Í")
           TmpHeader = Rtrim(TmpHeader) + st + " " +fldN + " " + st + "Í" + "Ø"
        endif

        // if FldNams1 near 255, store it and start on FldNams2
        if Length(TmpHeader) + Val(GetToken(LenStr," ",i+1)) > 252
           FldNams1  = TmpHeader
           TmpHeader = ""
           HD2       = True
        endif
    endfor

    if HD2
        FldNams2 = TmpHeader
    else
        FldNams1 = TmpHeader
    endif
    Return()

end  Make_Header

/*====================== Get_FieldData ======================================
   Binary loads the dBase header file and extracts the field names and
      their lengths into two space delimited strings which are used to
      build a field-name header line for the database
      Assumes that the sum of all (field names + 1) is less than 255.
        ie- a max of 21, 11 character field names.
   A Global string gFldPos contains begining column of each field.
   A Global string gFldTyps contains formatted field-types

  called by: Split_Screen
  calls:     Make_Header
  passed:    strings Header1 and Header2 (formaatted headers) by references
  returns:   nothing
  returns to: caller
  def/uses:   gDBworkFN, gFldPos, gFldTyps
  ==========================================================================*/
proc Get_FieldData(var string Header1, var string Header2)
   integer tmpID, h, i, j = 1

   string FldNames[255] = "",          // space delimited field names
          FldLens[255]  = "",          // space delimited field lengths
          fldN[255]     = "",          // current formatted field name
          FldT[255]     = "",          // current formatted field type
          FldNams1[255] = "",          // formatted field name header
          FldNams2[255] = "",          // overflow if 1 > 255
          s[50]         = "",
          d[12]

    // binary edit the working file with the correct record line length
    Editfile("-b32" + " " + gDBworkFN + ".HDR")
    tmpID = GetBufferID()

    while down()
       GotoColumn(1)                                 // field name position

         // No field seperators in binary header.  If field name is 11 chars
         //  GetWord() will get too much.  Also, unused field name chars
         //  are filled with 0h.  GetWord() considers 0h a character.
       s = ""
       for i = 1 to 11
          if  not Asc(GetText(i,1)) == 0
            s = s + GetText(i,1)
          endif
       endfor

       fldN = Format(s:Length(s) + 1:" ")            // formate field name

       GotoColumn(17)                                // field length position
       i = CurrChar()                                // field length
       j = j + i                                     // field position

       s = GetText(12,1)                             // field type
       case s                                        // FORMATE FIELD TYPES
        when "C"                                     // Char
          FldT= Format(s + "har":5:" ")
        when "N"                                     // Number.#decimals
          h = Asc(GetText(18,1))
          d = iif(h == 0, "", "d")                   // number of decimals
          s = s + "umber."
          FldT = " " + Format(s:7:" ") + Format(d:h:d)
        when "L"                                     // Logic
          FldT = Format(s + "ogic":6:" ")
        when "D"                                     // Date
          FldT = Format(s + "ate":5:" ")
        when "M"
          FldT = Format(s + "emo":5:" ")
       endcase


       if i > 0
         if Length(FldNames) + Val(Str(i)) < 254   // keep string length < 255
            FldNames = FldNames + fldN             // build field names string
            s = Format(Str(i):-4:" ")
            FldLens = FldLens + s                  // build field lengths string
            s = Format(Str(j):-4:" ")
            gFldPos  = gFldPos  + s                // build field positions string
            gFldTyps = gFldTyps + FldT             // build field types string
         else
          // space delmited field name string > 254 characters
          // SOME KIND OF ERROR AND EXIT ??
         endif
       endif
     endwhile

    Make_Header(FldNames, FldLens, FldNams1, FldNams2)

    Header1 = FldNams1     // formatted header strings from Make_Header
    Header2 = FldNams2

    AbandonFile(tmpID)
    Return()

end Get_FieldData

/*====================== Split_Screen =======================================
   Open 'system' help window as window 1 above the dBase work
      file (window 2) and put help data on lines 1 thru 3. Field name token
      list on row 4 and the field name header just above the work file on
      line 5.  Puts the current field type in an unused area.

  called by:  Do_Process
  passed:     nothing
  returns:    nothing
  returns to: caller
  uses:       gWin1ID, gDbworkID, WIN2_ROW1
  ==========================================================================*/
proc Split_Screen()
    integer j,
            i = WIN2_ROW1 - 4     // window size (lines)

  string  Header1[255] = "",
          Header2[255] = ""

   Get_FieldData(Header1, Header2)    // Get formatted header string

   PrevFile()                     // assure help widow is window 1

   CreateTempBuffer()             // open system help buffer
   gWin1ID = GetBufferID()

   if HWindow()                   // split screen into two windows
      GotoBufferID(gDbworkID)     // force work file into window 2
      GotoWindow(1)               // window 1, help window
      j = Query(WindowRows) - i   // calculate desired window rows
      ResizeWindow(_DOWN_,j)      // resize window 1 (rows)

      InsertData(NODATA)          // insert blank lines for help

      GotoBlockEnd()              // goto end of data block
      UnmarkBlock()               // unmark data block
      AddLine()                   // add blank line (header line)

//      MarkStream()                // insert database header
      InsertText(header1)         // strings are a max of 255
      EndLine()                   // use two strings for headers
      InsertText(header2)         // longer than 255
//      MarkStream()                // and use block attr
      GotoColumn(1)
   endif

   GotoWindow(2)                  // position to work file
   Return()
end   Split_Screen

/*====================== Window1_Display ====================================
   Puts appropriate help data in window 1 and maintains the data and
     field header positions regardless of virtual window position.
   Overlays the header line with a video copy.  The video copy uses the
     header text as a data source.

  called by:   Do_Process
  passed:
  returns:
  returns to:  caller
  uses:        gWin1ID, gDbworkID, gFldPos, gFldTyps, gFldToks
  ============================================================================*/
proc Window1_Display()
    integer ScrCols  = Query(screencols),
            headline = 6,
            DefAtt, CurPos, Offset,
            i, j, k ,x

   string st[255] = "",
          s[255]  = "",
          FT[12]  = ""

      Hook(_AFTER_UPDATE_DISPLAY_, Window1_Display)
                                           // FIELD HEADER
      CurPos = CurrPos()                   // cursor position in window 2
      PushPosition()                       // save it
      GotoBufferId(gWin1ID)                // window 1
      Offset = CurPos - Wherex() + 1       // virtual pos col 1 in window 1
      st = GetText(Offset, ScrCols - 1)    // header at vertual column 1

      DefAtt = Set(attr, Color(bright black on white))
      VGotoXY(1, headline)                 // begin of header line
      PutLine(st, ScrCols)                 // field names header

      for i = 1 to Length(st)              // parse header 1 char at
        s = GetText(Offset+i,1)            //   a time for gFldToks
        case s
          when  "à".."ð"                   // is 's' a token
             VGotoXY(i+1,headLine)                  // position to token
             PutAttr(Color(bright red on cyan),1)   // highlight token
        endcase
      endfor

      Set(attr,Color(bright cyan on blue))        // KEYDEFS
      VgotoXY(1,2)
      PutLine(KeyBinding1, ScrCols)
      VgotoXY(1,3)
      PutLine(KeyBinding2, ScrCols)
      VgotoXY(1,4)
      PutLine(GeneralHelp, Length(GeneralHelp))


      for i = 1 to NumTokens(gFldPos, " ")    // CURRENT FIELD TYPE
        j = Val(GetToken(gFldPos, " ", i))    // starting col current field
        k = Val(GetToken(gFldPos, " ", i+1))  // starting col next field

        if CurPos > j and CurPos <= k         // relative screen cursor position
           x = i                              // index into curr gFldTyps
        endif
      endfor

      FT = GetToken(gFldTyps, " ", x)         // Current Field Type
      VgotoXYabs(68,4)
      PutStr("               ")               // clear previous
      VgotoXYabs(68, 4)
      Set(attr, Color(red on white))
      PutLine(" " + FT + " ", Length(FT) + 2)

      Set(attr,Color(bright red on blue))     // FIELD-TOKEN HELP LINE
      VgotoXY(1, 5)
      PutLine(" " +  gFldToks, ScrCols)       // gFldToks + fld name

      Set(attr, DefAtt)
      GotoBufferID(gDbworkID)                 // return to edit buffer
      PopPosition()
end  Window1_Display

/*====================== Mark_CurrField =====================================
  Hightlights the field defined by the cursor position.  If the field is
    partially off screen, scrolls it on so the entire field is visible

  Video functions are limited to the actual video screen.  If a video
     function writes a string that extends beyond the screen boundry, it will
     wrap to the next line.  Block marking does not have this limitation.
  Determine what field the cursor is in and then mark the field with a column
     block.  Use the right and left edges of the block to detrmine if the
     block is completely on screen.  If not, scroll it on screen.  Then use
     video attr's to re-mark the field.  The block edges are also use to find
     the beginning or end of the next or previous field for scrolling by field
     at a time (KeyDefs).
  Also hi-lite the cursor line different from the field
  The end result is hi-lited window of field width at the current cursor
     location in which the cursor can move while the widow remains
     stationary
  Because of the hooks, a short if clause is used to confine the cursor
     movement to the record length.

  called by:  Do_Process
  passed:     nothing
  returns:    nothing
  returns to: caller
  def/uses:   WIN2_ROW1, gFldRite, gFldLeft, gFldPos, gRecLen
  ==========================================================================*/
proc Mark_CurrField()
  integer i, j,             // loop counters
          AfldL,            // absolute field  left column
          AfldR,            // absolute field right column
          BlockB,           // block beginning column
          BlockE,           // block ending    column
          ScrR,             // number screen rows with data
          WinRow = Query(WindowRows),
          WinCol = Query(WindowCols),
          x

   Hook(_AFTER_COMMAND_ , Mark_CurrField)
   Hook(_AFTER_UPDATE_DISPLAY_, Mark_CurrField)

   for i = 1 to NumTokens(gFldPos," ")                // get current field pos
     AfldL = Val(GetToken(gFldPos," ",i))
     AfldR = Val(GetToken(gFldPos," ",i+1))

     if AfldL == 0                                    // column 1 off limits
         AfldL = 1
     endif
       // as long as the cursor is in the field mark it
     if CurrPos() > AfldL and CurrPos() <= AfldR      // if cursor in field
        PushBlock()
          // mark the current window field position
        MarkColumn(1, AfldL + 1, WinRow, AfldR)

        BlockB   = Query(BlockBegCol)
        BlockE   = Query(BlockEndCol)
        gFldRite = BlockE                       // for ^F KeyDef
        gFldLeft = BlockB                       // for ^A KeyDef

          // special case for screen cols = 80 and field >= 80
        if BlockE - BlockB >= 79 and WinCol == 80
             // if block at already at left of screen, don't scroll,
             // use editor scroll to allow cursor to end of field
           if Query(BlockBegCol) > CurrXoffset() + 4
               // position block
              while Query(BlockBegCol) - 1 <> CurrXoffset()
                 ScrollRight()
              endwhile
           endif
        else
           // If the marked field extends beyond the right screen edge
           //   scroll it back on screen for video marking
           while BlockE > WinCol + CurrXoffset() - 1
               scrollRight()
           endwhile
        endif
           // If the marked field extends beyond the left screen edge
           //   scroll it back on screen for video marking
        if BlockB <= CurrXoffset()
            while BlockB < CurrXoffset() + 1
                ScrollLeft()
            endwhile
        endif


        x = BlockB - CurrXoffset()  // relitive left edge of field

          // number of rows to mark, have to account for EOF
        ScrR = min(WinRow, Query(blockendline)) + WIN2_ROW1 - 1

        UnmarkBlock()                            // finished with block

        for j = WIN2_ROW1 to ScrR                // re-mark field with video
          VgotoXYabs(1,j)                        // relitive col 1, row m
            // clear previous video marking
          PutAttr(Color(bright green on blue), WinCol)
            // mark current field
          VgotoxYabs(x,j)
          PutAttr(Color(bright black on white),AfldR-AfldL)
        endfor
        VgotoXYabs(x,CurrRow() + WIN2_ROW1 - 1)    // current cursor row
        PutAttr(Color(red on white), AfldR-AfldL)  // hi-lite cursor row

        PopBlock()                                 // restore previous block
     endif
   endfor

   if CurrPos() == 1              // column 1 is not valid
      Right()
   endif

   if CurrPos() > gRecLen         // confine cursor to record length
      EndLine()
      Left()
   endif

end  Mark_CurrField

/*===========================================================================
   Use Process to control the exit and cleanup when done editing
  =========================================================================*/
proc Do_Process()
  integer iniWrap   = Query(WordWrap),
          iniInsert = Query(Insert),
          iniInsCur = Query(OverwriteCursorSize),
          iniWhite  = Query(RemoveTrailingWhite),
          iniEOF    = Query(EofType),
          iniTxt    = Query(TextAttr),
          iniBor    = Query(CurrWinBorderAttr),
          iniBlock  = Query(BlockAttr)

   if Enable(dbfKeys, _DEFAULT_)
      PushBlock()
      Set(WordWrap,            OFF)                // setup for edit
      Set(OverwriteCursorSize,   4)
      Set(Insert,              OFF)
      Set(RemoveTrailingWhite, OFF)
      Set(EofType,             0)
      Set(TextAttr, Color(bright white on blue))
      Set(CurrWinBorderAttr, Color(blue on blue))
      Set(BlockAttr, Color(bright green on cyan))
Set(break, ON)
      Split_Screen()
      Window1_Display()
      Mark_CurrField()

      Process()

      Set(RemoveTrailingWhite, iniWhite)
      Set(OverwriteCursorSize, iniInsCur)
      Set(Insert,              iniInsert)
      Set(WordWrap,            iniWrap)
      Set(EofType,             iniEOF)
      Set(TextAttr,            iniTxt)
      Set(CurrWinBorderAttr,   iniBor)
      Set(BlockAttr,           iniBlock)
      PopBlock()

      Do_Exit()
      halt                              // needed for invoking from DOS
   endif
end

/****************************************************************************/
proc WhenLoaded()
    Open_DBF()
    Do_Process()
end

/**************
proc gStat_ShowHex()
    string  cStr[15] = Chr(Query(StatusLineFillChar))
    integer saveAttr = Query(Attr),
            curChar  = CurrChar()

   case curChar    // get hex and decimal numbers of character under cursor
   when -1
       cStr = Format(Chr(curChar), Chr(Query(StatusLineFillChar)),
                       '<EOL>':-8:Chr(Query(StatusLineFillChar)))
   when -2
       cStr = Format(Chr(curChar), Chr(Query(StatusLineFillChar)),
                       '<EOL+>':-8:Chr(Query(StatusLineFillChar)))
   otherwise
       cStr = Format(Chr(curChar), Chr(Query(StatusLineFillChar)),
                       Str(curChar, 16):2, 'h,', curChar:3, 'd')
   endcase

    Set(Attr, Color(bright yellow on cyan))
    VGotoXY(Query(ScreenCols) - 12, Query(StatusLineRow))
    PutStr(cStr)
    Set(Attr, saveAttr)
end gStat_ShowHex

proc gStat_ShowHexToggle()
    statlinehex_mode = statlinehex_mode ^ 1       // XOR flips bits
    if statlinehex_mode
       Hook(_IDLE_, gStat_ShowHex)
       Hook(_AFTER_UPDATE_STATUSLINE_, gStat_ShowHex)
    else
       Unhook(gStat_ShowHex)
    endif
end
  ****************/
