//*****************************************************************************
Binary "CAPSNUMS.BIN"
   Proc CapsOff()  :  0h
   Proc CapsOn()   :  9h
   Proc NumsOff()  : 12h
   Proc NumsOn()   : 1Bh
End


//*****************************************************************************
Menu   Select()
   "CAPS OFF", CapsOff()
   "CAPS ON",  CapsOn()
   "NUMS OFF", NumsOff()
   "NUMS ON",  NumsOn()
End    Select


//*****************************************************************************
Proc   Main()
   Select()
End    Main