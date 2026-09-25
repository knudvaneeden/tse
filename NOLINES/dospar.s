
#include ["pushpar.si"]
#include ["procpar.si"]

proc WhenLoaded()
   // See par.doc.
   string dcl [128] = Query(DosCmdLine)
   integer char = Pos(" -e", Lower(dcl))
   if Pos("-e", Lower(dcl)) == 1
      char = 2
   endif
   if char
      char = char + 2
      repeat
         char = char + 1
      until dcl[char] in "", " ", ":", Chr(0)
      if dcl[char] == ":"
         Set(DosCmdLine, SubStr(dcl, 1, char - 1)
                         + procpar(SubStr(dcl, char, Length(dcl) - char + 1)))
      endif
   endif
   PurgeMacro("dospar")
end

