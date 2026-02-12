/*************************************************************************
Macro Name: DataBase Version 1.3

Copyright 1996 Skip Gore <sg@peganet.com> All Rights Reserved Worldwide.

Date: Monday, September 30, 1996

Permission is granted to all persons for non-commercial distribution of
this file and the macros and ideas contained herein provided (a) credit
is given to the author and (b) all changes not made by the author are
attributed.

Permission is granted to SemWare for commercial distribution provided
(a) and (b) above.

I would like to personally thank george de bruin of Semware's Technical
Support Staff for all the help.  Additionally I would appreciate a copy
of any and all modifications.  Send via E-Mail to: sg@peganet.com

Over View:
This macro allows you to save text information of any size to a free
form database.  From the file you have loaded mark a block of text and
execute "DB"  A menu will pop up giving you choices.  Select save to
database.  You will be prompted for "Trigger" name.  This is a trigger
that you can recall at a later date.  You can enter more than one
trigger.  In fact you can enter as many as you want as you are prompted.
When you're finished entering triggers, hit the escape key and your
saved block will be saved to the database.

To retrieve data from the database select retrieve information.  You
will be prompted for a trigger name.  Type in the name and the database
will locate the information.  Mark the block of text you wan inserted
into your current file and select "Keep" whereupon the information will
be dumped into your current file and the database goes away.

You might want to edit this file to change the path and filename
structure.  Also the keys at the end of the file can be reassigned.

*************************************************************************/

proc CheckBreak()
if KeyPressed() and GetKey() == <Escape>
Alarm()
endif
end

integer proc mDelChar()
return(iif(CurrChar() >= 0, DelChar(), JoinLine()))
end

proc DBS()

string pathtodb[50], word[50]

pathtodb = "c:\tse\database\database.skp"
word =""

ClrScr()
while ask ("Enter a Trigger name", word) and length(word)
EditFile(Format( pathtodb))
EndFile() //where information will be inserted//
InsertText(" ~ " + word)
PushBlock()
UnmarkBlock()
MarkLine()
SaveBlock("c:\tse\database\temp.txt", _APPEND_) //triggers are saved//
UnMarkBlock()
PopBlock()
message("*Finished for word: ", word)
Sound(400) Delay(1) NoSound()
endwhile //escape starts the following//
BegLine()
CReturn()
Right()
BackSpace()
EndLine()
CReturn()
CReturn()
CopyBlock()
UnmarkBlock()
PushKey(<y>)
QuitFile() //information has been saved//
Sound(400) Delay(1) NoSound()
EditFile("c:\tse\database\temp.txt") //putting triggers into order//
EndFile()
EndLine()
CReturn()
BegFile()
BegLine()
MarkChar()
EndFile()
Up()
BegLine()
MarkChar()
DelBlock()
UnmarkBlock()
mDelChar()
mDelChar()
Repeat
Find("~", "i") //separating triggers//
Left()
mDelChar()
SplitLine()
Down()
Until Not RepeatFind()
BegFile()
Replace("^ ", "", "ignx")
EndFile()
DelLine()
BegLine()
Replace("~ ", "", "ignx")
BegFile()
BegLine()
MarkStream()
EndFile()
EndLine()
MarkStream()
SaveBlock("c:\tse\database\topics.txt", _APPEND_) //triggers are now
//saved//
Pushkey(<y>)
QuitFile()
EraseDiskFile("c:\tse\database\temp.txt")
end

proc DBR()

string pathtodb[50], word[40]

pathtodb = "c:\tse\database\database.skp"
word =""

ClrScr()
if ask ("Enter a Trigger Name", word)
UpdateDisplay()

EditFile(Format( pathtodb))
Find("~ " + word, "gi")
endif
Down(2)
end

proc Keep()

     SaveBlock("c:\temp.txt")
PushKey(<y>)
QuitFile()
InsertFile("c:\temp.txt")
EraseDiskFile("c:\temp.txt")
UnmarkBlock()
EndLine()
InsertText(" ")
end

proc TL()
EditFile(Format("c:\tse\database\topics.txt")) //displaying what's
//available//
end

          proc DBL()

    string word[80] = ""

BegLine() //standing on item you want to display//
MarkLine()
if MarkLine()
          SaveBlock("c:\temp.txt")
QuitFile()
EditFile(format("c:\tse\database\database.skp")) //information
//displayed//
BegFile()
InsertFile("c:\temp.txt")
BegLine()
MarkLine()
if MarkLine()
          Find("~ "+GetMarkedText(), "i")
Down(2)
BegLine()
PushPosition()
BegFile()
DelLine()
EraseDiskFile("c:\temp.txt")
PopPosition()
else
Message(word, "not found")
Sound(444) Delay(3) NoSound()
QuitFile()
endif
endif
end

menu MacroMenu()

"&1 equals Save to database", DBS()
"&2 equals Retrieve from database", DBR()
"&3 equals What's available", TL()
"&4 equals Choose what's available", DBL()
"&5 equals Insert information into current file", Keep()
end

proc Main()
ClrScr()
MacroMenu()
UpdateDisplay()
end

<Spacebar> keep() PurgeMacro("DBR")

