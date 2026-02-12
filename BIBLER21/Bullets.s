/*

                      BULLET OPERATIONS

Each Major Division begins with a major bullet [*] and a space.
Each Minor Division begins with a minor bullet [~] and a space.

Each file should end with an Major bullet [*] and a space plus at
least one non-white character, such as "* End . . ." to allow for
procs that use a marked block to have an ending point.

Objective for the "ShowMinors()" proc: from anywhere between one Major [*]
bullet and the next, display a picklist of all lines between those Major
[*] bullets that begin with a Minor [~]bullet. This currently works only
in Psalms and Proverbs, making it easier to jump to a particular Psalm
or chapter in Proverbs.

This produces a much shorter list and should prove more useful than
listing all the Minor [~] bullets in the entire file.  But there may be
times when you NEED a listing of all the Minor [~] bullets in the
entire file: choose '9' on the bullet menu for that listing.

Provided also is a way to jump from your current location to the
beginning of the next chapter (choose "C" on the Bullet Operations
menu).  If you prefer, choose "A" which will display a picklist of all
chapters in the current book.  Press <Enter> or click to move to the
first verse of any chapter.

This should work equally well with Scripture files and other text
files that make use of the Major/Minor bullet system.  I have many
home-made database files using Major and Minor symbols (using a font
that allows upper-ascii characters).

Menu Item 0 (zero) includes both  [*~]  which causes the major header
to be displayed at the top of the picklist of minor headers in order
to identify the major division that is being expanded to include minor
divisions.

Menu item 3 (bullet insertion) remains the same, as this is intended
for use only in cases where there are/will be minor divisions -- a
simple replace("* ", "*~ ", "1") is an easy way to add the double
bullet where desired.

The author always has 'EquateEnhancedKBD' and 'NumberLock' both set to
'Off' -- If you prefer these 'ON' you may need to assign this menu to some
key other than <CenterCursor> on the keypad.  I just wanted a single
key because I use these operations many times every day.

If you find that you use these enough that you remember the key to
press and don't like the menu coming up every time, here is a little
trick I use: uncomment the "Delay(24)" in the Main() proc below and
adjust the length of the delay to suit your taste.  This will allow
you to hit the key and perform the action without the momentary flash
of the menu each time.  But when you need a lesser-used operation,
just hesitate a little and the menu will appear.

*/

proc ShowMinors()  // between two Majors
   if CurrChar() == Asc("*")
      Down()
      MarkLine()
   else
   lFind("*", "b")
      Down()
      MarkLine()
   endif

   lFind("*", "")
   MarkLine()

   GotoBlockBegin()
   Find("~", "lv")
   UnmarkBlock()
end

proc ShowChapters()  // between two Majors
   if CurrChar() == Asc("*")
      Down()
      MarkLine()
   else
      lFind("*", "b")
      Down()
      MarkLine()
   endif

   lFind("*", "")
   Up()
   MarkLine()

   GotoBlockBegin()
   Find(":1", "$lv")
   UnmarkBlock()
end

menu BulletOperations()
   Title = "Bullet Operations"
   x = 20
   y = 4

   "&1 Show all [*] Bullets in this file  ", lFind("*", "v")
   "&2 Show [~] Bullets in this book      ", ShowMinors()
   ""                        ,                 ,Divide
   "&3 Insert [*] bullet                  ", InsertText("*", _INSERT_)
   "&4 Next [*] bullet                    ", Find("*", "+")
   "&5 Prev [*] bullet                    ", Find("*", "b")
   ""                        ,                 ,Divide
   "&6 Insert [~] bullet                  ", InsertText("~ ", _INSERT_)
   "&7 Next [~] bullet                    ", lFind("~", "+")
   "&8 Prev [~] bullet                    ", lFind("~", "b")
   ""                        ,                 ,Divide
   "&9 Show All [~] in this file          ", lFind("~", "v")
   "&0 Show All [*] and [~] in this file  ", lFind("[*~]", "xv")

   "&C Go to next chapter                 ", lFind(":1$", "x+")
   "&A Show all chapters in this book     ", ShowChapters()
end

proc Main()
   // Delay(24)
   BulletOperations()
end

