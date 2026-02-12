/*  MAKECSV.S   Macro to change a file of records with
    positionally defined fields in records to a file with comma
    separated value fields in records.
    M. W. Hulse, v.1.1, October 16, 1994  TSE v2.0

    Requires an input file named DEFINEcc.RCD where cc can be any
    two characters.  The format of this file is one line for each
    field desired in the output file. Leave no blank lines.  Each
    line is formatted as follows:

        Field Name, Beginning Column, Field Length, Character Field (Y/N?),

    Where:

        Field Name is a string of up to 16 characters. If used,
        it will be placed in the first line of the output file as
        a header line. It is omisible if not desired in the
        output, however, if omitted for one field, it must be
        omitted for all.

        Beginning Column is the starting column of the field.

        Field Length is width of the field in the input file, ie.
        the number of characters in the field.

        Character Field (Y/N?) indicates whether the field
        contains other than numbers, a leading "-" or a single
        decimal.

    Example:

        Last Name,1,16,Y,
        First Name,17,16,Y,
        Age,32,3,N,

    Fields must be defined in the order they are to appear in the .CSV
    file, but not every field in the input need be used nor do fields
    need to be in the same order as in the source file.

    Results are placed in file RESULTcc.CSV where "cc" is the same
    characters as used in the suffix to DEFINEcc.RCD.

*/

// Global Variables

String  StrField[1]   = ""

Integer StartCol,
        NbrChar,
        DataFile,
        DefineFile,
        ResultFile

PROC MoveHeader()                       // move field names into RESULTnn
    String FieldName[16] = ""

    Loop
        MarkStream()
        lFind(",", "")
        Left()
        FieldName = GetMarkedText()
        UnMarkBlock()
        GotoBufferID(ResultFile)
        EndLine()
        InsertText(Chr(34) + FieldName + Chr(34) + ",", _INSERT_)
        GotoBufferID(DefineFile)
        BegLine()
        If NOT Down() OR CurrChar() < 0
            GotoBufferID(ResultFile)
            EndLine()
            CReturn()
            Break
        EndIf
    EndLoop
END

PROC GetFormat()                        // in DEFINEnn file

    Lfind(",", "")
    Right()
    Markword()
    StartCol = Val(GetMarkedText())
    Lfind(",", "")
    Right()
    Markword()
    NbrChar = Val(GetMarkedText())
    Lfind(",", "")
    Right()
    Markword()
    StrField = GetMarkedText()
END

String PROC ProcessRecord()             // get a field
    String  Text[255] = ""

    GotoColumn(StartCol)                // kill leading blanks
    While CurrChar() == 32
        StartCol = StartCol + 1
        NbrChar  = NbrChar  - 1
        Right()
    EndWhile

    GotoColumn(StartCol + NbrChar - 1)  // kill trailing blanks

    While CurrChar() == 32
        NbrChar  = NbrChar  - 1
        Left()
    EndWhile

    Text = GetText(StartCol, NbrChar)           // get the trimed field
    If StrField == "Y"                          // if string
        Text = Chr(34) + Text + Chr(34) + ","   // put quotes
    Else                                        // otherwise
        Text = Text + ","                       // no quotes
    EndIf
    Return(Text)
END

PROC MoveData()                         // move fields into RESULTnn
    String Text[255]     = ""

// Loop through input file to place records in result file
   Repeat
        GotoBufferID(DefineFile)
        BegFile()

        Repeat                          // loop through the DEFINEnn file
            GetFormat()
            GotoBufferID(DataFile)
            Text = ProcessRecord()

            GotoBufferID(ResultFile)
            EndLine()
            InsertText(Text, _INSERT_)
            GotoBufferID(DefineFile)
            BegLine()
        Until NOT Down() OR CurrChar() < 0
        GotoBufferID(ResultFile)
        CReturn()
        GotoBufferID(DataFile)
        BegLine()
        Message("Line: ", Currline(), " done...")
    Until NOT Down()


END

PROC MakeCSV()

    STRING  fn[2]       = "",
            Q[1]        = "Y"

    Set(Break, On)
    DataFile    = GetBufferID()

// Can file be processed?
    If lFind('"', "G")
        Message("Double quote(s) in file...")
        Ask("Convert to single quote(s) (Y/N)", Q)
        If Q == "Y"
            lReplace(Chr(34), "'", "G")
        Else
            Message("Abandoning macro while you fix the file...")
            Halt
        EndIf
   EndIf
    // Intialize
// Get and load DEFINEcc.RCD file

    If NOT Ask("Enter 2 character DEFINEcc suffix: ", fn)
        Halt
    EndIf
    EditFile("DEFINE" + fn + ".RCD")
    DefineFile = GetBufferID()

// Setup output file
    EditFile("RESULT" + fn + ".CSV")
    ResultFile = GetBufferID()

// Loop through record to place header in result file

    GotoBufferID(DefineFile)
    BegFile()
    If CurrChar() <> 44             // if first character is not a comma
        MoveHeader()
    EndIf
    GotoBufferID(DataFile)
    BegLine()
    MoveData()                      // loop through input file
    GotoBufferID(ResultFile)
    SaveFile()                      // save result file
    AbandonFile()                   // and get out of
    AbandonFile()                   // ...all
    AbandonFile()                   // ...files
END

<Alt i> MakeCSV()
