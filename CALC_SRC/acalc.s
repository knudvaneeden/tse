/*
				  Tuesday, 27 July 1993
*/

/******************* Global Constants and Variables ***********************/
  Constant
	 MaxField = 17,		// max size of input field
	 FieldX	  = 6,		// horiz location of start of field
	 FieldY	  = 2			// verticle location of field


  String
	 Input[MaxField]  = '',		// keyboard input accumulator
	 cursorNumberS[MaxField]  = '',	// Word under cursor
	 BaseLtr[1] = 'd'					// number base indicator


  Integer
	 UpLtCol  = 10,		// initial location for calc window
	 UpLtRow  = 10,		// initial location for calc window
	 BotRtCol = 34,		// initial location for calc window - UpLtCol+24
	 BotRtRow = 15,		// initial location for calc window - UpLtRow+5
	 X	  =  0,				// current input
	 Y	  =  0,				// previous input
	 Base	  = 10,			// number base
	 WordSize = 16,	  // width of word to flip, affects Not, And, Or, Xor
// Booleans
	 New	 = True,  // Flags NEW input
	 InitFlag = False, // flag to initiate vars on firs load only
	 HelpFlag = False, // remember to trap keypress when back from help
// Math flags
	 Add	 = False,				// <----+
	 Subtract = False,		//			|
	 Multiply = False,		//			|
	 Divide	  = False,		//			|
	 Modulo	  = False,		//			|-- flags to control DoMath()
	 ShftRt	  = False,		//			|	 when "=" key is pressed
	 ShftLt	  = False,		//			|
	 AndFlag  = False,		//			|
	 OrFlag	  = False,		//			|
	 XorFlag  = False,		//			|
	 NotFlag  = False			// <----+


/************************************************************************/
/*			  Calculator helper functions				  */
/************************************************************************/
Proc InitRegs()		// initiate variable initial values

	X		 = 0				// zero input value
	Y		 = 0				// zero previous input value
	Base	 = 10			// default to decimal (set via global var???)
	BaseLtr  = 'd'	// decimal indicator
	InitFlag = true	// we're loaded...
End InitRegs
//-------------------------------------------------------------------------
Proc ClrField()	  // Used to clear numbers from field
	Vgotoxy(FieldX,FieldY)  // on screen when being updated with new
	PutLine(' ',MaxField-1) // data.
End ClrField
//-------------------------------------------------------------------------
Proc UpdateField()  // update display
	String Filler[1]=Iif(Base == 2, '0', ' ')	// fill field 0s for binary
																						//  else blanks
	ClrField()
	Vgotoxy(FieldX,FieldY)
	PutLine(Format(X:MaxField-1:Filler:Base,BaseLtr:1),MaxField)
End UpdateField
//-------------------------------------------------------------------------
Proc SetWordSize()  // set number of bits to toggle with AND/OR/XOR/NOT

	Integer	key,
					OldAttr

	Vgotoxy(FieldX,FieldY)									// locate
	PutLine('WordSize?',MaxField)						// and place prompt
	OldAttr = Set(Attr,Query(MenuTextAttr))	// set color to match menus
	Vgotoxy(FieldX,FieldY+1)								// locate
	PutLine('0FEDCBA987654321',MaxField-1)	// and add wordsize indicators
	VgotoXY(FieldX+(MaxField-(1+WordSize)),FieldY+1)	// locate on current size
	PutAttr(Query(MenuTextLtrAttr),1)	// highlight it
	Set(Attr,OldAttr)									// reset color
	key = GetKey() & 0FFh							// get keys char value
	Case key
		When 30h..39h,41h..46h,61h..66h				// number 0..16
	  	Vgotoxy(FieldX+Maxfield-3,FieldY)		// locate to show choice
			If Val(Chr(Key),16)	// if not 0
				WordSize = Val(Chr(Key),16)
			Else					  		// if 0 force to 10h
				WordSize = 16
			EndIf
			PutLine(Format(WordSize:2:'0':16,'h'),3)  // display value for
			Delay(4)			// only short time
			UpdateField()	// redisplay
		When 01Bh				// When Esc do nothing
		UpdateField()		// redisplay
	Otherwise
		SetWordSize()		// recurse until 0..F or Esc
	EndCase
	Set(Attr,Query(MenuTextAttr))				 // set color to match menus
	VgotoXY(FieldX,FieldY+1)				 // locate and replace tic marks
	PutLine(chr(249)+'   '+chr(249)+'   '+chr(249)+'   '+Chr(249),MaxField)
	VgotoXY(FieldX+(MaxField-(1+WordSize)),FieldY+1)// locate wordsize point
	PutLine(Chr(24),1)					 // place arrow indicator
	VgotoXY(FieldX+(MaxField-(1+WordSize)),FieldY+1)// back to arrow location
	PutAttr(Query(MenuTextLtrAttr),1)			 // highlight it
	Set(Attr,OldAttr)						 // reset color
End SetWordSize
//-------------------------------------------------------------------------
Proc Overflow()	  // display warning of pending overflow condition
	Vgotoxy(FieldX,FieldY)			 // locate for output
	PutLine('OVERFLOW',MaxField)  // Error Msg
	Delay(9)				 // pause for a bit
End OverFlow
//-------------------------------------------------------------------------
Proc DoMath()		 // Do the math

	Integer i = 1	  // scratch counter

	String XStr[MaxField-1] = '',   // holds binary string representaion of X
		YStr[MaxField-1] = '',   // holds binary string representaion of Y
		NewStr[MaxField-1] = '', // holds binary string representaion
		AddZeros[MaxField-1] = ''    // accumulates 0's for SHL

	If Add
		If MaxInt - Iif(Y<0,-y,y) >= Iif((X<0 and Y<0),-X,X)  /*check for overflow*/
	  	Y = X+Y
	  	X = Y
		Else
			X = Y
			OverFlow()
		EndIf
		Add = False
	ElseIf Subtract
	// (check for overflow) or (test for underflow ( > -MaxInt))
		If (X > 0 and Y > 0) OR (MaxInt - Iif(Y<0,-y,y) >= Iif((X<0 and Y<0),-X,X))
			Y = Y-X
			X = Y
		Else
			X = Y
			OverFlow()
		EndIf
		Subtract = False
	ElseIf Multiply
		If MaxInt/Iif(X<0 ,-X,X) > Iif(Y<0,-Y,Y) or X == 0 // check for overflow
			Y = Y*X
			X = Y
	Else
		X = Y
		OverFlow()
	EndIf
		Multiply = False
	ElseIf Divide
		Y = Y/X
		X = Y
		Divide = False
	ElseIf Modulo
		Y = Y Mod X
		X = Y
		Modulo = False
	ElseIf ShftRt
		XStr = Format(Y:MaxField-1:'0':2)
		X = Val(SubStr(XStr,1,Length(XStr)-x),2)	//clip off X digits
		ShftRT = False
	ElseIf ShftLt
		XStr = Format(Y:MaxField-1:'0':2)
		Repeat
			AddZeros = AddZeros + '0'  							// add X trailing 0s to Y
			i = i + 1
		Until i > x
		X = Val(SubStr(XStr,1+x,Length(XStr))+AddZeros,2)	//place Val in X
		ShftLt = False
	ElseIf AndFlag
		XStr = Format(X:MaxField-1:'0':2)
		YStr = Format(Y:MaxField-1:'0':2)
		NewStr = SubStr(YStr,1,(MaxField-WordSize)-1)
		i = MaxField - WordSize
		Repeat
			NewStr = NewStr + Str(Val(Ystr[i]) & Val(XStr[i]))
			i = i + 1
		Until i > Length(YStr)
		X = Val(NewStr,2)
		AndFlag = False
	ElseIf OrFlag
		XStr = Format(X:MaxField-1:'0':2)
		YStr = Format(Y:MaxField-1:'0':2)
		NewStr = SubStr(YStr,1,(MaxField-WordSize)-1)
		i = MaxField - WordSize
		Repeat
			NewStr = NewStr + Str(Val(Ystr[i]) | Val(XStr[i]))
			i = i + 1
		Until i > Length(YStr)
		X = Val(NewStr,2)
		OrFlag = False
	ElseIf XorFlag
		XStr = Format(X:MaxField-1:'0':2)
		YStr = Format(Y:MaxField-1:'0':2)
		NewStr = SubStr(YStr,1,(MaxField-WordSize)-1)
		i = MaxField - WordSize
		Repeat
			NewStr = NewStr + Str(Val(Ystr[i]) ^ Val(XStr[i]))
			i = i + 1
		Until i > Length(YStr)
		X = Val(NewStr,2)
		XorFlag = false
	ElseIf NotFlag											// only effects X register
		XStr = Format(X:MaxField-1:'0':2)
		i = MaxField - WordSize
		Repeat
			if XStr[i] == '0'								// if 0 toggle to 1
				XStr = (SubStr(XStr,1,i-1)+'1'+SubStr(XStr,i+1,Length(XStr)))
			Else														// if 1 toggle to 0
				XStr = (SubStr(XStr,1,i-1)+'0'+SubStr(XStr,i+1,Length(XStr)))
			EndIf
			i = i + 1
		Until i > Length(XStr) 						// done
		X = Val(XStr,2)	  								// get bitwise NOT value in X
		NotFlag = False
	EndIf
	UpdateField()
End DoMath
//-------------------------------------------------------------------------
Proc BinHexDecOct(Integer MyBase)		// Dec Hex or Binary Oct mode toggles

	If MyBase == 16
		BaseLtr = 'h'
		Base = 16
	EndIf
	If MyBase == 10
		BaseLtr = 'd'
		Base = 10
	EndIf
	If MyBase == 8
		BaseLtr = 'o'
		Base = 8
	EndIf
	If MyBase == 2
		BaseLtr = 'b'
		Base = 2
	EndIf
	If NOT New
		Input = Str(X,Base)  // make sure input string matches register base
	EndIf
	UpdateField()
End BinHexDecOct
//-------------------------------------------------------------------------
Proc ShadowBox(Integer SwitchOn)			// turn shadow under calc on or off
	If SwitchOn
		PopWinOpen(UpLtCol+1,UpLtRow+1,BotRtCol+1,BotRtRow+1,1,'',Color(Black on Black))
	Else
		PopWinClose()											// turn shadow off
	EndIf
End ShadowBox
//-------------------------------------------------------------------------
Proc CalcBox(Integer Open)	// place the calculator display on the screen
														// or turn it off
	Integer
		OldAttr
	String
		Tic[13] = chr(249)+'   '+chr(249)+'   '+chr(249)+'   '+Chr(249)

	If Open
		PopWinOpen(UpLtCol,UpLtRow,BotRtCol,BotRtRow,1,'Integer Calculator',Query(MenuBorderAttr))
		VgotoXY(1,1)					  // get video cursor in box
		OldAttr = Set(Attr,Query(MenuTextAttr))  // set color to match menus
		clrscr()						  	// clear box
		VgotoXY(FieldX,FieldY+1)
		PutLine(Tic,MaxField)			  // nibble tic marks
		VgotoXY(FieldX+(MaxField-(1+WordSize)),FieldY+1)
		PutLine(Chr(24),1)				  // wordsize indicator
		VgotoXY(FieldX+(MaxField-(1+WordSize)),FieldY+1)
		PutAttr(Query(MenuTextLtrAttr),1)	  // highlight it
		VgotoXY(1,FieldY+2)				 // locate for help line
		PutLine('Esc to Exit, H for help',23)     // short help
		Set(Attr,Query(TextAttr))  // set the attribute to reg edit screen
		ClrField()
	Else
		PopWinClose()  // all done, close window
	EndIf
End CalcBox
//-------------------------------------------------------------------------
Proc MoveBox(integer LtRt, integer UpDn)  // move the box around the screen

	If (UpLtCol + LtRt > 0) AND (UpLtCol + LtRt + 24 < Query(ScreenCols))
		UpLtCol = UpLtCol + LtRt
		BotRtCol = UpLtCol+24
	Else
		Return()
	EndIf
	If (UpLtRow + UpDn > 0) AND (UpLtRow + UpDn + 5 < Query(ScreenRows))
		UpLtRow = UpLtRow + UpDn
		BotRtRow = UpLtRow+5
	Else
		Return()
	EndIf
	CalcBox(Off)			// close the calc window
	ShadowBox(Off)		// erase the shadow
	ShadowBox(On)			// redraw the shadow
	CalcBox(On)				// redraw the window
	UpdateField()			// refill the fields
End MoveBox
/*********************** Temporary help display ***************************/
Proc CalcHelp()	  // minimum help.

	Integer
		OldAttr = Set(Attr,Query(MenuTextAttr))

	HelpFlag = True  // let GetInput know to trap keys entered here.
	PopWinOpen(1,1,42,21,1,'Help',Query(MenuBorderAttr))
	VgotoXY(1,1)
	ClrScr()
/* Put help text in help box */
	VgotoXY(1,2)
	PutLine('Active function keys are hi-lighted',40)
  VgotoXY(1,4)
	PutLine('Base Toggles:',40)
	VgotoXY(1,5)
	PutLine('Hex,  W: Binary,  Octal,  T: Decimal',40)
	VgotoXY(1,7)
	PutLine('Editing:',40)
	VgotoXY(1,8)
	PutLine('Backspace: Delete entry Rt to Lt.',40)
	VgotoXY(1,9)
	PutLine('Delete: Clear entry',40)
	VgotoXY(1,11)
	PutLine('Math:',40)
	VgotoXY(1,12)
	PutLine('< Shl  > Shr  & And  | Or  ^ Xor  \ Mod',40)
	VgotoXY(1,13)
	PutLine('+ Add  - Subtract  * Multiply  / Divide',40)
	VgotoXY(1,14)
	PutLine('Not',40)
	VgotoXY(1,16)
	PutLine('Other:',40)
	VgotoXY(1,17)
	PutLine('Get number under cursor into Field',40)
	VgotoXY(1,18)
	PutLine('Paste Field into Current edit buffer',40)
	VgotoXY(1,19)
	PutLine('Word size [0FEDCBA987654321] (0=10h)',40)
/* Highlight the hotkeys */
	VGotoXY(3,5)
	PutAttr(Query(MenuTextLtrAttr),1)  // hex
	VGotoXY(7,5)
	PutAttr(Query(MenuTextLtrAttr),1)  // binary
	VGotoXY(19,5)
	PutAttr(Query(MenuTextLtrAttr),1)  // octal
	VGotoXY(27,5)
	PutAttr(Query(MenuTextLtrAttr),1)  // decimal
	VGotoXY(1,8)
	PutAttr(Query(MenuTextLtrAttr),9)  // backspace
	VGotoXY(1,9)
	PutAttr(Query(MenuTextLtrAttr),6)  // delete
	VGotoXY(1,12)
	PutAttr(Query(MenuTextLtrAttr),1)  // <
	VGotoXY(8,12)
	PutAttr(Query(MenuTextLtrAttr),1)  // >
	VGotoXY(15,12)
	PutAttr(Query(MenuTextLtrAttr),1)  // &
	VGotoXY(22,12)
	PutAttr(Query(MenuTextLtrAttr),1)  // |
	VGotoXY(28,12)
	PutAttr(Query(MenuTextLtrAttr),1)  // ^
	VGotoXY(35,12)
	PutAttr(Query(MenuTextLtrAttr),1)  // Not
	VGotoXY(1,13)
	PutAttr(Query(MenuTextLtrAttr),1)  // +
	VGotoXY(8,13)
	PutAttr(Query(MenuTextLtrAttr),1)  // -
	VGotoXY(20,13)
	PutAttr(Query(MenuTextLtrAttr),1)  // *
	VGotoXY(32,13)
	PutAttr(Query(MenuTextLtrAttr),1)  // '/'
	VGotoXY(1,14)
	PutAttr(Query(MenuTextLtrAttr),1)  // MOD
	VGotoXY(1,17)
	PutAttr(Query(MenuTextLtrAttr),1)  // Get
	VGotoXY(1,18)
	PutAttr(Query(MenuTextLtrAttr),1)  // Paste
	VGotoXY(3,19)
	PutAttr(Query(MenuTextLtrAttr),1)  // WordSize
/* wait for key before exiting */
	Repeat until keypressed()		  // keep waiting for a keypress
	Set(Attr,OldAttr)				 // restore previous attr
	PopWinClose()			  // close up the box
End CalcHelp
/*********************** Get and display input ****************************/
Proc ShowInput(String tmp) // ShowInput only used by GetInput()

	String	InputTest[MaxField]  = '', // copy of input string
					s[1] = Upper(tmp)	  // force a..f upper case for overflow compare

	If New
		ClrField()		  // if NEW entry clear field
		InPut = s		 // set Input to first char
		New = False		 // after first key no longer 'New'
	// check for string length and overflow
	Elseif Length(Input) <= Length(Str(MaxInt,Base)) and Length(Input) < MaxField-1
		InputTest = Input + s// string for compare
		While InputTest[1] == '0' and Length(InputTest) > 1  // no leading zeros
			InputTest = SubStr(InputTest,2,Length(InputTest)) // strip leading 0s
		EndWhile
		If InputTest <> Str(Val(Input+s,base),base)  // if overflow strings won't match
			Overflow()	  // show error message
		Else
			Input = Input+s  // all is well add new digit on tail
		EndIf
	EndIf
	X = Val(Input,Base)	  // accumulate Real Input
	Vgotoxy(FieldX,FieldY)  // goto field
	PutLine(Format(Input:MaxField-1),MaxField-1)  // write the entered data
End ShowInput
//---------------------------
Proc SetOpFlags()
	Y = X
	New = True			// ready for next entry
End SetOpFlags
//---------------------------
Proc GetInput()		// get keyboard input and display it

	Integer
		Key,					// key character value
		NumKey,				// number value of key
		i							// scratch counter

Loop			 // you're in the loop now, only one way out...
	Repeat until Keypressed()  // keep cycling while waiting for keys
	Key = GetKey()		  // get value
	NumKey = Key & 0FFh  // character value of key (or 0 for numpad or 224 for greykeys)
	If HelpFlag			  // trap key used to exit help
		Key = 255		  // set key to unused value
		NumKey = 0			 // set key to unused value
		HelpFlag = False		 // ready to accept values or commands
	EndIf

	case NumKey			  /***** MAIN INPUT *****/
	 /***** NUMBER INPUT '0'..'9',A..F,a..f *****/

		When 030h..039h,041h..046h,061h..066h  // test if in 'all numbers set'
	  	If Base == 16				  // HEX accepts [0..9,a..f,A..F]
		 		ShowInput(Chr(NumKey))		  // display keyed number
			ElseIf Base == 10				 // DEC accepts [0..9]
		 		Case NumKey
		  		When 030h..039h
			 			ShowInput(Chr(NumKey))	  // display keyed number
		 		EndCase				  // fall through if not 0..9
	  	ElseIf Base == 8			  // OCT accepts [0..7]
		 		Case NumKey
		  		When 030h..037h
			 			ShowInput(Chr(NumKey))	  // display keyed number
		 		EndCase				  // fall through if not 0..7
			ElseIf Base == 2			  // BIN accepts [0,1]
				Case NumKey
		  		When 030h..031h
			 			ShowInput(Chr(NumKey))	  // display keyed number
		 			EndCase				  // fall through if not 0..7
	  	EndIf

		When 08h			  /***** BACKSPACE *****/
			If New InPut = '' EndIf
			Input = SubStr(Input,1,Length(Input)-1)  // remove last char.
	  	If Length(Input) > 0	 // as long as it has a length, 'Input'
		 		X = Val(Input,Base)  //  still has a value, update accumulator.
	  	Else
		 		X = 0			 // otherwise zero the accumulator
			EndIf
			ClrField()		  // clear the display
			Vgotoxy(FieldX,FieldY)
	  	PutLine(Format(X:MaxField-1:' ':Base,BaseLtr:1),MaxField)  // display

		When 02Bh		  /****** ADD *****/
			SetOpFlags()
			Add = True
		When 02Dh		  /****** SUBTRACT *****/
			SetOpFlags()
			Subtract = True
		When 02Ah		  /***** MULTIPLY *****/
			SetOpFlags()
			Multiply = True
		When 02Fh		  /****** DIVIDE *****/
			SetOpFlags()
			Divide = True
		When 05Ch		  /****** MODULO *****/
			SetOpFlags()
			Modulo = True
		When 026h		  /****** Bitwise AND *****/
			SetOpFlags()
			AndFlag = True
		When 07Ch		  /****** Bitwise OR *****/
			SetOpFlags()
			OrFlag = True
		When 05Eh		  /****** Bitwise XOR *****/
			SetOpFlags()
			XorFlag = True
		When 06Eh, 04Eh	  /****** Bitwise NOT *****/
			NotFlag = True
			DoMath()	  // do it now - does not affect any process in progress
		When 03Eh, 02Eh	  /****** SHR *****/
			SetOpFlags()
			ShftRt = True
		When 03Ch, 02Ch	  /****** SHL *****/
			SetOpFlags()
			ShftLt = True
		When 03Dh,0Dh  // <=> or <GreyEnter> keys
			DoMath()
			New = True
				/****** SPECIAL KEYS *****/
		When 0, 224		  // when number pad arrows or grey arrows
	  	Case Key shr 8	  // test key for extended values
		 		When 83		 // del
					X = 0
					New = True
					UpdateField()  // clear current entry
				When 115		  // ctrl left
					MoveBox(-1,0)  //	  move box left
				When 116		  // ctrl right
					MoveBox(1,0)	 //	  move box right
				When 141		  // ctrl up
					MoveBox(0,-1)  //	  move box up
				When 145		  // ctrl dn
					MoveBox(0,1)	 //	  move box dn
			EndCase
				/****** LETTER KEYS *****/
		When 057h, 077h	  // 'W','w' = binary
			BinHexDecOct(2)
		When 04Fh, 06Fh	  // 'O','o' = Octal
			BinHexDecOct(8)
		When 054h, 074h	  // 'T','t' = Decimal
			BinHexDecOct(10)
		When 058h, 078h	  // 'x','X' = HexiDecimal
			BinHexDecOct(16)
		When 048h, 068h	  // 'H' or 'h' calls help
			CalcHelp()
		When 047h, 067h	  // 'G' or 'g' get number
			If cursorNumberS == ''
		 		// do nothing
			Else
				X = Val(cursorNumberS,base)
				UpDateField()
			EndIf
		When 050h, 070h	  // 'P' or 'p' Paste X into buffer
			i = 1
			cursorNumberS = Format(x:MaxField-1:' ':Base)
			While cursorNumberS[i] == chr(32) and i < MaxField
				i = i + 1
			EndWhile
			cursorNumberS = SubStr(cursorNumberS,i,Length(cursorNumberS)) // trim leading spaces
			InsertText(' '+cursorNumberS+' ') // paste into text bracketed with spaces
			New = True		// assure that next entry is NEW
			break
		When 72h,52h		// set wordsize
			SetWordSize()
				 /****** ESCAPE KEY *****/
		When 01Bh			// Esc pressed, time to quit
			Y = X				// update
			New = True	// assure that next entry is NEW
			Break				// exit loop return to edit
		EndCase
EndLoop						// End entry loop - back to start
End GetInput
/******************************** MAIN ************************************/

Proc Main()						// Startup code ACalc.s
	If Not InitFlag			// if first use,
		InitRegs()				// inititilize vars, otherwise retain previous values
	EndIf
	// Mark current word for import
	If IsBlockMarked() PushBlock() EndIf		// save existing block marks
	If MarkWord()														// a word was markable
		cursorNumberS = GetMarkedText()							// grab it
		UnMarkBlock()													// unmark word
	Else
		cursorNumberS = ''                         	// set string to nil on failure
	EndIf
	If cursorNumberS <> '' PopBlock() EndIf       	// restore previous marking
  // end get import string
	UpDateDisplay()			// clean up any editor messages left onscreen
	Set(Cursor,Off)			// turn off cursor since it intrudes if under box
	ShadowBox(On)				// draw the shadow
	CalcBox(On)					// draw the window
	UpdateField()				// fill the fields
	GetInput()					// enter Input loop
	CalcBox(Off)				// close the calc window
	ShadowBox(Off)			// erase the shadow
	Set(Cursor,On)			// done - turn cursor back on
End Main							// Acalc.s

/**************************** EOF 'acalc.s'*********************************/

// <Ctrl centercursor>	 ExecMacro('acalc')   // my calc button
