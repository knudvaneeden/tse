//	BULLET.S
//	Bulleted list support for wordwrap macros.
//
//	BULLET is designed as a wrapper for you current wordwrap macro.
//	If you use WrapPara(), instead use ExecMacro("bullet -p").
//	If you use WrapLine(), instead use ExecMacro("bullet -l").
//	If you use ExecMacro("foo -x"), instead use ExecMacro("bullet foo -x").
//
//	Keys:
//	BULLET binds <Ctrl B> to bring up a Bullet Menu.  Select the bullet you
//	want to use and bingo!
//
//	Happy bulleting!
//	Chris Antos, chrisant@microsoft.com


//	BULLET uses a Global String Variable to look up a list of valid bullet
//	characters.  The name of the Global String Variable is "Bullets".  You
//	can set Bullets in your .UI file, or BULLET will automatically set it
//	with a default list of bullet characters if it is empty.


// BULLET_MENU: 1 = bind <Ctrl B> to bullet menu, 0 = don't
#define BULLET_MENU 1

// BULLET_CRETURN: 1 = bind <Enter> to auto-bullet procedure, 0 = don't
#define BULLET_CRETURN 1


integer fBullet = FALSE					// Bullet characters found.

string cmdline[255]
string bulletlist[] = "Bullets"			// Name of global string variable
string defbullets[] = "‏תשנû-*"		// Default list of bullet characters
string bullets[20]
integer ai, pes


proc FindBullets()
	//integer nCol = 0
	//string text[128]

	bullets = GetGlobalStr(bulletlist)
	fBullet = FALSE
	// try to delimit paragraph with blank lines if we detect bullet
	// characters in use.
	PushPosition()
	repeat
	until not PosFirstNonWhite() or
			Pos(Chr(CurrChar(PosFirstNonWhite())), bullets) or not Up()
	if Pos(Chr(CurrChar(PosFirstNonWhite())), bullets)
		fBullet = TRUE
		ai = Set(AutoIndent, _STICKY_)
		pes = Set(ParaEndStyle, 0)

		// insert blank line above this bullet paragraph
		InsertLine()
		PlaceMark("1")
		Down()

		/*
		PushPosition()
		if PosFirstNonWhite()
			GotoPos(PosFirstNonWhite())
			WordRight()
			nCol = CurrCol()
			text = GetText(1, PosFirstNonWhite() - 1)
		endif
		PopPosition()
		*/

		if not Down()
			AddLine()
		else
			/*
			// add hanging indent for bulleted lists
			if nCol and PosFirstNonWhite() and
					not Pos(Chr(CurrChar(PosFirstNonWhite())), bullets)
				PushPosition()
				if PosFirstNonWhite()
					GotoPos(PosFirstNonWhite())
					if CurrCol() < nCol
						BegLine()
						PushBlock()
						UnMarkBlock()
						MarkChar()
						GotoPos(PosFirstNonWhite())
						MarkChar()
						KillBlock()
						PopBlock()
						BegLine()
						InsertText(text, _INSERT_)
						GotoPos(PosFirstNonWhite())
						while nCol - CurrCol() > 0
							InsertText(" ", _INSERT_)
						endwhile
					endif
				endif
				PopPosition()
			endif
			*/

			// find bottom of this bullet paragraph and insert blank line
			repeat
			until not PosFirstNonWhite() or
					Pos(Chr(CurrChar(PosFirstNonWhite())), bullets) or
					not Down()
			if Pos(Chr(CurrChar(PosFirstNonWhite())), bullets)
				InsertLine()
			else
				AddLine()
			endif
		endif
		PlaceMark("2")
	endif
	PopPosition()
end


proc DoWrap()
	case Lower(Trim(cmdline))
		when "-p"
			WrapPara()
		when "-l"
			WrapLine()
		otherwise
			ExecMacro(cmdline)
	endcase
end


proc GotoPosFirstNonBullet()
    string ws[32]

	GotoPos(PosFirstNonWhite())
	ws = Set(WordSet, ChrSet("~ \t"))
	WordRight()
	Set(WordSet, ws)
end


proc RestoreBullets()
    integer nCol
    string text[128]

    if fBullet
		// hanging indent for bulleted lists
		PushPosition()
		// find top of bullet point
		if not PosFirstNonWhite()
			Up()
		endif
		repeat
		until not PosFirstNonWhite() or
				Pos(Chr(CurrChar(PosFirstNonWhite())), bullets) or not Up()
		if Pos(Chr(CurrChar(PosFirstNonWhite())), bullets)
			GotoPosFirstNonBullet()
			nCol = CurrCol()
			text = GetText(1, PosFirstNonWhite() - 1)
			Down()
			if PosFirstNonWhite() and not
					Pos(Chr(CurrChar(PosFirstNonWhite())), bullets)
				GotoPos(PosFirstNonWhite())
				if CurrCol() < nCol
					if CurrCol() > 1
						BegLine()
						PushBlock()
						UnMarkBlock()
						MarkChar()
						GotoPos(PosFirstNonWhite())
						MarkChar()
						KillBlock()
						PopBlock()
					endif
					BegLine()
					InsertText(text, _INSERT_)
					GotoPos(PosFirstNonWhite())
					while nCol - CurrCol() > 0
						InsertText(" ", _INSERT_)
					endwhile
					DoWrap()
				endif
			endif
		endif
		PopPosition()

		// remove blank line delimiters
		Set(AutoIndent, ai)
		Set(ParaEndStyle, pes)
		fBullet = FALSE
		PushPosition()
		GotoMark("1")
		DelBookMark("1")
		KillLine()
		GotoMark("2")
		DelBookMark("2")
		KillLine()
		PopPosition()
	endif
end


#if BULLET_CRETURN
integer proc BulletCReturn()
	integer fBullet = FALSE
	string bullet[128]
	integer nCol

	if Query(WordWrap) > 0
		// auto bullets
		bullets = GetGlobalStr(bulletlist)
		PushPosition()
		repeat
		until not PosFirstNonWhite() or
				Pos(Chr(CurrChar(PosFirstNonWhite())), bullets) or not Up()
		if PosFirstNonWhite() and Pos(Chr(CurrChar(PosFirstNonWhite())), bullets)
			GotoPos(PosFirstNonWhite())
			nCol = CurrCol()
			GotoPosFirstNonBullet()
			bullet = GetText(PosFirstNonWhite(), CurrPos()-PosFirstNonWhite())
			if Length(bullet) > 1 and bullet[2] <> bullet[1] and
					(Pos(" ", bullet) == 2 or Pos(Chr(9), bullet) == 2)
				fBullet = TRUE
			endif
		endif
		PopPosition()
	endif

	if not CReturn()
		return (FALSE)
	endif

	if fBullet
		GotoColumn(nCol)
		return (InsertText(bullet, _INSERT_))
	endif

	return (TRUE)
end
#endif


proc WhenLoaded()
	if GetGlobalStr(bulletlist) == ""
		SetGlobalStr(bulletlist, defbullets)
	endif
end


proc Main()
	cmdline = Query(MacroCmdLine)

	if not Length(Trim(cmdline))
		return()
	endif

	bullets = GetGlobalStr(bulletlist)
	FindBullets()
	DoWrap()
	RestoreBullets()
end


#if BULLET_MENU
menu BulletMenu()
	history = 3
	command = InsertText(MenuStr(BulletMenu, MenuOption())+" ", _INSERT_)

    "‏"
    "ת"
    "ש"
    ""
    ""
    "נ"
    "û"
end
<Ctrl B>	BulletMenu()
#endif


#if BULLET_CRETURN
<Enter>		BulletCReturn()
#endif
