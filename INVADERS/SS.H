binary "ss.bin"
    integer proc EnhancedShiftState() : 0
    integer proc NormalShiftState()   : 3
    integer proc BIOSShiftState()     : 6
end

constant sINSERT        = 0x80,
         sCAPS_LOCK     = 0x40,
         sNUM_LOCK      = 0x20,
         sSCROLL_LOCK   = 0x10,
         sALT           = 0x08,
         sCTRL          = 0x04,
         sLSHIFT        = 0x02,
         sRSHIFT        = 0x01,
         sSHIFT         = sLSHIFT | sRSHIFT

