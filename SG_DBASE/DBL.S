proc Main()
    string word[80] = ""

BegLine()
//MarkWord()
//If MarkWord()
MarkLine()
if MarkLine()
          SaveBlock("c:\temp.txt")
EditFile(format("c:\tse\database\database.skp"))
BegFile()
InsertFile("c:\temp.txt")
BegLine()
//MarkWord()
//if MarkWord()
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

