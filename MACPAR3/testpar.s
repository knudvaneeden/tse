/*
   This macro reports the parameters it was called with.

   It can be used to test the various ways to call a macro
   that uses poppar().
*/

#include ["initpar.si"]

proc Main()
   string par [255] = ""
   integer counter = 0
   Set(break, ON)
   repeat
      par = poppar()
      counter = counter + 1
      if par <> ""
         Message("Par", counter, "=", par, ".")
         Delay(99)
      endif
   until par == ""
   initpar()
   PurgeMacro("testpar")
end

