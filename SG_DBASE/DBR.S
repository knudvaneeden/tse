proc Main()
string pathtodb[50], word[40]

pathtodb = "c:\tse\database\database.skp"
word =""

ClrScr()
if ask ("Find what subject", word)
UpdateDisplay()

EditFile(Format( pathtodb))
if lFind("~ " + word, "gi")
Down(2)
BegLine()
else
Message(word, "not found")
Sound(444) Delay(3) NoSound()
QuitFile()
endif
endif
end

proc NextPara()
while PosFirstNonWhite()
if not Down()
goto common_exit
endif
endwhile

while PosFirstNonWhite() == 0
if not Down()
goto common_exit
endif
endwhile

common_exit:
GotoPos(PosFirstNonWhite())
Right(2) // may be taken out//
end
proc PrevPara()
if not Up()
goto common_exit
endif

while PosFirstNonWhite() == 0
if not Up()
goto common_exit
endif
endwhile

while PosFirstNonWhite()
if not Up()
goto common_exit
endif
endwhile

Down()

common_exit:
GotoPos(PosFirstNonWhite())
Right(2) // may be taken out//
end

proc Keep()

SaveBlock("d:\temp.txt")
QuitFile()
InsertFile("d:\temp.txt")
EraseDiskFile("d:\temp.txt")
UnmarkBlock()
EndLine()
InsertText(" ")
end

<Spacebar> keep() PurgeMacro("DBR")
<Ctrl CursorUp> PrevPara()
<Ctrl CursorDown>  NextPara()

