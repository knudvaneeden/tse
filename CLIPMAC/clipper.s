<HelpLine>	"{F2}-If {F3}-Iif() {F4}-Case {F5}-While {F7}-Func {F8}-StatFunc {F11}-SpellCheck"
<Alt HelpLine>	"{Alt: F1}-BeginSequence {F2}-Include {F3}-ForNext"

proc mCenterLine()
    integer right_margin = Query(RightMargin),
        left_margin = Query(LeftMargin),
        first_line, last_line, type, p, center, cid, tid

    PushPosition()
    if left_margin == 0 or left_margin >= right_margin
        left_margin = 1
    endif
    first_line = CurrLine()
    last_line = first_line
    type = isCursorInBlock()
    if type
        Set(Marking, off)
        first_line = Query(BlockBegLine)
        last_line = Query(BlockEndLine)
        if type == _COLUMN_
            GotoBlockBegin()
            cid = GetBufferId()
            tid = CreateTempBuffer()
            CopyBlock()

            /*
              Need to make sure we overlay everything with spaces
             */
            PushBlock()
            GotoBufferId(cid)
            CopyBlock(_OVERWRITE_)
            FillBlock(' ')
            GotoBufferid(tid)
            PopBlock()

            last_line = last_line - first_line + 1
            first_line = 1
            left_margin = 1
            right_margin = Query(BlockEndCol) - Query(BlockBegCol) + 1
        endif
    endif
    if right_margin > left_margin
        GotoLine(first_line)
        repeat
            p = PosFirstNonWhite()
            center = ((p + PosLastNonWhite()) / 2) - ((left_margin + right_margin) / 2)
            ShiftText(iif(center > 0,
                - (iif(center < p, center, p - 1)), Abs(center)))
        until (not RollDown()) or CurrLine() > last_line
        if type == _COLUMN_
            GotoBufferId(cid)
            CopyBlock(_OVERWRITE_)
            AbandonFile(tid)
        endif
    endif
    PopPosition()
end mCenterLine

proc IfEndif()
   integer IfElses=0
   string ElseIfs[1]="",answer[1]=" ",IfString[40]=""

   ask("Enter the desired 'if' condition:",IfString)
   ask("How many 'elseif' clauses do you want?",ElseIfs)
   ask("Do you want to include an 'else' clause?",answer)

   IfElses=val(ElseIfs)

	inserttext("if ")
	inserttext(IfString)
	creturn()

   while IfElses>0
   	inserttext("elseif ")
   	creturn()
   	IfElses=IfElses -1
   endwhile

	if answer=="Y" or answer=="y"
		inserttext("else")
		creturn()
		inserttext("endif")
		wordleft()
		find("if","bw")
	else
		inserttext("endif")
		wordleft()
		find("if","bw")
	endif

	endline()
	creturn()
	tabright()
end

proc I_if()
	inserttext("if(,,)")
	left()
	left()
	left()
end

proc DoCase()
	integer cases=1
	string casechoices[2]=""

	ask("How many 'case' clauses do you want?",casechoices)
	cases=val(casechoices)

   inserttext("do case")
   creturn()
   inserttext("endcase")
   up()
   creturn()
   tabright()

	while cases>0
		inserttext("case ")
		creturn()
		cases=cases - 1
   endwhile

   delline()

   find("do case","bw")
   down()
   endline()
end

proc ForNext()
	string startvalue[20]=""
	string endvalue[20]=""
	string loopcounter[20]=""

	ask("Enter your loop-counter's name:",loopcounter)
	ask("What is the loop-counter's starting value:",startvalue)
	ask("What is the loop-counter's ending value:",endvalue)

	inserttext("for ")
	inserttext(loopcounter)
	inserttext(" = ")
	inserttext(startvalue)
	inserttext(" to ")
	inserttext(endvalue)
	creturn()
	inserttext("next")
	up()
	endline()
	creturn()
	tabright()
end

proc DoWhile()
	string condition[40]=""

	ask("Enter your 'while' condition:",condition)

	inserttext("do while ")
	inserttext(condition)
	creturn()
	inserttext("enddo")
	up()
	endline()
	creturn()
	tabright()
end

proc Function()
   string function_name[50]="",return_value[25]=""

   ask("What is the function's name?",function_name)
   ask("What is the function's return value?",return_value)

	inserttext("******************************************************************************")

	copy()
	paste()
	paste()
   down()
   down()
   creturn()
   begline()

   inserttext("function ")
   inserttext(function_name)
   creturn()
   inserttext("/*")
   creturn()
   creturn()
   creturn()
   inserttext("Variable Information")
   mCenterLine()
   endline()
   creturn()
   creturn()
   begline()
   inserttext("*/")
   creturn()
   creturn()
   creturn()

   inserttext("saveenv()")
   creturn()
   creturn()
   creturn()
   creturn()
   inserttext("restenv()")
   creturn()
   creturn()
   inserttext("return ")
   inserttext(return_value)

   up()
   up()
   up()
   up()
   up()
   up()
   up()
   up()
   begline()
end

proc StaticFunction()
	function()
	find("function","bw")
	begword()
	inserttext("static ")
	find("*/","i")
	down()
end

proc CompileRun()
	savefile()
	dos("m",_DEFAULT_)
end

proc BeginEnd()
	inserttext("begin sequence")
	creturn()
	inserttext("end sequence")
	up()
	endline()
	creturn()
	tabright()
end

proc Include()
	inserttext('#include ""')
	left()
end

proc Inline()
	inserttext(":=")
end

proc Spell()
	savefile()
	dos("c:\spell\go "+currfilename(),_DONT_PROMPT_)
end


keydef f_keys
	<F2>			IfEndif()
	<F3>        I_if()
	<F4>        DoCase()
	<F5>        DoWhile()
	<F7>        Function()
	<F8>        StaticFunction()
	<F10>			CompileRun()
	<F11>			Spell()
	<Alt F1>		BeginEnd()
	<Alt F2>    Include()
	<Alt F3>		ForNext()
	<Alt ;>		Inline()
end

proc main()
	enable(f_keys,_DEFAULT_)
end