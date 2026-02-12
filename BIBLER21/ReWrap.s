/*
   ReWrap does not set any margins, it simply rewraps the
   Scripture verses to whatever margins you have set.  It
   locates each verse of the Bible, then drops to the next
   line, leaving the address line untouched.
*/

proc Main()
   while lFind("^[A-Z1-3][A-Z][A-Z] #[0-9]#:[0-9]#", "x")
      Down()
      WrapPara()
   endwhile
end

