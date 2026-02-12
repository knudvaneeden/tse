/************************************************************************
  Author:  Gregg Conklin
  Date:    Wed  23-Jun-1993

  Description:

  A function prototyping macro for C programmers that will copy all of
  the function lines to the top of the file.

  Usage notes:

  To use, add this macro to your TSE.S file, and key assignment to
  your TSE.KEY file, and re-bind the editor using the -b switch of sc.

  An example key assignment might be:

  <Ctrl f>      gcPrototype()

  Alternatively, add the key assignments to this file, and load the
  macro (as an external macro) as needed via the LoadMacro command
  (<ctrl f10><L> or 'menu->macro->load')

  -=-=-=-
  This next way it won't always be in memory, but when you load it, it will
  automatically execute, and change the keydef to reflect that it's in
  memory now.

  TSE.KEY:
  <Ctrl f> LoadMacro("C:\TSE\MAC\PROTOTYP.MAC")

  PROTOTYP.S:
  Proc WhenLoaded()
    gcPrototype()
  end

  <Ctrl f> gcPrototype()
  -=-=-=-
 ************************************************************************/

proc gcPrototype()
    string funcstart[50] = "/* Local Function Declarations */"
    string funcend[50]   = "/* * * * * * * * * * * * * * * */"
    string findfunc[50]  = "^[a-zA-Z_].*\(.*[~;]$"  // Regular expression to
                                                    //   find functions,
                                                    //   stolen from TSE.S
    string line[132]
    integer func_id, current_id = GetBufferId()

    PushBlock()
    PushPosition()

    UnMarkBlock()

    if lFind(funcstart, "^g")                  // If declarations already
        Down()                                 //   exist, erase them and
        MarkLine()                             //   prepare for recreating
        lFind(funcend, "^")                    //   between the existing
        Up()                                   //   funcstart and funcend
        MarkLine()                             //   lines
        DelBlock()
    else
        lFind(findfunc, "gx")                  // Find an empty line above
        BegLine()                              //   the first function to
        while (EndLine())                      //   create a new space for
            Up()                               //   the declarations
            BegLine()
        endwhile

        InsertLine(funcstart)
        Down()
        InsertLine("")
        InsertLine(funcend)
    endif


    func_id = CreateBuffer("Functions", _HIDDEN_)  // Create a temporary
    if func_id == 0                                //   buffer for copying
        func_id = GetBufferId("Functions")         //   the functions to
    endif

    if func_id == 0 or not GotoBufferId(func_id)
        return ()
    endif

    EmptyBuffer()

    GotoBufferID(current_id)
    BegFile()

    if lFind(findfunc, "x")                   // Find the functions in the
        repeat                                //   file to be copied to the
            line = GetText(1, sizeof(line))   //   buffer

            GotoBufferId(func_id)
            if not AddLine(line)
                break
            endif

            GotoBufferId(current_id)

            EndLine()

        until not lRepeatFind()
    endif

    GotoBufferId(func_id)
    BegFile()

    lReplace("{^[a-zA-Z_].*\(.*)}{.*}", "\1; \2", "xn")  // Find & replace to
                                                         //   add ; to
                                                         //   declarations,
                                                         //   allows for
                                                         //   comments after
                                                         //   functions
    MarkLine()
    EndFile()
    MarkLine()
    Copy()

    AbandonFile()

    GotoBufferId(current_id)

    if lFind(funcstart, "^g")            // Insert the functions under the
        Down()                           //   function comment
        Paste()
    endif

    PopBlock()
    PopPosition()

end gcPrototype

/*
proc WhenLoaded()
    gcPrototype()
end WhenLoaded
*/


<keydef> gcPrototype()
