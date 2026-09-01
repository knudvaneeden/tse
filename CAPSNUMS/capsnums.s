/*
 * CAPSNUMS.S
 * Version 1.0.0.0.3
 *
 * TSE Pro/32 SAL demonstration for CAPSNUMS.DLL.
 */

dll "capsnums.dll"
   proc CapsOff()
   proc CapsOn()
   proc NumsOff()
   proc NumsOn()
end

menu SelectLockState()
   "CAPS OFF", CapsOff()
   "CAPS ON",  CapsOn()
   "NUMS OFF", NumsOff()
   "NUMS ON",  NumsOn()
end SelectLockState

proc Main()
   SelectLockState()
end
