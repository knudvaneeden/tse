// Forward references (a.k.a. prototypes) for procedures contained in
// PRINTER.S.  #include this file in the main UI file right after
// the config/endconfig block.

forward integer proc PrinterReady()
forward proc PrinterWarning()
forward integer proc mPrintBlock()
forward integer proc mPrintChar(string s)
forward integer proc mPrintFile()
forward proc PrintString(string s)
forward integer proc SendPrintString(string s)
